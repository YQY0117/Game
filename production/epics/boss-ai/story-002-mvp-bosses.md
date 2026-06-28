# Story 002: MVP Bosses & Phase Transition

> **Epic**: Boss AI
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/boss-ai.md`
**Requirement**: TR-BOSS-003, TR-BOSS-004

**ADR**: N/A — BOSS 定义
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] BOSS-A 烈焰长老: 3 种攻击 (火球连射/火焰冲击/火焰爆发)
- [ ] BOSS-B 冰霜巨兽: 2 种攻击 (冰锥雨/冰霜吐息)
- [ ] BOSS-C 雷霆剑客: 3 种攻击 (雷斩/瞬移斩/雷阵)
- [ ] BOSS-D 守护者: 2 种攻击 (大地震击/墨潮涌动)
- [ ] Phase transition: 50% HP 攻速 +20%，25% HP 攻速 +40%

---

## Implementation Notes

- 每个 BOSS 有独立攻击模式配置
- Phase transition: 短暂无敌 1.0s + 行为变化
- BOSS HP: 80/120/100/150 (boss-ai GDD 定义)

---

## Out of Scope

- Story 001: 状态机框架

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/boss/boss_mvp_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None (Epic complete)
