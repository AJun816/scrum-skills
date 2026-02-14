# 敏捷团队技能组

**复制此目录到你的项目，直接使用！**

## ✨ 核心特性

- ✅ **复制粘贴即用**：无需安装、无需配置、无需学习
- ✅ **自动初始化**：第一次使用自动引导配置
- ✅ **配置驱动**：统一配置文件，所有技能共享
- ✅ **智能缓存**：节约70-80% Token，提高响应速度
- ✅ **数据验证**：防止AI幻觉，所有回答基于真实数据
- ✅ **质量监控**：自动监控上下文长度，保证最高质量回复
- ✅ **团队协作**：技能产出共享，避免重复劳动

## 快速开始

### 1. 复制到你的项目

```bash
cp -r skills /your-project/
```

### 2. 开始使用

直接调用任何技能，第一次使用时会自动引导你初始化。

**示例：**
```
用户：@0-scrum-master 帮我组织一次迭代计划会议
```

**自动引导：**
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

回答这3个问题后，我会自动生成配置文件，然后就可以开始工作了！
```

## 文件说明

```
skills/
├── PROJECT_CONFIG.md              # 项目配置（自动生成）
├── PROJECT_CONFIG.template.md     # 配置模板（参考）
├── README.md                      # 使用指南（本文件）
│
├── .cache/                        # 缓存目录（自动生成）
│   ├── shared/                    # 团队共享文档
│   └── {skill-name}/              # 各技能缓存
│
├── .context-quality-monitor.md    # 上下文质量监控机制
├── .data-verification-standard.md # 数据验证标准
├── .execution-visibility.md       # 执行可见性标准
├── .init-detection.md             # 初始化检测机制
├── .init-guide.md                 # 初始化指南
├── .skill-config-advisor.md       # 技能配置建议
├── .skill-execution-standard.md   # 技能执行标准
├── .team-shared-docs.md           # 团队共享文档机制
│
├── 0-scrum-master/                # 敏捷教练
├── 1-business-expert/             # 业务专家
├── 2-product-manager/             # 产品经理
├── 3-system-architect/            # 系统架构师
├── 4-java-backend-dev/            # Java后端开发
├── 4-vue-frontend-dev/            # Vue前端开发
├── 4-nielsen-ui-design/           # UI/UX设计（尼尔森原则）
├── 4-frontend-design/             # 前端视觉设计
├── 5-devops-engineer/             # DevOps工程师
├── 5-webapp-testing/              # Web应用测试
└── 6-bug-handler/                 # Bug处理专家
```

## 技能列表

| 技能 | 说明 | 使用场景 |
|------|------|----------|
| 0-scrum-master | 敏捷教练 | 组织敏捷仪式、协调团队、移除障碍 |
| 1-business-expert | 业务专家 | 梳理业务流程、定义业务规则 |
| 2-product-manager | 产品经理 | 需求分析、用户故事、需求变更 |
| 3-system-architect | 系统架构师 | 架构设计、技术选型、任务拆解 |
| 4-java-backend-dev | Java后端开发 | 后端代码实现、API开发 |
| 4-vue-frontend-dev | Vue前端开发 | 前端页面开发、组件设计 |
| 4-nielsen-ui-design | UI/UX设计 | 基于尼尔森原则的可用性设计 |
| 4-frontend-design | 前端视觉设计 | 创意视觉设计、品牌形象 |
| 5-devops-engineer | DevOps工程师 | CI/CD、自动化部署、监控 |
| 5-webapp-testing | Web应用测试 | 自动化测试、功能验证 |
| 6-bug-handler | Bug处理专家 | Bug分析、修复协调、验证 |

## 核心机制

### 1. 配置驱动

所有技能读取 `PROJECT_CONFIG.md` 获取项目信息：
- 项目名称和描述
- 技术栈配置
- 业务域定义
- 架构概览
- 核心业务规则
- 开发环境配置（MySQL、Redis等）
- MCP工具配置
- 上下文质量监控配置

**优势：**
- 节约 70-80% Token
- 确保所有技能使用统一的项目上下文
- 支持技能组在不同项目间迁移

### 2. 数据验证标准

**防止AI幻觉的核心机制：**
- ✅ **Read-First原则**：所有回答前必须先读取文件验证
- ✅ **Source Traceability**：每个回答必须标注数据来源
- ✅ **Uncertainty Declaration**：数据不存在时明确说明
- ✅ **Verification Visibility**：验证步骤实时显示

**详细说明：** `.data-verification-standard.md`

### 3. 上下文质量监控

**自动监控对话质量，防止Token过长导致回复质量下降：**
- ✅ 自动检测对话上下文长度
- ✅ 根据Token使用量评估质量等级
- ✅ 达到警告阈值时主动提醒用户重启对话
- ✅ 保证始终获得最高质量回复

**质量等级：**
- ⭐⭐⭐⭐⭐ 最佳 (0-50K tokens)
- ⭐⭐⭐⭐ 良好 (50K-100K tokens)
- ⭐⭐⭐ 可接受 (100K-150K tokens)
- ⭐⭐ 警告 (150K-180K tokens) - **建议重启**
- ⭐ 临界 (180K-200K tokens) - **强烈建议重启**

**详细说明：** `.context-quality-monitor.md`

### 4. 团队共享文档

**避免重复劳动，一次产出多次使用：**
- ✅ 产品经理产出需求文档 → 保存到共享目录
- ✅ 架构师读取需求文档 → 产出架构设计
- ✅ 开发人员读取需求和架构 → 开始编码
- ✅ 测试人员读取需求 → 编写测试用例

**共享目录：** `skills/.cache/shared/`
- `requirements/` - 需求文档
- `architecture/` - 架构设计
- `api-design/` - API设计
- `test-plans/` - 测试计划
- `meeting-notes/` - 会议记录

**详细说明：** `.team-shared-docs.md`

### 5. 智能缓存

技能会自动缓存项目信息到 `.cache/` 目录：
- 节约 70-80% Token
- 提高响应速度
- 自动增量更新
- 使用git diff识别变更

## 工作原理

### 自动初始化

第一次使用时，技能会自动检测 `PROJECT_CONFIG.md` 是否已配置：

- ✅ 已配置：直接开始工作
- ⚠️ 未配置：自动引导初始化

### 执行可见性

所有技能执行过程实时显示：
- 📖 读取配置文件
- 🔍 分析任务
- 📋 执行步骤
- ✅ 完成总结

让用户清楚了解技能在做什么。

### 数据验证

所有技能回答前必须验证数据：
- 读取相关文件
- 验证数据准确性
- 标注数据来源（文件路径、行号）
- 不确定时明确说明

绝不编造信息，绝不瞎回答。

## 手动配置（可选）

如果你想手动配置，可以直接编辑 `PROJECT_CONFIG.md`：

```bash
vi skills/PROJECT_CONFIG.md
```

只需填写3个必填项：
1. 项目基本信息
2. 技术栈
3. 业务域

参考 `PROJECT_CONFIG.template.md` 查看配置示例。

## 迁移到新项目

```bash
# 1. 复制 skills 目录
cp -r /old-project/skills /new-project/

