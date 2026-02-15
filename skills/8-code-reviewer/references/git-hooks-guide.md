# Git Hook配置指南

**本文档提供Git Hook的详细配置指南，实现自动化代码审查**

## 什么是Git Hook

Git Hook是Git提供的钩子机制，可以在特定的Git操作前后自动执行脚本。

**常用的Hook：**
- `pre-commit` - 提交前执行
- `pre-push` - 推送前执行
- `commit-msg` - 提交信息验证
- `pre-receive` - 服务器端接收前执行

## Pre-commit Hook配置

### 安装方法

**方法1：手动安装**
```bash
# 1. 复制hook脚本到.git/hooks/
cp .claude/skills/8-code-reviewer/scripts/pre-commit.sh .git/hooks/pre-commit

# 2. 添加执行权限
chmod +x .git/hooks/pre-commit

# 3. 测试hook
git add .
git commit -m "test"
```

**方法2：使用脚本安装**
```bash
# 运行安装脚本
.claude/skills/8-code-reviewer/scripts/install-hooks.sh
```

### Hook脚本内容

**基础版本：**
```bash
#!/bin/bash
# Pre-commit hook - 代码审查

echo "🔍 代码审查中..."

# 检查文件大小
echo "📏 检查文件大小..."
.claude/skills/8-code-reviewer/scripts/check-file-size.sh
if [ $? -ne 0 ]; then
  echo "❌ 文件大小检查失败"
  exit 1
fi

# 检查代码质量
echo "🔍 检查代码质量..."
.claude/skills/8-code-reviewer/scripts/check-code-quality.sh
if [ $? -ne 0 ]; then
  echo "❌ 代码质量检查失败"
  exit 1
fi

# 检查安全问题
echo "🔒 检查安全问题..."
.claude/skills/8-code-reviewer/scripts/check-security.sh
if [ $? -ne 0 ]; then
  echo "❌ 安全检查失败"
  exit 1
fi

echo "✅ 代码审查通过"
exit 0
```

**增强版本（带跳过选项）：**
```bash
#!/bin/bash
# Pre-commit hook - 代码审查（增强版）

# 检查是否跳过审查
if [ "$SKIP_CODE_REVIEW" = "true" ]; then
  echo "⚠️  跳过代码审查（SKIP_CODE_REVIEW=true）"
  exit 0
fi

echo "🔍 代码审查中..."

# 检查文件大小
echo "📏 检查文件大小..."
.claude/skills/8-code-reviewer/scripts/check-file-size.sh
FILE_SIZE_RESULT=$?

# 检查代码质量
echo "🔍 检查代码质量..."
.claude/skills/8-code-reviewer/scripts/check-code-quality.sh
CODE_QUALITY_RESULT=$?

# 检查安全问题
echo "🔒 检查安全问题..."
.claude/skills/8-code-reviewer/scripts/check-security.sh
SECURITY_RESULT=$?

# 汇总结果
FAILED=0
if [ $FILE_SIZE_RESULT -ne 0 ]; then
  echo "❌ 文件大小检查失败"
  FAILED=1
fi

if [ $CODE_QUALITY_RESULT -ne 0 ]; then
  echo "❌ 代码质量检查失败"
  FAILED=1
fi

if [ $SECURITY_RESULT -ne 0 ]; then
  echo "❌ 安全检查失败"
  FAILED=1
fi

if [ $FAILED -eq 1 ]; then
  echo ""
  echo "💡 提示："
  echo "   - 修复上述问题后重新提交"
  echo "   - 如需跳过审查（不推荐）：SKIP_CODE_REVIEW=true git commit"
  exit 1
fi

echo "✅ 代码审查通过"
exit 0
```

### 跳过审查（紧急情况）

**临时跳过：**
```bash
# 跳过本次提交的审查
SKIP_CODE_REVIEW=true git commit -m "紧急修复"
```

**永久跳过（不推荐）：**
```bash
# 删除hook
rm .git/hooks/pre-commit
```

## Pre-push Hook配置

### 安装方法

```bash
# 1. 复制hook脚本
cp .claude/skills/8-code-reviewer/scripts/pre-push.sh .git/hooks/pre-push

# 2. 添加执行权限
chmod +x .git/hooks/pre-push
```

### Hook脚本内容

```bash
#!/bin/bash
# Pre-push hook - 推送前审查

echo "🔍 推送前代码审查..."

# 获取待推送的commits
remote="$1"
url="$2"

while read local_ref local_sha remote_ref remote_sha
do
  if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
    # 删除分支，跳过检查
    continue
  fi

  if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]; then
    # 新分支，检查所有commits
    range="$local_sha"
  else
    # 已有分支，检查新commits
    range="$remote_sha..$local_sha"
  fi

  # 获取变更文件
  files=$(git diff --name-only $range)

  # 检查每个文件
  for file in $files; do
    if [ -f "$file" ]; then
      # 检查文件大小
      lines=$(wc -l < "$file")
      if [ $lines -gt 800 ]; then
        echo "❌ $file: $lines 行（超过800行限制）"
        exit 1
      fi
    fi
  done
done

echo "✅ 推送前审查通过"
exit 0
```

## Commit-msg Hook配置

### 安装方法

```bash
# 1. 复制hook脚本
cp .claude/skills/8-code-reviewer/scripts/commit-msg.sh .git/hooks/commit-msg

# 2. 添加执行权限
chmod +x .git/hooks/commit-msg
```

