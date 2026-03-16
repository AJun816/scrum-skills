# 全自动化工作流程详解

## 概述

Scrum Master 协调两层架构完成全自动化敏捷开发：

```
决策层  Claude Code 主进程（Scrum Master）
           ↓ 任务拆解 + 依赖设置
执行层  Agent 子进程（所有角色，使用 Claude Code Edit/Write 工具执行编码任务）
           ↓ 文档产出到 .cache/shared/，代码直接修改项目文件
```

**关键原则：**
- 文档型任务（需求/架构/设计/测试报告）→ **Agent 子进程**执行
- 编码型任务（后端/前端/DevOps脚本/Bug修复）→ **Agent 子进程**执行（使用 Claude Code Edit/Write 工具）
- 无依赖任务 → **并行**执行
- 有依赖任务 → **顺序**执行（等上游文档产出后再触发）

---

## 第1步：任务接收和分析

**输出给用户：**
```markdown
## 👋 我是 Scrum Master
**角色：** 敏捷教练
**职责：** 组织敏捷流程，协调团队，移除障碍

## 🔍 分析任务

**用户任务：** {用户输入}
```

**执行工具调用：**
```javascript
// 1. 读取项目配置
Read({ file_path: "PROJECT_CONFIG.md" })
```

**输出给用户：**
```markdown
### 读取项目配置
✅ 项目：{项目名称}
✅ 技术栈：{技术栈}
✅ 业务域：{业务域列表}

### 任务类型识别
**识别结果：**
- 任务类型：新功能开发
- 涉及业务域：{domain1}, {domain2}
- 复杂度：中等
- 执行策略：Agent并行规划 → Agent并行编码
```

---

## 第2步：创建任务列表 + 设置依赖

```javascript
// 创建文档型任务（Agent执行）
T1 = TaskCreate({ subject: "需求分析", activeForm: "分析需求中" })
T2 = TaskCreate({ subject: "编写用户故事", activeForm: "编写用户故事中" })
T3 = TaskCreate({ subject: "架构设计", activeForm: "设计架构中" })

// 创建编码型任务（Agent 子进程执行）
T4 = TaskCreate({ subject: "后端开发", activeForm: "编写后端中" })
T5 = TaskCreate({ subject: "前端开发", activeForm: "编写前端中" })

// 创建验收型任务（Agent执行）
T6 = TaskCreate({ subject: "UI审核", activeForm: "审核UI中" })
T7 = TaskCreate({ subject: "功能测试", activeForm: "测试中" })

// 设置依赖关系（顺序约束）
TaskUpdate({ taskId: T2, addBlockedBy: [T1] })     // 故事依赖需求
TaskUpdate({ taskId: T3, addBlockedBy: [T2] })     // 架构依赖故事
TaskUpdate({ taskId: T4, addBlockedBy: [T3] })     // 后端依赖架构
TaskUpdate({ taskId: T5, addBlockedBy: [T3] })     // 前端依赖架构（T4/T5可并行）
TaskUpdate({ taskId: T6, addBlockedBy: [T5] })     // UI审核依赖前端
TaskUpdate({ taskId: T7, addBlockedBy: [T4, T6] }) // 测试依赖后端+UI审核
```

**依赖关系图：**
```
T1(需求) → T2(故事) → T3(架构) → T4(后端) ─────┐
                                 ↘ T5(前端) → T6(UI审核) → T7(测试)
```

---

## 第3步：规划层 — Agent 并行执行文档任务

**T1/T2 分配给 Agent（产品经理），并行或串行按依赖执行：**

