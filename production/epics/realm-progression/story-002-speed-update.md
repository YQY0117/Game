# Story 002: Realm Speed Update

> **Epic**: Realm Progression
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/realm-progression.md`
**Requirement**: TR-REALM-007

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 境界突破时 PlayerController.set_realm(new_realm) 同步调用
- [ ] 速度公式: base_speed(R) = 88 + (124-88) × log(1+1.8×(R-1)) / log(1+1.8×5)
- [ ] 境界速度表 R1=88, R2=100, R3=109, R4=116, R5=121, R6=124 (±1 px/s)

---

## Implementation Notes

- RealmProgression 监听 realm_changed 信号
- 调用 PlayerController.set_realm(new_realm)
- PlayerController 内部更新 _base_speed

---

## Out of Scope

- Story 001: 突破仪式
- Story 003: 动画优化

---

## QA Test Cases

- **AC-1**: 速度同步
  - Given: PC @ R1 (88 px/s)
  - When: 境界突破到 R2
  - Then: PC.base_speed ≈ 100 px/s

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/realm/speed_update_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None