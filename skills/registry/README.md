# Pack Registry

`skills/registry/` 是 V3 第二阶段的 Pack Registry。

它负责把“外部技能包迁移规范”落成真实机制，而不是只保留文档要求。

## 命令

- `pack-list.sh`
  - 列出当前仓库已声明的扩展包
- `pack-doctor.sh`
  - 检查扩展包是否具备 `.source.json`、`pack.json`、中文入口等最小元数据
- `pack-install.sh`
  - 将指定扩展包装到目标宿主目录
- `pack-update.sh`
  - 更新单个扩展包或全部扩展包
- `pack-selfcheck.sh`
  - 自检脚本，验证 `doctor / list / install / update`

## 示例

```bash
sh skills/registry/bin/pack-list.sh
sh skills/registry/bin/pack-doctor.sh
sh skills/registry/bin/pack-install.sh gstack --agent=codex
sh skills/registry/bin/pack-update.sh --all --target=/path/to/.claude
sh skills/registry/bin/pack-selfcheck.sh
```
