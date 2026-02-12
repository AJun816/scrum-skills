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

```yaml
team_roles:
  scrum_master:
    skill_id: "0-scrum-master"
    display_name: "敏捷教练"

  business_expert:
    skill_id: "1-business-expert"
    display_name: "业务专家"

  product_manager:
    skill_id: "2-product-manager"
    display_name: "产品经理"

  system_architect:
    skill_id: "3-system-architect"
    display_name: "系统架构师"

  backend_developer:
    skill_id: "4-backend-dev"
    display_name: "后端开发"
    tech_stack: "Java + Spring Boot + DDD"

  frontend_developer:
    skill_id: "4-frontend-dev"
    display_name: "前端开发"
    tech_stack: "Vue 3 + TypeScript"

  qa_engineer:
    skill_id: "5-testing"
    display_name: "测试工程师"

  devops_engineer:
    skill_id: "5-devops"
    display_name: "DevOps工程师"

  bug_handler:
    skill_id: "6-bug-handler"
    display_name: "Bug处理专员"
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
