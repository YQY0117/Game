# Epic: Input System

> **Layer**: Foundation
> **GDD**: design/gdd/input-system.md
> **Architecture Module**: InputSystem
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories input-system`

## Overview

Input System 是统一抽象层，把键盘/鼠标、触屏、Gamepad 三类原始输入归一为语义动作（`move_up`、`move_down`、`pause`、`confirm` 等），供 Player Controller、HUD、Menu System 消费。系统维护当前活跃输入模式（KBM / Touch / Gamepad），通过滞后机制自动切换。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Event Bus | DamageBus + RunSession Autoload，其他用原生信号 | LOW |
| ADR-0003: Scene Management | Godot 场景树 + SceneManager Autoload | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-INPUT-001 | 语义动作映射（不直接读键码） | ADR-0001 ✅ |
| TR-INPUT-002 | 三类设备并行监听 | — |
| TR-INPUT-003 | 滞后切换（3事件/400ms） | — |
| TR-INPUT-004 | 强制模式覆盖（Settings） | — |
| TR-INPUT-005 | 死区与平滑 | — |
| TR-INPUT-006 | 无悬停依赖 | — |
| TR-INPUT-007 | input_mode_changed 信号 | ADR-0001 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- All acceptance criteria from `design/gdd/input-system.md` are verified
- KBM/Touch/Gamepad 三种输入模式正常切换
- 滞后机制防止误触
- Settings 强制模式覆盖生效

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Semantic Action Mapping | Logic | Ready | ADR-0001 |
| 002 | Mode Switch Hysteresis | Logic | Ready | — |
| 003 | Dead Zones & Response Curves | Logic | Ready | — |
| 004 | Touch Joystick & Multi-Finger | Integration | Ready | — |
| 005 | Idle Detection & Focus Loss | Integration | Ready | — |
| 006 | Force Mode & Contract Stability | Integration | Ready | ADR-0001 |
