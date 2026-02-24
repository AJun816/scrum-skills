# Scrum Skills / 敏捷团队技能组

A complete set of agile AI skills for Claude Code. Let AI be your agile team.
一套完整的敏捷开发 AI 技能组，让 AI 成为你的敏捷团队。

## Quick Start / 快速开始

```bash
# 1. Clone to your project / 克隆到你的项目
cp -r skills/ your-project/.claude/skills/
cp .claude/settings.json your-project/.claude/settings.json

# 2. Done! Hooks auto-active / 完成！钩子自动生效
#    @0-scrum-master 帮我开发用户登录功能

# 3. (Optional) Customize nickname / 可选：自定义昵称
sh .claude/skills/hooks/setup.sh
```

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
@2-product-manager 分析用户登录功能的需求

# Architecture design / 架构设计
@3-system-architect 设计订单管理模块的架构

# Backend development / 后端开发
@4-backend-dev 实现用户登录API

# Frontend development / 前端开发
@4-frontend-dev 实现登录页面

# Testing / 测试
@5-webapp-testing 编写登录功能的测试用例

# Full workflow / 完整流程（Scrum Master 自动协调）
@0-scrum-master 开发一个用户登录功能
```

## Hooks / 代码质量钩子

Hooks are auto-configured via `.claude/settings.json` — no manual setup needed.
钩子通过 `.claude/settings.json` 自动配置，无需手动设置。

- **pre-bash** — Block dangerous commands (force push, rm -rf /, DROP TABLE)
- **pre-file-write** — Block files >800 lines, detect secrets
- **post-file-write** — Warn on code smells (console.log, TODO)
- **commit-msg** — Require `Reviewed-by: 8-code-reviewer` in commits (needs setup.sh)

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
