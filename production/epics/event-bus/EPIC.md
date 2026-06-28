# Epic: Event Bus

> **Layer**: Foundation
> **GDD**: design/gdd/damage-health-system.md, design/gdd/run-session-management.md
> **Architecture Module**: DamageBus, RunSession (Autoloads)
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories event-bus`

## Overview

Event Bus 实现两个全局 Autoload 单例：DamageBus（所有伤害事件的统一处理中心）和 RunSession（全局状态机）。DamageBus 处理 DamageEvent 结构体、元素相克、HP 管理、无敌帧。RunSession 管理 RunState 状态机（menu/loading/playing/paused/breakthrough/dying/dead/victory）和 RunData 统计。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Event Bus | DamageBus + RunSession 为 Autoload，其他用原生信号 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-DAMAGE-001 | DamageEvent 统一接口 | ADR-0001 ✅ |
| TR-DAMAGE-002 | HP=20 固定不递增 | — |
| TR-DAMAGE-003 | 元素相克矩阵 (1.5/0.7/1.0) | — |
| TR-DAMAGE-004 | 无敌帧 600ms | — |
| TR-DAMAGE-005 | DamageBus 同步处理 | ADR-0001 ✅ |
| TR-DAMAGE-006 | 死亡判定 HP≤0 | ADR-0001 ✅ |
| TR-DAMAGE-007 | damage_dealt/hp_changed/entity_died 信号 | ADR-0001 ✅ |
| TR-RUN-001 | RunState 状态机 | ADR-0001 ✅ |
| TR-RUN-002 | run_state_changed 广播 | ADR-0001 ✅ |
| TR-RUN-003 | RunData 统计快照 | — |
| TR-RUN-004 | 暂停期间禁止数据写入 | — |
| TR-RUN-005 | 浏览器后台自动暂停 | — |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- DamageBus 正确处理 DamageEvent（元素相克、HP 扣减、信号广播）
- RunSession 状态机正确切换（9 个状态）
- 所有下游系统能订阅信号并正确响应
- 场景切换后 Autoload 状态保持

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | DamageEvent & DamageBus Core | Logic | Ready | ADR-0001 |
| 002 | HP Management & Element Mult | Logic | Ready | ADR-0001 |
| 003 | Damage Formulas & Edge Cases | Logic | Ready | — |
| 004 | RunSession State Machine | Logic | Ready | ADR-0001 |
| 005 | RunSession Broadcast & Integration | Integration | Ready | ADR-0001 |
