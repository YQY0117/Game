# Story 004: Ink Sweep Transition Polish

> **Epic**: Scene Management
> **Status**: In Progress
> **Layer**: Polish
> **Type**: Visual/Feel
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/run-session-management.md`
**Requirement**: TR-SCENE-008

**ADR**: N/A — 视觉优化
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 墨色横扫动画流畅 (300ms cover + 200ms dissipate)
- [ ] 转场期间无画面撕裂
- [ ] 转场完成后场景正确切换

---

## Implementation Notes

- 优化 SceneManager 的动画曲线
- 使用 ease-in-out 缓动
- 确保 CanvasLayer 层级正确

---

## Out of Scope

- Story 001: SceneManager 基础

---

## QA Test Cases

- **AC-1**: 转场流畅
  - Given: 当前在 menu 场景
  - When: change_scene("battle")
  - Then: 墨色横扫动画流畅，无撕裂

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: `production/qa/evidence/ink-sweep-polish.md`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None