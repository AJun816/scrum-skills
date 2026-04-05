# Harness Overrides

不再允许 `[skip-review]`。

如需临时豁免，必须：

1. 在本目录创建 `ADR-xxx.yaml`
2. 提供 `reason`、`scope`、`owner`、`expires_at`、`approved_by`
3. 在 commit message 中写入 `[imperial-override:ADR-xxx]`
