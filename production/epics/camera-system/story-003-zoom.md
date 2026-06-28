# Story 003: Zoom Transitions

> **Epic**: Camera System
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/camera-system.md`
**Requirement**: TR-CAM-003

**ADR**: N/A — Camera2D zoom 控制
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-Cam-07: Zoom 过渡 0.4s cubic in-out，中点 ≈0.95 (非线性 0.95)
- [ ] AC-Cam-08: Zoom 中断从当前值重新开始，单调递增/递减，无 rebound

---

## Implementation Notes

- Zoom 范围 [0.8, 1.2]，BOSS=1.1，突破=0.9
- cubic in-out: zoom(t) = lerp(from, to, cubic_interpolate(progress))
- 中断: 记录 current_zoom，新过渡从 current 开始

---

## Out of Scope

- Story 002: 震屏
- Story 004: 硬跟随

---

## QA Test Cases

- **AC-Cam-07**: Zoom 过渡
  - Given: zoom=1.0
  - When: 切换到 zoomed_boss (0.9)
  - Then: t=0.2s ≈0.95，t=0.4s ≈0.9 ±0.005

- **AC-Cam-08**: Zoom 中断
  - Given: zoomed_boss @ t=0.15s (zoom≈0.978)
  - When: 切换到 zoomed_breakthrough (1.15)
  - Then: 单调递增，0.4s 后完成

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/camera/zoom_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 002
- Unlocks: Story 004
