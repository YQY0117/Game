# Epic: Technique System

> **Layer**: Feature
> **GDD**: design/gdd/technique-system.md
> **Architecture Module**: TechniqueSystem
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories technique-system`

## Overview

Technique System 管理玩家可装备的功法——从获取、装备、自动释放到命中结算。每个功法是独立的"自动炮台"，按固定冷却周期自动释放弹幕。功法携带元素标签和笔形骨架，元素匹配产生 Combo 效果。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0004: MultiMesh | 杂兵批量渲染 | MEDIUM |
| ADR-0005: Particle System | GPUParticles2D 粒子池 | MEDIUM |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-TECH-001 | 功法数据结构 (id, element, cooldown, damage) | — |
| TR-TECH-002 | 自动释放机制 (独立冷却) | — |
| TR-TECH-003 | 槽位系统 (2+(R-1)) | — |
| TR-TECH-004 | 元素标签 | — |
| TR-TECH-005 | 伤害结算 (DamageBus) | ADR-0001 ✅ |
| TR-TECH-006 | 笔形骨架 (6种) | ADR-0005 ✅ |
| TR-TECH-007 | 信号契约 | ADR-0001 ✅ |

## Definition of Done

This epic is complete when:
- 6 种 MVP 功法可装备、自动释放、命中造成伤害
- 槽位随境界解锁
- 元素色板匹配 art-bible

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Technique Data & Auto-Fire | Logic | Ready | — |
| 002 | Damage & Element Integration | Integration | Ready | ADR-0001 |
| 003 | Slot Management & Candidate List | Logic | Ready | — |
| 004 | Cooldown Pause & Edge Cases | Logic | Ready | — |
