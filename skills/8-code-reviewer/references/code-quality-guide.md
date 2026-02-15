# 代码质量指南

**本文档提供代码质量的详细指导，确保代码符合高标准**

## KISS原则（Keep It Simple, Stupid）

### 核心理念
- 代码应该简单易懂
- 避免过度设计
- 优先选择简单的解决方案

### 实践建议

**简单的逻辑：**
```java
// ✅ 简单清晰
if (order.isPaid()) {
    shipOrder(order);
}

// ❌ 过度复杂
if (order.getStatus() == OrderStatus.PAID &&
    order.getPaymentTime() != null &&
    order.getPaymentTime().isBefore(LocalDateTime.now())) {
    if (order.getItems() != null && !order.getItems().isEmpty()) {
        shipOrder(order);
    }
}
```

**简单的方法：**
```java
// ✅ 简单直接
public boolean isEligibleForDiscount(User user) {
    return user.isVip() || user.getOrderCount() > 10;
}

// ❌ 过度设计
public boolean isEligibleForDiscount(User user) {
    DiscountEligibilityChecker checker = new DiscountEligibilityChecker();
    DiscountRule vipRule = new VipDiscountRule();
    DiscountRule orderCountRule = new OrderCountDiscountRule(10);
    checker.addRule(vipRule);
    checker.addRule(orderCountRule);
    return checker.check(user);
}
```

### 何时不用KISS
- 业务逻辑确实复杂
- 需要扩展性（如策略模式）
- 需要复用（如工具类）

## 单一职责原则（Single Responsibility Principle）

### 核心理念
- 一个类只有一个职责
- 一个方法只做一件事
- 职责变化时只影响一个类

### 实践建议

**类的单一职责：**
```java
// ✅ 单一职责：只负责订单业务逻辑
public class OrderService {
    public Order createOrder(OrderDTO dto) { ... }
    public void cancelOrder(Long orderId) { ... }
}

// ❌ 职责混乱：订单+支付+物流
public class OrderService {
    public Order createOrder(OrderDTO dto) { ... }
    public void processPayment(Long orderId) { ... }
    public void shipOrder(Long orderId) { ... }
}
```

**方法的单一职责：**
```java
// ✅ 单一职责：只创建订单
public Order createOrder(OrderDTO dto) {
    Order order = new Order();
    order.setUserId(dto.getUserId());
    order.setItems(dto.getItems());
    return orderRepository.save(order);
}

// ❌ 职责混乱：创建+支付+发货
public Order createOrder(OrderDTO dto) {
    Order order = new Order();
    order.setUserId(dto.getUserId());
    order.setItems(dto.getItems());
    orderRepository.save(order);

    // 支付
    paymentService.pay(order.getId());

    // 发货
    logisticsService.ship(order.getId());

    return order;
}
```

### 识别职责混乱的信号
- 类名包含"And"、"Manager"、"Helper"
- 方法名包含"And"
- 类有多个修改原因
- 方法超过50行

## 代码复用

### 核心理念
- DRY（Don't Repeat Yourself）
- 复用已有代码和模块
- 不重复造轮子

### 实践建议

**提取公共方法：**
```java
// ✅ 复用公共逻辑
public class OrderService {
    public Order createOrder(OrderDTO dto) {
        validateOrder(dto);
        return saveOrder(dto);
    }

    public Order updateOrder(Long id, OrderDTO dto) {
        validateOrder(dto);
        return updateOrder(id, dto);
    }

    private void validateOrder(OrderDTO dto) {
        // 公共验证逻辑
    }
}

// ❌ 重复代码
public class OrderService {
    public Order createOrder(OrderDTO dto) {
        if (dto.getItems() == null || dto.getItems().isEmpty()) {
            throw new IllegalArgumentException("订单项不能为空");
        }
        return saveOrder(dto);
    }

    public Order updateOrder(Long id, OrderDTO dto) {
        if (dto.getItems() == null || dto.getItems().isEmpty()) {
            throw new IllegalArgumentException("订单项不能为空");
        }
        return updateOrder(id, dto);
    }
}
```

