# 敏捷团队技能组 (Scrum Skills)

**一套完整的敏捷开发 AI 技能组，让 AI 成为你的敏捷团队！**

## ✨ 项目简介

这是一套专为敏捷开发设计的 AI 技能组，包含从需求分析到开发测试的完整角色：

- 🎯 **Scrum Master** - 敏捷教练，协调团队
- 💼 **业务专家** - 梳理业务流程和规则
- 📋 **产品经理** - 需求分析和用户故事
- 🏗️ **系统架构师** - 架构设计和技术选型
- 💻 **开发工程师** - 前端/后端代码实现
- 🎨 **UI/UX设计师** - 界面设计和用户体验
- 🧪 **测试工程师** - 自动化测试和质量保障
- 🚀 **DevOps工程师** - CI/CD和自动化部署
- 🐛 **Bug处理专家** - Bug分析和修复协调

## 🚀 快速开始

### 1. 复制技能组到你的项目

```bash
# 克隆或下载本项目
git clone https://github.com/your-repo/scrum-skills.git

# 或者直接复制 skills 目录到你的项目
cp -r scrum-skills/skills /your-project/
```

### 2. 第一次使用（自动初始化）

直接在 Claude Code 中调用任何技能，系统会自动引导你初始化：

```
@0-scrum-master 帮我组织一次迭代计划会议
```

**自动引导流程：**
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

### 3. 开始使用技能

初始化完成后，就可以调用各种技能了：

```
# 需求分析
@2-product-manager 帮我分析一下用户登录功能的需求

# 架构设计
@3-system-architect 设计订单管理模块的架构

# 后端开发
@4-java-backend-dev 实现用户登录API

# 前端开发
@4-vue-frontend-dev 实现登录页面

# 测试
@5-webapp-testing 编写登录功能的测试用例
```

## 📚 核心特性

### 1. 配置驱动 - 节约70-80% Token

所有技能共享 `PROJECT_CONFIG.md` 配置文件：
- ✅ 项目信息和技术栈
- ✅ 业务域定义
- ✅ 架构概览
- ✅ 核心业务规则
- ✅ 开发环境配置

**优势：** 避免每个技能重复读取项目信息，大幅节约 Token

### 2. 自动初始化 - 零配置开箱即用

第一次使用时自动检测并引导初始化：
- ✅ 自动分析项目结构
- ✅ 识别技术栈和业务模块
- ✅ 生成配置文件
- ✅ 创建缓存目录

**优势：** 无需手动配置，直接开始使用

### 3. 数据验证 - 防止AI幻觉

所有技能遵循严格的数据验证标准：
- ✅ Read-First原则：回答前必须先读取文件验证
- ✅ Source Traceability：标注数据来源（文件路径、行号）
- ✅ Uncertainty Declaration：不确定时明确说明
- ✅ Verification Visibility：验证步骤实时显示

**优势：** 确保所有回答基于真实数据，绝不编造信息

### 4. 团队协作 - 避免重复劳动

技能间共享工作成果：
- ✅ 产品经理产出需求文档 → 保存到共享目录
- ✅ 架构师读取需求文档 → 产出架构设计
- ✅ 开发人员读取需求和架构 → 开始编码
- ✅ 测试人员读取需求 → 编写测试用例

**优势：** 一次产出，多次使用，节约Token和时间

### 5. 智能缓存 - 提高响应速度

技能自动缓存项目信息：
- ✅ 首次使用：分析项目，生成缓存
- ✅ 后续使用：加载缓存，使用git diff识别变更
- ✅ 增量更新：只读取变更的文件

**优势：** 节约70-80% Token，提高响应速度

### 6. 质量监控 - 保证最高质量回复

自动监控对话上下文长度：
- ✅ 实时评估回复质量等级（⭐⭐⭐⭐⭐ 到 ⭐）
- ✅ 达到警告阈值时主动提醒
- ✅ 建议重启对话窗口恢复最佳性能

**优势：** 始终获得最高质量的AI回复

## 🛠️ 技能列表

| 编号 | 技能名称 | 职责 | 使用场景 |
|------|---------|------|----------|
| 0 | scrum-master | 敏捷教练 | 组织敏捷仪式、协调团队、移除障碍 |
| 1 | business-expert | 业务专家 | 梳理业务流程、定义业务规则 |
| 2 | product-manager | 产品经理 | 需求分析、用户故事、需求变更 |
| 3 | system-architect | 系统架构师 | 架构设计、技术选型、任务拆解 |
| 4 | java-backend-dev | Java后端开发 | 后端代码实现、API开发 |
| 4 | vue-frontend-dev | Vue前端开发 | 前端页面开发、组件设计 |
| 4 | nielsen-ui-design | UI/UX设计 | 基于尼尔森原则的可用性设计 |
| 4 | frontend-design | 前端视觉设计 | 创意视觉设计、品牌形象 |
| 5 | devops-engineer | DevOps工程师 | CI/CD、自动化部署、监控 |
| 5 | webapp-testing | Web应用测试 | 自动化测试、功能验证 |
| 6 | bug-handler | Bug处理专家 | Bug分析、修复协调、验证 |
| 7 | skill-creator | 技能创建器 | 创建新技能、扩展团队能力 |

