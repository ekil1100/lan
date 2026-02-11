# Lan Tasks（实时执行清单）

> 来源：`docs/ROADMAP.md`。本文件用于开发过程实时更新。

## In Progress

- [ ] R3-T12（NEXT）R3 第三批原子任务拆解（聚焦 Tool 协议与可观测性）
  - 预计时长：0.5-1 小时
  - 改动范围：`docs/TASKS.md`、`docs/ROADMAP.md`（如需）
  - DoD：
    1) 新增 3-5 个可执行任务（范围 + DoD + 预计时长）；
    2) 任务不与已完成 R3-T01~T11 重叠；
    3) 指定唯一 NEXT。

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

- [x] R1-T08 在 CI 中增加可选 `smoke-online`（secrets 存在时执行）
  - 文件：`.github/workflows/ci.yml`
  - 验收：存在任一 API key secrets 时执行 `make smoke-online`；无 secrets 时明确跳过且不失败
  - 本地验证：`zig build` / `zig build test` / `make smoke` 通过

- [x] R2-T01 第一批原子任务拆解（TDD/BDD）
  - 文件：`docs/TASKS.md`
  - 结果：产出 5 个可执行原子任务（R2-T02 ~ R2-T06），每项含 DoD、改动范围、预计时长
  - 指定下一执行项：R2-T02（NEXT）

- [x] R2-T02（BDD）命令面板最小闭环（`/help`、`/clear`、`/exit`）
  - 文件：`src/tui.zig`
  - 行为验收：
    1) `/help` 支持显示与再次输入后隐藏（toggle）；
    2) `/clear` 清空会话并保留 system message；
    3) `/exit` 稳定退出不崩溃。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T03（TDD）输入编辑基础：空输入/多行输入边界处理
  - 文件：`src/tui.zig`、`scripts/test-input-boundaries.sh`
  - 行为验收：
    1) 空输入不会产生 user message（不触发模型调用）；
    2) 支持 `""" ... """` 多行输入并完整保留换行；
    3) 新增可重复脚本：`./scripts/test-input-boundaries.sh`。
  - 验证：`zig build` / `zig build test` / `make smoke` / `scripts/test-input-boundaries.sh` 通过。

- [x] R2-T04（TDD）工具调用可视化状态：开始/成功/失败
  - 文件：`src/agent.zig`、`src/tui.zig`
  - 行为验收：
    1) 工具调用路径增加可见状态提示（start → success）；
    2) 失败提示附可操作建议（API key / 网络 / 通用诊断建议）；
    3) 未改变工具执行语义，仅增强提示层。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T05（BDD）错误分级最小实现：配置/网络/提供商
  - 文件：`src/config.zig`、`src/llm.zig`、`src/tui.zig`、`scripts/test-error-classification.sh`
  - 行为验收：
    1) UI 可见 `[error:config]` / `[error:network]` / `[error:provider]` 三类分级；
    2) 每类错误均有可执行下一步建议；
    3) 新增可复现场景脚本：`./scripts/test-error-classification.sh`（配置类）。
  - 验证：`zig build` / `zig build test` / `make smoke` / `scripts/test-error-classification.sh` 通过。

- [x] R2-T06（TDD）streaming 回归补强：partial line + escaped content
  - 文件：`src/llm.zig`（测试）
  - 新增测试：
    1) `SSE parser handles partial-line buffering across chunks`；
    2) `SSE parser unescapes newline and quote content`。
  - 说明：仅补测试，无业务语义变更。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T07 拆分下一批原子任务
  - 文件：`docs/TASKS.md`
  - 结果：新增 5 个可执行任务（R2-T08 ~ R2-T12），均包含范围与 DoD
  - 指定唯一 NEXT：R2-T08

