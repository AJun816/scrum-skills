# 常见问题和修复建议

**本文档列出代码审查中常见的问题和对应的修复建议**

## 文件大小问题

### 问题：文件超过800行

**常见原因：**
- 一个类承担了太多职责
- 方法过多
- 内部类过多
- 注释过多

**修复建议：**

1. **按职责拆分类**
```java
// 原文件：OrderService.java (1000行)
// 拆分为：
// - OrderService.java (300行) - 核心订单业务
// - OrderValidator.java (200行) - 订单验证
// - OrderPriceCalculator.java (200行) - 价格计算
// - OrderNotifier.java (150行) - 订单通知
```

2. **提取内部类**
```java
// 原文件：OrderService.java
public class OrderService {
    // 内部类占用200行
    private static class OrderBuilder { ... }
}

// 拆分后：
// OrderService.java
// OrderBuilder.java (独立文件)
```

3. **移动工具方法到工具类**
```java
// 原文件：OrderService.java
public class OrderService {
    private String formatOrderNo(Long id) { ... }
    private LocalDateTime parseDate(String date) { ... }
}

// 拆分后：
// OrderService.java
// OrderUtils.java (工具方法)
```

### 问题：方法超过50行

**常见原因：**
- 一个方法做了太多事情
- 嵌套层次过深
- 重复代码

**修复建议：**

1. **按步骤拆分**
```java
// 原方法：createOrder (80行)
public Order createOrder(OrderDTO dto) {
    // 验证 (20行)
    // 构建 (20行)
    // 计算 (20行)
    // 保存 (20行)
}

// 拆分后：
public Order createOrder(OrderDTO dto) {
    validateOrder(dto);
    Order order = buildOrder(dto);
    calculatePrice(order);
    return saveOrder(order);
}
```

2. **提取条件判断**
```java
// 原方法：
if (user.isVip() && user.getOrderCount() > 10 &&
    order.getTotalAmount() > 1000 && !user.hasUsedCoupon()) {
    // 复杂逻辑
}

// 拆分后：
if (isEligibleForVipDiscount(user, order)) {
    // 复杂逻辑
}

private boolean isEligibleForVipDiscount(User user, Order order) {
    return user.isVip() &&
           user.getOrderCount() > 10 &&
           order.getTotalAmount() > 1000 &&
           !user.hasUsedCoupon();
}
```

## 代码质量问题

### 问题：违反KISS原则（过度设计）

**示例：**
```java
// ❌ 过度设计
public interface DiscountStrategy {
    BigDecimal calculate(Order order);
}

public class VipDiscountStrategy implements DiscountStrategy { ... }
public class CouponDiscountStrategy implements DiscountStrategy { ... }
public class PromotionDiscountStrategy implements DiscountStrategy { ... }

public class DiscountCalculator {
    private List<DiscountStrategy> strategies;
    public BigDecimal calculate(Order order) {
        return strategies.stream()
            .map(s -> s.calculate(order))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

**修复建议：**
```java
// ✅ 简单直接
public class DiscountCalculator {
    public BigDecimal calculate(Order order, User user) {
        BigDecimal discount = BigDecimal.ZERO;

        if (user.isVip()) {
            discount = discount.add(calculateVipDiscount(order));
        }
        if (order.hasCoupon()) {
            discount = discount.add(calculateCouponDiscount(order));
        }
        if (isInPromotion(order)) {
            discount = discount.add(calculatePromotionDiscount(order));
        }

        return discount;
    }
}
```

### 问题：违反单一职责原则

**示例：**
```java
// ❌ 职责混乱
public class OrderService {
    public Order createOrder(OrderDTO dto) {
        // 验证订单
        validateOrder(dto);

        // 创建订单
        Order order = new Order();
        order.setUserId(dto.getUserId());

        // 处理支付
        Payment payment = new Payment();
        payment.setOrderId(order.getId());
        paymentRepository.save(payment);

        // 发送通知
        emailService.sendOrderConfirmation(order);
        smsService.sendOrderNotification(order);

        return order;
    }
}
```

**修复建议：**
```java
// ✅ 单一职责
public class OrderService {
    private final OrderValidator orderValidator;
    private final PaymentService paymentService;
    private final NotificationService notificationService;

