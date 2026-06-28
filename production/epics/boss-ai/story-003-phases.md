# Story 003: BOSS Phase Transitions

> **Epic**: Boss AI
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/boss-ai.md`
**Requirement**: TR-BOSS-005, TR-BOSS-006

**ADR**: N/A — BOSS 阶段转换逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 50% HP 触发 Phase 2: 攻速 +20%，短暂无敌 1.0s
- [ ] 25% HP 触发 Phase 3: 攻速 +40%，短暂无敌 1.0s
- [ ] Phase 转换时朱砂红闪烁 0.5s

---

## Implementation Notes

- Phase 2: attack_interval × 0.8
- Phase 3: attack_interval × 0.6
- 无敌期间 boss_state = PHASE_TRANSITION
- 闪烁: modulate = TELL_COLOR, 0.5s 后恢复

---

## Out of Scope

- Story 001: 状态机框架
- Story 002: MVP BOSS

---

## QA Test Cases

- **AC-1**: Phase 2 触发
  - Given: BOSS HP = 50%
  - When: take_damage(0)
  - Then: phase = 2, attack_interval × 0.8

- **AC-2**: Phase 3 触发
  - Given: BOSS HP = 25%
  - When: take_damage(0)
  - Then: phase = 3, attack_interval × 0.6

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/boss/phase_transition_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None