## 🎯 使用技能创建器

### 为什么需要技能创建器？

随着项目发展，你可能需要：
- ✅ 添加新的技术栈支持（如 React、Python、Go）
- ✅ 添加新的角色（如数据分析师、安全专家）
- ✅ 添加项目特定的技能（如特定业务领域专家）

**技能创建器让你轻松扩展技能组！**

### 如何使用技能创建器

#### 方式1：创建全新技能

```
@7-skill-creator 我想创建一个新技能
```

**交互式引导：**
```
🎯 创建新技能

我会帮你创建一个符合敏捷团队技能组风格的新技能。

请回答以下问题：

1️⃣ 技能基本信息
技能名称：（例如：8-security-expert）
技能中文名称：（例如：安全专家）
技能职责：（简要描述，1-2句话）

2️⃣ 技能使用场景
何时使用这个技能？（列出3-5个典型场景）

3️⃣ 技能工作流程
主要工作步骤：（列出3-7个主要步骤）

4️⃣ 团队协作
需要协作的技能：（列出相关技能）

5️⃣ 资源文件需求
是否需要 scripts/、references/、assets/ 目录？
```

**自动生成：**
- ✅ 完整的 SKILL.md 文件
- ✅ 符合项目风格的结构
- ✅ 集成执行标准和数据验证
- ✅ 包含团队协作机制
- ✅ 包含缓存优化机制

#### 方式2：快速创建（提供完整信息）

```
@7-skill-creator 创建一个安全专家技能

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

#### 方式3：优化现有技能

```
@7-skill-creator 帮我优化 2-product-manager 技能

需要优化的方面：
- 添加需求变更管理流程
- 完善团队协作机制
- 优化缓存策略
```

### 创建技能的最佳实践

1. **明确技能职责**
   - 职责清晰，不与现有技能重叠
   - 使用场景具体，便于触发

2. **设计合理的工作流程**
   - 步骤清晰，易于理解
   - 包含必要的验证和检查

3. **考虑团队协作**
   - 明确需要协作的技能
   - 说明主动介入和寻求帮助的时机

4. **准备资源文件**
   - references/：参考文档和知识库
   - assets/：模板和资源文件
   - scripts/：自动化脚本

## 📁 项目结构

```
scrum-skills/
├── README.md                          # 项目说明（本文件）
├── skills/                            # 技能组目录
│   ├── PROJECT_CONFIG.md              # 项目配置（自动生成）
│   ├── PROJECT_CONFIG.template.md     # 配置模板（参考）
│   ├── README.md                      # 技能组使用指南
│   │
│   ├── .cache/                        # 缓存目录（自动生成）
│   │   ├── shared/                    # 团队共享文档
│   │   └── {skill-name}/              # 各技能缓存
│   │
│   ├── .context-quality-monitor.md    # 上下文质量监控机制
│   ├── .data-verification-standard.md # 数据验证标准
│   ├── .init-detection.md             # 初始化检测机制
│   ├── .init-guide.md                 # 初始化指南
│   ├── .skill-execution-standard.md   # 技能执行标准
│   ├── .team-shared-docs.md           # 团队共享文档机制
│   │
│   ├── 0-scrum-master/                # 敏捷教练
│   ├── 1-business-expert/             # 业务专家
│   ├── 2-product-manager/             # 产品经理
│   ├── 3-system-architect/            # 系统架构师
│   ├── 4-java-backend-dev/            # Java后端开发
│   ├── 4-vue-frontend-dev/            # Vue前端开发
│   ├── 4-nielsen-ui-design/           # UI/UX设计
│   ├── 4-frontend-design/             # 前端视觉设计
│   ├── 5-devops-engineer/             # DevOps工程师
│   ├── 5-webapp-testing/              # Web应用测试
│   ├── 6-bug-handler/                 # Bug处理专家
│   └── 7-skill-creator/               # 技能创建器
│       ├── SKILL.md                   # 技能主文件
│       ├── scripts/                   # 脚本目录
│       │   ├── init_skill.py          # 初始化技能脚本
│       │   ├── package_skill.py       # 打包技能脚本
│       │   └── quick_validate.py      # 快速验证脚本
│       └── references/                # 参考文档
│           ├── workflows.md           # 工作流程模式
│           └── output-patterns.md     # 输出模式
```

## 🔧 高级功能

### 1. 手动配置项目

如果你想手动配置而不是自动初始化：

```bash
# 复制配置模板
cp skills/PROJECT_CONFIG.template.md skills/PROJECT_CONFIG.md

