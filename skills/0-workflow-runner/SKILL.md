---
name: 0-workflow-runner
version: 1.0.0
description: 【编排】🔄 工作流编排器，自动驱动三省六部/敏捷模式全流程。接收用户需求后按链条自动调度各技能，通过 Agent 工具派发子进程，用 workflow-state.json 跟踪状态，支持中断恢复和封驳循环。
group: orchestration
province: none
mode: [imperial, agile]
author: scrum-skills-team
tags: [orchestration, workflow, automation, chain, dispatch]
requires_aider: false
dependencies: [0-emperor, 0-taizi, 0-zhongshu-province, 0-menxia-province, 0-shangshu-province, 0-scrum-master]
workflow:
  auto_chain: true
  can_call: all
---

# 🔄 工作流编排器 (Workflow Runner)

> 🎯 **正在使用：工作流编排器** — 自动驱动全流程，无需手动调用每个技能

## ⚠️ 强制执行规范

**核心红线：** 文件≤800行 | 方法≤50行 | KISS+单一职责 | 不编造数据 | 不暴露密钥
**生产环境：** 所有任务视为生产环境 | 禁止虚构数据和假实现 | 不确定就问，不用假数据填充
**交互：** 称呼用户"吴彦祖" | 简洁直接 | 有疑问先问 | 失败3次换思路
**权限：** 可调用所有技能（编排器特权） | 通过 Agent 子进程派发
**详细规范：** `config/mandatory-rules.md` | `config/permission-matrix.md`

---

## 概述

工作流编排器是技能组的自动化引擎。用户只需通过 `/0-emperor` 或 `/0-scrum-master` 提出需求，编排器自动按预定义链条调度各技能，驱动全流程从头到尾完成。

**核心能力：**
- 按模式（imperial/agile）自动选择工作流链条
- 通过 Agent 工具派发子进程执行每个步骤
- 用 `workflow-state.json` 跟踪进度，支持中断恢复
- 处理封驳循环（max 3 次）和错误降级
- 在编码产出后自动接入 `.harness/bin/harness-check.sh` → `harness-fix.sh` → 再检查 的纠偏闭环
- V3 第一阶段已提供 `skills/runtime/bin/workflow.sh` 运行时骨架，用于落盘状态、恢复与审批命令

## 工作流模式

### 三省六部模式（imperial）

```
用户需求
  ↓
太子分拣 → 闲聊直接回复（退出流程）
  ↓ 正式旨意
中书省接旨 → 调用 PM + Architect 规划
  ↓
门下省审核（阶段1+2）
  ├→ 封驳 → 回中书省修改（max 3轮）
  ↓ 准奏
尚书省派发 → 六部执行
  ↓
门下省代码审核（阶段3）
  ├→ 封驳 → 回尚书省重派（max 3轮）
  ↓ 准奏
中书省回奏
  ↓
皇上御览 → git commit
```

### 敏捷模式（agile）

```
用户需求
  ↓
Scrum Master 分析 → 任务拆解
  ↓
PM + Architect 并行规划
  ↓
Dev + DevOps 并行执行
  ↓
Code Review
  ↓
提交
```

## 核心机制

### 1. 状态管理

所有流程状态记录在 `.cache/shared/workflow-state.json`：

```json
{
  "workflow_id": "uuid",
  "mode": "imperial",
  "user_request": "原始需求",
  "started_at": "ISO时间",
  "current_step": "zhongshu-plan",
  "status": "running",
  "steps": [
    {
      "step": "taizi-triage",
      "skill": "0-taizi",
      "status": "completed",
      "started_at": "ISO时间",
      "completed_at": "ISO时间",
      "rejection_count": 0,
      "outputs": [],
      "message": "正式旨意，传旨中书省"
    }
  ],
  "shared_documents": {
    "requirements": ".cache/shared/requirements/feature.md",
    "architecture": ".cache/shared/architecture/feature.md",
    "api_design": ".cache/shared/api-design/feature-api.md"
  },
  "harness": {
    "project_profile": ".harness/project-profile.json",
    "contract": ".harness/architecture/contract.yaml",
    "last_report": ".harness/state/last-report.json"
  }
}
```

### 2. Agent 派发模板

每个步骤通过 Agent 工具派发子进程：

```
使用 Agent 工具，prompt 包含：
1. 对应技能的 SKILL.md 路径（让 Agent 读取并遵循）
2. 当前任务上下文（用户需求、前序步骤产出）
3. 共享文档路径
4. 要求输出 workflow_signal JSON
```

**派发 prompt 模板：**

```
你是 {技能名}。请读取并严格遵循 skills/{skill-id}/SKILL.md 中的规范。

## 任务上下文
- 用户需求：{user_request}
- 前序产出：{previous_outputs}
- 共享文档：{shared_document_paths}

## 你的任务
{step_specific_instruction}

## 完成后
在输出末尾附加 workflow_signal JSON（见 SKILL.md 自动编排接口）。
```

### 3. 封驳循环处理

```
封驳计数 = 0
LOOP:
  提交门下省审核
  IF 准奏 → 继续下一步
  IF 封驳:
    封驳计数 += 1
    IF 封驳计数 >= 3:
      强制通过，记录风险到 workflow-state
      继续下一步
    ELSE:
      将封驳意见传回（中书省 or 尚书省）
      修改后 → GOTO LOOP
```

