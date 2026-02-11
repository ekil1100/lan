# Beta 试用反馈模板（可直接复制）

> 用法：每个问题一条，直接复制本模板填写并提交。
> 字段口径与 `docs/release/beta-trial-runbook.md` 对齐。

---

## 1) 问题等级（severity）
- [ ] P0（阻塞：无法继续试用/数据风险）
- [ ] P1（严重：核心路径受影响）
- [ ] P2（一般：有替代方案）
- [ ] P3（轻微：体验问题）

## 2) 基本信息
- 标题：
- 发现时间（本地时区）：
- 反馈人：
- 影响范围（单机/多机/全部试用者）：

## 3) 环境信息（environment）
- OS/版本：
- 机器架构（arm64/x86_64）：
- Lan 版本（`lan --version`）：
- 候选包：
- 安装路径：

## 4) 复现信息（repro）
- 前置条件：
- 复现步骤（Step 1/2/3...）：
- 预期结果：
- 实际结果：
- 复现概率（必现/偶现，约 xx%）：

## 5) 证据信息（evidence）
- 命令输出（粘贴关键片段）：
- 日志路径：
- 快照路径（如 `dist/beta-snapshots/<ts>`）：
- 截图/录屏（可选）：

## 6) next-step（建议动作）
- 建议动作 1：
- 建议动作 2：
- 临时绕过方案（如有）：

## 7) 处理状态（triage）
- 当前状态：Open / In Progress / Resolved / Won't Fix
- Owner：
- 目标修复版本：

---

## 一键复制（简版）

```text
[Beta Feedback]
Severity: P0|P1|P2|P3
Title:
Time:
Reporter:
Impact:
Environment: <OS/arch/version/package/path>
Repro Steps:
Expected:
Actual:
Repro Rate:
Evidence:
Next-step:
Status:
Owner:
Target Fix:
```
