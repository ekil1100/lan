# Beta 试用 Runbook（字段约定最小版）

> 当前为最小字段约定，后续在 R11-T04 扩充操作流程。

## 字段约定（与反馈模板一致）

- `severity`: P0/P1/P2/P3
- `environment`: OS / arch / lan version / package / install path
- `repro`: precondition / steps / expected / actual / repro_rate
- `evidence`: command output / log path / snapshot path / optional media
- `next_step`: mitigation / workaround
- `triage`: status / owner / target fix version

对应模板：`docs/release/beta-feedback-template.md`
