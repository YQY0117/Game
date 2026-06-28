# Epic: Enemy AI

> **Layer**: Feature
> **GDD**: design/gdd/enemy-ai.md
> **Architecture Module**: EnemyAI
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories enemy-ai`

## Overview

Enemy AI 实现 5 种杂兵类型 + 精英变种的运动行为、感知决策和攻击逻辑。每种杂兵通过独特的 steering modifier 实现 art-bible 锁定的运动语言。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0004: MultiMesh | 杂兵批量渲染 | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-ENEMY-001 | 5 种杂兵类型行为 | — |
| TR-ENEMY-002 | Steering behaviors (非 A*) | — |
| TR-ENEMY-003 | AI tick LOD (距离降频) | — |
| TR-ENEMY-004 | 精英特殊行为 (3种) | — |
| TR-ENEMY-005 | BOSS 留白圈避让 | — |
| TR-ENEMY-006 | 敌人之间不碰撞 | — |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Ink Drop & Scattered Ink | Logic | Ready | — |
| 002 | Sluggish/Flying/Cluster | Logic | Ready | — |
| 003 | Elite Mob Behavior | Logic | Ready | — |
| 004 | AI LOD & Boss Avoidance | Integration | Ready | — |

This epic is complete when:
- 5 种杂兵类型行为正确
- 精英 3 种变体工作正常
- 150+ 实体下 60fps

## Next Step

Run `/create-stories enemy-ai` to break this epic into implementable stories.
