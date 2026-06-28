# Story 001: BOSS State Machine & Tell Rhythm

> **Epic**: Boss AI
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/boss-ai.md`
**Requirement**: TR-BOSS-001, TR-BOSS-002

**ADR**: N/A — BOSS 行为状态机
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 4 拍 Tell 节奏: Charge (1.0-1.5s) → Mid-charge (0.5s) → Strike → Recovery (1.5-2.0s)
- [ ] 固定循环 2-3 种攻击模式
- [ ] BOSS 强制留白圈 2.0× bounding-box

---

## Implementation Notes

- 8 状态: spawning → idle → telegraph → attacking → recovery → hitstun → phase_transition → dying
- 优先级: dying > phase > hitstun > attacking > telegraph > idle > spawning
- Tell 色: 朱砂红 `#B8403A`（全元素统一）
- 攻击循环间隔: 3-5s (phase 加速)

---

## Out of Scope

- Story 002: 具体 BOSS 实现

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/boss/boss_state_machine_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
