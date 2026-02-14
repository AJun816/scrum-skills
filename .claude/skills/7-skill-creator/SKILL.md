---
name: 7-skill-creator
description: 【工具】技能创建器，用于创建新的技能或优化现有技能。当用户需要创建新技能、扩展团队能力、或优化现有技能时使用。本技能会引导用户输入简要信息，结合项目配置自动生成符合敏捷团队技能组风格的技能，包括标准的执行流程、团队协作机制、缓存优化等特性。
---

# 技能创建器 (Skill Creator)

> 🎯 **正在使用：技能创建器** - 帮助你创建符合敏捷团队技能组风格的新技能

## 执行标准

**所有任务执行前，必须遵循以下标准：**

1. **读取项目配置**：读取 `PROJECT_CONFIG.md` 获取项目信息、技术栈、业务域等
2. **实时显示进度**：所有操作实时显示，让用户了解执行过程
3. **使用中文输出**：所有提示、说明、错误信息使用中文
4. **数据验证原则**：基于真实项目结构生成技能，不编造信息

**详细执行标准参考：** `skills/.skill-execution-standard.md`

## 概述

本技能帮助你创建符合敏捷团队技能组风格的新技能。通过交互式引导，收集技能需求信息，然后结合项目配置自动生成完整的技能文件，包括：

- 标准的 SKILL.md 文件（符合项目风格）
- 执行标准和数据验证机制
- 团队协作和共享文档机制
- 缓存优化机制
- 资源文件结构（scripts/、references/、assets/）

## 技能创建流程

### 第一步：理解需求（交互式引导）

**引导用户提供技能信息：**

```markdown
## 🎯 创建新技能

我会帮你创建一个符合敏捷团队技能组风格的新技能。

请回答以下问题：

### 1️⃣ 技能基本信息

**技能名称（目录名）：** （例如：8-security-expert）

**⚠️ 命名规范（必须遵守）：**
- **格式：** `{编号}-{英文名称}`
- **编号：** 必须是数字
- **分隔符：** 必须使用连字符 `-`
- **英文名称：** 小写字母，多个单词用连字符连接

**编号分类规则：**
- **0** - 协调类（Scrum Master）
- **1-2** - 需求类（业务专家、产品经理）
- **3** - 架构类（系统架构师）
- **4** - 开发类（前端、后端、UI设计等）
- **5** - 质量类（测试、DevOps）
- **6** - 维护类（Bug处理）
- **7+** - 工具类或扩展类

**命名示例：**
- ✅ 正确：`8-security-expert`、`9-data-analyst`、`10-performance-optimizer`
- ❌ 错误：`security-expert`（缺少编号）、`8_security_expert`（错误分隔符）、`8-SecurityExpert`（大写字母）

**技能中文名称：** （例如：安全专家）

**技能职责：** （简要描述，1-2句话）
例如：负责系统安全评估、漏洞扫描、安全加固和安全培训

### 2️⃣ 技能使用场景

**何时使用这个技能？** （列出3-5个典型场景）
例如：
- 需要进行安全评估时
- 发现安全漏洞需要修复时
- 需要制定安全规范时
- 需要进行安全培训时

### 3️⃣ 技能工作流程

**主要工作步骤：** （列出3-7个主要步骤）
例如：
1. 分析安全需求
2. 执行安全扫描
3. 评估风险等级
4. 制定修复方案
5. 验证修复效果

### 4️⃣ 团队协作

**需要协作的技能：** （列出相关技能）
例如：
- 3-system-architect：架构安全设计
- 4-java-backend-dev：后端安全实现
- 4-vue-frontend-dev：前端安全实现
- 5-devops-engineer：部署安全配置

### 5️⃣ 资源文件需求

**是否需要以下资源：**
- [ ] scripts/ - 可执行脚本（例如：安全扫描脚本）
- [ ] references/ - 参考文档（例如：安全规范、最佳实践）
- [ ] assets/ - 资源文件（例如：模板、配置文件）

请提供以上信息，我会自动生成完整的技能文件。
```

### 第二步：读取项目配置

