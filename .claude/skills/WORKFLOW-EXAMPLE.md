# 全自动化敏捷团队工作流程示例

**本文档展示全自动化敏捷团队的实际运行效果**

## 场景：开发用户登录功能

**用户需求：** "开发一个用户登录功能"

---

## 第1步：Scrum Master接收任务

### 👋 我是 Scrum Master
**角色：** 敏捷教练
**职责：** 组织敏捷流程，协调团队，移除障碍

### 🔍 分析任务

**用户任务：** 开发一个用户登录功能

#### 读取项目配置
正在读取 PROJECT_CONFIG.md...
- ✅ 项目：电商平台
- ✅ 技术栈：Vue 3 + Spring Boot + MySQL
- ✅ 业务域：user（用户管理）

#### 任务类型识别
正在分析任务类型...

**识别结果：**
- 任务类型：新功能开发
- 涉及业务域：user（用户管理）
- 复杂度：中等
- 需要的角色：Product Manager、System Architect、Backend Developer、Frontend Developer、UI Designer、Tester

### 🏗️ 创建敏捷团队

正在创建团队：user-login-team...
✅ 团队已创建

正在启动团队成员...
- ✅ Product Manager（产品经理）
- ✅ System Architect（系统架构师）
- ✅ Backend Developer（后端开发）
- ✅ Frontend Developer（前端开发）
- ✅ UI Designer（UI设计师）
- ✅ Tester（测试工程师）

### 📋 创建任务列表

**任务列表：**
- Task #1: 需求分析（Product Manager）
- Task #2: 编写用户故事（Product Manager，依赖Task #1）
- Task #3: 架构设计（System Architect，依赖Task #2）
- Task #4: 后端开发（Backend Developer，依赖Task #3）
- Task #5: 前端开发（Frontend Developer，依赖Task #3）
- Task #6: UI设计审核（UI Designer，依赖Task #5）
- Task #7: 测试（Tester，依赖Task #4和Task #6）

✅ 所有任务已分配，团队成员开始工作...

---

## 第2步：Product Manager - 需求分析

### 👋 我是 Product Manager
**角色：** 产品经理
**职责：** 需求分析、用户故事编写、需求变更管理

### 📋 执行任务：需求分析

#### 读取项目配置
正在读取 PROJECT_CONFIG.md...
✅ 项目上下文已加载

#### 分析用户需求
正在分析用户任务：开发一个用户登录功能...

**需求分析结果：**
- 业务目标：用户通过用户名和密码登录系统
- 用户角色：普通用户、管理员
- 核心功能：登录、记住密码、忘记密码
- 业务规则：
  - 用户名和密码必填
  - 密码错误3次锁定账户30分钟
  - 登录成功后跳转到首页
- 验收标准：
  - 用户可以使用正确的用户名和密码登录
  - 密码错误时显示错误提示
  - 登录成功后跳转到首页

#### 保存需求文档
正在保存到共享目录：skills/.cache/shared/requirements/user-login.md...
✅ 需求文档已保存

---

### 📋 执行任务：编写用户故事

#### 读取需求文档
正在读取：skills/.cache/shared/requirements/user-login.md...
✅ 需求文档已加载

#### 编写用户故事

**用户故事1：用户登录**
```
作为 普通用户
我想要 使用用户名和密码登录系统
以便 访问我的个人信息和进行购物

验收标准：
- Given 用户在登录页面
- When 用户输入正确的用户名和密码并点击登录
- Then 系统验证通过，跳转到首页
- And 显示用户欢迎信息
```

**用户故事2：记住密码**
```
作为 普通用户
我想要 勾选"记住密码"选项
以便 下次登录时自动填充密码

验收标准：
- Given 用户在登录页面
- When 用户勾选"记住密码"并成功登录
- Then 下次访问登录页面时自动填充用户名和密码
```

**用户故事3：忘记密码**
```
作为 普通用户
我想要 通过邮箱重置密码
以便 在忘记密码时恢复账户访问

验收标准：
- Given 用户在登录页面
- When 用户点击"忘记密码"并输入邮箱
- Then 系统发送重置密码邮件
- And 用户通过邮件链接重置密码
```

