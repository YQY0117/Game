# Story 002: Performance Profiling

> **Epic**: Performance
> **Status**: In Progress
> **Layer**: Release
> **Type**: Performance
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: All GDDs
**Requirement**: TR-PERF-001

**ADR**: N/A — 性能分析
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 性能分析报告生成
- [ ] 瓶颈识别
- [ ] 优化建议

---

## Implementation Notes

- 使用 Godot 内置性能分析器
- 测量 CPU/GPU/内存使用
- 识别热点函数

---

## Out of Scope

- Story 001: Web 导出

---

## QA Test Cases

- **AC-1**: 性能分析
  - Given: Web 构建
  - When: 执行性能分析
  - Then: 报告生成，瓶颈识别

---

## Test Evidence

**Story Type**: Performance
**Required evidence**: `tests/unit/performance/performance_profiling_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None