# Story 005: RunSession Broadcast & Integration

> **Epic**: Event Bus
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/run-session-management.md`
**Requirement**: TR-RUN-002, TR-RUN-003, TR-RUN-004, TR-RUN-005

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-RUN-04: PC 订阅 run_state_changed，paused/dying/dead/breakthrough 时 set_immobile(true)
- [ ] AC-RUN-05: Camera 订阅 run_state_changed，相应状态 freeze()
- [ ] AC-RUN-06: Enemy Spawner/AI/Audio/HUD 订阅信号并正确响应

---

## Implementation Notes

- 下游系统在 _ready() 中连接 run_state_changed 信号
- PC: set_immobile(true/false) 基于状态判断
- Camera: freeze()/unfreeze() 基于状态判断
- RunData 统计在暂停期间禁止写入

---

## Out of Scope

- Story 004: 状态机本身

---

## QA Test Cases

- **AC-RUN-04**: PC 响应
  - Given: PC 已订阅信号
  - When: RunState → paused
  - Then: PC.is_immobile == true

- **AC-RUN-06**: 多下游联动
  - Given: 所有下游已订阅
  - When: RunState → paused
  - Then: Spawner 停止 / AI 停止 / Audio 切换 / HUD 显示暂停层

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/run/run_broadcast_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 004
- Unlocks: None (Epic complete)
