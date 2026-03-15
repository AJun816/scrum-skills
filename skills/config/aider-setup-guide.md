# Aider 配置与调用指南

本文档记录在 scrum-skills 技能组中集成 aider 时遇到的问题、排查过程及正确配置方式。

---

## 遇到的问题

### 现象

技能组通过 Bash 调用 aider 时，持续报错：

```
litellm.AuthenticationError: AnthropicException -
{"type":"error","error":{"type":"authentication_error","message":"invalid x-api-key"}}
```

或返回空响应：

```
Empty response received from LLM. Check your provider account?
```

但同样的 API Key 通过 `curl` 直接调用代理完全正常。

### 根因分析

经过逐层排查，定位到 **litellm URL 路径拼接错误**：

```
实际请求：https://ncode.vkm2.com/v1/v1/messages  ← 路径重复！
正确路径：https://ncode.vkm2.com/v1/messages
```

**原因链路：**

1. 用户在 `~/.zshrc` 中配置 `ANTHROPIC_BASE_URL=https://ncode.vkm2.com/`（尾部带 `/`）
2. Claude Code 正常使用此变量（Claude Code 自己处理了路径）
3. aider 底层通过 **litellm** 调用 Anthropic API
4. litellm 识别的环境变量是 `ANTHROPIC_API_BASE`（不是 `ANTHROPIC_BASE_URL`）
5. litellm 会在 `ANTHROPIC_API_BASE` 后自动拼接 `/v1/messages`
6. 如果 `ANTHROPIC_API_BASE` 的值包含 `/v1` 或尾部 `/`，就会拼成 `/v1/v1/messages` 或 `//v1/messages`
7. 代理收到错误路径后返回 HTML 首页（New API 管理后台），litellm 解析 JSON 失败

**关键差异表：**

| 组件 | 使用的环境变量 | 期望的值 |
|------|---------------|---------|
| Claude Code | `ANTHROPIC_BASE_URL` | `https://proxy.com/` ✅ |
| aider/litellm | `ANTHROPIC_API_BASE` | `https://proxy.com`（无 `/v1`，无尾部 `/`）✅ |
| aider/litellm | `ANTHROPIC_BASE_URL` | ❌ **不识别此变量** |

### 另一个坑：`--anthropic-api-base` 参数

aider v0.86.2 **不支持** `--anthropic-api-base` 命令行参数，也不支持在 `.aider.conf.yml` 中写 `anthropic-api-base:`。必须通过 `set-env` 注入环境变量。

---

## 正确配置方式

### 1. `~/.aider.conf.yml`（全局配置，aider 独立使用时生效）

```yaml
# ─── 模型配置 ───
model: anthropic/claude-opus-4-6
anthropic-api-key: your-api-key

# 通过 set-env 注入代理地址（不带 /v1，不带尾部斜杠）
set-env:
  - ANTHROPIC_API_BASE=https://your-proxy.com

# ─── 推荐配置 ───
yes-always: true
auto-accept-architect: true
auto-commits: false          # 由 Claude Code 主进程管理 git
dark-mode: true
stream: true
chat-language: chinese
```

**注意事项：**
- `ANTHROPIC_API_BASE` 的值**绝对不能**带 `/v1` 后缀
- `ANTHROPIC_API_BASE` 的值**不要**带尾部斜杠 `/`
- 使用 `set-env` 而非 `anthropic-api-base`（后者不被 aider 识别）

### 2. 技能组调用模板（Claude Code Bash 调用时生效）

```bash
ANTHROPIC_API_KEY="$ANTHROPIC_AUTH_TOKEN" \
ANTHROPIC_API_BASE="${ANTHROPIC_BASE_URL%/}" \
aider \
  --model anthropic/claude-sonnet-4-6 \
  --architect \
  --yes-always \
  --no-git \
  --no-show-model-warnings \
  --message "{编码指令}" \
  {目标文件}
```

**关键点：**
- `ANTHROPIC_API_KEY` ← 从 Claude Code 的 `$ANTHROPIC_AUTH_TOKEN` 取值
- `ANTHROPIC_API_BASE` ← 用 `${ANTHROPIC_BASE_URL%/}` 去除尾部斜杠
- `--no-git` ← 必须，由主进程统一管理 git commit
- `--architect` ← 推荐，先规划后执行更稳定

### 3. Shell 环境变量配置（`~/.zshrc` 或 `~/.bashrc`）

```bash
# Claude Code 使用（带尾部斜杠也可以）
export ANTHROPIC_AUTH_TOKEN=your-api-key
export ANTHROPIC_BASE_URL=https://your-proxy.com/

# 如果想让 aider 独立运行也走代理，额外配置：
export ANTHROPIC_API_BASE=https://your-proxy.com   # 注意：不带 /v1，不带尾部 /
```

