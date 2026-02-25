# 敏捷团队技能组

**复制此目录到你的项目，直接使用！**

## 快速开始

### 1. 复制到你的项目

```bash
# 复制技能目录和hooks配置
cp -r skills/ your-project/.claude/skills/
cp .claude/settings.json your-project/.claude/settings.json
```

### 2. 开始使用

直接调用任何技能，第一次使用时会自动引导你初始化。

```
/0-scrum-master 帮我组织一次迭代计划会议
```

首次使用会自动引导配置项目信息（名称、技术栈、业务模块）。

## 文件说明

```
skills/
├── config/                        # 共享配置
│   ├── mandatory-rules.md         # 强制执行规范
│   ├── coding-standards.md        # 编码规范
│   ├── workflow-guide.md          # 工作流程指南
│   └── init-guide.md              # 初始化指南
├── hooks/                         # 代码质量钩子（自动生效）
├── .cache/                        # 缓存目录（自动生成，已gitignore）
│
├── 0-scrum-master/                # 敏捷教练
├── 1-business-expert/             # 业务专家
├── 2-product-manager/             # 产品经理
├── 3-system-architect/            # 系统架构师
├── 4-backend-dev/                 # 后端开发（通用语言）
├── 4-frontend-dev/                # 前端开发（通用框架）
├── 4-nielsen-ui-design/           # UI/UX设计（尼尔森原则）
├── 4-frontend-design/             # 前端视觉设计
├── 5-devops-engineer/             # DevOps工程师
├── 5-webapp-testing/              # Web应用测试
├── 6-bug-handler/                 # Bug处理专家
├── 7-skill-creator/               # 技能创建器
├── 8-code-reviewer/               # 代码审查专家
│
├── PROJECT_CONFIG.md              # 项目配置（自动生成）
├── PROJECT_CONFIG.template.md     # 配置模板（参考）
└── README.md                      # 本文件
```

## 技能列表

| 技能 | 说明 | 使用场景 |
|------|------|----------|
| 0-scrum-master | 敏捷教练 | 组织敏捷仪式、协调团队、移除障碍 |
| 1-business-expert | 业务专家 | 梳理业务流程、定义业务规则 |
| 2-product-manager | 产品经理 | 需求分析、用户故事、需求变更 |
| 3-system-architect | 系统架构师 | 架构设计、技术选型、任务拆解 |
| 4-backend-dev | 后端开发 | 后端代码实现、API开发（根据项目自动适配语言） |
| 4-frontend-dev | 前端开发 | 前端页面开发、组件设计（根据项目自动适配框架） |
| 4-nielsen-ui-design | UI/UX设计 | 基于尼尔森原则的可用性设计 |
| 4-frontend-design | 前端视觉设计 | 创意视觉设计、品牌形象 |
| 5-devops-engineer | DevOps工程师 | CI/CD、自动化部署、监控 |
| 5-webapp-testing | Web应用测试 | 自动化测试、功能验证 |
| 6-bug-handler | Bug处理专家 | Bug分析、修复协调、验证 |
| 7-skill-creator | 技能创建器 | 创建新技能、扩展团队能力 |
| 8-code-reviewer | 代码审查专家 | git提交前代码审查、质量把关 |

## 核心机制

### 配置驱动

所有技能读取 `PROJECT_CONFIG.md` 获取项目信息（技术栈、业务域、架构模式等），确保统一上下文，节约 70-80% Token。

### 数据验证（Read-First）

防止AI幻觉：所有回答前必须先读取文件验证，标注数据来源，不确定时明确说明。

### 代码质量钩子

通过 `.claude/settings.json` 自动生效，无需手动配置：
- 文件超800行阻止写入
- 检测密码/密钥泄露
- 阻止危险命令（force push、DROP TABLE等）
- git commit 需要代码审查标记

### 智能缓存

技能自动缓存项目信息到 `.cache/` 目录，使用 `git diff` 增量更新。

### 团队共享文档

技能产出保存到 `.cache/shared/`，一次产出多次使用，避免重复劳动。

## 设计原则

1. **复制粘贴就能用** — skills 目录自包含，无外部依赖
2. **开箱即用** — hooks 自动生效，首次使用自动初始化
3. **配置驱动** — 统一配置，所有技能共享
4. **通用适配** — 后端/前端技能不限语言，根据项目自动适配
5. **质量内建** — hooks 强制执行代码规范，代码审查把关提交
