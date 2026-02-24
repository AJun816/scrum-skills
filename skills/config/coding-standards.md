# 编码规范

**定义技能组的代码质量标准，所有开发类技能必须遵循。**

---

## 后端代码（Java）

**命名规范：**
- 类名：PascalCase（如 `UserService`）
- 方法名：camelCase（如 `getUserById`）
- 变量名：camelCase，语义清晰（如 `userName`）
- 常量名：UPPER_SNAKE_CASE（如 `MAX_RETRY_COUNT`）
- 包名：全小写（如 `com.project.domain.user`）

**大小限制：**
- 单个方法不超过50行，单个类不超过500行
- 方法参数不超过5个，嵌套最多3层

**代码结构（DDD架构）：**
- 领域层（domain）：领域模型、值对象、领域服务
- 应用层（application）：应用服务、DTO
- 接口层（interfaces）：Controller、DTO转换
- 基础设施层（infrastructure）：Repository实现、外部服务

**异常处理：** 使用自定义业务异常，统一异常处理，记录异常日志
**日志规范：** ERROR/WARN/INFO/DEBUG分级，关键操作必须记录，禁止记录敏感信息

## 前端代码（Vue/TypeScript）

**命名规范：**
- 组件名：PascalCase（如 `UserProfile.vue`）
- 方法名：camelCase（如 `handleSubmit`）
- 常量名：UPPER_SNAKE_CASE（如 `API_BASE_URL`）

**大小限制：**
- 单个组件不超过300行，单个方法不超过30行
- 嵌套最多3层，使用TypeScript类型注解

**代码结构（Vue 3）：**
- views：页面组件
- components：可复用组件
- composables：组合式函数
- stores：状态管理（Pinia）
- api：API接口封装
- utils：工具函数

**异常处理：** API调用统一错误处理，用户友好的错误提示

## 注释规范

**必须添加注释：** 类/接口职责、公共方法参数和返回值、复杂逻辑、魔法数字
**注释要求：** 使用中文，简洁准确有价值，及时更新保持同步

## 性能优化

**后端：** 避免N+1查询，合理使用缓存，数据库索引优化，避免大事务
**前端：** 组件懒加载，图片懒加载，防抖节流，避免不必要的重渲染

## 安全编码

- SQL注入：使用参数化查询
- XSS攻击：输入验证和输出转义
- CSRF攻击：使用CSRF Token
- 敏感信息：不在日志中记录，接口级别权限验证

## 质量指标

- 单元测试覆盖率 ≥ 80%（后端）/ ≥ 70%（前端）
- 代码审查通过率 = 100%
- 代码重复率 ≤ 5%
- API响应时间 ≤ 500ms（P95）
- 页面加载时间 ≤ 2s
