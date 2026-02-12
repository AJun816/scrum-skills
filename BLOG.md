# AI驱动的敏捷团队技能组：让Claude变身完整开发团队

> 一个创新的AI协作框架，通过多角色技能组模拟真实敏捷团队，实现从需求到上线的全流程自动化开发

## 🎯 这是什么？

想象一下，你有一个完整的敏捷开发团队：产品经理、架构师、前后端开发、测试工程师、DevOps...但这个团队完全由AI驱动，可以并行工作，永不疲倦，随时待命。

**scrum-skills** 就是这样一个系统。它将敏捷开发方法论与AI多角色协作相结合，通过11个专业技能角色，模拟真实团队的工作方式。

开源地址：https://gitee.com/ajun816/scrum-skills.git

---

## 🚀 快速开始（3步上手）

### 第1步：复制到你的项目

```bash
cp -r skills /your-project/
```

就这么简单。无需安装、无需配置、无需学习。

### 第2步：开始使用

直接调用任何技能，第一次使用时会自动引导你初始化：

```
用户：@2-product-manager 帮我分析一下用户登录注册的需求

AI：🎯 检测到这是第一次使用技能组
    我会帮你快速初始化项目配置...
```

### 第3步：多角色协作

```
# 产品经理分析需求
@2-product-manager 分析用户登录注册需求

# 架构师设计方案
@3-system-architect 设计登录注册的架构方案

# 后端开发实现
@4-java-backend-dev 实现用户登录注册功能

# 前端开发实现
@4-vue-frontend-dev 实现登录注册页面

# 测试工程师验证
@5-webapp-testing 测试登录注册功能
```

---

## 🛠️ 使用 7-skill-creator 创建自己的技能

除了使用现有的11个技能角色，你还可以根据项目需要创建自定义技能。**7-skill-creator** 是一个强大的技能创建器，可以帮你快速创建符合敏捷团队技能组风格的新技能。

### 为什么需要创建自定义技能？

- **技术栈不同**：项目使用 React、Python、Flutter 等其他技术栈
- **特殊需求**：需要安全专家、数据分析师、性能优化专家等特定角色
- **业务特色**：需要针对特定业务领域的专家（如金融、医疗、电商）

### 如何使用 7-skill-creator？

#### 步骤1：调用技能创建器

```
@7-skill-creator 我想创建一个新技能
```

#### 步骤2：回答引导问题

技能创建器会引导你提供以下信息：

**1️⃣ 技能基本信息**
- **技能名称**：例如 `8-security-expert`（必须遵守命名规范：`{编号}-{英文名称}`）
- **中文名称**：例如 `安全专家`
- **技能职责**：简要描述，1-2句话

**命名规范：**
- **0** - 协调类（Scrum Master）
- **1-2** - 需求类（业务专家、产品经理）
- **3** - 架构类（系统架构师）
- **4** - 开发类（前端、后端、UI设计等）
- **5** - 质量类（测试、DevOps）
- **6** - 维护类（Bug处理）
- **7+** - 工具类或扩展类

**2️⃣ 技能使用场景**
- 列出3-5个典型使用场景

**3️⃣ 技能工作流程**
- 列出3-7个主要工作步骤

**4️⃣ 团队协作**
- 列出需要协作的其他技能

**5️⃣ 资源文件需求**
- 是否需要 scripts/（可执行脚本）
- 是否需要 references/（参考文档）
- 是否需要 assets/（资源文件）

#### 步骤3：自动生成技能

技能创建器会自动生成：

```
skills/8-security-expert/
├── SKILL.md              # 技能主文件
├── scripts/              # 可执行脚本（如需要）
├── references/           # 参考文档（如需要）
└── assets/               # 资源文件（如需要）
```

生成的技能自动包含：
- ✅ 标准的执行流程
- ✅ 数据验证机制（防止AI幻觉）
- ✅ 团队协作机制
- ✅ 缓存优化机制（节约70-80% Token）
- ✅ 中文输出规范

#### 步骤4：测试和使用

```
# 测试新技能
@8-security-expert 帮我进行安全评估

# 新技能会自动集成到技能组系统中
# 可以与其他技能协作
```

### 创建技能示例

**示例1：创建 React 前端开发技能**

```
@7-skill-creator 我想创建一个 React 前端开发技能

技能名称：4-react-frontend-dev
中文名称：React前端开发
职责：负责使用React + TypeScript开发前端应用
使用场景：
- React组件开发
- 页面实现
- 状态管理
- 前端性能优化
工作步骤：
1. 需求分析
2. 设计组件结构
3. 编码实现
4. 测试验证
协作技能：2-product-manager, 3-system-architect, 4-java-backend-dev
资源需求：references/（代码模板、最佳实践）
```

**示例2：创建安全专家技能**

