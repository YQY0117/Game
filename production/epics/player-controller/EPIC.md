# Epic: Player Controller

> **Layer**: Core
> **GDD**: design/gdd/player-controller.md
> **Architecture Module**: PlayerController
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories player-controller`

## Overview

Player Controller 把 Input System 的归一化方向向量转换为角色在 2D 世界中的实际位移，管理运动状态机 (idle/running/hitstun/immobile)，并通过信号广播位置和速度供下游消费。它是玩家"风暴之眼"幻想的执行层——走位是玩家唯一持续的主动表达。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Event Bus | 信号驱动架构 | LOW |
| ADR-0002: Object Pool | 池化管理 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-PC-001 | 方向输入即移动 (无加速度延迟) | — |
| TR-PC-002 | 轻度加减速 (60ms/30ms) | — |
| TR-PC-003 | 境界基础速度 (88-124 px/s) | — |
| TR-PC-004 | 无主动闪避/无冲刺 | — |
| TR-PC-005 | 击退由外部驱动 (apply_knockback) | ADR-0001 ✅ |
| TR-PC-006 | 位置只能由 PC 自己写 | — |
| TR-PC-007 | 碰撞与穿透 (CharacterBody2D) | — |
| TR-PC-008 | clearance_radius 数据属性 | — |
| TR-PC-009 | delta-time 弹性 | — |
| TR-PC-010 | 状态机 (idle/running/hitstun/immobile) | — |
| TR-PC-011 | 信号契约 (position_changed, velocity_changed, state_changed, realm_transitioned) | ADR-0001 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- 玩家可通过 WASD/方向键控制角色移动
- 境界速度公式正确 (R1=88, R6=124 px/s)
- 击退系统正常工作
- 4 个状态正确切换
- 下游系统能订阅信号

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Movement Core | Logic | Ready | — |
| 002 | Realm Speed & Clearance | Logic | Ready | — |
| 003 | Knockback & Hitstun | Integration | Ready | ADR-0001 |
| 004 | State Machine & Collision | Integration | Ready | ADR-0001 |
| 005 | Performance & Signals | Integration | Ready | ADR-0001 |