- [x] R2-T08（TDD）工具状态补全：失败路径可视化（start → fail）
  - 文件：`src/agent.zig`
  - 行为验收：
    1) 工具调用链路统一输出 `start`，并在识别失败摘要时输出 `fail`；
    2) fail 输出包含错误摘要与可执行建议；
    3) 不改变工具调用语义（仅提示层增强）。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T09（TDD）命令回归脚本：`/help` `/clear` `/exit` 自动验收
  - 文件：`scripts/test-commands.sh`
  - 行为验收：
    1) 覆盖 `/help` 显示与隐藏（toggle）；
    2) 覆盖 `/clear` 清理提示；
    3) 覆盖 `/exit` 退出链路；
    4) 脚本输出明确 PASS/FAIL 且可一条命令执行。
  - 验证：`./scripts/test-commands.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T10（BDD）错误分级复现场景补全：网络/提供商
  - 文件：`scripts/test-error-network-provider.sh`
  - 复现前置条件：本机可用 `python3`（用于本地 mock provider 端口）。
  - 场景覆盖：
    1) 网络类：`base_url=http://127.0.0.1:9/v1`（连接拒绝）→ 命中 `[error:network]`；
    2) 提供商类：本地 http server 返回非 2xx → 命中 `[error:provider]`。
  - 验证：`./scripts/test-error-network-provider.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T11（TDD）多行输入边界补测：空多行块/未闭合块
  - 文件：`src/tui.zig`、`scripts/test-input-boundaries.sh`
  - 行为验收：
    1) `"""` 空块显示 `Empty multiline input ignored.` 且不触发模型调用；
    2) 未闭合多行块显示 `Multiline input not closed...` 并丢弃输入，不崩溃；
    3) 自动化脚本断言已补齐。
  - 验证：`./scripts/test-input-boundaries.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T12（BDD）错误文案统一与精简（中英文一致性）
  - 文件：`src/tui.zig`、`README.md`
  - 行为验收：
    1) 三类错误统一为 `[error:<class>] <summary>` + `next: <step>`；
    2) 每类均包含明确可执行 next step；
    3) 删除重复/模糊提示并同步 README 的 Error Labels 说明。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R2-T13（收尾）R2 关闭条件判定 + R3 启动任务拆解
  - 文件：`docs/TASKS.md`、`docs/ROADMAP.md`
  - R2 判定：close-ready（R2-T02 ~ R2-T12 已完成，无阻塞项）
  - 结果：产出 R3 第一批 5 个原子任务（R3-T01 ~ R3-T05），均含范围/DoD/预计时长
  - 指定唯一 NEXT：R3-T01

- [x] R3-T01（TDD）Tool 错误码最小规范（read/write/exec/list）
  - 文件：`src/tools.zig`、`src/agent.zig`
  - 验收：
    1) 定义统一错误码枚举与输出格式：`[tool_error:<code>] <detail> | next: <step>`；
    2) 覆盖 read/write/exec/list 四个内置工具错误路径；
    3) 不改变工具语义，仅统一错误输出结构。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T02（BDD）Tool 调用日志最小落地（时间/工具名/结果）
  - 文件：`src/agent.zig`
  - 验收：
    1) 工具调用链路输出 `start/end`，包含 `ts`、`name`、`result`；
    2) fail 路径输出 `summary` + `next`；
    3) 不引入交互阻塞（仅输出日志文本）。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T03（TDD）`exec` 工具超时保护（最小实现）
  - 文件：`src/agent.zig`、`src/tools.zig`、`scripts/repro-exec-timeout.sh`
  - 验收：
    1) `toolExec` 默认超时 10s（常量）生效；
    2) 超时返回统一错误码：`[tool_error:process_timeout] ... | next: ...`；
    3) 正常短命令路径不受影响。
  - 验证：`zig build` / `zig build test` / `make smoke` / `./scripts/repro-exec-timeout.sh` 通过。

- [x] R3-T04（BDD）工具参数缺失文案统一（read/write/exec/list）
  - 文件：`src/agent.zig`、`scripts/repro-missing-args.sh`
  - 验收：
    1) read/write/exec/list 参数缺失统一返回 `[tool_error:missing_argument] ... | next: ...`；
    2) 每条缺失文案包含可执行 next step；
    3) 可复现脚本：`./scripts/repro-missing-args.sh`。
  - 验证：`zig build` / `zig build test` / `make smoke` / `./scripts/repro-missing-args.sh` 通过。

- [x] R3-T05（TDD）工具行为回归脚本 v1（read/write/list/exec）
  - 文件：`src/agent.zig`、`scripts/test-tools-regression.sh`
  - 验收：
    1) 覆盖 read/write/list/exec 四工具基础成功路径；
    2) 脚本输出 PASS/FAIL，适合本地/CI 批跑；
    3) 脚本不依赖在线 API key。
  - 验证：`./scripts/test-tools-regression.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T06（拆解）R3 第二批任务边界与任务包收敛
  - 文件：`docs/TASKS.md`
  - 结果：完成 A/B/C/D/E 收敛，产出 R3-T07 ~ R3-T10（3-5 个）并明确依赖关系
  - 指定唯一 NEXT：R3-T07

- [x] R3-T07（TDD，并行）工具失败路径回归扩展：非零退出码（离线）
  - 文件：`src/tools.zig`、`src/agent.zig`、`scripts/test-tools-fail-nonzero.sh`
  - 验收：
    1) 新增非零退出码失败路径回归（离线可复现）；
    2) 命中统一错误结构：`[tool_error:process_nonzero_exit] ... | next: ...`；
    3) 脚本输出 PASS/FAIL：`./scripts/test-tools-fail-nonzero.sh`。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T08（TDD，并行）exec 稳定性边界：`stderr/exit-code/timeout` 优先级固化
  - 文件：`src/agent.zig`、`src/tools.zig`、`scripts/test-exec-priority.sh`
  - 验收：
    1) 明确并实现优先级规则：timeout > wait/spawn 错误 > exit-code > stderr 附加信息；
    2) 规则通过测试/脚本验证（含 stderr 与 timeout 优先级）；
    3) 正常短命令成功路径保持不变。
  - 验证：`./scripts/test-exec-priority.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T09（BDD，串行）脚本与 CI 对齐：统一执行入口与失败判定
  - 文件：`Makefile`、`.github/workflows/ci.yml`、`scripts/test-regression-suite.sh`
  - 验收：
    1) 统一入口命令：`make regression`（本地/CI 同一套）；
    2) 通过标准与失败判定：exit code + `[regression-suite] PASS`；
    3) CI 直接复用本地入口（新增 Regression Suite 步骤）。
  - 验证：`make regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T10（收敛）第二批任务收口与依赖编排
  - 文件：`docs/TASKS.md`
  - 收口结果：
    1) 第二批任务总数为 4（R3-T07 ~ R3-T10，满足 3-5 约束）；
    2) 依赖关系明确：R3-T07 与 R3-T08 并行，R3-T09 串行依赖二者，R3-T10 最终收敛；
    3) 唯一 NEXT 已切换到 R3-T11。
  - 说明：本次为文档原子收口提交。

- [x] R3-T11（验收增强）回归入口失败判定补强 + 判定文案统一
  - 文件：`scripts/test-regression-suite.sh`、`scripts/test-tools-regression.sh`、`scripts/test-tools-fail-nonzero.sh`、`scripts/test-exec-priority.sh`
  - 验收：
    1) 任一子脚本失败即立即非零退出（ERR trap）；
    2) 入口输出统一失败摘要：`[regression-suite] FAIL case=<name> exit=<code>`；
    3) 三个关键子脚本判定文案统一为 `PASS/FAIL + reason=<...>`；
    4) 本地可复现失败演示：
       - `REGRESSION_FAIL_AT=./scripts/test-commands.sh ./scripts/test-regression-suite.sh` → `exit 1`；
    5) 正常路径保持 `[regression-suite] PASS`。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

## Blocked
- 暂无（如出现请写：阻塞原因/影响范围/预计解除时间）

## Next Up
1. 立即执行 R3-T12（NEXT）：R3 第三批原子任务拆解（Tool 协议与可观测性）

## 更新约定（强制）
- 每次代码改动后，若任务状态变化，必须同步更新本文件
- 状态仅允许：`In Progress / Done / Blocked / Next Up`
- 每个任务至少写：目标、当前状态、下一步
