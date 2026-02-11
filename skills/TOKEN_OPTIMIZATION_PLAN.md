# Token优化和缓存机制设计方案

## 设计目标

1. **节约Token**：减少重复读取文件的token消耗
2. **保证质量**：不影响产品质量（最高优先级）
3. **增量更新**：只读取变更的内容
4. **智能加载**：根据任务类型加载相关缓存

## 核心机制

### 1. 缓存文件系统

**目录结构：**
```
.claude/team-memory/
├── _meta.json                   # 元数据：缓存版本、更新时间
├── project-overview.md          # 项目整体概览（所有技能共享）
├── git-history.md               # Git变更历史记录
├── 1-business-expert/
│   ├── _cache-meta.json         # 缓存元数据
│   ├── business-rules.md        # 业务规则缓存
│   ├── business-processes.md    # 业务流程缓存
│   └── domain-glossary.md       # 业务术语表
├── 2-product-manager/
│   ├── _cache-meta.json
│   ├── requirements-summary.md  # 需求摘要
│   ├── user-stories.md          # 用户故事列表
│   └── change-history.md        # 需求变更历史
├── 3-system-architect/
│   ├── _cache-meta.json
│   ├── architecture-overview.md # 架构概览
│   ├── tech-stack.md            # 技术栈
│   ├── design-patterns.md       # 设计模式
│   └── api-contracts.md         # API契约
├── 4-java-backend-dev/
│   ├── _cache-meta.json
│   ├── domain-models.md         # 领域模型摘要
│   ├── api-endpoints.md         # API接口列表
│   ├── database-schema.md       # 数据库结构
│   ├── code-patterns.md         # 代码模式和最佳实践
│   └── common-issues.md         # 常见问题和解决方案
├── 4-vue-frontend-dev/
│   ├── _cache-meta.json
│   ├── components-index.md      # 组件索引
│   ├── routes.md                # 路由配置
│   ├── state-management.md      # 状态管理
│   ├── api-integration.md       # API集成
│   └── ui-patterns.md           # UI模式
└── ...
```

**缓存元数据格式（_cache-meta.json）：**
```json
{
  "version": "1.0.0",
  "lastUpdate": "2026-02-11T10:00:00Z",
  "gitCommit": "abc123def456",
  "filesAnalyzed": [
    "api/src/main/java/com/aff/domain/activity/Activity.java",
    "api/src/main/java/com/aff/application/service/AffActivityApplicationService.java"
  ],
  "cacheFiles": [
    "domain-models.md",
    "api-endpoints.md"
  ]
}
```

### 2. 缓存生成流程

**首次使用技能时：**

1. **分析项目结构**
   - 使用Glob快速扫描文件结构
   - 识别关键文件和目录
   - 生成项目结构索引

2. **提取关键信息**
   - 读取核心文件（不是全部文件）
   - 提取关键代码片段
   - 生成摘要和索引

3. **生成缓存文件**
   - 将提取的信息保存为md文件
   - 记录缓存元数据
   - 保存到 `.claude/team-memory/[skill-name]/`

4. **记录Git状态**
   - 记录当前Git commit hash
   - 记录已分析的文件列表

**缓存文件内容示例（domain-models.md）：**
```markdown
# 领域模型缓存

> 最后更新：2026-02-11 10:00:00
> Git Commit: abc123def456

## 核心领域模型

### Activity（活动）
- **位置：** `api/src/main/java/com/aff/domain/activity/Activity.java`
- **职责：** 管理联盟营销活动
- **关键字段：**
  - activityId: 活动ID
  - activityName: 活动名称
  - country: 国家
  - commission: 佣金
- **关键方法：**
  - create(): 创建活动
  - update(): 更新活动
  - calculateROI(): 计算ROI

### SkroLog（追踪日志）
- **位置：** `api/src/main/java/com/aff/domain/tracking/SkroLog.java`
- **职责：** 记录追踪日志
- **关键字段：**
  - logId: 日志ID
  - clickId: 点击ID
  - conversionStatus: 转化状态
...

## 领域关系

Activity ---> Campaign ---> SkroLog

## 常见操作模式

### 创建活动
```java
Activity activity = Activity.builder()
    .activityName(name)
    .country(country)
    .build();
