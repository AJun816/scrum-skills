# 初始化流程详解

## 概述

本文档详细说明 Scrum Master 的项目初始化流程，包括初始化检测、自动分析、配置生成、**Agent 团队创建**和增量更新机制。

## 初始化检测

### 检测逻辑

**每次执行任务前，必须先检测初始化状态：**

1. 检查缓存文件是否存在：`.cache/.project-info.json`
2. 根据检测结果执行相应流程

### 场景1：缓存存在（已初始化）

读取 `.cache/.project-info.json`，加载项目配置，直接开始工作。

**输出给用户：**
```markdown
## 🔍 检测初始化状态

✅ 检测到项目信息

你好，吴彦祖！检测到这个项目之前已经初始化过了。

**项目信息：**
- 项目名称：{从缓存读取}
- 初始化时间：{从缓存读取}
- 上次使用：{从缓存读取}

我已经加载了项目配置，可以直接开始工作了！
```

---

### 场景2：缓存不存在（未初始化）

**必须执行完整初始化流程，不得跳过。**

```markdown
## 🎯 欢迎使用敏捷团队技能组！

检测到这是第一次使用技能组，正在自动初始化项目配置...

### 🔍 自动分析项目
```

---

## 自动初始化流程（完整 8 步，必须按顺序执行）

### 步骤1：扫描项目结构

扫描技术栈配置文件（`package.json`、`pom.xml`、`requirements.txt`、`go.mod` 等），识别项目类型和技术栈。

**识别规则：**

| 文件名 | 技术栈 | 项目类型 |
|--------|--------|----------|
| package.json | Node.js/JavaScript | 前端或全栈 |
| pom.xml | Java/Maven | 后端 |
| build.gradle | Java/Gradle | 后端 |
| requirements.txt | Python | 后端或数据科学 |
| go.mod | Go | 后端 |
| Cargo.toml | Rust | 后端或系统 |

### 步骤2：分析技术栈

读取配置文件，识别具体的框架和依赖：
- 前端：Vue/React/Angular/Svelte
- 后端：Spring Boot/FastAPI/Express/Gin 等
- 数据库：通过 ORM 依赖识别

### 步骤3：识别业务模块

扫描 `src/` 目录结构，识别业务域（Java DDD 的包结构、Vue 的 views 目录等）。

### 步骤4：分析代码结构

使用 Grep 分析关键类和接口，识别架构模式（MVC/DDD/分层架构等）。

### 步骤5：推断项目信息并生成配置

综合分析结果，生成 `PROJECT_CONFIG.md`：

```markdown
# 项目配置

## 项目信息
- 项目名称：{projectName}
- 项目类型：{projectType}
- 技术栈：{techStack}

## 业务域
- {domain1}: {domain1}管理
- {domain2}: {domain2}管理

## 技术架构
- 前端：{frontend}
- 后端：{backend}
- 数据库：{database}

## 架构模式
- {architecture}

## 代码规范
- 文件大小：≤800行
- 方法大小：≤50行
- 遵循KISS原则和单一职责原则
```

### 步骤6：生成缓存文件

生成 `.cache/.project-info.json`：

```json
{
  "projectName": "{projectName}",
  "techStack": "{techStack}",
  "domains": ["{domain1}", "{domain2}"],
  "initialized": true,
  "initTime": "{ISO时间}",
  "lastUsed": "{ISO时间}",
  "teamCreated": true,
  "version": "2.0"
}
```

### 步骤7：预创建缓存目录 + 预填充技能组缓存（必须执行）

> **核心目标：** 让所有技能 clone 后首次调用时直接可用，无需各自重新扫描项目。

**7.1 创建完整缓存目录结构：**

```bash
# 共享文档目录
mkdir -p .cache/shared/{requirements,architecture,api-design,test-reports,ui-review,code-review}

# 各技能独立缓存目录
mkdir -p .cache/{0-scrum-master,1-business-expert,2-product-manager,3-system-architect}
mkdir -p .cache/{4-backend-dev,4-frontend-dev,5-devops-engineer,5-webapp-testing}
mkdir -p .cache/{6-bug-handler,8-code-reviewer}
```

