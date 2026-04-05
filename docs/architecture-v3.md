# Scrum Skills V3 Architecture

`Scrum Skills` V3 的定位收敛为：

> 面向 Claude / Codex / GitHub Copilot 等成熟宿主的 Host-Native Skills Harness 平台。

它不是新的 AI IDE，也不是新的聊天产品。它的目标是在宿主之上补齐：

- 项目级 Harness 初始化
- 三省六部 / 敏捷流程的真实运行时
- 结构化事实源与工作流状态
- 外部技能包治理与宿主兼容边界

该方向必须同时满足现有仓库约束：

1. `sh install.sh` 仍然是主安装路径
2. 核心层保持零额外环境，不强制要求 Python / Node.js / bun
3. `.harness/` 继续是项目级事实源
4. 外部扩展包默认独立调用，不自动接入 `0-workflow-runner`

## 1. 架构原则

### 1.1 Host-Native

Scrum Skills 默认假设：

- 会话、聊天、权限控制、模型调用由宿主负责
- Skills 只补“流程”和“约束”，不复制宿主已有能力
- Claude / Codex / Copilot 之间的差异通过适配层吸收

### 1.2 Core First

核心能力必须只依赖系统自带 shell / PowerShell：

- 安装
- 初始化
- Harness 检查 / 修复
- Workflow 状态机
- Pack 元数据解析

### 1.3 Facts On Disk

流程状态、项目画像、规则、扩展包来源必须全部落盘：

- `.harness/`
- `PROJECT_CONFIG.md`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`
- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`

### 1.4 Optional Enhancements

任何 UI、Dashboard、远程审批页都不是主路径。只有当团队协作需要时，才作为可选增强层接入。

## 2. 模块划分

V3 采用四层结构，不设 `Studio` 为主线模块。

### 2.1 Core Harness

职责：

- 安装到目标宿主目录
- 初始化项目级 `.harness/`
- 接入 `core.hooksPath = .harness/git-hooks`
- 执行 `harness-check` / `harness-fix`
- 提供 `worktree` / `checkpoint` 等 Git-first 能力
- 提供可选的 npm CLI 包装层，但不替代 `sh install.sh`

现有目录：

- `install.sh`
- `install.ps1`
- `package.json`
- `bin/skills.mjs`
- `skills/hooks/`
- `skills/harness/bin/`

### 2.2 Workflow Runtime

职责：

- 将 `0-workflow-runner` 中的流程说明落成真实状态机
- 管理 `workflow-state.json`
- 支持 `start / status / resume / approve / reject / abort`
- 维护封驳次数、回退目标和恢复点
- 在执行步骤后接入 Harness 回环

目录：

- `skills/runtime/bin/`
- `skills/runtime/lib/`
- `skills/runtime/schemas/`

### 2.3 Knowledge Plane

职责：

- 维护技能共享的磁盘事实源
- 让技能既能读 Markdown 地图，也能读结构化 JSON
- 为编排器、检查器和宿主提供一致上下文

核心文件：

- `PROJECT_CONFIG.md`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`
- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`

### 2.4 Pack Registry

职责：

- 统一管理外部技能包元数据
- 声明来源、版本、依赖、宿主兼容性
- 说明是否允许接入 `0-workflow-runner`
- 提供安装、更新、诊断入口

目标目录：

- `skills/registry/bin/`
- `skills/registry/schemas/`
- `skills/*/.source.json`
- `skills/*/pack.json`

## 3. 明确不做

以下能力不进入当前主架构：

- 新的聊天 UI
- 新的 IDE / Terminal 产品
- 默认安装的 Dashboard
- 默认安装的远程审批服务
- 默认自动接入所有外部扩展包

如果未来需要 UI，只允许作为只读观测层存在：

- 查看 workflow 状态
- 查看 Harness 报告
- 查看 pack 清单

但它不能替代 Claude / Codex 自己的会话和工具执行。

## 4. Workflow Runtime 设计

### 4.1 状态

Workflow 顶层状态：

- `idle`
- `running`
- `paused`
- `completed`
- `aborted`

