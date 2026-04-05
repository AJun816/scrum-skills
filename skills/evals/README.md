# Eval System

`skills/evals/` 提供行为级 eval 入口，用来补齐“结构约束通过了，但任务是否真的达成目标”的验证层。

当前能力：

- `eval-list.sh`
  - 列出内置 eval case 与项目级 `.harness/evals/*.case.env`
- `eval-run.sh`
  - 支持单 case / 多 case / `--all`
  - 支持 `--trials=N`
  - 为每次 trial 存档 stdout、stderr、grader 输出和执行元数据
- `eval-compare.sh`
  - 对比两次 run 的 pass rate 与平均耗时
- `eval-report.sh`
  - 聚合最近一次 run 和最近一次 comparison，输出 eval 总览；没有历史时输出 `no_eval_activity`
- `eval-selfcheck.sh`
  - 自检脚本，验证 run / transcript / compare / report 的最小闭环

## Case 来源

优先级：

1. 项目级 `.harness/evals/*.case.env`
2. 仓库内置 `skills/evals/cases/*.case.env`

如果项目和内置定义了同名 case，项目级 case 会覆盖内置版本。
`--all` 在普通项目中只跑项目级 case；只有在 `scrum-skills` 包根目录下运行时，才会把内置 case 一起纳入。

## Case 格式

使用 shell env 文件，至少包含：

```sh
EVAL_NAME='my-case'
EVAL_DESCRIPTION='one-line description'
EVAL_COMMAND='sh ./scripts/run-check.sh'
EVAL_EXPECT_EXIT='0'
EVAL_EXPECT_STDOUT_CONTAINS='READY
PASS'
```

可选字段：

- `EVAL_CWD`
- `EVAL_EXPECT_STDERR_CONTAINS`
- `EVAL_EXPECT_STDOUT_REGEX`
- `EVAL_EXPECT_STDERR_REGEX`
- `EVAL_MIN_PASS_PERCENT`
- `EVAL_TAGS`

## 产物

默认写入：

- `.cache/shared/evals/runs/<run-id>/summary.json`
- `.cache/shared/evals/runs/<run-id>/summary.tsv`
- `.cache/shared/evals/runs/<run-id>/<case>/trial-XX/stdout.txt`
- `.cache/shared/evals/runs/<run-id>/<case>/trial-XX/stderr.txt`
- `.cache/shared/evals/runs/<run-id>/<case>/trial-XX/grade.json`

比较结果写入：

- `.cache/shared/evals/comparisons/<compare-id>/comparison.json`

## 示例

```bash
sh skills/evals/bin/eval-list.sh
sh skills/evals/bin/eval-run.sh skills-help --trials=3
sh skills/evals/bin/eval-run.sh --all --project-root=.
sh skills/evals/bin/eval-compare.sh --current=eval-20260405010101-1234 --baseline=eval-20260404010101-5678
sh skills/evals/bin/eval-report.sh --project-root=. --json
sh skills/evals/bin/eval-selfcheck.sh
```
