# 并行工作策略和冲突预防

## 任务分配策略

### 1. 按模块分配

**适用场景：** 项目有清晰的模块划分

**分配规则：**
```javascript
function assignByModule(tasks, developers) {
  const moduleMap = {};

  // 按模块分组任务
  for (const task of tasks) {
    const module = task.module;
    if (!moduleMap[module]) {
      moduleMap[module] = [];
    }
    moduleMap[module].push(task);
  }

  // 分配模块给开发者
  const modules = Object.keys(moduleMap);
  for (let i = 0; i < modules.length; i++) {
    const developer = developers[i % developers.length];
    const moduleTasks = moduleMap[modules[i]];

    for (const task of moduleTasks) {
      assignTask(task, developer);
    }
  }
}
```

**示例：**
```markdown
## 按模块分配任务

**后端开发A：** user 模块
- Task #1: 用户注册API
- Task #2: 用户登录API
- Task #3: 用户信息查询API

**后端开发B：** order 模块
- Task #4: 订单创建API
- Task #5: 订单查询API
- Task #6: 订单取消API

**后端开发C：** payment 模块
- Task #7: 支付发起API
- Task #8: 支付回调API
- Task #9: 支付查询API
```

### 2. 按层次分配

**适用场景：** 需要跨模块协作，但可以按技术层次划分

**分配规则：**
```javascript
function assignByLayer(tasks, developers) {
  const layerMap = {
    controller: [],
    service: [],
    repository: []
  };

  // 按层次分组任务
  for (const task of tasks) {
    const layer = task.layer;
    layerMap[layer].push(task);
  }

  // 分配层次给开发者
  assignTask(layerMap.controller, developers[0]);
  assignTask(layerMap.service, developers[1]);
  assignTask(layerMap.repository, developers[2]);
}
```

**示例：**
```markdown
## 按层次分配任务

**前端开发A：** 页面和路由
- Task #1: 创建用户管理页面
- Task #2: 创建订单管理页面
- Task #3: 配置路由

**前端开发B：** 组件和composables
- Task #4: 开发用户表单组件
- Task #5: 开发订单列表组件
- Task #6: 开发通用composables

**前端开发C：** API对接和状态管理
- Task #7: 对接用户API
- Task #8: 对接订单API
- Task #9: 配置Pinia状态管理
```

### 3. 按优先级分配

**适用场景：** 任务有明确的优先级，需要优先处理高优先级任务

**分配规则：**
```javascript
function assignByPriority(tasks, developers) {
  // 按优先级排序任务
  tasks.sort((a, b) => b.priority - a.priority);

  // 轮流分配给开发者
  for (let i = 0; i < tasks.length; i++) {
    const developer = developers[i % developers.length];
    assignTask(tasks[i], developer);
  }
}
```

**示例：**
```markdown
## 按优先级分配任务

**P0（紧急）：**
- Task #1: 修复支付失败bug → 后端开发A
- Task #2: 修复登录异常bug → 后端开发B

**P1（重要）：**
- Task #3: 实现订单导出功能 → 后端开发C
- Task #4: 实现用户权限管理 → 后端开发A

**P2（普通）：**
- Task #5: 优化查询性能 → 后端开发B
- Task #6: 添加日志记录 → 后端开发C
```

### 4. 负载均衡分配

**适用场景：** 确保每个开发者的工作量均衡

**分配规则：**
```javascript
function assignByLoadBalance(tasks, developers) {
  // 初始化开发者负载
  const developerLoad = developers.map(d => ({
    developer: d,
    load: 0,
    tasks: []
  }));

  // 按任务工作量排序
  tasks.sort((a, b) => b.estimatedHours - a.estimatedHours);

  // 分配给负载最小的开发者
  for (const task of tasks) {
    // 找到负载最小的开发者
    const minLoadDev = developerLoad.reduce((min, dev) =>
      dev.load < min.load ? dev : min
    );

    // 分配任务
    minLoadDev.tasks.push(task);
    minLoadDev.load += task.estimatedHours;
  }

  return developerLoad;
}
```

**示例：**
```markdown
## 负载均衡分配

**后端开发A：** 总工作量 8小时
- Task #1: 用户登录API (3小时)
- Task #2: 用户信息查询API (2小时)
- Task #3: 用户权限验证 (3小时)

**后端开发B：** 总工作量 8小时
- Task #4: 订单创建API (4小时)
- Task #5: 订单查询API (2小时)
- Task #6: 订单统计 (2小时)

**后端开发C：** 总工作量 8小时
- Task #7: 支付发起API (5小时)
- Task #8: 支付回调API (3小时)
```

