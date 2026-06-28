# Story 003: Slot Management & Candidate List

> **Epic**: Technique System
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/technique-system.md`
**Requirement**: TR-TECH-003

**ADR**: N/A — 槽位逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-3: R2 突破槽位 2→3，新槽位解锁可装备新功法
- [ ] AC-4: R5 已装备 6 功法，新功法进候选列表 (最多 3 个)

---

## Implementation Notes

- slot_count = 2 + (R-1)，R1=2, R2=3, ..., R6=7
- 监听 realm_breakthrough 信号解锁新槽位
- 已装备功法不可卸下 (Pillar 2 "只增不减")
- 候选列表: 无空槽时新功法进入候选，最多 3 个
- 突破时弹出选择界面让玩家挑选装备哪个

---

## Out of Scope

- Story 001: 自动释放
- Story 004: 冷却暂停

---

## QA Test Cases

- **AC-3**: 槽位解锁
  - Given: R1 装备 2 功法
  - When: 突破到 R2
  - Then: 槽位从 2 增加到 3

- **AC-4**: 候选列表
  - Given: R5 装备 6 功法
  - When: 获得新功法
  - Then: 进入候选列表 (≤3 个)

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/technique/slot_management_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 002
- Unlocks: Story 004
