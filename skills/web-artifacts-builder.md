# Web Artifacts Builder

你是一个专注于 AFF 联盟营销系统前端开发的专家。基于以下技术栈和架构规范构建前端组件和页面。

## 技术栈

- **框架**: Vue 3.5+ (Composition API + `<script setup>`)
- **UI库**: Element Plus 2.x
- **状态管理**: Pinia 3.x
- **构建工具**: Vite 7.x
- **路由**: Vue Router 4.x
- **HTTP**: Axios (封装在 `src/utils/http/index.ts` 中的 PureHttp 类)
- **样式**: SCSS + Tailwind CSS 3.x
- **图标**: unplugin-icons (使用 `~icons/ri/xxx` 导入)
- **图表**: ECharts 6.x

## 项目结构

```
web/src/
├── api/              # API 接口定义（按模块拆分：skro.js, propellerads.js, automation.js）
├── components/       # 通用组件和业务组件
│   ├── AutoCampaign/ # 智能投放相关组件
│   ├── PageLayout.vue
│   └── WorkbenchPanel.vue
├── composables/      # 组合式函数（useBudgetCalculator, useDeploymentProcess 等）
├── layout/           # 布局组件
│   └── components/lay-navbar/  # 顶部导航栏（含 PlatformSelector）
├── store/modules/    # Pinia stores（user.ts, platform.ts）
├── utils/http/       # HTTP 请求封装（PureHttp 类 + 拦截器）
├── views/            # 页面视图
└── router/           # 路由配置
```

## 核心架构约定

### 1. 平台上下文
所有 API 请求自动携带平台上下文 Header（通过 axios 拦截器注入）：
- `X-Platform-Affiliate`: 当前广告联盟（如 goldengoose）
- `X-Platform-Tracker`: 当前追踪器（如 skro）
- `X-Platform-Traffic`: 当前流量源（如 propellerads）

使用 `usePlatformStoreHook()` 获取平台状态。

### 2. 组件编写规范
- 使用 `<script setup>` + TypeScript（或 JS）
- 使用 Element Plus 组件，不引入其他 UI 库
- 样式使用 `<style lang="scss" scoped>`
- 组件文件不超过 800 行，超过则拆分
- Props 使用 defineProps，事件使用 defineEmits

### 3. API 调用规范
```javascript
// 使用项目封装的 http 工具
import { http } from "@/utils/http";

// GET 请求
export const getData = (params) => http.get("/api/v1/xxx", { params });

// POST 请求
export const postData = (data) => http.post("/api/v1/xxx", { data });
```

### 4. Store 规范
```typescript
import { defineStore } from "pinia";
import { store } from "../utils";

export const useXxxStore = defineStore("xxx", {
  state: () => ({ /* ... */ }),
  getters: { /* ... */ },
  actions: { /* ... */ }
});

// 外部使用（非 setup 上下文）
export function useXxxStoreHook() {
  return useXxxStore(store);
}
```

### 5. Composable 规范
- 文件名以 `use` 开头，如 `useBudgetCalculator.js`
- 返回响应式引用和方法
- 保持单一职责

### 6. 页面结构模板
```vue
<template>
  <PageLayout title="页面标题" description="页面描述">
    <div class="content-section">
      <!-- 内容 -->
    </div>
  </PageLayout>
</template>

<script setup>
import { ref } from 'vue'
import PageLayout from '@/components/PageLayout.vue'
import { usePlatformStoreHook } from '@/store/modules/platform'

const platformStore = usePlatformStoreHook()
</script>

<style lang="scss" scoped>
.content-section {
  padding: 20px;
  background: white;
  border-radius: 8px;
}
</style>
```

## 构建指令

当被要求创建前端组件或页面时：
1. 遵循上述技术栈和规范
2. 复用已有组件（PageLayout, WorkbenchPanel 等）
3. 使用 `usePlatformStoreHook()` 获取平台上下文
4. API 文件放在 `src/api/` 下
5. 组合式函数放在 `src/composables/` 下
6. 确保与全局平台选择器联动（Header 自动注入）
7. 不引入新依赖，优先使用已有工具
8. 中文注释，中文 UI 文案
