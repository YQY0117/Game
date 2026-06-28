# Story 004: RunSession State Machine

> **Epic**: Event Bus
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/run-session-management.md`
**Requirement**: TR-RUN-001, TR-RUN-002

**ADR Governing Implementation**: ADR-0001: Event Bus
**ADR Decision Summary**: RunSession 为 Autoload，管理 RunState 状态机并广播 run_state_changed。

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-RUN-01: menu→loading→playing 转换链，run_state_changed 发射 2 次
- [ ] AC-RUN-02: playing↔paused 切换，SceneTree.paused 正确设置
- [ ] AC-RUN-03: dying→dead 强制不可中断，0.4s+0.8s+0.5s+0.3s=2s 仪式

---

## Implementation Notes

- RunState 为 GDScript enum (9 个状态)
- set_run_state() 内部调用 SceneTree.paused
- dying→dead 用 Timer 节点，不可被打断
- 每次状态切换 emit run_state_changed(old, new)

---

## Out of Scope

- Story 003: Damage 公式
- Story 005: 广播集成

---

## QA Test Cases

- **AC-RUN-01**: 状态转换链
  - Given: RunState == menu
  - When: start_new_run()
  - Then: menu→loading→playing，信号发射 2 次

- **AC-RUN-03**: 死亡仪式
  - Given: RunState == playing
  - When: entity_died(player)
  - Then: dying 0.4s → dead 0.8s → UI 接受输入

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/run/run_session_state_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 005
