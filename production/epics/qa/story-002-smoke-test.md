# Story 002: Smoke Test

> **Epic**: QA
> **Status**: In Progress
> **Layer**: Release
> **Type**: QA
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: All GDDs
**Requirement**: TR-QA-002

**ADR**: N/A — QA 测试
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 核心功能正常: 移动、攻击、受伤、突破
- [ ] 无崩溃、无卡死
- [ ] Smoke test 报告生成

---

## Implementation Notes

- 手动测试核心功能
- 验证关键路径
- 生成 smoke test 报告

---

## Out of Scope

- Story 001: 全回归测试

---

## QA Test Cases

- **AC-1**: 核心功能
  - Given: Web 构建
  - When: 执行 smoke test
  - Then: 核心功能正常

---

## Test Evidence

**Story Type**: QA
**Required evidence**: `production/qa/evidence/smoke-test-report.md`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 002
- Unlocks: None