**7.2 生成共享索引文件 `.cache/shared/SHARED_INDEX.md`：**

```markdown
# 共享文档索引

## 项目：{projectName}
初始化时间：{initTime}

## 目录结构
| 目录 | 用途 | 产出角色 |
|------|------|---------|
| requirements/ | 需求文档 | Product Manager |
| architecture/ | 架构设计 | System Architect |
| api-design/ | API契约 | System Architect / Backend Dev |
| test-reports/ | 测试报告 | QA Tester |
| ui-review/ | UI审核报告 | UI Designer |
| code-review/ | 代码审查报告 | Code Reviewer |

## 文档列表
（初始化完成，尚无文档。各角色执行任务后自动更新此索引。）
```

**7.3 为每个技能预填充项目概要缓存：**

为每个技能的缓存目录写入 `_project-context.md`，包含项目关键信息，避免各技能重复读取 `PROJECT_CONFIG.md`：

```markdown
# 项目上下文（自动生成，勿手动修改）

## 项目信息
- 项目名称：{projectName}
- 技术栈：{techStack}
- 架构模式：{architecture}

## 业务域
{domains.map(d => `- ${d}`).join('\n')}

## 编码规范
- 文件大小：≤800行，方法大小：≤50行
- KISS原则，单一职责
- 编码任务通过 Agent 子进程使用 Claude Code Edit/Write 工具执行

## 技术栈详情
- 前端：{frontend}
- 后端：{backend}
- 数据库：{database}

---
生成时间：{initTime}
```

**写入到以下所有缓存目录：**
- `.cache/0-scrum-master/_project-context.md`
- `.cache/1-business-expert/_project-context.md`
- `.cache/2-product-manager/_project-context.md`
- `.cache/3-system-architect/_project-context.md`
- `.cache/4-backend-dev/_project-context.md`
- `.cache/4-frontend-dev/_project-context.md`
- `.cache/5-devops-engineer/_project-context.md`
- `.cache/5-webapp-testing/_project-context.md`
- `.cache/6-bug-handler/_project-context.md`
- `.cache/8-code-reviewer/_project-context.md`

**7.4 为各技能预填充 `_cache-meta.json`：**

```json
{
  "version": "1.0",
  "createdAt": "{initTime}",
  "updatedAt": "{initTime}",
  "source": "scrum-master-init",
  "projectName": "{projectName}",
  "techStack": "{techStack}",
  "needsFullScan": true
}
```

> `needsFullScan: true` 表示该技能首次被调用时仍需执行自己的详细扫描（如后端开发需要扫描 API 端点列表），但项目基础信息已预填充，无需重复获取。

**输出给用户：**
```markdown
✅ 缓存目录已创建（共享目录 + 10 个技能缓存）
✅ 项目上下文已预填充到所有技能缓存
✅ 共享索引 SHARED_INDEX.md 已生成
```

### 步骤8：创建 Agent 团队（必须执行）

> **强制要求**：初始化完成后，必须使用 TeamCreate 创建敏捷团队，并在后续任务中优先使用多 Agent 并行执行。

**创建标准敏捷团队：**

```markdown
## 🤖 创建敏捷 Agent 团队

正在为项目创建敏捷开发团队...
```

**Agent 团队组成（标准配置）：**

| Agent 名称 | 角色 | 任务类型 |
|-----------|------|---------|
| `product-manager` | 产品经理 | 需求分析、用户故事 |
| `system-architect` | 系统架构师 | 架构设计、API契约 |
| `backend-dev` | 后端开发 | 后端编码（Agent 子进程） |
| `frontend-dev` | 前端开发 | 前端编码（Agent 子进程） |
| `qa-tester` | 测试工程师 | 测试验证 |

**创建流程（伪代码）：**

```javascript
// 1. 创建团队
const team = TeamCreate({
  team_name: "{projectName}-agile-team",
  description: "敏捷开发团队：{projectName}",
  agent_type: "scrum-master"
})

// 2. 保存团队信息到缓存
const cache = Read(".cache/.project-info.json")
cache.teamName = "{projectName}-agile-team"
cache.teamCreated = true
Write(".cache/.project-info.json", cache)
```