```
@7-skill-creator 我想创建一个安全专家技能

技能名称：8-security-expert
中文名称：安全专家
职责：负责系统安全评估、漏洞扫描、安全加固和安全培训
使用场景：
- 需要进行安全评估时
- 发现安全漏洞需要修复时
- 需要制定安全规范时
工作步骤：
1. 分析安全需求
2. 执行安全扫描
3. 评估风险等级
4. 制定修复方案
5. 验证修复效果
协作技能：3-system-architect, 4-java-backend-dev, 5-devops-engineer
资源需求：references/（安全规范、最佳实践）
```

### 技能创建的核心优势

1. **风格统一**：所有技能遵循相同的结构和规范
2. **标准完整**：自动集成执行标准、数据验证、团队协作等机制
3. **易于维护**：清晰的结构和文档，便于后续优化
4. **高效协作**：内置团队协作机制，促进技能间配合
5. **性能优化**：自动包含缓存机制，节约Token消耗

### 优化现有技能

如果你想优化已有的技能：

```
@7-skill-creator 帮我优化 4-java-backend-dev 技能
```

说明需要优化的方面，技能创建器会帮你改进。

---

## 💡 核心价值

### 1. 配置驱动，节约70-80% Token

传统方式下，每个AI角色都需要重复读取项目文档，消耗大量Token。本系统通过统一的 `PROJECT_CONFIG.md` 配置文件，让所有技能共享项目上下文，节约70-80%的Token消耗。

**传统方式：**
- 产品经理读取架构文档：48000 tokens
- 架构师读取架构文档：48000 tokens
- 开发人员读取架构文档：48000 tokens
- 总计：144000 tokens

**配置驱动：**
- 所有角色共享配置：10000 tokens
- 节约：134000 tokens (93%)

### 3. 防止AI幻觉的数据验证标准

AI最大的问题是什么？**幻觉**——编造不存在的信息。

本系统通过严格的数据验证标准解决这个问题：

- ✅ **Read-First原则**：所有回答前必须先读取文件验证
- ✅ **Source Traceability**：每个回答必须标注数据来源（文件路径:行号）
- ✅ **Uncertainty Declaration**：数据不存在时明确说明，绝不编造
- ✅ **Verification Visibility**：验证步骤实时显示给用户

### 4. 上下文质量监控

AI对话越长，回复质量越差。本系统自动监控对话Token长度，达到警告阈值时主动提醒用户重启对话，确保始终获得最高质量回复。

**质量等级：**
- ⭐⭐⭐⭐⭐ 最佳 (0-50K tokens)
- ⭐⭐⭐⭐ 良好 (50K-100K tokens)
- ⭐⭐⭐ 可接受 (100K-150K tokens)
- ⭐⭐ 警告 (150K-180K tokens) - **建议重启**
- ⭐ 临界 (180K-200K tokens) - **强烈建议重启**

### 5. 团队共享文档机制

避免重复劳动，一次产出多次使用：

```
产品经理产出需求文档 → 保存到 skills/.cache/shared/requirements/
架构师读取需求文档 → 产出架构设计 → 保存到 skills/.cache/shared/architecture/
开发人员读取需求和架构 → 开始编码
测试人员读取需求 → 编写测试用例
```

## 🏗️ 项目架构

### 技能组织结构

```
skills/
├── 0-scrum-master/          # 协调层：敏捷教练
├── 1-business-expert/       # 业务层：业务专家
├── 2-product-manager/       # 业务层：产品经理
├── 3-system-architect/      # 架构层：系统架构师
├── 4-java-backend-dev/      # 开发层：Java后端开发
├── 4-vue-frontend-dev/      # 开发层：Vue前端开发
├── 4-frontend-design/       # 开发层：前端视觉设计
├── 4-nielsen-ui-design/     # 开发层：UI/UX设计
├── 5-devops-engineer/       # 运维层：DevOps工程师
├── 5-webapp-testing/        # 测试层：Web应用测试
└── 6-bug-handler/           # 支持层：Bug处理专家
```

### 11个专业角色

| 编号 | 角色 | 职责 | 使用场景 |
|------|------|------|----------|
| 0 | 敏捷教练 | 组织敏捷仪式、移除障碍、促进协作 | 迭代计划、每日站会、回顾会议 |
| 1 | 业务专家 | 梳理业务流程、定义业务规则 | 业务需求分析、流程优化 |
| 2 | 产品经理 | 需求分析、用户故事、需求变更 | 需求文档、用户故事、优先级排序 |
| 3 | 系统架构师 | 架构设计、技术选型、任务拆解 | 架构设计、技术方案、任务分配 |
| 4 | Java后端开发 | 后端代码实现、API开发 | 业务逻辑、数据库设计、API开发 |
| 4 | Vue前端开发 | 前端页面开发、组件设计 | 页面开发、组件封装、状态管理 |
| 4 | 前端视觉设计 | 创意视觉设计、品牌形象 | UI设计、视觉规范、品牌设计 |
| 4 | UI/UX设计 | 基于尼尔森原则的可用性设计 | 交互设计、可用性测试、用户体验 |
| 5 | DevOps工程师 | CI/CD、自动化部署、监控 | 部署流程、监控告警、性能优化 |
| 5 | Web应用测试 | 自动化测试、功能验证 | 测试用例、自动化测试、回归测试 |
| 6 | Bug处理专家 | Bug分析、修复协调、验证 | Bug分析、修复方案、验证测试 |

