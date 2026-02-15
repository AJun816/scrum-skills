# 实时进度监控详解

## 概述

本文档详细说明 Scrum Master 的实时进度监控机制，包括监控原理、实现方法、可视化展示和最佳实践。

## 监控原理

### 核心机制

Scrum Master 通过 TaskList 工具实时监控团队进度，自动检测阻塞问题，提供可视化进度展示。

**监控频率：** 每30秒轮询一次任务状态

**监控内容：**
- 任务完成情况
- 任务进行状态
- 阻塞问题识别
- 团队成员状态
- 资源利用率
- 完成时间预测

### 实现逻辑

```javascript
// 伪代码示例
async function monitorProgress() {
  while (hasActiveTasks) {
    // 使用TaskList获取最新状态
    const tasks = await TaskList();

    // 分析任务状态
    const progress = analyzeProgress(tasks);

    // 检测阻塞问题
    const blockers = detectBlockers(tasks);

    // 显示进度
    displayProgress(progress, blockers);

    // 等待30秒
    await sleep(30000);
  }
}
```

---

## 进度计算

### 1. 整体进度统计

**计算公式：**
```
完成率 = 已完成任务数 / 总任务数 × 100%
```

**输出示例：**
```markdown
## 📊 实时进度监控

**整体进度：**
- 总任务数：10
- 已完成：3 (30%)
- 进行中：4 (40%)
- 待处理：3 (30%)
- 完成率：30%

**进度条：**
[████████░░░░░░░░░░░░] 30%
```

### 2. 任务状态分类

使用 TaskList 返回的状态信息：

| 状态 | 说明 | 计数方式 |
|------|------|----------|
| `pending` | 待处理任务 | 未开始的任务 |
| `in_progress` | 进行中任务 | 正在执行的任务 |
| `completed` | 已完成任务 | 已完成的任务 |
| `blockedBy` | 被阻塞的任务 | 有依赖未完成的任务 |

### 3. 进度可视化

**进度条生成：**
```javascript
function generateProgressBar(completed, total, width = 20) {
  const percentage = completed / total;
  const filled = Math.floor(percentage * width);
  const empty = width - filled;

  return '[' + '█'.repeat(filled) + '░'.repeat(empty) + '] ' +
         Math.floor(percentage * 100) + '%';
}
```

**输出示例：**
```
[████████░░░░░░░░░░░░] 30%  (3/10 任务完成)
[████████████████████] 100% (10/10 任务完成)
[██░░░░░░░░░░░░░░░░░░] 10%  (1/10 任务完成)
```

---

## 阻塞问题检测

### 1. 自动检测机制

**检测逻辑：**
```javascript
function detectBlockers(tasks) {
  const blockers = [];

  for (const task of tasks) {
    if (task.blockedBy && task.blockedBy.length > 0) {
      // 计算阻塞时长
      const blockDuration = calculateBlockDuration(task);

      // 识别阻塞原因
      const blockingTasks = task.blockedBy.map(id =>
        tasks.find(t => t.id === id)
      );

      blockers.push({
        task: task,
        duration: blockDuration,
        blockingTasks: blockingTasks
      });
    }
  }

  return blockers;
}
```

### 2. 阻塞问题报告

**输出示例：**
```markdown
## ⚠️ 阻塞问题检测

**发现阻塞：**
- Task #4（后端开发）被阻塞
  - 原因：等待Task #3（架构设计）完成
  - 阻塞时长：15分钟
  - 负责人：Backend Developer

- Task #5（前端开发）被阻塞
  - 原因：等待Task #3（架构设计）完成
  - 阻塞时长：15分钟
  - 负责人：Frontend Developer

**关键路径分析：**
- Task #3是关键任务，阻塞了2个后续任务
- 建议：优先关注Task #3的进度

**自动通知：**
✅ 已通知System Architect加快Task #3进度
```

### 3. 阻塞等级分类

| 等级 | 阻塞时长 | 处理方式 |
|------|----------|----------|
| 🟢 正常 | < 15分钟 | 继续观察 |
| 🟡 警告 | 15-30分钟 | 发送提醒 |
| 🟠 严重 | 30-60分钟 | 主动介入 |
| 🔴 紧急 | > 60分钟 | 立即升级 |

---

## 任务看板可视化

### 1. 看板布局

```markdown
## 📈 任务看板

### 待处理 (3)
- [ ] Task #8: UI设计审核
- [ ] Task #9: 性能测试
- [ ] Task #10: 文档编写

### 进行中 (4)
- [🔄] Task #3: 架构设计 (System Architect) - 进行中 45分钟
- [🔄] Task #6: 数据库设计 (Backend Developer) - 进行中 20分钟
- [🔄] Task #7: API开发 (Backend Developer) - 进行中 10分钟
- [🔄] Task #11: 代码审查 (System Architect) - 进行中 5分钟

### 已完成 (3)
- [✅] Task #1: 需求分析 (Product Manager)
- [✅] Task #2: 用户故事 (Product Manager)
- [✅] Task #12: 单元测试 (Tester)

### 被阻塞 (2)
- [⏳] Task #4: 后端开发 → 等待Task #3
- [⏳] Task #5: 前端开发 → 等待Task #3
```