**输出给用户：**
```markdown
## ✅ 初始化完成

**识别结果：**
- 项目名称：{projectName}
- 技术栈：{techStack}
- 业务域：{domains}
- 架构模式：{architecture}

**已创建：**
- ✅ PROJECT_CONFIG.md — 项目配置文件
- ✅ .cache/.project-info.json — 项目缓存
- ✅ .cache/shared/ — 共享文档目录（含索引）
- ✅ .cache/{各技能}/_project-context.md — 项目上下文已预填充到所有技能
- ✅ 敏捷 Agent 团队 — {team_name}

所有技能已就绪，可以直接调用任何技能开始工作！
```

---

## 后续任务执行：多 Agent 并行默认策略

初始化完成后，所有任务执行遵循以下优先顺序：

### 任务路由规则（强制）

```
编码型任务（后端/前端/DevOps/Bug修复）
  → Agent 子进程使用 Claude Code Edit/Write 工具执行
  → 执行完成后由主进程代码审查 + git commit

文档型任务（需求/架构/设计/测试报告）
  → 优先使用 Agent 子进程并行执行
  → 产出共享文档到 .cache/shared/
```

### 并行执行策略（强制）

**必须优先并行执行，不得顺序执行无依赖的任务：**

```javascript
// ✅ 正确：无依赖任务并行
const [T1, T2] = await Promise.all([
  // 需求分析 Agent
  Agent({ task: "/2-product-manager 分析 {feature} 需求" }),
  // 业务专家 Agent（可同时执行）
  Agent({ task: "/1-business-expert 梳理 {feature} 业务规则" })
])

// ✅ 正确：架构设计 Agent（等需求完成）
const T3 = await Agent({ task: "/3-system-architect 设计 {feature} 架构" })

// ✅ 正确：后端+前端 Agent 子进程并行编码（架构完成后）
// Agent 子进程使用 Claude Code Edit/Write 工具执行
```

---

## 失败处理

### 自动分析失败

无法识别项目结构时，提示用户手动编辑 `PROJECT_CONFIG.md`，使用模板配置后继续。

### Agent 团队创建失败

Team 创建失败时，记录失败信息到缓存，回退到单进程模式继续执行（不中断初始化流程）。

---

## 增量更新机制

已初始化的项目，每次启动通过 `git diff` 检测变更，只更新变更部分，节约 95% 的 Token 消耗。

---

## 最佳实践

1. **首次使用**：让系统自动分析，检查生成的配置，按需调整
2. **日常使用**：依赖增量更新机制，检查配置准确性
3. **大规模重构后**：删除缓存文件强制重新初始化
   ```bash
   rm -rf .cache/.project-info.json
   rm -rf .cache/0-scrum-master/
   ```
4. **多人协作**：`PROJECT_CONFIG.md` 纳入版本控制，缓存文件加入 `.gitignore`

---

## 总结

初始化流程确保：
1. ✅ **自动化** — 无需手动配置，自动分析项目
2. ✅ **团队就绪** — 自动创建 Agent 团队，后续任务直接并行执行
3. ✅ **准确性** — 基于真实代码结构识别
4. ✅ **高效性** — 增量更新，节约Token
5. ✅ **并行优先** — 所有无依赖任务默认并行，最大化效率


## 初始化检测

### 检测逻辑

**每次执行任务前，必须先检测初始化状态：**

1. 检查缓存文件是否存在：`.cache/.project-info.json`
2. 根据检测结果执行相应流程

### 场景1：缓存存在（已初始化）

**检测代码：**
```javascript
// 读取缓存文件
const cacheFile = ".cache/.project-info.json";
const cacheExists = await fileExists(cacheFile);

if (cacheExists) {
  // 读取缓存内容
  const projectInfo = await Read({ file_path: cacheFile });

  // 更新最后使用时间
  projectInfo.lastUsed = new Date().toISOString();
  await Write({ file_path: cacheFile, content: JSON.stringify(projectInfo) });

  // 显示欢迎信息
  displayWelcomeMessage(projectInfo);
}
```

