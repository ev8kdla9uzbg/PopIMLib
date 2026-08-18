#!/bin/bash

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
PODSPEC_FILE="PopIMLib.podspec"
MAX_ATTEMPTS=5
RETRY_DELAY=120
TIMEOUT=600

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}CocoaPods 推送脚本（带重试机制）${NC}"
echo -e "${GREEN}========================================${NC}"

# 配置网络设置
configure_network() {
    echo -e "${YELLOW}配置网络设置...${NC}"

    # Git HTTP 配置
    git config --global http.postBuffer 524288000
    git config --global http.lowSpeedLimit 0
    git config --global http.lowSpeedTime 999999
    git config --global http.version HTTP/1.1

    # 设置超时环境变量
    export RUBY_HTTP_TIMEOUT=$TIMEOUT
    export COCOAPODS_TRUNK_TIMEOUT=$TIMEOUT

    echo -e "${GREEN}✅ 网络配置完成${NC}"
}

# 检查服务状态
check_service_status() {
    echo -e "${YELLOW}检查服务状态...${NC}"

    # 检查 GitHub
    if curl -f -s -m 10 https://www.githubstatus.com/api/v2/status.json > /dev/null 2>&1; then
        echo -e "${GREEN}✅ GitHub 状态正常${NC}"
    else
        echo -e "${YELLOW}⚠️  GitHub 状态检查失败（可能不影响发布）${NC}"
    fi

    # 检查 CocoaPods Trunk
    if curl -f -s -m 10 https://trunk.cocoapods.org/ > /dev/null 2>&1; then
        echo -e "${GREEN}✅ CocoaPods Trunk 状态正常${NC}"
    else
        echo -e "${YELLOW}⚠️  CocoaPods Trunk 状态检查失败${NC}"
    fi
}

# 推送到 CocoaPods（带重试）
push_to_cocoapods() {
    local attempt=1

    while [ $attempt -le $MAX_ATTEMPTS ]; do
        echo -e "${YELLOW}========================================${NC}"
        echo -e "${YELLOW}尝试 $attempt/$MAX_ATTEMPTS 推送到 CocoaPods...${NC}"
        echo -e "${YELLOW}========================================${NC}"

        # 执行推送
        if pod trunk push "$PODSPEC_FILE" \
            --allow-warnings \
            --skip-import-validation \
            --verbose \
            --synchronous; then
            echo -e "${GREEN}========================================${NC}"
            echo -e "${GREEN}✅ 推送成功！${NC}"
            echo -e "${GREEN}========================================${NC}"
            return 0
        else
            local exit_code=$?
            echo -e "${RED}========================================${NC}"
            echo -e "${RED}❌ 尝试 $attempt 失败 (退出码: $exit_code)${NC}"
            echo -e "${RED}========================================${NC}"

            if [ $attempt -lt $MAX_ATTEMPTS ]; then
                echo -e "${YELLOW}等待 ${RETRY_DELAY} 秒后重试...${NC}"
                sleep $RETRY_DELAY

                # 清理可能的缓存
                echo -e "${YELLOW}清理 CocoaPods 缓存...${NC}"
                pod cache clean --all 2>/dev/null || true

                attempt=$((attempt + 1))
            else
                echo -e "${RED}========================================${NC}"
                echo -e "${RED}❌ 所有尝试均失败${NC}"
                echo -e "${RED}========================================${NC}"
                return 1
            fi
        fi
    done
}

# 验证发布
verify_publication() {
    echo -e "${YELLOW}验证发布...${NC}"

    local max_verify_attempts=3
    local verify_attempt=1

    while [ $verify_attempt -le $max_verify_attempts ]; do
        echo -e "${YELLOW}验证尝试 $verify_attempt/$max_verify_attempts...${NC}"

        # 等待 CDN 同步
        sleep 60

        if pod search PopIMLib --simple 2>/dev/null | grep -q "PopIMLib"; then
            echo -e "${GREEN}✅ 发布验证成功！${NC}"
            pod search PopIMLib --simple | head -10
            return 0
        else
            echo -e "${YELLOW}⚠️  验证尝试 $verify_attempt 未找到 pod，可能是 CDN 同步延迟${NC}"
            verify_attempt=$((verify_attempt + 1))
        fi
    done

    echo -e "${YELLOW}⚠️  无法验证发布，但这可能只是 CDN 同步延迟${NC}"
    echo -e "${YELLOW}请稍后手动验证: pod search PopIMLib${NC}"
    return 0
}

# 主流程
main() {
    configure_network
    check_service_status

    if push_to_cocoapods; then
        verify_publication
        exit 0
    else
        exit 1
    fi
}

main
