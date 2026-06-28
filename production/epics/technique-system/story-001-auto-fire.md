# Story 001: Technique Data & Auto-Fire

> **Epic**: Technique System
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/technique-system.md`
**Requirement**: TR-TECH-001, TR-TECH-002

**ADR**: N/A — 功法数据结构和自动释放逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-1: R1 装备 2 功法，敌人进入范围后按各自冷却独立自动释放弹幕，命中造成伤害
- [ ] AC-6: 烈焰掌 (1.2s CD, 5 dmg) + 冰锥术 (1.8s CD, 4 dmg)，10s 内释放 ≈8+5 次，DPS ≈53
- [ ] AC-8: 两个功法同帧冷却完成，按槽位索引顺序释放 (slot 0 先于 slot 1)

---

## Implementation Notes

- Technique 为 Resource，包含 id/element/cooldown/base_damage/projectile_type 等字段
- 每个装备槽维护独立 cooldown_timer
- 自动释放: 每 _physics_process 检查冷却 → 找最近敌人 → 实例化弹幕
- 弹幕使用对象池 (ADR-0002)
- 无敌人时冷却暂停 (见 Story 004)

---

## Out of Scope

- Story 002: 伤害和元素集成
- Story 003: 槽位管理

---

## QA Test Cases

- **AC-1**: 自动释放
  - Given: R1 装备 2 功法
  - When: 敌人进入范围
  - Then: 两个功法按各自冷却独立释放弹幕

- **AC-6**: DPS 验证
  - Given: 烈焰掌 (1.2s) + 冰锥术 (1.8s)
  - When: 运行 10s
  - Then: 烈焰掌 ≈8 次，冰锥术 ≈5 次

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/technique/auto_fire_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
