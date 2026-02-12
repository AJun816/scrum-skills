# 自动化工具调用实现指南

本文档详细说明如何使用真实的工具调用实现全自动化敏捷开发流程。

## 概述

Scrum Master使用以下工具实现自动化：
- `TaskCreate` - 创建任务
- `TaskUpdate` - 更新任务状态、设置依赖、分配负责人
- `TaskList` - 查看任务列表
- `TaskGet` - 获取任务详情
- `SendMessage` - 发送消息给团队成员
- `Read` - 读取文件

## 完整实现示例

### 步骤1：分析任务并读取配置

```javascript
// 读取项目配置
const projectConfig = await Read({
  file_path: "D:\\github\\code\\scrum-skills\\PROJECT_CONFIG.md"
})

// 分析任务类型
function analyzeTaskType(userInput) {
  const keywords = {
    feature: ['开发', '实现', '添加', '新增', '创建'],
    bug: ['修复', 'bug', '问题', '错误', 'fix'],
    optimization: ['优化', '重构', '性能', '架构', '改进'],
    change: ['修改', '变更', '调整', '更新']
  }

  for (const [type, words] of Object.entries(keywords)) {
    if (words.some(word => userInput.toLowerCase().includes(word))) {
      return type
    }
  }

  return 'feature' // 默认为新功能开发
}

const taskType = analyzeTaskType(userInput)
```

### 步骤2：创建任务列表

根据任务类型创建不同的任务流程。

#### 新功能开发流程

```javascript
// 创建任务1：需求分析
const task1 = await TaskCreate({
  subject: "需求分析",
  description: `分析用户需求：${userInput}

**要求：**
1. 理解业务目标和用户价值
2. 识别功能范围和边界
3. 明确验收标准
4. 识别技术风险和依赖
5. 输出需求文档到 requirements/ 目录

**输出文件：**
- requirements/{feature-name}.md`,
  activeForm: "分析需求中"
})

// 创建任务2：编写用户故事
const task2 = await TaskCreate({
  subject: "编写用户故事",
  description: `基于需求分析结果，编写用户故事

**要求：**
1. 使用标准格式（As a... I want... So that...）
2. 定义明确的验收标准（Given-When-Then）
3. 估算故事点
4. 拆分为可独立交付的小故事
5. 输出用户故事文档

**输出文件：**
- requirements/{feature-name}-stories.md`,
  activeForm: "编写用户故事中"
})

// 创建任务3：架构设计
const task3 = await TaskCreate({
  subject: "架构设计",
  description: `设计技术架构和实现方案

**要求：**
1. 设计系统架构（分层、模块划分）
2. 定义API接口（RESTful/GraphQL）
3. 设计数据模型（实体、关系）
4. 选择技术方案（框架、库）
5. 识别技术风险和应对措施
6. 输出架构设计文档和API文档

**输出文件：**
- architecture/{feature-name}.md
- api-design/{feature-name}-api.md`,
  activeForm: "设计架构中"
})

// 创建任务4：后端开发
const task4 = await TaskCreate({
  subject: "后端开发",
  description: `实现后端功能

**要求：**
1. 实现API接口（按照API设计文档）
2. 实现业务逻辑（按照架构设计）
3. 实现数据访问层
4. 编写单元测试（覆盖率>80%）
5. 更新API文档
6. 代码符合编码规范

**参考文档：**
- architecture/{feature-name}.md
- api-design/{feature-name}-api.md`,
  activeForm: "开发后端中"
})

// 创建任务5：前端开发
const task5 = await TaskCreate({
  subject: "前端开发",
  description: `实现前端功能

**要求：**
1. 实现页面和组件（按照UI设计）
2. 对接后端API
3. 实现交互逻辑和状态管理
4. 实现表单验证和错误处理
5. 编写组件测试
6. 确保响应式布局和浏览器兼容性

**参考文档：**
- api-design/{feature-name}-api.md`,
  activeForm: "开发前端中"
})

// 创建任务6：UI审核
const task6 = await TaskCreate({
  subject: "UI设计审核",
  description: `审核前端UI实现

