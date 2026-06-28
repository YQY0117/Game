# Sprint 2 — 2026-07-14 to 2026-07-25

## Sprint Goal

实现 Core 层核心系统：Player Controller 移动控制 + Camera 跟随/震屏，使玩家可通过输入控制角色移动，摄像机平滑跟随并提供击中反馈。

## Capacity

- Total days: 10
- Buffer (20%): 2 days
- Available: 8 days

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S2-001 | Player Controller: Movement Core | gameplay-programmer | 0.5 | S1-001 | AC-PC-01,02,03,04 |
| S2-002 | Player Controller: Realm Speed & Clearance | gameplay-programmer | 0.5 | S2-001 | AC-PC-05,06 |
| S2-003 | Camera: Soft-Follow & Deadzone | gameplay-programmer | 0.5 | S2-001 | AC-Cam-01,02,03 |
| S2-004 | Camera: Shake System | gameplay-programmer | 0.5 | S2-003 | AC-Cam-04,05 |
| S2-005 | Player Controller: Knockback & Hitstun | gameplay-programmer | 0.5 | S2-001, S1-004 | AC-PC-07,08,09 |

**Subtotal**: 2.5 days

### Should Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S2-006 | Player Controller: State Machine & Collision | gameplay-programmer | 0.5 | S2-001 | AC-PC-10,11 |
| S2-007 | Camera: Zoom Transitions | gameplay-programmer | 0.5 | S2-003 | AC-Cam-06 |
| S2-008 | Player Controller: Performance & Signals | gameplay-programmer | 0.5 | S2-001 | AC-PC-12,13 |
| S2-009 | Camera: Snap & Hard-Follow | gameplay-programmer | 0.5 | S2-003 | AC-Cam-07 |

**Subtotal**: 2.0 days

### Nice to Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S2-010 | Camera: State Priority & Edge Cases | gameplay-programmer | 0.5 | S2-003 | AC-Cam-08 |
| S2-011 | Sprint 1 Should-Have: Touch Joystick | gameplay-programmer | 0.5 | S1-003 | AC-06 |
| S2-012 | Sprint 1 Should-Have: Idle & Focus Loss | gameplay-programmer | 0.5 | S1-003 | AC-07,11,12 |

**Subtotal**: 1.5 days

## Carryover from Sprint 1

| Task | Reason | New Estimate |
|------|--------|-------------|
| S1-009 Touch Joystick | should-have, deferred | 0.5 days |
| S1-010 Idle & Focus Loss | should-have, deferred | 0.5 days |

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| CharacterBody2D move_and_slide 与自定义缓动冲突 | Medium | Medium | Early spike on movement |
| Camera shake 信号链路与 DamageBus 集成 | Low | Medium | Follow ADR-0001 pattern |

## Definition of Done

- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/qa-plan-sprint-2.md`)
- [ ] All Logic stories have passing unit tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] No S1 or S2 bugs in delivered features

## Next Sprint Preview

Sprint 3 聚焦 Feature 层: Enemy AI + Enemy Spawner + Technique System。