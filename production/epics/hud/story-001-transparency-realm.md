# Story 001: HUD Transparency & Realm Indicator

> **Epic**: HUD
> **Status**: In Progress
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/hud.md`
**Requirement**: TR-HUD-001

**ADR**: N/A — UI 渲染逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-1: 进入战斗时 HUD 从 α=0.35 渐入到 α=1.0 (0.2s)
- [ ] AC-6: 境界突破时境界标识从"炼气"更新为"筑基"
- [ ] AC-8: 战斗结束 3s 后 HUD 渐回 α=0.35

---

## Implementation Notes

- HUD 为 CanvasLayer + Control 节点
- 透明度: idle=0.35, combat=1.0 (0.2s ease-in), post_combat=0.35 (3s delay)
- 境界标识: 右上角朱砂印章，监听 realm_changed 信号
- Z-order: HUD 在 UI 层 (Layer 5-6)，不受 Camera 变换影响

---

## Out of Scope

- Story 002: 灵气条和技能槽
- Story 003: BOSS 血条和 HP 环

---

## Test Evidence

**Story Type**: UI
**Required evidence**: `tests/unit/hud/hud_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