```javascript
// Scrum Master 直接以 product-manager 角色执行，或启动 Agent 子进程
// 产出保存到：.cache/shared/requirements/{feature}.md

TaskUpdate({ taskId: T1, owner: "product-manager", status: "in_progress" })
// → 执行 /2-product-manager 技能，产出需求文档
// → 文档保存到 .cache/shared/requirements/{feature}.md
// → TaskUpdate({ taskId: T1, status: "completed" })

TaskUpdate({ taskId: T2, owner: "product-manager", status: "in_progress" })
// → 产出用户故事文档
// → 文档保存到 .cache/shared/requirements/{feature}-stories.md
// → TaskUpdate({ taskId: T2, status: "completed" })

// T3: 架构师（等 T2 完成后触发）
TaskUpdate({ taskId: T3, owner: "system-architect", status: "in_progress" })
// → 执行 /3-system-architect 技能
// → 读取需求文档，产出架构设计 + API 契约
// → 保存到 .cache/shared/architecture/{feature}.md
// → 保存到 .cache/shared/api-design/{feature}-api.md
// → TaskUpdate({ taskId: T3, status: "completed" })
```

**输出给用户：**
```markdown
## 📋 规划层执行（Agent）

✅ T1 需求分析完成 → .cache/shared/requirements/{feature}.md
✅ T2 用户故事完成 → .cache/shared/requirements/{feature}-stories.md
✅ T3 架构设计完成 → .cache/shared/architecture/{feature}.md
                   → .cache/shared/api-design/{feature}-api.md

规划文档就绪，启动编码执行层...
```

---

## 第4步：执行层 — Agent 子进程并行编码

**T4（后端）和 T5（前端）可并行，均由 Agent 子进程使用 Claude Code Edit/Write 工具执行：**

**后端任务：**
```markdown
## 💻 后端任务（T4）

### 执行编码
Agent 子进程读取共享架构文档，使用 Claude Code Edit/Write 工具实现后端代码：
- Controller + DTO（接口层）
- ApplicationService（应用层）
- Domain Model / DomainService（领域层）
- Repository 实现（基础设施层）

约束：单文件≤800行，方法≤50行，构造器注入，统一响应结构

执行完成后进行代码审查和 git commit。
```

**前端任务：**
```markdown
## 🎨 前端任务（T5）

### 执行编码
Agent 子进程读取共享 API 文档，使用 Claude Code Edit/Write 工具实现前端代码：
- api层 → store层 → composable → component → view → router

约束：单文件≤800行，loading状态，统一UI组件库

执行完成后进行代码审查和 git commit。
```

```javascript
TaskUpdate({ taskId: T4, owner: "backend-dev", status: "in_progress" })
TaskUpdate({ taskId: T5, owner: "frontend-dev", status: "in_progress" })
// 执行完成后，更新状态
TaskUpdate({ taskId: T4, status: "completed" })
TaskUpdate({ taskId: T5, status: "completed" })
```

**输出给用户：**
```markdown
## ⚙️ 执行层（Agent 子进程并行）

🔄 backend-dev: 实现后端 Controller/Service/Domain/Repository...
🔄 frontend-dev: 实现前端 API/Store/Component/View...

（并行执行中，等待完成...）

✅ backend-dev 完成 → 后端代码已生成
✅ frontend-dev 完成 → 前端代码已生成
```

---

## 第5步：验收层 — Agent 审核 + 测试

**T6 UI审核（Agent执行）：**
```javascript
TaskUpdate({ taskId: T6, owner: "ui-reviewer", status: "in_progress" })
// → 执行 /4-nielsen-ui-design 或 /4-frontend-design 审核
// → 读取前端代码，产出 UI 审核报告
// → 保存到 .cache/shared/ui-review/{feature}-ui-review.md
// → TaskUpdate({ taskId: T6, status: "completed" })
```

**T7 功能测试（Agent执行）：**
```javascript
TaskUpdate({ taskId: T7, owner: "tester", status: "in_progress" })
// → 执行 /5-webapp-testing 技能
// → 执行测试用例（Playwright 或 API 测试）
// → 产出测试报告
// → 保存到 .cache/shared/test-reports/{feature}-test-report.md
// → TaskUpdate({ taskId: T7, status: "completed" })
```