**复用已有模块：**
```java
// ✅ 复用Spring的工具类
import org.springframework.util.StringUtils;

if (StringUtils.hasText(username)) {
    // ...
}

// ❌ 重复造轮子
public boolean isNotEmpty(String str) {
    return str != null && !str.trim().isEmpty();
}
```

### 何时不复用
- 业务逻辑不同
- 未来可能分化
- 复用会增加复杂度

## 方法大小控制

### 标准
- ❌ 禁止：单个方法超过 50 行
- ✅ 必须：超过 30 行考虑拆分

### 拆分方法

**按步骤拆分：**
```java
// ✅ 拆分为多个小方法
public Order createOrder(OrderDTO dto) {
    validateOrder(dto);
    Order order = buildOrder(dto);
    calculatePrice(order);
    return saveOrder(order);
}

private void validateOrder(OrderDTO dto) { ... }
private Order buildOrder(OrderDTO dto) { ... }
private void calculatePrice(Order order) { ... }
private Order saveOrder(Order order) { ... }
```

**按职责拆分：**
```java
// ✅ 提取独立职责
public Order createOrder(OrderDTO dto) {
    Order order = orderBuilder.build(dto);
    orderValidator.validate(order);
    orderPriceCalculator.calculate(order);
    return orderRepository.save(order);
}
```

## 代码可读性

### 命名清晰
```java
// ✅ 清晰的命名
public boolean isEligibleForDiscount(User user) { ... }

// ❌ 模糊的命名
public boolean check(User u) { ... }
```

### 避免魔法数字
```java
// ✅ 使用常量
private static final int MAX_RETRY_COUNT = 3;
if (retryCount > MAX_RETRY_COUNT) { ... }

// ❌ 魔法数字
if (retryCount > 3) { ... }
```

### 合理的注释
```java
// ✅ 说明"为什么"
// 订单创建后30分钟内未支付自动取消
if (order.getCreateTime().plusMinutes(30).isBefore(LocalDateTime.now())) {
    cancelOrder(order);
}

// ❌ 说明"是什么"（无用注释）
// 取消订单
cancelOrder(order);
```

## 异常处理

### 合理的异常处理
```java
// ✅ 合理的异常处理
public Order getOrder(Long id) {
    return orderRepository.findById(id)
        .orElseThrow(() -> new OrderNotFoundException("订单不存在: " + id));
}

// ❌ 吞掉异常
public Order getOrder(Long id) {
    try {
        return orderRepository.findById(id).get();
    } catch (Exception e) {
        return null;
    }
}
```

### 不要过度捕获
```java
// ✅ 只捕获需要处理的异常
public void processPayment(Long orderId) {
    try {
        paymentService.pay(orderId);
    } catch (PaymentException e) {
        // 处理支付失败
        handlePaymentFailure(orderId, e);
    }
}

// ❌ 捕获所有异常
public void processPayment(Long orderId) {
    try {
        paymentService.pay(orderId);
    } catch (Exception e) {
        // 无法区分异常类型
    }
}
```

## 性能考虑

### 避免N+1查询
```java
// ✅ 使用JOIN查询
List<Order> orders = orderRepository.findAllWithItems();

// ❌ N+1查询
List<Order> orders = orderRepository.findAll();
for (Order order : orders) {
    List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
    order.setItems(items);
}
```

### 避免深层嵌套
```java
// ✅ 提前返回
public void processOrder(Order order) {
    if (!order.isPaid()) {
        return;
    }
    if (order.isShipped()) {
        return;
    }
    shipOrder(order);
}

// ❌ 深层嵌套
public void processOrder(Order order) {
    if (order.isPaid()) {
        if (!order.isShipped()) {
            shipOrder(order);
        }
    }
}
```

## 测试友好

### 依赖注入
```java
// ✅ 依赖注入，易于测试
public class OrderService {
    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }
}

// ❌ 硬编码依赖，难以测试
public class OrderService {
    private OrderRepository orderRepository = new OrderRepositoryImpl();
}
```

### 避免静态方法
```java
// ✅ 实例方法，易于Mock
public class DateUtils {
    public LocalDateTime now() {
        return LocalDateTime.now();
    }
}

// ❌ 静态方法，难以Mock
public class DateUtils {
    public static LocalDateTime now() {
        return LocalDateTime.now();
    }
}
```
