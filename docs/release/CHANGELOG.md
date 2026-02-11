# Changelog

所有值得关注的变更都记录在这里。格式参考 [Keep a Changelog](https://keepachangelog.com/)。

---

## [0.1.0-beta] — 2026-02-12

**首个公开 Beta 版本。** 从零到可安装、可升级、可回滚、可验证的完整 Agent CLI/TUI。

### 核心能力
- **CLI/TUI 交互**（R1-R2）：Zig 0.15 原生构建，流式 SSE 对话，多行编辑，历史回溯，快捷键帮助，错误分级与统一 next-step。
- **Tool Runtime**（R3）：工具协议（输入/输出/错误码），超时/取消/重试策略，结构化日志与脱敏。
- **Skill Runtime**（R4）：Skill 一等公民 — `lan skill list/add/update/remove`，manifest 校验，权限控制。
- **Provider 路由**（R5）：provider schema 校验，fallback 链，route_mode（speed/quality），route_event 日志。

### 发布与运维
- **打包与安装**（R6）：`--version` 输出，`package-release.sh` 打包，`install.sh` 安装，`upgrade.sh` 升级。
- **安装健壮性**（R7）：路径冲突检测，升级回滚，校验与 manifest 验证，安装/升级结构化日志。
- **发布体验**（R8）：平台检测，升级回滚增强，preflight 预检，release notes 生成。
- **运维就绪**（R9）：preflight JSON+text 双通道，release notes 参数化，离线 support bundle（含脱敏），ops 排障手册。

### Beta 准备
- **验收管线**（R10）：准入清单 → 一键验证 → 安装后健康检查 → 验收报告 → 快照。
- **试用准备**（R11）：试用预检 → 反馈模板 → 回滚演练 → 试用 runbook → 登记表。
- **试用执行**（R12）：环境自检脚本，登记表模板，结果汇总（机读+人读），go/no-go 风险模板。
- **运营质量**（R13）：跨批次统计聚合，go/no-go 字段校验器，证据一致性检查。

### 已知限制
- 仅支持 macOS arm64（其他平台未验证）。
- 在线对话需自备 API key（OpenAI 兼容）。
- TUI 二进制不支持 `--help`（使用 `/exit` 管道方式进行健康检查）。
- Skill 生态尚未建立，仅有 manifest 框架。

---

## [Unreleased]

_后续变更在此追踪。_