```
```

### 3. 缓存加载流程

**后续使用技能时：**

1. **检查缓存**
   - 检查 `.claude/team-memory/[skill-name]/` 是否存在
   - 检查缓存元数据是否有效

2. **加载缓存**
   - 读取缓存文件（token消耗很小）
   - 获取项目概览和关键信息

3. **识别变更**
   ```bash
   # 获取自上次缓存以来的变更文件
   git diff --name-only [last-commit] HEAD
   ```

4. **增量更新**
   - 只读取变更的文件
   - 更新缓存中相关的部分
   - 更新缓存元数据

5. **智能决策**
   - 如果变更很小：只读取变更文件
   - 如果变更很大（>30%文件）：重新生成缓存
   - 如果缓存过期（>7天）：重新生成缓存

### 4. Git集成优化

**变更检测：**
```bash
# 获取变更文件列表
git log --since="2026-02-01" --name-only --pretty=format: | sort -u

# 获取具体变更内容
git diff [last-commit] HEAD -- [file-path]
```

**智能过滤：**
- 忽略测试文件变更（如果任务不涉及测试）
- 忽略配置文件变更（如果任务不涉及配置）
- 优先关注核心业务代码变更

## Token优化策略

### 策略1：分层缓存

**L1缓存（最常用，总是加载）：**
- 项目概览（200-500 tokens）
- 技术栈和架构（200-300 tokens）
- 核心业务流程（300-500 tokens）

**L2缓存（按需加载）：**
- 具体模块详情（500-1000 tokens/模块）
- API接口列表（300-500 tokens）
- 数据模型详情（400-600 tokens）

**L3缓存（很少加载）：**
- 完整代码细节（按需读取原文件）
- 历史变更记录
- 详细的实现细节

### 策略2：智能加载

**根据任务类型加载：**

| 任务类型 | 加载的缓存 | Token消耗 |
|---------|-----------|----------|
| 新功能开发 | L1 + L2（相关模块） | 1000-2000 |
| Bug修复 | L1 + L2（相关模块） + 原文件 | 1500-3000 |
| 代码审查 | L1 + 原文件 | 1000-2000 |
| 架构设计 | L1 + L2（全部） | 2000-4000 |
| 需求分析 | L1 + 业务缓存 | 800-1500 |

### 策略3：摘要提取

**大文件处理：**
- 文件 > 500行：提取类/方法签名
- 文件 > 1000行：只提取公共API
- 文件 > 2000行：只提取关键方法

**示例：**
```markdown
## AffActivityApplicationService（大文件）

### 公共方法
- createActivity(ActivityDTO): ActivityDTO
- updateActivity(Long, ActivityDTO): ActivityDTO
- getActivity(Long): ActivityDTO
- listActivities(PageRequest): Page<ActivityDTO>

### 关键实现
- createActivity: 调用领域服务创建活动，发布事件
- updateActivity: 验证权限，更新活动，发布事件

详细实现见：api/src/main/java/.../AffActivityApplicationService.java:50-200
```

### 策略4：索引机制

**文件索引（file-index.md）：**
```markdown
# 文件索引

## 按功能分类

### 活动管理
- Activity.java - 活动领域模型
- ActivityRepository.java - 活动仓储
- AffActivityApplicationService.java - 活动应用服务
- AffActivityController.java - 活动控制器

### 追踪管理
- SkroLog.java - 追踪日志模型
- SkroApplicationService.java - 追踪应用服务
...

## 按层次分类

### 领域层
- domain/activity/Activity.java
- domain/tracking/SkroLog.java
...

### 应用层
- application/service/AffActivityApplicationService.java
...
```

**快速定位：**
- 根据任务关键词，快速定位相关文件
- 只读取相关文件，不读取无关文件

### 策略5：增量分析