**输出给用户：**
```markdown
## 🔍 检测初始化状态

✅ 检测到项目信息

你好！检测到这个项目之前已经初始化过了。

**项目信息：**
- 项目名称：电商平台
- 初始化时间：2026-02-10 14:30:00
- 上次使用：2026-02-15 09:00:00

看起来你是重新打开了 Claude 窗口，没关系，我已经加载了项目配置，可以直接开始工作了！

现在告诉我你想做什么吧！
```

**处理逻辑：**
- 读取缓存文件 `.cache/.project-info.json`
- 读取配置文件 `PROJECT_CONFIG.md`
- 更新 `last_used` 时间戳
- 直接开始工作

---

### 场景2：缓存不存在（未初始化）

**输出给用户：**
```markdown
## 🎯 欢迎使用敏捷团队技能组！

检测到这是第一次使用技能组，正在自动初始化项目配置...

### 🔍 自动分析项目
```

**执行自动初始化流程（详见下一节）**

---

## 自动初始化流程

### 步骤1：扫描项目结构

**目标：** 识别项目的技术栈和关键文件

**执行工具调用：**
```javascript
// 1. 扫描技术栈配置文件
const techStackFiles = await Glob({
  pattern: "**/{package.json,pom.xml,requirements.txt,go.mod,Cargo.toml,composer.json}"
});

// 输出给用户
console.log("✅ 识别关键文件");
console.log(`发现 ${techStackFiles.length} 个技术栈配置文件`);
```

**识别规则：**

| 文件名 | 技术栈 | 项目类型 |
|--------|--------|----------|
| package.json | Node.js/JavaScript | 前端或全栈 |
| pom.xml | Java/Maven | 后端 |
| build.gradle | Java/Gradle | 后端 |
| requirements.txt | Python | 后端或数据科学 |
| go.mod | Go | 后端 |
| Cargo.toml | Rust | 后端或系统 |
| composer.json | PHP | 后端 |

### 步骤2：分析技术栈

**目标：** 读取配置文件，识别具体的技术栈和依赖

**执行工具调用：**
```javascript
// 2. 读取技术栈配置文件
if (techStackFiles.includes("package.json")) {
  const packageJson = await Read({ file_path: "package.json" });
  const parsed = JSON.parse(packageJson);

  // 分析前端框架
  const frontend = analyzeFrontendFramework(parsed.dependencies);

  // 分析构建工具
  const buildTool = analyzeBuildTool(parsed.devDependencies);

  console.log("✅ 分析技术栈");
  console.log(`前端框架：${frontend}`);
  console.log(`构建工具：${buildTool}`);
}

if (techStackFiles.includes("pom.xml")) {
  const pomXml = await Read({ file_path: "pom.xml" });

  // 分析Java框架
  const backend = analyzeJavaFramework(pomXml);

  console.log(`后端框架：${backend}`);
}
```

**识别规则示例：**

**前端框架识别：**
```javascript
function analyzeFrontendFramework(dependencies) {
  if (dependencies['vue']) return 'Vue 3';
  if (dependencies['react']) return 'React';
  if (dependencies['@angular/core']) return 'Angular';
  if (dependencies['svelte']) return 'Svelte';
  return '未知前端框架';
}
```

**后端框架识别：**
```javascript
function analyzeJavaFramework(pomXml) {
  if (pomXml.includes('spring-boot-starter')) return 'Spring Boot';
  if (pomXml.includes('quarkus')) return 'Quarkus';
  if (pomXml.includes('micronaut')) return 'Micronaut';
  return '未知Java框架';
}
```

### 步骤3：识别业务模块

**目标：** 扫描代码目录，识别业务模块和领域

**执行工具调用：**
```javascript
// 3. 扫描业务模块目录
const sourceFiles = await Glob({
  pattern: "src/**/*.{js,ts,java,py,go}"
});

// 分析目录结构，识别业务模块
const modules = analyzeModules(sourceFiles);

console.log("✅ 识别业务模块");
console.log(`发现 ${modules.length} 个业务模块：${modules.join(', ')}`);
```

