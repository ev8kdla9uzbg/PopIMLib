#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'timeout'

# 颜色输出
class Colors
  RESET = "\033[0m"
  RED = "\033[0;31m"
  GREEN = "\033[0;32m"
  YELLOW = "\033[1;33m"
  BLUE = "\033[0;34m"
  CYAN = "\033[0;36m"
end

def log_section(message)
  puts "\n#{Colors::CYAN}#{'=' * 60}#{Colors::RESET}"
  puts "#{Colors::CYAN}#{message}#{Colors::RESET}"
  puts "#{Colors::CYAN}#{'=' * 60}#{Colors::RESET}\n"
end

def log_info(message)
  puts "#{Colors::BLUE}ℹ️  #{message}#{Colors::RESET}"
end

def log_success(message)
  puts "#{Colors::GREEN}✅ #{message}#{Colors::RESET}"
end

def log_warning(message)
  puts "#{Colors::YELLOW}⚠️  #{message}#{Colors::RESET}"
end

def log_error(message)
  puts "#{Colors::RED}❌ #{message}#{Colors::RESET}"
end

# 检查 HTTP 连接
def check_http_connection(url, name, timeout = 10)
  log_info("检查 #{name}: #{url}")

  start_time = Time.now

  begin
    uri = URI(url)

    Timeout.timeout(timeout) do
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                                  open_timeout: timeout, read_timeout: timeout) do |http|
        http.request(Net::HTTP::Get.new(uri))
      end

      elapsed = (Time.now - start_time).round(2)

      if response.is_a?(Net::HTTPSuccess) || response.code.to_i < 500
        log_success("#{name} 可访问 (#{response.code}) - 耗时: #{elapsed}s")

        # 检查 keep-alive
        if response['connection']
          log_info("  Connection header: #{response['connection']}")
        end

        if response['keep-alive']
          log_info("  Keep-Alive header: #{response['keep-alive']}")
        end

        return { success: true, code: response.code, time: elapsed }
      else
        log_error("#{name} 返回错误码: #{response.code}")
        return { success: false, code: response.code, time: elapsed }
      end
    end
  rescue Timeout::Error
    elapsed = (Time.now - start_time).round(2)
    log_error("#{name} 连接超时 (#{timeout}s) - 实际耗时: #{elapsed}s")
    return { success: false, error: 'timeout', time: elapsed }
  rescue => e
    elapsed = (Time.now - start_time).round(2)
    log_error("#{name} 连接失败: #{e.class} - #{e.message}")
    return { success: false, error: e.message, time: elapsed }
  end
end

# 检查 GitHub 状态
def check_github_status
  log_section('检查 GitHub 服务状态')

  result = check_http_connection('https://www.githubstatus.com/api/v2/status.json', 'GitHub Status API')

  if result[:success]
    begin
      uri = URI('https://www.githubstatus.com/api/v2/status.json')
      response = Net::HTTP.get(uri)
      status = JSON.parse(response)

      log_info("GitHub 状态: #{status['status']['description']}")
      log_info("最后更新: #{status['page']['updated_at']}")

      # 检查组件状态
      if status['components']
        log_info("\n组件状态:")
        status['components'].each do |component|
          status_emoji = component['status'] == 'operational' ? '✅' : '⚠️'
          puts "  #{status_emoji} #{component['name']}: #{component['status']}"
        end
      end
    rescue => e
      log_warning("无法解析 GitHub 状态: #{e.message}")
    end
  end

  # 检查 GitHub API
  check_http_connection('https://api.github.com', 'GitHub API')
end

# 检查 CocoaPods Trunk 状态
def check_cocoapods_status
  log_section('检查 CocoaPods Trunk 状态')

  endpoints = [
    ['https://trunk.cocoapods.org/', 'CocoaPods Trunk 主页'],
    ['https://trunk.cocoapods.org/api/v1/sessions', 'CocoaPods Trunk API'],
    ['https://cdn.cocoapods.org/', 'CocoaPods CDN']
  ]

  endpoints.each do |url, name|
    check_http_connection(url, name)
    sleep(1)
  end
end

# 检查网络配置
def check_network_config
  log_section('检查网络配置')

  # Git 配置
  log_info("Git HTTP 配置:")
  [
    'http.postBuffer',
    'http.lowSpeedLimit',
    'http.lowSpeedTime',
    'http.version'
  ].each do |key|
    value = `git config --global #{key}`.strip
    if value.empty?
      log_warning("  #{key}: 未设置")
    else
      log_success("  #{key}: #{value}")
    end
  end

  # 环境变量
  log_info("\n环境变量:")
  [
    'RUBY_HTTP_TIMEOUT',
    'COCOAPODS_TRUNK_TIMEOUT',
    'HTTP_PROXY',
    'HTTPS_PROXY',
    'NO_PROXY'
  ].each do |key|
    value = ENV[key]
    if value
      log_success("  #{key}: #{value}")
    else
      log_info("  #{key}: 未设置")
    end
  end
end

# 检查 CocoaPods 配置
def check_cocoapods_config
  log_section('检查 CocoaPods 配置')

  # CocoaPods 版本
  version = `pod --version`.strip
  log_info("CocoaPods 版本: #{version}")

  # Ruby 版本
  log_info("Ruby 版本: #{RUBY_VERSION}")

  # 检查 trunk token
  if ENV['COCOAPODS_TRUNK_TOKEN']
    token = ENV['COCOAPODS_TRUNK_TOKEN']
    masked_token = "#{token[0..5]}...#{token[-4..-1]}"
    log_success("COCOAPODS_TRUNK_TOKEN: #{masked_token}")
  else
    log_error("COCOAPODS_TRUNK_TOKEN: 未设置")
  end

  # 检查 podspec
  if File.exist?('PopIMLib.podspec')
    log_success("PopIMLib.podspec: 存在")

    # 读取版本号
    content = File.read('PopIMLib.podspec')
    if content =~ /s\.version\s*=\s*["']([^"']+)["']/
      log_info("  版本号: #{$1}")
    end
  else
    log_error("PopIMLib.podspec: 不存在")
  end
end

# 测试 DNS 解析
def check_dns
  log_section('检查 DNS 解析')

  hosts = [
    'trunk.cocoapods.org',
    'cdn.cocoapods.org',
    'api.github.com',
    'github.com'
  ]

  hosts.each do |host|
    begin
      require 'resolv'
      addresses = Resolv.getaddresses(host)

      if addresses.empty?
        log_error("#{host}: DNS 解析失败")
      else
        log_success("#{host}: #{addresses.join(', ')}")
      end
    rescue => e
      log_error("#{host}: DNS 解析错误 - #{e.message}")
    end
  end
end

# 主函数
def main
  log_section('CocoaPods 推送诊断工具')
  log_info("开始诊断 - #{Time.now}")

  check_network_config
  check_cocoapods_config
  check_dns
  check_github_status
  check_cocoapods_status

  log_section('诊断完成')
  log_info("结束时间: #{Time.now}")

  puts "\n#{Colors::YELLOW}建议:#{Colors::RESET}"
  puts "1. 如果 GitHub 或 CocoaPods 服务异常，等待服务恢复后重试"
  puts "2. 如果 DNS 解析失败，检查网络连接和 DNS 设置"
  puts "3. 如果连接超时，考虑增加超时时间或使用代理"
  puts "4. 如果 COCOAPODS_TRUNK_TOKEN 未设置，请设置该环境变量"
end

main if __FILE__ == $PROGRAM_NAME