```markdown
## 📖 读取项目配置

正在读取 `PROJECT_CONFIG.md`...
✅ 项目名称：{project_name}
✅ 技术栈：{tech_stack}
✅ 业务域：{business_domains}
✅ 团队角色：{team_roles}

配置加载完成，开始生成技能...
```

### 第三步：生成技能文件

**自动生成以下内容：**

1. **技能目录** - 按照命名规范创建
   - 格式：`skills/{编号}-{英文名称}/`
   - 示例：`skills/8-security-expert/`

2. **SKILL.md** - 技能主文件
   - YAML frontmatter（name、description）
   - name 字段：`{编号}-{英文名称}`（与目录名一致）
   - description 字段：`【{编号}】{中文名称}，...`
   - 执行标准（引用共享标准文档）
   - 概述和工作流程
   - 团队主动协作机制
   - 资源文件说明
   - 缓存机制说明

3. **目录结构**
   ```
   skills/{编号}-{英文名称}/
   ├── SKILL.md
   ├── scripts/          （如需要）
   ├── references/       （如需要）
   └── assets/           （如需要）
   ```

   **示例：**
   ```
   skills/8-security-expert/
   ├── SKILL.md
   ├── references/
   │   ├── security-checklist.md
   │   └── secure-coding-guide.md
   └── assets/
       └── security-report-template.md
   ```

4. **自动集成项目特性**
   - 读取 PROJECT_CONFIG.md 的标准流程
   - 数据验证标准（引用 .data-verification-standard.md）
   - 团队共享文档机制（引用 .team-shared-docs.md）
   - 缓存优化机制
   - 中文输出规范

### 第四步：验证和优化

```markdown
## ✅ 技能生成完成

**生成的文件：**
- ✅ `skills/{编号}-{英文名称}/SKILL.md`
- ✅ `skills/{编号}-{英文名称}/scripts/` （如需要）
- ✅ `skills/{编号}-{英文名称}/references/` （如需要）
- ✅ `skills/{编号}-{英文名称}/assets/` （如需要）

**示例：**
- ✅ `skills/8-security-expert/SKILL.md`
- ✅ `skills/8-security-expert/references/`

**下一步建议：**
1. 检查生成的 SKILL.md 文件
2. 根据需要添加 scripts、references、assets
3. 测试技能是否正常工作（使用 `@{编号}-{英文名称}` 调用）
4. 根据实际使用情况优化技能
```

## 技能命名规范详解

### 为什么使用"序号-技能名称"格式？

1. **清晰的分类**
   - 通过序号快速识别技能类型
   - 便于组织和管理技能

2. **调用方便**
   - 使用 `@{编号}-{英文名称}` 调用技能
   - 例如：`@8-security-expert`

3. **避免冲突**
   - 序号确保技能名称唯一性
   - 支持同类型的多个技能（如 4-java-backend-dev、4-vue-frontend-dev）

4. **扩展性好**
   - 新增技能时选择合适的序号
   - 不影响现有技能

### 序号分配指南

**现有序号分配：**
- **0** - scrum-master（敏捷教练）
- **1** - business-expert（业务专家）
- **2** - product-manager（产品经理）
- **3** - system-architect（系统架构师）
- **4** - 开发类技能（java-backend-dev、vue-frontend-dev、nielsen-ui-design、frontend-design）
- **5** - 质量类技能（devops-engineer、webapp-testing）
- **6** - bug-handler（Bug处理专家）
- **7** - skill-creator（技能创建器）

**新增技能序号建议：**
- **8+** - 扩展类技能（如：security-expert、data-analyst、performance-optimizer）
- **同序号** - 同类型的不同技术栈（如：4-react-frontend-dev、4-python-backend-dev）

### 命名注意事项

1. **目录名 = SKILL.md 中的 name 字段**
   ```yaml
   # 目录：skills/8-security-expert/
   # SKILL.md frontmatter:
   ---
   name: 8-security-expert
   description: 【8】安全专家，...
   ---
   ```

2. **description 字段格式**
   ```yaml
   description: 【{编号}】{中文名称}，{职责描述}。当{场景1}、{场景2}、或{场景3}时使用。本技能{详细说明}。
   ```