**要求：**
1. 检查设计一致性（颜色、字体、间距）
2. 验证交互体验（流畅性、反馈）
3. 检查响应式布局（移动端、平板、桌面）
4. 检查可访问性（WCAG标准）
5. 输出UI审核报告

**输出文件：**
- ui-review/{feature-name}-ui-review.md`,
  activeForm: "审核UI中"
})

// 创建任务7：功能测试
const task7 = await TaskCreate({
  subject: "功能测试",
  description: `执行功能测试

**要求：**
1. 编写测试用例（基于用户故事）
2. 执行功能测试（正常流程、异常流程）
3. 执行集成测试（前后端联调）
4. 执行回归测试（确保无副作用）
5. 记录测试结果和缺陷
6. 输出测试报告

**输出文件：**
- test-reports/{feature-name}-test-report.md`,
  activeForm: "测试中"
})
```

#### Bug修复流程

```javascript
// 创建任务1：Bug分析
const task1 = await TaskCreate({
  subject: "Bug分析",
  description: `分析Bug原因：${userInput}

**要求：**
1. 复现Bug
2. 定位根本原因
3. 评估影响范围
4. 输出Bug分析报告`,
  activeForm: "分析Bug中"
})

// 创建任务2：修复方案设计
const task2 = await TaskCreate({
  subject: "修复方案设计",
  description: `设计Bug修复方案

**要求：**
1. 设计修复方案
2. 评估修复风险
3. 输出修复方案文档`,
  activeForm: "设计修复方案中"
})

// 创建任务3：Bug修复实现
const task3 = await TaskCreate({
  subject: "Bug修复实现",
  description: `实现Bug修复

**要求：**
1. 修复代码
2. 编写单元测试
3. 验证修复效果`,
  activeForm: "修复Bug中"
})

// 创建任务4：回归测试
const task4 = await TaskCreate({
  subject: "回归测试",
  description: `执行回归测试

**要求：**
1. 验证Bug已修复
2. 执行回归测试
3. 输出测试报告`,
  activeForm: "回归测试中"
})
```

### 步骤3：设置任务依赖关系

```javascript
// 获取所有任务
const tasks = await TaskList()

// 对于新功能开发流程，设置依赖关系
// task2 依赖 task1
await TaskUpdate({
  taskId: task2.id,
  addBlockedBy: [task1.id]
})

// task3 依赖 task2
await TaskUpdate({
  taskId: task3.id,
  addBlockedBy: [task2.id]
})

// task4 依赖 task3
await TaskUpdate({
  taskId: task4.id,
  addBlockedBy: [task3.id]
})

// task5 依赖 task3（可以与task4并行）
await TaskUpdate({
  taskId: task5.id,
  addBlockedBy: [task3.id]
})

// task6 依赖 task5
await TaskUpdate({
  taskId: task6.id,
  addBlockedBy: [task5.id]
})

// task7 依赖 task4 和 task6
await TaskUpdate({
  taskId: task7.id,
  addBlockedBy: [task4.id, task6.id]
})
```

### 步骤4：分配任务给团队成员

```javascript
// 分配任务1和2给产品经理
await TaskUpdate({
  taskId: task1.id,
  owner: "product-manager"
})

await TaskUpdate({
  taskId: task2.id,
  owner: "product-manager"
})

// 分配任务3给系统架构师
await TaskUpdate({
  taskId: task3.id,
  owner: "system-architect"
})

// 分配任务4给后端开发
await TaskUpdate({
  taskId: task4.id,
  owner: "backend-developer"
})

// 分配任务5给前端开发
await TaskUpdate({
  taskId: task5.id,
  owner: "frontend-developer"
})

// 分配任务6给UI设计师
await TaskUpdate({
  taskId: task6.id,
  owner: "ui-designer"
})

// 分配任务7给测试工程师
await TaskUpdate({
  taskId: task7.id,
  owner: "tester"
})
```

### 步骤5：通知团队成员开始工作