**变更分析：**
```markdown
# Git变更历史

## 2026-02-11 更新
- 修改文件：Activity.java
- 变更内容：添加了 calculateROI() 方法
- 影响范围：活动管理模块
- 需要更新缓存：domain-models.md

## 2026-02-10 更新
- 新增文件：PropellerCampaign.java
- 变更内容：新增PropellerAds广告模型
- 影响范围：广告管理模块
- 需要更新缓存：domain-models.md, api-endpoints.md
```

**增量更新流程：**
1. 检测到文件变更
2. 只读取变更的文件
3. 更新缓存中相关的部分
4. 不重新读取未变更的文件

## 实施方案

### 阶段1：基础缓存机制（立即实施）

**目标：** 为所有技能添加基础缓存功能

**实施步骤：**
1. 创建 `.claude/team-memory/` 目录结构
2. 为每个技能添加缓存生成逻辑
3. 在技能SKILL.md中添加缓存使用说明

**每个技能需要添加的内容：**

```markdown
## 缓存机制

### 首次使用
本技能首次使用时会分析项目并生成缓存文件，保存到：
`.claude/team-memory/[skill-name]/`

### 后续使用
后续使用时会：
1. 优先加载缓存文件（节约token）
2. 使用git diff识别变更
3. 只读取变更的文件
4. 更新缓存

### 缓存文件
- `[cache-file-1].md` - [描述]
- `[cache-file-2].md` - [描述]

### 手动刷新缓存
如果需要重新生成缓存，删除缓存目录即可：
`rm -rf .claude/team-memory/[skill-name]/`
```

### 阶段2：Git集成优化（后续实施）

**目标：** 集成Git变更检测，实现增量更新

**实施步骤：**
1. 添加Git变更检测脚本
2. 实现增量缓存更新
3. 优化变更文件读取

### 阶段3：智能加载优化（长期优化）

**目标：** 实现分层缓存和智能加载

**实施步骤：**
1. 实现分层缓存机制
2. 根据任务类型智能加载
3. 优化缓存文件结构

## Token节约效果预估

### 当前Token消耗（无缓存）

**典型场景：后端开发任务**
- 读取项目结构：500 tokens
- 读取领域模型文件（10个）：5000 tokens
- 读取应用服务文件（5个）：3000 tokens
- 读取控制器文件（5个）：2000 tokens
- **总计：10,500 tokens**

### 优化后Token消耗（有缓存）

**首次使用（生成缓存）：**
- 与当前相同：10,500 tokens
- 生成缓存文件：500 tokens
- **总计：11,000 tokens**（略高）

**后续使用（加载缓存）：**
- 加载缓存文件：800 tokens
- 读取变更文件（假设2个）：1000 tokens
- **总计：1,800 tokens**

**节约效果：**
- 节约：10,500 - 1,800 = 8,700 tokens
- 节约率：83%

### 长期效果

**假设场景：**
- 每天使用技能10次
- 其中1次是首次使用（生成缓存）
- 其中9次是后续使用（加载缓存）

**Token消耗：**
- 无缓存：10,500 × 10 = 105,000 tokens/天
- 有缓存：11,000 × 1 + 1,800 × 9 = 27,200 tokens/天
- **节约：77,800 tokens/天（74%）**

## 质量保证

### 确保不影响产品质量

**原则：**
1. **缓存仅用于加速，不影响决策**
2. **关键信息必须准确**
3. **变更必须及时更新**
4. **疑问时重新读取原文件**

**质量检查：**
1. 缓存生成后，验证关键信息准确性
2. 定期（每周）重新生成缓存
3. 重要任务时，验证缓存与实际代码一致
4. 发现不一致时，立即重新生成缓存

**降级机制：**
- 如果缓存不可用，回退到直接读取文件
- 如果变更太大，重新生成缓存
- 如果缓存过期，重新生成缓存

## 总结

**核心优势：**
1. 大幅节约token（70-80%）
2. 加快响应速度
3. 不影响产品质量
4. 支持增量更新

**实施建议：**
1. 立即实施阶段1（基础缓存）
2. 逐步实施阶段2（Git集成）
3. 长期优化阶段3（智能加载）

**注意事项：**
1. 缓存文件需要定期更新
2. 重要任务时验证缓存准确性
3. 提供手动刷新缓存的方法
4. 质量永远是最高优先级