3. **调用技能时使用完整名称**
   ```
   @8-security-expert 帮我进行安全评估
   ```

4. **缓存目录也使用相同命名**
   ```
   skills/.cache/8-security-expert/
   ```

## 敏捷团队技能组风格标准

### 技能命名和目录结构

**必须遵守的命名规范：**

1. **目录名称：** `{编号}-{英文名称}`
   - 示例：`8-security-expert`、`9-data-analyst`

2. **SKILL.md 的 name 字段：** 与目录名称完全一致
   ```yaml
   ---
   name: 8-security-expert
   ---
   ```

3. **description 字段：** 以【编号】开头
   ```yaml
   ---
   description: 【8】安全专家，负责系统安全评估...
   ---
   ```

4. **缓存目录：** `skills/.cache/{编号}-{英文名称}/`
   - 示例：`skills/.cache/8-security-expert/`

### SKILL.md 结构模板

```markdown
---
name: {编号}-{英文名称}
description: 【{编号}】{中文名称}，负责{职责描述}。当{使用场景1}、{使用场景2}、或{使用场景3}时使用。本技能{详细说明}。
---

# {中文名称}

> 🎯 **正在使用：{中文名称}技能** - {简要说明}

## 执行标准

**所有任务执行前，必须遵循以下标准：**

1. **读取项目配置**：读取 `PROJECT_CONFIG.md` 获取项目信息、技术栈、业务域等
2. **实时显示进度**：所有操作实时显示，让用户了解执行过程
3. **使用中文输出**：所有提示、说明、错误信息使用中文
4. **数据验证原则**：绝不瞎回答，所有回答必须基于真实数据验证

**详细执行标准参考：** `skills/.skill-execution-standard.md`

**数据验证标准参考：** `skills/.data-verification-standard.md`

### {技能名称}特殊要求

**{技能特定的数据验证要求}：**
- {要求1}
- {要求2}
- {要求3}

**回答前必须验证：**
1. {验证项1}
2. {验证项2}
3. {验证项3}

## 概述

{技能的详细概述，说明技能的作用和价值}

## 工作流程

{技能的主要工作流程，分步骤说明}

### 1. {步骤1名称}

{步骤1的详细说明}

### 2. {步骤2名称}

{步骤2的详细说明}

### 3. {步骤3名称}

{步骤3的详细说明}

## 团队主动协作

### 主动介入时机

**{技能名称}主动介入的时机：**
- 当{场景1}时，主动介入{行动1}
- 当{场景2}时，主动介入{行动2}
- 当{场景3}时，主动介入{行动3}

### 主动寻求帮助

**遇到问题时主动协作：**
- {问题1}时，主动联系`{编号}-{技能名称}`{说明}
- {问题2}时，主动联系`{编号}-{技能名称}`{说明}
- {问题3}时，主动联系`{编号}-{技能名称}`{说明}

### 主动提供帮助

**{技能名称}主动支持团队：**
- 主动{行动1}
- 主动{行动2}
- 主动{行动3}

## 资源文件

### references/

- **{文件名}.md** - {文件说明}

### assets/

- **{文件名}** - {文件说明}

## 缓存机制（Token优化）

### 工作原理

本技能使用智能缓存机制，大幅节约token消耗（节约率70-80%）：

**首次使用：**
- 分析{相关内容}
- 提取关键信息并生成缓存
- 保存到 `skills/.cache/{编号}-{英文名称}/`

**后续使用：**
- 优先加载缓存文件（快速、省token）
- 使用git diff识别变更
- 只读取变更的文件
- 增量更新缓存

### 缓存文件

缓存保存在 `skills/.cache/{编号}-{英文名称}/`：

- `{cache-file-1}.md` - {说明}
- `{cache-file-2}.md` - {说明}
- `_cache-meta.json` - 缓存元数据（版本、更新时间）

### 手动刷新

如需重新生成缓存（例如大规模重构后）：
```bash
rm -rf skills/.cache/{编号}-{英文名称}/
```

下次使用时会自动重新生成缓存。
```

