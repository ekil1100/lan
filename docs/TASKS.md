# Lan Tasks（实时执行清单）

> 来源：`docs/ROADMAP.md`。本文件用于开发过程实时更新。

## In Progress

### R3 第三批收口结论（R3-T17）
- **状态判定**：close-ready ✅
- **第三批任务状态**：
  - R3-T12 Tool 协议响应结构 v1：done
  - R3-T13 Tool 调用耗时指标 duration_ms：done
  - R3-T14 Tool 观测日志格式稳定化：done
  - R3-T15 Tool 协议回归脚本 v1：done
  - R3-T16 观测与协议入口汇总（本地/CI）：done

### R4 第一批收口结论（R4-T06）
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R4-T01 Skill manifest schema v1：done
  - R4-T02 `lan skill list` 本地索引：done
  - R4-T03 `lan skill add` 本地目录安装：done
  - R4-T04 `lan skill remove` 卸载一致性：done
  - R4-T05.A 本地回归入口定义：done
  - R4-T05.B CI 复用本地回归入口：done

### R4 第二批收口结论（R4-T12）
- **状态判定**：close-ready ✅
- **第二批任务状态**：
  - R4-T07 manifest 字段边界校验：done
  - R4-T08 `lan skill update` 本地覆盖安装：done
  - R4-T09 skill index snapshot + list 回退：done
  - R4-T10 权限声明显示与提示：done
  - R4-T11 第二批回归入口与 CI 对齐：done

### R5 第一批收口结论（R5-T06）
- **收口判据**：
  1) R5-T01~R5-T05 均达到 DoD 且有对应回归入口；
  2) 本地与 CI 使用同一回归命令（无双维护）；
  3) route schema / fallback / mode / route_event 四项能力均可离线复现。
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R5-T01 Provider 配置 schema v1：done
  - R5-T02 Provider fallback 最小闭环：done
  - R5-T03 路由策略 speed|quality：done
  - R5-T04 路由日志标准化：done
  - R5-T05 第一批回归入口与 CI 对齐：done

### R6 第一批收口结论（R6-T06）
- **收口判据**：
  1) R6-T01~R6-T05 全部达到 DoD 且有离线回归验证；
  2) 本地与 CI 使用同一回归命令（无双维护）；
  3) 版本/打包/安装/升级链路完整闭环。
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R6-T01 `--version` 构建元信息：done
  - R6-T02 发布包最小闭环：done
  - R6-T03 安装脚本 v1：done
  - R6-T04 升级脚本 v1：done
  - R6-T05 第一批回归入口与 CI 对齐：done

### R7 第一批收口结论（R7-T06）
- **收口判据**：
  1) R7-T01~R7-T05 全部达到 DoD 且具备离线回归验证；
  2) 本地与 CI 复用同一入口命令，无双维护；
  3) 安装/升级/校验/日志四类能力形成闭环。
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R7-T01 安装路径冲突检查：done
  - R7-T02 升级失败回滚：done
  - R7-T03 checksum + manifest 校验：done
  - R7-T04 安装/升级日志标准化：done
  - R7-T05 第一批回归入口与 CI 对齐：done

### R8 第一批收口结论（R8-T06）
- **收口判据**：
  1) R8-T01~R8-T05 全部达到 DoD 且有离线回归；
  2) 本地与 CI 使用同一回归入口命令（无双维护）；
  3) 分发体验链路（安装/升级/预检/说明）闭环。
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R8-T01 安装器平台探测与默认路径：done
  - R8-T02 升级回滚日志与校验增强：done
  - R8-T03 安装前预检脚本：done
  - R8-T04 release notes stub：done
  - R8-T05 第一批回归入口与 CI 对齐：done

### R9 第一批收口结论（R9-T06）
- **收口判据**：
  1) R9-T01~R9-T05 全部达到 DoD 且有离线回归；
  2) 本地与 CI 复用同一回归入口（无双维护）；
  3) 预检/发布说明/诊断包/故障清单形成最小运维闭环。
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R9-T01 预检 JSON+文本双通道：done
  - R9-T02 发布说明模板参数化：done
  - R9-T03 离线诊断打包 support bundle：done
  - R9-T04 运维故障清单：done
  - R9-T05 第一批回归入口与 CI 对齐：done

### R10 第一批收口结论（R10-T06）
- **收口判据**：
  1) R10-T01~R10-T05 全部达到 DoD 且可离线复验；
  2) Beta 验收总入口可一键串联 checklist/verify/health/report；
  3) 本地与 CI 复用同一验收入口（无双维护）。
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R10-T01 Beta 清单执行脚本：done
  - R10-T02 Beta 候选一键验证入口：done
  - R10-T03 发布后健康检查：done
  - R10-T04 Beta 验收报告模板：done
  - R10-T05 Beta 一键验收总入口与 CI 对齐：done

### R11 第一批收口结论（R11-T06）
- **收口判据**：
  1) R11-T01~R11-T05 全部达到 DoD 且可离线回归；
  2) 本地与 CI 复用同一回归入口（`make r11-beta-trial-regression`）；
  3) 试用准备链路（快照/反馈模板/回滚演练/runbook）形成闭环。
