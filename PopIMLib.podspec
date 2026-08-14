Pod::Spec.new do |s|
  # 1. 基本信息
  s.name         = "PopIMLib"                # 组件名称（必填）
  s.version      = "1.1.5.2"                # 版本号（必填，需与后续 tag 一致）
  s.summary      = "IM聊天"  # 简短描述（必填）
  s.description  = <<-DESC                # 详细描述（可选，需比 summary 长）
                   YCIMLibSDK是一套功能完备的即时通讯开发工具包，提供稳定高效的即时消息收发、会话管理、用户状态同步、推送集成等核心能力，支持 iOS 平台的 Swift 与 Objective-C 混编项目，帮助开发者快速构建具备即时通讯功能的应用
                   DESC
  s.homepage     = "https://github.com/ev8kdla9uzbg/PopIMLib"  # 项目主页（必填，如 GitHub 地址）

  # 2. 授权信息
  s.license      = { :type => "MIT", :file => "LICENSE" }  # 许可证（必填）
  s.author       = { "PopIM" => "zhenwen.wu@v.show" }      # 作者信息（必填）

  # 3. 源码/二进制位置
  s.source       = { :git => "https://github.com/ev8kdla9uzbg/PopIMLib.git", :tag => s.version.to_s }  # 代码仓库地址（必填）

  # 4. 平台与版本支持
  s.platform     = :ios, "12.0"           # 支持的平台及最低版本（必填）
  s.swift_version = "5.0"                 # 若为 Swift 框架，指定 Swift 版本（可选）

  # 5. 二进制框架配置（核心）
  s.vendored_frameworks = "PopIMLib/PopIMLib.xcframework"  # 指定 Framework 路径（必填，相对于 podspec 位置）
  s.static_framework = true  # 强制生成静态库

  # 6. 依赖配置（可选）
  s.frameworks   = "Foundation", "UIKit"  # 依赖的系统框架
  
  # 7. 编译配置（可选，解决路径或符号问题）
  s.pod_target_xcconfig = {
    'MACH_O_TYPE' => 'staticlib',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    "FRAMEWORK_SEARCH_PATHS" => "$(SRCROOT)/**",  # 框架搜索路径
    "OTHER_LDFLAGS" => "-ObjC"                    # 若包含 OC 代码，需添加此标记
  }
end
    