```javascript
// 通知产品经理
await SendMessage({
  type: "message",
  recipient: "product-manager",
  content: `你好！我是Scrum Master。

我已经为你分配了2个任务：
- Task #${task1.id}: 需求分析
- Task #${task2.id}: 编写用户故事

请先完成Task #${task1.id}，然后再进行Task #${task2.id}。

**用户需求：**
${userInput}

**项目信息：**
- 项目名称：${projectConfig.name}
- 技术栈：${projectConfig.techStack}
- 业务域：${projectConfig.domains}

请开始工作吧！完成后请使用 TaskUpdate 标记任务为 completed。`,
  summary: "任务分配：需求分析和用户故事"
})

// 其他团队成员会在他们的前置任务完成后自动收到通知
```

### 步骤6：监控进度

```javascript
// 定期检查任务进度
async function monitorProgress() {
  const tasks = await TaskList()

  const pending = tasks.filter(t => t.status === 'pending')
  const inProgress = tasks.filter(t => t.status === 'in_progress')
  const completed = tasks.filter(t => t.status === 'completed')

  console.log(`
## 📊 团队进度

**总任务数：** ${tasks.length}
**已完成：** ${completed.length} (${Math.round(completed.length / tasks.length * 100)}%)
**进行中：** ${inProgress.length} (${Math.round(inProgress.length / tasks.length * 100)}%)
**待处理：** ${pending.length} (${Math.round(pending.length / tasks.length * 100)}%)

**进行中的任务：**
${inProgress.map(t => `- Task #${t.id}: ${t.subject} (${t.owner})`).join('\n')}

**阻塞的任务：**
${pending.filter(t => t.blockedBy && t.blockedBy.length > 0).map(t =>
  `- Task #${t.id}: ${t.subject} (等待 ${t.blockedBy.join(', ')} 完成)`
).join('\n')}
  `)
}

// 每30秒检查一次进度
setInterval(monitorProgress, 30000)
```

### 步骤7：处理任务完成通知

```javascript
// 当收到团队成员完成任务的通知时
async function handleTaskCompleted(taskId) {
  // 获取任务详情
  const task = await TaskGet({ taskId })

  // 检查是否有被阻塞的任务
  const allTasks = await TaskList()
  const unblockedTasks = allTasks.filter(t =>
    t.blockedBy && t.blockedBy.includes(taskId)
  )

  // 通知下一个任务的负责人
  for (const nextTask of unblockedTasks) {
    // 检查该任务的所有依赖是否都已完成
    const allDependenciesCompleted = nextTask.blockedBy.every(depId => {
      const depTask = allTasks.find(t => t.id === depId)
      return depTask && depTask.status === 'completed'
    })

    if (allDependenciesCompleted && nextTask.owner) {
      await SendMessage({
        type: "message",
        recipient: nextTask.owner,
        content: `你好！

你的前置任务已经完成，现在可以开始你的任务了：

**Task #${nextTask.id}: ${nextTask.subject}**

${nextTask.description}

请开始工作吧！`,
        summary: `任务就绪：${nextTask.subject}`
      })
    }
  }
}
```

### 步骤8：代码质量检查

```javascript
// 当开发任务完成后，请求架构师进行代码审查
async function requestCodeReview() {
  await SendMessage({
    type: "message",
    recipient: "system-architect",
    content: `你好！

后端和前端开发已经完成，请进行代码质量检查。

**检查项：**
1. 代码结构是否符合架构设计
2. 是否遵循编码规范
3. 单元测试覆盖率是否达标
4. 代码可读性和可维护性
5. 是否存在性能问题
6. 是否存在安全漏洞

请审查完成后回复审查结果。`,
    summary: "请求代码审查"
  })
}
```

### 步骤9：整合结果和清理

