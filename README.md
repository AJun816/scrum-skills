# Scrum Skills / 敏捷团队技能组

一套完整的 AI 敏捷开发团队技能组，让 AI 成为你的开发团队。支持**三省六部模式**（全流程审核）和**敏捷模式**（快速交付）双模式自动编排。

当前版本已整合两类外部扩展：

- **The Minimalist Entrepreneur** 创业增长扩展包：`/find-community`、`/validate-idea`、`/processize`、`/minimalist-review` 等
- **gstack** 完整工程工作流扩展包：`/office-hours`、`/plan-design-review`、`/review`、`/qa`、`/ship`、`/browse` 等

## Prerequisites / 前置条件

- [Claude Code](https://claude.ai/code)
- macOS/Linux: `sh`（系统自带）
- Windows: PowerShell（系统自带，用于 `install.bat` / `install.ps1`）
- Windows 如需手动执行 `skills/hooks/setup.sh` 或 `gstack/setup`，请使用 Git Bash、WSL 或其他兼容 `sh` 的 shell
- `bun >= 1.0`：仅在你需要启用 `gstack` 完整工作流时才需要

## Documentation Map / 文档导航

- `README.md`：安装入口、使用方式、扩展技能概览
- `skills/README.md`：`skills/` 目录详细说明与安装后使用说明
- `AGENTS.md`：仓库内 AI Agent 执行约束与上下文导航
- `CHANGELOG.md`：关键文档与安装流程变更记录
- `skills/config/harness-playbook.md`：Harness 约束、执行顺序和门禁
- `skills/config/harness-references.md`：Harness 延伸阅读与参考资料

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
# 或手动执行：powershell -ExecutionPolicy Bypass -File .\install.ps1

# 3. (Optional) Enable gstack / 可选：启用 gstack 完整技能组
cd ~/.claude/skills/gstack && ./setup
# 如果你使用 --target，请把 ~/.claude 替换为你的目标目录

# 4. Start Claude Code in your project / 在你的项目里启动
cd your-project && claude
```

默认会安装到 `~/.claude/`。
如果仓库本身已经位于 `~/.claude`、`~/.warp`、`~/.cursor`、`~/.windsurf`、`~/.cline` 或 `~/.continue` 下，`install.sh` 会自动识别当前 Agent 目录并直接安装到那里。

Shell 安装器 `install.sh` 可选参数：

```bash
sh install.sh --agent=warp                # 安装到 ~/.warp
sh install.sh --target=/path/to/.claude   # 指定安装目录
sh install.sh --keep-settings             # 保留已有 settings.json
sh install.sh --lang=en                   # 英文输出
```

Windows PowerShell 安装器可选参数：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Agent warp
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target C:\path\to\.claude
powershell -ExecutionPolicy Bypass -File .\install.ps1 -KeepSettings
```

若使用 `--target` 或 `-Target`，后续 `setup.sh` 路径请将 `~/.claude` 替换为你的目标目录。

## What The Installer Does / 安装器做了什么

执行 shell 安装器 `sh install.sh` 后，默认会完成这些动作：

1. 计算安装目标：优先使用 `--target`，其次使用 `--agent`，否则尝试识别当前仓库是否位于已知 Agent 目录下，最后回落到 `~/.claude/`
2. 将 `skills/` 复制到目标 Agent 目录，例如 `~/.claude/skills/`
3. 将 `.claude/settings.json` 复制到目标 Agent 目录，并把 hooks 路径改写成目标绝对路径
4. 自动执行 `skills/hooks/setup.sh --default --skip-repo-map`
5. 默认启用主技能组；`gstack` 仅做 vendoring，不会自动运行其 `./setup`

如果你走的是 Windows 原生安装器 `install.bat` / `install.ps1`，则只会完成前 2 步，不会自动执行 `setup.sh`。

这意味着：

- 主技能组安装后即可使用
- `gstack` 安装后仍需你手动执行一次 `~/.claude/skills/gstack/setup`
- Windows 原生安装后，如需生成 `user-config.json`、安装仓库 `commit-msg` hook、生成 `repo-map` 或启用 `gstack`，请在兼容 `sh` 的 shell 中手动执行对应 `setup.sh`
- 如需给某个仓库安装 `commit-msg` hook，请单独执行：

```bash
sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo
```

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

## Extension Packs / 扩展技能包

### gstack

同步来源：`garrytan/gstack` 主分支快照（版本 `0.11.20.0`，下载于 `2026-03-26`）

- 集成方式：以 vendored 形式保留完整运行时于 `skills/gstack/`
- 适用场景：设计审查、浏览器 QA、发布、回顾、安全审查、自动计划等完整工程流程
- 代表命令：`/office-hours`、`/plan-ceo-review`、`/plan-design-review`、`/review`、`/qa`、`/ship`、`/browse`、`/retro`
- 启用方式：复制本仓库到项目后，进入 `~/.claude/skills/gstack && ./setup`
- 额外依赖：`bun >= 1.0`，首次 setup 会处理生成技能文档和 Playwright/Chromium

由于 gstack 自带 `setup`、`browse`、遥测与生成流程，这一包采用整仓集成，而不是把 28 个技能直接平铺进当前 `skills/` 根目录。默认安装只会把它复制到目标目录，不会自动执行 `gstack/setup`。

### The Minimalist Entrepreneur

同步来源：`slavingia/skills@f4e1bf8`

| Skill | Command | Role / 职责 |
|---|---|---|
| Find Community | `/find-community` | 从你已加入的社群里识别值得长期服务的人群和持续痛点 |
| Validate Idea | `/validate-idea` | 先验证问题和付费意愿，再决定是否值得投入构建 |
| MVP | `/mvp` | 约束 MVP 范围，优先手工、无代码或极小实现 |
| Processize | `/processize` | 先把产品设想变成今天就能交付的手工流程 |
| First Customers | `/first-customers` | 为前 100 个客户制定一对一销售策略 |
| Pricing | `/pricing` | 制定起始定价并校准成本与价值逻辑 |
| Marketing Plan | `/marketing-plan` | 在有初步 PMF 后，用内容而非广告扩大受众 |
| Grow Sustainably | `/grow-sustainably` | 用盈利、可逆性和耐久性评估增长决策 |
| Company Values | `/company-values` | 明确公司价值观、文化边界和招聘信号 |
| Minimalist Review | `/minimalist-review` | 用极简创业原则审视任何商业决策 |

这些扩展技能保留了上游命令名，方便直接迁移和后续同步；它们不接入 `0-workflow-runner` 自动编排，建议按需单独调用。

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

# 创业增长扩展技能
/find-community 帮我找出 scrum-skills 最适合服务的 3 个用户社群
/processize 把“AI 敏捷开发陪跑服务”先设计成手工可交付流程
/minimalist-review 评估是否要把当前项目做成付费产品

# gstack 扩展技能（需先执行 ~/.claude/skills/gstack/setup）
/office-hours 帮我重新定义这个功能真正要解决的问题
/plan-design-review 审一下当前设计方案是否有 AI slop
/qa https://staging.example.com
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
    ├── gstack/              # 外部整仓扩展：完整工程工作流技能组
    ├── find-community/      # 外部扩展：社群发现
    ├── validate-idea/       # 外部扩展：创业验证
    ├── mvp/                 # 外部扩展：MVP 收敛
    ├── processize/          # 外部扩展：手工流程设计
    ├── first-customers/     # 外部扩展：前 100 客户
    ├── pricing/             # 外部扩展：定价策略
    ├── marketing-plan/      # 外部扩展：内容增长
    ├── grow-sustainably/    # 外部扩展：可持续增长
    ├── company-values/      # 外部扩展：公司价值观
    ├── minimalist-review/   # 外部扩展：极简创业评审
    ├── config/              # 共享配置（含 harness-playbook.md）
    └── hooks/               # 代码质量钩子
```

## Upstream Sync / 外部来源

- 创业增长扩展包同步自 `https://github.com/slavingia/skills`
- 当前集成提交：`f4e1bf8dd9c3a63eebab662fc57396183446068b`
- 每个外部技能目录下都包含 `.source.json`，用于记录来源、版本和更新时间
- gstack 以 vendored 形式集成在 `skills/gstack/`，保持其原始目录结构和 setup 流程

## Docs Maintenance / 文档维护原则

检查文档完整性时，优先核对以下一致性：

1. `README.md` 的安装步骤必须与 `install.sh`、`install.bat`、`install.ps1` 的真实行为一致
2. `skills/README.md` 的目录说明必须与 `skills/` 实际结构一致
3. `AGENTS.md`、`skills/config/*.md` 中提到的路径必须真实存在
4. 新增外部技能包时，必须同时补充来源说明、启用方式和依赖边界

## Maintainer Workflow / 仓库维护者调试

如果你是在当前仓库里调试技能，而不是安装到用户目录，可直接运行仓库内的 setup：

```bash
sh skills/hooks/setup.sh --default
```

这会在当前仓库的 `.claude/skills/` 下为各技能目录创建软链接；如果系统不支持软链接，则回退为复制。该模式适合维护技能文档、hooks 或本地联调，不会替代正式安装流程。

## Setup Options / 配置选项

以下命令均为 shell 版本；Windows 原生 PowerShell 安装器不会自动运行它们，如需手动执行请使用 Git Bash、WSL 或其他兼容 `sh` 的 shell。

```bash
sh install.sh                                    # 推荐：一键安装（自动执行 setup）
sh ~/.claude/skills/hooks/setup.sh               # 手动执行 setup（自动检测交互模式）
sh ~/.claude/skills/hooks/setup.sh --default     # 非交互模式，使用默认值
sh ~/.claude/skills/hooks/setup.sh --interactive # 强制交互模式
sh ~/.claude/skills/hooks/setup.sh --lang=en     # 设置语言
sh ~/.claude/skills/hooks/setup.sh --nickname=XX # 设置昵称（默认：吴彦祖）
sh ~/.claude/skills/hooks/setup.sh --no-git-hook # 跳过 git hook 安装
sh ~/.claude/skills/hooks/setup.sh --skip-repo-map # 跳过 repo-map 生成
sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo # 对指定仓库安装 commit-msg hook
```

## Design Principles / 设计原则

1. **核心一键安装** — 主技能组通过 `sh install.sh` 即可启用；`gstack` 属于可选扩展，启用时需 `bun`
2. **全自动编排** — 输入需求后全流程自动流转，无需手动调用每个技能
3. **双模式** — 三省六部（质量优先）+ 敏捷（效率优先），按需切换
4. **中断恢复** — workflow-state.json 记录进度，中断后可从断点恢复
5. **质量内建** — hooks 强制代码规范 + 门下省/code-reviewer 把关提交
6. **通用适配** — 不限语言框架，根据项目自动适配
7. **Harness 化协作** — `AGENTS.md` 作为活文档，约束执行顺序与持续反馈
8. **外部技能可整合** — `setup.sh` 会自动发现并链接所有含 `SKILL.md` 的技能目录，便于引入第三方技能包

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

[MulanPSL-2.0](LICENSE)