### 2. 任务状态图标

| 图标 | 状态 | 说明 |
|------|------|------|
| [ ] | 待处理 | 未开始的任务 |
| [🔄] | 进行中 | 正在执行的任务 |
| [✅] | 已完成 | 已完成的任务 |
| [⏳] | 被阻塞 | 等待依赖完成 |
| [❌] | 失败 | 执行失败的任务 |

---

## 团队成员状态监控

### 1. 成员状态表

```markdown
## 👥 团队成员状态

| 成员 | 状态 | 当前任务 | 进度 |
|------|------|----------|------|
| Product Manager | 空闲 | - | 已完成2个任务 |
| System Architect | 工作中 | Task #3: 架构设计 | 75% |
| Backend Developer A | 工作中 | Task #6: 数据库设计 | 60% |
| Backend Developer B | 工作中 | Task #7: API开发 | 30% |
| Frontend Developer | 阻塞 | 等待Task #3 | - |
| Tester | 空闲 | - | 已完成1个任务 |

**资源利用率：** 67% (4/6人工作中)
```

### 2. 成员状态分类

| 状态 | 说明 | 处理方式 |
|------|------|----------|
| 工作中 | 正在执行任务 | 继续监控 |
| 空闲 | 无任务分配 | 分配新任务 |
| 阻塞 | 等待依赖 | 协调解除阻塞 |
| 超负荷 | 任务过多 | 重新分配任务 |

---

## 速率和预测分析

### 1. 团队速率计算

**计算公式：**
```
任务完成速率 = 已完成任务数 / 已用时间
预计完成时间 = 剩余任务数 / 任务完成速率
```

**输出示例：**
```markdown
## 📉 团队速率分析

**当前速率：**
- 平均任务完成时间：25分钟
- 已完成任务：3个
- 总耗时：1小时15分钟
- 任务完成速率：2.4个/小时

**预计完成时间：**
- 剩余任务：7个
- 预计耗时：2小时55分钟
- 预计完成时间：今天 17:30

**风险提示：**
- ⚠️ Task #3阻塞了2个任务，可能影响整体进度
- ⚠️ Frontend Developer空闲中，资源未充分利用
```

### 2. 燃尽图数据

**数据收集：**
```javascript
const burndownData = {
  totalTasks: 10,
  dataPoints: [
    { time: '09:00', remaining: 10 },
    { time: '10:00', remaining: 9 },
    { time: '11:00', remaining: 7 },
    { time: '12:00', remaining: 7 },  // 阻塞期
    { time: '13:00', remaining: 5 },
    // ...
  ]
};
```

**可视化输出：**
```
剩余任务数
10 |●
 9 | ●
 8 |
 7 |   ●●
 6 |
 5 |      ●
 4 |       ●
 3 |        ●
 2 |         ●
 1 |          ●
 0 |___________●____
   09 10 11 12 13 14 15 16 17 时间
```

---

## 自动通知机制

### 1. 通知触发条件

| 条件 | 触发时机 | 通知对象 | 通知内容 |
|------|----------|----------|----------|
| 任务阻塞 | 阻塞超过15分钟 | 阻塞任务负责人 | 提醒加快进度 |
| 任务超时 | 进行中超过1小时 | 任务负责人 | 询问是否需要帮助 |
| 成员空闲 | 空闲超过30分钟 | Scrum Master | 分配新任务 |
| 关键路径延迟 | 关键任务延迟 | Scrum Master | 升级处理 |
| 资源利用率低 | 利用率<50% | Scrum Master | 优化任务分配 |

### 2. 通知实现

**发送通知：**
```javascript
function sendNotification(recipient, message) {
  SendMessage({
    type: "notification",
    recipient: recipient,
    content: message,
    priority: "high"
  });
}

// 示例：任务阻塞通知
if (blockDuration > 15 * 60 * 1000) {  // 15分钟
  sendNotification(
    blockingTask.owner,
    `⚠️ 提醒：Task #${blockingTask.id} 已阻塞其他任务超过15分钟，请加快进度。`
  );
}
```

---

## 实时监控输出示例

### 完整监控报告

```markdown
## 🔄 实时进度监控 (自动更新)

**时间：** 2026-02-15 15:30:25

**整体进度：**
[████████░░░░░░░░░░░░] 30% (3/10)

**任务状态：**
✅ 已完成：3个
🔄 进行中：4个
⏳ 待处理：3个
⚠️ 被阻塞：2个

**关键信息：**
- 当前速率：2.4个任务/小时
- 预计完成：今天 17:30
- 资源利用率：67%

**需要关注：**
⚠️ Task #3阻塞了2个后续任务
⚠️ Frontend Developer空闲中

**任务看板：**

