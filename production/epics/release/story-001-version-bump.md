# Story 001: Version Bump

> **Epic**: Release
> **Status**: In Progress
> **Layer**: Release
> **Type**: Release
> **Estimate**: 1h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: All GDDs
**Requirement**: TR-RELEASE-001

**ADR**: N/A — 版本管理
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 版本号更新到 1.0.0
- [ ] project.godot 中版本正确
- [ ] 所有引用版本的地方更新

---

## Implementation Notes

- 更新 project.godot 中的版本号
- 更新 README.md 中的版本信息
- 更新 CHANGELOG.md

---

## Out of Scope

- Story 002: 变更日志

---

## QA Test Cases

- **AC-1**: 版本号
  - Given: project.godot
  - When: 检查版本号
  - Then: 版本号 = 1.0.0

---

## Test Evidence

**Story Type**: Release
**Required evidence**: `production/qa/evidence/version-bump-report.md`
**Status**: [x] Created

---

## Dependencies

- Depends on: Story 002
- Unlocks: Story 003