- **状态判定**：close-ready ✅
- **第一批任务状态**：
  - R11-T01 Beta 验收结果快照脚本：done
  - R11-T02 试用反馈模板：done
  - R11-T03 Beta 回滚演练脚本：done
  - R11-T04 Beta 试用 runbook：done
  - R11-T05 第一批回归入口与 CI 对齐：done

### R12 第一批原子任务（Beta 小规模试用执行）
- [ ] R12-T05（NEXT，串行）R12 第一批回归入口与 CI 对齐
  - 依赖：R12-T01~R12-T04（串行收口）
  - 预计时长：1 小时
  - 改动范围：`Makefile`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - DoD：
    1) 定义统一入口执行 R12 第一批回归；
    2) 明确 PASS/FAIL 判定（exit code + 统一标记）；
    3) CI 复用本地入口命令；
    4) 三项命令验证通过。


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

- [x] R3-T11.A（并行）第三批原子任务拆解草案
  - 文件：`docs/TASKS.md`
  - 结果：新增 5 个任务（R3-T12 ~ R3-T16），均包含范围/DoD/预计时长
  - 约束：明确不与 R3-T01~T10 重叠（见“R3 第三批设计说明”）

- [x] R3-T11.B（串行，依赖A）唯一 NEXT 收敛
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 唯一 NEXT 明确为 R3-T12；
    2) 并行/串行依赖顺序已显式写入“R3 第三批设计说明”；
    3) 与 ROADMAP 当前阶段状态一致（R3 进行中）。

- [x] R3-T12（TDD）Tool 协议响应结构 v1（统一字段）
  - 文件：`src/tools.zig`、`src/agent.zig`
  - 验收：
    1) 成功/失败统一字段：`ok/code/detail/next/meta`；
    2) read/write/list/exec 四工具输出结构一致；
    3) 保持执行语义，仅统一输出结构。
  - 验证：`zig build` / `zig build test` / `make smoke` / `./scripts/test-tools-regression.sh` 通过。

- [x] R3-T13（TDD）Tool 调用耗时指标最小落地（duration_ms）
  - 文件：`src/agent.zig`
  - 验收：
    1) 工具调用日志 `end` 行新增 `duration_ms` 字段；
    2) success/fail 路径均输出耗时；
    3) 仅日志增强，不引入阻塞交互。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T14（BDD）Tool 观测日志格式稳定化（机器可解析）
  - 文件：`src/agent.zig`、`README.md`、`scripts/parse-tool-log-sample.sh`
  - 验收：
    1) 日志字段顺序与命名固定（`tool_event phase ts name result duration_ms summary next`）；
    2) 样例可被脚本稳定解析（`./scripts/parse-tool-log-sample.sh`）；
    3) README 已补字段说明与解析示例。
  - 验证：`zig build` / `zig build test` / `make smoke` / `./scripts/parse-tool-log-sample.sh` 通过。

- [x] R3-T15（TDD）Tool 协议回归脚本 v1（结构断言）
  - 文件：`src/agent.zig`、`scripts/test-tool-protocol-structure.sh`
  - 验收：
    1) 覆盖 read/write/list/exec 四工具协议结构断言（`ok/code/detail/next/meta`）；
    2) 脚本输出 PASS/FAIL，适合本地与 CI；
    3) 离线可运行。
  - 验证：`./scripts/test-tool-protocol-structure.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T16（BDD，串行）观测与协议入口汇总（本地/CI）
  - 文件：`Makefile`、`.github/workflows/ci.yml`、`scripts/test-regression-suite.sh`
  - 验收：
    1) 统一入口：`make protocol-observability`（本地）+ `make regression`（总入口）；
    2) 通过/失败判定明确：exit code + `[protocol-observability-suite] PASS` / FAIL 摘要；
    3) CI 复用本地入口（新增 `Protocol + Observability Suite` 步骤）。
  - 验证：`make protocol-observability` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R3-T16.B（并行）协议+观测回归入口文档化
  - 文件：`README.md`、`docs/TASKS.md`
  - 验收：
    1) 文档补充统一入口用法（`make regression` / `make protocol-observability`）；
    2) 提供本地执行命令与结果判读示例（exit code + PASS/FAIL）；
    3) 与 CI 入口一致（CI 同样执行 `make protocol-observability` / `make regression`）。

- [x] R3-T17（收口）R3 第三批收口与 R4 启动拆解
  - 文件：`docs/TASKS.md`
  - 结论：
    1) R3 第三批（R3-T12~R3-T16）全部 done，close-ready；
    2) 已产出 R4 第一批 5 个原子任务（R4-T01~R4-T05）；
    3) 唯一 NEXT 已切换到 R4-T01。

- [x] R4-1.A（并行）Tool 协议字段兼容性检查脚本
  - 文件：`scripts/check-tool-protocol-compat.sh`、`Makefile`、`scripts/test-regression-suite.sh`
  - 验收：
    1) 新增离线检查脚本，校验 v1 字段完整性 + 兼容约束；
    2) 输出 PASS/FAIL，并在失败时给出字段/约束原因明细；
    3) 已接入 `make protocol-observability` 与总回归入口。
  - 验证：`make protocol-observability` 通过。

- [x] R4-T01（TDD）Skill manifest schema v1（最小字段）
  - 文件：`src/skill_manifest.zig`、`src/main.zig`、`docs/skills/manifest.valid.json`、`docs/skills/manifest.invalid.json`
  - 验收：
    1) 定义最小字段：`name/version/entry/tools/permissions`；
    2) 提供 1 份合法 + 1 份非法样例；
    3) 增加 schema 校验测试（valid/invalid）。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R4-T02（TDD）`lan skill list` 最小闭环（本地索引）
  - 文件：`src/main.zig`、`src/skills.zig`
  - 验收：
    1) `lan skill list` 可列出已安装 skill 的 `name/version/path`；
    2) 无 skill 时输出可操作 next-step 提示；
    3) 全流程离线可运行。
  - 验证：`zig build` / `zig build test` / `make smoke` / `./zig-out/bin/lan skill list` 通过。

- [x] R4-T03（BDD）`lan skill add` 本地目录安装（无网络）
  - 文件：`src/main.zig`、`src/skills.zig`、`scripts/test-skill-add-local.sh`
  - 验收：
    1) 支持 `lan skill add <local-dir>` 本地安装；
    2) 安装前执行 manifest 校验，失败返回 `next:` 提示；
    3) 提供可复现 PASS/FAIL 脚本。
  - 验证：`./scripts/test-skill-add-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R4-T04（BDD）`lan skill remove` 卸载与状态一致性
  - 文件：`src/main.zig`、`src/skills.zig`、`scripts/test-skill-remove-local.sh`
  - 验收：
    1) 支持 `lan skill remove <name>` 按名称卸载；
    2) 卸载后 `lan skill list` 与索引状态一致；
    3) 错误路径（不存在/权限）返回可解释 `next:` 提示。
  - 验证：`./scripts/test-skill-remove-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R4-T05.A（串行）R4 第一批回归入口定义（本地）
  - 文件：`Makefile`、`scripts/test-r4-skill-suite.sh`、`src/skill_manifest.zig`
  - 验收：
    1) 新增统一入口：`make r4-skill-regression`（覆盖 manifest/list/add/remove）；
    2) PASS/FAIL 判定明确：exit code + `[r4-skill-suite] PASS/FAIL`；
    3) 入口离线可运行。
  - 验证：`make r4-skill-regression` 通过。

- [x] R4-T05.B（串行，依赖A）CI 复用 R4 回归入口
  - 文件：`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) CI 新增 `R4 Skill Suite` 步骤，执行 `make r4-skill-regression`；
    2) 与本地入口命令完全一致，无双维护；
    3) R4-T05 进度更新：A/B 全部完成，第一批回归入口对齐完成。

