# 前端代码模板与最佳实践

## 1. View 页面组件模板

### 标准页面（使用 PageLayout）

```vue
<template>
  <PageLayout title="页面标题" description="页面功能简介">
    <!-- 控制面板区域 -->
    <ControlsPanel
      v-model:date-range="dateRange"
      v-model:filter-type="filterType"
      @search="loadData"
    />

    <!-- 数据统计卡片 -->
    <StatsGrid
      :total="total"
      :success-rate="successRate"
    />

    <!-- 数据表格 -->
    <DataTable
      :data="tableData"
      :loading="loading"
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :total="totalRecords"
      @export="handleExport"
      @page-change="loadData"
    />
  </PageLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { ElMessage } from 'element-plus';
import PageLayout from '../components/PageLayout.vue';
import ControlsPanel from '../components/FeatureName/ControlsPanel.vue';
import StatsGrid from '../components/FeatureName/StatsGrid.vue';
import DataTable from '../components/FeatureName/DataTable.vue';
import { fetchData } from '../api/domain-name';

// 筛选状态
const dateRange = ref(getDefaultDateRange());
const filterType = ref('all');

// 数据状态
const loading = ref(false);
const tableData = ref([]);

// 分页
const currentPage = ref(1);
const pageSize = ref(20);
const totalRecords = ref(0);

// 统计指标
const total = ref(0);
const successRate = ref(0);

// 默认日期范围（最近7天）
function getDefaultDateRange() {
  const end = new Date();
  const start = new Date();
  start.setDate(start.getDate() - 7);
  return [start, end];
}

// 加载数据
const loadData = async () => {
  loading.value = true;
  try {
    const params = {
      from: formatDate(dateRange.value[0]),
      to: formatDate(dateRange.value[1]),
      page: currentPage.value,
      pageSize: pageSize.value
    };
    const response = await fetchData(params);
    tableData.value = response?.data?.records || [];
    totalRecords.value = response?.data?.total || 0;
  } catch (error) {
    ElMessage.error('数据加载失败，请稍后重试');
  } finally {
    loading.value = false;
  }
};

// 日期格式化
const formatDate = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d} 00:00:00`;
};

onMounted(() => {
  loadData();
});
</script>
```

### 复杂页面（带侧边工作台）

```vue
<template>
  <div class="feature-page">
    <div class="content-area">
      <div class="page-header">
        <h2 class="page-title">页面标题</h2>
        <p class="page-description">功能描述</p>
      </div>

      <el-tabs v-model="activeTab" type="card">
        <el-tab-pane label="配置" name="config">
          <ConfigPanel :form-data="formData" @submit="handleSubmit" />
        </el-tab-pane>
        <el-tab-pane label="列表" name="list">
          <ItemList :items="items" :loading="loading" @edit="handleEdit" />
        </el-tab-pane>
      </el-tabs>
    </div>

    <WorkbenchPanel v-model:collapsed="isWorkbenchCollapsed">
      <template #actions>
        <el-button @click="handleCreate" style="width: 100%">
          <el-icon><Plus /></el-icon>
          新增
        </el-button>
        <el-button type="success" @click="handleDeploy" :loading="deployLoading" style="width: 100%">
          <el-icon><Check /></el-icon>
          执行
        </el-button>
      </template>
    </WorkbenchPanel>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { Plus, Check } from '@element-plus/icons-vue';
import WorkbenchPanel from '../components/WorkbenchPanel.vue';
// ... composables 和业务逻辑
</script>
```

## 2. Component 子组件模板

### 数据表格组件

```vue
<template>
  <el-card shadow="never">
    <template #header>
      <div class="card-header">
        <span>表格标题</span>
        <div class="header-actions">
          <el-button type="primary" size="small" @click="$emit('export')">导出</el-button>
        </div>
      </div>
    </template>

    <el-table :data="data" v-loading="loading" stripe>
      <el-table-column prop="name" label="名称" min-width="120" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="row.status === 'active' ? 'success' : 'info'">
            {{ row.status === 'active' ? '活跃' : '暂停' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="$emit('edit', row)">编辑</el-button>
          <el-button link type="danger" @click="$emit('delete', row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="localPage"
      v-model:page-size="localPageSize"
      :total="total"
      :page-sizes="[10, 20, 50, 100]"
      layout="total, sizes, prev, pager, next"
      @current-change="$emit('update:currentPage', $event)"
      @size-change="$emit('update:pageSize', $event)"
    />
  </el-card>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  data: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  currentPage: { type: Number, default: 1 },
  pageSize: { type: Number, default: 20 },
  total: { type: Number, default: 0 }
});

