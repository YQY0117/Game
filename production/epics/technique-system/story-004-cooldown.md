# Story 004: Cooldown Pause & Edge Cases

> **Epic**: Technique System
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/technique-system.md`
**Requirement**: TR-TECH-002

**ADR**: N/A — 冷却逻辑
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] AC-5: 无敌人时冷却暂停，不释放弹幕；敌人出现后从暂停值继续

---

## Implementation Notes

- 冷却暂停: enemies_in_range == 0 时 cooldown_timer.paused = true
- 冷却恢复: enemies_in_range > 0 时从暂停值继续
- HUD 就绪脉冲触发条件: cooldown_remaining == 0 AND enemies_in_range > 0
- 玩家死亡时冷却冻结，复活后从零重新开始

---

## Out of Scope

- Story 003: 槽位管理

---

## QA Test Cases

- **AC-5**: 冷却暂停
  - Given: 功法冷却中
  - When: 所有敌人离开范围
  - Then: 冷却暂停，不释放弹幕

- **AC-5 恢复**: 冷却恢复
  - Given: 冷却暂停在 0.5s
  - When: 敌人重新进入范围
  - Then: 从 0.5s 继续倒计时

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/technique/cooldown_pause_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 003
- Unlocks: None (Epic complete)
