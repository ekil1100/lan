# Lan Tasks（实时执行清单）

> 来源：`docs/ROADMAP.md`。本文件用于开发过程实时更新。

## In Progress

- [ ] R1-T08 在 CI 中增加可选 `smoke-online`（secrets 存在时执行）
  - 现状：待改 workflow 条件执行

## Done

- [x] R1-D01 清理 git remote 凭据
  - 结果：origin 使用 `https://github.com/ekil1100/lan.git`

- [x] R1-D02 配置分支 upstream
  - 结果：`main` 跟踪 `origin/main`

- [x] R1-D03 增加 CI 基线
  - 文件：`.github/workflows/ci.yml`
  - 内容：`zig build` + `zig build test`

- [x] R1-D04 文档切换到 Zig 0.15 基线
  - 文件：`README.md`, `CONTRIBUTING.md`

- [x] R1-T01 完成 Zig 0.15.2 迁移并通过 `zig build`
  - 结果：`zig build` 通过（2026-02-11）
  - 修复范围：`ArrayList` API、`stdin/stdout` API、`std.http.Client` 请求 API、`std.time.sleep` API
  - 涉及文件：`src/agent.zig`, `src/tui.zig`, `src/llm.zig`, `src/tools.zig`

- [x] R1-T02 兼容修复后通过 `zig build test`
  - 结果：`zig build test` 通过（2026-02-11）

- [x] R1-T03 增加 smoke test（启动→对话→历史写入）
  - 文件：`scripts/smoke.sh`，`Makefile`（新增 `smoke`）
  - 结果：本地 smoke 通过（启动/退出/历史写入校验）
  - 说明：无 API key 时自动跳过在线对话路径

- [x] R1-T04 在 CI 中增加 smoke 阶段（可选）
  - 文件：`.github/workflows/ci.yml`
  - 结果：CI 已包含 `make smoke`

- [x] R1-T05 对 `src/llm.zig` 的流式请求路径做 0.15 原生 streaming 适配
  - 文件：`src/llm.zig`
  - 结果：`chatOpenAIStream` 改为真实 SSE 增量读取并即时输出（非回退到非流式）
  - 验证：`zig build` / `zig build test` / `make smoke` 全通过

- [x] R1-T06 增加“有 API key”的在线对话 smoke（CI secrets 可启用）
  - 文件：`scripts/smoke-online.sh`、`Makefile`（新增 `smoke-online`）
  - 结果：在线对话路径支持独立验收（有 key 必跑、无 key 直接 fail）

- [x] R1-T07 为 streaming 增加最小回归测试（SSE 片段解析）
  - 文件：`src/llm.zig`
  - 覆盖：多 chunk 拼接、`[DONE]` 终止、异常片段容错
  - 验证：`zig build` / `zig build test` / `make smoke` 通过

## Blocked
- 暂无（如出现请写：阻塞原因/影响范围/预计解除时间）

## Next Up
1. 完成 R1-T08：在 CI 中增加可选 `smoke-online`（secrets 存在时执行）
2. 基于 TDD/BDD 继续推进下一阶段任务
3. 视情况补充更多 streaming 边界回归样例

## 更新约定（强制）
- 每次代码改动后，若任务状态变化，必须同步更新本文件
- 状态仅允许：`In Progress / Done / Blocked / Next Up`
- 每个任务至少写：目标、当前状态、下一步
