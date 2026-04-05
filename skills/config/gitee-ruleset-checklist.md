# Gitee Protection Checklist

本文件记录把仓库级 Harness 变成真正强制约束时，Gitee 侧至少需要人工确认的保护项。

## 必查项

1. 保护分支覆盖 `main`、`master`
2. 禁止 direct push
3. 禁止 force push
4. 禁止删除保护分支
5. 要求通过 Pull Request / Merge Request 合并
6. 要求至少 1 个审核人
7. 如平台版本支持，要求通过状态检查后才能合并
8. 限制 bypass 权限，仅仓库管理员可紧急放行

## 当前仓库侧事实

- 本地 Harness 门禁在 `.harness/git-hooks/*`
- 本地/CI 合同检查入口在 `.harness/bin/harness-check.sh`
- 平台侧审计入口可使用 `sh skills/harness/bin/harness-platform-audit.sh`
- 当前仓库已提交 GitHub Actions 工作流：`.github/workflows/harness-gate.yml`

## 需要人工确认的原因

Gitee 的分支保护、审核流和状态检查配置属于远端平台设置，不会自动存储在 Git 仓库里。

因此仓库内脚本最多只能：

- 检测远端是否存在 Gitee remote
- 提醒你去核对保护配置
- 落盘本地审计报告

它不能在离线、无 API 凭证的前提下证明平台规则已经真正开启。

## 上线检查

在 Gitee 上完成保护配置后，至少验证一次：

1. 新建分支并发起合并请求
2. 确认审核流真实生效
3. 尝试直接推送到 `main/master`，确认被平台拦截
4. 如使用平台状态检查，确认 Harness 相关检查已成为合并前条件
