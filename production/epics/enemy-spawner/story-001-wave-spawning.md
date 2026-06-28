# Story 001: Wave Structure & Enemy Spawning

> **Epic**: Enemy Spawner
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/enemy-spawner-wave-manager.md`
**Requirement**: TR-SPAWN-001, TR-SPAWN-002, TR-SPAWN-003, TR-SPAWN-004, TR-SPAWN-005

**ADR Governing Implementation**: ADR-0002 (Object Pool), ADR-0004 (MultiMesh)
**Engine**: Godot 4.6 | **Risk**: MEDIUM

---

## Acceptance Criteria

- [ ] 每境界 5 波，波次间 3s 休息
- [ ] 敌人在屏幕外 400-800px 随机极坐标生成
- [ ] 同屏上限: R1=30, R5=150 (公式 30+30×(R-1))
- [ ] BOSS 在第 5 波 2s 延迟后生成
- [ ] 精英按波次配置随机出现

---

## Implementation Notes

- 波次配置表定义每波敌人类型和密度
- 生成位置: 极坐标 (角度随机，距离 400-800px)
- 对象池: get_instance() 获取，return_instance() 归还
- BOSS 生成: 玩家对面方向 600px

---

## Out of Scope

- 无（单一 Story 覆盖完整系统）

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/spawner/wave_spawning_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: None (Epic complete)
