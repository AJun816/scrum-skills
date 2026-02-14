# 任务拆解模板

## 功能概述
[简要描述要实现的功能]

## 用户故事
```
作为 [用户角色]
我想要 [功能描述]
以便 [业务价值]
```

## 验收标准

### 功能验收
- [ ] [验收条件1]
- [ ] [验收条件2]
- [ ] [验收条件3]

### 技术验收
- [ ] 代码通过评审
- [ ] 单元测试覆盖率 ≥ 80%
- [ ] 集成测试通过
- [ ] 性能指标达标

## 技术任务拆解

### 后端任务
- [ ] **领域模型设计**
  - 实体类：`domain/[domain]/[Entity].java`
  - 值对象：`domain/[domain]/vo/[ValueObject].java`
  - 仓储接口：`domain/[domain]/repository/[Repository].java`

- [ ] **应用服务实现**
  - 应用服务：`application/service/[Service].java`
  - DTO：`application/dto/[DTO].java`
  - 组装器：`application/assembler/[Assembler].java`

- [ ] **API 接口开发**
  - 控制器：`interfaces/controller/[Controller].java`
  - 请求/响应对象

- [ ] **数据库变更**
  - 建表 SQL
  - 索引创建
  - 数据迁移（如需要）

- [ ] **单元测试**
  - 领域模型测试
  - 应用服务测试
  - API 接口测试

### 前端任务
- [ ] **页面组件开发**
  - 视图：`views/[ViewName].vue`
  - 业务组件：`components/[ComponentName].vue`

- [ ] **状态管理**
  - Store：`store/[storeName].js`
  - State、Getters、Actions

- [ ] **API 集成**
  - API 客户端：`api/[resource].js`
  - Composable：`composables/use[FeatureName].js`

- [ ] **组件测试**
  - 单元测试
  - 集成测试

### 测试任务
- [ ] **测试用例编写**
  - 功能测试用例
  - 边界条件测试
  - 异常场景测试

- [ ] **测试执行**
  - 功能测试
  - 集成测试
  - 回归测试

## 依赖关系
- 前置条件：[列出依赖的其他任务]
- 阻塞项：[列出可能的阻塞因素]

## 工作量估算
- 故事点：[1/2/3/5/8]
- 预计工时：[X 人天]

## 风险评估
- 技术风险：[描述技术风险]
- 业务风险：[描述业务风险]
- 缓解措施：[描述缓解措施]

## 负责人分配
- 后端开发：[@开发者]
- 前端开发：[@开发者]
- 测试：[@测试工程师]
- 评审人：[@架构师]
