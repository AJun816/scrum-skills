# 全自动化工作流程详解

## 概述

本文档详细说明 Scrum Master 的全自动化敏捷开发流程，包括真实的工具调用示例和执行逻辑。

## 核心理念

**用户只需描述需求，Scrum Master 自动完成整个敏捷开发流程：**
- 自动分析任务类型
- 自动创建任务列表
- 自动分配团队成员
- 自动监控进度
- 自动质量检查
- 自动输出报告

## 详细执行流程

### 第1步：任务接收和分析

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
Read({
  file_path: "PROJECT_CONFIG.md"
})
```

**输出给用户：**
```markdown
### 读取项目配置
✅ 项目：电商平台
✅ 技术栈：Vue 3 + Spring Boot + MySQL
✅ 业务域：user, order, product, payment

### 任务类型识别
正在分析任务类型...

**识别结果：**
- 任务类型：新功能开发
- 涉及业务域：order, payment
- 复杂度：中等
- 需要的角色：产品经理、架构师、后端开发、前端开发、UI设计师、测试工程师

开始创建任务...
```

### 第2步：创建任务列表

**执行工具调用：**
```javascript
// 创建任务1：需求分析
TaskCreate({
  subject: "需求分析",
  description: "分析用户需求：{用户输入}\n\n要求：\n1. 理解业务目标\n2. 识别功能范围\n3. 明确验收标准\n4. 输出需求文档",
  activeForm: "分析需求中"
})

// 创建任务2：编写用户故事
TaskCreate({
  subject: "编写用户故事",
  description: "基于需求分析结果，编写用户故事\n\n要求：\n1. 使用标准格式（As a... I want... So that...）\n2. 定义验收标准\n3. 估算故事点\n4. 输出用户故事文档",
  activeForm: "编写用户故事中"
})

// 创建任务3：架构设计
TaskCreate({
  subject: "架构设计",
  description: "设计技术架构和实现方案\n\n要求：\n1. 设计系统架构\n2. 定义API接口\n3. 设计数据模型\n4. 输出架构设计文档",
  activeForm: "设计架构中"
})

// 创建任务4：后端开发
TaskCreate({
  subject: "后端开发",
  description: "实现后端功能\n\n要求：\n1. 实现API接口\n2. 实现业务逻辑\n3. 编写单元测试\n4. 更新API文档",
  activeForm: "开发后端中"
})

// 创建任务5：前端开发
TaskCreate({
  subject: "前端开发",
  description: "实现前端功能\n\n要求：\n1. 实现页面和组件\n2. 对接后端API\n3. 实现交互逻辑\n4. 编写组件测试",
  activeForm: "开发前端中"
})

// 创建任务6：UI审核
TaskCreate({
  subject: "UI设计审核",
  description: "审核前端UI实现\n\n要求：\n1. 检查设计一致性\n2. 验证交互体验\n3. 检查响应式布局\n4. 输出UI审核报告",
  activeForm: "审核UI中"
})

// 创建任务7：功能测试
TaskCreate({
  subject: "功能测试",
  description: "执行功能测试\n\n要求：\n1. 编写测试用例\n2. 执行功能测试\n3. 执行集成测试\n4. 输出测试报告",
  activeForm: "测试中"
})
```

**输出给用户：**
```markdown
## 📋 创建任务列表

✅ 任务列表已创建

**任务列表：**
- Task #1: 需求分析
- Task #2: 编写用户故事
- Task #3: 架构设计
- Task #4: 后端开发
- Task #5: 前端开发
- Task #6: UI设计审核
- Task #7: 功能测试
```

### 第3步：设置任务依赖关系

**执行工具调用：**
```javascript
// 获取任务列表
TaskList()
// 假设返回的任务ID为：task1_id, task2_id, task3_id, task4_id, task5_id, task6_id, task7_id

// 设置任务2依赖任务1
TaskUpdate({
  taskId: task2_id,
  addBlockedBy: [task1_id]
})

// 设置任务3依赖任务2
TaskUpdate({
  taskId: task3_id,
  addBlockedBy: [task2_id]
})

// 设置任务4依赖任务3
TaskUpdate({
  taskId: task4_id,
  addBlockedBy: [task3_id]
})

// 设置任务5依赖任务3（可以与任务4并行）
TaskUpdate({
  taskId: task5_id,
  addBlockedBy: [task3_id]
})

// 设置任务6依赖任务5
TaskUpdate({
  taskId: task6_id,
  addBlockedBy: [task5_id]
})

// 设置任务7依赖任务4和6
TaskUpdate({
  taskId: task7_id,
  addBlockedBy: [task4_id, task6_id]
})
```

**输出给用户：**
```markdown
✅ 任务依赖关系已设置

**依赖关系：**
- Task #2 依赖 Task #1
- Task #3 依赖 Task #2
- Task #4 依赖 Task #3
- Task #5 依赖 Task #3（可与Task #4并行）
- Task #6 依赖 Task #5
- Task #7 依赖 Task #4 和 Task #6
```

### 第4步：分配任务给团队成员

**执行工具调用：**
```javascript
// 分配任务1和2给产品经理
TaskUpdate({
  taskId: task1_id,
  owner: "product-manager"
})

TaskUpdate({
  taskId: task2_id,
  owner: "product-manager"
})

