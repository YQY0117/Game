# Story 003: Object Pool Monitoring

> **Epic**: Scene Management
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Integration
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/run-session-management.md`
**Requirement**: TR-SCENE-007

**ADR Governing Implementation**: ADR-0002: Object Pool
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 池大小监控: 每 5s 输出 available/total 到控制台
- [ ] 动态扩展: 池耗尽时自动创建新实例
- [ ] 池回收: 战斗结束时回收所有活跃实例

---

## Implementation Notes

- ObjectPool 添加 monitor() 函数
- 每 5s 输出: "[Pool] Enemy: 45/100, Projectile: 20/50"
- get_instance() 在池空时自动创建新实例
- return_all() 回收所有子节点

---

## Out of Scope

- Story 001: SceneManager 转场
- Story 002: 对象池基础

---

## QA Test Cases

- **AC-1**: 池监控输出
  - Given: 池有 45 个可用实例
  - When: monitor() 调用
  - Then: 控制台输出 "[Pool] Enemy: 45/100"

- **AC-2**: 动态扩展
  - Given: 池已空
  - When: get_instance() 调用
  - Then: 创建新实例，池大小 +1

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/unit/scene/pool_monitoring_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 002
- Unlocks: None