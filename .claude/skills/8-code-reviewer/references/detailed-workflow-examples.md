# 代码审查详细工作流程示例

## 概述

本文档详细说明代码审查的7个步骤，包含完整的示例和输出格式。

## 步骤1：读取git变更文件列表

### 执行命令

```bash
git diff --cached --name-only
```

### 输出示例

```markdown
## 📋 读取变更文件列表

正在读取git暂存区的变更文件...

**变更文件：**
- backend/src/main/java/com/shop/user/UserController.java
- backend/src/main/java/com/shop/user/UserService.java
- frontend/src/views/user/UserList.vue
- frontend/src/api/user.js

**统计：**
- 总文件数：4
- 后端文件：2
- 前端文件：2
```

---

## 步骤2：检查文件大小（≤800行）

### 检查逻辑

```javascript
function checkFileSize(file) {
  const lines = countLines(file);
  
  if (lines > 800) {
    return {
      status: 'FAIL',
      message: `文件超过800行限制（当前：${lines}行）`,
      severity: 'CRITICAL'
    };
  } else if (lines > 600) {
    return {
      status: 'WARNING',
      message: `文件接近上限（当前：${lines}行），建议考虑拆分`,
      severity: 'WARNING'
    };
  } else {
    return {
      status: 'PASS',
      message: `文件大小符合规范（${lines}行）`,
      severity: 'INFO'
    };
  }
}
```

### 输出示例

```markdown
## 🔍 检查文件大小

### UserController.java
- 当前行数：245行
- 状态：✅ 通过
- 说明：文件大小符合规范

### UserService.java
- 当前行数：680行
- 状态：⚠️ 警告
- 说明：文件接近上限，建议考虑拆分

### UserList.vue
- 当前行数：156行
- 状态：✅ 通过
- 说明：文件大小符合规范

### user.js
- 当前行数：89行
- 状态：✅ 通过
- 说明：文件大小符合规范

**总结：**
- ✅ 通过：3个文件
- ⚠️ 警告：1个文件（UserService.java接近上限）
- ❌ 失败：0个文件
```

---

## 步骤3：检查代码质量（KISS原则、单一职责）

### 检查项

**KISS原则检查：**
- 方法复杂度（圈复杂度 ≤ 10）
- 嵌套层级（≤ 3层）
- 方法长度（≤ 50行）
- 参数数量（≤ 5个）

**单一职责检查：**
- 类职责是否单一
- 方法职责是否单一
- 是否存在God Class
- 是否存在Feature Envy

### 输出示例

```markdown
## 🔍 检查代码质量

### UserController.java

**KISS原则：**
- ✅ 方法复杂度：平均3.2（≤10）
- ✅ 嵌套层级：最大2层（≤3）
- ✅ 方法长度：平均18行（≤50）
- ✅ 参数数量：最多3个（≤5）

**单一职责：**
- ✅ 类职责单一：仅负责用户相关的HTTP请求处理
- ✅ 方法职责单一：每个方法只处理一个HTTP端点
- ✅ 无God Class问题
- ✅ 无Feature Envy问题

**评分：** 10/10 ✅

---

### UserService.java

**KISS原则：**
- ⚠️ 方法复杂度：平均6.8，最高12（超标）
- ✅ 嵌套层级：最大2层（≤3）
- ⚠️ 方法长度：平均32行，最长65行（超标）
- ✅ 参数数量：最多4个（≤5）

**单一职责：**
- ⚠️ 类职责：包含用户管理、权限验证、数据统计（职责过多）
- ⚠️ 方法职责：部分方法做了多件事
- ⚠️ 存在God Class倾向
- ✅ 无Feature Envy问题

**问题详情：**

1. **方法过长：** `updateUserProfile()` 方法65行
   - 位置：UserService.java:156-221
   - 建议：拆分为多个小方法

2. **职责过多：** UserService类包含3个职责
   - 用户管理（CRUD）
   - 权限验证
   - 数据统计
   - 建议：拆分为UserService、UserPermissionService、UserStatisticsService

**评分：** 6/10 ⚠️

**建议：**
- 重构`updateUserProfile()`方法，拆分为多个小方法
- 考虑拆分UserService类，遵循单一职责原则
```

---

## 步骤4：检查代码规范（命名、格式、注释）

### 检查项

**命名规范：**
- 类名：PascalCase
- 方法名：camelCase
- 变量名：camelCase
- 常量名：UPPER_SNAKE_CASE
- 包名：lowercase

**格式规范：**
- 缩进：2空格（前端）或4空格（后端）
- 行长度：≤120字符
- 空行使用
- 括号风格

**注释规范：**
- 类注释：必须有
- 公共方法注释：必须有
- 复杂逻辑注释：建议有
- TODO/FIXME标记

