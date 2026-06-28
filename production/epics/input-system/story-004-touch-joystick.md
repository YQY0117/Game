# Story 004: Touch Joystick & Multi-Finger

> **Epic**: Input System
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/input-system.md`
**Requirement**: TR-INPUT-002 (三类设备并行监听)

**ADR**: N/A — 触屏输入处理
**Engine**: Godot 4.6 | **Risk**: LOW (4.6 双焦点系统需注意)

---

## Acceptance Criteria

- [ ] AC-06: 首指落地成为摇杆中心，第二指移动不影响 move_vector；首指释放 100ms 后下次触摸重置中心

---

## Implementation Notes

- 浮动中心: 首次 `InputEventScreenTouch.pressed` 位置即摇杆圆心
- 多指过滤: 跟踪 `touch_index`，只处理首指
- 释放重置: 首指释放后 100ms 计时器，超时后下次触摸设新中心
- 命中区: 屏幕左半部分

---

## Out of Scope

- Story 003: 死区曲线
- Story 005: 焦点丢失

---

## QA Test Cases

- **AC-6**: 浮动摇杆 + 多指
  - Given: active_mode == "touch"
  - When: 首指在左半屏落地，第二指移动
  - Then: 只有首指影响 move_vector

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/touch_joystick_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 003
- Unlocks: Story 005