const emit = defineEmits(['export', 'edit', 'delete', 'update:currentPage', 'update:pageSize']);

const localPage = computed({
  get: () => props.currentPage,
  set: (val) => emit('update:currentPage', val)
});
const localPageSize = computed({
  get: () => props.pageSize,
  set: (val) => emit('update:pageSize', val)
});
</script>
```

### 统计卡片组件

```vue
<template>
  <el-row :gutter="16" class="stats-grid">
    <el-col :span="6" v-for="stat in stats" :key="stat.label">
      <el-card shadow="never" class="stat-card">
        <div class="stat-value" :style="{ color: stat.color }">{{ stat.value }}</div>
        <div class="stat-label">{{ stat.label }}</div>
      </el-card>
    </el-col>
  </el-row>
</template>

<script setup>
import { computed } from 'vue';

const props = defineProps({
  total: { type: Number, default: 0 },
  successRate: { type: Number, default: 0 },
  pendingCount: { type: Number, default: 0 },
  improvement: { type: Number, default: 0 }
});

const stats = computed(() => [
  { label: '总数', value: props.total, color: '#409eff' },
  { label: '成功率', value: `${props.successRate}%`, color: '#67c23a' },
  { label: '待处理', value: props.pendingCount, color: '#e6a23c' },
  { label: '提升', value: `${props.improvement}%`, color: '#f56c6c' }
]);
</script>
```

### 控制面板组件

```vue
<template>
  <el-card shadow="never" class="controls-panel">
    <el-form :inline="true">
      <el-form-item label="日期范围">
        <el-date-picker
          :model-value="dateRange"
          @update:model-value="$emit('update:dateRange', $event)"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          :shortcuts="dateShortcuts"
        />
      </el-form-item>
      <el-form-item label="类型">
        <el-select
          :model-value="filterType"
          @update:model-value="$emit('update:filterType', $event)"
          placeholder="请选择"
        >
          <el-option label="全部" value="all" />
          <el-option label="类型A" value="typeA" />
          <el-option label="类型B" value="typeB" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="$emit('search')">查询</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup>
defineProps({
  dateRange: { type: Array, default: () => [] },
  filterType: { type: String, default: 'all' }
});

defineEmits(['update:dateRange', 'update:filterType', 'search']);

