# Story 003: Breakthrough Ceremony Visual Polish

> **Epic**: Realm Progression
> **Status**: In Progress
> **Layer**: Polish
> **Type**: Visual/Feel
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/realm-progression.md`
**Requirement**: TR-REALM-008

**ADR**: N/A — 视觉优化
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 1.2s 仪式动画完整 (art-bible Section 7.5)
- [ ] 0-200ms 减速 → 200-500ms 墨色扩张 → 500-800ms 印章 → 800-1100ms 描述 → 1100-1200ms 消散
- [ ] 境界印章正确显示

---

## Implementation Notes

- 使用 Tween 或 AnimationPlayer
- 每个阶段独立动画
- 印章使用朱砂红 #B8403A

---

## Out of Scope

- Story 001: 突破基础

---

## QA Test Cases

- **AC-1**: 仪式动画
  - Given: 灵气条满
  - When: 触发突破
  - Then: 1.2s 仪式动画完整播放

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: `production/qa/evidence/breakthrough-ceremony.md`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None