#### 保存用户故事
正在保存到共享目录：skills/.cache/shared/requirements/user-login-stories.md...
✅ 用户故事已保存

✅ Product Manager任务完成

---

## 第3步：System Architect - 架构设计

### 👋 我是 System Architect
**角色：** 系统架构师
**职责：** 架构设计、技术选型、代码审查

### 🏗️ 执行任务：架构设计

#### 读取共享文档
正在读取需求文档和用户故事...
- ✅ requirements/user-login.md
- ✅ requirements/user-login-stories.md

#### 设计架构方案

**领域模型：**
- User（用户实体）：userId, username, password, email, status
- LoginRecord（登录记录）：recordId, userId, loginTime, ipAddress

**API端点：**
- POST /api/v1/auth/login - 用户登录
- POST /api/v1/auth/logout - 用户登出
- POST /api/v1/auth/forgot-password - 忘记密码
- POST /api/v1/auth/reset-password - 重置密码

**技术选型：**
- 认证方式：JWT Token
- 密码加密：BCrypt
- 会话管理：Redis
- 前端状态：Pinia

#### 保存架构文档
正在保存到共享目录：skills/.cache/shared/architecture/user-login.md...
✅ 架构文档已保存

正在保存API设计：skills/.cache/shared/api-design/user-login-api.md...
✅ API设计已保存

✅ System Architect任务完成

---

## 第4步：Backend Developer - 后端开发

### 👋 我是 Backend Developer
**角色：** 后端开发工程师
**职责：** 实现后端功能、API接口、业务逻辑

### 💻 执行任务：后端开发

#### 读取共享文档
正在读取架构设计和API契约...
- ✅ architecture/user-login.md
- ✅ api-design/user-login-api.md

#### 读取编码规范
正在读取 PROJECT_CONFIG.md 中的编码规范...
✅ 编码规范已加载

#### 实现领域模型
正在实现领域模型...

**实现文件：**
- ✅ user/domain/model/User.java
- ✅ user/domain/model/LoginRecord.java

#### 实现业务逻辑
正在实现业务逻辑...

**实现文件：**
- ✅ user/application/service/AuthService.java
- ✅ user/domain/repository/UserRepository.java

#### 实现API接口
正在实现API接口...

**实现文件：**
- ✅ user/interfaces/controller/AuthController.java

#### 代码质量自检
正在进行代码质量检查...
- ✅ 编码规范检查通过
- ✅ 单元测试覆盖率：85%
- ✅ 代码审查通过

✅ Backend Developer任务完成

---

## 第5步：Frontend Developer - 前端开发

### 👋 我是 Frontend Developer
**角色：** 前端开发工程师
**职责：** 实现前端功能、页面组件、API对接

### 🎨 执行任务：前端开发

#### 读取共享文档
正在读取架构设计和API契约...
- ✅ architecture/user-login.md
- ✅ api-design/user-login-api.md

#### 读取编码规范
正在读取 PROJECT_CONFIG.md 中的编码规范...
✅ 编码规范已加载

#### 实现页面组件
正在实现页面组件...

**实现文件：**
- ✅ src/views/auth/LoginPage.vue
- ✅ src/components/auth/LoginForm.vue

#### 实现状态管理
正在实现状态管理...

**实现文件：**
- ✅ src/stores/auth.ts

#### 实现API对接
正在实现API对接...

**实现文件：**
- ✅ src/api/auth.ts

#### 代码质量自检
正在进行代码质量检查...
- ✅ 编码规范检查通过
- ✅ 组件测试通过
- ⏳ 等待UI设计师审核...

✅ Frontend Developer任务完成（等待UI审核）

---

## 第6步：UI Designer - UI设计审核

### 👋 我是 UI Designer
**角色：** UI设计师
**职责：** 审核页面设计，确保符合Nielsen十大可用性原则

### 🎨 执行任务：UI设计审核

