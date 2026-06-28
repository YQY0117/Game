# Epic: HUD

> **Layer**: Presentation
> **GDD**: design/gdd/hud.md
> **Architecture Module**: HUD
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories hud`

## Overview

HUD 是战斗界面的信息汇总层——订阅各系统的信号并渲染灵气条、技能槽、BOSS 血条、境界标识、玩家锚定 HP 环。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Event Bus | 信号驱动架构 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-HUD-001 | HUD 透明度策略 | ADR-0001 ✅ |
| TR-HUD-002 | 灵气条显示 | ADR-0001 ✅ |
| TR-HUD-003 | 技能槽冷却显示 | ADR-0001 ✅ |
| TR-HUD-004 | BOSS 血条显示 | ADR-0001 ✅ |
| TR-HUD-005 | 玩家 HP 环 | ADR-0001 ✅ |

## Definition of Done

This epic is complete when:
- HUD 透明度策略正确 (idle/combat/post_combat)
- 灵气条、技能槽、BOSS 血条、境界标识、HP 环全部工作
- Trinity 色隔离 (世界色不出现在 UI)

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | HUD Transparency & Realm Indicator | UI | Ready | — |
| 002 | Spirit Bar & Technique Slots | UI | Ready | — |
| 003 | Boss HP Bar & Player HP Ring | UI | Ready | — |

## Next Step

Run `/create-stories hud` to break this epic into implementable stories.
