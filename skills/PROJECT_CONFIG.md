# 项目配置文件

**本文件是技能组的统一入口和唯一真相来源（Single Source of Truth）**

---

## 🔍 初始化状态

```yaml
# 初始化标记（请勿手动修改）
initialized: true
initialized_at: "2024-02-12 16:00:00"
config_version: "1.0"

# 增量更新追踪
last_scan: "2024-02-12 16:00:00"
last_scan_commit: "0f35a3a"
last_updated: "2024-02-12 16:00:00"
```

**说明：**
- `initialized: true` - 表示配置已完成初始化
- `initialized_at` - 初始化时间
- `config_version` - 配置文件版本
- `last_scan` - 最后一次扫描项目的时间
- `last_scan_commit` - 最后一次扫描时的 git commit
- `last_updated` - 配置最后更新时间
- 如果是第一次使用，技能会自动引导你初始化
- 如需重新初始化，删除此文件或将 `initialized` 改为 `false`

---

## 核心价值

- ✅ 避免每个技能重复读取项目架构文档（节约70-80% token）
- ✅ 确保所有技能使用统一的项目上下文
- ✅ 提供项目核心信息的快速索引
- ✅ 支持技能组在不同项目间迁移
- ✅ 第一次使用自动引导初始化

---

## 项目基本信息

```yaml
project:
  name: "电商平台"
  description: "B2C在线购物平台，支持商品浏览、下单、支付、物流"
  domain: "电子商务"
  version: "1.0"
```

## 技术栈

```yaml
tech_stack:
  frontend:
    framework: "Vue 3"
    language: "TypeScript"
    ui_library: "Element Plus"
    state_management: "Pinia"
    build_tool: "Vite"

  backend:
    framework: "Spring Boot"
    language: "Java 17"
    architecture: "DDD (领域驱动设计)"
    build_tool: "Maven"
    database: "MySQL + Redis"

  devops:
    ci_cd: "Jenkins"
    container: "Docker"
    orchestration: "Kubernetes"
```

## 业务域

```yaml
business_domains:
  - name: "product"
    description: "商品管理 - 商品信息、分类、库存"

  - name: "order"
    description: "订单管理 - 下单、支付、退款"

  - name: "user"
    description: "用户管理 - 注册、登录、个人信息"

  - name: "payment"
    description: "支付管理 - 支付渠道、支付记录"

  - name: "logistics"
    description: "物流管理 - 发货、配送、物流跟踪"

  - name: "marketing"
    description: "营销管理 - 优惠券、促销活动"
```

## 团队角色映射

**本节定义团队角色与技能的映射关系，支持自定义配置**

```yaml
team_roles:
  # 核心角色（必需）
  scrum_master:
    skill_id: "0-scrum-master"
    display_name: "敏捷教练"
    description: "组织敏捷流程，协调团队，移除障碍"
    required: true

  # 业务和产品角色
  business_expert:
    skill_id: "1-business-expert"
    display_name: "业务专家"
    description: "澄清业务规则，提供领域知识"
    required: false

  product_manager:
    skill_id: "2-product-manager"
    display_name: "产品经理"
    description: "需求分析，用户故事编写"
    required: true

  # 技术架构角色
  system_architect:
    skill_id: "3-system-architect"
    display_name: "系统架构师"
    description: "架构设计，技术方案评审"
    required: true

  # 开发角色
  backend_developer:
    skill_id: "4-java-backend-dev"
    display_name: "后端开发"
    tech_stack: "Java + Spring Boot + DDD"
    description: "后端功能开发，API实现"
    required: true

  frontend_developer:
    skill_id: "4-vue-frontend-dev"
    display_name: "前端开发"
    tech_stack: "Vue 3 + TypeScript"
    description: "前端页面开发，组件实现"
    required: true

  ui_designer:
    skill_id: "4-frontend-design"
    display_name: "UI设计师"
    description: "UI设计审核，用户体验优化"
    required: false

  # 质量保障角色
  qa_engineer:
    skill_id: "5-webapp-testing"
    display_name: "测试工程师"
    description: "功能测试，自动化测试"
    required: true

  devops_engineer:
    skill_id: "5-devops-engineer"
    display_name: "DevOps工程师"
    description: "部署，运维，CI/CD"
    required: false

  # 支持角色
  bug_handler:
    skill_id: "6-bug-handler"
    display_name: "Bug处理专员"
    description: "Bug分析，问题修复"
    required: false

  skill_creator:
    skill_id: "7-skill-creator"
    display_name: "技能创建器"
    description: "创建新技能，扩展团队能力"
    required: false
```

