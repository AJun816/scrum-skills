# Harness Playbook

本文件把 Harness Engineering 在 Scrum Skills 中落成可执行约束。

## 1. 基线目标

Scrum Skills 的目标不是“多写提示词”，而是提供一套可安装、可初始化、可迁移、可持续维护的技能组 Harness：

1. 仓库即事实源：规则、安装行为、迁移边界都写进仓库。
2. 地图优先：`AGENTS.md` 负责导航，细节下沉到 `skills/config/`。
3. 机械化优先：能靠脚本和 hook 限制的，不只靠文档提醒。
4. 核心零额外环境：主技能组安装与初始化不依赖 Python、bun、Playwright。
5. 扩展隔离：外部技能包的附加依赖必须明确隔离，不能污染核心体验。
6. Git-first Harness：项目级规则必须落到 `.harness/`，并由 `core.hooksPath = .harness/git-hooks` 强制执行。

## 2. 标准执行序列

任何中大型任务必须按这个顺序推进：

1. Understand：读取目标技能、安装脚本、约束文件，确认当前真实行为。
2. Plan：列出最小变更方案，说明风险、回滚点和验收方式。
3. Implement：优先改脚本和事实源，避免只改 README。
4. Verify：至少验证一个真实安装/初始化路径。
5. Persist：更新 README、目录说明、迁移规范或中文目录。

## 3. 三层上下文

- Tier 1：`AGENTS.md`、`README.md`、`skills/config/mandatory-rules.md`
- Tier 2：`skills/README.md`、`skills/config/workflow-guide.md`、`skills/config/init-guide.md`
- Tier 3：具体 `SKILL.md`、外部技能目录说明、`.cache/shared/repo-map.md`、`.cache/shared/repo-index.json`

规则：先 Tier 1，再 Tier 2，最后按需下潜到 Tier 3。

## 4. 安装与初始化门禁

满足以下条件才算“初始化设计完整”：

1. `sh install.sh` 是主路径，Windows 也有可执行入口。
2. `install.sh` 与 `install.ps1` 对目标目录行为一致。
3. `skills/hooks/setup.sh` 在 repo / embedded / codex / custom target 场景下都能正确识别布局。
4. 只有 `~/.claude` 会声明 Claude hooks 已自动接入；其他目标不能伪装成 Claude。
5. 项目初始化后必须生成 `.harness/`、`PROJECT_CONFIG.md`、`.cache/.project-info.json`。
6. 项目初始化后必须生成 `.cache/shared/repo-map.md` 与 `.cache/shared/repo-index.json`。
7. 初始化失败时不删除用户仓库文件，不做破坏性清理。
8. 若需并行或长任务执行，应优先使用 `git worktree` 做任务隔离。

## 5. 外部技能包接入门禁

接入外部技能包时必须满足：

1. 保留来源信息：`.source.json` 必填。
2. 保留上游运行时：不随意破坏原有目录和 setup 流程。
3. 中文入口可见：用户必须能快速看到命令名、作用、适用场景、额外依赖。
4. 依赖边界清晰：可选扩展依赖必须写明“不影响核心技能组”。
5. 自动编排边界清晰：未适配的扩展包不得默认接入 `0-workflow-runner`。

## 6. 常见失败模式

- 失败模式：README 说支持，脚本实际上不支持
  - 防护：先改脚本，再改文档，再跑验证
- 失败模式：把扩展包依赖混进核心安装
  - 防护：核心安装只复制技能和必要脚本，扩展依赖显式标注为可选
- 失败模式：迁移技能描述只有英文，用户不知道怎么用
  - 防护：提供中文目录或中文前言，至少覆盖高频命令
- 失败模式：`setup.sh` 误判布局，把已安装目录当成仓库根目录
  - 防护：使用仓库标记判断 repo mode，不依赖单一目录名
- 失败模式：规则只存在于 README，Git 提交与推送仍可绕过
  - 防护：使用 `.harness/git-hooks` + `core.hooksPath` + CI required checks 做三层门禁
- 失败模式：多个 AI 任务在同一工作区互相覆盖
  - 防护：使用 `harness-worktree.sh` 为任务创建独立 worktree

## 7. 合入前检查

满足以下条件才允许合入：

1. 安装路径可复现。
2. 脚本幂等，不做破坏性清理。
3. README 与脚本行为一致。
4. `.harness/bin/harness-check.sh --all` 可运行。
5. 外部技能包中文目录和依赖说明已补齐。
6. 核心技能组不要求额外安装 Python。
7. runtime / registry / harness 文档必须与当前脚本入口一致，不保留“阶段计划”冒充现状。
