# Scrum Skills / 敏捷团队技能组

一套完整的 AI 敏捷开发团队技能组，让 AI 成为你的开发团队。支持**三省六部模式**（全流程审核）和**敏捷模式**（快速交付）双模式自动编排。


## Quick Start / 快速开始

```bash
# 1. Clone / 克隆
git clone https://gitee.com/ajun816/scrum-skills.git
# or GitHub
git clone https://github.com/AJun816/scrum-skills.git

# 2. Copy to your project / 复制到你的项目
cp -r scrum-skills/skills/ your-project/.claude/skills/
cp scrum-skills/.claude/settings.json your-project/.claude/settings.json

# 3. (Optional) Setup / 可选：配置昵称和 git hook
sh your-project/.claude/skills/hooks/setup.sh --default    # 非交互模式（推荐）
# 或
sh your-project/.claude/skills/hooks/setup.sh              # 交互模式
# setup.sh 会自动创建 .claude/skills/ 软链接、安装 git hook、生成项目 repo map

# 4. Start Claude Code / 启动
cd your-project && claude
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
- **commit-msg** — git hook 层强制 `✅[Reviewed]` 前缀（需 setup.sh）

## Project Structure / 项目结构

```
scrum-skills/
├── .claude/
│   └── settings.json      ← Hooks 配置（复制到你的项目）
├── README.md               ← 本文件
└── skills/                 ← 复制到 .claude/skills/
    ├── 0-emperor/           # 👑 皇上
    ├── 0-taizi/             # 🤴 太子
    ├── 0-zhongshu-province/ # 📜 中书省
    ├── 0-menxia-province/   # 🔍 门下省
    ├── 0-shangshu-province/ # 📮 尚书省
    ├── 0-workflow-runner/   # 🔄 工作流编排器
    ├── 0-scrum-master/      # 敏捷教练
    ├── 1~8-*/               # 六部执行层
    ├── config/              # 共享配置
    └── hooks/               # 代码质量钩子
```

## Setup Options / 配置选项

```bash
sh .claude/skills/hooks/setup.sh                # 自动检测（终端=交互，管道=默认）
sh .claude/skills/hooks/setup.sh --default      # 非交互模式，使用默认值
sh .claude/skills/hooks/setup.sh --interactive  # 强制交互模式
sh .claude/skills/hooks/setup.sh --lang=en      # 设置语言
sh .claude/skills/hooks/setup.sh --nickname=XX  # 设置昵称（默认：吴彦祖）
sh .claude/skills/hooks/setup.sh --no-git-hook  # 跳过 git hook 安装
```

## Design Principles / 设计原则

1. **零安装** — 无需 pip/npm/brew，复制粘贴即用
2. **全自动编排** — 输入需求后全流程自动流转，无需手动调用每个技能
3. **双模式** — 三省六部（质量优先）+ 敏捷（效率优先），按需切换
4. **中断恢复** — workflow-state.json 记录进度，中断后可从断点恢复
5. **质量内建** — hooks 强制代码规范 + 门下省/code-reviewer 把关提交
6. **通用适配** — 不限语言框架，根据项目自动适配

---

## License

[MulanPSL-2.0](skills/LICENSE)