### 技能自动发现机制

**Scrum Master 会自动扫描 `skills/` 目录，发现所有可用技能：**

```yaml
skill_discovery:
  # 自动发现配置
  enabled: true
  scan_directory: "skills/"
  skill_file_pattern: "*/SKILL.md"

  # 技能命名规范
  naming_convention:
    pattern: "{priority}-{role-name}"
    examples:
      - "0-scrum-master"     # 优先级0：协调角色
      - "1-business-expert"  # 优先级1：业务角色
      - "2-product-manager"  # 优先级2：产品角色
      - "3-system-architect" # 优先级3：架构角色
      - "4-*-dev"           # 优先级4：开发角色
      - "5-*"               # 优先级5：质量和运维角色
      - "6-bug-handler"     # 优先级6：支持角色
      - "7-skill-creator"   # 优先级7：工具角色

  # 技能元数据提取
  metadata_extraction:
    from_frontmatter: true
    fields:
      - "name"          # 技能ID
      - "description"   # 技能描述
      - "display_name"  # 显示名称（从描述中提取）
      - "tech_stack"    # 技术栈（如有）

  # 自动映射规则
  auto_mapping:
    enabled: true
    rules:
      - pattern: "0-*"
        role_type: "coordinator"
        required: true

      - pattern: "1-*"
        role_type: "business"
        required: false

      - pattern: "2-*"
        role_type: "product"
        required: true

      - pattern: "3-*"
        role_type: "architect"
        required: true

      - pattern: "4-*"
        role_type: "developer"
        required: true

      - pattern: "5-*"
        role_type: "quality"
        required: false

      - pattern: "6-*"
        role_type: "support"
        required: false

      - pattern: "7-*"
        role_type: "tool"
        required: false
```

### 自定义角色映射

**如需自定义角色映射，直接修改 `team_roles` 配置：**

1. **添加新角色**：在 `team_roles` 中添加新条目
2. **修改技能ID**：更改 `skill_id` 指向不同的技能
3. **调整显示名称**：修改 `display_name` 自定义显示
4. **设置必需性**：通过 `required` 控制是否必需

**示例：使用不同的后端技能**

```yaml
backend_developer:
  skill_id: "4-python-backend-dev"  # 改为Python后端
  display_name: "Python后端开发"
  tech_stack: "Python + FastAPI"
  description: "后端功能开发，API实现"
  required: true
```

## 项目结构

```yaml
project_structure:
  backend:
    root: "backend/"
    layers:
      - "controller/"      # 控制器层 (API接口)
      - "service/"         # 服务层 (业务逻辑)
      - "domain/"          # 领域层 (领域模型)
      - "repository/"      # 仓储层 (数据访问)
      - "infrastructure/"  # 基础设施层 (工具类)

  frontend:
    root: "frontend/"
    structure:
      - "src/views/"       # 页面
      - "src/components/"  # 组件
      - "src/composables/" # 组合式函数
      - "src/api/"         # API调用
      - "src/stores/"      # 状态管理
```

## 编码规范

```yaml
coding_standards:
  backend:
    principles:
      - "Clean Code"
      - "SOLID原则"
      - "DDD战术设计"
    notes: "编码规范文档可以在项目中自行创建和维护"

  frontend:
    principles:
      - "Vue 3 Composition API"
      - "TypeScript最佳实践"
      - "组件化设计"
    notes: "编码规范文档可以在项目中自行创建和维护"
```

---

## 项目架构概览

**本节提供项目架构的核心信息摘要，避免技能重复读取完整架构文档**

### 架构模式

