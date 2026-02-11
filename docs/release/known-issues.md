# Known Issues — Lan Beta

> 从 CHANGELOG 和 beta-announcement 已知限制提取，结构化跟踪。

| ID | Issue | Status | Workaround | Tracking |
|---|---|---|---|---|
| KI-001 | 仅验证 macOS arm64，其他平台未测试 | Open | 欢迎反馈其他平台结果 | — |
| KI-002 | 在线对话需自备 OpenAI 兼容 API key | By Design | 设置 `OPENAI_API_KEY` 环境变量 | — |
| KI-003 | TUI 二进制不支持 `--help` | By Design | 使用 `echo /exit \| lan` 管道方式做健康检查 | — |
| KI-004 | Skill 生态尚未建立 | Open | manifest 框架已就绪，可手动添加 skill | — |
| KI-005 | 1Password signing agent 间歇性挂起导致 git commit 失败 | Workaround | 使用 `git -c commit.gpgsign=false commit` 绕过 | — |

## 状态说明

- **Open**：已知但尚未修复
- **By Design**：设计限制，短期不会改变
- **Workaround**：有临时解决方案
- **Fixed**：已修复（标注修复版本）

## 反馈

发现新问题请使用 [Bug Report](https://github.com/ekil1100/lan/issues/new?template=bug_report.yml) 模板提交。
