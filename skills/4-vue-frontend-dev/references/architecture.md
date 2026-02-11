# 前端项目架构详解

## 技术栈

- **框架**: Vue 3 (Composition API + `<script setup>`)
- **UI组件库**: Element Plus
- **构建工具**: Vite
- **状态管理**: Pinia
- **路由**: Vue Router 4
- **HTTP客户端**: Axios
- **基础模板**: pure-admin-thin（提供 Layout、侧边栏、路由系统）
- **语言**: JavaScript（`.vue`/`.js`）+ 少量 TypeScript（`.ts`，仅 Store 和 HTTP 工具）

## 项目目录结构

```
web/src/
├── api/                        # API 请求层（按业务域拆分）
│   ├── config.js               #   全局API配置（URL、端点、状态码、超时、重试）
│   ├── skro.js                 #   Skro域统一导出（re-export聚合）
│   ├── skro-base.js            #   Skro Axios实例 + 重试拦截器 + fetchLogData通用方法
│   ├── skro-logs.js            #   Skro日志API（点击/转化/饼图）
│   ├── skro-campaigns.js       #   Skro活动API（campaigns/workspaces/offer/tracking）
│   ├── skro-utils.js           #   Skro工具函数（格式化/提取/查找）
│   ├── analysis.js             #   分析优化API（优化建议/历史记录）
│   ├── goldengoose.js          #   GoldenGoose广告联盟API
│   ├── propellerads.js         #   PropellerAds流量源API
│   └── automation.js           #   自动化投放API
│
├── components/                 # 业务组件（按功能域分目录）
│   ├── AutoCampaign/           #   智能投放相关组件
│   │   ├── ActivityForm.vue    #     活动配置表单
│   │   ├── ActivityList.vue    #     活动列表
│   │   ├── PlatformConfig.vue  #     平台选择配置
│   │   ├── ActivityStrategy.vue#     策略配置
│   │   └── ...
│   ├── DataOptimization/       #   数据优化相关组件
│   │   ├── OptimizationControlsPanel.vue
│   │   ├── OptimizationStatsGrid.vue
│   │   ├── RecommendationsTable.vue
│   │   └── OptimizationHistoryTable.vue
│   ├── DataPool/               #   ISP数据池组件
│   ├── PageLayout.vue          #   通用页面布局包装器
│   ├── WorkbenchPanel.vue      #   侧边工作台面板
│   ├── SmartRecommendation.vue #   智能推荐组件
│   ├── Navigation.vue          #   导航组件
│   └── ...
│
├── composables/                # 组合式函数（提取可复用逻辑）
│   ├── useActivityManagement.js#   活动增删改查+分页逻辑
│   ├── useOnboardingGuide.js   #   新手引导流程
│   ├── usePlatformManagement.js#   平台管理逻辑
│   ├── useFormManagement.js    #   表单数据管理
│   ├── useTargetingOptions.js  #   定向选项加载
│   ├── useBudgetCalculation.js #   预算计算逻辑
│   └── ...
│
├── store/                      # Pinia 全局状态
│   ├── utils.ts                #   Store工具（创建全局store实例）
│   └── modules/
│       └── platform.ts         #   平台选择状态（affiliate/tracker/traffic）
│
├── views/                      # 页面级组件（每个文件 = 一个路由页面）
│   ├── AutoCampaign.vue        #   智能投放页面
│   ├── DataOptimization.vue    #   数据优化页面
│   ├── PreLaunchAnalysis.vue   #   投前分析页面
│   ├── ChartAnalysis.vue       #   图表分析页面
│   ├── ClickLogs.vue           #   点击日志页面
│   ├── ConversionLogs.vue      #   转化日志页面
│   ├── SmartOptimization.vue   #   智能优化页面
│   ├── TrackerCampaigns.vue    #   追踪器活动页面
│   ├── TrafficCampaigns.vue    #   流量源活动页面
│   ├── DataPool.vue            #   ISP数据池页面
│   └── ...
│
├── router/
│   └── index.js                # 路由配置（Layout嵌套 + 懒加载）
│
├── layout/
│   └── index.vue               # 应用主布局（来自 pure-admin-thin）
│
└── utils/
    ├── http/
    │   └── index.ts            # PureHttp 封装（平台Header注入、Token刷新）
    └── dataAnalyzer.js         # 数据分析工具（指标计算、建议生成）
```

## 数据流架构

```
用户操作
  ↓
View (页面组件)
  ↓ 调用
Composable (业务逻辑) ←→ Store (全局状态)
  ↓ 调用
API Module (请求封装)
  ↓ HTTP
Axios Instance (拦截器: 重试/平台Header/Token)
  ↓
后端 API (/api/v1/...)
  ↓ 返回
ApiResponse<T> { code, message, data, timestamp }
  ↓
前端解析 response.data → 更新 ref/reactive 状态 → 视图自动刷新
```

## 路由结构

路由使用 Layout 嵌套模式，每个顶级路由对应侧边栏一个菜单项：

```javascript
{
  path: '/功能路径',
  component: Layout,           // 主布局（侧边栏+顶栏+内容区）
  redirect: '/功能路径/index',
  meta: { title: '菜单名', icon: 'ep:图标名', rank: 排序值 },
  children: [{
    path: '/功能路径/index',
    component: () => import('../views/页面.vue'),  // 懒加载
    meta: { title: '页面标题', icon: 'ep:图标名' }
  }]
}
```

- `meta.showLink: false` 可隐藏菜单项
- `meta.rank` 控制菜单排序（数值越小越靠前）

## 平台上下文机制

系统支持多平台组合（广告联盟 + 追踪器 + 流量源），通过 Pinia Store 管理：

1. **Store** (`platform.ts`): 维护 `selectedPlatform: { affiliate, tracker, traffic }`
2. **HTTP拦截器**: 自动在请求头注入 `X-Platform-Affiliate`、`X-Platform-Tracker`、`X-Platform-Traffic`
3. **组件访问**: 通过 `usePlatformStoreHook()` 获取当前平台名称、组合标签等
4. **持久化**: 选择状态存储在 `localStorage("platform-context")`

## API 配置体系

`api/config.js` 集中管理：
- **环境URL**: development/test/staging/production 四套配置
- **端点映射**: 各平台的 API 端点路径
- **超时/重试**: 默认30s超时，最多3次指数退避重试
- **状态码/错误消息**: 统一错误码和中文错误消息映射

## 组件拆分策略

项目采用 **View + Components + Composable** 三层拆分：

1. **View** — 页面级组件，职责是组装子组件、管理页面级状态
   - 简单页面: 直接在 View 中编写逻辑
   - 复杂页面: View 仅做组装，逻辑提取到 Composable，UI拆到 Components

2. **Components** — 按功能域组织在 `components/{Feature}/` 目录
   - 通过 `props` 接收数据，`emit` 向上通信
   - 不直接调用 API，数据由父组件或 composable 提供

3. **Composable** — `use{Feature}.js` 导出函数
   - 封装 ref/computed/方法，返回响应式状态和操作函数
   - 可调用 API 和 Store
   - 多个组件共享同一逻辑时必须提取
