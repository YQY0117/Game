# Epic: Spirit/XP System

> **Layer**: Feature
> **GDD**: design/gdd/spirit-xp-system.md
> **Architecture Module**: SpiritXP
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories spirit-xp`

## Overview

Spirit/XP System 管理灵气收集、存储和消耗。击杀敌人后灵气自动飘向玩家，填满灵气条后自动触发境界突破。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Event Bus | 信号驱动 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-SPIRIT-001 | 灵气自动吸收 | — |
| TR-SPIRIT-002 | 境界需求曲线 (100-700) | — |
| TR-SPIRIT-003 | 灵气掉落量 (1-15) | — |
| TR-SPIRIT-004 | 突破自动触发 | ADR-0001 ✅ |
| TR-SPIRIT-005 | 信号契约 | ADR-0001 ✅ |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Spirit Collection & Breakthrough | Logic | Ready | ADR-0001 |

## Definition of Done

This epic is complete when:
- 灵气自动飘向玩家
- 境界需求曲线正确
- 突破自动触发

## Next Step

Run `/create-stories spirit-xp` to break this epic into implementable stories.
