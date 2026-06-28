# Story 004: State Machine & Collision

> **Epic**: Player Controller
> **Status**: In Progress
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/player-controller.md`
**Requirement**: TR-PC-006, TR-PC-007, TR-PC-010, TR-PC-011

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-PC-09: hitstun 期间收到 immobile → 立即切到 immobile，后续 knockback 被忽略
- [ ] AC-PC-10: HP=0 → immobile + velocity=(0,0)，仅 teleport_to() 可用
- [ ] AC-PC-11: 外部直接写 position 被拒绝/回退
- [ ] AC-PC-12: PC 与敌人不碰撞（敌人是 trigger）
- [ ] AC-PC-13: 墙壁滑动，不卡顿

---

## Implementation Notes

- 4 状态: idle / running / hitstun / immobile
- 优先级: immobile > hitstun > running > idle
- collision_layer: PC=1, World=1, Enemy=2 (不与 PC 碰撞)
- teleport_to() 重置 velocity + 状态

---

## Out of Scope

- Story 003: 击退
- Story 005: 性能

---

## QA Test Cases

- **AC-PC-09**: 状态优先级
  - Given: PC hitstun
  - When: set_immobile(true)
  - Then: 立即切到 immobile

- **AC-PC-12**: 敌人穿透
  - Given: PC running 向敌人
  - When: hitbox 重叠
  - Then: PC 穿过，无碰撞响应

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/player_controller/state_collision_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 003
- Unlocks: Story 005
