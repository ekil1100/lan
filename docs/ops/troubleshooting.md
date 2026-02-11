# 运维故障排查清单（install / upgrade / verify / preflight）

> 口径与脚本输出保持一致，优先按 `next:` 执行。

## 1) preflight（`./scripts/preflight.sh`）

- `[preflight] FAIL reason=shell_missing`
  - next: `set SHELL environment variable and retry`
- `[preflight] FAIL reason=target_not_directory`
  - next: `choose a directory path, e.g. ~/.local/bin`
- `[preflight] FAIL reason=target_create_failed`
  - next: `use a writable install path or fix permissions`
- `[preflight] FAIL reason=target_not_writable`
  - next: `grant write permission or use another path`
- `[preflight] FAIL reason=sha_tool_missing`
  - next: `install shasum/sha256sum and retry`

## 2) install（`./scripts/install.sh`）

- `Install failed: missing package path`
  - next: `run ./scripts/install.sh <local-tarball> [target-dir]`
- `Install failed: package not found (...)`
  - next: `run ./scripts/package-release.sh then retry with the generated tarball path`
- `Install failed: invalid tarball`
  - next: `regenerate package via ./scripts/package-release.sh and retry`
- `Install failed: binary lan not found in package`
  - next: `ensure package includes lan binary and retry`
- `Install failed: target path is a file (...)`
  - next: `choose a directory path, e.g. ~/.local/bin`
- `Install failed: cannot create target directory (...)`
  - next: `check path permissions or use a writable directory`
- `Install failed: target directory not writable (...)`
  - next: `grant write permission or use another install path`
- `Install failed: conflict at <target>/lan (is directory)`
  - next: `remove/rename that directory then retry install`
- `Install failed: preflight_failed`
  - next: `fix preflight issues then retry install`

## 3) upgrade（`./scripts/upgrade.sh`）

- `Upgrade failed: missing package path`
  - next: `run ./scripts/upgrade.sh <local-tarball> [bin-dir] [config-dir]`
- `Upgrade failed: package not found (...)`
  - next: `run ./scripts/package-release.sh then retry with generated artifact`
- `Upgrade failed: invalid tarball`
  - next: `regenerate package via ./scripts/package-release.sh and retry`
- `Upgrade failed: binary lan not found in package`
  - next: `ensure package includes lan binary and retry`
- `Upgrade rollback: restored previous binary`
  - next: `check disk permissions and retry upgrade`
- `Upgrade rollback: no previous binary to restore`
  - next: `run install script to recover binary` / `run install script with a valid package`
- `Upgrade failed: binary is not executable`
  - next: `run chmod +x on the binary or rerun upgrade`
- `Upgrade failed: preflight_failed`
  - next: `fix preflight issues then retry upgrade`

## 4) verify（`./scripts/verify-package.sh`）

- `[verify-package] FAIL reason=missing-package`
  - next: `run ./scripts/verify-package.sh <artifact.tar.gz>`
- `[verify-package] FAIL reason=artifact-not-found`
  - next: `run ./scripts/package-release.sh to generate artifact`
- `[verify-package] FAIL reason=checksum-missing`
  - next: `regenerate package to produce checksum`
- `[verify-package] FAIL reason=manifest-missing`
  - next: `regenerate package to produce manifest`
- `[verify-package] FAIL reason=manifest-checksum-empty`
  - next: `regenerate package; manifest format invalid`
- `[verify-package] FAIL reason=no-sha-tool`
  - next: `install shasum/sha256sum and retry`
- `[verify-package] FAIL reason=checksum-mismatch`
  - next: `regenerate artifact and checksum, then retry`

## 推荐排障顺序

1. 先跑 preflight：`./scripts/preflight.sh <target-dir>`
2. 再跑 verify：`./scripts/verify-package.sh <artifact.tar.gz>`
3. 最后执行 install/upgrade 并按 `next:` 收敛
