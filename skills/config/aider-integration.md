# Aider 集成规范

**编程类技能在代码编写阶段优先使用 aider 执行。**

---

## 核心设计原则

```
Claude Code 主进程      →  决策层：理解需求、设计方案、协调团队
Claude Agent 子进程     →  规划层：产出文档、架构设计、任务拆解
aider（用户终端执行）    →  执行层：代码编写、多文件修改
Claude Code 主进程      →  验收层：代码审查、git commit
```

**为什么编码用 aider？**
- aider 有 repo-map：感知整个代码库，避免重复定义
- aider `--architect` 模式：先规划后执行，更稳定
- aider 自动 lint/test：执行链完整
- aider 专为代码编辑优化，多文件修改不丢上下文

---

## 执行模式（唯一标准方式）

**Claude Code 生成 aider 命令 → 用户在自己的终端里执行**

```
1. Claude Code 规划  →  产出共享文档到 .cache/shared/
2. Claude Code 生成  →  输出完整 aider 单行命令
3. 用户终端执行      →  cd 到项目根目录，粘贴执行
4. Claude Code 验收  →  读取生成的代码 → 审查 → git commit
```

> **为什么不从 Claude Code 子进程直接调用 aider？**
> Claude Code 会设置 `ANTHROPIC_BASE_URL` 指向内部代理，aider 通过该代理调用时会被拒绝（502）。
> 用户在自己的终端里执行 aider 不受此限制，是唯一可靠的方式。

---

## 标准命令格式（必须单行，方便直接执行）

**所有输出的 aider 命令必须是单行，不换行，用户可直接复制粘贴执行。**

### 输出格式模板

```
## 🤖 请在终端执行（先 cd 到项目根目录）

aider --architect --yes-always --no-git --read .cache/shared/architecture/{feature}.md --read .cache/shared/api-design/{feature}-api.md --message "按架构文档实现{功能}：1.{文件1}实现{职责} 2.{文件2}实现{职责}。约束：单文件≤800行，方法≤50行" {目标文件1} {目标文件2}

执行完成后告诉我，我来进行代码审查和 git commit。
```

### 跨平台路径规范

| 平台 | 路径分隔符 | 示例 |
|------|-----------|------|
| macOS / Linux | `/` | `src/main/java/UserController.java` |
| Windows (终端) | `/` 或 `\` | 统一用 `/`，aider 两者都接受 |

**统一使用正斜杠 `/`，macOS 和 Windows 均兼容。**

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

## 模型选择

| 任务类型 | 推荐模型 |
|---------|---------|
| 简单修改 | `claude-haiku-4-5-20251001` |
| 标准开发 | `claude-sonnet-4-6`（默认） |
| 复杂重构 | `claude-opus-4-6` |

aider 默认使用 `~/.aider.conf.yml` 中配置的模型，无需在命令中显式指定。

---

## 执行完成后

aider 执行完成后，通知 Claude Code，由主进程统一处理：

1. 读取 aider 生成/修改的文件，验证内容正确
2. 调用 `/8-code-reviewer` 进行代码审查
3. 审查通过后执行 git commit（带 `✅[Reviewed]` 前缀）

---

## 降级策略

```
aider 不可用 → Claude Code Edit/Write 工具直接实现（功能相同）
用户确认降级 → 技能继续执行，不中断流程
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


---

## 核心设计原则

```
Claude Code 主进程      →  决策层：理解需求、设计方案、协调团队
Claude Agent 子进程     →  规划层：产出文档、架构设计、任务拆解
aider                   →  执行层：代码编写、多文件修改、git commit
```

**为什么编码用 aider？**
- aider 有 repo-map：感知整个代码库，避免重复定义
- aider `--architect` 模式：先规划后执行，更稳定
- aider 自动 lint/test：执行链完整
- aider 专为代码编辑优化，多文件修改不丢上下文

---

## 执行模式（唯一标准方式）

**Claude Code 生成 aider 命令 → 用户在自己的终端里执行**

```
Claude Code（规划层）  →  生成完整 aider 命令 + 上下文文件
用户终端               →  粘贴执行 aider（aider 有完整 session 权限）
Claude Code（验收层）  →  读取生成的代码 → 代码审查 → git commit
```

这是唯一可靠的方式。Claude Code 的 bash 子进程受 API session 限制，无法直接调用 aider。

---

## 模式A：生成命令（cc-switch 环境标准模式）

**技能不直接调用 aider，而是输出完整的 aider 命令，让用户在终端里执行。**

### 输出格式

```markdown
## 🤖 aider 执行指令

请在你的终端里执行以下命令：

\`\`\`bash
aider \
  --architect \
  --yes-always \
  --no-git \
  --read .cache/shared/architecture/{feature}.md \
  --read .cache/shared/api-design/{feature}-api.md \
  --message "按架构文档实现 {功能}：
  1. {文件1}：{职责描述}
  2. {文件2}：{职责描述}
  约束：单文件≤800行，方法≤50行" \
  {目标文件1} \
  {目标文件2}
\`\`\`

执行完成后告诉我，我来进行代码审查和 git commit。
```

---

## 模式B：子进程直接执行（真实 API key 环境）

适用于配置了真实 `sk-ant-api03-...` key 且 `ANTHROPIC_BASE_URL` 为空的环境。

### 基础调用（单任务）

```bash
ANTHROPIC_BASE_URL="" \
aider \
  --architect \
  --yes-always \
  --no-git \
  --read .cache/shared/architecture/{feature}.md \
  --read .cache/shared/api-design/{feature}-api.md \
  --message "$(cat <<'TASK'
{具体编码指令}

要求：
- 文件 ≤ 800 行，方法 ≤ 50 行
- 遵循 PROJECT_CONFIG.md 中的编码规范
- 不暴露密钥，不编造数据
TASK
)" \
  {目标文件列表}
```

### 后端/前端并行调用

```bash
# 后端（后台执行）
ANTHROPIC_BASE_URL="" aider --architect --yes-always --no-git \
  --read .cache/shared/architecture/{feature}.md \
  --message "实现后端 {功能} API，Controller→Service→Domain→Repository" \
  src/{domain}/controller/{F}.java src/{domain}/service/{F}.java &
BACKEND_PID=$!

# 前端（后台执行，与后端并行）
ANTHROPIC_BASE_URL="" aider --architect --yes-always --no-git \
  --read .cache/shared/api-design/{feature}-api.md \
  --message "实现前端 {功能} 页面，api→store→component→view" \
  src/api/{f}.ts src/views/{f}/{Page}.vue &
FRONTEND_PID=$!

wait $BACKEND_PID $FRONTEND_PID
```

---

## 模型选择

| 任务类型 | 推荐模型 |
|---------|---------|
| 简单修改 | `claude-haiku-4-5-20251001` |
| 标准开发 | `claude-sonnet-4-6`（默认） |
| 复杂重构 | `claude-opus-4-6` |

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

## 执行完成后（两种模式统一）

无论哪种模式，aider 执行完成后由 **Claude Code 主进程** 统一处理：

```bash
# 1. 代码审查（调用 8-code-reviewer）
# 2. 审查通过后 git commit
git add {修改的文件}
git commit -m "feat: 实现 {功能}（aider生成）"
```

---

## 降级策略

```
aider 不可用或失败 → Claude Code Edit/Write 工具直接实现
（功能相同，只是不用 aider 的 repo-map 能力）
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