- [x] R4-T06（收口）R4 第一批收口与第二批任务拆解
  - 文件：`docs/TASKS.md`
  - 结论：
    1) R4 第一批（R4-T01~R4-T05）全部 done，close-ready；
    2) 已产出 R4 第二批 5 个原子任务（R4-T07~R4-T11）；
    3) 唯一 NEXT 已切换到 R4-T07。

- [x] R4-2.A（并行）skill remove 异常路径补强（权限/不存在/非法名）
  - 文件：`src/skills.zig`、`scripts/test-skill-remove-abnormal.sh`
  - 验收：
    1) 覆盖 3 类异常路径并输出 next-step（not found / invalid name / permission）；
    2) 新增离线 PASS/FAIL 回归脚本；
    3) 保持 add/list/remove 状态一致性基线校验。
  - 验证：`./scripts/test-skill-remove-abnormal.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R4-T07（TDD）Skill manifest 字段边界校验补强
  - 文件：`src/skill_manifest.zig`、`docs/skills/manifest.invalid.version.json`、`docs/skills/manifest.invalid.entry.json`
  - 验收：
    1) 增加版本号与 entry 路径边界校验（InvalidVersionFormat / InvalidEntryPath）；
    2) 补充 2 组非法样例与测试；
    3) 现有合法样例保持通过。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R4-T08（BDD）`lan skill update`（本地覆盖安装）最小闭环
  - 文件：`src/main.zig`、`src/skills.zig`、`scripts/test-skill-update-local.sh`
  - 验收：
    1) 支持 `lan skill update <local-dir>`；
    2) 更新前后 `lan skill list` 可见版本变化；
    3) 无目标 skill 时返回 `next:` 提示。
  - 验证：`./scripts/test-skill-update-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R4-T09（TDD）Skill 索引文件落地（metadata snapshot）
  - 文件：`src/skills.zig`
  - 验收：
    1) add/remove/update 成功后自动刷新 `~/.config/lan/skills/index.json`；
    2) `lan skill list` 优先读取 index，index 异常时自动回退目录扫描并重建；
    3) 离线可运行。
  - 验证：`zig build` / `zig build test` / `make smoke` / `scripts/test-skill-add-local.sh` / `scripts/test-skill-remove-local.sh` / `scripts/test-skill-update-local.sh` 通过。

- [x] R4-T10（BDD）Skill 权限声明显示与提示
  - 文件：`src/skills.zig`、`scripts/test-skill-add-local.sh`、`scripts/test-skill-update-local.sh`
  - 验收：
    1) `lan skill list` 输出 `permissions=` 摘要；
    2) add/update 成功输出 `permissions:` 提示；
    3) 仅可观测提示，不做权限拦截。
  - 验证：`zig build` / `zig build test` / `make smoke` / `scripts/test-skill-add-local.sh` / `scripts/test-skill-update-local.sh` / `scripts/test-skill-remove-local.sh` 通过。

