---
name: 5-webapp-testing
description: 【5】使用Playwright与本地Web应用程序交互和测试的工具包。支持验证前端功能、调试UI行为、捕获浏览器截图和查看浏览器日志。
license: Complete terms in LICENSE.txt
---

# Web应用测试

> 🎯 **正在使用：Web应用测试技能** - 负责使用Playwright进行前端功能测试、UI行为验证、自动化测试

## 执行标准

**所有任务执行前，必须遵循以下标准：**

1. **读取项目配置**：读取 `PROJECT_CONFIG.md` 获取项目信息、技术栈、业务域等
2. **实时显示进度**：所有操作实时显示，让用户了解执行过程
3. **使用中文输出**：所有提示、说明、错误信息使用中文
4. **数据验证原则**：绝不瞎回答，所有回答必须基于真实数据验证

**详细执行标准参考：** `skills/.skill-execution-standard.md`

**数据验证标准参考：** `skills/.data-verification-standard.md`

### 测试工程师特殊要求

**验证测试的完整性：**
- 读取被测代码，分析测试覆盖
- 验证测试用例的准确性
- 所有测试建议必须基于真实的代码分析
- 明确标注测试依据（文件路径、行号）

**回答前必须验证：**
1. 读取被测代码文件（前端组件、后端API等）
2. 分析现有测试覆盖情况
3. 设计测试用例，基于真实的业务规则
4. 明确标注数据来源（文件路径、行号）
5. 如有不确定，明确说明并寻求澄清

## 概述

要测试本地Web应用程序，编写原生Python Playwright脚本。

**可用的辅助脚本**：
- `scripts/with_server.py` - 管理服务器生命周期（支持多个服务器）

**始终先使用 `--help` 运行脚本**以查看用法。在尝试运行脚本并发现绝对需要自定义解决方案之前，不要阅读源代码。这些脚本可能非常大，会污染您的上下文窗口。它们的存在是为了作为黑盒脚本直接调用，而不是被摄入到您的上下文窗口中。

## 决策树：选择您的方法

```
用户任务 → 是静态HTML吗？
    ├─ 是 → 直接读取HTML文件以识别选择器
    │         ├─ 成功 → 使用选择器编写Playwright脚本
    │         └─ 失败/不完整 → 视为动态（见下文）
    │
    └─ 否（动态Web应用）→ 服务器已经在运行吗？
        ├─ 否 → 运行：python scripts/with_server.py --help
        │        然后使用辅助脚本 + 编写简化的Playwright脚本
        │
        └─ 是 → 侦察-然后-行动：
            1. 导航并等待networkidle
            2. 截图或检查DOM
            3. 从渲染状态识别选择器
            4. 使用发现的选择器执行操作
```

## 示例：使用 with_server.py

要启动服务器，先运行 `--help`，然后使用辅助脚本：

**单个服务器：**
```bash
python scripts/with_server.py --server "npm run dev" --port 5173 -- python your_automation.py
```

**多个服务器（例如，后端 + 前端）：**
```bash
python scripts/with_server.py \
  --server "cd backend && python server.py" --port 3000 \
  --server "cd frontend && npm run dev" --port 5173 \
  -- python your_automation.py
```

要创建自动化脚本，只包含Playwright逻辑（服务器自动管理）：
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True) # 始终以无头模式启动chromium
    page = browser.new_page()
    page.goto('http://localhost:5173') # 服务器已经运行并准备就绪
    page.wait_for_load_state('networkidle') # 关键：等待JS执行
    # ... 您的自动化逻辑
    browser.close()
