# 派发规则

**尚书省派发任务到六部的路由规则和策略。**

---

## 任务路由表

| 任务类型 | 关键词 | 派发目标 | 执行方式 |
|---|---|---|---|
| 后端 API 开发 | API、接口、后端、数据库、模型 | `/4-backend-dev` | aider |
| 前端页面开发 | 页面、组件、前端、UI实现 | `/4-frontend-dev` | aider |
| UI 设计 | 设计稿、原型、交互设计 | `/4-frontend-design` | Agent |
| UI 可用性审核 | 可用性、Nielsen、用户体验 | `/4-nielsen-ui-design` | Agent |
| DevOps 脚本 | CI/CD、Docker、部署、脚本 | `/5-devops-engineer` | aider |
| 自动化测试 | 测试、E2E、单元测试 | `/5-webapp-testing` | Agent |

## 并行策略

### 可并行的组合

- 后端 + 前端（无 API 依赖时）
- 后端 + DevOps
- UI 设计 + 后端
- 多个独立模块的后端开发

### 必须串行的组合

- 前端依赖后端 API → 后端先完成
- 测试依赖开发完成 → 开发先完成
- UI 实现依赖 UI 设计 → 设计先完成

## aider 调用模板

### 单任务派发

```bash
PYTHONIOENCODING=utf-8 \
ANTHROPIC_API_KEY="$ANTHROPIC_AUTH_TOKEN" \
ANTHROPIC_API_BASE="${ANTHROPIC_BASE_URL%/}" \
aider \
  --model anthropic/claude-sonnet-4-6 \
  --architect \
  --yes-always \
  --no-git \
  --no-show-model-warnings \
  --read .cache/shared/requirements/{feature}.md \
  --read .cache/shared/architecture/{feature}.md \
  --read .cache/shared/api-design/{feature}-api.md \
  --message "{尚书省派发的具体任务指令}。约束：单文件≤800行，方法≤50行" \
  {target_files}
```

### 并行派发

```bash
# 后端（后台）
aider ... --message "实现后端 {功能}" {后端文件} &
BACKEND_PID=$!

# 前端（后台）
aider ... --message "实现前端 {功能}" {前端文件} &
FRONTEND_PID=$!

wait $BACKEND_PID $FRONTEND_PID
```

## 文件冲突预防

- 派发前检查各任务的目标文件是否有重叠
- 有重叠时改为串行执行
- 维护文件锁定表，防止并发写入同一文件

## 异常处理

| 异常 | 处理方式 |
|---|---|
| aider 执行失败 | 重试 1 次，仍失败则降级为 Claude Code Edit/Write |
| 六部执行超时 | 记录超时原因，向中书省报告 |
| 文件冲突 | 改为串行执行，手动合并 |
| 依赖未满足 | 等待上游任务完成后再派发 |