- [x] R4-T11（串行，依赖 R4-T10）R4 第二批回归入口与 CI 对齐
  - 文件：`scripts/test-r4-skill-suite.sh`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) R4 第二批统一回归入口明确：`make r4-skill-regression`（覆盖 T07/T08/T09/T10）；
    2) PASS/FAIL 判定明确：exit code + `[r4-skill-suite] PASS/FAIL`；
    3) CI 复用同一入口命令（`make r4-skill-regression`）。
  - 验证：`make r4-skill-regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R4-T12（收口）R4 第二批收口与 R5 启动拆解
  - 文件：`docs/TASKS.md`
  - 结论：
    1) R4 第二批（R4-T07~R4-T11）全部 done，close-ready；
    2) 已产出 R5 第一批 5 个原子任务（R5-T01~R5-T05）；
    3) 唯一 NEXT 已切换到 R5-T01。

- [x] R5-1.A（并行预拆）Skill 权限提示可读性优化
  - 文件：`src/skills.zig`、`scripts/test-skill-add-local.sh`、`scripts/test-skill-update-local.sh`
  - 验收：
    1) permissions 展示改为稳定顺序 + 短格式：`perms=[a,b]`；
    2) add/update/list 三处输出统一为 `perms=` 结构；
    3) 增加最小回归断言（含稳定顺序字符串断言）。
  - 验证：`zig build` / `zig build test` / `make smoke` / `scripts/test-skill-add-local.sh` / `scripts/test-skill-update-local.sh` 通过。

- [x] R5-T01（TDD）Provider 配置 schema v1（路由最小字段）
  - 文件：`src/config.zig`、`docs/config/provider-route.valid.json`、`docs/config/provider-route.invalid.json`
  - 验收：
    1) 定义路由最小字段：`primary/fallback/timeout_ms/retry`；
    2) 提供 1 份合法 + 1 份非法配置样例；
    3) 新增 schema 校验测试（valid/invalid）。
  - 验证：`zig build` / `zig build test` / `make smoke` 通过。

- [x] R5-T02（BDD）Provider fallback 最小闭环（网络失败触发）
  - 文件：`src/config.zig`、`src/llm.zig`、`scripts/test-provider-fallback.sh`
  - 验收：
    1) 主 provider 失败后可切换 fallback（按 route_primary/route_fallback + retry）；
    2) 成功回退时输出可观测提示：`[fallback] primary=... fallback=...`；
    3) 提供离线可复现 PASS/FAIL 脚本。
  - 验证：`./scripts/test-provider-fallback.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R5-T03（TDD）路由策略 v1：速度优先/质量优先开关
  - 文件：`src/config.zig`、`src/llm.zig`
  - 验收：
    1) 新增 `route_mode`（speed|quality）并持久化到 config；
    2) speed/quality 模式选择不同 provider+model 组合（primary-first / fallback-first）；
    3) 保持默认兼容（未知 mode 回落 speed，默认配置可继续运行）。
  - 验证：`zig build` / `zig build test` / `make smoke` / `./scripts/test-provider-fallback.sh` 通过。

- [x] R5-T04（BDD）多模型路由日志标准化（机器可解析）
  - 文件：`src/llm.zig`、`scripts/parse-route-log-sample.sh`
  - 验收：
    1) 路由日志字段固定：`phase/provider/model/result/reason/duration_ms`；
    2) 提供脚本解析样例并输出 PASS/FAIL；
    3) 与 `tool_event` 风格一致（`route_event key=value ...`）。
  - 验证：`./scripts/parse-route-log-sample.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R5-T05（串行）R5 第一批回归入口与 CI 对齐
  - 文件：`Makefile`、`scripts/test-r5-routing-suite.sh`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) 统一入口：`make r5-routing-regression`（覆盖 R5-T01~R5-T04）；
    2) PASS/FAIL 判定：exit code + `[r5-routing-suite] PASS/FAIL`；
    3) CI 复用同一入口命令（`make r5-routing-regression`）。
  - 验证：`make r5-routing-regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R5-T06（并行预拆）R5 第一批收口与 R6 启动拆解草案
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 已写明 R5 第一批收口判据与 close-ready 结论；
    2) 预拆 R6 第一批 5 个原子任务（R6-T01~R6-T05）；
    3) 唯一 NEXT 已切换到 R6-T01。

- [x] R6-T01（TDD）CLI 版本与构建元信息输出（`lan --version`）
  - 文件：`build.zig`、`Makefile`、`src/main.zig`、`scripts/test-version.sh`
  - 验收：
    1) `lan --version` 输出 `version/commit/build_time`；
    2) 离线可运行，无网络依赖；
    3) 新增最小回归断言脚本（PASS/FAIL）。
  - 验证：`zig build` / `zig build test` / `make smoke` / `./scripts/test-version.sh` 通过。

