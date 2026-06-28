# Story 001: Soft-Follow & Deadzone

> **Epic**: Camera System
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/camera-system.md`
**Requirement**: TR-CAM-001

**ADR**: N/A — Camera2D 跟随逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-Cam-01: 软跟随无 snap，2s 连续移动单帧 Δpos ≤ 8px
- [ ] AC-Cam-02: 死区 32px 内 Camera 不响应，超出后开始跟随
- [ ] AC-Cam-03: 帧率无关 (30fps vs 144fps 1s 后位置差 ≤2px)

---

## Implementation Notes

- alpha = 1 - exp(-FOLLOW_RATE × dt)，FOLLOW_RATE=10.0
- 死区: |pc.pos - cam.pos| < DEAD_ZONE 时不更新
- 每帧 Camera position 取整 (integer-aligned)

---

## Out of Scope

- Story 002: 震屏
- Story 003: Zoom

---

## QA Test Cases

- **AC-Cam-01**: 软跟随
  - Given: PC @ viewport center
  - When: 连续移动 2s
  - Then: 单帧 Δpos ≤ 8px

- **AC-Cam-03**: 帧率无关
  - Given: PC teleport 200px
  - When: 30fps vs 144fps 各 1s
  - Then: 位置差 ≤2px

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/camera/follow_deadzone_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
