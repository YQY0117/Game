# Drop/Pickup System (掉落/拾取系统)

> **Status**: In Design
> **Author**: user + game-designer + systems-designer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 1 (近在咫尺 — 灵气飘向玩家的视觉驱动力) + Pillar 2 (越战越强 — 每次击杀都有可见奖励)
> **Priority**: MVP | **Layer**: Economy
> **Source Systems Index**: design/gdd/systems-index.md (Order #11)

## Overview

Drop/Pickup System 是灵气掉落的**视觉表现层**——它不管理灵气数值（那是 Spirit/XP System 的职责），只负责"灵气从敌人死亡位置飘向玩家"的粒子动画。系统监听 `entity_died` 信号，在敌人死亡位置实例化灵气粒子，0.5s 后飘向玩家，到达后触发 `spirit_absorbed` 信号。

本系统在 MVP 阶段极其轻量——只有灵气一种掉落物，且自动吸收无需拾取交互。未来扩展（功法碎片、临时 Buff、装备掉落）可在此框架上叠加，但 MVP 不需要。

## Player Fantasy

**Direct — 每次击杀都有金色光点飘向你的视觉奖励。**

玩家感受的:**击杀后的即时视觉反馈**。敌人死亡瞬间，金色灵气粒子从残骸中升起，0.5s 内飘向玩家——这是"越战越强"的微仪式。粒子不需要玩家操作，但它的存在告诉玩家:"你杀了这个敌人，你变强了。"

参考标杆:**Vampire Survivors** 的经验宝石——击杀后绿色光点飞向玩家。我们保留"飞向 player"的视觉满足感，但简化为直接飘向（无落地中间态），匹配"轻度操作"支柱。

## Detailed Design

### Core Rules

**1. 掉落物类型**: MVP 阶段仅灵气一种。未来可扩展功法碎片、临时 Buff 等。

**2. 灵气粒子生成**:
- 触发: 订阅 `entity_died(entity_id)` 信号
- 位置: 敌人死亡位置（`entity.global_position`）
- 数量: 1-3 个粒子（按灵气掉落量，每个粒子代表 1 灵气）
- 大小: 8×8 px（小圆形光点）
- 色相: 金色 `#C8A055`（art-bible Section 6.4，全境界统一）

**3. 灵气粒子行为**:
- 生成后 0.2s 延迟（让玩家看到粒子升起）
- 0.2s 后开始飘向玩家（线性插值，0.5s 到达）
- 到达玩家位置 → 粒子消失，触发 `spirit_absorbed(position, amount)` 信号
- Spirit/XP System 监听此信号，累加灵气值

**4. 视觉约束**（art-bible Section 6.4 锁定）:
- 灵气粒子使用境界对比色（金色），确保在所有境界背景下可见
- 粒子带微弱柔光（α=0.6→1.0 循环，0.3s 周期）
- 粒子不使用飞白或泼彩（那是玩家/BOSS 专属语言）
- 粒子数量上限: 同屏 ≤ 50 个灵气粒子（性能约束）

**5. BOSS 灵气掉落**:
- BOSS 击杀后生成 10-15 个灵气粒子（按 Spirit/XP GDD 的 BOSS 掉落量）
- 粒子从 BOSS 死亡位置环形扩散 0.3s，然后飘向玩家
- 视觉上比杂兵掉落更壮观（更多粒子、更大的柔光）

### States and Transitions

**灵气粒子状态**:

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **spawning** | 从敌人死亡位置升起，0.2s 延迟 | `entity_died` 信号触发 | 0.2s 后 |
| **flying** | 飘向玩家，0.5s 线性插值 | spawning 结束 | 到达玩家位置 |
| **absorbed** | 粒子消失，触发信号 | flying 到达 | 瞬时 |

**状态流转**: `spawning → flying → absorbed`

### Interactions with Other Systems

**上游**:

| 上游 | 接口 | 频率 |
|------|------|------|
| **Damage/Health System** | 订阅 `entity_died(entity_id)` 信号 | 事件驱动 |
| **Spirit/XP System** | 获取 `spirit_drop(enemy_type)` 掉落量 | 每次生成 |

**下游**:

| 下游 | 接口 | 类型 |
|------|------|------|
| **Spirit/XP System** | `spirit_absorbed(position, amount)` 信号 | 信号 |
| **VFX System** | 粒子视觉效果由 VFX System 渲染（MVP 用 placeholder） | 委托 |
| **Audio Manager** | 灵气吸收音效（微弱"叮"声） | 委托 |

**Godot 信号契约**:
- `spirit_absorbed(position: Vector2, amount: int)` — 灵气被吸收时

## Formulas

### Formula 1: 灵气粒子数量

```
particle_count(drop_amount) = clamp(drop_amount, 1, 3)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| drop_amount | D | int | 1–15 | 灵气掉落量 |
| particle_count | P | int | 1–3 | 生成的粒子数 |

**Rationale**: 杂兵掉 1-2 灵气 → 1-2 粒子。精英掉 3-5 → 3 粒子。BOSS 掉 10-15 → 特殊处理（环形扩散 + 更多粒子）。

### Formula 2: 灵气粒子飞行时间

```
fly_duration = 0.5s (固定)
```

**Rationale**: 固定时长保证视觉一致性——无论距离远近，灵气都在 0.5s 内到达玩家。

## Edge Cases

- **如果灵气粒子生成时玩家已死亡**: 粒子正常生成，但不飘向玩家（目标消失）。粒子在原地悬浮 2s 后消失。
- **如果同屏灵气粒子达到 50 上限**: 暂停生成新粒子，等现有粒子被吸收后再生成。不丢失灵气值（Spirit/XP 直接累加）。
- **如果 BOSS 死亡生成 15 个粒子**: 特殊处理——环形扩散 0.3s，然后分批飘向玩家（每批 5 个，间隔 0.2s）。
- **如果敌人在屏幕外死亡**: 粒子在屏幕外生成，正常飘向玩家。玩家会看到粒子从屏幕边缘飞入。

## Dependencies

### 上游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Damage/Health System** | Hard | `entity_died(entity_id)` 信号 |
| **Spirit/XP System** | Hard | `spirit_drop(enemy_type)` 掉落量 |

### 下游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Spirit/XP System** | Hard | `spirit_absorbed(position, amount)` 信号 |
| **VFX System** | Soft | 粒子渲染委托（MVP 可 placeholder） |
| **Audio Manager** | Soft | 吸收音效 |

## Tuning Knobs

| 旋钮 | 描述 | 安全范围 | 极端行为 |
|------|------|----------|----------|
| `particle_size` | 灵气粒子大小 | 4–16 px | <4: 看不见；>16: 太大，遮挡战斗 |
| `particle_spawn_delay` | 生成延迟 | 0.1–0.5s | <0.1: 太快无感；>0.5: 延迟明显 |
| `particle_fly_duration` | 飞行时长 | 0.3–1.0s | <0.3: 太快无满足感；>1.0: 太慢，打断节奏 |
| `particle_glow_cycle` | 柔光脉冲周期 | 0.2–0.5s | <0.2: 闪烁太快；>0.5: 脉冲太慢 |
| `max_particles_on_screen` | 同屏粒子上限 | 30–100 | <30: 粒子稀少；>100: 性能风险 |

## Visual/Audio Requirements

**灵气粒子视觉**:
- 色相: 金色 `#C8A055`（art-bible Section 6.4）
- 形状: 小圆形光点（8×8 px）
- 柔光: α=0.6→1.0 循环，0.3s 周期
- 拖尾: 无（保持简洁）
- 到达瞬间: 微弱金色闪光（0.1s）

**BOSS 灵气视觉**:
- 更多粒子（10-15 个）
- 环形扩散 0.3s
- 分批飘向玩家（每批 5 个，间隔 0.2s）

**音效**:
- 灵气吸收: 微弱"叮"声（金属质感，不刺耳）
- BOSS 灵气吸收: 更厚重的"嗡"声

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:drop-pickup-system` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## UI Requirements

本系统无独立 UI 需求。灵气粒子在世界层渲染，不涉及 HUD 元素。

## Acceptance Criteria

- **GIVEN** 杂兵死亡（掉 2 灵气），**WHEN** `entity_died` 触发，**THEN** 在死亡位置生成 2 个金色粒子，0.2s 延迟后飘向玩家，0.5s 到达。
- **GIVEN** 灵气粒子到达玩家，**WHEN** 吸收完成，**THEN** 触发 `spirit_absorbed(position, 2)` 信号，Spirit/XP 累加 2 灵气。
- **GIVEN** BOSS 死亡（掉 15 灵气），**WHEN** 触发，**THEN** 生成 15 个粒子，环形扩散 0.3s，分批飘向玩家。
- **GIVEN** 同屏 50 个灵气粒子，**WHEN** 新粒子待生成，**THEN** 暂停生成，等现有粒子被吸收后恢复。
- **GIVEN** 玩家死亡时有灵气粒子在飞行中，**WHEN** 死亡触发，**THEN** 粒子悬浮 2s 后消失，不飘向玩家。

## Open Questions

- [ ] 灵气粒子是否需要微弱的物理效果（如重力下坠）还是纯直线飞行？
- [ ] BOSS 灵气的环形扩散是否需要 BOSS 死亡动画配合？
- [ ] 灵气吸收音效是否需要叠加（多个粒子同时到达时）？
