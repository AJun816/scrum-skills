# 安全检查清单

**本文档提供详细的安全检查清单，确保代码无安全漏洞**

## OWASP Top 10 检查

### 1. 注入攻击（Injection）

**SQL注入：**
- [ ] 所有SQL查询使用参数化
- [ ] 无字符串拼接SQL
- [ ] 使用ORM框架

**示例（错误）：**
```java
// ❌ 危险：SQL注入风险
String sql = "SELECT * FROM users WHERE username = '" + username + "'";
```

**示例（正确）：**
```java
// ✅ 安全：参数化查询
String sql = "SELECT * FROM users WHERE username = ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, username);
```

**NoSQL注入：**
- [ ] MongoDB查询使用参数化
- [ ] 验证和清理用户输入

### 2. 失效的身份认证（Broken Authentication）

**检查项：**
- [ ] 密码强度要求（长度、复杂度）
- [ ] 密码加密存储（BCrypt、Argon2）
- [ ] 会话超时设置
- [ ] 登录失败次数限制
- [ ] 双因素认证（如需要）

**示例（错误）：**
```java
// ❌ 危险：明文存储密码
user.setPassword(password);
```

**示例（正确）：**
```java
// ✅ 安全：加密存储密码
String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
user.setPassword(hashedPassword);
```

### 3. 敏感数据泄露（Sensitive Data Exposure）

**检查项：**
- [ ] 无密码、密钥硬编码
- [ ] 无数据库连接字符串硬编码
- [ ] 无API密钥硬编码
- [ ] 敏感数据加密传输（HTTPS）
- [ ] 敏感数据加密存储
- [ ] 日志不记录敏感信息

**示例（错误）：**
```java
// ❌ 危险：密钥硬编码
String apiKey = "sk-1234567890abcdef";
```

**示例（正确）：**
```java
// ✅ 安全：从环境变量读取
String apiKey = System.getenv("API_KEY");
```

### 4. XML外部实体（XXE）

**检查项：**
- [ ] XML解析器禁用外部实体
- [ ] 使用安全的XML解析库

**示例（正确）：**
```java
// ✅ 安全：禁用外部实体
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
```

### 5. 失效的访问控制（Broken Access Control）

**检查项：**
- [ ] 所有敏感操作校验权限
- [ ] 不依赖客户端权限校验
- [ ] 使用白名单而非黑名单
- [ ] 防止越权访问

**示例（错误）：**
```java
// ❌ 危险：未校验权限
@GetMapping("/admin/users")
public List<User> getUsers() {
    return userService.getAllUsers();
}
```

**示例（正确）：**
```java
// ✅ 安全：校验权限
@GetMapping("/admin/users")
@PreAuthorize("hasRole('ADMIN')")
public List<User> getUsers() {
    return userService.getAllUsers();
}
```

### 6. 安全配置错误（Security Misconfiguration）

**检查项：**
- [ ] 生产环境关闭调试模式
- [ ] 移除默认账号和密码
- [ ] 错误信息不暴露系统内部信息
- [ ] 安全头配置（CSP、X-Frame-Options等）

### 7. 跨站脚本（XSS）

**检查项：**
- [ ] 用户输入已转义
- [ ] 无危险的innerHTML使用
- [ ] 使用框架的文本插值
- [ ] Content-Security-Policy配置

**示例（错误）：**
```javascript
// ❌ 危险：XSS风险
element.innerHTML = userInput;
```

**示例（正确）：**
```javascript
// ✅ 安全：使用textContent
element.textContent = userInput;

// 或使用Vue的文本插值
<div>{{ userInput }}</div>
```

### 8. 不安全的反序列化（Insecure Deserialization）

**检查项：**
- [ ] 不反序列化不可信数据
- [ ] 使用安全的序列化格式（JSON）
- [ ] 验证反序列化数据

### 9. 使用含有已知漏洞的组件（Using Components with Known Vulnerabilities）

**检查项：**
- [ ] 定期更新依赖库
- [ ] 使用依赖扫描工具（如OWASP Dependency-Check）
- [ ] 移除未使用的依赖

### 10. 不足的日志记录和监控（Insufficient Logging & Monitoring）

**检查项：**
- [ ] 记录关键操作日志
- [ ] 记录安全事件（登录失败、权限拒绝）
- [ ] 日志不记录敏感信息
- [ ] 配置日志监控和告警

## 前端安全检查

### CSRF防护
- [ ] 使用CSRF Token
- [ ] SameSite Cookie属性

### 点击劫持防护
- [ ] X-Frame-Options配置
- [ ] Content-Security-Policy frame-ancestors

### 安全Cookie
- [ ] HttpOnly标志
- [ ] Secure标志
- [ ] SameSite属性

## 后端安全检查

### 输入验证
- [ ] 所有用户输入验证
- [ ] 使用白名单验证
- [ ] 验证数据类型、长度、格式

### 输出编码
- [ ] HTML编码
- [ ] URL编码
- [ ] JavaScript编码

### 文件上传
- [ ] 文件类型白名单
- [ ] 文件大小限制
- [ ] 文件名清理
- [ ] 病毒扫描（如需要）

## 数据库安全检查

### 连接安全
- [ ] 使用最小权限账号
- [ ] 加密数据库连接
- [ ] 不暴露数据库错误信息

### 数据保护
- [ ] 敏感字段加密
- [ ] 定期备份
- [ ] 软删除而非物理删除

## API安全检查

### 认证和授权
- [ ] 使用JWT或OAuth2
- [ ] Token过期时间设置
- [ ] 刷新Token机制

### 速率限制
- [ ] API调用频率限制
- [ ] 防止暴力破解

### HTTPS
- [ ] 强制使用HTTPS
- [ ] 证书有效性检查

## 安全审查流程

### 自动化检查
1. 使用静态代码分析工具（SonarQube、FindBugs）
2. 使用依赖扫描工具（OWASP Dependency-Check）
3. 使用安全扫描工具（Burp Suite、OWASP ZAP）

### 手动审查
1. 检查敏感信息泄露
2. 检查权限校验
3. 检查输入验证
4. 检查错误处理

### 渗透测试
1. SQL注入测试
2. XSS测试
3. CSRF测试
4. 权限绕过测试
