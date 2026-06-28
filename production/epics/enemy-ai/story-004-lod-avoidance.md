# Story 004: AI LOD & Boss Clearance Avoidance

> **Epic**: Enemy AI
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/enemy-ai.md`
**Requirement**: TR-ENEMY-003, TR-ENEMY-005, TR-ENEMY-006

**ADR**: N/A — 性能优化
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AI tick LOD: >600px 每 2 帧，>1200px 每 4 帧
- [ ] BOSS 留白圈 2.0× 内杂兵被推开
- [ ] 敌人之间不碰撞 (boids separation，允许重叠)

---

## Implementation Notes

- LOD: 距离 PC 越远，AI tick 频率越低
- BOSS clearance: 检测与 BOSS 距离，触发 emergency steering
- 无碰撞: 敌人之间用 boids separation (轻微推开) 但允许重叠

---

## Out of Scope

- Story 003: 精英

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/enemy/ai_lod_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 003
- Unlocks: None (Epic complete)