### 核心机制

#### 1. 配置驱动模式

所有技能共享统一的 `PROJECT_CONFIG.md` 配置文件：

```yaml
project:
  name: "电商平台"
  description: "B2C在线购物平台"
  domain: "电子商务"

tech_stack:
  frontend:
    framework: "Vue 3"
    language: "TypeScript"
  backend:
    framework: "Spring Boot"
    language: "Java 17"
    architecture: "DDD"

business_domains:
  - product   # 商品管理
  - order     # 订单管理
  - user      # 用户管理
  - payment   # 支付管理
```

**优势：**
- 节约70-80% Token
- 确保所有技能使用统一的项目上下文
- 支持技能组在不同项目间迁移

#### 2. 智能缓存系统

```
skills/.cache/
├── shared/                  # 团队共享文档
│   ├── requirements/        # 需求文档
│   ├── architecture/        # 架构设计
│   ├── api-design/          # API设计
│   ├── test-plans/          # 测试计划
│   └── meeting-notes/       # 会议记录
└── {skill-name}/            # 各技能独立缓存
```

- 使用git diff识别变更
- 增量更新，节约Token
- 自动清理过期缓存

#### 3. 数据验证标准

防止AI幻觉的核心机制：

```markdown
## 📖 数据验证

正在读取文件验证数据...
✅ 文件：backend/src/main/java/com/shop/product/controller/ProductController.java
✅ 行号：23-45
✅ 数据来源：已验证

根据 ProductController.java:23-45，商品列表接口定义如下：
[具体内容]
```

#### 4. 上下文质量监控

自动监控对话质量，防止Token过长导致回复质量下降：

```markdown
## 📊 上下文质量监控

当前对话状态：
- 对话轮次：45
- Token使用：125000 / 200000
- 质量等级：⭐⭐⭐ 可接受
- 建议：继续使用，建议在完成当前任务后重启对话
```

#### 5. 自动初始化机制

第一次使用时自动检测并引导初始化：

```
🎯 检测到这是第一次使用技能组

我会帮你快速初始化项目配置，只需要回答几个简单问题：

1️⃣ 项目名称是什么？
   例如：电商平台、博客系统、CRM系统

2️⃣ 使用什么技术栈？
   前端：Vue 3 / React / Angular
   后端：Spring Boot / NestJS / Django

3️⃣ 主要业务模块有哪些？
   例如：商品管理、订单管理、用户管理
```

## 📚 使用场景

### 场景1：新功能开发

```
1. @2-product-manager 分析需求 → 产出需求文档
2. @3-system-architect 设计架构 → 产出架构设计
3. @4-java-backend-dev 实现后端 → 产出代码
4. @4-vue-frontend-dev 实现前端 → 产出代码
5. @5-webapp-testing 测试验证 → 产出测试报告
6. @5-devops-engineer 部署上线 → 完成发布
```

### 场景2：Bug修复

```
1. @6-bug-handler 分析Bug → 定位问题
2. @4-java-backend-dev 修复代码 → 提交修复
3. @5-webapp-testing 回归测试 → 验证修复
```

### 场景3：敏捷仪式

```
# 迭代计划会议
@0-scrum-master 组织迭代计划会议

# 每日站会
@0-scrum-master 组织每日站会

# 迭代回顾
@0-scrum-master 组织迭代回顾会议
```

## 🎨 技术亮点

### 1. DDD领域驱动设计

项目采用DDD架构，按业务域垂直切分：

```
backend/src/main/java/com/shop/
├── product/          # 商品域
│   ├── controller/   # API接口
│   ├── service/      # 业务逻辑
│   ├── domain/       # 领域模型
│   └── repository/   # 数据访问
├── order/            # 订单域
├── user/             # 用户域
└── payment/          # 支付域
```

**核心原则：**
- 依赖倒置：高层不依赖低层，都依赖抽象
- 单向依赖：只能从上层依赖下层，禁止反向依赖
- 领域纯净：Domain层不依赖任何外部框架
- 业务域隔离：域之间通过接口通信，不直接依赖

### 2. 分层架构

```
Controller层 → Service层 → Domain层
                ↓
           Repository层 → Infrastructure层
```

