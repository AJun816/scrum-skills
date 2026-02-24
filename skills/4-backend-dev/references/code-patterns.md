# 代码模板与命名规范

## 目录
1. Controller 层
2. Request/Response DTO
3. Application Service 层
4. Domain 层 (领域事件)
5. Adapter 层
6. 命名规范

---

## 1. Controller 层

```java
package com.{company}.{project}.{module}.interfaces;

import com.{company}.{project}.{module}.application.{Module}ApplicationService;
import com.{company}.{project}.{module}.interfaces.request.*;
import com.{company}.{project}.{module}.interfaces.response.*;
import com.{company}.{project}.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/{platform}")
@RequiredArgsConstructor
@Tag(name = "{Platform}平台", description = "{Platform}平台数据接口")
public class {Platform}Controller {

    private final {Platform}ApplicationService applicationService;

    @GetMapping("/resources")
    @Operation(summary = "获取资源列表")
    public ApiResponse<ResourceListResponse> getResources(
            @Valid @ModelAttribute ResourceRequest request) {
        return ApiResponse.success(applicationService.getResources(request));
    }

    @PostMapping("/resources")
    @Operation(summary = "创建资源")
    public ApiResponse<ResourceData> createResource(
            @Valid @RequestBody CreateResourceRequest request) {
        return ApiResponse.success(applicationService.createResource(request));
    }

    @PutMapping("/resources/{id}")
    @Operation(summary = "更新资源")
    public ApiResponse<ResourceData> updateResource(
            @PathVariable Long id,
            @Valid @RequestBody UpdateResourceRequest request) {
        return ApiResponse.success(applicationService.updateResource(id, request));
    }

    @DeleteMapping("/resources/{id}")
    @Operation(summary = "删除资源")
    public ApiResponse<Void> deleteResource(@PathVariable Long id) {
        applicationService.deleteResource(id);
        return ApiResponse.success(null);
    }
}
```

**要点**:
- GET 请求参数用 `@ModelAttribute`，POST/PUT 请求体用 `@RequestBody`
- 返回统一 `ApiResponse<T>`
- Controller 不做业务逻辑，只做参数接收和响应封装

---

## 2. Request/Response DTO

### Request DTO (接口层)
```java
package com.{company}.{project}.{category}.{platform}.interfaces.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateResourceRequest {
    @NotBlank(message = "名称不能为空")
    private String name;
    private String description;
    private Map<String, Object> config;
}
```

### Response DTO (接口层)
```java
package com.{company}.{project}.{category}.{platform}.interfaces.response;

import lombok.Data;
import java.util.List;

@Data
public class ResourceListResponse {
    private List<ResourceData> records;
    private Integer totalRecords;
}

@Data
public class ResourceData {
    private Long id;
    private String name;
    private String status;
    // 只暴露前端需要的字段
}
```

---

## 3. Application Service 层

```java
package com.{company}.{project}.{category}.{platform}.application;

import com.{company}.{project}.{category}.{platform}.adapter.{Platform}ApiClient;
import com.{company}.{project}.{category}.{platform}.interfaces.request.*;
import com.{company}.{project}.{category}.{platform}.interfaces.response.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class {Platform}ApplicationService {

    private final {Platform}ApiClient apiClient;
    // 如需缓存: private final RedisTemplate<String, Object> redisTemplate;

    public ResourceListResponse getResources(ResourceRequest request) {
        log.info("获取资源列表: param={}", request);
        try {
            return apiClient.getResources(request);
        } catch (Exception e) {
            log.error("获取资源列表失败", e);
            throw new RuntimeException("获取资源列表失败: " + e.getMessage());
        }
    }

    public ResourceData createResource(CreateResourceRequest request) {
        log.info("创建资源: name={}", request.getName());
        // 1. 业务校验
        // 2. 调用适配器
        // 3. 发布领域事件 (可选)
        // 4. 返回结果
        return apiClient.createResource(request);
    }
}
```

**要点**:
- 编排用例流程，不包含具体业务规则（规则放 Domain 层）
- 管理事务边界（短事务）
- 调用 Adapter 获取外部数据，调用 Domain Service 处理业务逻辑