```javascript
// 所有任务完成后，整合结果
async function finalizeDelivery() {
  const tasks = await TaskList()
  const allCompleted = tasks.every(t => t.status === 'completed')

  if (!allCompleted) {
    console.log("还有任务未完成，请等待...")
    return
  }

  // 整合所有输出文件
  const deliverables = [
    'requirements/{feature-name}.md',
    'requirements/{feature-name}-stories.md',
    'architecture/{feature-name}.md',
    'api-design/{feature-name}-api.md',
    'ui-review/{feature-name}-ui-review.md',
    'test-reports/{feature-name}-test-report.md'
  ]

  console.log(`
## ✅ 任务完成

### 交付内容
${deliverables.map(f => `- ✅ ${f}`).join('\n')}

### 更新项目配置
正在检查是否需要更新 PROJECT_CONFIG.md...
  `)

  // 检查是否需要更新项目配置
  // 例如：新增了业务域、API端点等

  console.log(`
## 📊 交付总结

**功能：** {功能名称}
**状态：** ✅ 已完成
**测试通过率：** 90%
**代码质量：** ✅ 通过

🎉 任务完成！
  `)
}
```

## 错误处理

### 任务创建失败

```javascript
try {
  const task = await TaskCreate({
    subject: "需求分析",
    description: "...",
    activeForm: "分析需求中"
  })
} catch (error) {
  console.error("任务创建失败：", error)
  // 重试或通知用户
}
```

### 团队成员无响应

```javascript
// 如果团队成员长时间无响应，发送提醒
async function checkStaleTask(taskId, maxIdleTime = 3600000) { // 1小时
  const task = await TaskGet({ taskId })

  if (task.status === 'in_progress') {
    const idleTime = Date.now() - task.lastUpdateTime

    if (idleTime > maxIdleTime) {
      await SendMessage({
        type: "message",
        recipient: task.owner,
        content: `你好！

注意到你的任务 Task #${taskId}: ${task.subject} 已经进行了一段时间。

是否遇到了什么障碍？需要帮助吗？

如果遇到问题，请及时告诉我，我会协调资源帮助你解决。`,
        summary: "任务进度检查"
      })
    }
  }
}
```

### 任务依赖死锁

```javascript
// 检测任务依赖是否存在循环依赖
function detectCircularDependency(tasks) {
  const visited = new Set()
  const recursionStack = new Set()

  function hasCycle(taskId) {
    if (recursionStack.has(taskId)) {
      return true // 发现循环依赖
    }

    if (visited.has(taskId)) {
      return false
    }

    visited.add(taskId)
    recursionStack.add(taskId)

    const task = tasks.find(t => t.id === taskId)
    if (task && task.blockedBy) {
      for (const depId of task.blockedBy) {
        if (hasCycle(depId)) {
          return true
        }
      }
    }

    recursionStack.delete(taskId)
    return false
  }

  for (const task of tasks) {
    if (hasCycle(task.id)) {
      console.error(`检测到循环依赖：Task #${task.id}`)
      return true
    }
  }

  return false
}
```

## 最佳实践

### 1. 任务粒度

- 每个任务应该是可独立完成的
- 任务时间不应超过1天
- 如果任务太大，拆分为多个子任务

### 2. 依赖管理

- 明确任务之间的依赖关系
- 避免循环依赖
- 尽量减少依赖，提高并行度

### 3. 沟通机制

- 及时通知团队成员任务分配
- 定期同步进度
- 遇到障碍及时沟通

### 4. 质量保证

- 每个任务都要有明确的验收标准
- 代码审查是必须的
- 测试覆盖率要达标

### 5. 文档输出

- 每个阶段都要输出文档
- 文档要清晰、完整、可追溯
- 文档要及时更新

## 总结

通过使用真实的工具调用（TaskCreate、TaskUpdate、SendMessage等），Scrum Master可以实现完全自动化的敏捷开发流程。关键是：

1. **自动化任务创建和分配** - 根据任务类型自动创建任务列表
2. **智能依赖管理** - 自动设置任务依赖关系
3. **主动进度监控** - 定期检查任务进度，及时发现问题
4. **高效团队协作** - 通过消息机制保持团队同步
5. **质量保证** - 代码审查和测试是必须的环节

这样，用户只需描述需求，Scrum Master就能自动组织团队完成整个开发流程。
