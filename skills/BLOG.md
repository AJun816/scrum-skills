# AI驱动的敏捷团队技能组：让AI变身完整开发团队

> 🚀 通用的AI敏捷开发团队框架，支持Claude等AI工具，从需求分析到代码审核全流程自动化

## 🎯 项目介绍

**scrum-skills** 是一个创新的AI协作框架，将真实的敏捷开发团队搬进AI工具。

**核心理念：skills技能组是通用的，不限定语言和框架，根据项目自动适配。**

- ✅ **Claude Code** - 通过.claude目录使用，hooks自动生效
- ✅ **其他AI工具** - 只要支持技能/提示词系统，都可以使用

### 核心特性

**🏆 完整的敏捷团队**
- 13个专业角色：产品经理、架构师、前后端开发、测试、DevOps、敏捷教练...
- 真实的敏捷流程：需求分析 → 架构设计 → 并行开发 → 测试验证 → 自动部署
- 团队协作机制：角色间自动协作，共享文档，避免重复劳动

**🛡️ 代码质量管控（核心亮点）**
- 文件写入后自动触发代码质量报告
- 检查方法行数、嵌套深度、代码异味
- 自动运行项目已有的 linter（eslint、ruff、flake8、go vet）
- git commit 前强制要求代码审查标记
- 文件超800行自动阻止写入

**🔧 通用性强，不限语言框架**
- ✅ 后端：Java / Go / Python / Node.js / Rust / C# 等
- ✅ 前端：Vue / React / Angular / Svelte 等
- ✅ 根据 PROJECT_CONFIG.md 自动适配技术栈

**💡 开箱即用**
- 复制粘贴即用，hooks通过 `.claude/settings.json` 自动生效
- 第一次使用自动引导初始化
- 节约70-80% Token，降低成本
- 防止AI幻觉，确保数据准确

---

## 📦 项目地址

**Gitee：** https://gitee.com/ajun816/scrum-skills
**GitHub：** https://github.com/AJun816/scrum-skills

欢迎Star、Fork和贡献代码！

---

## 🚀 快速使用（3步上手）

**第1步：克隆仓库**
```bash
git clone https://github.com/AJun816/scrum-skills.git
# or Gitee / 或使用 Gitee
git clone https://gitee.com/ajun816/scrum-skills.git
```

**第2步：复制到你的项目**
```bash
cp -r scrum-skills/skills/ your-project/.claude/skills/
cp scrum-skills/.claude/settings.json your-project/.claude/settings.json
```

**第3步：开始使用**
```
# 在Claude Code中直接调用技能
/0-scrum-master 帮我开发用户登录功能

# 或单独调用某个角色
/2-product-manager 分析用户登录功能的需求
/3-system-architect 设计订单管理模块的架构
/4-backend-dev 实现用户登录API
/4-frontend-dev 实现登录页面
/5-webapp-testing 编写登录功能的测试用例
```

**可选：自定义昵称和安装git hook**
```bash
sh .claude/skills/hooks/setup.sh
```

---

## 👥 13个专业角色

完整的敏捷开发团队，覆盖从需求到上线的全流程：

| 编号 | 角色 | 职责 | 典型场景 |
|------|------|------|----------|
| **0** | **敏捷教练** | 组织敏捷仪式、移除障碍、促进协作 | 迭代计划、每日站会、回顾会议 |
| **1** | **业务专家** | 梳理业务流程、定义业务规则 | 业务需求分析、流程优化 |
| **2** | **产品经理** | 需求分析、用户故事、需求变更 | 需求文档、用户故事、优先级排序 |
| **3** | **系统架构师** | 架构设计、技术选型、任务拆解 | 架构设计、技术方案、任务分配 |
| **4** | **后端开发** | 后端代码实现、API开发（通用语言） | 业务逻辑、数据库设计、API开发 |
| **4** | **前端开发** | 前端页面开发、组件设计（通用框架） | 页面开发、组件封装、状态管理 |
| **4** | **前端视觉设计** | 创意视觉设计、品牌形象 | UI设计、视觉规范、品牌设计 |
| **4** | **UI/UX设计** | 基于尼尔森原则的可用性设计 | 交互设计、可用性测试、用户体验 |
| **5** | **DevOps工程师** | CI/CD、自动化部署、监控 | 部署流程、监控告警、性能优化 |
| **5** | **Web应用测试** | 自动化测试、功能验证 | 测试用例、自动化测试、回归测试 |
| **6** | **Bug处理专家** | Bug分析、修复协调、验证 | Bug分析、修复方案、验证测试 |
| **7** | **技能创建器** | 创建自定义技能、扩展团队能力 | 新角色创建、技能优化 |
| **8** | **代码审查专家** | git提交前强制代码审查 | 代码质量检查、阻止不合规提交 |

---

## 🛡️ 代码质量管控

### Hooks 自动生效

通过 `.claude/settings.json` 配置，复制到项目后自动生效，无需手动设置。

