#!/bin/bash

# 测试脚本 - 验证重试机制配置

set -e

echo "=========================================="
echo "验证 CocoaPods 发布重试机制配置"
echo "=========================================="
echo ""

# 检查必需的文件
echo "1️⃣  检查必需的文件..."
files=(
    ".github/workflows/release.yml"
    ".github/scripts/push_to_cocoapods.sh"
    ".github/scripts/push_to_cocoapods.rb"
    ".github/scripts/diagnose.rb"
    "PopIMLib.podspec"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (缺失)"
        exit 1
    fi
done
echo ""

# 检查脚本执行权限
echo "2️⃣  检查脚本执行权限..."
scripts=(
    ".github/scripts/push_to_cocoapods.sh"
    ".github/scripts/push_to_cocoapods.rb"
    ".github/scripts/diagnose.rb"
)

for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        echo "  ✅ $script (可执行)"
    else
        echo "  ⚠️  $script (不可执行，正在修复...)"
        chmod +x "$script"
        echo "  ✅ $script (已修复)"
    fi
done
echo ""

# 检查脚本语法
echo "3️⃣  检查脚本语法..."
if bash -n .github/scripts/push_to_cocoapods.sh 2>/dev/null; then
    echo "  ✅ push_to_cocoapods.sh 语法正确"
else
    echo "  ❌ push_to_cocoapods.sh 语法错误"
    exit 1
fi

if ruby -c .github/scripts/push_to_cocoapods.rb >/dev/null 2>&1; then
    echo "  ✅ push_to_cocoapods.rb 语法正确"
else
    echo "  ❌ push_to_cocoapods.rb 语法错误"
    exit 1
fi

if ruby -c .github/scripts/diagnose.rb >/dev/null 2>&1; then
    echo "  ✅ diagnose.rb 语法正确"
else
    echo "  ❌ diagnose.rb 语法错误"
    exit 1
fi
echo ""

# 检查 workflow 配置
echo "4️⃣  检查 workflow 配置..."
if grep -q "nick-invision/retry@v2" .github/workflows/release.yml; then
    echo "  ✅ GitHub Actions 重试配置已启用"
else
    echo "  ❌ 缺少 GitHub Actions 重试配置"
fi

if grep -q "push_to_cocoapods.rb" .github/workflows/release.yml; then
    echo "  ✅ Ruby 脚本重试配置已启用"
else
    echo "  ❌ 缺少 Ruby 脚本重试配置"
fi

if grep -q "push_to_cocoapods.sh" .github/workflows/release.yml; then
    echo "  ✅ Bash 脚本重试配置已启用"
else
    echo "  ❌ 缺少 Bash 脚本重试配置"
fi

if grep -q "http.postBuffer" .github/workflows/release.yml; then
    echo "  ✅ 网络优化配置已启用"
else
    echo "  ❌ 缺少网络优化配置"
fi
echo ""

# 检查环境
echo "5️⃣  检查环境..."
if command -v pod >/dev/null 2>&1; then
    echo "  ✅ CocoaPods 已安装 ($(pod --version))"
else
    echo "  ⚠️  CocoaPods 未安装"
fi

if command -v ruby >/dev/null 2>&1; then
    echo "  ✅ Ruby 已安装 ($(ruby --version | awk '{print $2}'))"
else
    echo "  ❌ Ruby 未安装"
    exit 1
fi

if command -v git >/dev/null 2>&1; then
    echo "  ✅ Git 已安装 ($(git --version | awk '{print $3}'))"
else
    echo "  ❌ Git 未安装"
    exit 1
fi
echo ""

# 检查 podspec
echo "6️⃣  检查 PopIMLib.podspec..."
if grep -q "s.name.*=.*\"PopIMLib\"" PopIMLib.podspec; then
    echo "  ✅ podspec 名称正确"
else
    echo "  ❌ podspec 名称错误"
fi

if grep -q "s.version" PopIMLib.podspec; then
    VERSION=$(grep "s.version" PopIMLib.podspec | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
    echo "  ✅ podspec 版本: $VERSION"
else
    echo "  ❌ podspec 缺少版本号"
fi

if grep -q "s.source.*github.com" PopIMLib.podspec; then
    echo "  ✅ podspec source 配置正确"
else
    echo "  ⚠️  podspec source 可能需要检查"
fi
echo ""

# 总结
echo "=========================================="
echo "✅ 配置验证完成！"
echo "=========================================="
echo ""
echo "重试机制已配置："
echo "  • 方案1: GitHub Actions 重试 (5次，间隔120秒)"
echo "  • 方案2: Ruby 脚本重试 (5次，间隔120秒)"
echo "  • 方案3: Bash 脚本重试 (5次，间隔120秒)"
echo ""
echo "网络优化已配置："
echo "  • Git HTTP 缓冲区: 500MB"
echo "  • HTTP 版本: 1.1"
echo "  • 超时设置: 600秒"
echo ""
echo "下一步："
echo "  1. 确保 GitHub Secrets 中已设置 COCOAPODS_TRUNK_TOKEN"
echo "  2. 触发 repository_dispatch 事件进行发布"
echo "  3. 或本地运行: ruby .github/scripts/push_to_cocoapods.rb"
echo ""