### 输出示例

```markdown
## 🔍 检查代码规范

### UserController.java

**命名规范：**
- ✅ 类名：UserController（PascalCase）
- ✅ 方法名：getUserList, createUser（camelCase）
- ✅ 变量名：userId, userName（camelCase）
- ✅ 常量名：MAX_PAGE_SIZE（UPPER_SNAKE_CASE）

**格式规范：**
- ✅ 缩进：4空格
- ✅ 行长度：最长98字符（≤120）
- ✅ 空行使用合理
- ✅ 括号风格一致

**注释规范：**
- ✅ 类注释：完整
- ✅ 公共方法注释：完整
- ✅ 复杂逻辑注释：充分
- ✅ 无TODO/FIXME标记

**评分：** 10/10 ✅

---

### user.js

**命名规范：**
- ✅ 函数名：getUserList, createUser（camelCase）
- ✅ 变量名：userId, userName（camelCase）
- ✅ 常量名：API_BASE_URL（UPPER_SNAKE_CASE）

**格式规范：**
- ✅ 缩进：2空格
- ✅ 行长度：最长85字符（≤120）
- ✅ 空行使用合理
- ✅ 括号风格一致

**注释规范：**
- ⚠️ 函数注释：部分缺失
- ⚠️ 复杂逻辑注释：不足
- ✅ 无TODO/FIXME标记

**问题详情：**

1. **缺少函数注释：** `updateUser()` 函数
   - 位置：user.js:45
   - 建议：添加JSDoc注释

2. **复杂逻辑缺少注释：** 数据转换逻辑
   - 位置：user.js:67-82
   - 建议：添加注释说明转换规则

**评分：** 7/10 ⚠️

**建议：**
- 为所有导出函数添加JSDoc注释
- 为复杂的数据转换逻辑添加注释
```

---

## 步骤5：检查安全问题（敏感信息、SQL注入等）

### 检查项

**敏感信息检查：**
- 密码、密钥、token
- API密钥
- 数据库连接字符串
- 个人身份信息（PII）

**安全漏洞检查：**
- SQL注入
- XSS跨站脚本
- CSRF跨站请求伪造
- 路径遍历
- 命令注入

### 输出示例

```markdown
## 🔍 检查安全问题

### UserController.java

**敏感信息检查：**
- ✅ 无硬编码密码
- ✅ 无硬编码API密钥
- ✅ 无硬编码数据库连接字符串
- ✅ 无明文存储的敏感信息

**安全漏洞检查：**
- ✅ 无SQL注入风险（使用参数化查询）
- ✅ 无XSS风险（输入验证和输出转义）
- ✅ 无CSRF风险（使用CSRF token）
- ✅ 无路径遍历风险
- ✅ 无命令注入风险

**评分：** 10/10 ✅

---

### config.js

**敏感信息检查：**
- ❌ 发现硬编码API密钥
- ❌ 发现硬编码数据库密码

**问题详情：**

1. **硬编码API密钥：**
   ```javascript
   const API_KEY = 'sk-1234567890abcdef';  // ❌ 不要硬编码
   ```
   - 位置：config.js:12
   - 建议：使用环境变量 `process.env.API_KEY`

2. **硬编码数据库密码：**
   ```javascript
   const DB_PASSWORD = 'mypassword123';  // ❌ 不要硬编码
   ```
   - 位置：config.js:18
   - 建议：使用环境变量 `process.env.DB_PASSWORD`

**评分：** 0/10 ❌ **严重安全问题**

**必须修复：**
- 移除所有硬编码的敏感信息
- 使用环境变量或密钥管理服务
- 不要将敏感信息提交到版本控制
```

---

## 步骤6：生成审查报告

### 报告格式