const dateShortcuts = [
  { text: '最近7天', value: () => { const e = new Date(); const s = new Date(); s.setDate(s.getDate() - 7); return [s, e]; } },
  { text: '最近30天', value: () => { const e = new Date(); const s = new Date(); s.setDate(s.getDate() - 30); return [s, e]; } }
];
</script>
```

## 3. Composable 组合式函数模板

```javascript
import { ref, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { fetchItems, createItem, updateItem, deleteItem } from '../api/domain-name';

/**
 * 功能管理 composable
 * 封装列表加载、增删改查、分页等通用逻辑
 */
export function useItemManagement() {
  // 列表数据
  const items = ref([]);
  const loading = ref(false);
  const selectedItems = ref([]);

  // 分页
  const page = ref(1);
  const pageSize = ref(20);
  const total = ref(0);

  // 筛选
  const filters = ref({});

  // 加载列表
  const loadItems = async (params = {}) => {
    loading.value = true;
    try {
      const requestParams = {
        page: params.page || page.value,
        pageSize: params.pageSize || pageSize.value,
        ...filters.value
      };
      const response = await fetchItems(requestParams);
      items.value = response?.data?.records || [];
      total.value = response?.data?.total || 0;
      page.value = requestParams.page;
      pageSize.value = requestParams.pageSize;
    } catch (error) {
      ElMessage.error('加载数据失败，请稍后重试');
    } finally {
      loading.value = false;
    }
  };

  // 删除
  const onDelete = async (item) => {
    try {
      await ElMessageBox.confirm('确认删除该记录？', '提示', { type: 'warning' });
      await deleteItem(item.id);
      ElMessage.success('删除成功');
      await loadItems();
    } catch (error) {
      if (error !== 'cancel') {
        ElMessage.error('删除失败');
      }
    }
  };

  // 筛选变更
  const onFilterChange = (newFilters) => {
    filters.value = { ...filters.value, ...newFilters };
    page.value = 1;
    loadItems();
  };

  const resetFilters = () => {
    filters.value = {};
    page.value = 1;
    loadItems();
  };

  return {
    items,
    loading,
    selectedItems,
    page,
    pageSize,
    total,
    filters,
    loadItems,
    onDelete,
    onFilterChange,
    resetFilters
  };
}
```

## 4. API 模块模板

### 新业务域 API 模块

```javascript
// src/api/domain-name.js
import axios from 'axios';
import { getApiBaseUrl, API_TIMEOUT, API_RETRY_CONFIG } from './config';

// API配置
const API_CONFIG = {
  BASE_URL: getApiBaseUrl('DEFAULT'),
  ENDPOINTS: {
    LIST: '/domain/items',
    DETAIL: '/domain/items',     // GET /{id}
    CREATE: '/domain/items',     // POST
    UPDATE: '/domain/items',     // PUT /{id}
    DELETE: '/domain/items'      // DELETE /{id}
  }
};

// 创建 Axios 实例
const domainApi = axios.create({
  baseURL: API_CONFIG.BASE_URL,
  timeout: API_TIMEOUT.DEFAULT,
  withCredentials: true
});

// 重试拦截器（标准模式）
domainApi.interceptors.response.use(
  response => response,
  async error => {
    const req = error.config;
    if (!req._retryCount) req._retryCount = 0;
    if (req._retryCount >= API_RETRY_CONFIG.MAX_RETRIES) return Promise.reject(error);
    req._retryCount++;
    const delay = API_RETRY_CONFIG.RETRY_DELAY * Math.pow(2, req._retryCount - 1);
    await new Promise(r => setTimeout(r, delay));
    return domainApi(req);
  }
);

/**
 * 获取列表
 * @param {Object} params - { page, pageSize, ...filters }
 */
export const fetchItems = async (params) => {
  try {
    const response = await domainApi.get(API_CONFIG.ENDPOINTS.LIST, { params });
    return response.data;
  } catch (error) {
    console.error('获取列表失败:', error);
    throw error;
  }
};

/**
 * 获取详情
 * @param {string|number} id
 */
export const fetchItemDetail = async (id) => {
  try {
    const response = await domainApi.get(`${API_CONFIG.ENDPOINTS.DETAIL}/${id}`);
    return response.data;
  } catch (error) {
    console.error('获取详情失败:', error);
    throw error;
  }
};

/**
 * 创建
 * @param {Object} data - 创建参数（对齐后端 CreateRequest DTO）
 */
export const createItem = async (data) => {
  try {
    const response = await domainApi.post(API_CONFIG.ENDPOINTS.CREATE, data);
    return response.data;
  } catch (error) {
    console.error('创建失败:', error);
    throw error;
  }
};

/**
 * 更新
 * @param {string|number} id
 * @param {Object} data - 更新参数（对齐后端 UpdateRequest DTO）
 */
export const updateItem = async (id, data) => {
  try {
    const response = await domainApi.put(`${API_CONFIG.ENDPOINTS.UPDATE}/${id}`, data);
    return response.data;
  } catch (error) {
    console.error('更新失败:', error);
    throw error;
  }
};

/**
 * 删除
 * @param {string|number} id
 */
export const deleteItem = async (id) => {
  try {
    const response = await domainApi.delete(`${API_CONFIG.ENDPOINTS.DELETE}/${id}`);
    return response.data;
  } catch (error) {
    console.error('删除失败:', error);
    throw error;
  }
};
```

### 域内模块拆分模式

当一个域的 API 较多时，拆分为多个子模块 + 统一入口：

```
src/api/
├── domain.js           # 统一入口，re-export所有子模块
├── domain-base.js      # Axios实例 + 通用请求方法
├── domain-xxx.js       # 子模块A的API函数
├── domain-yyy.js       # 子模块B的API函数
└── domain-utils.js     # 该域的工具函数
```

统一入口 `domain.js`：
```javascript
import { API_CONFIG, domainApi } from './domain-base';
import { fetchXxx, createXxx } from './domain-xxx';
import { fetchYyy } from './domain-yyy';

export { API_CONFIG, domainApi, fetchXxx, createXxx, fetchYyy };
```

## 5. Store 模块模板

```typescript
// src/store/modules/feature-name.ts
import { defineStore } from "pinia";
import { store } from "../utils";

interface FeatureState {
  /** 状态描述 */
  someData: string;
  /** 是否已加载 */
  loaded: boolean;
}

export const useFeatureStore = defineStore("feature-name", {
  state: (): FeatureState => ({
    someData: "",
    loaded: false
  }),

  getters: {
    /** Getter 描述 */
    formattedData(state): string {
      return state.someData.toUpperCase();
    }
  },

  actions: {
    /** 更新数据 */
    updateData(value: string) {
      this.someData = value;
      localStorage.setItem("feature-data", value);
    },

    /** 从后端加载 */
    async loadFromServer() {
      try {
        // 调用 API
        this.loaded = true;
      } catch (e) {
        console.warn("加载失败，使用默认配置", e);
        this.loaded = true;
      }
    },

    /** 从localStorage恢复 */
    restore() {
      const saved = localStorage.getItem("feature-data");
      if (saved) this.someData = saved;
    },

    /** 初始化 */
    async init() {
      this.restore();
      await this.loadFromServer();
    }
  }
});

/** Hook方式使用（在setup外也可调用） */
export function useFeatureStoreHook() {
  return useFeatureStore(store);
}
```

## 6. Router 路由注册模板

```javascript
// 在 src/router/index.js 的 routes 数组中添加

// 新功能模块
{
  path: '/feature-path',
  name: 'FeatureName',
  component: Layout,
  redirect: '/feature-path/index',
  meta: {
    title: '功能名称',
    icon: 'ep:图标名',   // Element Plus 图标，前缀 ep:
    rank: 10             // 菜单排序
  },
  children: [
    {
      path: '/feature-path/index',
      name: 'FeatureNameIndex',
      component: () => import('../views/FeatureName.vue'),
      meta: {
        title: '功能名称',
        icon: 'ep:图标名'
      }
    }
  ]
}
```

## 7. 常用 Element Plus 模式

### 确认对话框
```javascript
import { ElMessageBox, ElMessage } from 'element-plus';

const handleDelete = async () => {
  try {
    await ElMessageBox.confirm('确认删除？此操作不可恢复。', '警告', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning'
    });
    // 执行删除
    ElMessage.success('删除成功');
  } catch {
    // 用户点击取消，不做处理
  }
};
```

### 表单验证
```vue
<template>
  <el-form ref="formRef" :model="formData" :rules="rules" label-width="120px">
    <el-form-item label="名称" prop="name">
      <el-input v-model="formData.name" placeholder="请输入名称" maxlength="50" show-word-limit />
    </el-form-item>
    <el-form-item>
      <el-button type="primary" @click="handleSubmit">提交</el-button>
    </el-form-item>
  </el-form>
</template>

<script setup>
import { ref, reactive } from 'vue';

const formRef = ref(null);
const formData = reactive({ name: '' });
const rules = {
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }]
};

const handleSubmit = async () => {
  const valid = await formRef.value.validate().catch(() => false);
  if (!valid) return;
  // 提交逻辑
};
</script>
```

### v-model 双向绑定（父子组件）
```vue
<!-- 父组件 -->
<ChildComponent v-model:visible="dialogVisible" v-model:value="inputValue" />

<!-- 子组件 -->
<script setup>
const props = defineProps({
  visible: Boolean,
  value: String
});
const emit = defineEmits(['update:visible', 'update:value']);
// 使用: emit('update:visible', false)
</script>
```