```yaml
architecture:
  pattern: "DDD领域驱动设计 + 分层架构"
  description: |
    采用领域驱动设计(DDD)，按业务域垂直切分。
    每个业务域包含完整的分层结构，域之间通过接口通信。

  layers:
    - name: "Controller层"
      responsibility: "API接口、请求响应处理"
      dependencies: ["Service层"]

    - name: "Service层"
      responsibility: "业务逻辑编排、事务管理"
      dependencies: ["Domain层", "Repository层"]

    - name: "Domain层"
      responsibility: "领域模型、业务规则"
      dependencies: []  # 核心层，无外部依赖

    - name: "Repository层"
      responsibility: "数据访问、持久化"
      dependencies: ["Infrastructure层"]

    - name: "Infrastructure层"
      responsibility: "工具类、外部服务集成"
      dependencies: []

  key_principles:
    - "依赖倒置：高层不依赖低层，都依赖抽象"
    - "单向依赖：只能从上层依赖下层，禁止反向依赖"
    - "领域纯净：Domain层不依赖任何外部框架"
    - "业务域隔离：域之间通过接口通信，不直接依赖"
```

### 目录结构示例

```yaml
directory_structure:
  backend:
    pattern: "backend/src/main/java/com/shop/{domain}/{layer}/"
    example: "backend/src/main/java/com/shop/product/controller/"

  frontend:
    pattern: "frontend/src/{type}/"
    example: "frontend/src/views/product/"
```

## 核心业务规则

**本节提供关键业务规则摘要，技能可快速理解业务逻辑**

```yaml
business_rules:
  product:
    - "商品上架前必须审核通过"
    - "库存不足时自动下架"
    - "商品价格必须大于0"
    - "商品图片至少1张，最多10张"

  order:
    - "订单创建后30分钟内未支付自动取消"
    - "订单支付成功后不可取消，只能申请退款"
    - "订单金额 = 商品总价 + 运费 - 优惠"
    - "订单状态流转：待支付→已支付→已发货→已完成"

  user:
    - "手机号唯一，用于登录"
    - "密码必须包含字母和数字，长度8-20位"
    - "用户注册后默认为普通会员"
    - "连续登录失败5次锁定账号30分钟"

  payment:
    - "支持支付宝、微信、银行卡支付"
    - "支付失败自动重试3次"
    - "退款金额不能超过实付金额"
    - "退款到账时间：1-7个工作日"

  logistics:
    - "订单支付成功后24小时内发货"
    - "支持顺丰、圆通、中通等物流"
    - "物流信息实时同步"
    - "签收后7天内可申请退货"

  marketing:
    - "优惠券有使用期限和使用条件"
    - "同一订单只能使用一张优惠券"
    - "促销活动可叠加优惠券"
    - "会员等级越高，折扣越大"
```

## 关键文件索引

**本节提供重要文件的快速索引，根据实际项目结构自定义**

```yaml
key_files:
  # 示例：如果项目中有架构文档，可以在这里添加索引
  # architecture_docs:
  #   - path: "架构文档路径"
  #     description: "文档描述"
  #     when_to_read: "何时阅读"

  # 示例：如果项目中有编码规范文档，可以在这里添加索引
  # coding_standards:
  #   - path: "编码规范路径"
  #     description: "规范描述"
  #     when_to_read: "编写代码前必读"

  # 说明：此部分为可选配置，根据实际项目需要添加
  # 技能组不依赖这些文件，只是提供快速索引功能
```

## API端点概览

**本节提供主要API接口的快速参考**

```yaml
api_endpoints:
  base_url: "/api/v1"

  product:
    - endpoint: "GET /products"
      description: "商品列表（支持分页、筛选）"
      auth_required: false

    - endpoint: "GET /products/{id}"
      description: "商品详情"
      auth_required: false

    - endpoint: "POST /products"
      description: "创建商品（管理员）"
      auth_required: true

  order:
    - endpoint: "POST /orders"
      description: "创建订单"
      auth_required: true

    - endpoint: "GET /orders/{id}"
      description: "订单详情"
      auth_required: true

    - endpoint: "POST /orders/{id}/pay"
      description: "支付订单"
      auth_required: true

  user:
    - endpoint: "POST /users/register"
      description: "用户注册"
      auth_required: false

    - endpoint: "POST /users/login"
      description: "用户登录"
      auth_required: false

    - endpoint: "GET /users/profile"
      description: "获取个人信息"
      auth_required: true

  response_format:
    success: |
      {
        "code": 200,
        "message": "success",
        "data": { ... }
      }
    error: |
      {
        "code": 400/500,
        "message": "错误描述",
        "data": null
      }
```

