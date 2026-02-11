# Beta 候选包安装与验证（试用者人话版）

> 这页只讲最短路径：**下载包 → 校验 → 预检 → 安装**。

## 0) 你需要准备什么

- macOS / Linux 终端
- `tar` + `shasum`（或 `sha256sum`）
- 一份候选包（示例）：`dist/lan-0.1.0-macos-arm64.tar.gz`

---

## 1) 先做包校验（verify）

```bash
./scripts/verify-package.sh dist/lan-0.1.0-macos-arm64.tar.gz
```

期望输出（成功）：

```text
[verify-package] PASS reason=checksum-and-manifest-verified
```

若失败：按输出里的 `next:` 处理后再继续。

---

## 2) 再做环境预检（preflight）

文本模式：

```bash
./scripts/preflight.sh "$HOME/.local/bin"
```

JSON 模式（便于机器读取）：

```bash
./scripts/preflight.sh --json "$HOME/.local/bin"
```

期望输出（成功）：

```text
[preflight] PASS target=...
```

或

```json
{"ok":true,"reason":"ok","target":"...","next":"-"}
```

若失败：按 `next:` 提示修复（路径/权限/sha 工具等）。

---

## 3) 安装候选包（install）

```bash
./scripts/install.sh dist/lan-0.1.0-macos-arm64.tar.gz "$HOME/.local/bin"
```

期望输出（成功）：

```text
Install success: .../lan
```

失败时会给出：
- `Install failed: ...`
- `next: ...`

直接按 `next:` 操作即可。

---

## 4) 安装后快速确认

```bash
"$HOME/.local/bin/lan" --version
```

如果能打印版本号，说明候选包安装可用。

---

## 常见问题（最短回答）

1) **校验失败怎么办？**
- 先重新生成/下载包，再执行 `verify-package.sh`。

2) **预检失败怎么办？**
- 按 `next:` 修路径或权限；必要时换可写目录（如 `~/.local/bin`）。

3) **安装失败怎么办？**
- 不猜原因，直接用输出里的 `next:` 作为下一步。

---

## 口径说明

本页命令与输出口径对齐以下脚本：
- `scripts/verify-package.sh`
- `scripts/preflight.sh`
- `scripts/install.sh`
- 详细故障清单：`docs/ops/troubleshooting.md`