### Hook脚本内容

```bash
#!/bin/bash
# Commit-msg hook - 提交信息验证

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# 检查提交信息格式
# 格式：<type>: <subject>
# 例如：feat: 添加订单管理功能

if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore): .+"; then
  echo "❌ 提交信息格式错误"
  echo ""
  echo "正确格式："
  echo "  <type>: <subject>"
  echo ""
  echo "类型（type）："
  echo "  feat     - 新功能"
  echo "  fix      - Bug修复"
  echo "  docs     - 文档更新"
  echo "  style    - 代码格式（不影响功能）"
  echo "  refactor - 重构"
  echo "  test     - 测试"
  echo "  chore    - 构建/工具"
  echo ""
  echo "示例："
  echo "  feat: 添加订单管理功能"
  echo "  fix: 修复支付失败问题"
  exit 1
fi

echo "✅ 提交信息格式正确"
exit 0
```

## 团队共享Hook配置

### 问题
Git Hook默认不会被提交到仓库，每个开发者需要手动安装。

### 解决方案

**方法1：使用安装脚本**

创建 `scripts/install-hooks.sh`：
```bash
#!/bin/bash
# 安装Git Hooks

echo "🔧 安装Git Hooks..."

# 复制hooks
cp .claude/skills/8-code-reviewer/scripts/pre-commit.sh .git/hooks/pre-commit
cp .claude/skills/8-code-reviewer/scripts/pre-push.sh .git/hooks/pre-push
cp .claude/skills/8-code-reviewer/scripts/commit-msg.sh .git/hooks/commit-msg

# 添加执行权限
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push
chmod +x .git/hooks/commit-msg

echo "✅ Git Hooks安装完成"
```

在README中提示：
```markdown
## 开发环境配置

1. 克隆仓库
2. 安装Git Hooks：`./scripts/install-hooks.sh`
3. 开始开发
```

**方法2：使用Husky（推荐）**

Husky是一个流行的Git Hook管理工具，可以将hooks提交到仓库。

```bash
# 安装Husky
npm install husky --save-dev

# 初始化Husky
npx husky install

# 添加pre-commit hook
npx husky add .husky/pre-commit ".claude/skills/8-code-reviewer/scripts/check-all.sh"

# 添加pre-push hook
npx husky add .husky/pre-push ".claude/skills/8-code-reviewer/scripts/check-all.sh"
```

**方法3：使用Git配置**

```bash
# 设置hooks目录
git config core.hooksPath .githooks

# 将hooks放在.githooks目录
mkdir .githooks
cp .claude/skills/8-code-reviewer/scripts/pre-commit.sh .githooks/pre-commit
chmod +x .githooks/pre-commit
```

## CI/CD集成

### GitHub Actions

创建 `.github/workflows/code-review.yml`：
```yaml
name: Code Review

on:
  pull_request:
    branches: [ main, master ]

jobs:
  code-review:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Check file size
      run: .claude/skills/8-code-reviewer/scripts/check-file-size.sh

    - name: Check code quality
      run: .claude/skills/8-code-reviewer/scripts/check-code-quality.sh

    - name: Check security
      run: .claude/skills/8-code-reviewer/scripts/check-security.sh
```

### GitLab CI

创建 `.gitlab-ci.yml`：
```yaml
code-review:
  stage: test
  script:
    - .claude/skills/8-code-reviewer/scripts/check-file-size.sh
    - .claude/skills/8-code-reviewer/scripts/check-code-quality.sh
    - .claude/skills/8-code-reviewer/scripts/check-security.sh
  only:
    - merge_requests
```

## 常见问题

### Q: Hook不执行？

**检查：**
1. Hook文件是否有执行权限：`ls -l .git/hooks/pre-commit`
2. Hook文件是否在正确位置：`.git/hooks/pre-commit`
3. Hook脚本是否有语法错误：`bash -n .git/hooks/pre-commit`

### Q: 如何调试Hook？

**方法：**
```bash
# 1. 在hook脚本开头添加调试输出
#!/bin/bash
set -x  # 打印执行的命令

# 2. 手动执行hook
.git/hooks/pre-commit

# 3. 查看Git输出
GIT_TRACE=1 git commit -m "test"
```

### Q: Hook执行太慢？

**优化：**
1. 只检查变更文件，不检查整个项目
2. 使用并行执行
3. 使用缓存
4. 跳过不必要的检查

### Q: 如何在不同项目使用相同的Hook？

**方法：**
1. 创建全局Hook模板目录
2. 配置Git使用模板

```bash
# 创建模板目录
mkdir -p ~/.git-templates/hooks

# 复制hooks
cp .claude/skills/8-code-reviewer/scripts/pre-commit.sh ~/.git-templates/hooks/pre-commit

# 配置Git使用模板
git config --global init.templateDir ~/.git-templates

# 新项目会自动使用这些hooks
```

## 最佳实践

1. **渐进式引入**
   - 先在个人项目试用
   - 再在团队项目推广
   - 逐步增加检查项

2. **提供跳过机制**
   - 紧急情况可以跳过
   - 但需要记录和审查

3. **快速反馈**
   - Hook执行时间 < 10秒
   - 提供清晰的错误信息
   - 提供修复建议

4. **团队共识**
   - 团队讨论并同意规则
   - 定期回顾和调整
   - 记录在文档中

5. **CI/CD双保险**
   - 本地Hook + CI/CD检查
   - 防止跳过Hook的提交