## 数据模型概览

**本节提供核心数据模型的快速参考**

```yaml
data_models:
  Product:
    description: "商品"
    key_fields:
      - "id: Long - 商品ID"
      - "name: String - 商品名称"
      - "price: BigDecimal - 价格"
      - "stock: Integer - 库存"
      - "status: Enum - 状态（ON_SALE/OFF_SALE）"
      - "categoryId: Long - 分类ID"

  Order:
    description: "订单"
    key_fields:
      - "id: Long - 订单ID"
      - "orderNo: String - 订单号"
      - "userId: Long - 用户ID"
      - "totalAmount: BigDecimal - 订单总额"
      - "status: Enum - 状态（PENDING/PAID/SHIPPED/COMPLETED）"
      - "createTime: LocalDateTime - 创建时间"

  User:
    description: "用户"
    key_fields:
      - "id: Long - 用户ID"
      - "phone: String - 手机号（登录账号）"
      - "password: String - 密码（加密存储）"
      - "nickname: String - 昵称"
      - "level: Enum - 会员等级（NORMAL/VIP/SVIP）"

  Payment:
    description: "支付记录"
    key_fields:
      - "id: Long - 支付ID"
      - "orderId: Long - 订单ID"
      - "amount: BigDecimal - 支付金额"
      - "paymentMethod: Enum - 支付方式（ALIPAY/WECHAT/BANK）"
      - "status: Enum - 状态（PENDING/SUCCESS/FAILED）"

  relationships:
    - "Order N:1 User"
    - "Order 1:N OrderItem"
    - "OrderItem N:1 Product"
    - "Order 1:1 Payment"
```

## 技术约束和规范

**本节定义必须遵守的技术约束，确保代码一致性**

```yaml
technical_constraints:
  backend:
    naming_conventions:
      - "Controller类：{Entity}Controller"
      - "Service类：{Entity}Service"
      - "Repository接口：{Entity}Repository"
      - "DTO类：{Entity}DTO"
      - "实体类：{Entity}（无后缀）"

    code_rules:
      - "单文件不超过500行"
      - "方法不超过50行"
      - "Controller只做参数验证和响应封装"
      - "Service层处理业务逻辑"
      - "统一使用ApiResponse<T>封装响应"

    response_handling:
      - "成功：ApiResponse.success(data)"
      - "失败：ApiResponse.error(code, message)"
      - "Controller不做try-catch，由全局异常处理器处理"

  frontend:
    naming_conventions:
      - "组件文件：PascalCase.vue"
      - "composables：use{Name}.ts"
      - "API文件：{domain}Api.ts"
      - "Store：{domain}Store.ts"

    code_rules:
      - "优先使用Composition API"
      - "组件不超过300行"
      - "业务逻辑提取到composables"
      - "API调用统一封装"

  database:
    - "表名：snake_case"
    - "字段名：snake_case"
    - "主键：id (BIGINT AUTO_INCREMENT)"
    - "时间字段：created_at, updated_at"
    - "软删除：deleted_at"

  api_design:
    - "RESTful风格"
    - "URL使用小写，单词用连字符分隔"
    - "版本号：/api/v1/"
    - "分页参数：page, size"
    - "排序参数：sort=field,direction"
```

---

## Definition of Done (DoD)

**本节定义统一的完成标准，确保交付质量**

### 用户故事级别 DoD

**一个用户故事被认为"完成"，必须满足以下所有条件：**

