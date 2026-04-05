# 敏捷团队技能组

**推荐通过仓库根目录一键安装（`sh install.sh`）后使用。**

当前目录已额外整合 `slavingia/skills` 的 10 个创业增长技能，保留原始命令名，适合在做产品方向、验证商业价值、设计手工交付流程和早期增长策略时直接调用。

同时也 vendoring 进来了 `garrytan/gstack`，保留其完整运行时目录，适合在需要设计审查、浏览器 QA、发布和复盘流程时启用。

仓库根目录现在还提供一个可选的 npm CLI 包装层。安装后可通过 `skills` 命令管理安装、Harness、自检、Workflow 和扩展包；但主路径仍然是 `sh install.sh`。

## 文档导航

- `../README.md`：仓库级安装入口、扩展技能概览
- `README.md`：当前 `skills/` 目录说明
- `../AGENTS.md`：仓库内 Agent 执行约束
- `config/harness-playbook.md`：Harness 约束与门禁
- `../docs/architecture-v3.md`：V3 Host-Native Skills Harness 架构设计
- `config/extension-pack-guidelines.md`：外部技能包迁移规范
- `registry/README.md`：Pack Registry 命令与扩展包元数据规则
- `config/harness-references.md`：Harness 延伸阅读
- `gstack/COMMANDS.zh-CN.md`：gstack 中文命令目录

## 快速开始

### 1. 一键安装（推荐）

```bash
# 在仓库根目录执行
sh install.sh               # 默认安装到 ~/.claude
sh install.sh --agent=codex # 如果你使用 Codex
# Windows 可直接双击 install.bat（无需 Git Bash）
```

默认安装到 `~/.claude/`。
如果仓库本身已经位于 `~/.claude`、`~/.codex`、`~/.warp`、`~/.cursor`、`~/.windsurf`、`~/.cline` 或 `~/.continue` 下，`install.sh` 会自动识别当前 Agent 目录并直接安装到那里。只有 `~/.claude` 会自动部署 `settings.json` hooks；其他目标默认只部署技能组与 setup 脚本。可选参数：

```bash
sh install.sh --agent=codex
sh install.sh --target=/path/to/.claude
sh install.sh --keep-settings
sh install.sh --lang=en
```

Windows PowerShell 原生安装也支持以下参数：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Agent codex
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Target C:\path\to\.claude
powershell -ExecutionPolicy Bypass -File .\install.ps1 -KeepSettings
```

如果使用 `--target` 或 `-Target`，后续 `setup.sh` 路径请替换成你的目标目录。

### 可选：npm CLI

```bash
# 全局安装并暴露 skills 命令
npm install -g github:AJun816/scrum-skills
skills install --agent=codex
skills harness selfcheck
skills pack list

# 零安装临时执行
npx --yes --package github:AJun816/scrum-skills skills doctor
```

注意：公开 npm 上已有一个无关的 `skills` 包，因此“公网直接 `npx skills`”不由本仓库控制。当前仓库保证的是 `skills` 二进制和 `npx --package ... skills ...` 这种零安装调用方式。

### 安装后默认状态

- 主技能组安装后即可使用
- 如果目标是 `~/.claude`，`.claude/settings.json` 中的 hooks 路径会被安装器改写到目标目录
- 如果目标是 `~/.codex` 或其他目录，则不会伪装成 Claude 配置目录
- `sh install.sh` 会自动执行 `skills/hooks/setup.sh --default --skip-repo-map`，只完成用户级配置
- Windows 原生 `install.bat` / `install.ps1` 不会自动执行 `setup.sh`
- `gstack/` 会被复制过去，但不会自动执行其 `setup`
- `runtime/` 会随技能组一起安装，作为 workflow-runner 的真实运行时骨架，并提供 `workflow-selfcheck.sh`
- `registry/` 会随技能组一起安装，提供 `pack-list` / `pack-doctor` / `pack-install` / `pack-update` / `pack-selfcheck`
- 仓库根目录的 npm CLI 可暴露 `skills install/setup/harness/workflow/pack/doctor`
- 如需启用 `gstack`，请额外执行 `<target>/skills/gstack/setup`
- 如需为任意项目生成 `.harness/`、`PROJECT_CONFIG.md`、`.cache/.project-info.json`、版本化 git hooks 或 `repo-map`，请在兼容 `sh` 的 shell 中手动执行 `setup.sh --project-root=/path/to/repo`

### 2. 开始使用

**自动编排模式（推荐）：** 输入需求，全自动流转到底。

Claude Code 可直接使用 `/0-emperor`、`/0-scrum-master`。
如果你使用 Codex 或其他 Agent，请按该 Agent 的技能调用方式触发同名技能。

```
# 三省六部模式（复杂任务，全流程审核）
/0-emperor 开发用户登录功能，要求 JWT 鉴权 + Redis 缓存

