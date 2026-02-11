# Lan 错误码表

> 统一错误码规范，每个错误含描述、next-step、严重等级。
> 脚本和代码中使用 `reason=<error_id>` 引用。

## 错误码格式

`E<category><sequence>` — 例如 `E101`

- **E1xx** — 安装 (Install)
- **E2xx** — 升级 (Upgrade)
- **E3xx** — Provider / 路由
- **E4xx** — Skill

---

## E1xx — 安装

| Code | Severity | Description | Next Step |
|---|---|---|---|
| E101 | P0 | 安装目标路径不存在且无法创建 | 检查路径权限或选择其他安装目录 |
| E102 | P1 | 安装目标路径已存在同名文件（非目录） | 移除冲突文件或选择其他路径 |
| E103 | P1 | 解压 tarball 失败（文件损坏或格式错误） | 重新下载 release artifact 并重试 |
| E104 | P2 | 校验和不匹配（SHA256 验证失败） | 重新下载并用 `shasum -a 256` 确认完整性 |
| E105 | P2 | 安装后二进制不可执行 | 检查 `chmod +x` 权限或文件系统挂载选项 |

## E2xx — 升级

| Code | Severity | Description | Next Step |
|---|---|---|---|
| E201 | P1 | 升级回滚失败（备份文件丢失） | 手动从 release 重新安装 |
| E202 | P1 | 升级过程中新版本验证失败 | 检查新版本 artifact 完整性，必要时回滚 |
| E203 | P2 | 升级前 preflight 检查未通过 | 运行 `./scripts/preflight.sh` 查看具体失败项 |
| E204 | P2 | 版本降级被阻止 | 如需降级请使用 `--force` 参数或手动安装 |

## E3xx — Provider / 路由

| Code | Severity | Description | Next Step |
|---|---|---|---|
| E301 | P1 | Provider 端点不可达（网络超时） | 检查网络连接和 `LAN_PROVIDER_URL` 配置 |
| E302 | P1 | Provider 认证失败（401/403） | 检查 API key 是否正确设置 |
| E303 | P2 | Provider 返回非预期状态码 | 查看 provider 状态页或切换备用 provider |
| E304 | P2 | 路由 fallback 全部失败 | 检查所有配置的 provider 端点和 API key |
| E305 | P3 | Provider 响应延迟过高（>5s） | 考虑切换到更快的 provider 或检查网络 |

## E4xx — Skill

| Code | Severity | Description | Next Step |
|---|---|---|---|
| E401 | P1 | Skill manifest.json 解析失败 | 检查 JSON 语法（可用 `jq . manifest.json` 验证） |
| E402 | P1 | Skill manifest 缺少必填字段 | 确保包含 name/version/entry/tools/permissions |
| E403 | P2 | Skill entry 文件不存在 | 确认 manifest 中 entry 字段指向的文件存在 |
| E404 | P2 | Skill 版本号格式不符合 semver | 使用 `x.y.z` 格式（如 `0.1.0`） |
| E405 | P2 | Skill 名称冲突（已安装同名 skill） | 先运行 `lan skill remove <name>` 再重新安装 |

---

## 严重等级说明

| Level | 含义 | 影响 |
|---|---|---|
| P0 | 阻塞（无法继续） | 必须立即修复 |
| P1 | 高（功能不可用） | 应尽快修复 |
| P2 | 中（有 workaround） | 按优先级排期 |
| P3 | 低（体验问题） | 可延后处理 |
