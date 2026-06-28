# Story 003: HUD Transparency System

> **Epic**: HUD
> **Status**: In Progress
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/hud.md`
**Requirement**: TR-HUD-002, TR-HUD-003

**ADR**: N/A — UI 渲染逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 空闲状态 HUD α=0.35
- [ ] 进入战斗 α 渐入到 1.0 (0.2s ease-in)
- [ ] 战斗结束 3s 后 α 渐回 0.35
- [ ] 技能槽冷却中显示半透明

---

## Implementation Notes

- HUD 透明度由 _target_alpha 控制
- ease-in 缓动: alpha = lerp(current, target, progress)
- 技能槽冷却: modulate.a = 0.5 during cooldown

---

## Out of Scope

- Story 001: 境界标识
- Story 002: 灵气条

---

## QA Test Cases

- **AC-1**: 空闲透明度
  - Given: HUD 空闲状态
  - When: 查询 alpha
  - Then: alpha ≈ 0.35

- **AC-2**: 战斗渐入
  - Given: HUD 空闲
  - When: enter_combat()
  - Then: 0.2s 后 alpha ≈ 1.0

---

## Test Evidence

**Story Type**: UI
**Required evidence**: `tests/unit/hud/transparency_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None