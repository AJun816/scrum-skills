# Scrum Skills V3 Architecture

`Scrum Skills` V3 的定位已经收敛为：

> 面向 Claude / Codex / GitHub Copilot 等成熟宿主的 Host-Native Skills Harness 平台。

它不是新的 AI IDE，也不是新的聊天产品。当前实现聚焦在宿主之上补齐：

- 项目级 Harness 初始化
- 三省六部 / 敏捷流程的真实运行时
- 结构化磁盘事实源
- 外部技能包治理与安装更新
- 可选的 npm CLI 包装层

## 1. 设计约束

当前架构必须同时满足这些硬约束：

1. `sh install.sh` 仍然是主安装路径
2. 核心能力保持零额外环境，不强制要求 Python / Node.js / bun
3. `.harness/` 是项目级事实源
4. 外部扩展包默认独立调用，不自动接入 `0-workflow-runner`
5. `~/.claude` 才会自动接入 `.claude/settings.json` hooks
6. `~/.codex` 与其他自定义目标只做 skill-only 安装

## 2. 架构原则

### 2.1 Host-Native

- 会话、模型调用、权限控制由 Claude / Codex / Copilot 负责
- Scrum Skills 只补“流程、约束、事实源、门禁”
- 宿主差异通过安装层与技能调用方式吸收

### 2.2 Facts On Disk

流程状态、项目画像、规则、扩展包元数据都必须落盘：

- `PROJECT_CONFIG.md`
- `.harness/`
- `.cache/.project-info.json`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`
- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`

### 2.3 Git-First Harness

- Git 门禁通过 `core.hooksPath = .harness/git-hooks` 生效
- `harness-check` / `harness-fix` / `harness-gate` 对仓库漂移做机械化约束
- `harness-worktree` / `harness-checkpoint` 负责任务隔离与阶段性提交

### 2.4 Optional Enhancements

- npm CLI `skills` 是可选包装层，不替代 `sh install.sh`
- gstack 是可选整仓扩展，不污染核心安装路径
- 不把 Studio、Dashboard、审批 UI 作为主线模块

## 3. 模块分层

### 3.1 Install Layer

职责：

- 识别安装目标（Claude / Codex / 自定义 target）
- 复制技能组与配置文件
- 在 Claude 目标下部署 `.claude/settings.json`
- 暴露可选 `skills` CLI

当前入口：

- `install.sh`
- `install.ps1`
- `package.json`
- `bin/skills.mjs`

### 3.2 Harness Core

职责：

- 初始化项目级 `.harness/`
- 生成 `PROJECT_CONFIG.md` 与 `.cache/.project-info.json`
- 生成 `.cache/shared/repo-map.md` 与 `.cache/shared/repo-index.json`
- 接入 `core.hooksPath = .harness/git-hooks`
- 提供 check / fix / gate / selfcheck / worktree / checkpoint 能力

当前目录：

- `skills/hooks/`
- `skills/harness/bin/`
- `.harness/`

### 3.3 Workflow Runtime

职责：

- 将 `0-workflow-runner` 的流程说明落成真实状态机
- 支持 `start / status / resume / approve / reject / abort / reset`
- 维护步骤状态、封驳次数、恢复点与事件流
- 在执行类步骤后自动接入 Harness 校验闭环

当前目录：

- `skills/runtime/bin/`
- `skills/runtime/lib/`
- `skills/runtime/schemas/`

### 3.4 Knowledge Plane

职责：

- 为技能、runtime、Harness 提供共享事实源
- 同时保留 Markdown 地图和 JSON 索引
- 让“人读”和“脚本消费”使用同一批磁盘产物

当前核心文件：

- `PROJECT_CONFIG.md`
- `.cache/.project-info.json`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`
- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`

### 3.5 Pack Registry

职责：

- 纳管外部技能包的来源、依赖、宿主兼容与中文入口
- 提供 list / doctor / install / update / selfcheck
- 保护扩展包的依赖边界，不把可选依赖推给核心用户

当前目录：

- `skills/registry/bin/`
- `skills/registry/lib/`
- `skills/*/.source.json`
- `skills/*/pack.json`

## 4. Workflow Runtime 现状

### 4.1 模式

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

### 4.2 命令面

当前已实现：

- `workflow.sh start`
- `workflow.sh status`
- `workflow.sh resume`
- `workflow.sh approve`
- `workflow.sh reject`
- `workflow.sh abort`
- `workflow.sh reset`
- `workflow-selfcheck.sh`
- `workflow-approve.sh` / `workflow-status.sh` / `workflow-resume.sh` 等快捷包装脚本