**识别规则：**

**Java项目（DDD架构）：**
```
src/main/java/com/company/project/
  ├── user/          → user 业务域
  ├── order/         → order 业务域
  ├── product/       → product 业务域
  └── payment/       → payment 业务域
```

**Vue项目：**
```
src/
  ├── views/
  │   ├── user/      → user 业务域
  │   ├── order/     → order 业务域
  │   └── product/   → product 业务域
  └── api/
      ├── user.js    → user 业务域
      └── order.js   → order 业务域
```

**识别代码：**
```javascript
function analyzeModules(sourceFiles) {
  const modules = new Set();

  for (const file of sourceFiles) {
    // Java DDD项目
    const javaMatch = file.match(/src\/main\/java\/.*?\/([^\/]+)\//);
    if (javaMatch) {
      modules.add(javaMatch[1]);
    }

    // Vue项目
    const vueMatch = file.match(/src\/views\/([^\/]+)\//);
    if (vueMatch) {
      modules.add(vueMatch[1]);
    }
  }

  return Array.from(modules);
}
```

### 步骤4：分析代码结构

**目标：** 使用 Grep 分析代码结构，识别关键类和接口

**执行工具调用：**
```javascript
// 4. 分析代码结构
const codeStructure = await Grep({
  pattern: "class|interface|function|def",
  path: "src/",
  output_mode: "files_with_matches"
});

console.log("✅ 分析代码结构");
console.log(`发现 ${codeStructure.length} 个代码文件`);
```

### 步骤5：推断项目信息

**目标：** 综合分析结果，推断项目信息

**推断逻辑：**
```javascript
function inferProjectInfo(techStack, modules) {
  // 推断项目名称（从 package.json 或 pom.xml）
  const projectName = inferProjectName();

  // 推断项目类型
  const projectType = inferProjectType(techStack);

  // 推断架构模式
  const architecture = inferArchitecture(modules);

  return {
    projectName,
    projectType,
    techStack,
    modules,
    architecture
  };
}
```

**输出给用户：**
```markdown
✅ 识别关键文件
✅ 分析技术栈
✅ 识别业务模块
✅ 推断项目信息

### ✅ 初始化完成

**识别结果：**
- 项目名称：电商平台
- 项目类型：Web应用
- 技术栈：Vue 3 + Spring Boot + MySQL
- 业务域：user, order, product, payment
- 架构模式：DDD（领域驱动设计）

配置已保存到 PROJECT_CONFIG.md 和缓存文件。
```

### 步骤6：生成配置文件

**目标：** 生成 PROJECT_CONFIG.md 和缓存文件

**执行工具调用：**
```javascript
// 5. 生成配置文件
const configContent = generateProjectConfig(projectInfo);

await Write({
  file_path: "PROJECT_CONFIG.md",
  content: configContent
});

console.log("✅ 生成 PROJECT_CONFIG.md");
```

**配置文件模板：**
```markdown
# 项目配置

## 项目信息
- 项目名称：{projectName}
- 项目类型：{projectType}
- 技术栈：{techStack}

## 业务域
{modules.map(m => `- ${m}: ${m}管理`).join('\n')}

## 技术架构
- 前端：{frontend}
- 后端：{backend}
- 数据库：{database}

## 架构模式
- {architecture}

## 代码规范
- 文件大小：≤800行
- 方法大小：≤50行
- 遵循KISS原则和单一职责原则
```

**生成缓存文件：**
```javascript
// 6. 生成缓存文件
const cacheContent = {
  projectName: projectInfo.projectName,
  techStack: projectInfo.techStack,
  domains: projectInfo.modules,
  initialized: true,
  initTime: new Date().toISOString(),
  lastUsed: new Date().toISOString(),
  version: "1.0"
};

await Write({
  file_path: ".cache/.project-info.json",
  content: JSON.stringify(cacheContent, null, 2)
});

console.log("✅ 生成缓存文件");
```

### 步骤7：完成初始化

**输出给用户：**
```markdown
如需调整配置，可以直接编辑 PROJECT_CONFIG.md 文件。

现在可以开始工作了！
```