#### 读取前端代码
正在读取前端页面代码...
- ✅ src/views/auth/LoginPage.vue
- ✅ src/components/auth/LoginForm.vue

#### 审核页面设计
正在审核页面设计，检查Nielsen十大可用性原则...

**审核结果：**
1. ✅ 系统状态可见性 - 登录按钮有加载状态
2. ✅ 系统与现实世界的匹配 - 使用"登录"而非"Sign In"
3. ✅ 用户控制和自由 - 提供"取消"按钮
4. ✅ 一致性和标准 - 遵循Element Plus设计规范
5. ✅ 错误预防 - 密码输入框有显示/隐藏切换
6. ✅ 识别而非回忆 - 表单字段有清晰标签
7. ✅ 灵活性和效率 - 支持Enter键提交
8. ✅ 美学和简约设计 - 界面简洁，无冗余信息
9. ✅ 帮助用户识别、诊断和从错误中恢复 - 错误提示清晰
10. ✅ 帮助和文档 - 提供"忘记密码"链接

#### 保存审核报告
正在保存审核报告：skills/.cache/shared/ui-review/user-login-ui-review.md...
✅ 审核报告已保存

✅ UI Designer任务完成

---

## 第7步：Tester - 测试

### 👋 我是 Tester
**角色：** 测试工程师
**职责：** 编写测试用例、执行测试、输出测试报告

### 🧪 执行任务：测试

#### 读取共享文档
正在读取需求文档和用户故事...
- ✅ requirements/user-login.md
- ✅ requirements/user-login-stories.md

#### 编写测试用例

**测试用例1：正常登录**
- 前置条件：用户已注册
- 测试步骤：输入正确的用户名和密码，点击登录
- 预期结果：登录成功，跳转到首页

**测试用例2：密码错误**
- 前置条件：用户已注册
- 测试步骤：输入正确的用户名和错误的密码，点击登录
- 预期结果：显示"用户名或密码错误"提示

**测试用例3：账户锁定**
- 前置条件：用户已注册
- 测试步骤：连续3次输入错误密码
- 预期结果：账户被锁定30分钟，显示锁定提示

**测试用例4：记住密码**
- 前置条件：用户已注册
- 测试步骤：勾选"记住密码"并登录，关闭浏览器后重新打开
- 预期结果：用户名和密码自动填充

**测试用例5：忘记密码**
- 前置条件：用户已注册
- 测试步骤：点击"忘记密码"，输入邮箱，提交
- 预期结果：收到重置密码邮件

#### 执行测试
正在执行测试...

**测试结果：**
- ✅ 测试用例1：通过
- ✅ 测试用例2：通过
- ✅ 测试用例3：通过
- ✅ 测试用例4：通过
- ✅ 测试用例5：通过

#### 生成测试报告

**测试报告：**
- 总用例数：5
- 通过：5
- 失败：0
- 通过率：100%

#### 保存测试报告
正在保存测试报告：skills/.cache/shared/test-reports/user-login-test-report.md...
✅ 测试报告已保存

✅ Tester任务完成

---

## 第8步：Scrum Master - 交付总结

### 👋 我是 Scrum Master
**角色：** 敏捷教练
**职责：** 组织敏捷流程，协调团队，移除障碍

### ✅ 任务完成

#### 整合结果
正在整合所有团队成员的工作成果...

**交付内容：**
- ✅ 需求文档：requirements/user-login.md
- ✅ 用户故事：requirements/user-login-stories.md
- ✅ 架构设计：architecture/user-login.md
- ✅ API设计：api-design/user-login-api.md
- ✅ 后端代码：user/domain/model/User.java, user/application/service/AuthService.java, user/interfaces/controller/AuthController.java
- ✅ 前端代码：src/views/auth/LoginPage.vue, src/components/auth/LoginForm.vue, src/stores/auth.ts, src/api/auth.ts
- ✅ UI审核报告：ui-review/user-login-ui-review.md
- ✅ 测试报告：test-reports/user-login-test-report.md

#### 更新PROJECT_CONFIG.md
正在检查是否需要更新项目配置...
✅ 项目配置已更新（新增API端点）