步骤状态：

- `pending`
- `in_progress`
- `completed`
- `rejected`
- `force_passed`
- `error`

### 4.2 模式

支持两种模式：

- `imperial`
- `agile`

`imperial` 默认步骤：

1. `taizi-triage`
2. `zhongshu-plan`
3. `menxia-review-plan`
4. `shangshu-dispatch`
5. `menxia-review-code`
6. `zhongshu-report`
7. `emperor-review`

`agile` 默认步骤：

1. `scrum-analyze`
2. `scrum-plan`
3. `scrum-execute`
4. `scrum-review`

### 4.3 运行时命令

第一阶段只实现以下入口：

- `workflow.sh start`
- `workflow.sh status`
- `workflow.sh resume`
- `workflow.sh approve`
- `workflow.sh reject`
- `workflow.sh abort`
- `workflow.sh reset`
- `workflow-selfcheck.sh`

它们默认操作当前项目的：

- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`
- `.cache/shared/workflow-runtime/`

### 4.4 回退策略

拒绝后不直接自动重跑业务步骤，而是：

1. 记录拒绝步骤
2. 记录拒绝原因
3. 根据模式和步骤推导回退目标
4. 将 workflow 置为 `paused`
5. 等待用户或宿主执行 `resume`

这样可以兼容 Claude / Codex 不同的审批与继续方式。

## 5. Knowledge Plane 设计

第一阶段新增：

- `.cache/shared/workflow-runs.jsonl`
- `.cache/shared/workflow-runtime/`

第二阶段新增：

- `.cache/shared/repo-index.json`

`repo-map.md` 继续保留，用于人类和技能快速阅读。

`repo-index.json` 用于：

- 文件级索引
- 模块级索引
- 入口文件和公共模块归档

## 6. Pack Registry 设计

每个外部包最终统一具备：

- `.source.json`
- `pack.json`
- 中文入口说明

`pack.json` 最低字段：

- `name`
- `kind`
- `source`
- `hosts`
- `runtime.dependencies`
- `capabilities`
- `workflow_integration`
- `docs`
- `security`

第一阶段先不实现 registry 命令，只锁定元数据结构和目录位置。

## 7. 分阶段实施

### Phase 1

目标：把 Workflow Runtime 从文档落成真实 shell 运行时。

交付：

- `docs/architecture-v3.md`
- `skills/runtime/bin/*`
- `skills/runtime/lib/*`
- `skills/runtime/schemas/workflow-state.schema.json`
- `skills/runtime/README.md`
- README / 技能目录同步

### Phase 2

目标：把 Pack Registry 从规范落成机制。

交付：

- `skills/registry/bin/pack-list.sh`
- `skills/registry/bin/pack-install.sh`
- `skills/registry/bin/pack-update.sh`
- `skills/registry/bin/pack-doctor.sh`
- `skills/registry/bin/pack-selfcheck.sh`
- `pack.json` schema

## 8. 外部项目借鉴边界

### 借鉴 `claude-code-templates`

借：

- Pack / plugin 管理视角
- 多来源安装与诊断入口
- 观测层是“增强层”而不是“核心层”

不借：

- 重型 UI 作为核心入口
- 强依赖 Node 的默认安装路径

### 借鉴 `claude-code-cli`

借：

- `commands / services / state / tasks / tools` 的运行时分层
- 会话状态和任务状态独立落盘
- 宿主适配而不是把所有逻辑塞进单个脚本

不借：

- 直接 vendoring 为生产运行时
- 把本项目做成新的终端产品

## 9. 成功标准

V3 第一阶段完成后，至少满足：

1. `workflow-state.json` 不再只是文档示例，而是实际落盘结果
2. 用户可以用 shell 命令驱动 workflow 的开始、查看、恢复、准奏、封驳、终止
3. 自检脚本可以覆盖 imperial / agile / reject / force-pass / abort / reset
4. README 与技能目录能说明 runtime 的真实位置和边界
5. 不引入新的强制依赖
6. 不改变 `sh install.sh` 主路径
