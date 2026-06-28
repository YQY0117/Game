# Epic: Drop/Pickup System

> **Layer**: Feature
> **GDD**: design/gdd/drop-pickup-system.md
> **Architecture Module**: DropPickup
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories drop-pickup`

## Overview

Drop/Pickup System 是灵气掉落的视觉表现层——金色粒子从敌人死亡位置飘向玩家。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0002: Object Pool | 粒子池化 | LOW |
| ADR-0005: Particle System | GPUParticles2D | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-DROP-001 | 金色粒子生成 | ADR-0005 ✅ |
| TR-DROP-002 | 0.5s 飘向玩家 | — |
| TR-DROP-003 | BOSS 灵气环形扩散 | — |
| TR-DROP-004 | 同屏粒子上限 50 | ADR-0005 ✅ |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Spirit Particle Visuals | Visual/Feel | Ready | ADR-0002, ADR-0005 |

## Definition of Done

This epic is complete when:
- 灵气粒子正确生成和飘向玩家
- BOSS 灵气环形扩散
- 粒子池正常工作

## Next Step

Run `/create-stories drop-pickup` to break this epic into implementable stories.
