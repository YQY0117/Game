# Story 001: DamageEvent & DamageBus Core

> **Epic**: Event Bus
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/damage-health-system.md`
**Requirement**: TR-DAMAGE-001, TR-DAMAGE-005, TR-DAMAGE-007

**ADR Governing Implementation**: ADR-0001: Event Bus
**ADR Decision Summary**: DamageBus 为 Autoload 单例，所有伤害通过 deal_damage() 入口，同步处理。

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-DMG-01: DamageEvent 包含 7 个字段: attacker_id, victim_id, raw_damage, element, knockback_tier, is_crit, position
- [ ] AC-DMG-02: 静态扫描确认无绕过 DamageBus 的 HP 修改
- [ ] AC-DMG-03: entity_died 签名 = (victim_id: int, final_event: DamageEvent)
- [ ] AC-DMG-05: 同帧多事件按 attacker_id 升序处理，100 次运行结果一致

---

## Implementation Notes

- DamageBus 为 Autoload（project.godot 中配置）
- DamageEvent 为 GDScript class，7 个字段严格定义
- deal_damage() 同步处理：验证 → 元素相克 → 扣 HP → emit 信号
- 单帧事件队列按 attacker_id 升序排序后 flush

---

## Out of Scope

- Story 002: HP 管理和元素相克
- Story 003: 公式和边界情况

---

## QA Test Cases

- **AC-DMG-01**: DamageEvent 字段
  - Given: 构造 DamageEvent
  - When: 检查字段
  - Then: 必须包含且仅包含 7 个字段

- **AC-DMG-05**: 确定性排序
  - Given: 同帧 3 个 DamageEvent (attacker_id=300,100,200)
  - When: flush()
  - Then: 处理顺序 = [100,200,300]

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/damage/damage_bus_core_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