```markdown
# 代码审查报告

**审查时间：** 2026-02-15 14:30:25
**审查人：** Code Reviewer (AI)
**变更文件数：** 4

---

## 📊 审查总结

| 检查项 | 通过 | 警告 | 失败 |
|--------|------|------|------|
| 文件大小 | 3 | 1 | 0 |
| 代码质量 | 1 | 1 | 0 |
| 代码规范 | 1 | 1 | 0 |
| 安全问题 | 2 | 0 | 1 |

**总体评分：** 6.5/10 ⚠️

**审查结果：** ❌ 不通过（存在严重安全问题）

---

## 🔴 严重问题（必须修复）

### 1. 硬编码敏感信息
- **文件：** config.js
- **位置：** 第12行、第18行
- **问题：** 硬编码API密钥和数据库密码
- **影响：** 严重安全风险，可能导致数据泄露
- **修复建议：**
  ```javascript
  // ❌ 错误
  const API_KEY = 'sk-1234567890abcdef';
  
  // ✅ 正确
  const API_KEY = process.env.API_KEY;
  ```

---

## ⚠️ 警告问题（建议修复）

### 1. 文件接近大小上限
- **文件：** UserService.java
- **当前行数：** 680行
- **建议：** 考虑拆分，避免超过800行限制

### 2. 方法过长
- **文件：** UserService.java
- **方法：** updateUserProfile()
- **当前行数：** 65行
- **建议：** 拆分为多个小方法（≤50行）

### 3. 类职责过多
- **文件：** UserService.java
- **问题：** 包含用户管理、权限验证、数据统计3个职责
- **建议：** 拆分为UserService、UserPermissionService、UserStatisticsService

### 4. 缺少函数注释
- **文件：** user.js
- **位置：** 第45行 updateUser()
- **建议：** 添加JSDoc注释

---

## ✅ 通过的检查

- UserController.java：代码质量、代码规范、安全检查全部通过
- UserList.vue：所有检查通过
- user.js：文件大小、命名规范通过

---

## 📋 修复清单

**必须修复（阻止提交）：**
- [ ] config.js：移除硬编码的API密钥和数据库密码

**建议修复（不阻止提交）：**
- [ ] UserService.java：拆分updateUserProfile()方法
- [ ] UserService.java：考虑拆分类，遵循单一职责
- [ ] user.js：添加函数注释

---

## 🚫 审查决定

**结果：** ❌ 不通过

**原因：** 存在严重安全问题（硬编码敏感信息）

**下一步：**
1. 修复config.js中的安全问题
2. 重新提交代码审查
3. 建议同时修复警告问题，提高代码质量

**预计修复时间：** 15分钟
```

---

## 步骤7：决定是否通过

### 决策规则

```javascript
function makeDecision(report) {
  // 规则1：存在严重问题 → 不通过
  if (report.criticalIssues.length > 0) {
    return {
      decision: 'REJECT',
      reason: '存在严重问题，必须修复',
      blockCommit: true
    };
  }
  
  // 规则2：警告问题过多 → 需修改
  if (report.warnings.length > 5) {
    return {
      decision: 'NEEDS_WORK',
      reason: '警告问题过多，建议修复',
      blockCommit: false
    };
  }
  
  // 规则3：所有检查通过 → 通过
  if (report.warnings.length === 0) {
    return {
      decision: 'APPROVE',
      reason: '所有检查通过',
      blockCommit: false
    };
  }
  
  // 规则4：少量警告 → 通过但建议改进
  return {
    decision: 'APPROVE_WITH_COMMENTS',
    reason: '通过，但建议修复警告问题',
    blockCommit: false
  };
}
```

### 输出示例

#### 场景1：不通过（存在严重问题）

```markdown
## 🚫 审查决定：不通过

**决定：** ❌ 不通过
**原因：** 存在严重安全问题

**严重问题：**
- config.js：硬编码敏感信息（API密钥、数据库密码）

**影响：**
- 阻止git commit
- 必须修复后才能提交

**下一步：**
1. 修复config.js中的安全问题
2. 运行 `git add config.js`
3. 重新运行 `git commit`

**预计修复时间：** 15分钟
```

#### 场景2：通过但有建议

```markdown
## ✅ 审查决定：通过

**决定：** ✅ 通过（有改进建议）
**原因：** 代码质量良好，但有改进空间

**改进建议：**
- UserService.java：建议拆分过长的方法
- user.js：建议添加函数注释

**影响：**
- 不阻止git commit
- 建议在后续迭代中改进

**可以继续提交：**
```bash
git commit -m "feat: 实现用户管理功能"
```

**后续改进：**
- 创建技术债务卡片跟踪改进项
- 在下次迭代中优先处理
```

#### 场景3：完美通过

```markdown
## ✅ 审查决定：通过

**决定：** ✅ 完美通过
**原因：** 所有检查通过，代码质量优秀

**检查结果：**
- ✅ 文件大小：符合规范
- ✅ 代码质量：KISS原则、单一职责
- ✅ 代码规范：命名、格式、注释
- ✅ 安全检查：无安全问题

**总体评分：** 10/10 ✅

**可以继续提交：**
```bash
git commit -m "feat: 实现用户管理功能"
```

**点赞：** 👍 代码质量优秀，继续保持！
```

---

## 总结

代码审查的7个步骤确保：
1. ✅ **完整性** - 检查所有变更文件
2. ✅ **规范性** - 遵循代码规范和质量标准
3. ✅ **安全性** - 防止敏感信息泄露和安全漏洞
4. ✅ **可维护性** - 保持代码简洁、清晰、易维护
5. ✅ **可追溯性** - 生成详细的审查报告
6. ✅ **强制性** - 不通过则阻止提交
7. ✅ **指导性** - 提供具体的修复建议

让代码质量成为团队的基因！