// 分配任务3给系统架构师
TaskUpdate({
  taskId: task3_id,
  owner: "system-architect"
})

// 分配任务4给后端开发
TaskUpdate({
  taskId: task4_id,
  owner: "backend-developer"
})

// 分配任务5给前端开发
TaskUpdate({
  taskId: task5_id,
  owner: "frontend-developer"
})

// 分配任务6给UI设计师
TaskUpdate({
  taskId: task6_id,
  owner: "ui-designer"
})

// 分配任务7给测试工程师
TaskUpdate({
  taskId: task7_id,
  owner: "tester"
})

// 通知产品经理开始工作
SendMessage({
  type: "message",
  recipient: "product-manager",
  content: "你好！我是Scrum Master。\n\n我已经为你分配了2个任务：\n- Task #" + task1_id + ": 需求分析\n- Task #" + task2_id + ": 编写用户故事\n\n请先完成Task #" + task1_id + "，然后再进行Task #" + task2_id + "。\n\n用户需求：{用户输入}\n\n请开始工作吧！",
  summary: "任务分配：需求分析和用户故事"
})
```

**输出给用户：**
```markdown
## 👥 分配任务

✅ 所有任务已分配

**任务分配：**
- Task #1, #2: Product Manager（产品经理）
- Task #3: System Architect（系统架构师）
- Task #4: Backend Developer（后端开发）
- Task #5: Frontend Developer（前端开发）
- Task #6: UI Designer（UI设计师）
- Task #7: Tester（测试工程师）

✅ 已通知产品经理开始工作

团队成员开始并行工作...
```

### 第5步：监控进度

**输出给用户：**
```markdown
## 📊 监控团队进度

正在监控团队成员工作进度...

**进度：**
- ✅ Product Manager：需求分析完成
- ✅ Product Manager：用户故事完成
- 🔄 System Architect：架构设计进行中...
- ⏳ Backend Developer：等待架构设计完成
- ⏳ Frontend Developer：等待架构设计完成

**实时进度监控：**
- 总任务数：7
- 已完成：2 (29%)
- 进行中：1 (14%)
- 待处理：4 (57%)
- 阻塞任务：2个（等待Task #3完成）

⏱️ 下次更新：30秒后
```

### 第6步：代码质量检查

**输出给用户：**
```markdown
## 🔍 代码质量检查

### 协调System Architect进行代码审查
正在请求System Architect审查代码...

**审查结果：**
- ✅ 代码结构符合架构设计
- ✅ 遵循编码规范
- ✅ 单元测试覆盖率达标
- ✅ 代码可读性良好
- ✅ 无明显性能问题
- ✅ 无安全漏洞

✅ 代码质量检查通过
```

### 第7步：交付和总结

**输出给用户：**
```markdown
## ✅ 任务完成

### 整合结果
正在整合所有团队成员的工作成果...

**交付内容：**
- ✅ 需求文档：requirements/{feature-name}.md
- ✅ 用户故事：requirements/{feature-name}-stories.md
- ✅ 架构设计：architecture/{feature-name}.md
- ✅ API设计：api-design/{feature-name}-api.md
- ✅ 后端代码：{文件列表}
- ✅ 前端代码：{文件列表}
- ✅ UI审核报告：ui-review/{feature-name}-ui-review.md
- ✅ 测试报告：test-reports/{feature-name}-test-report.md

### 更新PROJECT_CONFIG.md
正在检查是否需要更新项目配置...
✅ 项目配置已更新

### 清理团队资源
正在使用TeamDelete清理团队资源...
✅ 团队资源已清理

## 📊 交付总结

**功能：** {功能名称}
**状态：** ✅ 已完成
**测试通过率：** 90%
**代码质量：** ✅ 通过

**输出文件：**
- 📄 测试报告：.cache/shared/test-reports/{feature-name}-test-report.md

🎉 任务完成！
```

## 任务类型识别规则

### 1. 新功能开发
**关键词：** 开发、实现、添加、新增、创建
**流程：** 需求分析 → 用户故事 → 架构设计 → 开发 → UI审核 → 测试

### 2. Bug修复
**关键词：** 修复、Bug、问题、错误、异常
**流程：** Bug分析 → 修复方案 → 修复实现 → 回归测试

### 3. 架构优化
**关键词：** 优化、重构、性能、架构、改进
**流程：** 性能分析 → 优化方案 → 优化实现 → 性能测试

### 4. 需求变更
**关键词：** 修改、变更、调整、更新
**流程：** 变更影响分析 → 变更设计 → 变更实现 → 回归测试

## 错误处理

### 任务创建失败
- 重试3次
- 记录错误日志
- 通知用户

### 团队成员无响应
- 等待30秒
- 发送提醒
- 超时后重新分配

### 代码质量检查失败
- 标记问题代码
- 通知相关开发人员
- 阻止提交，要求修复

## 最佳实践

1. **清晰的任务描述** - 每个任务都有明确的要求和验收标准
2. **合理的依赖关系** - 避免循环依赖，最大化并行度
3. **及时的进度监控** - 每30秒更新一次进度
4. **主动的障碍移除** - 发现阻塞立即处理
5. **严格的质量把关** - 代码质量检查不通过不允许提交
