# 共享知识库 (Shared Knowledge Base)

> 所有敏捷团队技能共享的项目知识和资源

## 目录结构

本目录存储所有技能共同需要的项目知识，避免重复缓存，提升token使用效率。

### 核心文件

- `project-overview.md` - 项目概览（技术栈、架构模式、核心功能）
- `architecture.md` - 系统架构详解（前后端架构、模块划分、数据流）
- `business-domain.md` - 业务领域知识（联盟营销术语、业务规则、业务流程）
- `api-catalog.md` - API接口目录（所有后端API的路径、参数、响应格式）
- `tech-stack.md` - 技术栈清单（依赖版本、工具链、开发环境）
- `coding-standards.md` - 编码规范（后端、前端、数据库设计规范）
- `database-schema.md` - 数据库结构（表结构、字段说明、关系图）
- `deployment-guide.md` - 部署指南（环境配置、启动流程、常见问题）

## 使用方式

### 双层缓存机制

**共享知识库（本目录）：**
- 存储所有技能共同需要的项目知识
- 由任何技能首次使用时生成
- 所有技能优先从这里读取通用信息

**技能独立缓存（`.claude/team-memory/{序号-技能名}/`）：**
- 存储技能特定的专业知识
- 例如：`4-java-backend-dev/` 存储领域模型、代码模式
- 例如：`4-vue-frontend-dev/` 存储组件库、页面清单

### 读取优先级

1. **首次使用**：检查共享知识库是否存在
   - 如不存在，分析项目生成共享知识
   - 同时生成技能独立缓存

2. **后续使用**：
   - 优先读取共享知识库（项目通用信息）
   - 再读取技能独立缓存（专业领域信息）
   - 使用git diff识别变更，增量更新

### 缓存更新策略

**共享知识库更新时机：**
- 项目架构重大变更
- 技术栈升级
- 业务领域模型调整
- API接口大规模变更

**手动刷新：**
```bash
# 刷新共享知识库
rm -rf .claude/team-memory/shared/

# 刷新特定技能缓存
rm -rf .claude/team-memory/{序号-技能名}/

# 刷新所有缓存
rm -rf .claude/team-memory/
```

## Token优化效果

**传统方式（无缓存）：**
- 每次技能调用都需要读取大量项目文件
- 重复读取相同的架构、API、业务知识
- Token消耗高，响应慢

**双层缓存方式：**
- 共享知识库：所有技能共享，避免重复缓存
- 技能独立缓存：专业知识独立维护
- Token节约率：70-80%
- 响应速度：显著提升

## 维护说明

### 谁来维护

- **共享知识库**：任何技能首次使用时自动生成，所有技能共同维护
- **技能独立缓存**：各技能独立维护自己的专业知识

### 更新频率

- **共享知识库**：项目重大变更时更新
- **技能独立缓存**：技能使用时增量更新

### 一致性保证

- 使用git commit hash追踪项目版本
- 缓存元数据记录生成时间和版本
- 检测到版本不一致时自动重新生成

## 示例：技能如何使用

### 场景1：后端开发任务

```markdown
1. 读取共享知识库：
   - `architecture.md` - 了解DDD架构和模块划分
   - `api-catalog.md` - 查看现有API接口
   - `coding-standards.md` - 获取后端编码规范

2. 读取技能独立缓存：
   - `4-java-backend-dev/domain-models.md` - 领域模型清单
   - `4-java-backend-dev/code-patterns.md` - 代码模式示例

3. 使用git diff识别变更：
   - 只读取变更的Java文件
   - 增量更新缓存
```

### 场景2：前端开发任务

```markdown
1. 读取共享知识库：
   - `architecture.md` - 了解前端架构和目录结构
   - `api-catalog.md` - 查看需要对接的后端API
   - `coding-standards.md` - 获取前端编码规范

2. 读取技能独立缓存：
   - `4-vue-frontend-dev/components-library.md` - 组件库清单
   - `4-vue-frontend-dev/pages-inventory.md` - 页面清单

3. 使用git diff识别变更：
   - 只读取变更的Vue文件
   - 增量更新缓存
```

## 缓存文件夹命名规范

所有缓存文件夹使用 `{序号-技能名}` 格式，便于识别：

```
.claude/team-memory/
├── shared/                      # 共享知识库
├── 0-scrum-master/             # Scrum Master缓存
├── 1-business-expert/          # 业务专家缓存
├── 2-product-manager/          # 产品经理缓存
├── 3-system-architect/         # 系统架构师缓存
├── 4-java-backend-dev/         # Java后端开发缓存
├── 4-vue-frontend-dev/         # Vue前端开发缓存
├── 4-nielsen-ui-design/        # UI/UX设计缓存
├── 4-frontend-design/          # 前端设计缓存
├── 5-webapp-testing/           # Web测试缓存
├── 5-devops-engineer/          # DevOps工程师缓存
└── 6-bug-handler/              # Bug处理专家缓存
```

## 最后更新

- **创建时间**: 2026-02-11
- **维护者**: 敏捷团队所有技能
- **版本**: 1.0.0