---

## 失败处理

### 自动分析失败

**场景：** 无法识别项目结构或技术栈

**处理逻辑：**
```javascript
try {
  // 尝试自动分析
  const projectInfo = await autoAnalyzeProject();
} catch (error) {
  // 分析失败，提示用户手动配置
  console.log(`
⚠️ 自动分析失败

无法自动识别项目信息。请手动编辑 PROJECT_CONFIG.md 文件。

**配置模板：**
\`\`\`markdown
# 项目配置

## 项目信息
- 项目名称：[填写项目名称]
- 项目类型：[Web应用/移动应用/后端服务]
- 技术栈：[填写技术栈]

## 业务域
- [domain1]: [描述]
- [domain2]: [描述]
\`\`\`

配置完成后，我会继续工作。
  `);

  // 使用默认配置继续
  const defaultConfig = {
    projectName: "未命名项目",
    techStack: ["通用技术栈"],
    domains: ["default"]
  };

  return defaultConfig;
}
```

### 文件写入失败

**场景：** 无法写入配置文件或缓存文件

**处理逻辑：**
```javascript
// 重试机制
async function writeWithRetry(filePath, content, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await Write({ file_path: filePath, content: content });
      return true;
    } catch (error) {
      console.log(`⚠️ 写入失败，重试 ${i + 1}/${maxRetries}...`);
      await sleep(1000);  // 等待1秒
    }
  }

  // 重试失败，提示用户
  console.log(`
❌ 文件写入失败

无法写入文件：${filePath}

请检查：
1. 文件权限是否正确
2. 磁盘空间是否充足
3. 文件路径是否有效

是否跳过此文件继续？（30秒后自动跳过）
  `);

  // 等待30秒用户响应
  const userResponse = await waitForUserResponse(30000);

  if (userResponse === 'skip' || userResponse === null) {
    console.log("⚠️ 跳过文件写入，继续执行...");
    return false;
  }

  return false;
}
```

---

## 增量更新机制

### 概述

**目标：** 每次启动时，自动检测项目变更并增量更新配置，避免全量扫描

**优势：**
- Token节约：95%（使用 git diff 而不是全量扫描）
- 速度快：只分析变更文件
- 准确性高：基于真实变更

### 检测逻辑

**步骤1：检查上次扫描时间**
```javascript
// 读取缓存元数据
const cacheFile = ".cache/.project-info.json";
const projectInfo = await Read({ file_path: cacheFile });

// 获取上次扫描时间
const lastScanTime = projectInfo.lastUsed;
```

**步骤2：使用 git diff 检查变更**
```javascript
// 使用 git diff 获取变更文件列表
const gitDiff = await Bash({
  command: `git diff --name-only HEAD~10 HEAD`,
  description: "检查最近10次提交的变更文件"
});

// 解析变更文件列表
const changedFiles = gitDiff.split('\n').filter(f => f.trim());

console.log(`
## 🔄 检测项目变更

正在使用 git diff 检查项目变更...

**发现变更：**
${changedFiles.map(f => `- ${f}`).join('\n')}
`);
```

**步骤3：分析变更影响**
```javascript
// 分析变更文件，识别新增业务域
const newDomains = analyzeChangedFiles(changedFiles);

