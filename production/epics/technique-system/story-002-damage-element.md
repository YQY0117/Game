# Story 002: Damage & Element Integration

> **Epic**: Technique System
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/technique-system.md`
**Requirement**: TR-TECH-005

**ADR Governing Implementation**: ADR-0001: Event Bus
**ADR Decision Summary**: 所有伤害通过 DamageBus.deal_damage() 结算

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-2: 火系功法命中冰系敌人，伤害 = base_damage × 1.5
- [ ] AC-7: hitstun 时弹幕正常释放，不受击退影响

---

## Implementation Notes

- 弹幕命中 → 构造 DamageEvent → DamageBus.deal_damage()
- DamageEvent: attacker_id=player, raw_damage=technique.base_damage, element=technique.element
- 元素相克由 DamageBus 处理，本系统不重复计算
- 弹幕释放独立于 PC 状态 (hitstun 不影响)

---

## Out of Scope

- Story 001: 自动释放
- Story 003: 槽位管理

---

## QA Test Cases

- **AC-2**: 元素相克
  - Given: 火系功法 base_damage=5
  - When: 命中冰系敌人
  - Then: DamageEvent.raw_damage=5, DamageBus 计算 5×1.5=7.5

- **AC-7**: hitstun 不影响
  - Given: PC hitstun
  - When: 功法冷却完成
  - Then: 弹幕正常释放

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/technique/damage_element_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
