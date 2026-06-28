# Story 003: Damage Formulas & Edge Cases

> **Epic**: Event Bus
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/damage-health-system.md`
**Requirement**: TR-DAMAGE-002, TR-DAMAGE-004

**ADR**: N/A — 纯公式实现
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-DMG-06: HP≤0 时 entity_died 仅触发 1 次，第二个事件丢弃
- [ ] AC-DMG-07: 过量伤害截断，final_damage = min(raw_after_resist, current_HP)
- [ ] AC-DMG-10: mob_damage 线性递增，R1-R6 = [2,3,4,5,6,7]
- [ ] AC-DMG-15: 多敌人同帧仅第一个生效（attacker_id 升序）
- [ ] AC-DMG-16: immobile 期间伤害截断，不触发 i-frame
- [ ] AC-DMG-17: raw=0 时 final=1（最小伤害下限）
- [ ] AC-DMG-18: 碰撞→伤害桥接通过 Area2D

---

## Implementation Notes

- entity_died 防重复: 死亡标志位检查
- 过量截断: final = min(damage, current_hp)
- mob_damage: base_dmg × (1 + 0.45 × (R-1))
- immobile 截断: DamageBus 订阅 PC state_changed

---

## Out of Scope

- Story 002: HP 和元素
- Story 004: RunSession

---

## QA Test Cases

- **AC-DMG-06**: 防重复死亡
  - Given: HP=5，同帧两个 10 伤害事件
  - When: flush()
  - Then: entity_died 仅触发 1 次

- **AC-DMG-10**: mob_damage 递增
  - Given: base_dmg[杂兵]=2
  - When: R=1..6
  - Then: [2,3,4,5,6,7]

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/damage/damage_formulas_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 002
- Unlocks: Story 004