# 2. 删除旧配置
rm /new-project/skills/PROJECT_CONFIG.md
rm -rf /new-project/skills/.cache

# 3. 开始使用，自动引导初始化
```

## 高级功能

### 开发环境配置

在 `PROJECT_CONFIG.md` 中配置开发环境：
- MySQL连接信息
- Redis连接信息
- 第三方服务配置（支付、短信、OSS等）
- 日志配置

技能可以直接使用这些配置进行开发和调试。

### MCP工具配置

配置Model Context Protocol工具：
- 浏览器自动化测试（Playwright）
- Chrome DevTools
- 截图和录屏
- 网络监控
- 性能分析
- API测试
- 数据库工具
- 代码生成

技能可以自动调用这些工具完成任务。

### 并行执行

多个技能实例可以同时工作：
- 3个后端开发 + 2个前端开发 + 1个测试
- 按模块、层次、优先级隔离任务
- 避免文件冲突
- 最大化开发效率

## 设计原则

1. **复制粘贴就能用**：skills目录是自包含的，无外部依赖
2. **自我引导**：第一次使用自动初始化
3. **配置驱动**：统一配置，所有技能共享
4. **数据验证**：防止AI幻觉，基于真实数据回答
5. **质量监控**：自动监控上下文，保证最高质量
6. **团队协作**：共享文档，避免重复劳动

## 就这么简单！

复制 → 使用 → 自动初始化 → 开始工作

**无需安装、无需配置、无需学习**
