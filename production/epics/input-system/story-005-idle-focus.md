# Story 005: Idle Detection & Focus Loss

> **Epic**: Input System
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/input-system.md`
**Requirement**: TR-INPUT-006 (无悬停依赖)

**ADR**: N/A — 浏览器集成
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-07: move_vector 连续输出零向量 ≥50ms 时 emit input_idle 一次
- [ ] AC-11: 浏览器标签失焦时所有键状态设为 released，move_vector = (0,0)
- [ ] AC-12: InputManager 在 breakthrough_ritual 状态仍 emit pause（由下游 PauseManager 过滤）

---

## Implementation Notes

- 空闲检测: 50ms 计时器，零向量时递增，非零时重置
- 焦点丢失: 监听 `NOTIFICATION_APPLICATION_FOCUS_OUT`，重置所有键状态
- Pause 不做过滤: Input System 只负责翻译，不包含业务逻辑

---

## Out of Scope

- Story 004: 触屏摇杆
- Story 006: Force Mode

---

## QA Test Cases

- **AC-7**: 空闲检测
  - Given: move_vector != 0
  - When: 连续 50ms 输出零向量
  - Then: emit input_idle 一次

- **AC-11**: 焦点丢失
  - Given: 键盘按键按下
  - When: 浏览器标签失焦
  - Then: move_vector = (0,0)，无卡键

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/idle_focus_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 004
- Unlocks: Story 006