---

## 4. Domain 层

### 领域事件
```java
package com.{company}.{project}.{category}.{platform}.domain.event;

import com.{company}.{project}.common.event.DomainEvent;

public class {Resource}CreatedEvent extends DomainEvent {
    private final Long resourceId;
    private final String resourceName;

    public {Resource}CreatedEvent(Long resourceId, String resourceName) {
        super("{platform}");  // sourceContext = 平台标识
        this.resourceId = resourceId;
        this.resourceName = resourceName;
    }

    @Override
    public String getEventType() {
        return "{platform}.{resource}.created";
    }

    @Override
    public Object getAggregateId() {
        return resourceId;
    }

    // getter methods
    public Long getResourceId() { return resourceId; }
    public String getResourceName() { return resourceName; }
}
```

### 领域模型 (聚合根)
```java
package com.{company}.{project}.{category}.{platform}.domain.model;

import lombok.Data;
import lombok.Builder;

@Data
@Builder
public class {Platform}Campaign {
    private Long id;
    private String name;
    private String status;
    private CampaignBudget budget;  // 值对象
}
```

### 仓储接口
```java
package com.{company}.{project}.{category}.{platform}.domain.repository;

import com.{company}.{project}.{category}.{platform}.domain.model.{Platform}Campaign;
import java.util.Optional;

public interface {Platform}CampaignRepository {
    Optional<{Platform}Campaign> findById(Long id);
    void save({Platform}Campaign campaign);
    void deleteById(Long id);
}
```

---

## 5. Adapter 层

### 第三方 API 客户端
```java
package com.{company}.{project}.{category}.{platform}.adapter;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Component
@RequiredArgsConstructor
public class {Platform}ApiClient {

    private final RestTemplate restTemplate;
    private final {Platform}ApiConfig config;

    public ResourceListResponse getResources(ResourceRequest request) {
        String url = config.getBaseUrl() + "/resources";
        // 构建请求、调用API、解析响应
    }
}
```

### Orchestration Adapter 实现
```java
package com.{company}.{project}.{category}.{platform}.adapter;

import com.{company}.{project}.orchestration.adapter.TrackerAdapter; // 或 TrafficSourceAdapter / AffiliateAdapter
import org.springframework.stereotype.Component;

@Component("{platformId}")  // Bean名称 = 平台ID (小写)
public class {Platform}TrackerAdapter implements TrackerAdapter {

    private final {Platform}ApiClient apiClient;

    @Override
    public String getPlatformId() {
        return "{platformId}";
    }

    @Override
    public Map<String, Object> createOffer(Map<String, Object> offerData) {
        // 将通用参数转换为平台特定格式，调用 apiClient
    }

    // 实现所有接口方法...
}
```

---

## 6. 命名规范

### 包名
- 分类: `com.{company}.{project}.{affiliate|tracker|traffic}`
- 平台: `com.{company}.{project}.{category}.{platform}` (全小写，如 `com.{company}.{project}.tracker.skro`)
- 分层: `{platform}.{adapter|application|domain|infrastructure|interfaces}`

### 类名
- Controller: `{Platform}Controller`
- Application Service: `{Platform}ApplicationService`
- API Client: `{Platform}ApiClient`
- Adapter: `{Platform}{Type}Adapter` (如 `SkroTrackerAdapter`)
- Domain Event: `{Resource}{Action}Event` (如 `SkroCampaignCreatedEvent`)
- Request DTO: `{Action}{Resource}Request` (如 `CreateOfferRequest`)
- Response DTO: `{Resource}Data` / `{Resource}sResponse` (如 `OfferData`, `OffersResponse`)

### API路径
- 格式: `/api/v1/{platform}/{resource}`
- 列表: `GET /api/v1/skro/campaigns`
- 详情: `GET /api/v1/skro/campaigns/{id}`
- 创建: `POST /api/v1/skro/campaigns`
- 更新: `PUT /api/v1/skro/campaigns/{id}`
- 删除: `DELETE /api/v1/skro/campaigns/{id}`
