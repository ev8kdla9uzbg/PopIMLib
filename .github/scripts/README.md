# CocoaPods 发布脚本

## 脚本说明

- `push_to_cocoapods.sh` - Bash 重试脚本
- `push_to_cocoapods.rb` - Ruby 重试脚本（推荐）
- `diagnose.rb` - 诊断工具
- `verify_config.sh` - 配置验证脚本

## 使用方法

### 自动发布（CI/CD）
触发 repository_dispatch 事件，workflow 会自动执行三层重试机制。

### 本地发布

```bash
# 设置环境变量
export COCOAPODS_TRUNK_TOKEN="your_token"

# 使用 Ruby 脚本（推荐）
ruby .github/scripts/push_to_cocoapods.rb

# 或使用 Bash 脚本
bash .github/scripts/push_to_cocoapods.sh
```

### 诊断问题

```bash
ruby .github/scripts/diagnose.rb
```

### 验证配置

```bash
bash .github/scripts/verify_config.sh
```