# 编辑配置文件
vi skills/PROJECT_CONFIG.md
```

只需填写3个必填项：
1. 项目基本信息
2. 技术栈
3. 业务域

### 2. 迁移到新项目

```bash
# 1. 复制 skills 目录
cp -r /old-project/skills /new-project/

# 2. 删除旧配置
rm /new-project/skills/PROJECT_CONFIG.md
rm -rf /new-project/skills/.cache

# 3. 开始使用，自动引导初始化
```

### 3. 并行执行多个技能

多个技能实例可以同时工作：

```
# 同时启动3个后端开发 + 2个前端开发 + 1个测试
@4-java-backend-dev 实现订单模块
@4-java-backend-dev 实现支付模块
@4-java-backend-dev 实现物流模块
@4-vue-frontend-dev 实现订单页面
@4-vue-frontend-dev 实现支付页面
@5-webapp-testing 编写测试用例
```

**优势：** 最大化开发效率，按模块、层次、优先级隔离任务

### 4. 开发环境配置

在 `PROJECT_CONFIG.md` 中配置开发环境：
- MySQL连接信息
- Redis连接信息
- 第三方服务配置（支付、短信、OSS等）
- 日志配置

技能可以直接使用这些配置进行开发和调试。

### 5. MCP工具配置

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

## 📖 使用示例

### 示例1：开发新功能（完整流程）

```
# 1. 需求分析
@2-product-manager 帮我分析一下订单管理功能的需求

# 2. 架构设计
@3-system-architect 基于需求文档设计订单模块的架构

# 3. 后端开发
@4-java-backend-dev 基于架构文档实现订单API

# 4. 前端开发
@4-vue-frontend-dev 基于需求和API文档实现订单管理页面

# 5. 测试
@5-webapp-testing 基于需求文档编写订单功能的测试用例

# 6. 部署
@5-devops-engineer 配置订单模块的CI/CD流程
```

**优势：** 技能间自动共享文档，避免重复劳动

### 示例2：Bug修复

```
# 1. Bug分析
@6-bug-handler 分析订单支付失败的bug

# 2. 修复代码
@4-java-backend-dev 修复支付接口的bug

# 3. 验证修复
@5-webapp-testing 验证bug是否已修复

# 4. 部署hotfix
@5-devops-engineer 部署hotfix到生产环境
```

### 示例3：需求变更

```
# 1. 变更分析
@2-product-manager 分析订单取消功能的变更影响

# 2. 架构调整
@3-system-architect 评估架构是否需要调整

# 3. 实施变更
@4-java-backend-dev 实现订单取消功能
@4-vue-frontend-dev 添加订单取消按钮

# 4. 回归测试
@5-webapp-testing 执行回归测试
```

## 🎓 设计原则

1. **复制粘贴就能用**
   - skills目录是自包含的，无外部依赖
   - 无需安装、无需配置、无需学习

2. **自我引导**
   - 第一次使用自动初始化
   - 交互式引导配置

3. **配置驱动**
   - 统一配置，所有技能共享
   - 节约70-80% Token

4. **数据验证**
   - 防止AI幻觉，基于真实数据回答
   - Read-First原则，Source Traceability

5. **质量监控**
   - 自动监控上下文，保证最高质量
   - 主动提醒重启对话

6. **团队协作**
   - 共享文档，避免重复劳动
   - 一次产出，多次使用

## 🤝 贡献指南

欢迎贡献新的技能或改进现有技能！

### 贡献新技能

1. 使用 `@7-skill-creator` 创建新技能
2. 测试技能是否正常工作
3. 提交 Pull Request

### 改进现有技能

1. 使用 `@7-skill-creator` 优化技能
2. 说明优化的原因和效果
3. 提交 Pull Request

## 📝 许可证

本项目采用 MIT 许可证。详见 `skills/7-skill-creator/LICENSE.txt`

## 🙏 致谢

感谢所有为敏捷开发和AI技术做出贡献的开发者！

## 📮 联系方式

- GitHub Issues: [提交问题](https://github.com/your-repo/scrum-skills/issues)
- 讨论区: [参与讨论](https://github.com/your-repo/scrum-skills/discussions)

---

**让AI成为你的敏捷团队，高效交付价值！** 🚀
