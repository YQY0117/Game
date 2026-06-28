# Story 001: Full Regression Test

> **Epic**: QA
> **Status**: In Progress
> **Layer**: Release
> **Type**: QA
> **Estimate**: 4h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: All GDDs
**Requirement**: TR-QA-001

**ADR**: N/A — QA 测试
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 所有 AC 回归测试通过
- [ ] 无 S1/S2 级别 bug
- [ ] 测试报告生成

---

## Implementation Notes

- 运行所有单元测试
- 运行所有集成测试
- 手动测试核心功能
- 生成测试报告

---

## Out of Scope

- 无（QA 覆盖全系统）

---

## QA Test Cases

- **AC-1**: 回归测试
  - Given: 所有测试用例
  - When: 执行回归测试
  - Then: 全部通过

---

## Test Evidence

**Story Type**: QA
**Required evidence**: `production/qa/evidence/regression-report.md`
**Status**: [x] Created

---

## Dependencies

- Depends on: All systems
- Unlocks: Story 002