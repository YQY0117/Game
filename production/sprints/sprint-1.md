# Sprint 1 — 2026-06-30 to 2026-07-11

## Sprint Goal

搭建 Foundation 层基础设施（输入、伤害总线、场景管理、对象池），使游戏能启动、接收输入、处理伤害事件、切换场景。

## Capacity

- Total days: 10
- Buffer (20%): 2 days
- Available: 8 days

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S1-001 | Input: Semantic Actions | gameplay-programmer | 0.5 | None | AC-01, AC-04 |
| S1-002 | Input: Mode Switch Hysteresis | gameplay-programmer | 0.5 | S1-001 | AC-02 |
| S1-003 | Input: Dead Zones & Curves | gameplay-programmer | 0.5 | S1-001 | AC-03 |
| S1-004 | Event Bus: DamageBus Core | gameplay-programmer | 0.5 | None | AC-DMG-01,02,03,05 |
| S1-005 | Event Bus: HP & Element Mult | systems-designer | 0.5 | S1-004 | AC-DMG-04,08,09,12,13,14 |
| S1-006 | Event Bus: RunSession State | gameplay-programmer | 0.5 | S1-004 | AC-RUN-01,02,03 |
| S1-007 | Scene: SceneManager & Ink Sweep | gameplay-programmer | 0.5 | None | TR-SCENE-001,002,006 |
| S1-008 | Scene: Object Pool Foundation | gameplay-programmer | 0.5 | S1-007 | TR-SCENE-003,004 |

**Subtotal**: 4.0 days

### Should Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S1-009 | Input: Touch Joystick | gameplay-programmer | 0.5 | S1-003 | AC-06 |
| S1-010 | Input: Idle & Focus Loss | gameplay-programmer | 0.5 | S1-003 | AC-07,11,12 |
| S1-011 | Event Bus: Damage Formulas | systems-designer | 0.5 | S1-005 | AC-DMG-06,07,10,15,16,17,18 |
| S1-012 | Event Bus: RunSession Broadcast | gameplay-programmer | 0.5 | S1-006 | AC-RUN-04,05,06 |
| S1-013 | Scene: Lifecycle Integration | qa-tester | 0.5 | S1-008 | TR-SCENE-005 |

**Subtotal**: 2.5 days

### Nice to Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S1-014 | Input: Force Mode & Contract | gameplay-programmer | 0.5 | S1-002 | AC-08,15 |
| S1-015 | Player Controller: Movement Core | gameplay-programmer | 0.5 | S1-001 | AC-PC-01,02,03,04 |

**Subtotal**: 1.0 days

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Godot 4.6 Autoload 信号兼容性 | Low | High | Early spike on Day 1 |
| Web 导出性能未验证 | Medium | Medium | Test on Chrome early |

## Definition of Done

- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/qa-plan-sprint-1.md`)
- [ ] All Logic stories have passing unit tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] No S1 or S2 bugs in delivered features

## Next Sprint Preview

Sprint 2 聚焦 Core 层: Player Controller 移动 + Camera 跟随 + 震屏。
