# Story 003: Elite Mob Behavior

> **Epic**: Enemy AI
> **Status**: Ready
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: 2h
> **Manifest Version**: 2026-06-27

## Context

**GDD**: `design/gdd/enemy-ai.md`
**Requirement**: TR-ENEMY-004

**ADR**: N/A — 精英 AI
**Engine**: Godot 4.6 | **Risk**: LOW

---

## Acceptance Criteria

- [ ] 精英 Top mark: 远程，保持距离 + 周期攻击
- [ ] 精英 Side mark: 冲撞，周期性 dash 攻击
- [ ] 精英 Bottom mark: AoE，缓慢靠近 + 范围攻击
- [ ] 精英尺寸 1.0× player，一笔锋标记位置编码威胁

---

## Implementation Notes

- 精英 = 大杂兵 + 一笔锋 (static asymmetric mark)
- Top: 类似飞墨行为
- Side: dash 速度 2.5× player，然后停下
- Bottom: 靠近后释放 80px AoE

---

## Out of Scope

- Story 002: 高级杂兵
- Story 004: LOD 和避让

---

## Test Evidence

**Story Type**: Logic
**Required evidence**: `tests/unit/enemy/elite_test.gd`
**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: Story 002
- Unlocks: Story 004
