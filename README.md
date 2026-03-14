# Scrum Skills / 敏捷团队技能组

A complete set of agile AI skills for Claude Code. Let AI be your agile team.
一套完整的敏捷开发 AI 技能组，让 AI 成为你的敏捷团队。

## Prerequisites / 前置条件

- [Claude Code](https://claude.ai/code) — AI 主进程
- [aider](https://aider.chat) — AI 编码执行层（`pip install aider-chat`）

aider 需要在本地终端可以正常运行（`aider --version` 有输出即可）。

## Quick Start / 快速开始

```bash
# 1. Clone this repo / 克隆仓库
git clone https://github.com/AJun816/scrum-skills.git
# or Gitee / 或使用 Gitee
git clone https://gitee.com/ajun816/scrum-skills.git

# 2. Copy to your project / 复制到你的项目
cp -r scrum-skills/skills/ your-project/.claude/skills/
cp scrum-skills/.claude/settings.json your-project/.claude/settings.json

# 3. (Optional) Customize / 可选：自定义昵称和安装 git hook
sh your-project/.claude/skills/hooks/setup.sh

# 4. Done! Start working / 完成！开始工作
#    /0-scrum-master 帮我开发用户登录功能
```

## How It Works / 工作原理

```
用户描述需求
    ↓
Claude Code（Scrum Master）→ 任务拆解、架构设计、生成文档
    ↓
Claude Code 输出 aider 命令（单行，可直接复制执行）
    ↓
用户在终端执行 aider → 代码写入项目文件
    ↓
Claude Code → 代码审查 → git commit
```

**编码任务由 aider 在用户终端执行**，规划/设计/审查由 Claude Code 完成。


## Skills / 技能列表

| # | Skill | Role / 职责 |
|---|-------|-------------|
| 0 | scrum-master | Agile coach / 敏捷教练 |
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

# Full workflow / 完整流程（Scrum Master 自动协调）
/0-scrum-master 开发一个用户登录功能
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
│   └── settings.json      ← Hooks auto-config
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
