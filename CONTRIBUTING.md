# Contributing

## Prerequisites
- Zig 0.15.x (`brew install zig` on macOS, `snap install zig --classic` on Ubuntu)

## Local Development

### Build & Test
```bash
zig build          # compile
zig build test     # unit tests
make smoke         # smoke test (build + boot + exit + history check)
make regression    # full regression suite
```

### Format
```bash
zig fmt src/       # auto-format
zig fmt --check src/  # CI uses this — check before committing
```

### Regression Suites (by round)
```bash
make r4-skill-regression
make r5-routing-regression
make r6-release-regression
make r7-install-upgrade-regression
make r8-release-experience-regression
make r9-ops-readiness-regression
make r10-beta-acceptance-regression
make r11-beta-trial-regression
make r12-beta-trial-execution-regression
make r13-beta-trial-ops-regression
make r14-beta-launch-regression
```

## Commit Message Convention

Use [Conventional Commits](https://www.conventionalcommits.org/) prefixes:

| Prefix | Usage |
|--------|-------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `ci` | CI/CD changes |
| `build` | Build system / dependencies |
| `refactor` | Code restructuring (no behavior change) |
| `test` | Adding or updating tests |
| `revert` | Reverting a previous commit |

Examples:
```
feat(skill): add manifest validation for skill entries
fix(tui): handle empty input on multi-line edit
docs(roadmap): update Beta exit conditions
ci(release): add cross-platform build matrix
```

## PR Flow

1. Fork / create branch from `main`
2. Make changes — keep commits atomic (one logical change per commit)
3. Ensure all local checks pass: `zig fmt --check src/ && zig build test && make smoke`
4. Push and open PR against `main`
5. PR title should follow commit convention (e.g., `feat(skill): ...`)
6. CI runs automatically — all checks must pass before merge

## Code Style

- Follow Zig standard style (enforced by `zig fmt`)
- Keep functions small and focused
- Errors should include actionable `next-step` guidance
- Structured log output: `[component] PASS/FAIL key=value`
