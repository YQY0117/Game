# Story 003: Dead Zones & Response Curves

> **Epic**: Input System
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/input-system.md`
**Requirement**: TR-INPUT-005 (死区与平滑)

**ADR**: N/A — 纯数学公式
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-03: Touch 死区 0.10，Gamepad 死区 0.15。magnitude 0.08/0.12 输出 (0,0)；0.20 输出非零向量

---

## Implementation Notes

- Formula: `m = clamp((|raw| - DEAD_ZONE) / (1 - DEAD_ZONE), 0, 1)`
- Touch: `output = raw.normalized() * pow(m, 1.5)` (非线性)
- Gamepad: `output = raw.normalized() * pow(m, 1.0)` (线性)
- 死区值可从 `data/input_config.json` 覆盖

---

## Out of Scope

- Story 002: 模式切换
- Story 004: 触屏摇杆

---

## QA Test Cases

- **AC-3**: 死区生效
  - Given: active_mode == "touch" (deadzone 0.10)
  - When: stick magnitude = 0.08
  - Then: 输出 (0,0)

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/deadzone_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 004