### 关键风格要点

1. **中文优先**
   - 所有说明使用中文
   - 技术术语可保留英文，但建议添加中文解释
   - description 字段使用中文，包含【编号】标记

2. **执行标准统一**
   - 所有技能必须引用 `.skill-execution-standard.md`
   - 所有技能必须引用 `.data-verification-standard.md`
   - 必须说明技能特定的验证要求

3. **团队协作机制**
   - 必须包含"团队主动协作"部分
   - 说明主动介入时机
   - 说明主动寻求帮助的场景
   - 说明主动提供帮助的方式

4. **缓存优化**
   - 所有技能必须包含缓存机制说明
   - 说明缓存的工作原理
   - 说明缓存文件的位置和内容
   - 说明如何手动刷新缓存

5. **实时显示**
   - 所有操作必须实时显示进度
   - 使用 emoji 和格式化增强可读性
   - 让用户清楚了解每个步骤

6. **数据验证**
   - 强调"绝不瞎回答"原则
   - 所有回答必须基于真实数据
   - 明确标注数据来源
   - 不确定时明确说明

## 技能创建示例

### 示例1：创建安全专家技能

**用户输入：**
```
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

**生成的 SKILL.md：**
```markdown
---
name: 8-security-expert
description: 【8】安全专家，负责系统安全评估、漏洞扫描、安全加固和安全培训。当需要进行安全评估、发现安全漏洞需要修复、或需要制定安全规范时使用。本技能基于OWASP Top 10和行业最佳实践，提供全面的安全保障。
---

# 安全专家

> 🎯 **正在使用：安全专家技能** - 负责系统安全评估、漏洞扫描、安全加固和安全培训

## 执行标准

**所有任务执行前，必须遵循以下标准：**

1. **读取项目配置**：读取 `PROJECT_CONFIG.md` 获取项目信息、技术栈、业务域等
2. **实时显示进度**：所有操作实时显示，让用户了解执行过程
3. **使用中文输出**：所有提示、说明、错误信息使用中文
4. **数据验证原则**：绝不瞎回答，所有回答必须基于真实数据验证

**详细执行标准参考：** `skills/.skill-execution-standard.md`

**数据验证标准参考：** `skills/.data-verification-standard.md`

### 安全专家特殊要求

**安全评估的真实性和完整性：**
- 读取现有代码，验证安全漏洞
- 基于真实的代码和配置进行评估
- 所有安全建议必须基于实际发现的问题
- 明确标注漏洞位置（文件路径、行号）

**回答前必须验证：**
1. 检查代码中的安全漏洞（SQL注入、XSS、CSRF等）
2. 验证配置文件的安全性（密码、密钥等）
3. 检查依赖库的安全漏洞
4. 明确标注数据来源（文件路径、行号）
5. 如有不确定，明确说明并建议进一步检查

## 概述

本技能负责系统的安全评估、漏洞扫描、安全加固和安全培训。基于OWASP Top 10和行业最佳实践，提供全面的安全保障，确保系统免受常见安全威胁。

## 工作流程

### 1. 分析安全需求

- 理解系统的安全要求
- 识别关键资产和敏感数据
- 确定安全评估范围
- 制定安全评估计划

### 2. 执行安全扫描

- 代码安全审查（静态分析）
- 依赖库漏洞扫描
- 配置安全检查
- 运行时安全测试（动态分析）

### 3. 评估风险等级

- 识别发现的安全问题
- 评估漏洞的严重程度（高/中/低）
- 分析潜在影响和利用难度
- 确定修复优先级

### 4. 制定修复方案

- 针对每个安全问题提供修复建议
- 提供代码示例和最佳实践
- 考虑修复的可行性和成本
- 制定修复时间表

### 5. 验证修复效果

- 验证修复是否有效
- 确认没有引入新的安全问题
- 更新安全文档
- 提供安全培训和指导

## 团队主动协作

### 主动介入时机

