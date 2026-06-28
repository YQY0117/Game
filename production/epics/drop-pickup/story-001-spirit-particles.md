# Story 001: Spirit Particle Visuals

> **Epic**: Drop/Pickup System
> **Status**: Ready
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/drop-pickup-system.md`
**Requirement**: TR-DROP-001, TR-DROP-002, TR-DROP-003, TR-DROP-004

**ADR Governing Implementation**: ADR-0002 (Object Pool), ADR-0005 (Particle System)
**Engine**: Godot 4.6 | **Risk**: MEDIUM

---

## Acceptance Criteria

- [ ] 金色粒子 `#C8A055` 从敌人死亡位置生成
- [ ] 0.2s 延迟后飘向玩家，0.5s 到达
- [ ] BOSS 灵气: 15 个粒子环形扩散 0.3s 后分批飘向
- [ ] 同屏粒子上限 50
- [ ] 到达时触发 spirit_absorbed 信号

---

## Implementation Notes

- 粒子: 8×8px 圆形光点，α=0.6→1.0 脉冲 (0.3s 周期)
- 池化: GPUParticles2D 发射器池化
- BOSS: 环形扩散 → 分批 (每批 5 个，间隔 0.2s)

---

## Out of Scope

- 无（单一 Story 覆盖完整系统）

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: `production/qa/evidence/drop-pickup-visual.md`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: None (Epic complete)
