# Scrum Skills / 敏捷团队技能组

一套完整的 AI 敏捷开发团队技能组，让 AI 成为你的开发团队。支持**三省六部模式**（全流程审核）和**敏捷模式**（快速交付）双模式自动编排。

## Prerequisites / 前置条件

- [Claude Code](https://claude.ai/code)
- macOS/Linux: `sh`（系统自带）
- Windows: PowerShell（系统自带，使用 `install.bat`）

## Quick Start / 快速开始

```bash
# 1. Clone / 克隆
git clone https://gitee.com/ajun816/scrum-skills.git
# or GitHub
git clone https://github.com/AJun816/scrum-skills.git

# 2. Install (one command) / 一键安装
cd scrum-skills
sh install.sh
# Windows: double-click install.bat (PowerShell, no Git Bash required)

# 3. Start Claude Code in your project / 在你的项目里启动
cd your-project && claude
```

默认会安装到 `~/.claude/`。可选参数：

```bash
sh install.sh --agent=warp                # 安装到 ~/.warp
sh install.sh --target=/path/to/.claude   # 指定安装目录
sh install.sh --keep-settings             # 保留已有 settings.json
sh install.sh --lang=en                   # 英文输出
```

若使用 `--target`，后续 `setup.sh` 路径请将 `~/.claude` 替换为你的目标目录。

**然后输入需求，全自动流转：**

```
# 三省六部模式（复杂任务，全流程质量审核）
/0-emperor 开发用户登录功能，要求 JWT 鉴权 + Redis 缓存

# 敏捷模式（简单任务，快速处理）
/0-scrum-master 修复登录按钮样式问题
```

无需手动调用每个技能，`workflow-runner` 自动按链条调度到底。

## How It Works / 工作原理

### 三省六部模式（推荐用于复杂任务）

```
👑 皇上（用户下旨）
    ↓
🤴 太子 分拣（闲聊直接回 / 正式旨意传旨）
    ↓
📜 中书省 规划（调用 PM + Architect）
    ↓
🔍 门下省 审核（可封驳，max 3轮）
    ↓
📮 尚书省 派发（六部并行执行）
    ↓
🔍 门下省 代码审核（可封驳，max 3轮）
    ↓
📜 中书省 回奏
    ↓
👑 皇上 御览 → git commit ✅[Reviewed]
```

### 敏捷模式（推荐用于简单任务）

```
Scrum Master → PM + Architect 并行规划 → Dev 并行执行 → Code Review → 提交
```

### 两层架构

- **决策层** — 主进程：理解需求、拆解任务、协调团队
- **执行层** — Agent 子进程：所有角色通过 Claude Code Edit/Write 工具执行

## Skills / 技能列表

| # | Skill | Role / 职责 |
|---|-------|-------------|
| 0 | emperor | 👑 皇上（三省六部入口，下旨启动全流程） |
| 0 | taizi | 🤴 太子（消息分拣，闲聊/旨意分流） |
| 0 | zhongshu-province | 📜 中书省（规划中枢） |
| 0 | menxia-province | 🔍 门下省（质量门禁，审核/封驳） |
| 0 | shangshu-province | 📮 尚书省（派发协调，调度六部执行） |
| 0 | workflow-runner | 🔄 工作流编排器（自动驱动全流程） |
| 0 | scrum-master | 敏捷教练（协调全流程） |
| 1 | business-expert | 业务专家 |
| 2 | product-manager | 产品经理 |
| 3 | system-architect | 系统架构师 |
| 4 | backend-dev | 后端开发（通用语言） |
| 4 | frontend-dev | 前端开发（通用框架） |
| 4 | nielsen-ui-design | UI/UX设计 |
| 4 | frontend-design | 前端视觉设计 |
| 5 | devops-engineer | DevOps工程师 |
| 5 | webapp-testing | 测试工程师 |
| 6 | bug-handler | Bug处理专家 |
| 7 | skill-creator | 技能创建器 |
| 8 | code-reviewer | 代码审查专家 |

## Usage Examples / 使用示例

```
# 全自动编排（推荐）
/0-emperor 开发一个用户登录功能
/0-scrum-master 开发一个用户登录功能

# 单独调用某个角色
/2-product-manager 分析用户登录功能的需求
/3-system-architect 设计订单管理模块的架构
/4-backend-dev 实现用户登录API
/4-frontend-dev 实现登录页面
/5-webapp-testing 编写登录功能的测试用例
```

## Hooks / 代码质量钩子

通过 `.claude/settings.json` 自动生效，无需手动配置：

- **pre-bash** — git commit 强制要求 `✅[Reviewed]` 前缀
- **pre-file-write** — 代码文件 >800 行阻止写入，>600 行警告
- **post-file-write** — 代码质量报告（方法行数、嵌套深度、代码异味、auto-linter）
- **commit-msg** — git hook 层强制 `✅[Reviewed]` 前缀（可选，需在目标仓库执行 setup）

## Project Structure / 项目结构

```
scrum-skills/
├── AGENTS.md               ← Harness 地图式入口
├── .claude/
│   └── settings.json       ← 安装脚本会部署到目标 Agent 目录
├── README.md               ← 本文件
└── skills/                 ← 安装脚本部署的技能目录
    ├── 0-emperor/           # 👑 皇上
    ├── 0-taizi/             # 🤴 太子
    ├── 0-zhongshu-province/ # 📜 中书省
    ├── 0-menxia-province/   # 🔍 门下省
    ├── 0-shangshu-province/ # 📮 尚书省
    ├── 0-workflow-runner/   # 🔄 工作流编排器
    ├── 0-scrum-master/      # 敏捷教练
    ├── 1~8-*/               # 六部执行层
    ├── config/              # 共享配置（含 harness-playbook.md）
    └── hooks/               # 代码质量钩子
```

## Setup Options / 配置选项

```bash
sh install.sh                                  # 推荐：一键安装（自动执行 setup）
sh ~/.claude/skills/hooks/setup.sh               # 手动执行 setup（自动检测交互模式）
sh ~/.claude/skills/hooks/setup.sh --default     # 非交互模式，使用默认值
sh ~/.claude/skills/hooks/setup.sh --interactive # 强制交互模式
sh ~/.claude/skills/hooks/setup.sh --lang=en     # 设置语言
sh ~/.claude/skills/hooks/setup.sh --nickname=XX # 设置昵称（默认：吴彦祖）
sh ~/.claude/skills/hooks/setup.sh --no-git-hook # 跳过 git hook 安装
sh ~/.claude/skills/hooks/setup.sh --skip-repo-map # 跳过 repo-map 生成
sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo # 对指定仓库安装commit-msg hook
```

## Design Principles / 设计原则

1. **零安装** — 无需 pip/npm/brew，一条 `sh install.sh` 即用
2. **全自动编排** — 输入需求后全流程自动流转，无需手动调用每个技能
3. **双模式** — 三省六部（质量优先）+ 敏捷（效率优先），按需切换
4. **中断恢复** — workflow-state.json 记录进度，中断后可从断点恢复
5. **质量内建** — hooks 强制代码规范 + 门下省/code-reviewer 把关提交
6. **通用适配** — 不限语言框架，根据项目自动适配
7. **Harness 化协作** — `AGENTS.md` 作为活文档，约束执行顺序与持续反馈

## Harness Baseline / 驭缰基线

仓库内落地文件：

- `AGENTS.md`：地图式入口（渐进披露）
- `skills/config/harness-playbook.md`：Harness 执行约束与门禁
- `skills/config/harness-references.md`：Harness 资料索引
- `skills/hooks/*.sh`：机械化约束（Backpressure）

推荐执行顺序：Understand → Plan → Implement → Verify → Persist

## Further Reading / 延伸阅读

以下资料可用于持续完善 Harness 体系：

- OpenAI: Harness engineering (agent-first world)
- Anthropic: Effective harnesses for long-running agents
- Martin Fowler: Harness Engineering / Context Engineering
- Mitchell Hashimoto: AI adoption journey
- [deusyu/harness-engineering](https://github.com/deusyu/harness-engineering)（学习档案与实践索引）

---

## License

[ChangeLog](CHANGELOG.md)

[MulanPSL-2.0](skills/LICENSE)
