# Story 002: Object Pool Foundation

> **Epic**: Scene Management
> **Status**: In Progress
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: 3h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/run-session-management.md` (pool init/cleanup)
**Requirement**: TR-SCENE-003, TR-SCENE-004

**ADR Governing Implementation**: ADR-0002: Object Pool
**ADR Decision Summary**: 预分配对象池，返回时断开信号，防止内存泄漏。

**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] TR-SCENE-003: 战斗场景 _ready() 初始化 3 个池 (Enemy 100/200, Projectile 50/100, Particle 100/200)
- [ ] TR-SCENE-004: 战斗场景 _exit_tree() 返回所有池对象并断开信号

---

## Implementation Notes

- ObjectPool 为通用 class，支持 get_instance() / return_instance() / return_all()
- 池化实体: 预创建节点，get 时 visible=true + set_process(true)，return 时 visible=false + set_process(false) + 位置移到屏幕外
- 信号清理: return_instance() 内部断开所有 DamageBus/RunSession 信号
- 3 个池: EnemyPool, ProjectilePool, ParticlePool

---

## Out of Scope

- Story 001: SceneManager 转场
- Story 003: 集成测试

---

## QA Test Cases

- **TR-SCENE-003**: 池初始化
  - Given: 战斗场景加载
  - When: _ready() 执行
  - Then: EnemyPool 实例 100 个，ProjectilePool 50 个，ParticlePool 100 个

- **TR-SCENE-004**: 池清理
  - Given: 战斗场景有活跃实体
  - When: _exit_tree() 执行
  - Then: 所有实体返回池，信号断开

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/scene/object_pool_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: Story 003
