# Story 002: Shake System

> **Epic**: Camera System
> **Status**: In Progress
> **Layer**: Core
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/camera-system.md`
**Requirement**: TR-CAM-002

**ADR Governing Implementation**: ADR-0001: Event Bus
**ADR Decision Summary**: DamageBus 信号触发震屏

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-Cam-04: 5 档击退 magnitude [2,4,7,12,18] px，duration [100,130,160,200,250] ms (±15%)
- [ ] AC-Cam-05: 震屏衰减为 cubic (1-progress)³，非线性
- [ ] AC-Cam-06: 多震屏叠加 clamp ±30px

---

## Implementation Notes

- Perlin 噪声采样，每次 shake 用不同 seed
- 衰减: envelope = (1-progress)³
- 叠加: total_offset = clamp(sum(offsets), -SHAKE_TOTAL_CLAMP, +SHAKE_TOTAL_CLAMP)
- 信号: shake_started(magnitude, duration)

---

## Out of Scope

- Story 001: 软跟随
- Story 003: Zoom

---

## QA Test Cases

- **AC-Cam-04**: 震屏参数
  - Given: knockback force=240
  - When: shake() 调用
  - Then: magnitude ≈12px ±15%，duration ≈200ms ±20ms

- **AC-Cam-05**: 衰减曲线
  - Given: shake(mag0=12, duration=200ms)
  - When: 采样 t=50/100/150/200ms
  - Then: 包络 ≈ 5.06/1.5/0.19/0 px

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/camera/shake_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
