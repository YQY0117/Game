# Sprint 4 — 2026-08-11 to 2026-08-22

## Sprint Goal

实现 Feature 层高级系统：Boss AI 状态机 + Realm Progression 境界突破 + HUD 界面，使游戏有BOSS战、境界提升和基础UI。

## Capacity

- Total days: 10
- Buffer (20%): 2 days
- Available: 8 days

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S4-001 | Boss AI: State Machine & Tell | gameplay-programmer | 0.5 | None | 8状态机+4拍Tell |
| S4-002 | Boss AI: MVP Bosses (2个) | gameplay-programmer | 0.5 | S4-001 | 墨龙+墨凤行为 |
| S4-003 | Realm Progression: Breakthrough | gameplay-programmer | 0.5 | None | 境界突破仪式 |
| S4-004 | HUD: Spirit Bar & Slots | gameplay-programmer | 0.5 | S3-003 | 灵力条+技能槽 |
| S4-005 | HUD: Boss HP & Realm | gameplay-programmer | 0.5 | S4-001 | BOSS血条+境界显示 |

**Subtotal**: 2.5 days

### Should Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S4-006 | Realm Progression: Speed Update | gameplay-programmer | 0.5 | S4-003 | 境界速度同步 |
| S4-007 | HUD: Transparency System | gameplay-programmer | 0.5 | S4-004 | 空闲淡化+战斗显示 |
| S4-008 | Boss AI: Phase Transitions | gameplay-programmer | 0.5 | S4-001 | 阶段转换+加速 |
| S4-009 | Spirit/XP: Auto-Breakthrough | gameplay-programmer | 0.5 | S4-003 | 自动突破逻辑 |

**Subtotal**: 2.0 days

### Nice to Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S4-010 | HUD: Damage Numbers | gameplay-programmer | 0.5 | S4-004 | 伤害飘字 |
| S4-011 | Boss AI: Special Attacks | gameplay-programmer | 0.5 | S4-002 | 特殊攻击模式 |
| S4-012 | Realm Progression: Ceremony | gameplay-programmer | 0.5 | S4-003 | 突破动画优化 |

**Subtotal**: 1.5 days

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| BOSS状态机复杂度 | Medium | Medium | 简化MVP状态数 |
| HUD性能开销 | Low | Low | 对象池+批量更新 |

## Definition of Done

- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/qa-plan-sprint-4.md`)
- [ ] All Logic stories have passing unit tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] No S1 or S2 bugs in delivered features

## Next Sprint Preview

Sprint 5 聚焦 Polish: 性能优化 + 音效集成 + 视觉特效。