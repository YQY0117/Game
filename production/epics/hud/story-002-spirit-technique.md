# Story 002: Spirit Bar & Technique Slots

> **Epic**: HUD
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/hud.md`
**Requirement**: TR-HUD-002, TR-HUD-003

**ADR**: N/A — UI 组件
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-2: 灵气条填充从 50% 更新到 60% (spirit_changed 信号)
- [ ] AC-3: 技能槽冷却完成时播放 200ms 就绪脉冲

---

## Implementation Notes

- 灵气条: 顶部居中水平线，3px 高，墨色填充由左至右晕开
- 突破节点: 4-5 个标记，已到达=朱砂红，未到达=淡墨
- 技能槽: 4 槽底部居中，方印 40×48px
- 冷却: 朱砂红径向擦除 (顺时针)
- 就绪: 200ms 脉冲 (环外扩 4px + 字体闪白)

---

## Out of Scope

- Story 001: 透明度和境界标识
- Story 003: BOSS 血条和 HP 环

---

## Test Evidence

**Story Type**: UI
**Required evidence**: `production/qa/evidence/hud-spirit-technique.md`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
