# Release Checklist — Lan Beta

> 人工核对清单，发布前逐项确认。

## 信息核对

| # | 项目 | 责任人 | 验收标准 | 状态 |
|---|---|---|---|---|
| 1 | 版本号确认 | @like | `version` 与 tag 一致（如 `v0.1.0-beta`） | ☑ |
| 2 | Git tag 创建 | @like | tag 打在 main 分支最新 commit | ☑ |
| 3 | CHANGELOG 更新 | @like | 包含本轮所有变更（人话描述，非 commit 列表） | ☑ |
| 4 | 已知问题文档 | @like | `docs/release/known-issues.md` 已更新 | ☑ |

## 构建与产物

| # | 项目 | 责任人 | 验收标准 | 状态 |
|---|---|---|---|---|
| 5 | CI 全绿 | CI | 所有 regression 步骤通过 | ☑ |
| 6 | macOS artifact | CI | `lan-v*-macos-aarch64.tar.gz` 已生成 | ☐ (pending CI) |
| 7 | Linux artifact | CI | `lan-v*-linux-x86_64.tar.gz` 已生成 | ☐ (pending CI) |
| 8 | Checksum 文件 | CI | `.sha256` 文件与 artifact 一同生成 | ☐ (pending CI) |
| 9 | Manifest 文件 | CI | `.manifest` 文件包含版本与平台信息 | ☐ (pending CI) |

## 文档与入口

| # | 项目 | 责任人 | 验收标准 | 状态 |
|---|---|---|---|---|
| 10 | README 安装说明 | @like | 指向最新 release 下载链接 | ☑ |
| 11 | Beta 公告模板 | @like | `docs/release/beta-announcement.md` 已更新 | ☑ |
| 12 | 反馈渠道 | @like | Issue template 可用，链接有效 | ☑ |

## 发布前最终检查

| # | 项目 | 责任人 | 验收标准 | 状态 |
|---|---|---|---|---|
| 13 | 本地 smoke 通过 | @like | `make smoke` 通过 | ☑ |
| 14 | 本地 full-regression 通过 | @like | `make full-regression` 通过 | ☑ |
| 15 | 安装验证脚本通过 | @like | `./scripts/verify-install.sh v0.1.0-beta` 通过 | ☐ (pending artifact) |
| 16 | 无阻塞级 issue | @like | GitHub issues 无 P0/P1 阻塞项 | ☑ |

---

**验证记录**

| 时间 | 验证项 | 结果 | 备注 |
|---|---|---|---|
| 2026-02-12 13:26 | Git tag | ☑ | `v0.1.0-beta` 已 push |
| 2026-02-12 13:26 | CI 状态 | ☐ | workflow 运行中，产物待生成 |
| 2026-02-12 13:26 | Release 页面 | ☐ | 等待 CI 完成创建 |

**下一步**：CI 完成后运行 `./scripts/verify-ci-release.sh` 确认产物。

---

**发布决策**

- [ ] 所有检查项已完成
- [ ] 至少 1 人 review 通过
- [ ] 正式发布

**发布命令（参考）**
```bash
git tag -a v0.1.0-beta -m "Beta release"
git push origin v0.1.0-beta
```

---

*Last updated: 2026-02-12*