**职责划分：**
- **Controller层**：API接口、请求响应处理
- **Service层**：业务逻辑编排、事务管理
- **Domain层**：领域模型、业务规则（核心层，无外部依赖）
- **Repository层**：数据访问、持久化
- **Infrastructure层**：工具类、外部服务集成

### 3. 技术栈

**前端：**
- Vue 3 + TypeScript
- Element Plus UI组件库
- Pinia状态管理
- Vite构建工具

**后端：**
- Spring Boot + Java 17
- DDD领域驱动设计
- MySQL + Redis
- Maven构建工具

**DevOps：**
- Jenkins CI/CD
- Docker容器化
- Kubernetes编排

### 4. MCP工具集成

支持Model Context Protocol工具，实现自动化测试和开发辅助：

- 浏览器自动化测试（Playwright）
- Chrome DevTools
- 截图和录屏
- 网络监控
- 性能分析
- API测试
- 数据库工具
- 代码生成

## 🔧 高级功能

### 1. 开发环境配置

在 `PROJECT_CONFIG.md` 中配置开发环境：

```yaml
development_environment:
  database:
    mysql:
      host: "localhost"
      port: 3306
      database: "shop_db"
      username: "root"
      password: "your_password"

    redis:
      host: "localhost"
      port: 6379

  application:
    backend:
      port: 8080
    frontend:
      port: 5173
```

### 2. 任务隔离策略

多个技能实例并行工作时，通过任务隔离避免冲突：

**按模块隔离：**
```
开发1 → 商品模块
开发2 → 订单模块
开发3 → 用户模块
```

**按层次隔离：**
```
开发1 → Controller层
开发2 → Service层
开发3 → Repository层
```

**按优先级隔离：**
```
开发1 → P0高优先级任务
开发2 → P1中优先级任务
开发3 → P2低优先级任务
```

### 3. 增量更新机制

使用git diff识别变更，只更新修改的部分：

```bash
# 检测变更
git diff last_scan_commit..HEAD

# 只更新变更的文件
update_cache(changed_files)
```

## 📖 设计原则

1. **复制粘贴就能用**：skills目录是自包含的，无外部依赖
2. **自我引导**：第一次使用自动初始化
3. **配置驱动**：统一配置，所有技能共享
4. **数据验证**：防止AI幻觉，基于真实数据回答
5. **质量监控**：自动监控上下文，保证最高质量
6. **团队协作**：共享文档，避免重复劳动
7. **可迁移性**：支持在不同项目间迁移

## 🌟 最佳实践

### 1. 定期重启对话

建议每完成一个大任务后重启对话窗口，保持最佳性能：

```
完成商品模块开发 → 重启对话 → 开始订单模块开发
```

### 2. 及时响应质量提醒

看到质量警告时尽快重启：

```
⚠️ 上下文质量：⭐⭐ 警告
建议重启对话以获得最佳回复质量
```

### 3. 善用共享文档

让技能产出保存到共享目录，供其他技能使用：

```
产品经理：需求文档 → skills/.cache/shared/requirements/
架构师：架构设计 → skills/.cache/shared/architecture/
```

### 4. 并行执行提高效率

对于独立的任务，使用多个技能实例并行执行：

```
# 串行执行（慢）
开发商品模块 → 开发订单模块 → 开发用户模块

# 并行执行（快）
开发1：商品模块 | 开发2：订单模块 | 开发3：用户模块
```

### 5. 保持配置更新

项目变更时及时更新 `PROJECT_CONFIG.md`：

```bash
# 更新配置后清除缓存
rm -rf skills/.cache/
```

## 🔗 项目地址

**GitHub仓库：** https://github.com/your-username/scrum-skills

欢迎Star、Fork和贡献代码！

## 📝 迁移到新项目

```bash
# 1. 复制skills目录
cp -r /old-project/skills /new-project/

# 2. 删除旧配置
rm /new-project/skills/PROJECT_CONFIG.md
rm -rf /new-project/skills/.cache

# 3. 开始使用，自动引导初始化
```

---

## 总结

**scrum-skills** 是一个创新的AI协作框架，它将敏捷开发方法论与AI多角色协作相结合，通过配置驱动、数据验证、共享文档等机制，实现了一个可复用、高效、可靠的AI驱动敏捷团队框架。

**核心优势：**
- ✅ 复制粘贴即用，无需安装配置
- ✅ 节约70-80% Token，降低成本
- ✅ 防止AI幻觉，确保数据准确
- ✅ 自动质量监控，保证最佳回复
- ✅ 团队协作机制，避免重复劳动
- ✅ 支持并行执行，最大化效率

**适用场景：**
- 个人项目快速开发
- 团队协作效率提升
- 敏捷开发流程实践
- AI辅助编程学习