---

## 冲突预防机制

### 1. 文件级隔离

**核心原则：** 不同实例避免同时修改同一个文件

**实现机制：**

**文件锁定表：**
```javascript
const fileLockTable = {
  'UserController.java': {
    lockedBy: 'backend-dev-a',
    lockedAt: '2026-02-15 10:00:00',
    taskId: 'task1'
  },
  'OrderController.java': {
    lockedBy: 'backend-dev-b',
    lockedAt: '2026-02-15 10:05:00',
    taskId: 'task4'
  }
};
```

**锁定检查：**
```javascript
function checkFileLock(file, developer) {
  const lock = fileLockTable[file];

  if (lock && lock.lockedBy !== developer) {
    console.log(`
⚠️ 文件冲突检测

文件：${file}
当前锁定者：${lock.lockedBy}
锁定时间：${lock.lockedAt}
任务ID：${lock.taskId}

建议：等待 ${lock.lockedBy} 完成后再修改此文件
    `);
    return false;
  }

  return true;
}
```

**自动协调：**
```javascript
function coordinateFileAccess(file, developer, taskId) {
  // 检查文件锁定
  if (!checkFileLock(file, developer)) {
    // 文件被锁定，协调顺序执行
    console.log(`
## 🔄 协调文件访问

Scrum Master 正在协调文件访问...

**方案：**
1. 等待 ${fileLockTable[file].lockedBy} 完成 Task #${fileLockTable[file].taskId}
2. 然后 ${developer} 开始 Task #${taskId}

**预计等待时间：** 15分钟
    `);

    // 设置任务依赖
    TaskUpdate({
      taskId: taskId,
      addBlockedBy: [fileLockTable[file].taskId]
    });

    return false;
  }

  // 文件未锁定，锁定文件
  fileLockTable[file] = {
    lockedBy: developer,
    lockedAt: new Date().toISOString(),
    taskId: taskId
  };

  return true;
}
```

### 2. 模块级隔离

**核心原则：** 优先分配不同模块的任务给不同实例

**实现机制：**

**模块分配表：**
```javascript
const moduleAssignment = {
  'user': 'backend-dev-a',
  'order': 'backend-dev-b',
  'payment': 'backend-dev-c'
};
```

**模块冲突检查：**
```javascript
function checkModuleConflict(module, developer) {
  const assignedDev = moduleAssignment[module];

  if (assignedDev && assignedDev !== developer) {
    console.log(`
⚠️ 模块冲突检测

模块：${module}
当前负责人：${assignedDev}

建议：将此任务分配给 ${assignedDev}
    `);
    return false;
  }

  return true;
}
```

### 3. Git分支策略

**核心原则：** 每个实例在独立的feature分支工作

**分支命名规范：**
```
feature/{developer}-{task-id}-{description}

示例：
- feature/backend-dev-a-task1-user-login
- feature/backend-dev-b-task4-order-create
- feature/frontend-dev-a-task7-user-page
```

**分支管理：**
```javascript
function createFeatureBranch(developer, taskId, description) {
  const branchName = `feature/${developer}-${taskId}-${description}`;

  // 创建并切换到新分支
  Bash({
    command: `git checkout -b ${branchName}`,
    description: `创建feature分支：${branchName}`
  });

  console.log(`
✅ 创建feature分支

分支名称：${branchName}
负责人：${developer}
任务ID：${taskId}

请在此分支上工作，完成后提交PR合并到主分支。
  `);
}
```

**合并策略：**
```javascript
function mergeFeatureBranch(branchName) {
  // 检查冲突
  const conflicts = checkMergeConflicts(branchName);

  if (conflicts.length > 0) {
    console.log(`
⚠️ 合并冲突检测

发现 ${conflicts.length} 个冲突文件：
${conflicts.map(f => `- ${f}`).join('\n')}

**解决方案：**
1. 手动解决冲突
2. 或者协调相关开发者顺序合并
    `);
    return false;
  }

  // 无冲突，自动合并
  Bash({
    command: `git merge ${branchName}`,
    description: `合并feature分支：${branchName}`
  });

  console.log(`✅ 分支合并完成`);
  return true;
}
```

---

## 相关文档

- **并行工作概述和原则：** `parallel-work-overview.md`
- **协调机制和效率优化：** `parallel-work-coordination.md`
