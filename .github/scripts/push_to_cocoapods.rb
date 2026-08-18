#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'timeout'
require 'json'

# 配置
PODSPEC_FILE = 'PopIMLib.podspec'
MAX_ATTEMPTS = 5
RETRY_DELAY = 120
HTTP_TIMEOUT = 600

# 颜色输出
class Colors
  RESET = "\033[0m"
  RED = "\033[0;31m"
  GREEN = "\033[0;32m"
  YELLOW = "\033[1;33m"
  BLUE = "\033[0;34m"
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

def log_section(message)
  puts "\n#{Colors::YELLOW}#{'=' * 50}#{Colors::RESET}"
  puts "#{Colors::YELLOW}#{message}#{Colors::RESET}"
  puts "#{Colors::YELLOW}#{'=' * 50}#{Colors::RESET}\n"
end

# 配置网络设置
def configure_network
  log_section('配置网络设置')

  # 配置 Git
  system('git config --global http.postBuffer 524288000')
  system('git config --global http.lowSpeedLimit 0')
  system('git config --global http.lowSpeedTime 999999')
  system('git config --global http.version HTTP/1.1')

  # 设置环境变量
  ENV['RUBY_HTTP_TIMEOUT'] = HTTP_TIMEOUT.to_s
  ENV['COCOAPODS_TRUNK_TIMEOUT'] = HTTP_TIMEOUT.to_s

  # 配置 Ruby Net::HTTP 的默认超时
  Net::HTTP.class_eval do
    alias_method :original_initialize, :initialize

    def initialize(*args)
      original_initialize(*args)
      @open_timeout = HTTP_TIMEOUT
      @read_timeout = HTTP_TIMEOUT
      @write_timeout = HTTP_TIMEOUT if respond_to?(:write_timeout=)
    end
  end

  log_success('网络配置完成')
end

# 检查服务状态
def check_service_status
  log_section('检查服务状态')

  # 检查 GitHub
  begin
    uri = URI('https://www.githubstatus.com/api/v2/status.json')
    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      status = JSON.parse(response.body)
      log_success("GitHub 状态: #{status['status']['description']}")
    else
      log_warning('GitHub 状态检查返回非 200 响应')
    end
  rescue => e
    log_warning("GitHub 状态检查失败: #{e.message}")
  end

  # 检查 CocoaPods Trunk
  begin
    uri = URI('https://trunk.cocoapods.org/api/v1/sessions')
    response = Net::HTTP.get_response(uri)
    if response.code.to_i < 500
      log_success('CocoaPods Trunk 可访问')
    else
      log_warning("CocoaPods Trunk 返回: #{response.code}")
    end
  rescue => e
    log_warning("CocoaPods Trunk 检查失败: #{e.message}")
  end
end

# 清理 CocoaPods 缓存
def clean_cache
  log_info('清理 CocoaPods 缓存...')
  system('pod cache clean --all 2>/dev/null')
rescue => e
  log_warning("缓存清理失败: #{e.message}")
end

# 验证 podspec
def validate_podspec
  log_section("验证 #{PODSPEC_FILE}")

  cmd = "pod lib lint #{PODSPEC_FILE} --allow-warnings --skip-import-validation --verbose"
  log_info("执行: #{cmd}")

  system(cmd)
end

# 推送到 CocoaPods（单次尝试）
def push_attempt
  cmd = "pod trunk push #{PODSPEC_FILE} --allow-warnings --skip-import-validation --skip-tests --verbose --synchronous"
  log_info("执行: #{cmd}")

  # 使用 system 并捕获退出状态
  system(cmd)
  $?.success?
end

# 推送到 CocoaPods（带重试）
def push_to_cocoapods
  log_section('推送到 CocoaPods')

  attempt = 1

  while attempt <= MAX_ATTEMPTS
    log_section("尝试 #{attempt}/#{MAX_ATTEMPTS}")

    begin
      if push_attempt
        log_success('推送成功！')
        return true
      else
        log_error("尝试 #{attempt} 失败")

        if attempt < MAX_ATTEMPTS
          log_warning("等待 #{RETRY_DELAY} 秒后重试...")
          sleep(RETRY_DELAY)

          # 清理缓存
          clean_cache

          attempt += 1
        else
          log_error('所有尝试均失败')
          return false
        end
      end
    rescue Timeout::Error => e
      log_error("超时错误: #{e.message}")

      if attempt < MAX_ATTEMPTS
        log_warning("等待 #{RETRY_DELAY} 秒后重试...")
        sleep(RETRY_DELAY)
        attempt += 1
      else
        return false
      end
    rescue Interrupt
      log_error('用户中断')
      exit(1)
    rescue => e
      log_error("未预期的错误: #{e.class} - #{e.message}")
      log_error(e.backtrace.join("\n"))

      if attempt < MAX_ATTEMPTS
        log_warning("等待 #{RETRY_DELAY} 秒后重试...")
        sleep(RETRY_DELAY)
        attempt += 1
      else
        return false
      end
    end
  end

  false
end

# 验证发布
def verify_publication
  log_section('验证发布')

  max_verify_attempts = 3
  verify_attempt = 1

  while verify_attempt <= max_verify_attempts
    log_info("验证尝试 #{verify_attempt}/#{max_verify_attempts}")

    # 等待 CDN 同步
    sleep(60)

    result = `pod search PopIMLib --simple 2>/dev/null`
    if result.include?('PopIMLib')
      log_success('发布验证成功！')
      puts result.lines.take(10).join
      return true
    else
      log_warning("验证尝试 #{verify_attempt} 未找到 pod，可能是 CDN 同步延迟")
      verify_attempt += 1
    end
  end

  log_warning('无法验证发布，但这可能只是 CDN 同步延迟')
  log_info('请稍后手动验证: pod search PopIMLib')
  true
end

# 主流程
def main
  log_section('开始 CocoaPods 推送流程')

  # 检查 podspec 文件是否存在
  unless File.exist?(PODSPEC_FILE)
    log_error("找不到 #{PODSPEC_FILE} 文件")
    exit(1)
  end

  configure_network
  check_service_status

  # 可选：先验证 podspec
  # validate_podspec

  if push_to_cocoapods
    verify_publication
    log_section('✅ 发布流程完成')
    exit(0)
  else
    log_section('❌ 发布流程失败')
    exit(1)
  end
end

# 运行主流程
main if __FILE__ == $PROGRAM_NAME
