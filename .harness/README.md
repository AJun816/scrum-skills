# Harness Directory

本目录是项目级 Harness 合同与 Git 门禁的事实源。

## 目录说明

- `project-profile.json`：项目画像
- `architecture/`：架构合同与依赖方向
- `rules/`：后端、前端、测试规则
- `git-hooks/`：版本化 Git hooks
- `bin/`：仓库内可执行 harness 脚本
- `state/`：漂移基线与最近检查结果
- `overrides/`：审计型豁免，不再允许 `[skip-review]`
- `.worktrees/`：按任务隔离的 Git worktree 工作区（运行时目录，不提交）
- `.cache/shared/repo-map.md`：人类可读仓库地图
- `.cache/shared/repo-index.json`：结构化仓库索引
- `.harness/state/harness-runs.jsonl`：Harness 检查/修复事件日志
- `.cache/shared/harness-report.json`：Harness 可观测性报表
- `.cache/shared/platform-audit.json`：平台侧门禁审计报告

## 使用方式

- 初始化：`sh .harness/bin/harness-init.sh --project-root=.`
- 增量检查：`sh .harness/bin/harness-check.sh --changed-files`
- 新任务隔离：`sh .harness/bin/harness-worktree.sh create TASK-ID`
- 检查点提交：`sh .harness/bin/harness-checkpoint.sh "checkpoint note"`
- Harness 报表：`sh .harness/bin/harness-report.sh --project-root=.`
- 刷新 repo-map：`sh .harness/bin/harness-repo-map.sh --project-root=.`
- 刷新 repo-index：`sh .harness/bin/harness-repo-index.sh --project-root=.`
- 平台侧审计：`sh .harness/bin/harness-platform-audit.sh --project-root=.`
- 提交前检查：由 `.harness/git-hooks/pre-commit` 自动触发
- 推送前检查：由 `.harness/git-hooks/pre-push` 自动触发