---

## 验证方法

### 快速验证 aider 是否可用

```bash
aider --model anthropic/claude-sonnet-4-6 \
  --yes-always --no-git --no-show-model-warnings \
  --no-restore-chat-history \
  --message "只回复两个字：成功" --exit
```

期望输出：

```
成功

Tokens: 599 sent, 1 received. Cost: $0.0018 message, $0.0018 session.
```

### 验证技能组调用模板

```bash
ANTHROPIC_API_KEY="$ANTHROPIC_AUTH_TOKEN" \
ANTHROPIC_API_BASE="${ANTHROPIC_BASE_URL%/}" \
aider --model anthropic/claude-sonnet-4-6 \
  --architect --yes-always --no-git --no-show-model-warnings \
  --no-restore-chat-history \
  --message "只回复两个字：成功" --exit
```

### 验证代理本身是否正常

```bash
curl -s -X POST "https://your-proxy.com/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_AUTH_TOKEN" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-sonnet-4-6","max_tokens":50,"messages":[{"role":"user","content":"回复：成功"}]}'
```

---

## 排查清单

当 aider 调用失败时，按顺序检查：

| # | 检查项 | 命令 | 正确结果 |
|---|--------|------|---------|
| 1 | aider 已安装 | `aider --version` | 版本号 |
| 2 | API Key 已设置 | `echo ${#ANTHROPIC_AUTH_TOKEN}` | 非 0 |
| 3 | 代理可达 | `curl` 直接调用（见上方） | 返回 JSON |
| 4 | `ANTHROPIC_API_BASE` 无 `/v1` | `echo $ANTHROPIC_API_BASE` | `https://proxy.com` |
| 5 | `.aider.conf.yml` 正确 | `cat ~/.aider.conf.yml` | `set-env` 含 `ANTHROPIC_API_BASE` |
| 6 | litellm 请求路径 | 开启 debug 看 curl 输出 | `/v1/messages`（非 `/v1/v1/messages`） |

### 开启 litellm 调试

```bash
LITELLM_LOG=DEBUG aider --model anthropic/claude-sonnet-4-6 \
  --yes-always --no-git --no-show-model-warnings \
  --message "test" --exit 2>&1 | grep "curl -X POST"
```

检查输出的 URL 是否为 `https://your-proxy.com/v1/messages`。

---

## 模型选择参考

| 场景 | 模型 | 说明 |
|------|------|------|
| 简单修改 / Bug 修复 | `anthropic/claude-haiku-4-5-20251001` | 快速、低成本 |
| 标准开发（默认） | `anthropic/claude-sonnet-4-6` | 平衡性价比 |
| 复杂重构 / 架构级改动 | `anthropic/claude-opus-4-6` | 最强能力 |

---

## 跨平台配置方案（Windows + Mac）

环境变量不跨电脑共享，推荐使用 `~/.aider.conf.yml` 统一管理，**格式完全一致，无需区分平台**。

### 一次性配置步骤

**Mac（Terminal）：**

```bash
cat > ~/.aider.conf.yml << 'EOF'
model: anthropic/claude-sonnet-4-6
anthropic-api-key: sk-ant-xxx
set-env:
  - ANTHROPIC_API_BASE=https://your-proxy.com
yes-always: true
auto-commits: false
dark-mode: true
chat-language: chinese
EOF
```

**Windows（PowerShell）：**

```powershell
@"
model: anthropic/claude-sonnet-4-6
anthropic-api-key: sk-ant-xxx
set-env:
  - ANTHROPIC_API_BASE=https://your-proxy.com
yes-always: true
auto-commits: false
dark-mode: true
chat-language: chinese
"@ | Out-File "$env:USERPROFILE\.aider.conf.yml" -Encoding utf8
```

### 注意事项

- `ANTHROPIC_API_BASE` 不带 `/v1`，不带尾部 `/`
- 配置文件**不要提交到 git**（包含 API Key）
- 配置完成后，技能组通过 Bash 调用 aider 时会自动读取此文件

### 验证配置是否生效

```bash
aider --model anthropic/claude-sonnet-4-6 \
  --yes-always --no-git --no-show-model-warnings \
  --no-restore-chat-history \
  --message "只回复两个字：成功" --exit
```

---

## 降级策略

```
aider 调用失败
  ├── 检查环境变量 → 修复后重试
  ├── 代理不可达 → 检查网络 / 代理状态
  ├── 连续失败 3 次 → 降级为 Claude Code Edit/Write 工具直接实现
  └── 降级后通知 Scrum Master 记录异常
```