```

## 侦察-然后-行动模式

1. **检查渲染的DOM**：
   ```python
   page.screenshot(path='/tmp/inspect.png', full_page=True)
   content = page.content()
   page.locator('button').all()
   ```

2. **从检查结果中识别选择器**

3. **使用发现的选择器执行操作**

## 常见陷阱

❌ **不要**在动态应用上等待 `networkidle` 之前检查DOM
✅ **要**在检查之前等待 `page.wait_for_load_state('networkidle')`

## 最佳实践

- **将捆绑脚本用作黑盒** - 要完成任务，考虑 `scripts/` 中可用的脚本是否可以帮助。这些脚本可靠地处理常见的复杂工作流，而不会使上下文窗口混乱。使用 `--help` 查看用法，然后直接调用。
- 对同步脚本使用 `sync_playwright()`
- 完成后始终关闭浏览器
- 使用描述性选择器：`text=`、`role=`、CSS选择器或ID
- 添加适当的等待：`page.wait_for_selector()` 或 `page.wait_for_timeout()`

## 自动环境准备

### 测试工具自动安装

**首次使用检查：**
- 自动检测系统是否安装Playwright和Chrome浏览器
- 如未安装，自动执行安装命令：
  ```bash
  pip install playwright
  playwright install chromium
  ```
- 确保测试环境完整可用
- 验证安装成功后再执行测试任务

## 真实数据测试要求

**测试完成标准：**
- 所有开发任务完成后，必须使用真实数据进行测试
- 测试场景必须覆盖实际业务流程
- 只有测试成功后才能报告任务完成
- 测试失败时，主动通知相关开发人员修复
- 禁止使用模拟数据或跳过测试环节

**测试数据要求：**
- 使用生产环境的真实数据结构
- 覆盖正常场景和边界场景
- 包含异常情况的测试用例
- 验证数据完整性和一致性

## 团队主动协作

### 主动介入时机

**测试工程师主动介入的时机：**
- 当`4-vue-frontend-dev`或`4-java-backend-dev`完成功能开发时，主动介入测试
- 当`6-bug-handler`报告bug修复完成时，主动介入验证
- 当`5-devops-engineer`完成部署时，主动介入生产验证
- 当`2-product-manager`发布新需求时，主动参与测试计划制定
- 当`3-system-architect`设计新架构时，主动评估测试策略

### 主动寻求帮助

**遇到问题时主动协作：**
- 测试环境问题时，主动联系`5-devops-engineer`
- 测试数据准备时，主动联系`4-java-backend-dev`
- 业务逻辑不清楚时，主动联系`1-business-expert`
- UI/UX问题时，主动联系`4-frontend-design`
- 测试策略不确定时，主动联系`3-system-architect`

### 主动提供帮助

**测试工程师主动支持团队：**
- 主动为开发人员提供测试环境和测试数据
- 主动分享测试脚本和自动化工具
- 主动报告发现的潜在问题和改进建议
- 主动协助复现和定位bug
- 主动参与代码审查，从测试角度提供反馈

## 并行执行支持

本技能支持多实例并行工作，多个测试工程师可以同时测试不同功能，最大化测试效率。

### 并行测试模式

**多实例协作：**
- 支持2-3个测试实例同时工作
- 每个实例独立测试不同的功能模块
- 通过测试用例隔离避免冲突

**典型场景：**
```
测试A: 测试活动管理功能（创建、编辑、删除）
测试B: 测试数据追踪功能（日志查询、统计分析）
测试C: 测试智能投放功能（广告创建、状态管理）
```

### 任务隔离策略

**按功能模块隔离：**
- 不同实例测试不同的功能模块
- 每个模块独立的测试脚本
- 避免测试数据冲突

**按测试类型隔离：**
- 实例A: 功能测试（UI交互、业务流程）
- 实例B: 性能测试（加载速度、响应时间）
- 实例C: 兼容性测试（浏览器、设备）

**按优先级隔离：**
- P0紧急bug验证
- P1核心功能测试
- P2边界场景测试

### 测试环境管理

**独立测试环境：**
- 每个实例使用独立的测试数据
- 避免测试数据相互污染
- 测试完成后清理测试数据

**浏览器实例隔离：**
- 每个实例使用独立的浏览器实例
- 避免session和cookie冲突
- 并行执行提升测试速度

### 协作机制

**测试结果共享：**
- 所有实例共享测试结果
- 实时更新测试进度
- 发现bug立即通知团队

**测试脚本复用：**
- 通用测试脚本统一维护
- 避免重复编写相同的测试
- 测试工具和方法共享

## 参考文件

- **examples/** - 显示常见模式的示例：
  - `element_discovery.py` - 发现页面上的按钮、链接和输入
  - `static_html_automation.py` - 对本地HTML使用 file:// URL
  - `console_logging.py` - 在自动化期间捕获控制台日志

## 缓存机制（Token优化）

### 工作原理

本技能使用智能缓存机制，大幅节约token消耗（节约率70-80%）：

**首次使用：**
- 分析测试脚本和页面结构
- 提取常用选择器和测试模式
- 生成缓存并保存到 `skills/.cache/5-webapp-testing/`

**后续使用：**
- 优先加载缓存文件（快速、省token）
- 使用git diff识别变更
- 只读取变更的测试文件
- 增量更新缓存

### 缓存文件

缓存保存在 `skills/.cache/5-webapp-testing/`：

- `test-patterns.md` - 测试模式库
- `selectors-library.md` - 选择器库
- `automation-scripts.md` - 自动化脚本清单
- `test-results.md` - 测试结果历史
- `_cache-meta.json` - 缓存元数据（版本、更新时间）

### 手动刷新

如需重新生成缓存（例如测试框架大规模更新后）：
```bash
rm -rf skills/.cache/5-webapp-testing/
```

下次使用时会自动重新生成缓存。