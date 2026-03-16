# 工作流编排详细规则

## 状态机定义

### 流程状态

| 状态 | 说明 |
|---|---|
| `idle` | 无活跃流程 |
| `running` | 流程执行中 |
| `paused` | 用户暂停或等待确认 |
| `completed` | 流程正常完成 |
| `aborted` | 用户终止或致命错误 |

### 步骤状态

| 状态 | 说明 |
|---|---|
| `pending` | 等待执行 |
| `in_progress` | 正在执行 |
| `completed` | 执行完成 |
| `rejected` | 被门下省封驳 |
| `error` | 执行出错 |
| `skipped` | 用户选择跳过 |
| `force_passed` | 达到封驳上限，强制通过 |

## 三省六部模式状态机

```
[start] → taizi-triage
  ├→ chat → [end] (闲聊直接回复)
  ├→ simple → [end] (建议敏捷模式)
  └→ edict → zhongshu-plan

zhongshu-plan → menxia-review-plan
  ├→ approved → shangshu-dispatch
  ├→ rejected (count < 3) → zhongshu-plan
  └→ rejected (count >= 3) → shangshu-dispatch [force_passed]

shangshu-dispatch → menxia-review-code
  ├→ approved → zhongshu-report
  ├→ rejected (count < 3) → shangshu-dispatch
  └→ rejected (count >= 3) → zhongshu-report [force_passed]

zhongshu-report → emperor-review
  ├→ approved → [commit + end]
  └→ rejected → zhongshu-plan (重新规划)
```

## 敏捷模式状态机

```
[start] → scrum-analyze
scrum-analyze → scrum-plan (PM + Architect 并行)
scrum-plan → scrum-execute (Dev 并行执行)
scrum-execute → scrum-review (Code Review)
scrum-review
  ├→ approved → [commit + end]
  └→ rejected → scrum-execute (修改后重审)
```

## Agent 调用规范

### 调用模板

每次通过 Agent 工具派发时，prompt 必须包含以下结构：

```markdown
你是 {角色名}。请读取 skills/{skill-id}/SKILL.md 并严格遵循其中的规范执行任务。

## 当前工作流
- workflow_id: {id}
- 模式: {imperial/agile}
- 当前步骤: {step_name}

## 用户需求
{user_request}

## 前序产出
{列出前面步骤的产出文件路径和关键结论}

## 共享文档
{列出 .cache/shared/ 下的相关文档路径}

## 你的任务
{具体任务描述}

## 输出要求
1. 按 SKILL.md 规范执行并输出
2. 产出物保存到 .cache/shared/ 对应目录
3. 在输出末尾附加 workflow_signal JSON：

\`\`\`json
{
  "workflow_signal": {
    "skill": "{skill-id}",
    "status": "completed|rejected|error",
    "outputs": ["文件路径列表"],
    "rejection_reason": "封驳原因（仅 rejected 时）",
    "message": "简要说明"
  }
}
\`\`\`
```

### 解析 workflow_signal

Agent 返回后，编排器从输出末尾提取 `workflow_signal` JSON：

1. 查找输出中最后一个 `{"workflow_signal":` 开头的 JSON 块
2. 解析 status 字段决定下一步
3. 将 outputs 记录到 workflow-state.json
4. status=error 时进入错误处理流程

### 信号缺失处理

如果 Agent 输出中没有 workflow_signal：
- 检查输出是否包含明确的完成/失败标志
- 如果输出看起来正常完成，视为 `status: completed`
- 如果输出包含错误信息，视为 `status: error`
- 记录警告到 workflow-state.json

## 错误处理策略

### 三级错误处理

**Level 1: 自动重试**
- Agent 超时或返回空结果
- 重试同一步骤，最多 2 次
- 每次重试在 prompt 中说明"上次执行未成功，请重试"

**Level 2: 换思路重试**
- 同一步骤连续失败 3 次
- 在 prompt 中加入"前几次尝试均失败，请换一种方式"
- 如果是编码任务，提示使用不同的实现策略

**Level 3: 用户介入**
- 换思路后仍然失败
- 暂停流程，向用户展示错误信息
- 提供选项：
  a) 手动处理后输入"继续"恢复流程
  b) 跳过此步骤（记录风险）
  c) 终止流程

### 错误记录

每次错误都记录到 workflow-state.json 的步骤中：

```json
{
  "step": "shangshu-dispatch",
  "status": "error",
  "error_count": 2,
  "errors": [
    { "attempt": 1, "message": "Agent 超时", "timestamp": "..." },
    { "attempt": 2, "message": "编译错误", "timestamp": "..." }
  ]
}
```

## 中断恢复逻辑

### 检测中断

编排器启动时：

```
1. 检查 .cache/shared/workflow-state.json 是否存在
2. 如果存在且 status=running：
   - 展示上次流程信息（需求、进度、中断点）
   - 询问用户：
     a) 恢复流程（从中断点继续）
     b) 放弃旧流程，开始新流程
     c) 查看详情后再决定
3. 如果不存在或 status=completed/aborted：
   - 正常开始新流程
```

### 恢复执行

恢复时：
1. 读取 workflow-state.json
2. 找到 `current_step`
3. 检查该步骤状态：
   - `in_progress` → 重新执行该步骤
   - `rejected` → 重新执行（带上封驳意见）
   - `error` → 重新执行（带上错误信息）
4. 跳过所有 `completed` 的步骤
5. 恢复 shared_documents 路径

## 并发控制

### 同一时间只允许一个工作流

- 启动新流程前检查是否有活跃流程
- 如果有，必须先完成/终止旧流程
- 防止多个流程同时修改同一文件

### 步骤内并行

某些步骤内部可以并行：
- 中书省规划：PM 和 Architect 可并行
- 尚书省派发：无依赖的六部可并行
- 并行由对应技能自行管理，编排器只关心步骤级别的串行

## workflow-state.json 完整示例

```json
{
  "workflow_id": "wf-20240101-abc123",
  "mode": "imperial",
  "user_request": "开发用户登录功能，要求 JWT 鉴权",
  "started_at": "2024-01-01T10:00:00Z",
  "current_step": "menxia-review-plan",
  "status": "running",
  "steps": [
    {
      "step": "taizi-triage",
      "skill": "0-taizi",
      "status": "completed",
      "started_at": "2024-01-01T10:00:00Z",
      "completed_at": "2024-01-01T10:00:03Z",
      "rejection_count": 0,
      "outputs": [],
      "message": "正式旨意：开发用户登录功能"
    },
    {
      "step": "zhongshu-plan",
      "skill": "0-zhongshu-province",
      "status": "completed",
      "started_at": "2024-01-01T10:00:03Z",
      "completed_at": "2024-01-01T10:01:00Z",
      "rejection_count": 0,
      "outputs": [
        ".cache/shared/requirements/user-login.md",
        ".cache/shared/architecture/user-login.md",
        ".cache/shared/api-design/user-login-api.md"
      ],
      "message": "规划完成，提交门下省审核"
    },
    {
      "step": "menxia-review-plan",
      "skill": "0-menxia-province",
      "status": "in_progress",
      "started_at": "2024-01-01T10:01:00Z",
      "rejection_count": 0,
      "outputs": [],
      "message": ""
    }
  ],
  "shared_documents": {
    "edict": ".cache/shared/edicts/user-login.md",
    "requirements": ".cache/shared/requirements/user-login.md",
    "architecture": ".cache/shared/architecture/user-login.md",
    "api_design": ".cache/shared/api-design/user-login-api.md"
  },
  "errors": [],
  "force_passed_steps": []
}
```