if (newDomains.length > 0) {
  console.log(`
**分析变更影响：**
- ✅ 新增业务域：${newDomains.join(', ')}
- ✅ 需要更新配置
  `);
}
```

**步骤4：增量更新配置**
```javascript
// 只更新变更部分，不重写整个文件
if (newDomains.length > 0) {
  // 读取现有配置
  const config = await Read({ file_path: "PROJECT_CONFIG.md" });

  // 增量添加新业务域
  const updatedConfig = addNewDomains(config, newDomains);

  // 写回配置文件
  await Write({
    file_path: "PROJECT_CONFIG.md",
    content: updatedConfig
  });

  console.log("✅ 配置已更新（仅更新变更部分，未重新扫描整个项目）");
  console.log("**Token节约：** 95%（使用 git diff 而不是全量扫描）");
}
```

### 增量更新规则

**1. 新增业务域**
```javascript
// 检测新增的业务模块目录
function detectNewDomains(changedFiles) {
  const newDomains = [];

  for (const file of changedFiles) {
    // Java DDD项目
    const javaMatch = file.match(/src\/main\/java\/.*?\/([^\/]+)\//);
    if (javaMatch && !existingDomains.includes(javaMatch[1])) {
      newDomains.push(javaMatch[1]);
    }

    // Vue项目
    const vueMatch = file.match(/src\/views\/([^\/]+)\//);
    if (vueMatch && !existingDomains.includes(vueMatch[1])) {
      newDomains.push(vueMatch[1]);
    }
  }

  return [...new Set(newDomains)];
}
```

**2. 新增API端点**
```javascript
// 检测新增的API端点
function detectNewApis(changedFiles) {
  const newApis = [];

  for (const file of changedFiles) {
    if (file.includes('Controller.java') || file.includes('api/')) {
      // 读取文件，分析API端点
      const content = await Read({ file_path: file });
      const apis = extractApiEndpoints(content);
      newApis.push(...apis);
    }
  }

  return newApis;
}
```

**3. 新增数据模型**
```javascript
// 检测新增的数据模型
function detectNewModels(changedFiles) {
  const newModels = [];

  for (const file of changedFiles) {
    if (file.includes('entity/') || file.includes('model/')) {
      // 读取文件，分析数据模型
      const content = await Read({ file_path: file });
      const models = extractDataModels(content);
      newModels.push(...models);
    }
  }

  return newModels;
}
```

### 更新缓存

**更新缓存元数据：**
```javascript
// 更新缓存文件
projectInfo.lastUsed = new Date().toISOString();
projectInfo.lastScanTime = new Date().toISOString();
projectInfo.domains = [...projectInfo.domains, ...newDomains];

await Write({
  file_path: ".cache/.project-info.json",
  content: JSON.stringify(projectInfo, null, 2)
});
```

---

## 高级选项

### 环境变量配置

**跳过初始化：**
```bash
export SCRUM_SKILLS_SKIP_INIT=true
```

**使用手动配置模式：**
```bash
export SCRUM_SKILLS_MANUAL_INIT=true
```

**强制重新初始化：**
```bash
export SCRUM_SKILLS_FORCE_INIT=true
```

### 配置文件优先级

1. 环境变量（最高优先级）
2. PROJECT_CONFIG.md（用户配置）
3. 缓存文件（自动生成）
4. 默认配置（最低优先级）

---

## 最佳实践

### 1. 首次使用
- ✅ 让系统自动分析项目
- ✅ 检查生成的配置是否准确
- ✅ 根据需要手动调整配置

### 2. 日常使用
- ✅ 依赖增量更新机制
- ✅ 定期检查配置准确性
- ✅ 发现问题及时更新配置

### 3. 大规模重构后
- ✅ 删除缓存文件，重新初始化
- ✅ 手动检查配置文件
- ✅ 更新业务域和架构信息

### 4. 多人协作
- ✅ 将 PROJECT_CONFIG.md 纳入版本控制
- ✅ 不要提交缓存文件到版本控制
- ✅ 团队成员共享配置

---

## 常见问题

### 问题1：自动分析不准确
**解决：** 手动编辑 PROJECT_CONFIG.md 文件

### 问题2：缓存文件损坏
**解决：** 删除缓存文件，重新初始化
```bash
rm -rf .cache/.project-info.json
```

### 问题3：增量更新遗漏变更
**解决：** 强制重新初始化
```bash
export SCRUM_SKILLS_FORCE_INIT=true
```

### 问题4：初始化时间过长
**解决：** 使用增量更新机制，避免全量扫描

---

## 总结

初始化流程确保：
1. ✅ **自动化** - 无需手动配置，自动分析项目
2. ✅ **准确性** - 基于真实代码结构识别
3. ✅ **高效性** - 增量更新，节约Token
4. ✅ **灵活性** - 支持手动调整和强制重新初始化
5. ✅ **容错性** - 失败时提供降级方案

让技能组快速适应任何项目，开箱即用！