    public Order createOrder(OrderDTO dto) {
        orderValidator.validate(dto);

        Order order = new Order();
        order.setUserId(dto.getUserId());
        orderRepository.save(order);

        paymentService.createPayment(order.getId());
        notificationService.notifyOrderCreated(order);

        return order;
    }
}
```

### 问题：重复代码

**示例：**
```java
// ❌ 重复代码
public void createOrder(OrderDTO dto) {
    if (dto.getItems() == null || dto.getItems().isEmpty()) {
        throw new IllegalArgumentException("订单项不能为空");
    }
    // ...
}

public void updateOrder(Long id, OrderDTO dto) {
    if (dto.getItems() == null || dto.getItems().isEmpty()) {
        throw new IllegalArgumentException("订单项不能为空");
    }
    // ...
}
```

**修复建议：**
```java
// ✅ 提取公共方法
public void createOrder(OrderDTO dto) {
    validateOrderItems(dto);
    // ...
}

public void updateOrder(Long id, OrderDTO dto) {
    validateOrderItems(dto);
    // ...
}

private void validateOrderItems(OrderDTO dto) {
    if (dto.getItems() == null || dto.getItems().isEmpty()) {
        throw new IllegalArgumentException("订单项不能为空");
    }
}
```

## 代码规范问题

### 问题：命名不规范

**示例：**
```java
// ❌ 命名不规范
public class orderservice { ... }  // 类名应该PascalCase
public void GetOrder() { ... }     // 方法名应该camelCase
private String USERID;             // 变量名应该camelCase
```

**修复建议：**
```java
// ✅ 命名规范
public class OrderService { ... }
public void getOrder() { ... }
private String userId;
```

### 问题：魔法数字

**示例：**
```java
// ❌ 魔法数字
if (order.getStatus() == 1) { ... }
if (retryCount > 3) { ... }
```

**修复建议：**
```java
// ✅ 使用常量
private static final int ORDER_STATUS_PAID = 1;
private static final int MAX_RETRY_COUNT = 3;

if (order.getStatus() == ORDER_STATUS_PAID) { ... }
if (retryCount > MAX_RETRY_COUNT) { ... }

// 或使用枚举
public enum OrderStatus {
    PENDING(0), PAID(1), SHIPPED(2), COMPLETED(3);
}

if (order.getStatus() == OrderStatus.PAID) { ... }
```

### 问题：注释不当

**示例：**
```java
// ❌ 无用注释
// 创建订单
public Order createOrder(OrderDTO dto) { ... }

// ❌ 过时注释
// TODO: 需要添加支付功能（已经实现了）
public void processPayment() { ... }
```

**修复建议：**
```java
// ✅ 有用的注释
// 订单创建后30分钟内未支付自动取消
public Order createOrder(OrderDTO dto) { ... }

// ✅ 删除过时注释
public void processPayment() { ... }
```

## 安全问题

### 问题：SQL注入

**示例：**
```java
// ❌ SQL注入风险
String sql = "SELECT * FROM users WHERE username = '" + username + "'";
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(sql);
```

**修复建议：**
```java
// ✅ 参数化查询
String sql = "SELECT * FROM users WHERE username = ?";
PreparedStatement ps = conn.prepareStatement(sql);
ps.setString(1, username);
ResultSet rs = ps.executeQuery();
```

### 问题：XSS漏洞

**示例：**
```javascript
// ❌ XSS风险
element.innerHTML = userInput;
```

**修复建议：**
```javascript
// ✅ 使用textContent
element.textContent = userInput;