```yaml
story_dod:
  requirements:
    - name: "验收标准满足"
      description: "所有验收标准都已实现并验证通过"
      checked_by: "Product Manager"

    - name: "代码已实现"
      description: "功能代码已完成，符合架构设计"
      checked_by: "Developer"

    - name: "代码已审查"
      description: "代码通过同行评审或架构师审查"
      checked_by: "System Architect"

    - name: "单元测试通过"
      description: "单元测试覆盖率 ≥ 80%，所有测试通过"
      checked_by: "Developer"

    - name: "集成测试通过"
      description: "API集成测试通过，接口契约验证通过"
      checked_by: "Tester"

    - name: "UI审核通过"
      description: "前端页面符合Nielsen十大可用性原则"
      checked_by: "UI Designer"

    - name: "文档已更新"
      description: "API文档、技术文档已更新"
      checked_by: "Developer"

    - name: "无已知缺陷"
      description: "无P0/P1级别缺陷，P2缺陷已记录"
      checked_by: "Tester"

    - name: "性能达标"
      description: "响应时间、并发量等性能指标达标"
      checked_by: "Tester"

    - name: "安全检查通过"
      description: "无SQL注入、XSS等安全漏洞"
      checked_by: "System Architect"

    - name: "代码已合并"
      description: "代码已合并到主分支"
      checked_by: "Developer"

    - name: "部署到测试环境"
      description: "功能已部署到测试环境并可演示"
      checked_by: "DevOps"
```

### 迭代级别 DoD

**一个迭代被认为"完成"，必须满足以下所有条件：**

```yaml
sprint_dod:
  requirements:
    - name: "所有承诺的用户故事完成"
      description: "所有承诺的用户故事都满足Story DoD"
      checked_by: "Scrum Master"

    - name: "迭代目标达成"
      description: "迭代目标已实现"
      checked_by: "Product Manager"

    - name: "回归测试通过"
      description: "完整的回归测试套件通过"
      checked_by: "Tester"

    - name: "演示环境就绪"
      description: "演示环境已准备好，可以进行迭代评审"
      checked_by: "DevOps"

    - name: "文档已更新"
      description: "用户手册、发布说明已更新"
      checked_by: "Product Manager"

    - name: "技术债务已记录"
      description: "新增技术债务已记录到Product Backlog"
      checked_by: "System Architect"

    - name: "速率已更新"
      description: "团队速率数据已更新"
      checked_by: "Scrum Master"

    - name: "燃尽图已完成"
      description: "迭代燃尽图已完成并分析"
      checked_by: "Scrum Master"
```

### 发布级别 DoD

**一个版本被认为"可发布"，必须满足以下所有条件：**

```yaml
release_dod:
  requirements:
    - name: "所有功能完成"
      description: "所有计划功能都满足Story DoD"
      checked_by: "Product Manager"

    - name: "端到端测试通过"
      description: "完整的端到端测试场景通过"
      checked_by: "Tester"

    - name: "性能测试通过"
      description: "压力测试、负载测试达标"
      checked_by: "Tester"

    - name: "安全测试通过"
      description: "安全扫描、渗透测试通过"
      checked_by: "Security Expert"

    - name: "用户验收测试通过"
      description: "UAT测试通过，用户签字确认"
      checked_by: "Product Manager"

    - name: "生产环境就绪"
      description: "生产环境配置完成，部署脚本验证通过"
      checked_by: "DevOps"

    - name: "回滚方案就绪"
      description: "回滚方案已准备并验证"
      checked_by: "DevOps"

    - name: "监控告警配置"
      description: "生产监控和告警已配置"
      checked_by: "DevOps"

    - name: "发布文档完整"
      description: "发布说明、用户手册、运维手册完整"
      checked_by: "Product Manager"

    - name: "培训已完成"
      description: "用户培训、运维培训已完成"
      checked_by: "Product Manager"

    - name: "发布审批通过"
      description: "发布变更已通过审批流程"
      checked_by: "Release Manager"
```

### DoD 检查清单模板

**用于实际工作中检查DoD的模板：**

```markdown
## ✅ Definition of Done 检查清单

### 用户故事：{story_title}

**Story ID：** {story_id}
**负责人：** {owner}
**检查日期：** {date}

#### 验收标准
- [ ] 验收标准1：{description}
- [ ] 验收标准2：{description}
- [ ] 验收标准3：{description}

#### 代码质量
- [ ] 代码已实现
- [ ] 代码已审查（审查人：{reviewer}）
- [ ] 单元测试通过（覆盖率：{coverage}%）
- [ ] 编码规范检查通过

#### 测试
- [ ] 集成测试通过
- [ ] UI审核通过（审核人：{reviewer}）
- [ ] 无P0/P1缺陷
- [ ] 性能测试通过

#### 安全和文档
- [ ] 安全检查通过
- [ ] API文档已更新
- [ ] 技术文档已更新

#### 部署
- [ ] 代码已合并到主分支
- [ ] 已部署到测试环境
- [ ] 演示环境可用

**DoD状态：** ✅ 完成 / ⏳ 进行中 / ❌ 未完成

**备注：**
{notes}
```

