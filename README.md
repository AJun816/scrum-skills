# Scrum Skills / 敏捷团队技能组

A complete set of agile AI skills for Claude Code. Let AI be your agile team.
一套完整的敏捷开发 AI 技能组，让 AI 成为你的敏捷团队。

## Prerequisites / 前置条件

- [Claude Code](https://claude.ai/code) — AI 主进程
- [aider](https://aider.chat) — AI 编码执行层（`pip install aider-chat`）

### aider 环境配置 / aider Setup

技能组通过 aider 执行编码任务，需要配置 API 密钥。根据你的使用方式选择配置：

**方式1：环境变量（推荐）**

```bash
# Mac/Linux: 写入 ~/.zshrc 或 ~/.bashrc
export ANTHROPIC_AUTH_TOKEN=your-api-key
export ANTHROPIC_BASE_URL=https://your-proxy.com/   # 可选，使用代理时配置

# Windows: 系统环境变量
set ANTHROPIC_AUTH_TOKEN=your-api-key
set ANTHROPIC_BASE_URL=https://your-proxy.com/       # 可选
```

**方式2：aider 配置文件 `~/.aider.conf.yml`**

```yaml
model: anthropic/claude-sonnet-4-6
anthropic-api-key: your-api-key
set-env:
  - ANTHROPIC_API_BASE=https://your-proxy.com    # 可选，不带 /v1，不带尾部 /
yes-always: true
auto-commits: false
```

**验证 aider 是否可用：**

```bash
aider --version                          # 确认已安装
aider --model anthropic/claude-sonnet-4-6 \
  --yes-always --no-git --no-show-model-warnings \
  --no-restore-chat-history \
  --message "只回复两个字：成功" --exit   # 确认 API 连通
```

> **注意：** 如果使用 API 代理，aider 底层 litellm 使用 `ANTHROPIC_API_BASE` 环境变量（不是 `ANTHROPIC_BASE_URL`），且值**不能**带 `/v1` 后缀或尾部 `/`，否则会产生路径重复错误。技能组调用模板已自动处理此转换。
> 详细排查指南见 [aider-setup-guide.md](skills/config/aider-setup-guide.md)

## Quick Start / 快速开始

```bash
# 1. Clone this repo / 克隆仓库
git clone https://gitee.com/ajun816/scrum-skills.git
# or GitHub
git clone https://github.com/AJun816/scrum-skills.git

# 2. Copy to your project / 复制到你的项目
cp -r scrum-skills/skills/ your-project/.claude/skills/
cp scrum-skills/.claude/settings.json your-project/.claude/settings.json

# 3. (Optional) Install git hooks / 可选：安装 git hook
sh your-project/.claude/skills/hooks/setup.sh

# 4. Done! Start with Scrum Master / 完成！用敏捷教练开始
#    /0-scrum-master 初始化技能组
```

**首次使用：** 运行 `/0-scrum-master` 会自动扫描项目结构、识别技术栈、检测 aider 环境、生成项目配置，并引导你完成初始化。

## How It Works / 工作原理

```
用户描述需求
    ↓
Claude Code（Scrum Master）→ 任务拆解、架构设计、生成共享文档
    ↓
Claude Code Bash 直接调用 aider → 代码写入项目文件
    ↓
Claude Code → 代码审查（/8-code-reviewer）→ git commit
```

**三层架构：**
- **决策层** — Scrum Master 主进程：理解需求、拆解任务、协调团队
- **规划层** — Agent 子进程：需求分析、架构设计、测试报告（文档型任务）
- **执行层** — aider 进程：后端/前端/DevOps 编码（`--no-git`，主进程统一 commit）

## Skills / 技能列表

| # | Skill | Role / 职责 |
|---|-------|-------------|
| 0 | scrum-master | Agile coach / 敏捷教练（协调全流程） |
| 1 | business-expert | Business analyst / 业务专家 |
| 2 | product-manager | Product manager / 产品经理 |
| 3 | system-architect | System architect / 系统架构师 |
| 4 | backend-dev | Backend dev / 后端开发（通用语言） |
| 4 | frontend-dev | Frontend dev / 前端开发（通用框架） |
| 4 | nielsen-ui-design | UI/UX design / UI设计 |
| 4 | frontend-design | Visual design / 前端视觉设计 |
| 5 | devops-engineer | DevOps / 运维工程师 |
| 5 | webapp-testing | Testing / 测试工程师 |
| 6 | bug-handler | Bug handler / Bug处理专家 |
| 7 | skill-creator | Skill creator / 技能创建器 |
| 8 | code-reviewer | Code reviewer / 代码审查 |

## Usage Examples / 使用示例

```
# 首次使用：初始化技能组（自动扫描项目+检测aider环境）
/0-scrum-master 初始化技能组

# Full workflow / 完整流程（Scrum Master 自动协调）
/0-scrum-master 开发一个用户登录功能

# Requirement analysis / 需求分析
/2-product-manager 分析用户登录功能的需求

# Architecture design / 架构设计
/3-system-architect 设计订单管理模块的架构

# Backend development / 后端开发
/4-backend-dev 实现用户登录API

# Frontend development / 前端开发
/4-frontend-dev 实现登录页面

# Testing / 测试
/5-webapp-testing 编写登录功能的测试用例
```

## Hooks / 代码质量钩子

Hooks are auto-configured via `.claude/settings.json` — no manual setup needed.
钩子通过 `.claude/settings.json` 自动配置，无需手动设置。

- **pre-bash** — Enforce `✅[Reviewed]` prefix on every git commit
- **pre-file-write** — Block code files >800 lines, warn >600 lines
- **post-file-write** — Code quality report (function length, nesting depth, code smells, auto-linter)
- **commit-msg** — Enforce `✅[Reviewed]` prefix (git hook layer, needs setup.sh)

See [hooks/README.md](skills/hooks/README.md) for details.

## Project Structure / 项目结构

```
scrum-skills/
├── .claude/
│   └── settings.json      ← Hooks auto-config (copy to your project)
├── README.md               ← You are here
└── skills/                 ← Copy this to .claude/skills/
    ├── 0-scrum-master/
    ├── 1-business-expert/
    ├── 2-product-manager/
    ├── 3-system-architect/
    ├── 4-backend-dev/
    ├── 4-frontend-dev/
    ├── 4-nielsen-ui-design/
    ├── 4-frontend-design/
    ├── 5-devops-engineer/
    ├── 5-webapp-testing/
    ├── 6-bug-handler/
    ├── 7-skill-creator/
    ├── 8-code-reviewer/
    ├── config/              ← Shared config files
    ├── hooks/               ← Code quality hooks
    └── PROJECT_CONFIG.template.md
```

## License

[MulanPSL-2.0](skills/LICENSE)