| Hook | 触发时机 | 作用 |
|------|----------|------|
| pre-bash.sh | git commit 前 | 强制要求 `✅[Reviewed]` 前缀（无例外） |
| pre-file-write.sh | 文件写入前 | 代码文件 >800 行阻止，>600 行警告 |
| post-file-write.sh | 文件写入后 | 代码质量报告 |
| commit-msg.sh | git commit-msg | 强制要求 `✅[Reviewed]` 前缀（git hook层） |

### 代码质量报告（post-file-write）

每次写入代码文件后自动输出：

- **文件行数** — >800行报错，>600行警告
- **方法/函数长度** — >50行警告
- **嵌套深度** — >6层报错，>4层警告
- **代码异味** — console.log、TODO/FIXME/HACK 检测
- **Linter自动运行** — 检测到 eslint/ruff/flake8/go vet 自动执行

### 代码审查流程

```
开发完成 → git commit
  ↓
pre-bash.sh 检查提交信息是否包含 Reviewed-by: 8-code-reviewer ✅
  ↓
缺少标记 → ❌ 阻止提交，要求先执行代码审查
包含标记 → ✅ 允许提交
```

---

## 💡 核心价值

### 1. 完整的敏捷团队，真实的协作流程

**不是单个AI助手，而是一个完整的开发团队：**

```
用户需求
  ↓
产品经理（需求分析）→ 需求文档
  ↓
系统架构师（架构设计）→ 架构方案
  ↓
后端开发 + 前端开发 + UI设计（并行开发）→ 代码实现
  ↓
测试工程师（测试验证）→ 测试报告
  ↓
代码审查专家（质量把关）→ 审查通过
  ↓
DevOps工程师（自动部署）→ 上线发布
```

### 2. 配置驱动，节约70-80% Token

通过统一的 `PROJECT_CONFIG.md` 配置文件，让所有技能共享项目上下文，避免每个角色重复读取项目文档。

### 3. 防止AI幻觉的数据验证标准

- ✅ **Read-First原则**：所有回答前必须先读取文件验证
- ✅ **Source Traceability**：每个回答标注数据来源（文件路径:行号）
- ✅ **Uncertainty Declaration**：数据不存在时明确说明，绝不编造

### 4. 通用适配，不限语言框架

后端和前端技能根据 `PROJECT_CONFIG.md` 中的技术栈自动适配，无需为不同语言创建不同技能。

---

## 📚 使用场景

### 场景1：新功能开发（全流程自动化）

```
1. /2-product-manager 分析需求 → 产出需求文档
2. /3-system-architect 设计架构 → 产出架构设计
3. /4-backend-dev 实现后端 → 产出代码
4. /4-frontend-dev 实现前端 → 产出代码
5. /5-webapp-testing 测试验证 → 产出测试报告
6. git commit → 检查 Reviewed-by 标记 → 通过后提交
7. /5-devops-engineer 部署上线 → 完成发布
```

### 场景2：Bug修复（快速响应）

```
1. /6-bug-handler 分析Bug → 定位问题
2. /4-backend-dev 修复代码 → 提交修复
3. git commit → 检查审查标记 → 通过后提交
4. /5-webapp-testing 回归测试 → 验证修复
```

### 场景3：敏捷仪式（团队协作）

```
/0-scrum-master 组织迭代计划会议
/0-scrum-master 组织每日站会
/0-scrum-master 组织迭代回顾会议
```

### 场景4：创建自定义技能

```
/7-skill-creator 我想创建一个安全专家技能
```

技能创建器会引导你完成技能定义，自动生成符合规范的技能文件。

---

## 📖 设计原则

1. **复制粘贴就能用** — skills目录自包含，无外部依赖
2. **Hooks自动生效** — 通过 `.claude/settings.json` 自动配置
3. **配置驱动** — 统一配置，所有技能共享
4. **通用适配** — 不限语言框架，根据项目自动适配
5. **数据验证** — 防止AI幻觉，基于真实数据回答
6. **质量内建** — hooks强制执行代码规范，代码审查把关提交

---

## 🔗 项目地址

**Gitee：** https://gitee.com/ajun816/scrum-skills
**GitHub：** https://github.com/AJun816/scrum-skills

欢迎Star、Fork和贡献代码！

---

## 总结

**scrum-skills** 将敏捷开发方法论与AI多角色协作相结合，通过配置驱动、代码质量hooks、数据验证、共享文档等机制，实现了一个通用、高效、可靠的AI驱动敏捷团队框架。

**核心优势：**
- ✅ 复制粘贴即用，hooks自动生效
- ✅ 不限语言框架，根据项目自动适配
- ✅ 代码质量自动管控（方法行数、嵌套深度、linter集成）
- ✅ 节约70-80% Token，降低成本
- ✅ 防止AI幻觉，确保数据准确
- ✅ 13个专业角色，覆盖完整开发流程
