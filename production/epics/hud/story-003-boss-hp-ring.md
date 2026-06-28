# Story 003: Boss HP Bar & Player HP Ring

> **Epic**: HUD
> **Status**: In Progress
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/hud.md`
**Requirement**: TR-HUD-004, TR-HUD-005

**ADR**: N/A — UI 组件
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-4: BOSS 生成时 BOSS 血条在顶部居中显示
- [ ] AC-5: BOSS 死亡时 BOSS 血条隐藏
- [ ] AC-7: 玩家 HP 降到 15% 时 HP 环 α=0.85 + 慢呼吸脉冲每 1.2s

---

## Implementation Notes

- BOSS 血条: 顶部居中水平线，朱砂红填充，双层反馈 (前层即时，后层 200ms 延迟)
- BOSS 名称: 血条上方朱砂印章
- HP 环: 玩家锚定 80px 半径，100% 时不可见，<20% 时 α=1.0 + 脉冲
- HP 环不受全局 HUD 透明度影响

---

## Out of Scope

- Story 001: 透明度
- Story 002: 灵气条和技能槽

---

## Test Evidence

**Story Type**: UI
**Required evidence**: `tests/unit/hud/boss_hp_ring_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 002
- Unlocks: None (Epic complete)
