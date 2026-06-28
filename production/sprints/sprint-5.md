# Sprint 5 — 2026-08-25 to 2026-09-05

## Sprint Goal

Polish 层优化：性能优化 + 音效集成 + 视觉特效 + 集成测试，使游戏达到可发布质量。

## Capacity

- Total days: 10
- Buffer (20%): 2 days
- Available: 8 days

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S5-001 | Performance: Enemy LOD & Culling | technical-artist | 0.5 | S3-001 | 距离降频+屏幕外剔除 |
| S5-002 | Performance: Object Pool Monitoring | gameplay-programmer | 0.5 | S1-008 | 池大小监控+动态扩展 |
| S5-003 | Integration: Full Game Loop Test | qa-tester | 0.5 | All | menu→战斗→BOSS→突破→胜利 |
| S5-004 | Visual: Ink Sweep Polish | technical-artist | 0.5 | S1-007 | 转场动画优化 |
| S5-005 | Visual: Breakthrough Ceremony | technical-artist | 0.5 | S4-003 | 突破动画完整 |

**Subtotal**: 2.5 days

### Should Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S5-006 | Audio: Damage SFX | sound-designer | 0.5 | S1-004 | 击中音效 |
| S5-007 | Audio: Technique SFX | sound-designer | 0.5 | S3-003 | 功法释放音效 |
| S5-008 | Visual: Enemy Death VFX | technical-artist | 0.5 | S3-001 | 敌人死亡特效 |
| S5-009 | Visual: Realm Color Transition | technical-artist | 0.5 | S4-003 | 境界色调过渡 |

**Subtotal**: 2.0 days

### Nice to Have

| ID | Task | Agent | Est. Days | Dependencies | AC |
|----|------|-------|-----------|-------------|-----|
| S5-010 | Polish: HUD Animations | technical-artist | 0.5 | S4-004 | HUD元素动画 |
| S5-011 | Polish: Boss Death Sequence | technical-artist | 0.5 | S4-002 | BOSS死亡演出 |
| S5-012 | Performance: Web Export Optimization | technical-artist | 0.5 | All | 50MB包+60fps |

**Subtotal**: 1.5 days

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 音效资源缺失 | High | Medium | 使用占位音效 |
| Web导出性能 | Medium | High | 早期测试+优化 |

## Definition of Done

- [ ] All Must Have tasks completed
- [ ] All tasks pass acceptance criteria
- [ ] QA plan exists (`production/qa/qa-plan-sprint-5.md`)
- [ ] All Logic stories have passing unit tests
- [ ] Smoke check passed (`/smoke-check sprint`)
- [ ] No S1 or S2 bugs in delivered features

## Next Sprint Preview

Sprint 6 聚焦 Release: 最终测试 + 打包 + 部署。