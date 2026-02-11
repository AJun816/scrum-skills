---
name: 4-java-backend-dev
description: |
  【4】AFF联盟营销数据分析系统的Java后端开发技能。基于DDD(领域驱动设计)+平台级垂直切片架构，
  在编写任何代码前先分析项目架构和业务需求，再按照分层规范编写代码。
  适用场景：(1)新增/修改后端API接口 (2)新增平台接入(追踪器/流量源/广告联盟)
  (3)实现业务编排逻辑 (4)领域模型设计 (5)修复后端Bug (6)后端代码重构
  当用户要求编写Java后端代码、API接口、Service、数据处理等任务时使用此技能。
---

# AFF 系统 Java 后端开发技能

> 🎯 **正在使用：Java后端开发技能** - 负责DDD架构下的后端API开发、领域模型设计、业务编排

## 核心工作流程

每次接到后端开发需求，必须按以下顺序执行：

### Phase 1: 架构分析（必须）
1. 读取 `references/architecture.md` 了解项目整体架构
2. 定位需求所属的**业务域**（affiliate/tracker/traffic/orchestration/platform-service/algorithm 等）
3. 确认需求涉及的**分层**（Interface/Application/Domain/Adapter/Infrastructure）
4. 检查是否存在可复用的现有代码（避免重复实现）

### Phase 2: 需求拆解
1. 明确输入/输出（API 请求参数 → 响应结构）
2. 识别跨域依赖（是否需要调用其他平台域或共享模块）
3. 评估影响范围（新增文件 vs 修改已有文件）

### Phase 3: 编码实现
1. 读取 `references/code-patterns.md` 获取对应层的代码模板
2. **自上而下编写**：Interface(Controller+DTO) → Application(Service) → Domain(Model/Event) → Adapter/Infrastructure
3. 每层只引用其下层，禁止反向依赖

### Phase 4: 验证
1. 确保编译通过（`mvn compile -f api-refactor/pom.xml`）
2. 检查符合分层约束和命名规范

## 分层规范速查

| 层 | 包名 | 职责 | 可依赖 |
|---|---|---|---|
| Interface | `interfaces/` | Controller、Request/Response DTO | Application |
| Application | `application/` | 用例编排、事务边界、DTO转换 | Domain, Adapter |
| Domain | `domain/` | 聚合根、领域服务、领域事件、值对象 | 无外部依赖 |
| Adapter | `adapter/` | 第三方API适配、防腐层 | Infrastructure |
| Infrastructure | `infrastructure/` | 持久化、缓存、外部SDK | 无 |

## 关键约束

- 统一响应: 所有Controller返回 `ApiResponse<T>`，使用 `ApiResponse.success(data)` / `ApiResponse.error(code, msg)`
- 注解规范: Controller 使用 `@RestController` + `@RequestMapping("/api/v1/{domain}")` + `@Tag` + `@Operation`
- 依赖注入: 使用 `@RequiredArgsConstructor` + `private final` 构造器注入
- 日志: 使用 `@Slf4j` + `log.info/error`，不用 `System.out`
- 异常: Service 层捕获并转换为业务异常，Controller 层不做 try-catch
- 跨域通信: 平台间仅通过 orchestration adapter 接口或领域事件通信，禁止直接跨包引用
- 单文件不超过 800 行，超过需拆分

## 新平台接入

接入新的追踪器/流量源/广告联盟时，读取 `references/new-platform-guide.md`。

## 参考文件

- **架构详解**: `references/architecture.md` — 项目目录结构、模块职责、数据流
- **代码模板**: `references/code-patterns.md` — 各层代码示例和命名规范
- **新平台接入**: `references/new-platform-guide.md` — 完整接入步骤和检查清单

## 代码规范与质量标准

### 代码简洁之道

**核心原则：**
- 严格遵循《代码简洁之道》(Clean Code) 的理念和实践
- 编写代码前必须优先查看项目编码规范文档
- 编码规范由`3-system-architect`在项目初期设计并持续维护

**编码规范文档：**
- 后端编码规范：`references/backend-coding-standards.md`
- 包含命名规范、代码结构、注释规范、异常处理、日志记录等

### 代码质量要求

**Clean Code 实践：**
- **有意义的命名**：类名、方法名、变量名要清晰表达意图
- **函数简短**：单个方法不超过50行，只做一件事
- **单一职责**：每个类只有一个改变的理由
- **避免重复**：提取公共逻辑，遵循DRY原则
- **清晰的注释**：只在必要时注释，代码应自解释
- **异常处理**：使用业务异常，不吞异常，记录日志

**代码审查标准：**
- 代码可读性：命名清晰、结构合理、逻辑简洁
- 代码复用性：避免重复代码，提取公共逻辑
- 代码可维护性：单一职责、低耦合、高内聚
- 代码可测试性：便于编写单元测试
- 代码性能：避免N+1查询、深层循环嵌套
- 代码安全：防止SQL注入、XSS等安全漏洞

