# GA v1.0.0 Checklist

> 最终发布前逐项确认清单

## 基础条件

| # | 检查项 | 状态 | 证据/备注 |
|---|--------|------|-----------|
| 1 | 版本号更新为 v1.0.0 | ☐ | `src/main.zig`, `build.zig.zon` |
| 2 | 所有测试通过 | ☐ | `make full-regression` |
| 3 | 文档完整 | ☑ | README, docs/ 已审查 (R30-T03) |
| 4 | CI 全绿 | ☐ | GitHub Actions 状态 (等待中) |

## 功能完整性

| # | 检查项 | 状态 | 证据/备注 |
|---|--------|------|-----------|
| 5 | TUI 基础功能正常 | ☑ | smoke test 通过 |
| 6 | Skill 管理可用 | ☑ | add/remove/list/info/search (R28) |
| 7 | 历史记录功能 | ☑ | export/search/clear/stats (R29) |
| 8 | Config 热重载 | ☑ | `lan config reload` (R29) |
| 9 | Provider 降级 | ☑ | fallback logging (R28) |
| 10 | 跨平台支持 | ☑ | macOS + Linux artifact |

## 发布准备

| # | 检查项 | 状态 | 证据/备注 |
|---|--------|------|-----------|
| 11 | Release notes 完成 | ☐ | `docs/release/v1.0.0-notes.md` |
| 12 | 安装验证通过 | ☐ | `verify-install.sh v1.0.0` |
| 13 | 回滚预案就绪 | ☑ | `docs/release/rollback-plan.md` (R31) |
| 14 | 错误码文档完整 | ☑ | `docs/errors.md` E1xx-E5xx (R30/R31) |

## GA 条件追踪 (来自 ROADMAP)

| # | 条件 | 状态 | 备注 |
|---|------|------|------|
| 1 | 连续四个迭代无阻塞回归 | ☑ | R27-R30 完成 |
| 2 | 双平台支持（macOS + Linux）| ☑ | Linux 验证通过 |
| 3 | 运维文档与诊断包 | ☑ | doctor, support-bundle |
| 4 | 发布流程稳定 | ☑ | v0.1.0-beta tag pushed |
| 5 | P0/P1 issue 清零 | ☑ | 当前无阻塞 |
| 6 | Error code 统一 | ☑ | R30-T01 完成 |
| 7 | CI 产物最终验证 | ☐ | **等待 Actions** |

## 发布执行

| # | 步骤 | 命令 |
|---|------|------|
| 15 | 创建 tag | `git tag -a v1.0.0 -m "Lan v1.0.0 GA"` |
| 16 | Push tag | `git push origin v1.0.0` |
| 17 | 验证 CI | 检查 Actions 运行状态 |
| 18 | 验证 Release | 检查 artifact + checksum |
| 19 | 发布公告 | GitHub Discussion |

## 签字

- [ ] 技术验收：@like
- [ ] 文档验收：@like
- [ ] 发布执行：@like

---

*Created: 2026-02-12*
