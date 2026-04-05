# Harness V2 Final Requirements And Self-Review

本文件整理本轮需求、实现结果与 5 轮自审记录。

## 1. 最终需求整理

结合本轮全部对话，最终需求收敛为以下 8 项：

1. `scrum-skills` 要从“技能包 + hooks”升级为可初始化任意项目的 Harness 平台。
2. 初始化后必须在目标仓库生成机器可读的事实源，而不只是文档建议。
3. 约束必须是强制性的，不能保留 `[skip-review]` 这类建议式旁路。
4. 要能以 `aff` 这类项目为例，对架构漂移进行自动检查，并在可修复时自动纠偏。
5. 要充分利用 Git，而不是只把 Git 当提交工具。
6. 要吸收 Harness Engineering / Ralph / Anthropic long-running harness / aider 的 Git 实践。
7. 要把仓库本身变成记录系统，补齐平台侧规则说明。
8. 最终产出要经过自审，并确认所有需求已经响应。

## 2. 响应矩阵

| 需求 | 响应方式 | 关键文件 |
|------|----------|----------|
| 任意项目 Harness 初始化 | `setup.sh --project-root=...` 生成 `.harness/`、`PROJECT_CONFIG.md`、`.cache/.project-info.json` | `skills/hooks/setup.sh` `skills/harness/bin/harness-init.sh` |
| 强制约束 | `core.hooksPath = .harness/git-hooks` + CI workflow + GitHub ruleset 清单 | `.harness/git-hooks/*` `.github/workflows/harness-gate.yml` `skills/config/github-ruleset-checklist.md` |
| 去掉建议式旁路 | 删除 `[skip-review]`，改为审计型 override | `skills/hooks/pre-bash.sh` `skills/hooks/commit-msg.sh` `.harness/overrides/README.md` |
| 自动检查并纠偏 | `harness-check` + `harness-fix` + `post-file-write` 回环 | `skills/harness/bin/harness-check.sh` `skills/harness/bin/harness-fix.sh` `skills/hooks/post-file-write.sh` |
| Git-first | worktree、checkpoint、versioned hooks、CI gate | `skills/harness/bin/harness-worktree.sh` `skills/harness/bin/harness-checkpoint.sh` `.harness/git-hooks/*` |
| 编排器接 Harness | `workflow-runner` 文档明确接入 check/fix/re-check | `skills/0-workflow-runner/SKILL.md` |
| 仓库即记录系统 | 新增项目级合同、GitHub 规则清单、最终需求文档 | `.harness/*` `skills/config/github-ruleset-checklist.md` `docs/harness-v2-final-requirements.md` |

## 3. 5 轮自审记录

### 第 1 轮：脚本语法与落盘检查

- 检查项：`sh -n skills/harness/bin/*.sh skills/hooks/*.sh`
- 发现：`harness-init.sh` 末尾的 `set -e` 与短路写法会导致初始化后错误退出
- 修正：改成显式 `if [ "$REFRESH" = "yes" ]; then exit 0; fi`
- 结果：初始化可正常完成

### 第 2 轮：项目初始化结果检查

- 检查项：`setup.sh --project-root=...` 后 `.harness/`、`PROJECT_CONFIG.md`、`core.hooksPath`
- 发现：项目级 Harness 已生成，但 baseline 仍为空
- 修正：把 baseline 生成逻辑从“手写扫描”改为“复用 `harness-check` 的输出”
- 结果：历史债务成功写入 `drift-baseline.json`

### 第 3 轮：Baseline JSON 与校验口径检查

- 检查项：`.harness/state/drift-baseline.json`
- 发现：JSON 存在顺序和逗号问题
- 修正：重排 `harness-init.sh` 生成顺序，并修正多对象拼接格式
- 结果：baseline JSON 合法，`harness-check --all` 可通过

### 第 4 轮：编排器与 Git-first 能力检查

- 检查项：`workflow-runner` 是否接入 Harness；Git 是否只停在 commit-msg 层
- 发现：编排器文档缺少 Harness 纠偏闭环；Git-first 还缺 worktree / checkpoint 明确入口
- 修正：补 `workflow-runner` Harness 回环说明；新增 `harness-worktree.sh`、`harness-checkpoint.sh`
- 结果：Git-first 能力不再停在口头方案

### 第 5 轮：文档、安装器、平台侧规则一致性检查

- 检查项：`README.md`、`AGENTS.md`、`install.ps1`、GitHub 侧门禁说明
- 发现：Windows 安装器与 shell 版的 Harness 说明不完全一致；平台侧强制门禁未显式落盘
- 修正：补 `install.ps1` 对齐说明，新增 `github-ruleset-checklist.md`
- 结果：仓库内记录与平台侧动作边界清晰

## 4. 当前结论

仓库内可完成的 Harness V2 工作已经完成，且已通过当前仓库的全量 Harness 校验。

剩余唯一仓库外动作：

1. 在 GitHub/Gitee 平台侧开启分支保护或等效规则
2. 将 `Harness Gate` 设为 required status check
3. 禁止 direct push / force push 到主分支

完成这一步后，系统才从“仓库内强制”升级为“平台级强制”。
