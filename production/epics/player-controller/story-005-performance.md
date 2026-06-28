# Story 005: Performance & Signals

> **Epic**: Player Controller
> **Status**: In Progress
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/player-controller.md`
**Requirement**: TR-PC-011

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-PC-16: 对角位移 guard，60fps 和 15fps 下 |Δposition| ≤ expected × delta + 0.5px
- [ ] AC-PC-17: 查询 API (is_moving, movement_intensity, is_in_knockback) 正确
- [ ] AC-PC-19: _physics_process ≤ 0.5ms/frame @ 60fps
- [ ] AC-PC-20: Chrome/Firefox/Safari 位置差异 ≤2px

---

## Implementation Notes

- 信号: position_changed, velocity_changed, state_changed, realm_transitioned
- movement_intensity = current_speed / base_speed，范围 [0.0, 1.0]
- 对角归一化: Input.get_vector() 自动处理
- 性能: 避免每帧分配，缓存引用

---

## Out of Scope

- Story 004: 状态机

---

## QA Test Cases

- **AC-PC-19**: 性能预算
  - Given: 8 敌人场景
  - When: PC 持续移动 60s
  - Then: _physics_process ≤ 0.5ms/frame

- **AC-PC-20**: 跨浏览器
  - Given: 相同输入录制
  - When: Chrome/Firefox/Safari 执行
  - Then: 最终位置差异 ≤2px

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/player_controller/perf_signals_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 004
- Unlocks: None (Epic complete)