### DoD 使用指南

**何时检查DoD：**

1. **开发过程中**
   - 开发人员自检：完成编码后
   - 代码审查时：审查人检查
   - 测试时：测试人员检查

2. **迭代评审前**
   - Scrum Master检查所有用户故事的DoD
   - 只有满足DoD的故事才能在评审会上演示

3. **迭代结束时**
   - 检查迭代级别DoD
   - 记录未完成的DoD项，作为技术债务

4. **发布前**
   - 检查发布级别DoD
   - 所有条件满足才能发布

**DoD 不满足时的处理：**

```yaml
dod_violation_handling:
  story_level:
    - action: "标记为未完成"
    - consequence: "不计入本迭代速率"
    - next_step: "移到下一迭代或Product Backlog"

  sprint_level:
    - action: "记录未完成项"
    - consequence: "影响迭代目标达成"
    - next_step: "在回顾会上讨论原因和改进"

  release_level:
    - action: "延迟发布"
    - consequence: "不能发布到生产环境"
    - next_step: "制定补救计划，重新评估发布时间"
```

### DoD 持续改进

**在迭代回顾会上讨论：**

1. **DoD是否合理？**
   - 是否过于严格或宽松？
   - 是否需要增加或删除某些条件？

2. **DoD执行情况如何？**
   - 哪些条件经常不满足？
   - 原因是什么？如何改进？

3. **DoD是否需要更新？**
   - 随着团队成熟度提高，提高DoD标准
   - 根据项目阶段调整DoD（如MVP阶段可适当放宽）

**DoD版本管理：**

```yaml
dod_version_history:
  v1.0:
    date: "2024-01-01"
    changes: "初始版本"

  v1.1:
    date: "2024-02-01"
    changes: "增加性能测试要求"

  v1.2:
    date: "2024-03-01"
    changes: "提高单元测试覆盖率要求从70%到80%"
```

## 依赖关系图

```yaml
dependencies:
  backend_layers:
    Controller:
      depends_on: ["Service"]
      depended_by: []

    Service:
      depends_on: ["Domain", "Repository"]
      depended_by: ["Controller"]

    Domain:
      depends_on: []  # 核心层，无依赖
      depended_by: ["Service", "Repository"]

    Repository:
      depends_on: ["Infrastructure"]
      depended_by: ["Service"]

    Infrastructure:
      depends_on: []
      depended_by: ["Repository"]

  business_domains:
    product:
      depends_on: []
      depended_by: ["order"]

    order:
      depends_on: ["product", "user", "payment"]
      depended_by: []

    user:
      depends_on: []
      depended_by: ["order"]

    payment:
      depends_on: []
      depended_by: ["order"]

    logistics:
      depends_on: ["order"]
      depended_by: []
```

---

## 开发环境配置

**本节提供开发和调试所需的环境配置信息**

```yaml
development_environment:
  # 数据库配置
  database:
    mysql:
      enabled: true
      host: "localhost"
      port: 3306
      database: "shop_db"
      username: "root"
      password: "your_password_here"  # 请修改为实际密码
      charset: "utf8mb4"
      timezone: "Asia/Shanghai"

    redis:
      enabled: true
      host: "localhost"
      port: 6379
      password: ""  # 如果Redis设置了密码，请填写
      database: 0

  # 应用配置
  application:
    backend:
      host: "localhost"
      port: 8080
      context_path: "/api"

    frontend:
      host: "localhost"
      port: 5173
      proxy_target: "http://localhost:8080"

  # 第三方服务配置
  external_services:
    # 支付服务
    payment:
      alipay:
        enabled: false
        app_id: ""
        private_key: ""
        public_key: ""

      wechat:
        enabled: false
        app_id: ""
        mch_id: ""
        api_key: ""

    # 短信服务
    sms:
      enabled: false
      provider: "aliyun"  # aliyun/tencent
      access_key: ""
      secret_key: ""

    # 对象存储
    oss:
      enabled: false
      provider: "aliyun"  # aliyun/qiniu/aws
      bucket: ""
      access_key: ""
      secret_key: ""

  # 日志配置
  logging:
    level: "INFO"  # DEBUG/INFO/WARN/ERROR
    file_path: "logs/application.log"
    max_file_size: "10MB"
    max_history: 30
```

