# Story 001: Semantic Action Mapping

> **Epic**: Input System
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/input-system.md`
**Requirement**: TR-INPUT-001 (语义动作映射)

**ADR Governing Implementation**: ADR-0001: Event Bus
**ADR Decision Summary**: DamageBus + RunSession 为 Autoload，其他系统用原生信号。Input System 暴露语义动作接口。

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-01: 8 个语义动作 (move_up/down/left/right, pause, confirm, cancel, technique_slot_1..4) 可通过 KBM 默认绑定触发，≤1 frame 延迟
- [ ] AC-04: 同时按 W+S 时该轴输出 0.000；对角 W+D 输出 magnitude == 1.000 ± 0.001

---

## Implementation Notes

- 使用 Godot InputMap 在 project.godot 中定义所有语义动作
- `_physics_process` 中调用 `Input.get_vector()` 获取归一化方向
- 对向键抵消: Godot 默认处理（W+S=0），需验证
- 对角线归一化: `Input.get_vector()` 自动归一化

---

## Out of Scope

- Story 002: 模式切换滞后机制
- Story 003: 死区和平滑曲线

---

## QA Test Cases

- **AC-1**: 语义动作触发
  - Given: 游戏在 gameplay 场景，InputManager 初始化
  - When: 按 W/A/S/D/Esc/Enter/1-4
  - Then: 对应语义事件在 ≤1 frame 内 emit

- **AC-4**: 对向键抵消 + 对角归一化
  - Given: active_mode == "kbm"
  - When: 同时按 W+S
  - Then: 该轴输出 0.000

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/input/semantic_action_test.gd`
**Status**: [ ] Not yet created

---

## Completion Notes
**Completed**: 2026-06-27
**Criteria**: 2/2 passing
**Deviations**: None
**Test Evidence**: `tests/unit/input/semantic_action_test.gd`
**Code Review**: Complete (APPROVED WITH SUGGESTIONS)

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
