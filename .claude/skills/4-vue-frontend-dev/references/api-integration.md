# 前后端 API 对接指南

## 后端响应格式

后端统一使用 `ApiResponse<T>` 包装所有响应：

```json
{
  "code": 200,
  "message": "success",
  "data": { ... },
  "timestamp": 1700000000000
}
```

### 响应码约定

| code | 含义 | 前端处理 |
|------|------|----------|
| 200 | 成功 | 取 `response.data` 使用 |
| 400 | 请求参数错误 | 显示 `message` 提示用户 |
| 401 | 未授权 | 跳转登录页 |
| 403 | 无权限 | 显示权限不足提示 |
| 404 | 资源不存在 | 显示对应提示 |
| 500 | 服务器错误 | 显示通用错误提示 |

### 分页响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [ ... ],
    "total": 100,
    "page": 1,
    "pageSize": 20
  }
}
```

前端解析方式：
```javascript
const response = await fetchItems(params);
const records = response?.data?.records || [];
const total = response?.data?.total || 0;
```

## 前端 HTTP 基础设施

### Axios 实例创建模式

每个业务域创建独立的 Axios 实例：

```javascript
import axios from 'axios';
import { getApiBaseUrl, API_TIMEOUT, API_RETRY_CONFIG } from './config';

const domainApi = axios.create({
  baseURL: getApiBaseUrl('DEFAULT'),  // 从 config.js 获取环境URL
  timeout: API_TIMEOUT.DEFAULT,       // 30秒
  withCredentials: true
});
```

### 重试拦截器（标准模式）

```javascript
domainApi.interceptors.response.use(
  response => response,
  async error => {
    const req = error.config;
    if (!req._retryCount) req._retryCount = 0;
    if (req._retryCount >= API_RETRY_CONFIG.MAX_RETRIES) return Promise.reject(error);
    req._retryCount++;
    await new Promise(r => setTimeout(r, API_RETRY_CONFIG.RETRY_DELAY * Math.pow(2, req._retryCount - 1)));
    return domainApi(req);
  }
);
```

### 平台 Header 自动注入

`PureHttp`（`utils/http/index.ts`）可以自动注入业务上下文 Header：

```
X-Platform-Type: platform-a
X-Business-Domain: domain-b
X-Service-Name: service-c
```

来源于业务 Store 的配置。如果使用独立 Axios 实例，需要手动确保 Header 注入或在请求拦截器中添加。

## API URL 映射

### 环境配置（config.js）

```javascript
// 开发环境统一代理到 /api/v1
API_BASE_URLS: {
  development: {
    DEFAULT: '/api/v1',
    DOMAIN_A: '/api/v1',
    DOMAIN_B: '/api/v1/domain-b',
    // ...
  }
}
```

### 端点映射

```javascript
API_ENDPOINTS: {
  DOMAIN_A: {
    ITEMS: '/domain-a/items',
    LOGS: '/domain-a/logs',
    REPORTS: '/domain-a/reports',
    STATISTICS: '/domain-a/statistics',
    // ...
  }
}
```

### 完整 URL 构成

```
最终URL = BASE_URL + ENDPOINT
例: /api/v1 + /domain-a/items = /api/v1/domain-a/items
对应后端: @RequestMapping("/api/v1/domain-a") + @GetMapping("/items")
```

## 前端 → 后端参数对齐规则

### GET 请求（查询参数）

前端参数名 **必须与后端 @RequestParam 或 Request DTO 字段名完全一致**：

```javascript
// 前端
const params = {
  from: '2024-01-01 00:00:00',   // 对应后端 String from
  to: '2024-01-07 00:00:00',     // 对应后端 String to
  timezone: 'Asia/Shanghai',      // 对应后端 String timezone
  page: 1,                        // 对应后端 Integer page
  pageSize: 100                   // 对应后端 Integer pageSize
};
const response = await domainApi.get('/endpoint', { params });
```

### POST/PUT 请求（请求体）

前端请求体字段 **必须与后端 @RequestBody DTO 字段名完全一致**：

```javascript
// 后端 CreateCampaignRequest DTO:
// { String name, String country, BigDecimal budget, List<String> zones }

// 前端
const data = {
  name: '活动名称',
  country: 'US',
  budget: 100.00,
  zones: ['zone1', 'zone2']
};
const response = await domainApi.post('/endpoint', data);
```

### 通用日志查询参数

业务域可以使用通用查询方法，支持以下标准参数：

```javascript
const validParams = [
  'from', 'to', 'timezone', 'id',
  'page', 'pageSize', 'orderBy', 'sortBy',
  'workspace', 'type', 'dataType',
  'name', 'isActive', 'isDeleted', 'status',
  'category', 'keyword', 'country'
];
```

## 错误处理标准模式

### API 层（捕获 + 上抛）

```javascript
export const fetchData = async (params) => {
  try {
    const response = await domainApi.get('/endpoint', { params });
    return response.data;
  } catch (error) {
    console.error('获取数据失败:', error);
    throw error;  // 向上层抛出，让调用方处理UI反馈
  }
};
```

### View/Composable 层（捕获 + 用户反馈）

```javascript
const loadData = async () => {
  loading.value = true;
  try {
    const response = await fetchData(params);
    tableData.value = response?.data?.records || [];

    if (tableData.value.length === 0) {
      ElMessage.warning('当前时间范围内暂无数据');
    } else {
      ElMessage.success(`加载成功，共 ${tableData.value.length} 条记录`);
    }
  } catch (error) {
    // 用户友好的错误消息，不暴露技术细节
    ElMessage.error('数据加载失败，请检查网络连接后重试');
  } finally {
    loading.value = false;  // 无论成功失败都关闭 loading
  }
};
```

### 错误消息映射（config.js）

```javascript
ERROR_MESSAGES: {
  NETWORK_ERROR: '网络连接失败，请检查您的网络设置',
  TIMEOUT_ERROR: '请求超时，请稍后重试',
  SERVER_ERROR: '服务器错误，请联系管理员',
  NOT_FOUND: '请求的资源不存在',
  UNAUTHORIZED: '未授权，请重新登录',
  FORBIDDEN: '禁止访问，您没有权限执行此操作',
  UNKNOWN_ERROR: '未知错误，请稍后重试'
}
```

## 新增 API 对接检查清单

为新功能对接后端 API 时，按以下步骤检查：

1. **确认后端接口**
   - [ ] 后端 Controller URL 路径（`@RequestMapping` + `@GetMapping/@PostMapping`）
   - [ ] 请求方法（GET/POST/PUT/DELETE）
   - [ ] Request DTO 字段名和类型
   - [ ] Response DTO 结构（特别是 `data` 字段的嵌套结构）

2. **前端 API 模块**
   - [ ] 在 `src/api/` 中新建或复用现有模块
   - [ ] 端点路径与后端一致
   - [ ] 参数名与后端 DTO 完全对齐
   - [ ] 添加 JSDoc 注释说明参数

3. **前端调用层**
   - [ ] try-catch 包裹 API 调用
   - [ ] 维护 loading 状态
   - [ ] 安全解析响应：`response?.data?.records || []`
   - [ ] 空数据状态处理
   - [ ] 错误消息用户友好（中文）

4. **端点注册**（如果是新域）
   - [ ] 在 `config.js` 的 `API_ENDPOINTS` 中添加端点
   - [ ] 在 `API_BASE_URLS` 各环境中添加对应 URL（如需要）