# 敏捷模式（简单任务，快速处理）
/0-scrum-master 修复登录按钮样式问题
```

无需手动调用每个技能，workflow-runner 自动按链条调度：
- 三省六部：太子→中书省→门下省→尚书省→六部→门下省→中书省→皇上
- 敏捷：PM + Architect 并行→Dev 并行→Code Review→提交

### 3. 手动 setup（可选）

以下命令需在支持 `sh` 的 shell 中执行；Windows 建议使用 Git Bash、WSL 或等效环境。

```bash
sh ~/.claude/skills/hooks/setup.sh --default
sh ~/.codex/skills/hooks/setup.sh --default
sh ~/.claude/skills/hooks/setup.sh --interactive
sh ~/.claude/skills/hooks/setup.sh --lang=en
sh ~/.claude/skills/hooks/setup.sh --nickname=XX
sh ~/.claude/skills/hooks/setup.sh --no-git-hook
sh ~/.claude/skills/hooks/setup.sh --skip-repo-map
sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo
```

如果你是在当前仓库里直接维护技能，而不是安装到用户目录，可运行：

```bash
sh skills/hooks/setup.sh --default
```

该命令会在当前仓库的 `.claude/skills/` 与 `.codex/skills/` 下创建软链接；不支持软链接时回退为复制，适合本地调试 `SKILL.md`、hooks 和共享配置。

### 4. 创业增长扩展技能（独立调用，不接入自动编排）

```text
/find-community 识别你已经身处其中、且可长期服务的社群
/validate-idea 先验证问题和付费意愿，再决定是否投入开发
/processize 把产品想法改写成今天就能手工交付的流程
/minimalist-review 用极简创业视角审查你的商业决策
```

## 文件说明

```
skills/
├── config/                        # 共享配置
│   ├── mandatory-rules.md         # 强制执行规范
│   ├── coding-standards.md        # 编码规范
│   ├── workflow-guide.md          # 工作流程指南
│   ├── init-guide.md              # 初始化指南
│   ├── permission-matrix.md       # 权限矩阵
│   ├── skill-groups.md            # 技能分组
│   ├── skill-metadata.md          # 技能元数据
│   ├── harness-playbook.md        # Harness 约束与门禁
│   ├── extension-pack-guidelines.md # 外部技能包迁移规范
│   └── harness-references.md      # Harness 延伸阅读
├── hooks/                         # 代码质量钩子（自动生效）
├── registry/                      # Pack Registry（扩展包清单 / 安装 / 更新 / 诊断）
├── runtime/                       # Workflow Runtime（状态机 / 恢复 / 审批 / 自检）
├── harness/                       # Harness 内核（init / check / fix / repo-map / repo-index）
├── .cache/                        # 缓存目录（自动生成，已gitignore）
│
├── 0-emperor/                     # 👑 皇上（三省六部入口）
├── 0-taizi/                       # 🤴 太子（消息分拣）
├── 0-zhongshu-province/           # 📜 中书省（规划中枢）
├── 0-menxia-province/             # 🔍 门下省（质量门禁）
├── 0-shangshu-province/           # 📮 尚书省（派发协调）
├── 0-workflow-runner/             # 🔄 工作流编排器（自动驱动全流程）
├── 0-scrum-master/                # 敏捷教练
├── 1-business-expert/             # 业务专家
├── 2-product-manager/             # 产品经理
├── 3-system-architect/            # 系统架构师
├── 4-backend-dev/                 # 后端开发（通用语言）
├── 4-frontend-dev/                # 前端开发（通用框架）
├── 4-nielsen-ui-design/           # UI/UX设计（尼尔森原则）
├── 4-frontend-design/             # 前端视觉设计
├── 5-devops-engineer/             # DevOps工程师
├── 5-webapp-testing/              # Web应用测试
├── 6-bug-handler/                 # Bug处理专家
├── 7-skill-creator/               # 技能创建器
├── 8-code-reviewer/               # 代码审查专家
├── gstack/                        # 外部整仓扩展：完整工程工作流技能组
├── find-community/                # 外部扩展：社群发现
├── validate-idea/                 # 外部扩展：创业验证
├── mvp/                           # 外部扩展：MVP 收敛
├── processize/                    # 外部扩展：手工流程设计
├── first-customers/               # 外部扩展：前 100 客户
├── pricing/                       # 外部扩展：定价策略
├── marketing-plan/                # 外部扩展：内容增长
├── grow-sustainably/              # 外部扩展：可持续增长
├── company-values/                # 外部扩展：公司价值观
├── minimalist-review/             # 外部扩展：极简创业评审
│
├── PROJECT_CONFIG.md              # 项目配置（自动生成）
├── PROJECT_CONFIG.template.md     # 配置模板（参考）
└── README.md                      # 本文件
```

## 技能列表

| 技能 | 说明 | 使用场景 |
|------|------|----------|
| 0-emperor | 👑 皇上 | 三省六部模式入口，下旨启动全流程 |
| 0-taizi | 🤴 太子 | 消息分拣，闲聊直接回 / 旨意传中书省 |
| 0-zhongshu-province | 📜 中书省 | 规划中枢，调用 PM + Architect |
| 0-menxia-province | 🔍 门下省 | 质量门禁，审核/封驳 |
| 0-shangshu-province | 📮 尚书省 | 派发协调，调度六部执行 |
| 0-workflow-runner | 🔄 工作流编排器 | 自动驱动全流程，无需手动调用每个技能 |
| 0-scrum-master | 敏捷教练 | 组织敏捷仪式、协调团队、移除障碍 |
| 1-business-expert | 业务专家 | 梳理业务流程、定义业务规则 |
| 2-product-manager | 产品经理 | 需求分析、用户故事、需求变更 |
| 3-system-architect | 系统架构师 | 架构设计、技术选型、任务拆解 |
| 4-backend-dev | 后端开发 | 后端代码实现、API开发（根据项目自动适配语言） |
| 4-frontend-dev | 前端开发 | 前端页面开发、组件设计（根据项目自动适配框架） |
| 4-nielsen-ui-design | UI/UX设计 | 基于尼尔森原则的可用性设计 |
| 4-frontend-design | 前端视觉设计 | 创意视觉设计、品牌形象 |
| 5-devops-engineer | DevOps工程师 | CI/CD、自动化部署、监控 |
| 5-webapp-testing | Web应用测试 | 自动化测试、功能验证 |
| 6-bug-handler | Bug处理专家 | Bug分析、修复协调、验证 |
| 7-skill-creator | 技能创建器 | 创建新技能、扩展团队能力 |
| 8-code-reviewer | 代码审查专家 | git提交前代码审查、质量把关 |

### 外部扩展技能：The Minimalist Entrepreneur

同步来源：`slavingia/skills@f4e1bf8`

| 技能 | 命令 | 使用场景 |
|------|------|----------|
| Find Community | `/find-community` | 寻找商业方向、识别最值得服务的社群 |
| Validate Idea | `/validate-idea` | 验证创业想法是否值得继续推进 |
| MVP | `/mvp` | 收敛 MVP 范围，避免过度构建 |
| Processize | `/processize` | 先用手工流程交付价值，再决定自动化 |
| First Customers | `/first-customers` | 制定前 100 个客户的销售动作 |
| Pricing | `/pricing` | 设置初始定价和未来分层 |
| Marketing Plan | `/marketing-plan` | 设计内容驱动的增长方案 |
| Grow Sustainably | `/grow-sustainably` | 评估花钱、招聘、扩张是否可持续 |
| Company Values | `/company-values` | 定义公司文化和价值观边界 |
| Minimalist Review | `/minimalist-review` | 用极简创业原则快速复盘决策 |

这些技能与主流程技能并列存在，但不会自动加入 `0-workflow-runner` 调度。

### 外部整仓扩展：gstack

同步来源：`garrytan/gstack` 主分支快照（版本 `0.11.20.0`，下载于 `2026-03-26`）

| 入口 | 说明 | 启用方式 |
|------|------|----------|
| `gstack/` | 保留完整运行时、setup、browse、review、qa、ship 等工作流能力 | 复制到项目后执行 `<target>/skills/gstack/setup` |

说明：
- 这不是纯 `SKILL.md` 技能包，而是带运行时和生成流程的完整工程工具栈
- 代表命令包括 `/office-hours`、`/plan-design-review`、`/review`、`/qa`、`/ship`、`/browse`
- 中文目录见 `gstack/COMMANDS.zh-CN.md`
- 需要 `bun >= 1.0`；首次 setup 会处理生成技能文档和 Playwright/Chromium

## 核心机制

### 配置驱动

所有技能读取 `PROJECT_CONFIG.md` 获取项目信息（技术栈、业务域、架构模式等），确保统一上下文，节约 70-80% Token。

### 数据验证（Read-First）

防止AI幻觉：所有回答前必须先读取文件验证，标注数据来源，不确定时明确说明。

### 代码质量钩子

如果目标安装到 `~/.claude`，这些钩子会通过 `.claude/settings.json` 自动生效；任意项目执行 `setup.sh --project-root=...` 后，还会获得版本化的 `.harness/git-hooks`：
- 文件超800行阻止写入
- 检测密码/密钥泄露
- 阻止危险命令（force push、DROP TABLE等）
- `.harness/git-hooks` 在 commit / push 时再次强制校验，且不允许 `[skip-review]`
- git commit 需要代码审查标记

### 智能缓存

技能自动缓存项目信息到 `.cache/` 目录，使用 `git diff` 增量更新。

### 团队共享文档

技能产出保存到 `.cache/shared/`，一次产出多次使用，避免重复劳动。

### Harness 基线

- `AGENTS.md`：地图式入口，控制上下文加载与执行顺序
- `config/harness-playbook.md`：可执行的 Harness 约束与门禁
- `config/extension-pack-guidelines.md`：迁移技能包的设计边界
- `config/harness-references.md`：Harness 学习与实践资料索引
- `gstack/COMMANDS.zh-CN.md`：迁移技能的中文命令目录
- `hooks/*.sh`：机械化约束（Backpressure）

### 延伸资料

- OpenAI / Anthropic / Martin Fowler Harness 系列文章
- [deusyu/harness-engineering](https://github.com/deusyu/harness-engineering)（学习路径与案例索引）

## 设计原则

1. **一键安装即用** — 核心技能组无需 pip/npm/brew/python/bun，`sh install.sh` 即可
2. **开箱即用** — hooks 自动生效，首次使用自动初始化
3. **全自动编排** — `/0-emperor` 或 `/0-scrum-master` 启动后全流程自动流转，无需手动调用每个技能
4. **配置驱动** — 统一配置，所有技能共享
5. **通用适配** — 后端/前端技能不限语言，根据项目自动适配
6. **质量内建** — hooks 强制执行代码规范，门下省/code-reviewer 把关提交
7. **中断恢复** — workflow-state.json 记录进度，中断后可从断点恢复
8. **外部技能可整合** — 扩展包保留上游结构，并补中文入口与依赖边界
9. **完整运行时可 vendoring** — 像 `gstack` 这种带 `setup` 和运行时资产的技能组也可以整仓接入，而不是只复制提示词
