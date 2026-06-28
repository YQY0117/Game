# Story 003: Store Metadata

> **Epic**: Release
> **Status**: In Progress
> **Layer**: Release
> **Type**: Release
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: All GDDs
**Requirement**: TR-RELEASE-003

**ADR**: N/A — 商店元数据
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 商店描述准备
- [ ] 截图准备
- [ ] 标签准备

---

## Implementation Notes

- 编写商店描述
- 准备游戏截图
- 准备标签关键词

---

## Out of Scope

- Story 002: 变更日志

---

## QA Test Cases

- **AC-1**: 商店元数据
  - Given: 游戏信息
  - When: 准备商店元数据
  - Then: 描述、截图、标签准备完成

---

## Test Evidence

**Story Type**: Release
**Required evidence**: `tests/unit/release/store_metadata_test.gd`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 001
- Unlocks: None