// 或使用Vue的文本插值
<div>{{ userInput }}</div>
```

### 问题：敏感信息泄露

**示例：**
```java
// ❌ 密钥硬编码
String apiKey = "sk-1234567890abcdef";
String dbPassword = "admin123";
```

**修复建议：**
```java
// ✅ 从环境变量读取
String apiKey = System.getenv("API_KEY");
String dbPassword = System.getenv("DB_PASSWORD");

// 或从配置文件读取
@Value("${api.key}")
private String apiKey;
```

### 问题：权限校验缺失

**示例：**
```java
// ❌ 未校验权限
@GetMapping("/admin/users")
public List<User> getUsers() {
    return userService.getAllUsers();
}
```

**修复建议：**
```java
// ✅ 校验权限
@GetMapping("/admin/users")
@PreAuthorize("hasRole('ADMIN')")
public List<User> getUsers() {
    return userService.getAllUsers();
}
```

## 性能问题

### 问题：N+1查询

**示例：**
```java
// ❌ N+1查询
List<Order> orders = orderRepository.findAll();
for (Order order : orders) {
    List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
    order.setItems(items);
}
```

**修复建议：**
```java
// ✅ 使用JOIN查询
@Query("SELECT o FROM Order o LEFT JOIN FETCH o.items")
List<Order> findAllWithItems();

List<Order> orders = orderRepository.findAllWithItems();
```

### 问题：深层嵌套

**示例：**
```java
// ❌ 深层嵌套
if (user != null) {
    if (user.isActive()) {
        if (order != null) {
            if (order.isPaid()) {
                shipOrder(order);
            }
        }
    }
}
```

**修复建议：**
```java
// ✅ 提前返回
if (user == null || !user.isActive()) {
    return;
}
if (order == null || !order.isPaid()) {
    return;
}
shipOrder(order);
```

## 架构问题

### 问题：违反分层架构

**示例：**
```java
// ❌ Controller直接访问Repository
@RestController
public class OrderController {
    @Autowired
    private OrderRepository orderRepository;

    @GetMapping("/orders/{id}")
    public Order getOrder(@PathVariable Long id) {
        return orderRepository.findById(id).orElse(null);
    }
}
```

**修复建议：**
```java
// ✅ Controller通过Service访问数据
@RestController
public class OrderController {
    @Autowired
    private OrderService orderService;

    @GetMapping("/orders/{id}")
    public Order getOrder(@PathVariable Long id) {
        return orderService.getOrder(id);
    }
}
```

### 问题：循环依赖

**示例：**
```java
// ❌ 循环依赖
public class OrderService {
    @Autowired
    private PaymentService paymentService;
}

public class PaymentService {
    @Autowired
    private OrderService orderService;
}
```

**修复建议：**
```java
// ✅ 引入中间层或事件机制
public class OrderService {
    @Autowired
    private ApplicationEventPublisher eventPublisher;

    public void createOrder(Order order) {
        // ...
        eventPublisher.publishEvent(new OrderCreatedEvent(order));
    }
}

public class PaymentService {
    @EventListener
    public void handleOrderCreated(OrderCreatedEvent event) {
        // 处理订单创建事件
    }
}
```

## 快速修复清单

### 文件大小超标
1. 按职责拆分类
2. 提取内部类
3. 移动工具方法到工具类

### 方法过长
1. 按步骤拆分
2. 提取条件判断
3. 提取重复代码

### 代码质量
1. 简化过度设计
2. 拆分职责混乱的类
3. 提取重复代码

### 代码规范
1. 修正命名
2. 替换魔法数字
3. 改进注释

### 安全问题
1. 使用参数化查询
2. 转义用户输入
3. 移除硬编码密钥
4. 添加权限校验

### 性能问题
1. 优化N+1查询
2. 减少嵌套层次
3. 添加缓存

### 架构问题
1. 遵循分层架构
2. 解决循环依赖
3. 使用依赖注入