### 4.3 运行时文件

默认操作当前项目的：

- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`
- `.cache/shared/workflow-runtime/`

如果项目已经完成 Harness 初始化，`workflow-state.json` 还会引用：

- `PROJECT_CONFIG.md`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`
- `.harness/project-profile.json`
- `.harness/state/last-report.json`

### 4.4 回退与门禁

拒绝后不会直接自动重跑业务步骤，而是：

1. 记录拒绝步骤和原因
2. 根据模式推导回退目标
3. 将 workflow 置为 `paused`
4. 等待宿主或用户执行 `resume`

在执行类步骤上，`approve` 会自动触发：

1. `sh .harness/bin/harness-check.sh --changed-files --json`
2. 必要时 `sh .harness/bin/harness-fix.sh --changed-files`
3. 再检查，最多重试数轮
4. 无法修复时将 workflow 置为 `paused`

## 5. Harness 现状

当前 `setup.sh --project-root=...` 或 `harness-init.sh` 会生成：

- `.harness/README.md`
- `.harness/project-profile.json`
- `.harness/architecture/contract.yaml`
- `.harness/architecture/dependency-rules.yaml`
- `.harness/rules/*.yaml`
- `.harness/git-hooks/pre-commit`
- `.harness/git-hooks/commit-msg`
- `.harness/git-hooks/pre-push`
- `.harness/bin/harness-init.sh`
- `.harness/bin/harness-check.sh`
- `.harness/bin/harness-fix.sh`
- `.harness/bin/harness-gate.sh`
- `.harness/bin/harness-worktree.sh`
- `.harness/bin/harness-checkpoint.sh`
- `.harness/bin/harness-repo-map.sh`
- `.harness/bin/harness-repo-index.sh`
- `.harness/bin/harness-selfcheck.sh`
- `.harness/state/drift-baseline.json`
- `.harness/state/last-report.json`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`

这意味着 Harness 已经不是“文档建议”，而是实际脚本与 Git 门禁。

## 6. Pack Registry 现状

当前 registry 已经实现：

- `pack-list.sh`
- `pack-doctor.sh`
- `pack-install.sh`
- `pack-update.sh`
- `pack-selfcheck.sh`

`pack-doctor` 会校验：

- `.source.json`
- `pack.json`
- `pack.json` 中的最小字段集合
- `docs.zh_cn` 指向的中文入口说明
- `hosts` 不为空

Pack Registry 当前已经纳管：

- `gstack`
- `find-community`
- `validate-idea`
- `mvp`
- `processize`
- `first-customers`
- `pricing`
- `marketing-plan`
- `grow-sustainably`
- `company-values`
- `minimalist-review`

## 7. 关于 Studio

V3 不把 `Studio` 作为主线模块。

理由：

- 本项目服务的主要对象是 Claude、Codex 这类成熟宿主
- 宿主已经提供会话、模型、工具与权限体系
- Scrum Skills 的价值在“流程 Harness + 事实源 + 门禁”，不是重复造一个界面层

如果未来需要可视化能力，也只能作为可选的只读观测层存在，例如：

- 查看 workflow 状态
- 查看 Harness 报告
- 查看 pack 清单

它不能替代主安装路径，也不能变成默认依赖。

## 8. 外部项目借鉴边界

### 借鉴 `claude-code-templates`

借：

- Pack / plugin 管理视角
- 多来源安装与诊断入口
- 把“观测层”放在增强层，而不是核心层

不借：

- 重型 UI 作为核心入口
- 强依赖 Node 的默认安装路径

### 借鉴 `claude-code-cli`

借：

- `commands / services / state / tasks / tools` 的运行时分层
- 会话状态和任务状态独立落盘
- 宿主适配，而不是把所有逻辑塞进单个脚本

不借：

- 把本项目演化成新的终端产品
- 直接依赖上游内部运行时实现

## 9. 当前完成标准

当前版本至少满足：

1. `sh install.sh` 仍然是最短安装路径
2. `workflow-state.json`、`workflow-runs.jsonl`、`repo-map.md`、`repo-index.json` 都是实际落盘结果
3. 用户可以用 shell 命令驱动 workflow 的开始、查看、恢复、准奏、封驳、终止
4. 执行类步骤会自动接入 Harness 校验闭环
5. `pack list / doctor / install / update / selfcheck` 已可执行
6. README、`skills/README.md`、`AGENTS.md` 与脚本行为保持一致
7. 不引入新的强制依赖，也不改变 `sh install.sh` 主路径
