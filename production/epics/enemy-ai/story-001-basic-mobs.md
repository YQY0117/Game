# Story 001: Ink Drop & Scattered Ink Behavior

> **Epic**: Enemy AI
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/enemy-ai.md`
**Requirement**: TR-ENEMY-001, TR-ENEMY-002

**ADR**: N/A — Steering behavior 逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 墨滴: 纯 seek 行为，直接朝玩家移动
- [ ] 散墨: seek + 侧向正弦偏移 (curved swarm)
- [ ] 两种类型视觉可区分 (32px 缩略图测试)

---

## Implementation Notes

- 墨滴: velocity = (PC.pos - self.pos).normalized() × move_speed
- 散墨: velocity = seek_dir × speed + perpendicular(seek_dir) × sin(t × freq) × strength
- 速度比: 墨滴 0.7× player，散墨 0.85× player

---

## Out of Scope

- Story 002: 闷墨/飞墨/群墨
- Story 003: 精英行为

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/enemy/mob_basic_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