**安全专家主动介入的时机：**
- 当`3-system-architect`设计架构时，主动介入进行安全架构评审
- 当`4-java-backend-dev`或`4-vue-frontend-dev`编写代码时，主动介入进行代码安全审查
- 当`5-devops-engineer`配置部署时，主动介入进行部署安全检查
- 当`6-bug-handler`报告安全相关bug时，主动介入进行安全分析和修复
- 当发现安全漏洞时，主动通知相关技能并协助修复

### 主动寻求帮助

**遇到问题时主动协作：**
- 架构安全设计不确定时，主动联系`3-system-architect`讨论安全架构方案
- 需要修复代码安全问题时，主动联系`4-java-backend-dev`或`4-vue-frontend-dev`协助实现
- 需要配置安全防护时，主动联系`5-devops-engineer`配置防火墙、WAF等
- 需要验证安全修复时，主动联系`5-webapp-testing`进行安全测试

### 主动提供帮助

**安全专家主动支持团队：**
- 主动为团队提供安全培训和指导
- 主动分享安全最佳实践和案例
- 主动审查关键代码的安全性
- 主动监控系统安全状态
- 主动更新安全规范和检查清单

## 资源文件

### references/

- **security-checklist.md** - 安全检查清单（OWASP Top 10）
- **secure-coding-guide.md** - 安全编码指南
- **vulnerability-database.md** - 常见漏洞数据库

### assets/

- **security-report-template.md** - 安全评估报告模板

## 缓存机制（Token优化）

### 工作原理

本技能使用智能缓存机制，大幅节约token消耗（节约率70-80%）：

**首次使用：**
- 分析项目代码和配置
- 提取安全相关信息并生成缓存
- 保存到 `skills/.cache/8-security-expert/`

**后续使用：**
- 优先加载缓存文件（快速、省token）
- 使用git diff识别变更
- 只读取变更的文件
- 增量更新缓存

### 缓存文件

缓存保存在 `skills/.cache/8-security-expert/`：

- `security-issues.md` - 已发现的安全问题
- `security-fixes.md` - 已修复的安全问题
- `security-config.md` - 安全配置摘要
- `_cache-meta.json` - 缓存元数据（版本、更新时间）

### 手动刷新

如需重新生成缓存（例如大规模重构后）：
```bash
rm -rf skills/.cache/8-security-expert/
```

