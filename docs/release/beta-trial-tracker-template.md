# Beta 试用登记表模板（批次 / 设备 / 状态）

> 用途：按“设备维度”记录每轮 Beta 试用执行状态。
> 字段口径与 `docs/release/beta-feedback-template.md` 保持一致（severity/环境/状态）。

---

## 1) 填报说明（人话版）

- 一台设备一行，方便汇总通过率。
- 有问题就填 `Issue Severity` + `Issue Link/Note`。
- `Status` 统一用：`Not Started / Running / Pass / Fail / Blocked`。

---

## 2) 登记表（可直接复制）

```markdown
| Batch | Device ID | Owner | OS/Version | Arch | Lan Version | Package | Install Path | Status | Issue Severity | Issue Link/Note | Last Update |
|---|---|---|---|---|---|---|---|---|---|---|---|
| B1 | MBP14-M3-01 | like | macOS 15.0 | arm64 | lan version=0.1.0 | lan-0.1.0-macos-arm64.tar.gz | ~/.local/bin | Pass | - | - | 2026-02-12 02:20 |
| B1 | MINI-01 | like | macOS 14.6 | arm64 | lan version=0.1.0 | lan-0.1.0-macos-arm64.tar.gz | ~/.local/bin | Fail | P1 | #issue-123 | 2026-02-12 02:25 |
```

---

## 3) 字段定义（与反馈模板一致）

- `Issue Severity`：`P0 / P1 / P2 / P3 / -`
- `OS/Version + Arch + Lan Version + Package + Install Path`：对应反馈模板里的环境信息
- `Issue Link/Note`：可填 issue 链接或复现要点
- `Status`：
  - `Not Started`：未开始
  - `Running`：进行中
  - `Pass`：本轮通过
  - `Fail`：本轮失败
  - `Blocked`：被外部条件阻塞

---

## 4) 快速同步建议

1. 先更新 `Status`，再补 issue。
2. `Fail/Blocked` 必填 `Issue Severity` 与 `Issue Link/Note`。
3. 每次更新都改 `Last Update`，保证可追踪。