**配置说明：**
- 🔒 **安全提示**：请勿将真实密码提交到版本控制系统
- 📝 **使用方式**：技能可以读取这些配置进行开发和调试
- 🔧 **自定义配置**：根据实际项目需求修改配置项

---

## MCP工具配置

**本节配置Model Context Protocol (MCP) 工具，用于自动化测试和开发辅助**

```yaml
mcp_tools:
  # 浏览器自动化测试工具
  browser_automation:
    enabled: true
    tool_name: "playwright"  # playwright/puppeteer/selenium
    browser: "chromium"      # chromium/firefox/webkit
    headless: true
    viewport:
      width: 1920
      height: 1080
    timeout: 30000  # 毫秒

  # Chrome DevTools Protocol
  chrome_devtools:
    enabled: true
    remote_debugging_port: 9222
    user_data_dir: ".chrome-profile"

  # 截图和录屏
  screenshot:
    enabled: true
    output_dir: "screenshots/"
    full_page: true

  # 网络监控
  network_monitor:
    enabled: true
    capture_requests: true
    capture_responses: true

  # 性能分析
  performance:
    enabled: true
    metrics:
      - "FCP"  # First Contentful Paint
      - "LCP"  # Largest Contentful Paint
      - "TTI"  # Time to Interactive
      - "TBT"  # Total Blocking Time

  # API测试工具
  api_testing:
    enabled: true
    base_url: "http://localhost:8080/api/v1"
    auth_token: ""  # 如需要，填写测试用token
    timeout: 10000

  # 数据库工具
  database_tools:
    enabled: true
    auto_backup: true
    backup_dir: "backups/"

  # 代码生成工具
  code_generation:
    enabled: true
    templates_dir: "templates/"
    output_dir: "generated/"
```

**MCP工具使用说明：**

1. **浏览器自动化测试**
   - 技能：`5-webapp-testing`
   - 用途：自动化UI测试、功能验证、截图对比
   - 配置：根据需要调整浏览器类型和视口大小

2. **API测试**
   - 技能：`4-java-backend-dev`、`5-webapp-testing`
   - 用途：API接口测试、性能测试、压力测试
   - 配置：设置正确的base_url和auth_token

3. **数据库工具**
   - 技能：`4-java-backend-dev`、`6-bug-handler`
   - 用途：数据库备份、数据迁移、数据修复
   - 配置：启用auto_backup确保数据安全

4. **代码生成**
   - 技能：`3-system-architect`、`4-java-backend-dev`、`4-vue-frontend-dev`
   - 用途：根据模板生成代码、减少重复工作
   - 配置：提供模板目录和输出目录

**技能调用MCP工具的标准流程：**

```markdown
## 🔧 调用MCP工具

### 步骤1：检查工具配置
正在读取MCP工具配置...
✅ 工具：{tool_name}
✅ 状态：{enabled}
✅ 配置：已加载

### 步骤2：执行工具操作
正在执行：{operation}...
✅ 完成

### 步骤3：处理结果
{结果描述}
```

---

## 上下文质量监控配置

**本节配置AI对话上下文质量监控，防止AI幻觉，确保最高质量回复**

