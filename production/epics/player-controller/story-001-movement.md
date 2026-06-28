# Story 001: Movement Core

> **Epic**: Player Controller
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/player-controller.md`
**Requirement**: TR-PC-001, TR-PC-002, TR-PC-009

**ADR**: N/A — CharacterBody2D 移动逻辑，无架构模式
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-PC-01: R1 idle，按右 1.0s，位移 = 88 × (1.0 - 0.060/2) ± 0.5px
- [ ] AC-PC-02: 启动缓动 60ms cubic ease-out，50% @ 30ms，90% @ 48ms
- [ ] AC-PC-03: 停止缓动 30ms ease-in quad，无过冲，残余 <0.5px
- [ ] AC-PC-04: 反向输入 ≤90ms 翻转，无滑行，无冲刺

---

## Implementation Notes

- CharacterBody2D + move_and_slide()
- _physics_process(delta) 中处理移动
- 启动缓动: v(t) = v_target × (1 - (1 - t/T_start)³)
- 停止缓动: v(t) = v_initial × (1 - (t/T_stop)²)
- delta-time 弹性: 位移 = velocity × delta

---

## Out of Scope

- Story 002: 境界速度
- Story 003: 击退

---

## QA Test Cases

- **AC-PC-01**: 输入到速度确定性
  - Given: PC idle @ R1 (base_speed=88)
  - When: 按右 1.0s
  - Then: 位移 ≈ 88px，velocity = (88, 0) ± 0.1

- **AC-PC-02**: 启动缓动
  - Given: PC idle
  - When: 按方向
  - Then: 50% @ 30ms，90% @ 48ms，100% @ 60ms

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/player_controller/movement_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