- [x] R6-T02（BDD）发布包最小闭环（macOS/Linux）
  - 文件：`Makefile`、`scripts/package-release.sh`、`scripts/test-package-release.sh`
  - 验收：
    1) 生成包含二进制与 README 的可分发压缩包；
    2) 产物命名包含平台与版本（`lan-<ver>-<os>-<arch>.tar.gz`）；
    3) 提供离线自检脚本 PASS/FAIL。
  - 验证：`./scripts/test-package-release.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R6-T03（TDD）安装脚本 v1（本地 tarball 安装）
  - 文件：`scripts/install.sh`、`scripts/test-install-local.sh`
  - 验收：
    1) 支持从本地 tarball 安装到目标目录；
    2) 安装失败输出 `next:` 指引；
    3) 提供离线 PASS/FAIL 回归断言。
  - 验证：`./scripts/test-install-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R6-T04（BDD）升级脚本 v1（保留配置）
  - 文件：`scripts/upgrade.sh`、`scripts/test-upgrade-local.sh`
  - 验收：
    1) 支持升级二进制并保留配置目录；
    2) 升级前后版本可观测（before/after）；
    3) 异常路径输出 `next:` 提示。
  - 验证：`./scripts/test-upgrade-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R6-T05（串行）R6 第一批回归入口与 CI 对齐
  - 文件：`Makefile`、`scripts/test-r6-release-suite.sh`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) 本地统一入口：`make r6-release-regression`（覆盖 T01~T04）；
    2) PASS/FAIL 判定：exit code + `[r6-release-suite] PASS/FAIL`；
    3) CI 复用同一入口命令（`make r6-release-regression`）。
  - 验证：`make r6-release-regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R6-T06（并行预拆）R6 第一批收口与 R7 启动草案
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 已给出 R6 第一批收口判据与 done/remaining 结论（close-ready）；
    2) 预拆 R7 第一批 5 个原子任务（R7-T01~R7-T05）；
    3) 唯一 NEXT 已切换到 R7-T01。

- [x] R7-T01（TDD）安装路径探测与冲突检查
  - 文件：`scripts/install.sh`、`scripts/test-install-path-conflict.sh`
  - 验收：
    1) 安装前检测目标路径冲突（文件/目录/权限）；
    2) 冲突场景输出 `next:` 指引；
    3) 增加离线 PASS/FAIL 回归断言。
  - 验证：`./scripts/test-install-path-conflict.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R7-T02（BDD）升级回滚最小机制（失败可回退）
  - 文件：`scripts/upgrade.sh`、`scripts/test-upgrade-local.sh`
  - 验收：
    1) 升级前备份旧二进制（`lan.bak`）；
    2) 升级失败自动回滚到旧二进制；
    3) 输出回滚结果与 `next:` 提示。
  - 验证：`./scripts/test-upgrade-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R7-T03（TDD）发布产物校验清单（checksum + manifest）
  - 文件：`scripts/package-release.sh`、`scripts/verify-package.sh`、`scripts/test-package-release.sh`
  - 验收：
    1) 打包时输出 checksum 与 manifest；
    2) 提供离线校验脚本（`verify-package.sh`）并 PASS/FAIL；
    3) 校验失败路径输出 `next:` 提示。
  - 验证：`./scripts/test-package-release.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R7-T04（并行，BDD）安装/升级日志标准化（机器可解析）
  - 文件：`scripts/install.sh`、`scripts/upgrade.sh`、`scripts/parse-install-upgrade-log-sample.sh`、`scripts/test-install-local.sh`、`scripts/test-upgrade-local.sh`
  - 验收：
    1) 固定日志字段：`phase/action/target/result/reason/duration_ms`；
    2) 提供解析样例与 PASS/FAIL 断言；
    3) 与 route/tool_event 风格一致（`install_event key=value ...`）。
  - 验证：`./scripts/parse-install-upgrade-log-sample.sh` / `zig build` / `zig build test` / `make smoke` / `scripts/test-install-local.sh` / `scripts/test-upgrade-local.sh` 通过。

- [x] R7-T05（串行）R7 第一批回归入口与 CI 对齐
  - 文件：`Makefile`、`scripts/test-r7-install-upgrade-suite.sh`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) 本地统一入口：`make r7-install-upgrade-regression`（覆盖 R7-T01~R7-T04）；
    2) PASS/FAIL 判定：exit code + `[r7-install-upgrade-suite] PASS/FAIL`；
    3) CI 复用同一入口命令（`make r7-install-upgrade-regression`）。
  - 验证：`make r7-install-upgrade-regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R7-T06（并行预拆）R7 第一批收口与 R8 启动草案
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 已给出 R7 第一批收口判据与 done/remaining 结论（close-ready）；
    2) 预拆 R8 第一批 5 个原子任务（R8-T01~R8-T05）；
    3) 唯一 NEXT 已切换到 R8-T01。