下次使用时会自动重新生成缓存。
```

## 资源文件说明

### references/ 目录

**用途：** 存放参考文档和知识库

**适用场景：**
- 技术规范和标准
- 最佳实践指南
- 领域知识文档
- API文档和接口说明

**示例：**
- `security-checklist.md` - 安全检查清单
- `coding-standards.md` - 编码规范
- `api-documentation.md` - API文档
- `business-rules.md` - 业务规则

### assets/ 目录

**用途：** 存放模板和资源文件

**适用场景：**
- 文档模板
- 配置文件模板
- 代码模板
- 图片和图标

**示例：**
- `report-template.md` - 报告模板
- `config-template.yaml` - 配置模板
- `code-template.java` - 代码模板

### scripts/ 目录

**用途：** 存放可执行脚本

**适用场景：**
- 自动化任务脚本
- 数据处理脚本
- 工具脚本

**示例：**
- `security-scan.py` - 安全扫描脚本
- `generate-report.py` - 报告生成脚本
- `validate-config.py` - 配置验证脚本

## 技能优化建议

### 何时优化技能

1. **使用后发现问题**
   - 工作流程不清晰
   - 缺少必要的说明
   - 协作机制不完善

2. **项目需求变化**
   - 技术栈升级
   - 业务域扩展
   - 团队角色调整

3. **性能优化**
   - Token消耗过高
   - 响应速度慢
   - 缓存机制不完善

### 优化方法

1. **优化 SKILL.md**
   - 补充缺失的说明
   - 优化工作流程描述
   - 完善协作机制

2. **添加资源文件**
   - 添加 references/ 文档
   - 添加 assets/ 模板
   - 添加 scripts/ 脚本

3. **优化缓存机制**
   - 识别高频读取的内容
   - 设计合理的缓存结构
   - 实现增量更新逻辑

## 使用技能创建器

### 创建新技能

```
@7-skill-creator 我想创建一个新技能
```

然后按照引导提供技能信息即可。

### 优化现有技能

```
@7-skill-creator 帮我优化 {技能名称} 技能
```

说明需要优化的方面，技能创建器会帮你改进。

## 总结

技能创建器帮助你快速创建符合敏捷团队技能组风格的新技能，确保：

1. ✅ **风格统一** - 所有技能遵循相同的结构和规范
2. ✅ **标准完整** - 自动集成执行标准、数据验证、团队协作等机制
3. ✅ **易于维护** - 清晰的结构和文档，便于后续优化
4. ✅ **高效协作** - 内置团队协作机制，促进技能间配合
5. ✅ **性能优化** - 自动包含缓存机制，节约Token消耗

**让技能组持续成长，满足项目不断变化的需求！**

## Core Principles

### Concise is Key

The context window is a public good. Skills share the context window with everything else Claude needs: system prompt, conversation history, other Skills' metadata, and the actual user request.

**Default assumption: Claude is already very smart.** Only add context Claude doesn't already have. Challenge each piece of information: "Does Claude really need this explanation?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability:

**High freedom (text-based instructions)**: Use when multiple approaches are valid, decisions depend on context, or heuristics guide the approach.

**Medium freedom (pseudocode or scripts with parameters)**: Use when a preferred pattern exists, some variation is acceptable, or configuration affects behavior.

**Low freedom (specific scripts, few parameters)**: Use when operations are fragile and error-prone, consistency is critical, or a specific sequence must be followed.

Think of Claude as exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many routes (high freedom).

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   ├── description: (required)
│   │   └── compatibility: (optional, rarely needed)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

#### SKILL.md (required)

Every SKILL.md consists of:

- **Frontmatter** (YAML): Contains `name` and `description` fields (required), plus optional fields like `license`, `metadata`, and `compatibility`. Only `name` and `description` are read by Claude to determine when the skill triggers, so be clear and comprehensive about what the skill is and when it should be used. The `compatibility` field is for noting environment requirements (target product, system packages, etc.) but most skills don't need it.
- **Body** (Markdown): Instructions and guidance for using the skill. Only loaded AFTER the skill triggers (if at all).

#### Bundled Resources (optional)

##### Scripts (`scripts/`)

Executable code (Python/Bash/etc.) for tasks that require deterministic reliability or are repeatedly rewritten.

- **When to include**: When the same code is being rewritten repeatedly or deterministic reliability is needed
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Benefits**: Token efficient, deterministic, may be executed without loading into context
- **Note**: Scripts may still need to be read by Claude for patching or environment-specific adjustments

##### References (`references/`)

Documentation and reference material intended to be loaded as needed into context to inform Claude's process and thinking.

- **When to include**: For documentation that Claude should reference while working
- **Examples**: `references/finance.md` for financial schemas, `references/mnda.md` for company NDA template, `references/policies.md` for company policies, `references/api_docs.md` for API specifications
- **Use cases**: Database schemas, API documentation, domain knowledge, company policies, detailed workflow guides
- **Benefits**: Keeps SKILL.md lean, loaded only when Claude determines it's needed
- **Best practice**: If files are large (>10k words), include grep search patterns in SKILL.md
- **Avoid duplication**: Information should live in either SKILL.md or references files, not both. Prefer references files for detailed information unless it's truly core to the skill—this keeps SKILL.md lean while making information discoverable without hogging the context window. Keep only essential procedural instructions and workflow guidance in SKILL.md; move detailed reference material, schemas, and examples to references files.

##### Assets (`assets/`)

Files not intended to be loaded into context, but rather used within the output Claude produces.

- **When to include**: When the skill needs files that will be used in the final output
- **Examples**: `assets/logo.png` for brand assets, `assets/slides.pptx` for PowerPoint templates, `assets/frontend-template/` for HTML/React boilerplate, `assets/font.ttf` for typography
- **Use cases**: Templates, images, icons, boilerplate code, fonts, sample documents that get copied or modified
- **Benefits**: Separates output resources from documentation, enables Claude to use files without loading them into context

#### What to Not Include in a Skill

A skill should only contain essential files that directly support its functionality. Do NOT create extraneous documentation or auxiliary files, including:

- README.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- etc.

The skill should only contain the information needed for an AI agent to do the job at hand. It should not contain auxilary context about the process that went into creating it, setup and testing procedures, user-facing documentation, etc. Creating additional documentation files just adds clutter and confusion.

### Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (Unlimited because scripts can be executed without reading into context window)

#### Progressive Disclosure Patterns

Keep SKILL.md body to the essentials and under 500 lines to minimize context bloat. Split content into separate files when approaching this limit. When splitting out content into other files, it is very important to reference them from SKILL.md and describe clearly when to read them, to ensure the reader of the skill knows they exist and when to use them.

**Key principle:** When a skill supports multiple variations, frameworks, or options, keep only the core workflow and selection guidance in SKILL.md. Move variant-specific details (patterns, examples, configuration) into separate reference files.

**Pattern 1: High-level guide with references**

```markdown
# PDF Processing

