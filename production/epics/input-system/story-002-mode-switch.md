# Story 002: Mode Switch Hysteresis

> **Epic**: Input System
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/input-system.md`
**Requirement**: TR-INPUT-003 (滞后切换)

**ADR**: N/A — 纯逻辑实现，无架构模式
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-02: Touch 产生 3 个连续 touch_down (400ms 内) 或单个 touch_down 持续 ≥400ms 时，active_mode 切换到 "touch" 并 emit input_mode_changed(touch)

---

## Implementation Notes

- 维护 `consecutive_events_count` 和 `continuous_duration_ms` 计数器
- 每次同设备类型事件重置计数器，不同设备类型归零
- Touch 模式额外 +200ms 冷却（防误触）
- 切换后 emit `input_mode_changed(new_mode)` 信号

---

## Out of Scope

- Story 001: 语义动作映射
- Story 003: 死区和平滑

---

## QA Test Cases

- **AC-2**: 模式切换滞后
  - Given: active_mode == "kbm"
  - When: Touch 产生 3 个连续 touch_down (400ms 内)
  - Then: active_mode 切换到 "touch"，emit input_mode_changed(touch)

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/mode_switch_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
