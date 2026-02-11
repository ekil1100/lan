# Beta 准入清单（人话版）

> 目标：明确 **什么时候可以从 MVP 进入 Beta**，并且每一项都能拿命令和证据说话。
> 口径对齐 `docs/ROADMAP.md` 的里程碑：**MVP → Beta → 1.0**。

## A. 能力可用（用户能顺利用起来）

1) 安装/升级/预检/校验链路可闭环
- 验收命令：
  - `./scripts/test-install-platform-path.sh`
  - `./scripts/test-upgrade-local.sh`
  - `./scripts/test-preflight.sh`
  - `./scripts/verify-package.sh <artifact.tar.gz>`
- 证据路径：
  - `scripts/install.sh`
  - `scripts/upgrade.sh`
  - `scripts/preflight.sh`
  - `scripts/verify-package.sh`

2) 发布说明与诊断支持可生成
- 验收命令：
  - `./scripts/test-release-notes.sh`
  - `./scripts/test-support-bundle.sh`
- 证据路径：
  - `scripts/release-notes.sh`
  - `scripts/support-bundle.sh`
  - `dist/release-notes.md`（运行后产物）
  - `dist/lan-support-<platform>-<timestamp>.tar.gz`（运行后产物）

---

## B. 回归门禁（本地与 CI 一把尺子）

1) R9 第一批统一回归入口通过
- 验收命令：
  - `make r9-ops-readiness-regression`
- 证据路径：
  - `Makefile`（`r9-ops-readiness-regression`）
  - `scripts/test-r9-ops-readiness-suite.sh`

2) CI 复用同一命令（无双维护）
- 验收命令：
  - 查看 CI 配置：`rg "r9-ops-readiness-regression" .github/workflows/ci.yml`
- 证据路径：
  - `.github/workflows/ci.yml`

---

## C. 稳定性基线（最小可运维）

1) 关键构建与基础冒烟稳定
- 验收命令：
  - `zig build`
  - `zig build test`
  - `make smoke`
- 证据路径：
  - `scripts/smoke.sh`
  - CI 运行记录（Actions）

2) 失败路径可解释（都有 next-step）
- 验收命令：
  - `./scripts/test-preflight-json.sh`
  - `./scripts/test-upgrade-local.sh`
- 证据路径：
  - `docs/ops/troubleshooting.md`
  - `scripts/preflight.sh` / `scripts/upgrade.sh`

---

## D. 发布支持（出问题能定位）

0) 面向试用者的安装/验证说明可直接使用
- 验收命令：
  - `cat docs/release/beta-candidate-install-verify.md`
- 证据路径：
  - `docs/release/beta-candidate-install-verify.md`


1) 故障清单文档齐全且和脚本一致
- 验收命令：
  - `rg "next:" docs/ops/troubleshooting.md`
- 证据路径：
  - `docs/ops/troubleshooting.md`
  - `README.md`（Ops Troubleshooting 入口）

2) 支持包包含最小排障信息（版本/脱敏配置/日志）
- 验收命令：
  - `./scripts/test-support-bundle.sh`
- 证据路径：
  - `scripts/support-bundle.sh`
  - 支持包解压内容（`version.txt` / `config-summary.txt` / `recent.log`）

---

## Beta 准入结论模板（执行时填写）

- 能力可用：PASS / FAIL
- 回归门禁：PASS / FAIL
- 稳定性基线：PASS / FAIL
- 发布支持：PASS / FAIL

**总体结论：**
- 若四项均 PASS：可从 MVP 进入 Beta
- 任一 FAIL：维持 MVP，按失败项补齐后复核