## Quick start

Extract text with pdfplumber:
[code example]

## Advanced features

- **Form filling**: See [FORMS.md](FORMS.md) for complete guide
- **API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
- **Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
```

Claude loads FORMS.md, REFERENCE.md, or EXAMPLES.md only when needed.

**Pattern 2: Domain-specific organization**

For Skills with multiple domains, organize content by domain to avoid loading irrelevant context:

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When a user asks about sales metrics, Claude only reads sales.md.

Similarly, for skills supporting multiple frameworks or variants, organize by variant:

```
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

When the user chooses AWS, Claude only reads aws.md.

**Pattern 3: Conditional details**

Show basic content, link to advanced content:

```markdown
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Claude reads REDLINING.md or OOXML.md only when the user needs those features.

**Important guidelines:**

- **Avoid deeply nested references** - Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md.
- **Structure longer reference files** - For files longer than 100 lines, include a table of contents at the top so Claude can see the full scope when previewing.

## Skill Creation Process

Skill creation involves these steps:

1. Understand the skill with concrete examples
2. Plan reusable skill contents (scripts, references, assets)
3. Initialize the skill (run init_skill.py)
4. Edit the skill (implement resources and write SKILL.md)
5. Package the skill (run package_skill.py)
6. Iterate based on real usage

Follow these steps in order, skipping only if there is a clear reason why they are not applicable.

### Step 1: Understanding the Skill with Concrete Examples

Skip this step only when the skill's usage patterns are already clearly understood. It remains valuable even when working with an existing skill.

To create an effective skill, clearly understand concrete examples of how the skill will be used. This understanding can come from either direct user examples or generated examples that are validated with user feedback.

For example, when building an image-editor skill, relevant questions include:

- "What functionality should the image-editor skill support? Editing, rotating, anything else?"
- "Can you give some examples of how this skill would be used?"
- "I can imagine users asking for things like 'Remove the red-eye from this image' or 'Rotate this image'. Are there other ways you imagine this skill being used?"
- "What would a user say that should trigger this skill?"

To avoid overwhelming users, avoid asking too many questions in a single message. Start with the most important questions and follow up as needed for better effectiveness.

Conclude this step when there is a clear sense of the functionality the skill should support.

### Step 2: Planning the Reusable Skill Contents

To turn concrete examples into an effective skill, analyze each example by:

1. Considering how to execute on the example from scratch
2. Identifying what scripts, references, and assets would be helpful when executing these workflows repeatedly

Example: When building a `pdf-editor` skill to handle queries like "Help me rotate this PDF," the analysis shows:

1. Rotating a PDF requires re-writing the same code each time
2. A `scripts/rotate_pdf.py` script would be helpful to store in the skill

Example: When designing a `frontend-webapp-builder` skill for queries like "Build me a todo app" or "Build me a dashboard to track my steps," the analysis shows:

1. Writing a frontend webapp requires the same boilerplate HTML/React each time
2. An `assets/hello-world/` template containing the boilerplate HTML/React project files would be helpful to store in the skill

Example: When building a `big-query` skill to handle queries like "How many users have logged in today?" the analysis shows:

1. Querying BigQuery requires re-discovering the table schemas and relationships each time
2. A `references/schema.md` file documenting the table schemas would be helpful to store in the skill

To establish the skill's contents, analyze each concrete example to create a list of the reusable resources to include: scripts, references, and assets.

### Step 3: Initializing the Skill

At this point, it is time to actually create the skill.

Skip this step only if the skill being developed already exists, and iteration or packaging is needed. In this case, continue to the next step.

When creating a new skill from scratch, always run the `init_skill.py` script. The script conveniently generates a new template skill directory that automatically includes everything a skill requires, making the skill creation process much more efficient and reliable.

Usage:

```bash
scripts/init_skill.py <skill-name> --path <output-directory>
```

The script:

- Creates the skill directory at the specified path
- Generates a SKILL.md template with proper frontmatter and TODO placeholders
- Creates example resource directories: `scripts/`, `references/`, and `assets/`
- Adds example files in each directory that can be customized or deleted

After initialization, customize or remove the generated SKILL.md and example files as needed.

### Step 4: Edit the Skill

When editing the (newly-generated or existing) skill, remember that the skill is being created for another instance of Claude to use. Include information that would be beneficial and non-obvious to Claude. Consider what procedural knowledge, domain-specific details, or reusable assets would help another Claude instance execute these tasks more effectively.

#### Learn Proven Design Patterns

Consult these helpful guides based on your skill's needs:

- **Multi-step processes**: See references/workflows.md for sequential workflows and conditional logic
- **Specific output formats or quality standards**: See references/output-patterns.md for template and example patterns

These files contain established best practices for effective skill design.

#### Start with Reusable Skill Contents

To begin implementation, start with the reusable resources identified above: `scripts/`, `references/`, and `assets/` files. Note that this step may require user input. For example, when implementing a `brand-guidelines` skill, the user may need to provide brand assets or templates to store in `assets/`, or documentation to store in `references/`.

Added scripts must be tested by actually running them to ensure there are no bugs and that the output matches what is expected. If there are many similar scripts, only a representative sample needs to be tested to ensure confidence that they all work while balancing time to completion.

Any example files and directories not needed for the skill should be deleted. The initialization script creates example files in `scripts/`, `references/`, and `assets/` to demonstrate structure, but most skills won't need all of them.

#### Update SKILL.md

**Writing Guidelines:** Always use imperative/infinitive form.

##### Frontmatter

Write the YAML frontmatter with `name` and `description`:

- `name`: The skill name
- `description`: This is the primary triggering mechanism for your skill, and helps Claude understand when to use the skill.
  - Include both what the Skill does and specific triggers/contexts for when to use it.
  - Include all "when to use" information here - Not in the body. The body is only loaded after triggering, so "When to Use This Skill" sections in the body are not helpful to Claude.
  - Example description for a `docx` skill: "Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks"

Do not include any other fields in YAML frontmatter.

##### Body

Write instructions for using the skill and its bundled resources.

### Step 5: Packaging a Skill

Once development of the skill is complete, it must be packaged into a distributable .skill file that gets shared with the user. The packaging process automatically validates the skill first to ensure it meets all requirements:

```bash
scripts/package_skill.py <path/to/skill-folder>
```

Optional output directory specification:

```bash
scripts/package_skill.py <path/to/skill-folder> ./dist
```

The packaging script will:

1. **Validate** the skill automatically, checking:

   - YAML frontmatter format and required fields
   - Skill naming conventions and directory structure
   - Description completeness and quality
   - File organization and resource references

2. **Package** the skill if validation passes, creating a .skill file named after the skill (e.g., `my-skill.skill`) that includes all files and maintains the proper directory structure for distribution. The .skill file is a zip file with a .skill extension.

If validation fails, the script will report the errors and exit without creating a package. Fix any validation errors and run the packaging command again.

### Step 6: Iterate

After testing the skill, users may request improvements. Often this happens right after using the skill, with fresh context of how the skill performed.

**Iteration workflow:**

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Identify how SKILL.md or bundled resources should be updated
4. Implement changes and test again