### 4. 错误降级

```
错误计数 = 0
执行步骤:
  IF 成功 → 继续
  IF 失败:
    错误计数 += 1
    IF 错误计数 >= 3:
      记录错误到 workflow-state
      通知用户，询问是否：
        a) 跳过此步骤继续
        b) 手动处理后恢复
        c) 终止流程
    ELSE:
      换思路重试
```

### 5. Harness 纠偏循环

执行类步骤结束后，编排器必须自动触发 Harness 检查：

```
编码产出完成
  ↓
运行 sh .harness/bin/harness-check.sh --changed-files --json
  ↓
IF exit=0:
  继续门下省代码审核
IF exit=2:
  运行 sh .harness/bin/harness-fix.sh --changed-files
  再次运行 harness-check
  最多 3 轮
IF exit=3 或 3轮后仍失败:
  记录漂移报告到 workflow-state
  提交门下省封驳
IF exit=4:
  视为仓库未完成 Harness 初始化，停止流程并提示先执行 setup.sh --project-root=...
```

要求：
- 编排器只把 Harness 当作门禁和反馈信号，不替代具体业务技能。
- 每轮纠偏都基于磁盘事实源重读 `.harness/` 和改动文件，避免长上下文累积漂移。
- 不允许用 `[skip-review]` 类文本旁路替代 Harness 门禁。

### 6. 中断恢复

编排器启动时检查 `.cache/shared/workflow-state.json`：
- 如果存在且 `status=running`，提示用户是否恢复
- 恢复时从 `current_step` 继续，跳过已完成步骤
- 用户也可选择放弃旧流程，开始新流程

## 执行流程（三省六部模式详解）

### Step 1: 太子分拣

```
Agent 派发 → 0-taizi
输入：用户原始需求
判断：
  - 闲聊 → 直接回复，workflow 结束
  - 简单任务 → 建议敏捷模式，workflow 结束或切换
  - 正式旨意 → 继续 Step 2
```

### Step 2: 中书省规划

```
Agent 派发 → 0-zhongshu-province
输入：太子整理后的旨意
执行：调用 PM + Architect 产出文档
输出：需求文档 + 架构设计路径
```

### Step 3: 门下省审核（阶段1+2）

```
Agent 派发 → 0-menxia-province
输入：中书省产出的文档路径
审核：需求 + 架构
结果：准奏 → Step 4 | 封驳 → 回 Step 2（max 3轮）
```

### Step 4: 尚书省派发执行

```
Agent 派发 → 0-shangshu-province
输入：准奏后的文档路径
执行：派发六部（后端/前端/DevOps/测试）
输出：执行结果 + 修改文件列表
随后：自动进入 Harness 检查/修复循环
```

### Step 5: 门下省代码审核（阶段3）

```
Agent 派发 → 0-menxia-province
输入：尚书省汇总的执行结果 + Harness 检查报告
审核：代码质量
结果：准奏 → Step 6 | 封驳 → 回 Step 4（max 3轮）
```

### Step 6: 中书省回奏

```
Agent 派发 → 0-zhongshu-province
输入：全流程产出物
执行：汇总最终报告
输出：回奏报告
```

### Step 7: 皇上御览

```
将回奏报告展示给用户
等待用户确认：
  - 满意 → git commit ✅[Reviewed]
  - 不满意 → 记录意见，回 Step 2
```

## 进度展示

每个步骤执行时实时展示进度：

```markdown
## 🔄 工作流进度

**需求：** {user_request}
**模式：** 三省六部

| # | 步骤 | 状态 | 耗时 |
|---|------|------|------|
| 1 | 🤴 太子分拣 | ✅ 完成 | 3s |
| 2 | 📜 中书省规划 | ✅ 完成 | 45s |
| 3 | 🔍 门下省审核 | 🔄 进行中... | - |
| 4 | 📮 尚书省派发 | ⏳ 等待 | - |
| 5 | 🔍 门下省代码审核 | ⏳ 等待 | - |
| 6 | 📜 中书省回奏 | ⏳ 等待 | - |
| 7 | 👑 皇上御览 | ⏳ 等待 | - |
```

## 质量标准

- 每步必须等待 workflow_signal 确认后才进入下一步
- 封驳循环严格遵守 max 3 次限制
- 所有状态变更必须写入 workflow-state.json
- 错误降级必须通知用户，不可静默跳过
- 中断恢复必须让用户确认，不可自动恢复

## 协作模式

### 可调用的技能（编排器特权）

| 技能 | 调用时机 | 模式 |
|---|---|---|
| `0-taizi` | 消息分拣 | imperial |
| `0-zhongshu-province` | 规划/回奏 | imperial |
| `0-menxia-province` | 审核 | imperial |
| `0-shangshu-province` | 派发执行 | imperial |
| `0-scrum-master` | 敏捷协调 | agile |
| 所有六部技能 | 通过尚书省间接调用 | both |

## 资源文件

### references/
- **orchestration-guide.md** - 编排详细规则、状态机定义、错误处理策略
