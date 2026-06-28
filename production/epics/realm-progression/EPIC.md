# Epic: Realm Progression

> **Layer**: Feature
> **GDD**: design/gdd/realm-progression.md
> **Architecture Module**: RealmProgression
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories realm-progression`

## Overview

Realm Progression 是境界突破的协调层——监听突破信号，协调槽位解锁、速度切换、色调切换。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Event Bus | 信号驱动 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-REALM-001 | 突破触发 (灵气条满) | ADR-0001 ✅ |
| TR-REALM-002 | 1.2s 突破仪式 | — |
| TR-REALM-003 | 槽位解锁 | — |
| TR-REALM-004 | 速度切换 | — |
| TR-REALM-005 | 境界色调切换 | — |
| TR-REALM-006 | 飞升终局 | — |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Realm Breakthrough Ceremony | Visual/Feel | Ready | ADR-0001 |

## Definition of Done

This epic is complete when:
- 突破仪式正确播放
- 槽位/速度/色调正确切换
- 飞升触发 victory 状态

## Next Step

Run `/create-stories realm-progression` to break this epic into implementable stories.