- [x] R8-T01（TDD）安装器平台探测与默认路径策略
  - 文件：`scripts/install.sh`、`scripts/test-install-platform-path.sh`、`scripts/test-install-path-conflict.sh`
  - 验收：
    1) 自动识别平台并选择默认安装路径（macOS: `~/bin`, Linux: `~/.local/bin`）；
    2) 路径冲突与权限不足仍输出 `next:` 提示；
    3) 新增离线 PASS/FAIL 回归脚本覆盖平台默认路径与冲突场景。
  - 验证：`./scripts/test-install-platform-path.sh` / `./scripts/test-install-path-conflict.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R8-T02（并行，BDD）升级脚本回滚日志与校验增强
  - 文件：`scripts/upgrade.sh`、`scripts/test-upgrade-local.sh`、`scripts/parse-install-upgrade-log-sample.sh`
  - 验收：
    1) 回滚路径输出结构化日志（phase/action/result/reason/duration_ms）；
    2) 升级前后二进制可执行性校验；
    3) 失败路径输出明确 `next:`。
  - 验证：`./scripts/parse-install-upgrade-log-sample.sh` / `./scripts/test-upgrade-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R8-T03（BDD）安装前预检脚本（env/path/permissions）
  - 文件：`scripts/preflight.sh`、`scripts/test-preflight.sh`、`scripts/install.sh`、`scripts/upgrade.sh`
  - 验收：
    1) 预检 shell、目标路径、写权限、sha 工具可用性；
    2) 预检输出 PASS/FAIL + next-step；
    3) install/upgrade 入口已接入 preflight 校验。
  - 验证：`./scripts/test-preflight.sh` / `./scripts/test-install-local.sh` / `./scripts/test-upgrade-local.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R8-T04（TDD）最小变更日志生成（release notes stub）
  - 文件：`scripts/release-notes.sh`、`scripts/test-release-notes.sh`
  - 验收：
    1) 基于 git log 生成简版发布说明；
    2) 输出包含 New/Fixes/Known Issues 模板；
    3) 全流程离线可运行。
  - 验证：`./scripts/test-release-notes.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R8-T05（串行）R8 第一批回归入口与 CI 对齐
  - 文件：`Makefile`、`scripts/test-r8-release-experience-suite.sh`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) 本地统一入口：`make r8-release-experience-regression`（覆盖 R8-T01~R8-T04）；
    2) PASS/FAIL 判定：exit code + `[r8-release-experience-suite] PASS/FAIL`；
    3) CI 复用同一入口命令（`make r8-release-experience-regression`）。
  - 验证：`make r8-release-experience-regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R8-T06（并行预拆）R8 第一批收口与 R9 启动草案
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 已给出 R8 第一批收口判据与 done/remaining 结论（close-ready）；
    2) 预拆 R9 第一批 5 个原子任务（R9-T01~R9-T05）；
    3) 唯一 NEXT 已切换到 R9-T01。

- [x] R9-T01（TDD）预检结果结构化输出（JSON + 文本双通道）
  - 文件：`scripts/preflight.sh`、`scripts/test-preflight.sh`、`scripts/test-preflight-json.sh`
  - 验收：
    1) `preflight --json` 输出稳定字段（ok/reason/target/next）；
    2) 失败时文本输出保留 `next-step`；
    3) JSON 与文本语义一致（同 reason/next）。
  - 验证：`./scripts/test-preflight.sh` / `./scripts/test-preflight-json.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R9-T02（并行，BDD）发布说明模板参数化（版本/日期/commit 注入）
  - 文件：`scripts/release-notes.sh`、`scripts/test-release-notes.sh`
  - 验收：
    1) release notes stub 支持版本/日期/commit 参数注入；
    2) 模板缺参时输出明确 FAIL + `next:`；
    3) 输出格式与现有发布流程兼容。
  - 验证：`./scripts/test-release-notes.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R9-T03（TDD）离线诊断打包（support bundle stub）
  - 文件：`scripts/support-bundle.sh`、`scripts/test-support-bundle.sh`
  - 验收：
    1) 打包版本信息、配置摘要（脱敏）、最近日志；
    2) 产物命名包含时间戳+平台；
    3) 离线可运行。
  - 验证：`./scripts/test-support-bundle.sh` / `./scripts/support-bundle.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R9-T04（并行，BDD）运维文档最小闭环（故障排查清单）
  - 文件：`README.md`、`docs/ops/troubleshooting.md`
  - 验收：
    1) 文档新增 install/upgrade/verify/preflight 故障清单；
    2) 每类故障提供 next-step；
    3) 文档口径与脚本输出一致。
  - 验证：`./scripts/preflight.sh --json "$HOME/.local/bin"` / `./scripts/verify-package.sh dist/lan-0.1.0-macos-arm64.tar.gz` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R9-T05（串行）R9 第一批回归入口与 CI 对齐
  - 文件：`Makefile`、`scripts/test-r9-ops-readiness-suite.sh`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) 本地统一入口：`make r9-ops-readiness-regression`（覆盖 R9-T01~R9-T04）；
    2) PASS/FAIL 判定：exit code + `[r9-ops-readiness-suite] PASS/FAIL`；
    3) CI 复用同一入口命令（`make r9-ops-readiness-regression`）。
  - 验证：`make r9-ops-readiness-regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R9-T06（收口）R9 第一批收口与 R10 启动拆解
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 已给出 R9 第一批 done/remaining 收口结论（close-ready）；
    2) 预拆 R10 第一批 5 个原子任务（含依赖与串并行关系）；
    3) 唯一 NEXT 切换到 R10-T01。

- [x] R10-T01（并行）Beta 准入清单执行脚本（checklist runner）
  - 文件：`scripts/check-beta-readiness.sh`、`scripts/test-beta-readiness-check.sh`、`docs/beta-checklist.md`
  - 验收：
    1) 按条检查 Beta 清单项并输出 PASS/FAIL；
    2) 失败输出包含失败项与 `next:`；
    3) 与 `docs/beta-checklist.md`（映射 `docs/release/beta-entry-checklist.md`）口径一致。
  - 验证：`./scripts/test-beta-readiness-check.sh` 通过。

- [x] R10-T02（并行）Beta 候选一键验证入口（聚合 install/verify/preflight）
  - 文件：`scripts/verify-beta-candidate.sh`、`scripts/test-verify-beta-candidate.sh`、`README.md`、`docs/TASKS.md`
  - 验收：
    1) 单命令执行 verify/preflight/install 聚合核验；
    2) 输出统一 PASS/FAIL + 失败 `next:` 提示；
    3) README/TASKS 补充使用说明。
  - 验证：`./scripts/test-verify-beta-candidate.sh` 通过。

- [x] R10-T03（TDD）发布后健康检查脚本（post-install health）
  - 文件：`scripts/post-install-health.sh`、`scripts/test-post-install-health.sh`、`docs/TASKS.md`
  - 验收：
    1) 覆盖版本可读、核心命令可执行、基础依赖可用；
    2) 输出统一 PASS/FAIL + `next:`；
    3) 支持离线执行。
  - 验证：`./scripts/test-post-install-health.sh` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R10-T04（并行）Beta 候选验收报告模板（人话版）
  - 文件：`docs/release/beta-acceptance-report-template.md`、`docs/release/beta-entry-checklist.md`
  - 验收：
    1) 模板固定“通过项/失败项/next-step/是否可试用”；
    2) 与 beta checklist 与一键验证入口口径一致。

- [x] R10-T05（串行）Beta 候选一键验收总入口（整合 checklist/verify/health/report）
  - 文件：`scripts/run-beta-acceptance.sh`、`scripts/test-run-beta-acceptance.sh`、`Makefile`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) 单入口串联 checklist runner + beta verify + post-install health + acceptance report；
    2) 输出统一 PASS/FAIL + 失败 `next:`；
    3) CI 复用同一入口命令（`make r10-beta-acceptance-regression`）。
  - 验证：`./scripts/test-run-beta-acceptance.sh` / `make r10-beta-acceptance-regression` 通过。

- [x] R10-T06（收口）R10 第一批收口与 R11 启动拆解
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 已输出 R10 第一批 done/remaining 收口结论（close-ready）；
    2) 预拆 R11 第一批 5 个原子任务（范围+DoD+预计时长+依赖）；
    3) 唯一 NEXT 切换到 R11-T01。

- [x] R11-T01（并行，TDD）Beta 验收结果快照脚本
  - 文件：`scripts/snapshot-beta-acceptance.sh`、`scripts/test-snapshot-beta-acceptance.sh`
  - 验收：
    1) 生成本轮 Beta 验收快照（通过项/失败项/next-step）；
    2) 输出机读结果（`results.jsonl`）+ 人类摘要（`summary.txt`）；
    3) 与 beta 验收入口口径一致（checklist/verify/health/acceptance）。
  - 验证：`./scripts/test-snapshot-beta-acceptance.sh` 通过。

- [x] R11-T02（并行，BDD）试用反馈模板（问题分级+复现信息）
  - 文件：`docs/release/beta-feedback-template.md`、`docs/release/beta-trial-runbook.md`
  - 验收：
    1) 模板覆盖严重级别/复现步骤/环境信息；
    2) 提供可直接复制版本用于收集反馈；
    3) 字段与 runbook 一致（severity/environment/repro/evidence/next_step/triage）。

- [x] R11-T03（并行，TDD）Beta 回滚演练脚本
  - 文件：`scripts/rehearse-beta-rollback.sh`、`scripts/test-rehearse-beta-rollback.sh`
  - 验收：
    1) 提供最小回滚演练脚本，覆盖 success/fail 分支；
    2) 输出统一 PASS/FAIL + next-step；
    3) 离线可运行。
  - 验证：`./scripts/test-rehearse-beta-rollback.sh` 通过。

- [x] R11-T04（并行，BDD）Beta 试用 runbook（最小版）
  - 文件：`docs/release/beta-trial-runbook.md`
  - 验收：
    1) 人话说明试用流程（安装→验证→反馈）；
    2) 每步包含命令与期望输出；
    3) 常见失败给出 next-step。

- [x] R11-T05（串行）R11 第一批回归入口与 CI 对齐
  - 文件：`Makefile`、`scripts/test-r11-beta-trial-suite.sh`、`.github/workflows/ci.yml`、`docs/TASKS.md`
  - 验收：
    1) 本地统一入口：`make r11-beta-trial-regression`（覆盖 R11-T01~R11-T04）；
    2) PASS/FAIL 判定：exit code + `[r11-beta-trial-suite] PASS/FAIL`；
    3) CI 复用同一入口命令（`make r11-beta-trial-regression`）。
  - 验证：`make r11-beta-trial-regression` / `zig build` / `zig build test` / `make smoke` 通过。

- [x] R11-T06（收口）R11 第一批收口与 R12 启动拆解
  - 文件：`docs/TASKS.md`
  - 结果：
    1) 已输出 R11 第一批 done/remaining 收口结论（close-ready）；
    2) 预拆 R12 第一批 5 个原子任务（范围+DoD+预计时长+依赖）；
    3) 唯一 NEXT 切换到 R12-T01。

- [x] R11-Prep-A（并行）里程碑估时口径修正（小时优先）并落文档
  - 文件：`docs/ROADMAP.md`
  - 结果：
    1) 增加“剩余≤2任务按小时估时”规则；
    2) 增加正常/重跑两档示例；
    3) 口径与 #overview 模板字段对齐（样本/平均/P50/P90）。

- [x] R12-A（并行）Beta 候选安装后健康检查增强（覆盖异常分支）
  - 文件：`scripts/post-install-health.sh`、`scripts/test-post-install-health.sh`
  - 验收：
    1) 扩展覆盖至少 2 个失败分支（missing binary / version mismatch）；
    2) 统一 PASS/FAIL + next-step 输出；
    3) 更新验收脚本断言并通过。
  - 验证：`./scripts/test-post-install-health.sh` / `./scripts/post-install-health.sh ./zig-out/bin/lan` 通过。

- [x] R12-B（并行）Beta 验收快照与报告模板对齐检查
  - 文件：`scripts/snapshot-beta-acceptance.sh`、`scripts/test-snapshot-beta-acceptance.sh`、`docs/release/beta-acceptance-report-template.md`、`README.md`
  - 验收：
    1) 快照字段与报告模板逐项对齐；
    2) 缺失字段通过 `report-mapping.json` 补齐兼容映射；
    3) README/TASKS 补充人话说明。
  - 验证：`./scripts/test-snapshot-beta-acceptance.sh` 通过。

- [x] R12-C（并行）Beta 试用 runbook 命令自检脚本
  - 文件：`scripts/check-beta-runbook-commands.sh`、`scripts/test-check-beta-runbook-commands.sh`、`docs/release/beta-trial-runbook.md`
  - 验收：
    1) 提供 runbook 关键命令一键自检脚本；
    2) 输出通过率与失败命令清单；
    3) 失败输出 `next:` 修复建议。
  - 验证：`./scripts/test-check-beta-runbook-commands.sh` 通过。

- [x] R12-D（串行）R12 第一批回归入口与 CI 对齐预留
  - 文件：`scripts/test-r12-beta-trial-ops-suite.sh`、`Makefile`、`docs/TASKS.md`
  - 验收：
    1) 预定义回归入口命令骨架：`make r12-beta-trial-ops-regression`；
    2) PASS/FAIL 判定与日志标记：`[r12-beta-trial-ops-suite] PASS/FAIL ...`；
    3) TASKS 依赖顺序写清（R12-T01~T04 → R12-T05）。
  - 验证：`./scripts/test-r12-beta-trial-ops-suite.sh` / `make r12-beta-trial-ops-regression` 通过。

- [x] R12-T01（并行，TDD）Beta 试用环境自检脚本（trial precheck）
  - 文件：`scripts/trial-precheck.sh`、`scripts/test-trial-precheck.sh`
  - 验收：
    1) 一键自检覆盖环境/路径/基础依赖；
    2) 输出统一 PASS/FAIL + next-step；
    3) 机读字段（json lines）与人类摘要（summary）并存。
  - 验证：`./scripts/test-trial-precheck.sh` 通过。

- [x] R12-T02（并行，BDD）Beta 试用登记表模板（批次/设备/状态）
  - 文件：`docs/release/beta-trial-tracker-template.md`
  - 验收：
    1) 提供可直接填报模板（批次/设备/执行状态/问题等级）；
    2) 字段与反馈模板一致（severity/环境信息/状态）；
    3) 文档人话可读。

- [x] R12-T03（并行，TDD）Beta 试用结果汇总脚本（summary generator）
  - 文件：`scripts/summarize-beta-trial.sh`、`scripts/test-summarize-beta-trial.sh`
  - 验收：
    1) 汇总通过率/失败项/待处理项；
    2) 输出统一报告（机读 json + 人读 text）；
    3) 失败项附 `next-step`。
  - 验证：`./scripts/test-summarize-beta-trial.sh` 通过。

- [x] R12-T04（并行，BDD）Beta 风险清单（go/no-go）模板
  - 文件：`docs/release/beta-go-no-go-template.md`
  - 验收：
    1) 模板包含 go/no-go 判定条件；
    2) 风险项包含 owner/mitigation action/due time；
    3) 与试用汇总脚本口径一致（pass_rate/failed_items/pending_items）。

- [x] R10-Prep-A（并行预拆）Beta 准入清单文档化（人话版）
  - 文件：`docs/release/beta-entry-checklist.md`、`docs/ROADMAP.md`
  - 验收：
    1) 新增 Beta 准入清单（能力/回归/稳定性/发布支持）；
    2) 每项包含“验收命令 + 证据路径”；
    3) 与 ROADMAP 的 MVP→Beta→1.0 口径一致。

- [x] R10-Prep-B（并行）Beta 候选打包与验证说明（人话版）
  - 文件：`docs/release/beta-candidate-install-verify.md`、`docs/release/beta-entry-checklist.md`
  - 验收：
    1) 增加试用者视角安装/验证说明；
    2) 命令示例覆盖 install/verify/preflight；
    3) 与脚本输出口径一致。

## Blocked
- 暂无（如出现请写：阻塞原因/影响范围/预计解除时间）

## Next Up
1. 立即执行 R12-T05（NEXT）：R12 第一批回归入口与 CI 对齐

## 更新约定（强制）
- 每次代码改动后，若任务状态变化，必须同步更新本文件
- 状态仅允许：`In Progress / Done / Blocked / Next Up`
- 每个任务至少写：目标、当前状态、下一步
