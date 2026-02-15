# Git Hook 集成实现指南

## 概述

本文档详细说明如何将代码审查集成到Git工作流程中，通过pre-commit hook实现自动化代码审查。

## Git Hook 类型

### pre-commit Hook

**触发时机：** 执行 `git commit` 之前
**用途：** 代码质量检查、格式化、测试
**特点：** 可以阻止提交

### pre-push Hook

**触发时机：** 执行 `git push` 之前
**用途：** 运行完整测试套件、安全扫描
**特点：** 可以阻止推送

### commit-msg Hook

**触发时机：** 编辑commit消息之后
**用途：** 验证commit消息格式
**特点：** 可以修改或拒绝commit消息

---

## Pre-commit Hook 实现

### 完整代码

详细的pre-commit hook实现代码请参考项目中的 `scripts/hooks/pre-commit` 文件。

**核心检查项：**
1. 文件大小检查（≤800行）
2. 方法大小检查（≤50行）
3. 敏感信息检查
4. TODO/FIXME检查
5. 代码格式检查

---

## 安装步骤

### 方法1：手动安装

```bash
# 1. 进入项目根目录
cd /path/to/your/project

# 2. 创建hooks目录（如果不存在）
mkdir -p .git/hooks

# 3. 复制pre-commit文件
cp scripts/hooks/pre-commit .git/hooks/pre-commit

# 4. 添加执行权限
chmod +x .git/hooks/pre-commit

# 5. 测试hook
git add .
git commit -m "test: 测试pre-commit hook"
```

### 方法2：使用脚本安装

创建安装脚本 `install-hooks.sh`：

```bash
#!/bin/bash
# install-hooks.sh

set -e

echo "🔧 安装Git Hooks..."

# 检查是否在git仓库中
if [ ! -d ".git" ]; then
  echo "❌ 错误：当前目录不是git仓库"
  exit 1
fi

# 创建hooks目录
mkdir -p .git/hooks

# 复制pre-commit hook
cp scripts/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✅ Pre-commit hook 安装成功"

# 复制pre-push hook（可选）
if [ -f "scripts/hooks/pre-push" ]; then
  cp scripts/hooks/pre-push .git/hooks/pre-push
  chmod +x .git/hooks/pre-push
  echo "✅ Pre-push hook 安装成功"
fi

echo ""
echo "🎉 Git Hooks 安装完成！"
echo ""
echo "现在每次 git commit 时都会自动运行代码审查。"
```

运行安装：

```bash
chmod +x install-hooks.sh
./install-hooks.sh
```

### 方法3：使用Husky（推荐）

Husky是一个流行的Git Hooks管理工具，适用于Node.js项目。

**安装Husky：**

```bash
# 1. 安装husky
npm install --save-dev husky

# 2. 启用Git hooks
npx husky install

# 3. 添加pre-commit hook
npx husky add .husky/pre-commit "npm run lint"
```

---

## Pre-push Hook 实现

Pre-push hook用于在推送前运行完整的测试套件和安全扫描。

**核心检查项：**
1. 运行单元测试
2. 运行集成测试
3. 安全扫描
4. 代码覆盖率检查

详细实现请参考 `scripts/hooks/pre-push` 文件。

---

## Commit-msg Hook 实现

Commit-msg hook用于验证commit消息格式，确保遵循Conventional Commits规范。

**格式要求：**
```
type(scope): subject

body

footer
```

**类型（type）：**
- feat: 新功能
- fix: Bug修复
- docs: 文档更新
- style: 代码格式（不影响功能）
- refactor: 重构
- test: 测试
- chore: 构建/工具

**示例：**
```
feat(user): 添加用户登录功能
fix(order): 修复订单计算错误
docs: 更新README
```

---

## 跳过Hook检查

### 临时跳过

```bash
# 跳过pre-commit检查
git commit --no-verify -m "fix: 紧急修复"

# 跳过pre-push检查
git push --no-verify
```

**注意：** 只在紧急情况下使用，并在后续补充检查。

### 永久禁用

```bash
# 删除hook文件
rm .git/hooks/pre-commit
rm .git/hooks/pre-push

# 或者重命名
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
```

---

## 团队共享Hook

### 方法1：使用scripts目录

```bash
# 项目结构
project/
├── .git/
├── scripts/
│   ├── hooks/
│   │   ├── pre-commit
│   │   ├── pre-push
│   │   └── commit-msg
│   └── install-hooks.sh
└── README.md
```

**团队成员安装：**
```bash
./scripts/install-hooks.sh
```

### 方法2：使用Git配置

```bash
# 设置hooks目录
git config core.hooksPath scripts/hooks

# 团队成员只需运行一次
```

### 方法3：使用Husky（推荐）

Husky会自动管理hooks，团队成员只需：

```bash
npm install  # 自动安装hooks
```

---

## 最佳实践

### 1. Hook应该快速

- Pre-commit检查应在5秒内完成
- 耗时的检查放到pre-push或CI/CD

### 2. 提供清晰的错误信息

- 说明什么检查失败了
- 提供修复建议
- 显示相关文件和行号

### 3. 允许跳过（但记录）

- 紧急情况可以使用 `--no-verify`
- 但应该记录跳过的原因
- 后续补充检查

### 4. 团队共享

- 将hooks纳入版本控制
- 提供安装脚本
- 文档化使用方法

### 5. 持续改进

- 根据团队反馈调整检查项
- 平衡检查严格度和开发效率
- 定期更新检查规则

---

## 故障排除

### 问题1：Hook没有执行

**原因：** 没有执行权限

**解决：**
```bash
chmod +x .git/hooks/pre-commit
```

### 问题2：Hook执行失败

**原因：** 脚本语法错误

**解决：**
```bash
# 手动运行hook测试
bash -x .git/hooks/pre-commit
```

### 问题3：Hook被跳过

**原因：** 使用了 `--no-verify`

**解决：**
```bash
# 不使用--no-verify
git commit -m "message"
```

### 问题4：Hook太慢

**原因：** 检查项太多或太耗时

**解决：**
- 只检查变更的文件
- 将耗时检查移到CI/CD
- 使用缓存加速

---

## 总结

Git Hooks确保：
1. ✅ **自动化** - 无需手动运行检查
2. ✅ **强制性** - 不通过无法提交
3. ✅ **即时反馈** - 提交前发现问题
4. ✅ **团队一致** - 所有人使用相同标准
5. ✅ **持续改进** - 可以不断优化检查规则

让代码质量检查成为开发流程的一部分！
