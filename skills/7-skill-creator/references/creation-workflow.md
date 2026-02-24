# 技能创建详细流程

## 第一步：理解需求（交互式引导）

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
- 4-backend-dev：后端安全实现
- 4-frontend-dev：前端安全实现
- 5-devops-engineer：部署安全配置

### 5️⃣ 资源文件需求

**是否需要以下资源：**
- [ ] scripts/ - 可执行脚本（例如：安全扫描脚本）
- [ ] references/ - 参考文档（例如：安全规范、最佳实践）
- [ ] assets/ - 资源文件（例如：模板、配置文件）

请提供以上信息，我会自动生成完整的技能文件。
```

## 第二步：读取项目配置

```markdown
## 📖 读取项目配置

正在读取 `PROJECT_CONFIG.md`...
✅ 项目名称：{project_name}
✅ 技术栈：{tech_stack}
✅ 业务域：{business_domains}
✅ 团队角色：{team_roles}

配置加载完成，开始生成技能...
```

## 第三步：生成技能文件

**自动生成以下内容：**

1. **技能目录** - 按照命名规范创建
   - 格式：`skills/{编号}-{英文名称}/`
   - 示例：`skills/8-security-expert/`

2. **SKILL.md** - 技能主文件
   - YAML frontmatter（name、description）
   - name 字段：`{编号}-{英文名称}`（与目录名一致）
   - description 字段：`【{编号}】{中文名称}，...`
   - 强制执行规范（引用 config/mandatory-rules.md）
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
   - 强制执行规范（引用 config/mandatory-rules.md）
   - 数据验证标准（引用 .data-verification-standard.md）
   - 团队共享文档机制（引用 .team-shared-docs.md）
   - 缓存优化机制
   - 中文输出规范

## 第四步：验证和优化

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
