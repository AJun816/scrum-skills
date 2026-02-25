# 项目配置

## 项目信息

- **项目名称：** Scrum Skills（敏捷团队技能组）
- **项目类型：** AI技能组 / 开发工具
- **项目描述：** 基于Claude的敏捷开发团队技能组，提供完整的软件开发流程自动化
- **版本：** 1.0.0

## 技术栈

### 支持的技术栈

技能组不限定技术栈，根据用户项目的 `PROJECT_CONFIG.md` 自动适配。

**后端（自动适配）：** Java / Go / Python / Node.js / Rust / C# / PHP / Ruby 等
**前端（自动适配）：** Vue / React / Angular / Svelte / Next.js 等
**数据库：** MySQL / PostgreSQL / MongoDB / Redis 等
**其他：** Git、Docker、CI/CD、Nginx 等

## 业务域

本项目是技能组工具项目，主要业务域：

1. **技能管理（skills）** - 技能定义、配置、执行和协调
2. **团队协作（collaboration）** - 任务分配、进度监控、团队沟通
3. **代码质量（quality）** - 代码审查、质量检查、标准执行
4. **项目管理（management）** - 需求分析、架构设计、迭代规划

## 代码规范

### 文件大小限制

- **硬性限制：** 单个文件 ≤ 800 行
- **警告阈值：** 单个文件 > 600 行

### 方法大小限制

- **硬性限制：** 单个方法 ≤ 50 行
- **建议限制：** 单个方法 ≤ 30 行

### 设计原则

1. **KISS原则** - 保持简单
2. **单一职责原则** - 每个类/方法只有一个职责
3. **DRY原则** - 不重复
4. **最小变更原则** - 只改必要的部分
5. **代码复用** - 优先复用已有代码

## 技能组配置

### 可用技能列表

| # | 技能 | 职责 |
|---|------|------|
| 0 | scrum-master | 敏捷教练（协调者） |
| 1 | business-expert | 业务专家 |
| 2 | product-manager | 产品经理 |
| 3 | system-architect | 系统架构师 |
| 4 | backend-dev | 后端开发（通用语言） |
| 4 | frontend-dev | 前端开发（通用框架） |
| 4 | frontend-design | 前端视觉设计 |
| 4 | nielsen-ui-design | UI/UX设计 |
| 5 | devops-engineer | DevOps工程师 |
| 5 | webapp-testing | Web应用测试 |
| 6 | bug-handler | Bug处理专家 |
| 7 | skill-creator | 技能创建器 |
| 8 | code-reviewer | 代码审查专家 |

### 标准工作流程

```
用户需求
  ↓
1. 需求分析（Product Manager）
  ↓
2. 用户故事（Product Manager）
  ↓
3. 架构设计（System Architect）
  ↓
4. 并行开发
   ├── 后端开发（Backend Dev）
   ├── 前端开发（Frontend Dev）
   └── UI设计（UI Designer）
  ↓
5. 代码审查（Code Reviewer）
  ↓
6. 测试验证（Tester）
  ↓
7. 交付部署（DevOps）
```

## 代码质量 Hooks

通过 `.claude/settings.json` 自动生效：

| Hook | 触发时机 | 作用 |
|------|----------|------|
| pre-bash.sh | git commit 前 | 检查 Reviewed-by 审查标记 |
| pre-file-write.sh | 文件写入前 | 代码文件 >800 行阻止，>600 行警告 |
| post-file-write.sh | 文件写入后 | 代码质量报告（方法行数、嵌套深度、代码异味、linter） |

## 缓存机制

缓存目录：`.cache/`（已 gitignore）

- 首次使用：全量分析，生成缓存
- 后续使用：加载缓存，增量更新
- 使用 git diff 识别变更
- Token 节约率：70-80%
