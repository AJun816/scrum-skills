# aider 快速配置指南

**让技能组在你的电脑上开箱即用。**

> 本指南面向首次使用敏捷团队技能组的用户。遇到问题请参考 [排查指南](aider-setup-guide.md)。

---

## 第一步：安装 aider

```bash
# 推荐方式（全平台通用）
pip install aider-chat

# 或使用 pipx（隔离安装，推荐 Mac/Linux）
pipx install aider-chat

# 验证安装
aider --version
```

**Windows 用户注意：**
- 需要先安装 [Python 3.9+](https://www.python.org/downloads/)
- 安装时勾选 "Add Python to PATH"
- 使用 PowerShell 或 CMD 执行以上命令

---

## 第二步：配置 API 密钥

技能组需要 Anthropic API Key 来调用 Claude 模型。选择以下任一方式配置：

### 方式1：环境变量（推荐）

**Mac / Linux：**
```bash
# 写入 shell 配置文件（永久生效）
echo 'export ANTHROPIC_AUTH_TOKEN=your-api-key' >> ~/.zshrc
# 或 ~/.bashrc（如果使用 bash）

# 立即生效
source ~/.zshrc
```

**Windows（PowerShell）：**
```powershell
# 设置用户级环境变量（永久生效）
[Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", "your-api-key", "User")

# 重启终端后生效
```

**Windows（CMD）：**
```cmd
setx ANTHROPIC_AUTH_TOKEN "your-api-key"
:: 重启终端后生效
```

### 方式2：aider 配置文件

创建 `~/.aider.conf.yml`（Mac/Linux 在 `~`，Windows 在 `%USERPROFILE%`）：

```yaml
model: anthropic/claude-sonnet-4-6
anthropic-api-key: your-api-key
yes-always: true
auto-commits: false
```

---

## 第三步：配置 API 代理（可选）

如果你使用 API 代理（如中转服务），需要额外配置：

### 环境变量方式

**Mac / Linux：**
```bash
# Claude Code 使用（尾部斜杠可有可无）
echo 'export ANTHROPIC_BASE_URL=https://your-proxy.com/' >> ~/.zshrc

# aider 独立使用时也需要（注意：不带 /v1，不带尾部 /）
echo 'export ANTHROPIC_API_BASE=https://your-proxy.com' >> ~/.zshrc

source ~/.zshrc
```

**Windows（PowerShell）：**
```powershell
[Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "https://your-proxy.com/", "User")
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_BASE", "https://your-proxy.com", "User")
```

### aider 配置文件方式

```yaml
# ~/.aider.conf.yml
model: anthropic/claude-sonnet-4-6
anthropic-api-key: your-api-key
set-env:
  - ANTHROPIC_API_BASE=https://your-proxy.com    # 不带 /v1，不带尾部 /
yes-always: true
auto-commits: false
```

### 代理配置注意事项

| 组件 | 环境变量 | 值的格式 |
|------|---------|---------|
| Claude Code | `ANTHROPIC_BASE_URL` | `https://proxy.com/`（尾部 `/` 可有可无）|
| aider / litellm | `ANTHROPIC_API_BASE` | `https://proxy.com`（**不带 `/v1`，不带尾部 `/`**）|

> **关键差异：** aider 底层通过 litellm 调用 API，litellm 会自动在 `ANTHROPIC_API_BASE` 后拼接 `/v1/messages`。如果你的值包含 `/v1`，最终请求路径会变成 `/v1/v1/messages`，导致认证失败。
>
> **技能组已自动处理：** 技能组调用模板中使用 `ANTHROPIC_API_BASE="${ANTHROPIC_BASE_URL%/}"` 自动去除尾部斜杠，你只需配置 `ANTHROPIC_BASE_URL` 即可。

---

## 第四步：验证配置

### 验证 aider 安装

```bash
aider --version
# 期望输出：aider v0.xx.x
```

### 验证 API 连通性

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

### 验证代理连通性（使用代理时）

```bash
curl -s -X POST "https://your-proxy.com/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_AUTH_TOKEN" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"claude-sonnet-4-6","max_tokens":50,"messages":[{"role":"user","content":"回复：成功"}]}'
```

---

## 第五步：开始使用技能组

```bash
# 1. 将技能组复制到你的项目
cp -r scrum-skills/skills/ your-project/.claude/skills/
cp scrum-skills/.claude/settings.json your-project/.claude/settings.json

# 2. 进入项目目录，启动 Claude Code
cd your-project
claude

# 3. 首次使用：初始化技能组（自动检测环境 + 扫描项目）
/0-scrum-master 初始化技能组
```

Scrum Master 会自动：
1. 检测 aider 环境是否就绪
2. 扫描项目结构、识别技术栈
3. 生成项目配置和缓存
4. 如果 aider 有问题，输出具体的修复指引

---

## 常见问题

### Q: aider 报 `AuthenticationError: invalid x-api-key`

**原因：** API 代理路径配置错误，导致 `/v1/v1/messages` 路径重复。

**解决：** 检查 `ANTHROPIC_API_BASE` 的值不能包含 `/v1` 后缀：
```bash
# 错误
export ANTHROPIC_API_BASE=https://proxy.com/v1

# 正确
export ANTHROPIC_API_BASE=https://proxy.com
```

### Q: aider 报 `Empty response received from LLM`

**原因：** 代理返回了非 JSON 内容（通常是 HTML 管理页面）。

**解决：** 同上，检查 `ANTHROPIC_API_BASE` 不包含 `/v1`。也可开启调试：
```bash
LITELLM_LOG=DEBUG aider --model anthropic/claude-sonnet-4-6 \
  --yes-always --no-git --message "test" --exit 2>&1 | grep "curl -X POST"
```
检查输出的 URL 是否为 `https://your-proxy.com/v1/messages`（正确）而非 `.../v1/v1/messages`（错误）。

### Q: Windows 上 `pip install aider-chat` 失败

**解决：**
1. 确保 Python 3.9+ 已安装：`python --version`
2. 尝试使用 `python -m pip install aider-chat`
3. 如果权限不足，使用管理员权限的终端

### Q: aider 不可用，技能组还能用吗？

**可以。** 技能组有降级策略：aider 不可用时，自动降级为 Claude Code 内置的 Edit/Write 工具直接编码。功能不受影响，但无法利用 aider 的 repo-map（代码库全局感知）优势。

### Q: 环境变量 `ANTHROPIC_AUTH_TOKEN` 和 `ANTHROPIC_API_KEY` 的区别？

- `ANTHROPIC_AUTH_TOKEN` — Claude Code 使用的变量名
- `ANTHROPIC_API_KEY` — aider/litellm 使用的变量名
- 技能组调用模板中已自动转换：`ANTHROPIC_API_KEY="$ANTHROPIC_AUTH_TOKEN"`
- 你只需配置 `ANTHROPIC_AUTH_TOKEN`，或在 `~/.aider.conf.yml` 中配置 `anthropic-api-key`

---

## 配置检查清单

| # | 检查项 | 命令 | 期望结果 |
|---|--------|------|---------|
| 1 | aider 已安装 | `aider --version` | 输出版本号 |
| 2 | API Key 已设置 | `echo ${#ANTHROPIC_AUTH_TOKEN}` | 非 0 |
| 3 | API 可连通 | 运行验证命令（见上方） | 输出"成功" |
| 4 | 代理路径正确（可选） | `echo $ANTHROPIC_API_BASE` | 不含 `/v1` |

全部通过后，运行 `/0-scrum-master 初始化技能组` 开始使用！
