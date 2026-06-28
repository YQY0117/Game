# Epic: Scene Management

> **Layer**: Foundation
> **GDD**: design/gdd/run-session-management.md (scene transitions)
> **Architecture Module**: SceneManager (Autoload)
> **Status**: Ready
> **Stories**: Not yet created — run `/create-stories scene-management`

## Overview

Scene Management 实现场景加载/卸载和转场动画。SceneManager Autoload 管理菜单场景和战斗场景的切换，使用 art-bible 定义的墨色横扫转场（300ms cover + 200ms dissipate）。场景切换时自动初始化/清理对象池。

## Governing ADRs

| ADR | Decision Summary | Engine Risk |
|-----|-----------------|-------------|
| ADR-0002: Object Pool | 预分配对象池，返回时断开信号 | LOW |
| ADR-0003: Scene Management | Godot 场景树 + SceneManager Autoload | LOW |

## GDD Requirements

| TR-ID | Requirement | ADR Coverage |
|-------|-------------|--------------|
| TR-SCENE-001 | 墨色横扫转场 (300ms + 200ms) | ADR-0003 ✅ |
| TR-SCENE-002 | Autoload 跨场景持久 | ADR-0003 ✅ |
| TR-SCENE-003 | 战斗场景初始化对象池 | ADR-0002 ✅ |
| TR-SCENE-004 | 战斗场景清理（返回所有池对象） | ADR-0002 ✅ |
| TR-SCENE-005 | 场景加载 <2s (4G) | ADR-0003 ✅ |
| TR-SCENE-006 | start_new_run() / return_to_menu() | ADR-0003 ✅ |

## Definition of Done

This epic is complete when:
- All stories are implemented, reviewed, and closed via `/story-done`
- 菜单→战斗场景切换正常，转场动画播放
- 战斗→菜单场景切换正常，对象池清理
- Autoload 状态跨场景保持
- 场景加载时间 <2s

## Stories

| # | Story | Type | Status | ADR |
|---|-------|------|--------|-----|
| 001 | SceneManager & Ink Sweep | Logic | Ready | ADR-0003 |
| 002 | Object Pool Foundation | Logic | Ready | ADR-0002 |
| 003 | Scene Lifecycle Integration | Integration | Ready | ADR-0002, ADR-0003 |
