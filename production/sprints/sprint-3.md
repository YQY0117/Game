# Sprint 3 — 2026-07-28 to 2026-08-08

## Sprint Goal

实现 Feature 层核心系统：Enemy AI 5种杂兵行为 + Technique System 功法自动释放，使游戏有敌人和战斗循环。

## Capacity

- Total days: 10
- Buffer (20%): 2 days
- Available: 8 days

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S3-001 | Enemy AI: Ink Drop & Scattered Ink | gameplay-programmer | 0.5 | None | 墨滴seek, 散墨seek+sine |
| S3-002 | Enemy AI: Sluggish/Flying/Cluster | gameplay-programmer | 0.5 | S3-001 | 闷墨/飞墨/群墨行为 |
| S3-003 | Technique: Data & Auto-Fire | gameplay-programmer | 0.5 | None | 功法数据结构+自动释放 |
| S3-004 | Technique: Damage & Element | gameplay-programmer | 0.5 | S3-003, S1-004 | 伤害结算+元素集成 |
| S3-005 | Enemy Spawner: Wave Manager | gameplay-programmer | 0.5 | S3-001 | 5波敌人生成 |

**Subtotal**: 2.5 days

### Should Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S3-006 | Enemy AI: Elite Mob Behavior | gameplay-programmer | 0.5 | S3-002 | 3种精英变体 |
| S3-007 | Technique: Slot Management | gameplay-programmer | 0.5 | S3-003 | 槽位2+(R-1) |
| S3-008 | Technique: Cooldown Pause | gameplay-programmer | 0.5 | S3-003 | 无敌人时暂停 |
| S3-009 | Enemy AI: LOD & Avoidance | gameplay-programmer | 0.5 | S3-001 | 距离降频+BOSS避让 |

**Subtotal**: 2.0 days

### Nice to Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S3-010 | Spirit/XP: Collection System | gameplay-programmer | 0.5 | None | 灵力吸收+自动突破 |
| S3-011 | Drop/Pickup: Spirit Drops | gameplay-programmer | 0.5 | S3-010 | 灵力掉落+飞向玩家 |
| S3-012 | HUD: Spirit Bar & Slots | gameplay-programmer | 0.5 | S3-003 | 灵力条+技能槽显示 |

**Subtotal**: 1.5 days

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 150+敌人性能 | Medium | High | MultiMesh渲染+LOD |
| 功法弹幕对象池溢出 | Low | Medium | 池大小监控+动态扩展 |

## Definition of Done

- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/qa-plan-sprint-3.md`)
- [ ] All Logic stories have passing unit tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] No S1 or S2 bugs in delivered features

## Next Sprint Preview

Sprint 4 聚焦 Feature 层: Boss AI + Realm Progression + HUD。