---

## 第6步：代码审查 + git commit

**由 Scrum Master 协调代码审查，审查通过后统一 commit：**

```javascript
// 调用 8-code-reviewer 审查代码
// /8-code-reviewer 审查 git diff（未提交变更）

// 审查通过后，Scrum Master 统一执行 git commit
Bash({
  command: `git add . && git commit -m "feat: 实现 {feature} 功能

  - 后端：Controller/Service/Domain/Repository
  - 前端：API/Store/Component/View"`
})
```

---

## 第7步：交付总结

```markdown
## ✅ 任务完成

### 交付内容
- ✅ 需求文档：.cache/shared/requirements/{feature}.md
- ✅ 架构设计：.cache/shared/architecture/{feature}.md
- ✅ API 契约：.cache/shared/api-design/{feature}-api.md
- ✅ 后端代码：{后端文件列表}
- ✅ 前端代码：{前端文件列表}
- ✅ UI 审核报告：.cache/shared/ui-review/{feature}-ui-review.md
- ✅ 测试报告：.cache/shared/test-reports/{feature}-test-report.md

### 执行统计
- 规划层（Agent）：产出 4 份共享文档
- 执行层（Agent 子进程）：并行修改 {N} 个代码文件
- 验收层（Agent）：UI审核通过，测试通过率 {X}%

🎉 任务完成！
```

---

## 任务类型路由规则

### 1. 新功能开发
**流程：** Agent规划（需求/故事/架构）→ Agent子进程并行编码（后端+前端）→ Agent验收（测试）

### 2. Bug修复
**流程：** Agent分析（6-bug-handler定位根因）→ Agent子进程修复（最小变更）→ Agent回归测试

```markdown
## 💻 Bug修复

Agent 子进程读取问题相关代码文件，使用 Claude Code Edit/Write 工具修复 Bug：
- 修复描述：{描述}
- 根本原因：{原因}
- 最小变更原则，添加单元测试

执行完成后进行代码审查和 git commit。
```

### 3. 架构优化/重构
**流程：** Agent分析（3-system-architect设计方案）→ Agent子进程重构 → Agent性能测试

```markdown
## 💻 重构任务

Agent 子进程读取新架构方案文档，使用 Claude Code Edit/Write 工具按新架构方案重构：
- 保持接口兼容性
- 逐文件重构

执行完成后进行代码审查和 git commit。
```

### 4. 需求变更
**流程：** Agent影响分析（2-product-manager+3-system-architect）→ Agent子进程变更实现 → Agent回归测试

---

## 错误处理和降级

### 编码任务执行失败
```
Agent 子进程失败 1次 → 调整任务指令，优化任务描述后重试
Agent 子进程失败 2次 → 缩小目标文件范围，拆分任务后重试
Agent 子进程失败 3次 → Scrum Master 直接使用 Claude Code Edit 工具
                  → 必须通过 SendMessage 向用户报告原因
```

### Agent 子进程超时
```
Agent 超时 → 检查 TaskList 任务状态
           → 重新发送任务描述（SendMessage）
           → 若持续无响应，Scrum Master 直接接管执行
```

### 并行冲突
```
后端/前端 Agent 子进程同时修改同一文件 → 必须顺序执行
Scrum Master 在启动并行前检查目标文件列表，确认无重叠
```

---

## 最佳实践

1. **共享文档优先** — 规划层产出文档后，执行层 Agent 子进程读取共享文档，不在任务指令中重复描述
2. **最小目标文件** — 每次编码任务明确指定文件列表，不传入整个目录
3. **并行最大化** — 无文件冲突的任务尽量并行（后端/前端/配置可并行）
4. **统一 git 管理** — 由 Scrum Master 统一 commit
5. **审查先于提交** — 编码完成后，先触发 8-code-reviewer 审查，通过后再 commit
