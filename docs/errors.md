# Lan Error Codes

> 统一错误码规范，便于问题定位和用户自助排查。

## 错误码格式

`E<category><sequence>`

- **E1xx** — 配置 (Config)
- **E2xx** — 会话/历史 (History)
- **E3xx** — 安装/升级 (Install/Upgrade)
- **E4xx** — Skill 管理

---

## E1xx — 配置错误

| Code | Severity | Description | Next Step |
|------|----------|-------------|-----------|
| E101 | P1 | Config file not found | Run `lan config init` to create default config |
| E102 | P1 | Config file invalid JSON | Fix JSON syntax in `~/.config/lan/config.json` |
| E103 | P2 | Config reload failed (file not found) | Ensure config file exists at `~/.config/lan/config.json` |

---

## E2xx — 会话/历史错误

| Code | Severity | Description | Next Step |
|------|----------|-------------|-----------|
| E201 | P2 | Config reload failed | Ensure config file exists at `~/.config/lan/config.json` |
| E301 | P2 | History stats failed (no history) | Run a session first with `lan` |
| E302 | P2 | History search failed (no history) | Run a session first with `lan` |
| E303 | P2 | History export failed (no history) | Run a session first with `lan` |

---

## E3xx — 安装/升级错误

| Code | Severity | Description | Next Step |
|------|----------|-------------|-----------|
| E409 | P1 | Skill install failed: missing manifest.json | Provide a local folder containing manifest.json |
| E410 | P1 | Skill install failed: invalid manifest schema | Ensure name/version/entry/tools/permissions are valid |
| E411 | P1 | Skill update failed: missing manifest.json | Provide a local folder containing manifest.json |
| E412 | P1 | Skill update failed: invalid manifest schema | Ensure name/version/entry/tools/permissions are valid |
| E413 | P1 | Skill update failed: target not installed | Run `lan skill list` then `lan skill add <path>` first |

---

## E4xx — Skill 管理错误

| Code | Severity | Description | Next Step |
|------|----------|-------------|-----------|
| E401 | P2 | Skill install failed: missing path | Run `lan skill add <local-dir>` with a valid path |
| E402 | P2 | Skill update failed: missing path | Run `lan skill update <local-dir>` with a valid path |
| E403 | P2 | Skill info failed: missing name | Run `lan skill info <name>` with a skill name |
| E405 | P2 | Skill remove failed: missing name | Run `lan skill remove <name>` with a skill name |
| E406 | P2 | Skill remove failed: invalid name | Use a plain skill name (e.g. hello-world) |
| E407 | P2 | Skill remove failed: not found | Run `lan skill list` to check installed names |
| E408 | P1 | Skill remove failed: permission denied | Check directory permissions under `~/.config/lan/skills` |

---

## 严重等级说明

| Level | 含义 | 影响 |
|-------|------|------|
| P0 | 阻塞（无法继续） | 必须立即修复 |
| P1 | 高（功能不可用） | 应尽快修复 |
| P2 | 中（有 workaround） | 按优先级排期 |
| P3 | 低（体验问题） | 可延后处理 |

---

*Last updated: 2026-02-12*