### 进行中 (4)
- [🔄] Task #3: 架构设计 (System Architect) - 75%
- [🔄] Task #6: 数据库设计 (Backend Dev A) - 60%
- [🔄] Task #7: API开发 (Backend Dev B) - 30%
- [🔄] Task #11: 代码审查 (System Architect) - 20%

### 被阻塞 (2)
- [⏳] Task #4: 后端开发 → 等待Task #3 (阻塞15分钟)
- [⏳] Task #5: 前端开发 → 等待Task #3 (阻塞15分钟)

### 已完成 (3)
- [✅] Task #1: 需求分析 (Product Manager)
- [✅] Task #2: 用户故事 (Product Manager)
- [✅] Task #12: 单元测试 (Tester)

### 待处理 (3)
- [ ] Task #8: UI设计审核
- [ ] Task #9: 性能测试
- [ ] Task #10: 文档编写

**团队成员状态：**
| 成员 | 状态 | 当前任务 |
|------|------|----------|
| Product Manager | 空闲 | - |
| System Architect | 工作中 | Task #3 (75%) |
| Backend Dev A | 工作中 | Task #6 (60%) |
| Backend Dev B | 工作中 | Task #7 (30%) |
| Frontend Developer | 阻塞 | 等待Task #3 |
| Tester | 空闲 | - |

⏱️ 下次更新：30秒后
```

---

## 监控工具使用

### 核心工具：TaskList

**调用方式：**
```javascript
// 获取所有任务状态
const tasks = await TaskList();

// 返回数据结构
[
  {
    id: "task1_id",
    subject: "需求分析",
    status: "completed",
    owner: "product-manager",
    blockedBy: []
  },
  {
    id: "task4_id",
    subject: "后端开发",
    status: "pending",
    owner: "backend-developer",
    blockedBy: ["task3_id"]
  },
  // ...
]
```

**数据处理：**
```javascript
// 1. 统计各状态任务数量
const statusCount = {
  pending: tasks.filter(t => t.status === 'pending').length,
  in_progress: tasks.filter(t => t.status === 'in_progress').length,
  completed: tasks.filter(t => t.status === 'completed').length
};

// 2. 识别blockedBy字段，检测阻塞
const blockedTasks = tasks.filter(t =>
  t.blockedBy && t.blockedBy.length > 0
);

// 3. 计算完成百分比
const completionRate =
  (statusCount.completed / tasks.length) * 100;

// 4. 预测完成时间
const avgTaskTime = totalTime / statusCount.completed;
const remainingTime = avgTaskTime *
  (statusCount.pending + statusCount.in_progress);
```

### 监控流程

```
开始监控
  ↓
调用TaskList
  ↓
分析任务状态
  ↓
检测阻塞问题
  ↓
计算进度百分比
  ↓
预测完成时间
  ↓
生成可视化报告
  ↓
发送通知（如需要）
  ↓
等待30秒
  ↓
循环
```

---

## 监控最佳实践

### 1. 持续监控
- ✅ 在任务执行期间持续监控，不中断
- ✅ 每30秒更新一次进度
- ✅ 自动检测状态变化

### 2. 主动通知
- ✅ 发现问题立即通知相关人员
- ✅ 使用分级通知机制（提醒、警告、紧急）
- ✅ 记录通知历史，避免重复通知

### 3. 数据驱动
- ✅ 基于真实数据预测，不凭感觉
- ✅ 使用历史数据优化预测准确性
- ✅ 记录速率变化趋势

### 4. 可视化展示
- ✅ 使用进度条、表格、看板等可视化方式
- ✅ 突出显示关键信息和风险
- ✅ 保持报告简洁易读

### 5. 关注关键路径
- ✅ 优先关注阻塞多个任务的关键任务
- ✅ 识别关键路径上的延迟
- ✅ 主动协调资源解决关键任务

### 6. 资源优化
- ✅ 监控团队成员工作负载
- ✅ 识别空闲资源，及时分配任务
- ✅ 平衡团队工作量

---

## 常见问题和解决方案

### 问题1：监控数据不准确
**原因：** 团队成员未及时更新任务状态
**解决：**
- 提醒团队成员及时更新状态
- 使用自动化工具同步状态
- 定期检查数据准确性

### 问题2：阻塞问题未及时发现
**原因：** 监控频率不够
**解决：**
- 缩短监控间隔（从30秒到15秒）
- 增加主动询问机制
- 建立快速响应流程

### 问题3：预测时间不准确
**原因：** 任务复杂度差异大
**解决：**
- 使用加权平均计算速率
- 考虑任务复杂度因素
- 基于历史数据优化算法

### 问题4：通知过多干扰团队
**原因：** 通知阈值设置不合理
**解决：**
- 调整通知阈值
- 使用分级通知机制
- 合并相似通知

---

## 总结

实时进度监控是 Scrum Master 的核心职责之一，通过：
- **持续监控** - 每30秒更新进度
- **自动检测** - 识别阻塞和风险
- **可视化展示** - 清晰展示进度和状态
- **主动通知** - 及时提醒相关人员
- **数据驱动** - 基于真实数据预测

确保团队高效协作，按时交付价值。
