# 新平台接入指南

## 接入原则
1. **零侵入**: 不修改任何现有代码
2. **只需实现接口 + 注册Bean**: Spring 自动发现
3. **前端无需改动**: `/v1/platforms` API 自动返回新平台

## 接入步骤

### Step 1: 确定平台类型
- 追踪器 → 实现 `TrackerAdapter` → 放 `com.aff.tracker.{platform}/`
- 流量源 → 实现 `TrafficSourceAdapter` → 放 `com.aff.traffic.{platform}/`
- 广告联盟 → 实现 `AffiliateAdapter` → 放 `com.aff.affiliate.{platform}/`

### Step 2: 创建域目录结构
```
com/aff/{category}/{platform}/
├── adapter/
│   ├── {Platform}ApiClient.java          # HTTP客户端
│   ├── {Platform}ApiConfig.java          # API配置 (@ConfigurationProperties)
│   └── {Platform}{Type}Adapter.java      # 实现编排适配器接口
├── application/
│   └── {Platform}ApplicationService.java # 应用服务
├── domain/
│   └── event/                            # 领域事件 (可选)
├── infrastructure/
│   └── converter/                        # 数据转换器 (可选)
└── interfaces/
    ├── {Platform}Controller.java         # REST Controller (可选)
    ├── request/                          # 请求DTO
    └── response/                         # 响应DTO
```

### Step 3: 实现编排适配器

以追踪器为例 (`TrackerAdapter` 接口):

```java
@Component("{platformId}")
public class {Platform}TrackerAdapter implements TrackerAdapter {
    private final {Platform}ApiClient apiClient;

    @Override public String getPlatformId() { return "{platformId}"; }
    @Override public Map<String, Object> createOffer(Map<String, Object> offerData) { ... }
    @Override public Map<String, Object> createCampaign(Map<String, Object> campaignData) { ... }
    @Override public List<Map<String, Object>> getClickLogs(String campaignId, LocalDateTime from, LocalDateTime to, String timezone) { ... }
    @Override public List<Map<String, Object>> getConversionLogs(String campaignId, LocalDateTime from, LocalDateTime to, String timezone) { ... }
    @Override public List<Map<String, Object>> getCampaigns(Map<String, Object> params) { ... }
    @Override public Map<String, Object> getReport(Map<String, Object> params) { ... }
}
```

流量源 (`TrafficSourceAdapter`) 需实现:
- `getPlatformId()`, `createCampaign()`, `getCampaigns()`, `getCampaignDetail()`
- `updateCampaign()`, `getZoneStatistics()`, `excludeZones()`, `getTargetingOptions()`

广告联盟 (`AffiliateAdapter`) 需实现:
- `getPlatformId()`, `getOffers()`, `getOfferDetail()`, `getConversions()`, `getStatistics()`

### Step 4: 添加配置

`application.yml`:
```yaml
{platform}:
  api:
    base-url: https://api.{platform}.com
    api-key: ${PLATFORM_API_KEY}
```

配置类:
```java
@Data
@Component
@ConfigurationProperties(prefix = "{platform}.api")
public class {Platform}ApiConfig {
    private String baseUrl;
    private String apiKey;
}
```

### Step 5: 实现 API 客户端

```java
@Slf4j
@Component
@RequiredArgsConstructor
public class {Platform}ApiClient {
    private final RestTemplate restTemplate;
    private final {Platform}ApiConfig config;

    // 封装所有第三方API调用
    // 统一处理认证、错误、重试
}
```

### Step 6: 编译验证

```bash
mvn compile -f api-refactor/pom.xml
```

## 检查清单

- `getPlatformId()` 返回唯一的小写ID
- 所有适配器接口方法已实现
- 异常时抛出有意义的错误信息（中文描述 + 原始错误）
- `application.yml` 敏感信息使用环境变量 `${VAR}`
- 编译通过无错误
- `@Component` 注解的 Bean 名称与 platformId 一致
- 不引用其他平台域的内部类（只通过 orchestration adapter 交互）
