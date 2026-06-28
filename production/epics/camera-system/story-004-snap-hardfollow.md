# Story 004: Snap & Hard-Follow

> **Epic**: Camera System
> **Status**: In Progress
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/camera-system.md`
**Requirement**: TR-CAM-004

**ADR**: N/A — Camera 安全边界
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-Cam-09: snap_to() 1 帧内到达目标，软跟随从新原点恢复
- [ ] AC-Cam-10: 硬跟随在 PC 离开 viewport 前触发 (margin_x=80, margin_y=120)
- [ ] AC-Cam-11: 最终渲染位置整数对齐，无次像素抖动

---

## Implementation Notes

- snap_to(): 立即设置 position，跳过平滑
- 硬跟随: |pc.x - cam.x| > viewport_half_w - margin_x 时强制跟随
- 整数对齐: floor(camera.position) 后渲染

---

## Out of Scope

- Story 003: Zoom
- Story 005: 状态优先级

---

## QA Test Cases

- **AC-Cam-09**: Snap
  - Given: Camera (0,0)
  - When: snap_to(500, 300)
  - Then: 1 帧内 position = (500, 300)

- **AC-Cam-10**: 硬跟随
  - Given: PC 超出 soft-follow 追踪
  - When: overflow > 0
  - Then: Camera 同帧修正，PC 不离开 viewport

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/camera/snap_hardfollow_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 003
- Unlocks: Story 005
