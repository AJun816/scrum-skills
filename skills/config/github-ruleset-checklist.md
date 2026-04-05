# GitHub Ruleset Checklist

本文件记录把仓库级 Harness 变成真正强制约束时，GitHub 侧需要开启的配置。

## 必开项

1. Protected branch / Ruleset 覆盖 `main`、`master`
2. 禁止 direct push
3. 禁止 force push
4. 禁止删除保护分支
5. 要求 Pull Request 合并
6. 要求 `Harness Gate` workflow 为 required status check
7. 要求至少 1 个 Review
8. 如有 CODEOWNERS，则要求 Code Owner Review
9. 开启 secret scanning push protection

## 建议项

1. 开启 merge queue
2. 开启 required signed commits
3. 开启 linear history
4. 要求最新一次 push 后重新 review
5. 限制 bypass 权限，仅仓库管理员可紧急放行

## 与仓库文件的对应关系

- `.github/workflows/harness-gate.yml`
  - CI 门禁入口
- `.harness/git-hooks/*`
  - 本地 Git 门禁
- `.harness/overrides/`
  - 审计型 override 记录
- `AGENTS.md`
  - 地图式入口
- `skills/config/harness-playbook.md`
  - Harness 设计基线

## 上线检查

在 GitHub 上完成上述配置后，至少验证一次：

1. 新建分支提交一个正常 PR
2. 确认 `Harness Gate` 自动运行
3. 尝试直接推送到 `main/master`，确认被平台拦截
4. 尝试提交违反规则的改动，确认本地 hook 和 CI 至少有一层拦截
