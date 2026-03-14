# Aider 集成规范

**编程类技能在代码编写阶段直接通过 Bash 工具调用 aider，无需用户手动操作。**

> 首次配置或遇到调用问题？请参阅 [Aider 配置与调用指南](aider-setup-guide.md)

---

## 核心设计原则

```
Claude Code 主进程  →  决策层：理解需求、设计方案、协调团队
Claude Code Bash    →  执行层：直接调用 aider 完成代码编写
Claude Code 主进程  →  验收层：代码审查、git commit
```

**为什么编码用 aider？**
- aider 有 repo-map：感知整个代码库，避免重复定义
- aider `--architect` 模式：先规划后执行，更稳定
- aider 专为代码编辑优化，多文件修改不丢上下文

---

## 环境变量配置（用户必须配置）

技能通过以下环境变量调用 aider，**不硬编码任何密钥**：

| 变量 | 说明 | 示例 |
|------|------|------|
| `ANTHROPIC_AUTH_TOKEN` | API 密钥 | `sk-ant-api03-...` |
| `ANTHROPIC_BASE_URL` | API 代理地址（可选） | `https://your-proxy.com/` |

**配置方式（任选其一）：**

```bash
# 方式1：写入 shell 配置（推荐，永久生效）
echo 'export ANTHROPIC_AUTH_TOKEN=your-key' >> ~/.bashrc
echo 'export ANTHROPIC_BASE_URL=https://your-proxy.com/' >> ~/.bashrc

# 方式2：~/.aider.conf.yml
anthropic-api-key: your-key
anthropic-api-base: https://your-proxy.com   # 注意：不带尾部斜杠，不带 /v1
```

> **重要：** aider 通过 litellm 调用 Anthropic API，litellm 使用 `ANTHROPIC_API_BASE`（非 `ANTHROPIC_BASE_URL`）且会自动拼接 `/v1/messages`。因此：
> - `ANTHROPIC_API_BASE` 的值**不能带 `/v1` 后缀**，否则会变成 `/v1/v1/messages`
> - 技能调用模板中已做转换：从 `$ANTHROPIC_BASE_URL` 去除尾部斜杠后赋给 `ANTHROPIC_API_BASE`
> - 零硬编码，开源安全

---

## 标准调用模板（Bash 直接执行）

技能通过 Bash 工具直接调用，**不再输出命令让用户复制粘贴**。

### 基础调用（单任务）

```bash
ANTHROPIC_API_KEY="$ANTHROPIC_AUTH_TOKEN" \
ANTHROPIC_API_BASE="${ANTHROPIC_BASE_URL%/}" \
aider \
  --model anthropic/claude-sonnet-4-6 \
  --architect \
  --yes-always \
  --no-git \
  --no-show-model-warnings \
  --read .cache/shared/architecture/{feature}.md \
  --read .cache/shared/api-design/{feature}-api.md \
  --message "{具体编码指令}。约束：单文件≤800行，方法≤50行，遵循项目编码规范" \
  {目标文件1} {目标文件2}
```

### 后端/前端并行调用

```bash
# 后端（后台执行）
ANTHROPIC_API_KEY="$ANTHROPIC_AUTH_TOKEN" ANTHROPIC_API_BASE="${ANTHROPIC_BASE_URL%/}" \
aider --model anthropic/claude-sonnet-4-6 --architect --yes-always --no-git --no-show-model-warnings \
  --read .cache/shared/architecture/{feature}.md \
  --message "实现后端 {功能} API" \
  {后端目标文件} &
BACKEND_PID=$!

# 前端（后台执行，与后端并行）
ANTHROPIC_API_KEY="$ANTHROPIC_AUTH_TOKEN" ANTHROPIC_API_BASE="${ANTHROPIC_BASE_URL%/}" \
aider --model anthropic/claude-sonnet-4-6 --architect --yes-always --no-git --no-show-model-warnings \
  --read .cache/shared/api-design/{feature}-api.md \
  --message "实现前端 {功能} 页面" \
  {前端目标文件} &
FRONTEND_PID=$!

wait $BACKEND_PID $FRONTEND_PID
```

---

## 模型选择

| 任务类型 | 模型 |
|---------|------|
| 简单修改 / Bug修复 | `anthropic/claude-haiku-4-5-20251001` |
| 标准开发（默认） | `anthropic/claude-sonnet-4-6` |
| 复杂重构 | `anthropic/claude-opus-4-6` |

---

## 上下文文件注入（--read）

| 文件 | 用途 |
|------|------|
| `.cache/shared/architecture/{feature}.md` | 架构设计（必须） |
| `.cache/shared/api-design/{feature}-api.md` | API 契约 |
| `.cache/shared/requirements/{feature}.md` | 需求文档 |
| `skills/config/coding-standards.md` | 编码规范 |

**目标文件原则：** 明确指定路径，新文件预先列出，单次 ≤ 10 个文件。

---

## 执行完成后

aider 执行完成后，由 Claude Code 主进程统一处理：

1. 读取 aider 生成/修改的文件，验证内容正确
2. 调用 `/8-code-reviewer` 进行代码审查
3. 审查通过后执行 git commit

---

## 降级策略

```
aider 不可用（未安装/环境变量未配置）→ Claude Code Edit/Write 工具直接实现
失败超过 3 次 → 降级并向 Scrum Master 报告
```

---

## 与技能组的集成点

| 技能 | aider 调用时机 |
|------|--------------|
| `4-backend-dev` | Phase 3 编码实现阶段 |
| `4-frontend-dev` | Phase 3 编码实现阶段 |
| `5-devops-engineer` | 编写 CI/CD 脚本、Dockerfile 时 |
| `6-bug-handler` | 修复实施阶段 |
| `8-code-reviewer` | 不使用 aider（只读不写） |
