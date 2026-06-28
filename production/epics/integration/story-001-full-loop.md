# Story 001: Full Game Loop Integration Test

> **Epic**: Integration
> **Status**: In Progress
> **Layer**: Polish
> **Type**: Integration
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: All GDDs
**Requirement**: TR-INT-001

**ADR**: N/A — 集成测试
**Engine**: Godot 4.6 | **Risk**: MEDIUM

---

## Acceptance Criteria

- [ ] 完整游戏循环: menu → loading → playing → BOSS战 → 突破 → victory
- [ ] 所有系统协同工作: Input → Player → Camera → Enemy → Technique → HUD
- [ ] 无崩溃、无卡死、无内存泄漏

---

## Implementation Notes

- 集成测试脚本模拟完整游戏流程
- 验证每个状态转换正确
- 检查信号链路完整

---

## Out of Scope

- 无（集成测试覆盖全系统）

---

## QA Test Cases

- **AC-1**: 完整循环
  - Given: 游戏启动
  - When: 执行完整游戏循环
  - Then: 无崩溃，状态正确转换

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/full_loop_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: All systems
- Unlocks: None