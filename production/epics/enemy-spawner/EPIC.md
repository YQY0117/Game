# Epic: Enemy Spawner

> **Layer**: Feature
> **GDD**: design/gdd/enemy-spawner-wave-manager.md
> **Architecture Module**: EnemySpawner
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories enemy-spawner`

## Overview

Enemy Spawner 控制敌人何时、何地、以何种配置生成。每境界 5 波，波次间休息，最后一波 BOSS 战。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0002: Object Pool | 对象池管理 | LOW |
| ADR-0004: MultiMesh | 批量渲染 | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-SPAWN-001 | 固定波次结构 (5波) | — |
| TR-SPAWN-002 | 屏幕外随机生成 (400-800px) | — |
| TR-SPAWN-003 | 同屏上限 (30-150) | ADR-0004 ✅ |
| TR-SPAWN-004 | BOSS 生成规则 | — |
| TR-SPAWN-005 | 精英生成规则 | — |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Wave Structure & Spawning | Logic | Ready | ADR-0002, ADR-0004 |

## Definition of Done

This epic is complete when:
- 5 波结构正确
- 敌人生成位置和密度正确
- BOSS 在第 5 波生成

## Next Step

Run `/create-stories enemy-spawner` to break this epic into implementable stories.