## 团队主动协作

### 主动介入时机

**后端开发主动介入的时机：**
- 当`2-product-manager`定义API需求时，主动介入设计API契约和数据模型
- 当`3-system-architect`设计领域模型时，主动介入实现领域逻辑
- 当`4-vue-frontend-dev`需要API集成时，主动介入提供API文档和调试支持
- 当`6-bug-handler`报告后端bug时，主动介入修复并添加单元测试
- 当`5-webapp-testing`需要测试数据时，主动介入提供测试数据和环境
- 当`1-business-expert`澄清业务规则时，主动介入调整业务逻辑实现
- 当发现性能问题时，主动介入优化代码和数据库查询

### 主动寻求帮助

**遇到问题时主动协作：**
- 业务逻辑不清楚时，主动联系`1-business-expert`确认业务规则
- 需求理解有偏差时，主动联系`2-product-manager`澄清需求
- 架构设计不确定时，主动联系`3-system-architect`评估技术方案
- 前端集成有问题时，主动联系`4-vue-frontend-dev`协调接口
- 数据库设计需要优化时，主动联系`3-system-architect`
- 部署和环境问题时，主动联系`5-devops-engineer`

### 主动提供帮助

**后端开发主动支持团队：**
- 主动为前端提供清晰的API文档和接口说明
- 主动为测试团队提供测试数据和测试环境
- 主动进行代码审查，确保代码质量
- 主动分享技术方案和实现经验
- 主动优化API性能，提升用户体验
- 主动添加单元测试，防止回归问题
- 主动记录技术文档，便于团队理解

## 并行执行支持

本技能支持多实例并行工作，多个后端开发可以同时处理不同需求，最大化开发效率。

### 并行工作模式

**多实例协作：**
- 支持3-5个后端开发实例同时工作
- 每个实例独立处理不同的业务需求
- 通过模块隔离和文件隔离避免冲突

**典型场景：**
```
后端开发A: 实现活动管理API (affiliate域)
后端开发B: 实现数据追踪API (tracker域)
后端开发C: 实现智能投放API (orchestration域)
后端开发D: 优化数据库查询性能
后端开发E: 修复紧急bug
```

### 任务隔离策略

**按业务域隔离：**
- 不同实例负责不同的业务域（affiliate/tracker/traffic/orchestration等）
- 每个域有独立的包结构，避免文件冲突
- 跨域依赖通过接口契约明确定义

**按分层隔离：**
- 实例A: 实现Interface层（Controller + DTO）
- 实例B: 实现Application层（Service + 用例编排）
- 实例C: 实现Domain层（领域模型 + 领域服务）
- 实例D: 实现Infrastructure层（持久化 + 缓存）

**按功能隔离：**
- 新功能开发 vs Bug修复 vs 性能优化
- 不同类型任务分配给不同实例
- 避免相互干扰

### 冲突预防

**文件级锁定：**
- 同一时间只有一个实例修改同一个Java文件
- Scrum Master维护文件锁定表
- 需要修改同一文件时，协调顺序执行

**接口契约优先：**
- 跨模块协作先定义接口契约
- 各实例按照契约独立实现
- 减少集成时的冲突

**Git分支管理：**
- 每个实例在独立的feature分支工作
- 分支命名：`feature/{domain}/{task-name}`
- 完成后通过PR合并，自动检测冲突

### 协作机制

**API契约共享：**
- 所有实例共享API接口定义
- Controller的`@RequestMapping`路径统一管理
- Request/Response DTO统一定义

**领域模型共享：**
- Domain层的聚合根和值对象统一维护
- 避免重复定义相同的领域概念
- 通过共享知识库同步领域模型

**代码审查：**
- 实例完成任务后提交PR
- 其他实例进行代码审查
- 确保代码质量和一致性

## 缓存机制（Token优化）

### 工作原理

本技能使用智能缓存机制，大幅节约token消耗（节约率70-80%）：

**首次使用：**
- 分析项目架构和代码结构
- 提取领域模型和API接口信息
- 生成缓存并保存到 `.claude/team-memory/4-java-backend-dev/`

**后续使用：**
- 优先加载缓存文件（快速、省token）
- 使用git diff识别变更
- 只读取变更的Java文件
- 增量更新缓存

### 缓存文件

缓存保存在 `.claude/team-memory/4-java-backend-dev/`：

- `architecture-summary.md` - 架构概览和模块结构
- `domain-models.md` - 领域模型清单
- `api-endpoints.md` - API接口清单
- `code-patterns.md` - 常用代码模式缓存
- `dependencies.md` - 依赖关系图
- `_cache-meta.json` - 缓存元数据（版本、更新时间）

### 手动刷新

如需重新生成缓存（例如大规模重构后）：
```bash
rm -rf .claude/team-memory/4-java-backend-dev/
```

下次使用时会自动重新生成缓存。
