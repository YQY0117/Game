# Sprint 6 — 2026-09-08 to 2026-09-19

## Sprint Goal

Release 层：最终测试 + Web导出打包 + 部署准备，完成游戏发布。

## Capacity

- Total days: 10
- Buffer (20%): 2 days
- Available: 8 days

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S6-001 | QA: Full Regression Test | qa-tester | 0.5 | All | 所有AC回归通过 |
| S6-002 | Build: Web Export | devops-engineer | 0.5 | All | 50MB包+60fps |
| S6-003 | QA: Smoke Test | qa-tester | 0.5 | S6-002 | 核心功能正常 |
| S6-004 | Release: Version Bump | release-manager | 0.5 | S6-002 | 版本号更新 |
| S6-005 | Release: Changelog | release-manager | 0.5 | All | 变更日志生成 |

**Subtotal**: 2.5 days

### Should Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S6-006 | Polish: Performance Profiling | technical-artist | 0.5 | S6-002 | 性能分析报告 |
| S6-007 | Polish: Memory Leak Check | technical-artist | 0.5 | S6-002 | 无内存泄漏 |
| S6-008 | QA: Accessibility Test | qa-tester | 0.5 | S6-002 | 无障碍通过 |
| S6-009 | Release: Store Metadata | release-manager | 0.5 | S6-004 | 商店描述准备 |

**Subtotal**: 2.0 days

### Nice to Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S6-010 | Polish: Final Bug Fixes | gameplay-programmer | 0.5 | S6-001 | 已知bug修复 |
| S6-011 | Release: Trailer | marketing | 0.5 | S6-002 | 预告片制作 |
| S6-012 | Release: Press Kit | marketing | 0.5 | S6-002 | 媒体资料包 |

**Subtotal**: 1.5 days

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Web导出性能不达标 | Medium | High | 优化+降级 |
| 回归测试发现阻断bug | Low | High | 预留buffer |

## Definition of Done

- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/qa-plan-sprint-6.md`)
- [ ] All Logic stories have passing unit tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] No S1 or S2 bugs in delivered features
- [ ] Web build ≤ 50MB
- [ ] 60fps on target devices

## Release Checklist

- [ ] Version bumped to 1.0.0
- [ ] Changelog generated
- [ ] Store metadata ready
- [ ] Press kit prepared
- [ ] Trailer recorded