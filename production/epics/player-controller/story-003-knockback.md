# Story 003: Knockback & Hitstun

> **Epic**: Player Controller
> **Status**: In Progress
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/player-controller.md`
**Requirement**: TR-PC-005

**ADR Governing Implementation**: ADR-0001: Event Bus
**ADR Decision Summary**: DamageBus 信号驱动击退

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-PC-06: apply_knockback(方向, force=240, duration=0.25)，peak velocity ≈240 px/s，二次衰减到 0
- [ ] AC-PC-07: 新击退覆盖旧击退，不叠加
- [ ] AC-PC-08: 同帧两个击退，max force 胜出

---

## Implementation Notes

- apply_knockback() 由 Damage System 调用
- 击退期间进入 hitstun 状态，玩家输入无效
- 击退曲线: v(t) = force × (1 - (t/duration)²)
- 新击退直接替换旧击退（不叠加）

---

## Out of Scope

- Story 002: 境界速度
- Story 004: 状态机

---

## QA Test Cases

- **AC-PC-06**: 击退 API
  - Given: PC running
  - When: apply_knockback((1,0), 240, 0.25)
  - Then: peak velocity ≈240，0.25s 后归零

- **AC-PC-07**: 击退覆盖
  - Given: PC hitstun (force=150, t=0.1s)
  - When: 新 knockback force=360
  - Then: 旧击退被替换

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/player_controller/knockback_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 002
- Unlocks: Story 004
