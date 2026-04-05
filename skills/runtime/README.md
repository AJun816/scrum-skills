# Workflow Runtime

`skills/runtime/` 是 `Scrum Skills` V3 第一阶段引入的真实 workflow runtime 骨架。

它不替代 Claude / Codex 的会话能力，只负责把三省六部 / 敏捷流程的状态落盘，并提供 shell 入口。

## 目录

- `bin/workflow.sh`
  - 主入口，支持 `start / status / resume / approve / reject / abort / reset`
- `bin/workflow-*.sh`
  - 主入口的快捷包装命令
- `bin/workflow-selfcheck.sh`
  - 自检脚本，验证 imperial / agile / reject / force-pass / reset / abort
- `lib/runtime-common.sh`
  - 路径、状态文件、步骤规格、事件落盘等公共函数
- `schemas/workflow-state.schema.json`
  - `workflow-state.json` 的结构说明

## 运行时文件

默认写入当前项目的：

- `.cache/shared/workflow-state.json`
- `.cache/shared/workflow-runs.jsonl`
- `.cache/shared/workflow-runtime/`

## 示例

```bash
sh skills/runtime/bin/workflow.sh start --mode=imperial --request="实现工作流运行时"
sh skills/runtime/bin/workflow.sh status
sh skills/runtime/bin/workflow.sh approve --message="太子分拣完成"
sh skills/runtime/bin/workflow.sh reject --reason="需要补充规划"
sh skills/runtime/bin/workflow.sh resume --message="恢复到规划步骤"
sh skills/runtime/bin/workflow.sh abort --message="终止当前流程"
sh skills/runtime/bin/workflow.sh reset
```

## 自检

```bash
sh skills/runtime/bin/workflow-selfcheck.sh
```

预期输出：

```text
SELF-CHECK OK
```
