# AGENTS.md

Scrum Skills 仓库的 Harness 入口文件。这里是地图，不是大而全手册。

## 快速导航

- 安装入口与 Agent 差异：`README.md`
- 技能目录说明：`skills/README.md`
- Harness 基线：`skills/config/harness-playbook.md`
- GitHub 门禁清单：`skills/config/github-ruleset-checklist.md`
- 最终需求与自审：`docs/harness-v2-final-requirements.md`
- V3 架构设计：`docs/architecture-v3.md`
- 强制规则：`skills/config/mandatory-rules.md`
- 工作流约束：`skills/config/workflow-guide.md`
- 外部技能迁移规范：`skills/config/extension-pack-guidelines.md`
- gstack 中文命令目录：`skills/gstack/COMMANDS.zh-CN.md`
- 安装与初始化脚本：`install.sh`、`install.ps1`、`skills/hooks/setup.sh`
- 项目级 Harness 内核：`skills/harness/bin/`
- Pack Registry：`skills/registry/`
- Workflow Runtime：`skills/runtime/`

## 1. 执行契约

所有非平凡修改都必须按这个顺序推进：

1. Understand：先读相关文件，确认范围、安装行为和约束。
2. Plan：大改前写出短计划，明确风险与验收点。
3. Implement：做小步、可回退、职责清晰的改动。
4. Verify：运行脚本或最小化验证，确认行为真实成立。
5. Persist：如果行为变了，同步更新文档、规则或目录说明。

不要从用户请求直接跳到一大段一次性重写。

## 2. 上下文纪律

- 优先读根文档，再读 `skills/config/`，最后读具体技能。
- 保持上下文紧凑，不要一次性加载无关技能包。
- 外部迁移包优先看目录说明和来源文件，不直接假设其运行方式。
- 对话过长时先总结，再继续执行。

## 3. 安装现实

- 主安装路径必须始终是 `sh install.sh`。
- `~/.claude` 目标会额外部署 `settings.json`，自动接入 hooks。
- `~/.codex` 与其他自定义目标默认只部署技能组，不伪装成 Claude 配置目录。
- `skills/hooks/setup.sh` 必须同时兼容：
  - 仓库调试模式：`repo/skills/hooks/setup.sh`
  - 已安装模式：`~/.claude/skills/hooks/setup.sh`
  - Codex / 自定义目标：`<target>/skills/hooks/setup.sh`
- 对具体项目做 Harness 初始化时，事实源必须写入该项目的 `.harness/`，并通过 `core.hooksPath = .harness/git-hooks` 接入 Git 门禁。

任何文档都不能宣称“自动配置成功”，除非脚本真实做到了。

## 4. 持久化约束

优先把规则落到仓库，而不是留在会话里：

- `README.md`：安装行为、Agent 差异、用户入口
- `skills/config/harness-playbook.md`：Harness 执行顺序与门禁
- `skills/config/extension-pack-guidelines.md`：外部技能包接入规则
- `skills/hooks/*.sh`：机械化 Backpressure
- `skills/harness/bin/*.sh`：项目级 Harness 初始化、检查、修复、门禁
- `skills/gstack/COMMANDS.zh-CN.md`：迁移技能中文调用目录

如果安装、初始化、迁移设计有变化，至少更新其中一个事实源。

## 5. 外部技能包规则

- 保留上游目录结构与运行时，不随意“魔改”核心执行逻辑。
- 必须补 `.source.json`，记录来源、版本和同步时间。
- 必须补 `pack.json`，记录宿主兼容、依赖边界、工作流接入和安全声明。
- 必须提供中文入口说明，至少让用户知道“这个技能做什么、何时用、是否有额外依赖”。
- 可选依赖必须隔离。核心技能组不能因为扩展包而强制要求 Python、bun 或 Playwright。
- 不自动接入 `0-workflow-runner` 的扩展包，要在文档里明确说明“独立调用”。

## 6. 完成标准

只有同时满足以下条件，改动才算完成：

1. `sh install.sh` 仍然是最短可复现路径。
2. `install.sh`、`install.ps1`、`skills/hooks/setup.sh` 的行为与 README 一致。
3. `setup.sh` 在 repo / embedded / codex 场景下都不会误判目录结构。
4. `setup.sh --project-root=...` 能真实生成 `.harness/`、`PROJECT_CONFIG.md` 和 `.cache/.project-info.json`。
5. Git 门禁走 `core.hooksPath = .harness/git-hooks`，不再依赖 `[skip-review]` 之类的建议式旁路。
6. 用户不安装 Python 也能完成核心技能组初始化。
7. 迁移进来的技能包有中文入口说明和清晰依赖边界。