#### 清理团队资源
正在使用TeamDelete清理团队资源...
✅ 团队资源已清理

### 📊 交付总结

**功能：** 用户登录功能
**状态：** ✅ 已完成
**测试通过率：** 100%
**代码质量：** ✅ 通过

**输出文件：**
- 📄 测试报告：skills/.cache/shared/test-reports/user-login-test-report.md

🎉 任务完成！

---

## 测试报告详情

### 用户登录功能测试报告

**测试时间：** 2026-02-12 18:00:00
**测试人员：** Tester
**测试环境：** 开发环境

#### 测试概述

**测试目标：** 验证用户登录功能的正确性和可用性
**测试范围：** 用户登录、记住密码、忘记密码、账户锁定

#### 测试用例

##### 用例1：正常登录
- **前置条件：** 用户已注册（用户名：testuser，密码：Test@123）
- **测试步骤：**
  1. 打开登录页面
  2. 输入用户名：testuser
  3. 输入密码：Test@123
  4. 点击"登录"按钮
- **预期结果：** 登录成功，跳转到首页，显示"欢迎，testuser"
- **实际结果：** 登录成功，跳转到首页，显示"欢迎，testuser"
- **测试状态：** ✅ 通过

##### 用例2：密码错误
- **前置条件：** 用户已注册（用户名：testuser）
- **测试步骤：**
  1. 打开登录页面
  2. 输入用户名：testuser
  3. 输入错误密码：WrongPassword
  4. 点击"登录"按钮
- **预期结果：** 显示"用户名或密码错误"提示
- **实际结果：** 显示"用户名或密码错误"提示
- **测试状态：** ✅ 通过

##### 用例3：账户锁定
- **前置条件：** 用户已注册（用户名：testuser）
- **测试步骤：**
  1. 打开登录页面
  2. 连续3次输入错误密码
  3. 第4次尝试登录
- **预期结果：** 显示"账户已被锁定30分钟，请稍后再试"
- **实际结果：** 显示"账户已被锁定30分钟，请稍后再试"
- **测试状态：** ✅ 通过

##### 用例4：记住密码
- **前置条件：** 用户已注册（用户名：testuser，密码：Test@123）
- **测试步骤：**
  1. 打开登录页面
  2. 输入用户名和密码
  3. 勾选"记住密码"
  4. 点击"登录"按钮
  5. 关闭浏览器
  6. 重新打开登录页面
- **预期结果：** 用户名和密码自动填充
- **实际结果：** 用户名和密码自动填充
- **测试状态：** ✅ 通过

##### 用例5：忘记密码
- **前置条件：** 用户已注册（邮箱：test@example.com）
- **测试步骤：**
  1. 打开登录页面
  2. 点击"忘记密码"
  3. 输入邮箱：test@example.com
  4. 点击"提交"按钮
  5. 检查邮箱
- **预期结果：** 收到重置密码邮件，包含重置链接
- **实际结果：** 收到重置密码邮件，包含重置链接
- **测试状态：** ✅ 通过

#### 测试结果统计

- **总用例数：** 5
- **通过：** 5
- **失败：** 0
- **通过率：** 100%

#### 问题列表

无问题

#### 测试结论

用户登录功能测试全部通过，功能正常，可以发布。

---

## 总结

通过全自动化敏捷团队工作流程，我们成功完成了用户登录功能的开发：

1. **Scrum Master** 接收任务，分析任务类型，创建团队，分配任务
2. **Product Manager** 分析需求，编写用户故事
3. **System Architect** 设计架构，定义API契约
4. **Backend Developer** 实现后端功能，通过代码质量自检
5. **Frontend Developer** 实现前端功能，等待UI审核
6. **UI Designer** 审核页面设计，确保符合可用性原则
7. **Tester** 编写测试用例，执行测试，输出测试报告
8. **Scrum Master** 整合结果，更新配置，清理资源

**整个流程全自动化，用户只需提出需求，团队自动完成所有工作，最终输出测试报告。**
