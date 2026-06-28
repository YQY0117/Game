# Story 005: State Priority & Edge Cases

> **Epic**: Camera System
> **Status**: In Progress
> **Layer**: Core
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/camera-system.md`
**Requirement**: TR-CAM-005, TR-CAM-006

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-Cam-12: frozen 状态下位置+zoom 锁定，shake 暂停队列，退出后恢复
- [ ] AC-Cam-13: 死亡时 shake 立即清除
- [ ] AC-Cam-14: 12fps 下 PC 不逃出 viewport (硬跟随保护)
- [ ] AC-Cam-15: Pull 模型 — Camera 读 PC 位置，不订阅信号

---

## Implementation Notes

- 状态优先级: frozen > zoomed_breakthrough > zoomed_boss > default
- frozen: 位置+zoom 锁定，shake offset=0
- 死亡: 清除所有 shake，Camera 冻结
- Pull: Camera._physics_process 中读 PC.global_position

---

## Out of Scope

- Story 004: Snap/硬跟随

---

## QA Test Cases

- **AC-Cam-12**: 状态优先级
  - Given: zoomed_boss + active shake
  - When: 进入 frozen
  - Then: 位置+zoom 锁定，shake=0

- **AC-Cam-15**: Pull 模型
  - Given: Camera 加载
  - When: PC position_changed 信号断开
  - Then: Camera 仍正确跟踪 (grep 无 connect 到 PC 信号)

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/camera/state_edge_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 004
- Unlocks: None (Epic complete)
