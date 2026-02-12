# 项目配置文件模板

**本文件是技能组的统一入口 - 复制此模板并填入你的项目信息即可使用**

## 快速开始

1. 复制本文件：`cp PROJECT_CONFIG.template.md PROJECT_CONFIG.md`
2. 填写下面的配置项（标记⚠️的为必填）
3. 技能组自动读取配置，开始工作

---

## ⚠️ 项目基本信息（必填）

```yaml
project:
  name: "你的项目名称"                    # 例如：电商平台、博客系统、CRM系统
  description: "项目简短描述"             # 一句话说明项目是做什么的
  domain: "所属领域"                      # 例如：电子商务、内容管理、企业管理
  version: "1.0"                         # 项目版本号
```

**示例（电商系统）：**
```yaml
project:
  name: "电商平台"
  description: "B2C在线购物平台，支持商品浏览、下单、支付、物流"
  domain: "电子商务"
  version: "1.0"
```

---

## ⚠️ 技术栈（必填）

```yaml
tech_stack:
  frontend:
    framework: "前端框架"               # 例如：Vue 3、React、Angular
    language: "编程语言"                # 例如：TypeScript、JavaScript

  backend:
    framework: "后端框架"               # 例如：Spring Boot、NestJS、Django
    language: "编程语言"                # 例如：Java、TypeScript、Python
    architecture: "架构模式"            # 例如：DDD、微服务、分层架构

  database: "数据库"                    # 例如：MySQL、PostgreSQL、MongoDB
```

**示例（电商系统）：**
```yaml
tech_stack:
  frontend:
    framework: "Vue 3"
    language: "TypeScript"

  backend:
    framework: "Spring Boot"
    language: "Java"
    architecture: "DDD领域驱动设计"

  database: "MySQL + Redis"
```

---

## ⚠️ 业务域（必填）

**列出项目的主要业务模块**

```yaml
business_domains:
  - name: "模块名称"
    description: "模块说明"
```

**示例（电商系统）：**
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
```

**示例（博客系统）：**
```yaml
business_domains:
  - name: "article"
    description: "文章管理 - 发布、编辑、分类"

  - name: "comment"
    description: "评论管理 - 评论、回复、审核"

  - name: "user"
    description: "用户管理 - 注册、登录、个人主页"
```

---

## 团队角色（可选，使用默认配置）

**如果你的团队结构与默认配置不同，可以修改这里**

```yaml
team_roles:
  scrum_master:
    skill_id: "0-scrum-master"
    display_name: "敏捷教练"

  product_manager:
    skill_id: "2-product-manager"
    display_name: "产品经理"

  system_architect:
    skill_id: "3-system-architect"
    display_name: "系统架构师"

  backend_developer:
    skill_id: "4-backend-dev"              # 根据技术栈修改
    display_name: "后端开发"

  frontend_developer:
    skill_id: "4-frontend-dev"             # 根据技术栈修改
    display_name: "前端开发"

  qa_engineer:
    skill_id: "5-testing"
    display_name: "测试工程师"
```

---

## 项目结构（可选）

**如果你的项目结构与标准结构不同，可以修改这里**

```yaml
project_structure:
  backend:
    root: "后端代码根目录"               # 例如：backend/、api/、server/

  frontend:
    root: "前端代码根目录"               # 例如：frontend/、web/、client/
```

**示例：**
```yaml
project_structure:
  backend:
    root: "backend/"

  frontend:
    root: "frontend/"
```

---

## 核心业务规则（可选，建议填写）

**列出项目的关键业务规则，帮助技能理解业务逻辑**

```yaml
business_rules:
  模块名称:
    - "规则1"
    - "规则2"
```

**示例（电商系统）：**
```yaml
business_rules:
  product:
    - "商品上架前必须审核通过"
    - "库存不足时自动下架"
    - "商品价格必须大于0"

  order:
    - "订单创建后30分钟内未支付自动取消"
    - "订单支付成功后不可取消，只能申请退款"
    - "订单金额 = 商品总价 + 运费 - 优惠"

  payment:
    - "支持支付宝、微信、银行卡支付"
    - "支付失败自动重试3次"
    - "退款金额不能超过实付金额"
```

---

## 技术约束（可选，建议填写）

**定义项目的编码规范和技术约束**

```yaml
technical_constraints:
  backend:
    - "统一使用RESTful API"
    - "统一响应格式：{code, message, data}"
    - "异常统一处理，不在Controller层try-catch"

  frontend:
    - "组件文件使用PascalCase命名"
    - "API调用统一封装"
    - "状态管理使用[Pinia/Redux/Vuex]"
```

---

## 配置完成

✅ 保存此文件为 `PROJECT_CONFIG.md`
✅ 技能组会自动读取配置
✅ 开始使用技能组工作

**如需帮助，查看：**
- `README.md` - 技能组使用指南
- `PROJECT_CONFIG.md` - 查看完整配置示例
