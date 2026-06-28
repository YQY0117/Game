# Story 002: HP Management & Element Mult

> **Epic**: Event Bus
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/damage-health-system.md`
**Requirement**: TR-DAMAGE-002, TR-DAMAGE-003, TR-DAMAGE-004

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-DMG-04: Player.max_hp 恒为 20，不随境界变化
- [ ] AC-DMG-08: F1 final_damage = round(raw × element_mult × (1-mitigation))，clamp [1, max_HP]
- [ ] AC-DMG-09: 7×7 元素矩阵：火→冰/冰→雷/雷→风/风→火=1.5，反向=0.7，其余=1.0
- [ ] AC-DMG-12: i-frame 600ms，起点=DamageEvent 处理完成时
- [ ] AC-DMG-13: critical 阈值 HP≤25% (5/20)，无滞回
- [ ] AC-DMG-14: dead 状态不可逆，仅 resurrect() 可解除

---

## Implementation Notes

- max_HP = 20 全局常量
- 元素相克矩阵用 2D Dictionary 或 match 语句
- i-frame 用 Timer 节点或累加器
- critical 状态由 HP 值派生，不是独立状态机

---

## Out of Scope

- Story 001: DamageEvent 结构
- Story 003: 公式和边界

---

## QA Test Cases

- **AC-DMG-04**: HP 常量
  - Given: 任意境界
  - When: 查询 max_hp
  - Then: 返回 20

- **AC-DMG-09**: 元素矩阵
  - Given: 49 个元素组合
  - When: 遍历
  - Then: 火→冰=1.5，冰→火=0.7，火→火=1.0

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/damage/hp_element_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
