# Story 002: Realm Speed & Clearance

> **Epic**: Player Controller
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/player-controller.md`
**Requirement**: TR-PC-003, TR-PC-008

**ADR**: N/A — 纯公式
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-PC-05: 境界速度表 R1=88, R2=100, R3=109, R4=116, R5=121, R6=124 (±1 px/s)
- [ ] AC-PC-14: clearance_radius R1=16, R2=22.4, R3=32, R4=41.6, R5=52.8, R6=64 px

---

## Implementation Notes

- base_speed(R) = 88 + (124-88) × log(1+1.8×(R-1)) / log(1+1.8×5)
- clearance_radius = 32 × multiplier (F4 离散表)
- realm_transitioned 信号触发速度更新

---

## Out of Scope

- Story 001: 移动核心
- Story 003: 击退

---

## QA Test Cases

- **AC-PC-05**: 境界速度
  - Given: PC @ R1-R6
  - When: 测量 base_speed
  - Then: 匹配表格 ±1 px/s

- **AC-PC-14**: clearance 半径
  - Given: PC @ R1-R6
  - When: 查询 clearance_radius
  - Then: R1=16, R6=64

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/player_controller/realm_speed_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
