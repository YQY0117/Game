# Story 001: SceneManager & Ink Sweep Transition

> **Epic**: Scene Management
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/run-session-management.md` (scene transitions)
**Requirement**: TR-SCENE-001, TR-SCENE-002, TR-SCENE-006

**ADR Governing Implementation**: ADR-0003: Scene Management
**ADR Decision Summary**: Godot 场景树 + SceneManager Autoload，墨色横扫转场 (300ms cover + 200ms dissipate)。

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] TR-SCENE-001: 墨色横扫转场 300ms 覆盖 + 200ms 消散
- [ ] TR-SCENE-002: Autoload 跨场景持久 (DamageBus, RunSession, SceneManager, InputSystem)
- [ ] TR-SCENE-006: start_new_run() 触发 menu→battle 切换，return_to_menu() 触发 battle→menu 切换

---

## Implementation Notes

- SceneManager 为 Autoload (project.godot 中配置)
- change_scene() 流程: emit transition_started → 播放 cover 动画 → get_tree().change_scene_to_file() → 播放 dissipate 动画 → emit transition_completed
- 墨色横扫: CanvasLayer + ColorRect 从右到左覆盖 (300ms)，再从左到右消散 (200ms)
- 场景结构: /Main → Autoloads + CurrentScene (swapped)

---

## Out of Scope

- Story 002: 对象池
- Story 003: 集成测试

---

## QA Test Cases

- **TR-SCENE-001**: 转场动画
  - Given: 当前在 menu 场景
  - When: change_scene("battle")
  - Then: 墨色横扫 300ms + 消散 200ms，总 500ms

- **TR-SCENE-002**: Autoload 持久
  - Given: DamageBus 有状态数据
  - When: 场景切换
  - Then: DamageBus 状态保持不变

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/scene/scene_manager_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: None
- Unlocks: Story 002
