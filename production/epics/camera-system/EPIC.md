# Epic: Camera System

> **Layer**: Core
> **GDD**: design/gdd/camera-system.md
> **Architecture Module**: CameraSystem
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories camera-system`

## Overview

Camera System 让玩家始终在屏幕中保持可读位置，并通过震屏/微缩放在击中、击退、境界突破等关键节点强化反馈。Camera 是注意力管理工具——决定"玩家能看见多远的危险"。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0001: Event Bus | 信号驱动架构 | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-CAM-001 | 跟随 PC (平滑, 微滞后 60-80ms) | — |
| TR-CAM-002 | 震屏 API (shake) | ADR-0001 ✅ |
| TR-CAM-003 | 微缩放 (zoom_pulse) | — |
| TR-CAM-004 | 强制留白圈保护 | — |
| TR-CAM-005 | 状态色温切换 | — |
| TR-CAM-006 | freeze/unfreeze (Run 状态响应) | ADR-0001 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- Camera 平滑跟随玩家 (微滞后 60-80ms)
- 震屏 API 可被 Damage/Health 调用
- Run 状态变化时 freeze/unfreeze 正确
- 境界色调通过 CanvasModulate 切换

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | Soft-Follow & Deadzone | Logic | Ready | — |
| 002 | Shake System | Logic | Ready | ADR-0001 |
| 003 | Zoom Transitions | Logic | Ready | — |
| 004 | Snap & Hard-Follow | Integration | Ready | — |
| 005 | State Priority & Edge Cases | Integration | Ready | ADR-0001 |
