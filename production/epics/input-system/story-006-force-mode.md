# Story 006: Force Mode & Contract Stability

> **Epic**: Input System
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/input-system.md`
**Requirement**: TR-INPUT-004, TR-INPUT-007

**ADR Governing Implementation**: ADR-0001: Event Bus
**ADR Decision Summary**: Input System 暴露 input_mode_changed 信号供 HUD 消费

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-08: Settings 设置 force_input_mode="touch" 时，UI 保持 Touch 样式，但 move_vector 仍响应 Gamepad
- [ ] AC-15: 8 个语义动作名 + input_mode_changed + input_idle 信号签名与 GDD 一致

---

## Implementation Notes

- Force Mode: Settings 读取 `input_mode` 持久化值，非 Auto 时锁定 UI 样式
- 信号契约测试: 验证所有信号名称和参数类型
- Settings API: `set_force_mode(mode: String)` + `get_force_mode() -> String`

---

## Out of Scope

- Story 005: 空闲检测和焦点丢失

---

## QA Test Cases

- **AC-8**: Force Mode
  - Given: Settings force_input_mode = "touch"
  - When: Gamepad stick pushed 1.0 持续 1s
  - Then: UI 保持 Touch 样式，move_vector 响应 Gamepad

- **AC-15**: 信号契约
  - Given: InputManager 初始化
  - When: 运行 integration test
  - Then: 所有信号签名匹配 GDD

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/input/force_mode_contract_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 005
- Unlocks: None (Epic complete)
