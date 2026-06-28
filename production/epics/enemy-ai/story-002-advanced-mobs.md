# Story 002: Sluggish/Flying/Cluster Ink Behavior

> **Epic**: Enemy AI
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/enemy-ai.md`
**Requirement**: TR-ENEMY-001, TR-ENEMY-002

**ADR**: N/A — Steering behavior
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 闷墨: seek + 速度限制 + 加减速延迟 (slow, predictable)
- [ ] 飞墨: 保持距离 + 周期性 projectile 发射
- [ ] 群墨: 慢速 seek，受击后爆裂为 3-5 个散墨

---

## Implementation Notes

- 闷墨: lerp velocity, max_speed × 0.55
- 飞墨: stay-at-range (200-400px)，周期发射弹幕
- 群墨: HP≤0 触发 cluster_split 信号，实例化 3-5 个散墨

---

## Out of Scope

- Story 001: 基础杂兵
- Story 003: 精英

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/enemy/mob_advanced_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
