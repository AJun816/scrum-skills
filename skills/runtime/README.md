# Workflow Runtime

`skills/runtime/` 是 `Scrum Skills` 当前已落地的 workflow runtime。

它不替代 Claude / Codex 的会话能力，只负责把三省六部 / 敏捷流程的状态落盘，并提供 shell 入口与 Harness 门禁回环。

## 目录

- `bin/workflow.sh`
  - 主入口，支持 `start / status / resume / approve / reject / abort / reset`
- `bin/workflow-*.sh`
  - 主入口的快捷包装命令，例如 `workflow-approve.sh`、`workflow-status.sh`
- `bin/workflow-selfcheck.sh`
  - 自检脚本，验证 imperial / agile / reject / force-pass / reset / abort / 缺失 Harness 时暂停
- `lib/runtime-common.sh`
  - 路径、状态文件、步骤规格、Harness 回环、事件落盘等公共函数
- `schemas/workflow-state.schema.json`
  - `workflow-state.json` 的结构说明

## 运行时文件

默认写入当前项目的：

- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`
- `.cache/shared/workflow-runtime/`

如果项目已完成 `setup.sh --project-root=...` 初始化，运行时状态还会引用：

- `PROJECT_CONFIG.md`
- `.cache/shared/repo-map.md`
- `.cache/shared/repo-index.json`
- `.harness/project-profile.json`
- `.harness/state/last-report.json`

在 `imperial:shangshu-dispatch` 和 `agile:scrum-execute` 这类执行步骤上，`approve` 会自动触发：

1. `sh .harness/bin/harness-check.sh --changed-files --json`
2. 必要时 `sh .harness/bin/harness-fix.sh --changed-files`
3. 再次检查；失败则把 workflow 置为 `paused`

## 示例

```bash
sh skills/runtime/bin/workflow.sh start --mode=imperial --request="实现工作流运行时"
sh skills/runtime/bin/workflow.sh status
sh skills/runtime/bin/workflow.sh approve --message="太子分拣完成"
sh skills/runtime/bin/workflow.sh reject --reason="需要补充规划"
sh skills/runtime/bin/workflow.sh resume --message="恢复到规划步骤"
sh skills/runtime/bin/workflow.sh abort --message="终止当前流程"
sh skills/runtime/bin/workflow.sh reset
sh skills/runtime/bin/workflow-status.sh --json
sh skills/runtime/bin/workflow-approve.sh --message="执行步骤通过"
```

## 自检

```bash
sh skills/runtime/bin/workflow-selfcheck.sh
```

预期输出：

```text
SELF-CHECK OK
```
