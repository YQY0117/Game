# Story 001: Spirit Collection & Breakthrough

> **Epic**: Spirit/XP System
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/spirit-xp-system.md`
**Requirement**: TR-SPIRIT-001, TR-SPIRIT-002, TR-SPIRIT-003, TR-SPIRIT-004, TR-SPIRIT-005

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 击杀敌人后灵气自动飘向玩家 (0.5s)
- [ ] 境界需求: R1=100, R2=200, R3=350, R4=550, R5=700
- [ ] 灵气掉落: 杂兵 1-2, 精英 3-5, BOSS 10-15
- [ ] 灵气条满自动触发突破
- [ ] 突破后灵气清零，进入下一境界需求

---

## Implementation Notes

- 监听 entity_died 信号 → 生成灵气值 → 飘向玩家
- spirit_required(R) = 100 + 100×(R-1) + 50×(R-1)×(R-2)/2
- 溢出截断: 多余灵气不保留
- 信号: spirit_changed, realm_breakthrough, spirit_absorbed

---

## Out of Scope

- 无（单一 Story 覆盖完整系统）

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/spirit/spirit_collection_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: None (Epic complete)
