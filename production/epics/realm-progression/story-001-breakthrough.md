# Story 001: Realm Breakthrough Ceremony

> **Epic**: Realm Progression
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/realm-progression.md`
**Requirement**: TR-REALM-001, TR-REALM-002, TR-REALM-003, TR-REALM-004, TR-REALM-005, TR-REALM-006

**ADR Governing Implementation**: ADR-0001: Event Bus
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 灵气条满触发突破，Run/Session 进入 breakthrough 状态
- [ ] 1.2s 仪式动画 (art-bible Section 7.5)
- [ ] 槽位解锁: TechniqueSystem.unlock_slot(new_realm)
- [ ] 速度切换: PlayerController.realm_transitioned(new_realm)
- [ ] 境界色调切换: CanvasModulate 应用新境界色
- [ ] R5 灵气满触发飞升 (victory 状态)

---

## Implementation Notes

- 监听 realm_breakthrough 信号
- 仪式序列: 0-200ms 减速 → 200-500ms 墨色扩张 → 500-800ms 印章 → 800-1100ms 描述 → 1100-1200ms 消散
- 色调: R1 松绿, R2 云青, R3 金, R4 紫霞, R5 流光, R6 无色

---

## Out of Scope

- 无（单一 Story 覆盖完整系统）

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: `tests/unit/realm/realm_progression_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: None (Epic complete)
