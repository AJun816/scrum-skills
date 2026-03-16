# 初始化与缓存指南

**定义技能组的初始化检测、引导流程和缓存机制。**

---

## 初始化检测

### 检测逻辑

每次技能启动时，检查 `.cache/.project-info.json`：

| 缓存文件 | 配置文件 | 状态 | 处理 |
|----------|---------|------|------|
| ✅ 存在 | ✅ 存在 | 已初始化 | 加载配置，更新last_used，直接工作 |
| ❌ 不存在 | ❌ 不存在 | 未初始化 | 启动初始化引导流程 |
| ❌ 不存在 | ✅ 存在 | 缓存丢失 | 从配置文件重建缓存 |
| ✅ 存在 | ❌ 不存在 | 配置丢失 | 从缓存恢复或重新初始化 |

### 已初始化的响应

```markdown
✅ 检测到项目信息
- 项目名称：{从缓存读取}
- 初始化时间：{从缓存读取}
可以直接开始工作了！
```

### 未初始化的引导

提供两种方式：
1. **自动分析（推荐）**：遍历项目代码，识别技术栈和业务模块
2. **手动配置**：用户逐项提供项目信息

## 自动分析流程

### 步骤1：扫描项目结构

**识别技术栈：**
- 前端：检查 `package.json` dependencies（vue/react/angular）+ 配置文件（vite/webpack）
- 后端：检查 `pom.xml`（Spring Boot）/ `package.json`（NestJS/Express）/ `requirements.txt`（Django/Flask）
- 数据库：检查 `application.yml`、`docker-compose.yml` 中的数据库配置
- 架构：检查目录结构（domain/application/infrastructure → DDD）

**识别业务模块：**
- Java：扫描 `src/main/java/com/{company}/{project}/` 下的顶层包
- Node.js：扫描 `src/modules/` 或 `src/domains/`
- Python：扫描 `apps/` 或 `modules/`
- 前端：扫描 `src/views/` 或 `src/pages/`

### 步骤2：确认并保存

展示识别结果让用户确认，然后生成 `PROJECT_CONFIG.md` 和 `.cache/.project-info.json`。

## 缓存机制

### 缓存目录结构

```
.cache/
├── .project-info.json              # 项目初始化信息
├── shared/                         # 团队共享文档
│   ├── requirements/               # 需求文档
│   ├── architecture/               # 架构设计
│   ├── api-design/                 # API设计
│   ├── test-reports/               # 测试报告
│   ├── ui-review/                  # UI审核报告
│   ├── code-review/                # 代码审查报告
│   ├── repo-map.md                 # 仓库地图（全局项目结构，初始化时生成）
│   └── SHARED_INDEX.md             # 总索引
├── 0-scrum-master/                 # 各技能独立缓存
├── 1-business-expert/
├── ...
└── 8-code-reviewer/
```

### .project-info.json 结构

```json
{
  "project_name": "项目名称",
  "initialized": true,
  "initialized_at": "2024-02-12 16:00:00",
  "last_used": "2024-02-12 17:30:00",
  "config_version": "1.0",
  "cache_version": "1.0",
  "tech_stack": {
    "frontend": "Vue 3",
    "backend": "Spring Boot",
    "database": "MySQL"
  },
  "business_domains": ["product", "order", "user", "payment"]
}
```

### 缓存工作原理

**首次使用：**
1. 分析项目文件，提取关键信息
2. 生成缓存保存到 `.cache/{skill-name}/`

**后续使用：**
1. 优先加载缓存文件（快速、省token）
2. 使用 `git diff` 识别变更
3. 只读取变更的文件
4. 增量更新缓存

### 仓库地图（Repo Map）

**目的：** 为所有技能提供全局项目结构视图，避免每个技能重复扫描项目。

**生成时机：** 项目初始化时（步骤2：确认并保存）自动生成。

**存储位置：** `.cache/shared/repo-map.md`

**格式规范：**

```markdown
# 仓库地图

**生成时间：** {timestamp}
**最后更新：** {timestamp}
**基于提交：** {commit_hash}

## 技术栈概览
- 后端：{语言} + {框架}
- 前端：{框架} + {UI库}
- 数据库：{数据库}
- 构建工具：{工具}

## 目录结构
{tree 输出，深度2-3层，排除 node_modules/.git/dist/build}

## 核心模块
| 模块 | 路径 | 职责 | 关键文件 |
|------|------|------|----------|

## 入口文件
- 后端入口：{path}
- 前端入口：{path}
- 配置文件：{列出关键配置}

## 公共模块（复用扫描参考）
- utils/：{描述}
- common/：{描述}
- shared/：{描述}
```

**增量更新规则：**
- 触发条件与缓存增量更新一致
- 仅在目录结构或依赖变化时更新，纯代码修改不触发

### 增量更新

**触发条件：** git有新提交 / 上次扫描超过24小时 / 用户手动触发

**流程：**
1. `git diff --name-only {last_scan_commit} HEAD` 获取变更文件
2. 过滤相关文件（源码、配置），忽略测试/文档/构建产物
3. 分析变更影响（新业务域、新API、新数据模型）
4. 增量更新配置和缓存

### 手动刷新

```bash
# 清除所有缓存
rm -rf .cache/

# 清除特定技能缓存
rm -rf .cache/{skill-name}/
```

下次使用时会自动重新生成缓存。