```yaml
context_quality_monitoring:
  # 基本配置
  enabled: true
  model: "claude-sonnet-4-5"
  max_context_tokens: 200000

  # 质量阈值（基于实际使用经验）
  thresholds:
    optimal: 50000      # 最佳质量区间 (0-50K tokens) ⭐⭐⭐⭐⭐
    good: 100000        # 良好质量区间 (50K-100K tokens) ⭐⭐⭐⭐
    acceptable: 150000  # 可接受区间 (100K-150K tokens) ⭐⭐⭐
    warning: 180000     # 警告区间 (150K-180K tokens) ⭐⭐
    critical: 200000    # 临界区间 (180K-200K tokens) ⭐

  # 自动提醒配置
  auto_reminder:
    enabled: true
    check_frequency: 10           # 每10轮对话检查一次
    show_warning: true            # 达到警告阈值时提醒
    show_critical: true           # 达到临界阈值时强烈建议重启
    suggest_restart: true         # 建议重启对话窗口

  # 统计信息（自动更新）
  statistics:
    conversation_turns: 0         # 对话轮次
    tool_calls: 0                 # 工具调用次数
    file_reads: 0                 # 文件读取次数
    code_blocks: 0                # 代码块数量
    estimated_tokens: 0           # 估算Token数
    last_check: null              # 上次检查时间
    quality_level: "optimal"      # 当前质量等级
```

**质量监控说明：**

1. **自动监控**
   - 所有技能在执行任务时自动检查上下文长度
   - 根据Token使用情况评估回复质量等级
   - 达到警告阈值时主动提醒用户

2. **质量等级**
   - ⭐⭐⭐⭐⭐ 最佳 (0-50K)：响应快速、准确度高、无遗忘
   - ⭐⭐⭐⭐ 良好 (50K-100K)：响应正常、准确度高
   - ⭐⭐⭐ 可接受 (100K-150K)：响应稍慢、建议定期总结
   - ⭐⭐ 警告 (150K-180K)：响应变慢、可能遗忘、**建议重启**
   - ⭐ 临界 (180K-200K)：响应很慢、频繁遗忘、**强烈建议重启**

3. **重启对话的好处**
   - 恢复最佳性能：新对话窗口从0开始，AI处于最佳状态
   - 提高准确度：避免遗忘和混淆，回答更准确
   - 加快响应速度：减少上下文处理时间
   - 防止幻觉：降低AI编造信息的风险
   - 不丢失进度：项目配置自动加载，无缝继续工作

4. **用户使用建议**
   - 定期重启：建议每完成一个大任务后重启对话
   - 及时响应提醒：看到警告时尽快重启
   - 保存进度：重启前确保代码已保存
   - 信任机制：相信技能组会自动加载配置

**详细监控机制参考：** `skills/.context-quality-monitor.md`

---

## 技能标准初始化流程

**所有技能在执行任务前必须遵循以下初始化流程：**

### 第一步：读取项目配置（必需）

```markdown
## 🚀 初始化：读取项目配置

读取 `PROJECT_CONFIG.md` 获取项目上下文：

✅ 项目信息：{{PROJECT.name}} - {{PROJECT.description}}
✅ 专业领域：{{PROJECT.domain}}
✅ 技术栈：{{TECH_STACK.frontend.framework}} + {{TECH_STACK.backend.framework}}
✅ 架构模式：{{TECH_STACK.backend.architecture}}
✅ 业务域：{{BUSINESS_DOMAINS}}
✅ 团队角色：已加载
✅ 架构概览：已加载
✅ 核心业务规则：已加载
✅ 技术约束：已加载

**配置加载完成，开始执行任务...**
```

### 第二步：验证配置完整性

```markdown
## ✅ 配置验证

- [x] 项目基本信息已定义
- [x] 技术栈已配置
- [x] 业务域已定义
- [x] 团队角色已映射
- [x] 架构概览已加载

配置验证通过 ✅
```

### 第三步：开始执行任务

```markdown
## 🎯 准备就绪

✅ 项目上下文已加载
✅ 开始执行任务
```

## Token优化效果

**传统方式：** 每个技能读取完整文档 = 48000 tokens
**配置驱动：** 所有技能共享配置 = 10000 tokens
**节约：** 38000 tokens (79%)

---

## 配置文件维护

**何时更新配置文件：**
- ✅ 项目信息变更
- ✅ 技术栈升级
- ✅ 新增或删除业务域
- ✅ 核心业务规则变更
- ✅ API接口变更

**更新后清除缓存：**
```bash
rm -rf team-memory/shared/*/
```
