# 项目配置

## 项目信息

- **项目名称：** Scrum Skills（敏捷团队技能组）
- **项目类型：** AI技能组 / 开发工具
- **项目描述：** 基于Claude的敏捷开发团队技能组，提供完整的软件开发流程自动化
- **版本：** 1.0.0
- **创建时间：** 2024-02-13
- **最后更新：** 2026-02-15

## 技术栈

### 支持的技术栈

**后端技术：**
- Java + Spring Boot（主要）
- DDD（领域驱动设计）架构
- MyBatis / JPA
- MySQL / PostgreSQL
- Redis
- Maven / Gradle

**前端技术：**
- Vue 3 + TypeScript（主要）
- Vite
- Element Plus / Ant Design Vue
- Pinia（状态管理）
- Vue Router
- Axios

**其他技术：**
- Git（版本控制）
- Docker（容器化）
- Jenkins / GitHub Actions（CI/CD）
- Nginx（Web服务器）

## 业务域

### 核心业务域

本项目是技能组项目，主要业务域为：

1. **技能管理（skills）**
   - 技能定义和配置
   - 技能执行和协调
   - 技能优化和维护

2. **团队协作（collaboration）**
   - 任务分配和跟踪
   - 进度监控
   - 团队沟通

3. **代码质量（quality）**
   - 代码审查
   - 质量检查
   - 标准执行

4. **项目管理（management）**
   - 需求分析
   - 架构设计
   - 迭代规划

### 支持的业务域（用于实际项目）

技能组可以支持任何业务域的项目开发，常见的包括：

- **用户管理（user）** - 用户注册、登录、权限管理
- **订单管理（order）** - 订单创建、查询、处理
- **商品管理（product）** - 商品信息、库存管理
- **支付管理（payment）** - 支付流程、对账
- **内容管理（content）** - 文章、评论、标签
- **数据分析（analytics）** - 统计、报表、可视化

## 架构模式

### 后端架构（DDD）

```
backend/
├── domain/              # 领域层
│   ├── model/          # 领域模型
│   ├── service/        # 领域服务
│   └── repository/     # 仓储接口
├── application/         # 应用层
│   ├── service/        # 应用服务
│   └── dto/            # 数据传输对象
├── interfaces/          # 接口层
│   ├── controller/     # REST控制器
│   └── assembler/      # DTO转换器
└── infrastructure/      # 基础设施层
    ├── persistence/    # 持久化实现
    └── external/       # 外部服务
```

### 前端架构（Vue 3）

```
frontend/
├── src/
│   ├── views/          # 页面组件
│   ├── components/     # 可复用组件
│   ├── composables/    # 组合式函数
│   ├── stores/         # 状态管理（Pinia）
│   ├── api/            # API接口
│   ├── router/         # 路由配置
│   ├── utils/          # 工具函数
│   └── assets/         # 静态资源
```

## 代码规范

### 文件大小限制

- **硬性限制：** 单个文件 ≤ 800 行
- **建议限制：** 单个文件 ≤ 500 行（SKILL.md）
- **警告阈值：** 单个文件 > 600 行

### 方法大小限制

- **硬性限制：** 单个方法 ≤ 50 行
- **建议限制：** 单个方法 ≤ 30 行
- **警告阈值：** 单个方法 > 30 行

### 命名规范

**Java：**
- 类名：PascalCase（如 `UserService`）
- 方法名：camelCase（如 `getUserById`）
- 变量名：camelCase（如 `userName`）
- 常量名：UPPER_SNAKE_CASE（如 `MAX_RETRY_COUNT`）
- 包名：lowercase（如 `com.project.domain.user`）

**Vue/TypeScript：**
- 组件名：PascalCase（如 `UserProfile.vue`）
- 方法名：camelCase（如 `handleSubmit`）
- 变量名：camelCase（如 `userName`）
- 常量名：UPPER_SNAKE_CASE（如 `API_BASE_URL`）

### 设计原则

