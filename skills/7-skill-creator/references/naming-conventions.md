# 技能命名规范详解

## 为什么使用"序号-技能名称"格式？

1. **清晰的分类**
   - 通过序号快速识别技能类型
   - 便于组织和管理技能

2. **调用方便**
   - 使用 `@{编号}-{英文名称}` 调用技能
   - 例如：`@8-security-expert`

3. **避免冲突**
   - 序号确保技能名称唯一性
   - 支持同类型的多个技能（如 4-backend-dev、4-frontend-dev）

4. **扩展性好**
   - 新增技能时选择合适的序号
   - 不影响现有技能

## 序号分配指南

**现有序号分配：**
- **0** - scrum-master（敏捷教练）
- **1** - business-expert（业务专家）
- **2** - product-manager（产品经理）
- **3** - system-architect（系统架构师）
- **4** - 开发类技能（backend-dev、frontend-dev、nielsen-ui-design、frontend-design）
- **5** - 质量类技能（devops-engineer、webapp-testing）
- **6** - bug-handler（Bug处理专家）
- **7** - skill-creator（技能创建器）

**新增技能序号建议：**
- **8+** - 扩展类技能（如：security-expert、data-analyst、performance-optimizer）
- **同序号** - 同类型的不同技术栈（如：4-react-frontend-dev、4-python-backend-dev）

## 命名注意事项

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
   .cache/8-security-expert/
   ```

## 命名规范（必须遵守）

**格式：** `{编号}-{英文名称}`

**规则：**
- **编号：** 必须是数字
- **分隔符：** 必须使用连字符 `-`
- **英文名称：** 小写字母，多个单词用连字符连接

**示例：**
- ✅ 正确：`8-security-expert`、`9-data-analyst`、`10-performance-optimizer`
- ❌ 错误：`security-expert`（缺少编号）、`8_security_expert`（错误分隔符）、`8-SecurityExpert`（大写字母）
