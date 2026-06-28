# Epic: Boss AI

> **Layer**: Feature
> **GDD**: design/gdd/boss-ai.md
> **Architecture Module**: BossAI
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories boss-ai`

## Overview

Boss AI 定义每个 BOSS 的行为模式——4 拍 Tell 节奏、攻击循环、阶段转换。MVP 实现 4 个 BOSS（3 可选 + 1 守护者）。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0004: MultiMesh | 渲染优化 | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-BOSS-001 | 4 拍 Tell 节奏 | — |
| TR-BOSS-002 | 固定循环攻击模式 | — |
| TR-BOSS-003 | Phase transition (50%/25% HP) | — |
| TR-BOSS-004 | 4 个 MVP BOSS 定义 | — |
| TR-BOSS-005 | 强制留白圈 2.0× | — |

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | State Machine & Tell Rhythm | Logic | Ready | — |
| 002 | MVP Bosses & Phase Transition | Logic | Ready | — |

## Definition of Done

This epic is complete when:
- 4 个 BOSS 行为正确
- 4 拍 Tell 节奏可读
- Phase transition 触发正确

## Next Step

Run `/create-stories boss-ai` to break this epic into implementable stories.