1. **KISS原则** - Keep It Simple, Stupid（保持简单）
2. **单一职责原则** - 每个类/方法只有一个职责
3. **DRY原则** - Don't Repeat Yourself（不重复）
4. **最小变更原则** - 只改必要的部分
5. **代码复用** - 优先复用已有代码

## 技能组配置

### 可用技能列表

1. **0-scrum-master** - 敏捷教练（协调者）
2. **1-business-expert** - 业务专家
3. **2-product-manager** - 产品经理
4. **3-system-architect** - 系统架构师
5. **4-backend-dev** - Java后端开发
6. **4-frontend-dev** - Vue前端开发
7. **4-frontend-design** - 前端设计
8. **4-nielsen-ui-design** - UI/UX设计
9. **5-devops-engineer** - DevOps工程师
10. **5-webapp-testing** - Web应用测试
11. **6-bug-handler** - Bug处理专家
12. **7-skill-creator** - 技能创建器
13. **8-code-reviewer** - 代码审查专家

### 标准工作流程

```
用户需求
  ↓
1. 需求分析（Product Manager）
  ↓
2. 用户故事（Product Manager）
  ↓
3. 架构设计（System Architect）
  ↓
4. 并行开发
   ├── 后端开发（Backend Dev）
   ├── 前端开发（Frontend Dev）
   └── UI设计（UI Designer）
  ↓
5. 代码审查（Code Reviewer）
  ↓
6. 测试验证（Tester）
  ↓
7. 交付部署（DevOps）
```

## 质量标准

### 代码质量

- ✅ 遵循代码规范
- ✅ 通过代码审查
- ✅ 单元测试覆盖率 ≥ 80%
- ✅ 无严重安全漏洞
- ✅ 无性能问题

### 文档质量

- ✅ API文档完整
- ✅ 代码注释清晰
- ✅ README完整
- ✅ 变更日志更新

### 交付标准

- ✅ 功能完整
- ✅ 测试通过
- ✅ 文档齐全
- ✅ 代码审查通过
- ✅ 无已知bug

## 环境配置

### 开发环境

- JDK 17+
- Node.js 18+
- MySQL 8.0+
- Redis 6.0+
- Git 2.30+

### 构建工具

- Maven 3.8+ / Gradle 7.0+
- npm 9+ / pnpm 8+
- Docker 20.0+

## 团队协作

### 沟通机制

- 使用TaskCreate/TaskUpdate管理任务
- 使用SendMessage进行团队沟通
- 实时进度监控（每30秒）
- 自动检测阻塞问题

### 并行工作

- 支持多个技能实例并行工作
- 按模块/层次/优先级分配任务
- 文件级和模块级隔离
- Scrum Master协调防止冲突

### 质量保障

- 代码审查强制执行
- 自动化测试
- 持续集成/持续部署
- 定期代码质量检查

## 缓存机制

### 缓存目录

```
.cache/
├── .project-info.json          # 项目信息缓存
├── 0-scrum-master/             # Scrum Master缓存
├── 2-product-manager/          # 产品经理缓存
├── 3-system-architect/         # 架构师缓存
├── 4-backend-dev/         # 后端开发缓存
├── 4-frontend-dev/         # 前端开发缓存
├── 7-skill-creator/            # 技能创建器缓存
└── 8-code-reviewer/            # 代码审查缓存
```

### 缓存策略

- 首次使用：全量分析，生成缓存
- 后续使用：加载缓存，增量更新
- 使用git diff识别变更
- Token节约率：70-80%

## 更新日志

### 2026-02-15
- 优化所有SKILL.md文件，控制在500行以内
- 创建详细的references/文档
- 完善强制执行规范
- 优化缓存机制

### 2024-02-13
- 初始化项目
- 创建13个核心技能
- 建立团队协作机制
- 实现自动化工作流程

---

**注意：** 本配置文件会根据项目实际情况自动更新。如需手动修改，请确保所有技能都能正确读取。
