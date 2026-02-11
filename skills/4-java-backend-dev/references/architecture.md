# 项目架构详解

## 技术栈
- Java 17 + Spring Boot 3.x + Maven
- Lombok (@Data, @Slf4j, @RequiredArgsConstructor, @Builder)
- Swagger/OpenAPI 3 (@Tag, @Operation)
- Redis (缓存)、MySQL (持久化)
- Jakarta Validation (@Valid, @NotNull, @NotBlank)

## 架构模式
**平台级垂直切片 + DDD 分层**：以业务分类(affiliate/tracker/traffic)为顶层组织，每个平台域内保持完整 DDD 分层。

## 目录结构
```
api-refactor/src/main/java/com/aff/
├── affiliate/              # 广告联盟分类
│   ├── zeydoo/             # Zeydoo 平台域 (完整DDD分层)
│   ├── goldengoose/        # GoldenGoose 平台域
│   └── adsterra/           # Adsterra 平台域
├── tracker/                # 追踪器分类
│   ├── skro/               # Skro 平台域 (最成熟，作为参考模板)
│   ├── bemob/              # BeMob 平台域
│   └── voluum/             # Voluum 平台域
├── traffic/                # 流量源分类
│   ├── propellerads/       # PropellerAds 平台域
│   ├── kadam/              # Kadam 平台域
│   └── popads/             # PopAds 平台域
├── orchestration/          # 编排域 (跨平台协调)
│   ├── adapter/            # 统一适配器接口 (TrackerAdapter, TrafficSourceAdapter, AffiliateAdapter)
│   ├── platform/           # 平台上下文 (PlatformRegistry, PlatformContext)
│   ├── config/             # MVC配置、Redis配置
│   └── interfaces/         # PlatformController
├── platform-service/       # 自有业务域 (跨平台复用)
│   ├── campaigninfo/       # 活动信息管理
│   └── ipPool/             # IP池管理
├── algorithm/              # 算法模块 (策略模式)
├── workflow/               # 工作流引擎
├── activity/               # 活动管理 (有完整DDD分层示例)
├── pool/                   # 数据池 (Zone黑名单/IP池)
├── zone/                   # Zone管理和优化
├── analysis/               # 分析工具
├── common/                 # 公共模块
│   ├── response/           # ApiResponse 统一响应
│   ├── event/              # DomainEvent 基类、EventPublisher/Listener
│   └── domain/             # 共享领域服务
├── shared/                 # 共享基础设施
│   └── eventbus/           # SimpleEventBus (内存事件总线)
└── infra/                  # 全局基础设施
    ├── config/             # 全局配置管理
    └── httpclient/         # HTTP客户端工具
```

## 每个平台域的内部分层
```
{platform}/
├── adapter/                # 第三方API适配器 + 防腐层
│   ├── {Platform}ApiClient.java        # HTTP客户端封装
│   ├── {Platform}Adapter.java          # 实现 orchestration adapter 接口
│   └── model/                          # 适配器层数据模型
├── application/            # 应用服务层
│   ├── {Platform}ApplicationService.java  # 用例编排
│   ├── dto/                               # 数据传输对象
│   ├── assembler/                         # DTO转换器
│   └── service/                           # 应用级服务
├── domain/                 # 领域层
│   ├── model/              # 聚合根、实体、值对象
│   ├── repository/         # 仓储接口 (持久化抽象)
│   ├── service/            # 领域服务
│   └── event/              # 领域事件
├── infrastructure/         # 基础设施层
│   ├── persistence/        # JPA/MyBatis 仓储实现
│   ├── converter/          # 数据转换器
│   └── config/             # 平台专属配置
└── interfaces/             # 接口层
    ├── controller/         # REST Controller (或直接 {Platform}Controller.java)
    ├── request/            # 请求DTO
    └── response/           # 响应DTO
```

## 模块职责

### orchestration（编排域）
协调多平台调用。核心组件：
- `TrackerAdapter` / `TrafficSourceAdapter` / `AffiliateAdapter` — 统一适配器接口
- `PlatformRegistry` — Spring自动发现所有Adapter Bean并注册
- `PlatformContext` + `PlatformContextInterceptor` — 通过 HTTP Header (X-Platform-*) 解析当前平台上下文
- 新平台只需实现接口 + 注册为 Spring Bean，零侵入

### common（公共模块）
- `ApiResponse<T>` — 统一响应格式 `{code, message, data, timestamp}`
- `DomainEvent` — 领域事件抽象基类 (eventId/occurredAt/version/sourceContext)
- `EventPublisher` / `EventListener` — 事件发布/订阅接口

### platform-service（自有业务域）
不依赖任何第三方平台的通用业务：活动管理、IP池、Zone管理等。

## 数据流
```
HTTP请求 → PlatformContextInterceptor (解析X-Platform-*Header)
         → Controller (参数校验+响应封装)
         → ApplicationService (用例编排+缓存+事务)
         → Adapter/ApiClient (调用第三方API)
         → 返回结果 → ApplicationService (数据转换) → Controller → ApiResponse
```

## API路径规范
- 平台域: `/api/v1/{platform}/**` (如 `/api/v1/skro/campaigns`)
- 编排域: `/v1/**` (如 `/v1/platforms`)
- 业务域: `/api/v1/{business}/**` (如 `/api/v1/activities`)
