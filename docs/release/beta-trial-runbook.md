# Beta 试用 Runbook（最小版）

> 目标：让试用者按一条清晰路径完成 **安装 → 验证 → 反馈**。
> 口径对齐当前脚本输出（PASS/FAIL + next-step）。

---

## 0) 准备候选包

示例候选包路径：

```bash
dist/lan-0.1.0-macos-arm64.tar.gz
```

如果你还没有包，可先在研发环境打包：

```bash
./scripts/package-release.sh
```

期望输出（成功）：

```text
[package] PASS artifact=...
```

---

## 1) 安装（Install）

推荐直接走一键验证入口（会包含安装）：

```bash
./scripts/verify-beta-candidate.sh <artifact.tar.gz> "$HOME/.local/bin"
```

期望输出（成功）：

```text
[beta-candidate-verify] PASS package=... target=...
```

常见失败与 next-step：
- 失败：`[beta-candidate-verify] FAIL case=args ...`
  - next: 用正确参数重跑 `./scripts/verify-beta-candidate.sh <artifact.tar.gz> [target-dir]`
- 失败：内部 verify/preflight/install 任一步失败
  - next: 按该步输出里的 `next:` 修复后重跑

---

## 2) 验证（Verify）

### 2.1 一键验收（推荐）

```bash
./scripts/run-beta-acceptance.sh <artifact.tar.gz> "$HOME/.local/bin" dist/beta-acceptance-report.md
```

期望输出（成功）：

```text
[beta-acceptance] PASS package=... target=... report=...
```

### 2.2 健康检查（可选补充）

```bash
./scripts/post-install-health.sh "$HOME/.local/bin/lan"
```

期望输出（成功）：

```text
[post-install-health] PASS summary=all_checks_passed
```

常见失败与 next-step：
- 失败：`[beta-acceptance] FAIL case=<step> ...`
  - next: 先修复失败步骤（checklist/verify/post-health/report），再重跑同一命令
- 失败：`[post-install-health] FAIL case=binary ...`
  - next: 先安装或修复可执行权限（`chmod +x`）后重跑

---

## 3) 反馈（Feedback）

收集反馈请直接复制模板：

```bash
cat docs/release/beta-feedback-template.md
```

重点必填：
- 严重级别（P0/P1/P2/P3）
- 复现步骤（step-by-step）
- 环境信息（OS/架构/版本/包路径）
- 证据（命令输出、日志、快照路径）

---

## 4) 快速判定（可否继续试用）

- 满足以下条件可继续试用：
  1) `verify-beta-candidate` PASS
  2) `run-beta-acceptance` PASS
  3) 无 P0/P1 未缓解问题

- 若不满足：
  - 按失败输出 `next:` 修复；
  - 用反馈模板登记问题并指定 owner。
