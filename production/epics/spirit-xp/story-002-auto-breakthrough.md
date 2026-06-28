# Story 002: Spirit Auto-Breakthrough

> **Epic**: Spirit/XP System
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/spirit-xp-system.md`
**Requirement**: TR-SPIRIT-003

**ADR**: N/A — 自动突破逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 灵气条满自动触发突破，无需玩家操作
- [ ] 突破期间灵气吸收暂停
- [ ] 突破完成后灵气条清零

---

## Implementation Notes

- RealmProgression.add_spirit() 检查是否达到阈值
- 达到阈值自动调用 _start_breakthrough()
- 突破期间 _is_breaking_through = true，暂停吸收

---

## Out of Scope

- Story 001: 灵气收集

---

## QA Test Cases

- **AC-1**: 自动突破
  - Given: 灵气 = 99
  - When: add_spirit(1)
  - Then: 自动触发突破

- **AC-2**: 突破期间暂停
  - Given: 突破中
  - When: add_spirit(10)
  - Then: 灵气不变

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/spirit/auto_breakthrough_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None