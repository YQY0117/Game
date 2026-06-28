# Story 003: Scene Lifecycle Integration

> **Epic**: Scene Management
> **Status**: Ready
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/run-session-management.md`
**Requirement**: TR-SCENE-005

**ADR Governing Implementation**: ADR-0002 + ADR-0003
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] TR-SCENE-005: 场景加载 <2s (4G 网络)
- [ ] 完整 menu→battle→menu 循环无内存泄漏
- [ ] Autoload 状态在 10 次循环后保持一致

---

## Implementation Notes

- 使用 Godot 的 ResourceLoader 测量加载时间
- 内存检查: OS.get_static_memory_usage() 循环前后对比
- 集成测试: 验证 SceneManager + ObjectPool + RunSession 协同工作

---

## Out of Scope

- Story 002: 对象池本身

---

## QA Test Cases

- **TR-SCENE-005**: 加载时间
  - Given: 4G 网络模拟
  - When: change_scene("battle")
  - Then: 加载完成 <2s

- **内存泄漏**: 循环测试
  - Given: 初始内存 M
  - When: menu→battle→menu 循环 10 次
  - Then: 最终内存 ≤ M × 1.1 (10% 容差)

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/scene/scene_lifecycle_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 002
- Unlocks: None (Epic complete)
