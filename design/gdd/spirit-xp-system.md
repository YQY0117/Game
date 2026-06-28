# Spirit/XP System (灵气系统)

> **Status**: In Design
> **Author**: user + game-designer + systems-designer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 2 (越战越强 — 灵气增长 = 境界突破 = 力量跃迁) + Pillar 1 (近在咫尺 — 灵气条可视化 = 下一个目标永远可见)
> **Priority**: MVP | **Layer**: Progression
> **Source Systems Index**: design/gdd/systems-index.md (Order #8)

## Overview

Spirit/XP System 管理灵气的收集、存储和消耗——它是"境界突破"的燃料系统。击杀敌人后，灵气自动飘向玩家（无需拾取），填满灵气条后自动触发境界突破（解锁功法槽位 + 基础属性跃迁）。灵气条在 HUD 顶部可视化，下一个突破节点清晰可见——这是"近在咫尺"支柱在进度层的直接翻译。

对玩家而言，这个系统是**"再杀 20 个怪就到筑基了"的持续驱动力**。对技术层而言，它是 `entity_died` 信号的消费者、境界突破事件的生产者、HUD 灵气条的数据源。

## Player Fantasy

**Direct — 灵气条是玩家每秒都在看的进度指示器。**

玩家直接感受的: **灵气条缓缓增长的满足感**。击杀敌人后，金色灵气粒子从敌人残骸飘向玩家，灵气条在 HUD 顶部墨色填充——"快了，再杀几个就突破了"。突破瞬间，画面从浅绿变深蓝，新槽位解锁，功法释放频率提升——**这就是"越战越强"的仪式感**。

玩家不需要理解数值，只需要看到"条在涨，快满了"。这是 Survivor-like 的核心反馈循环: **可见的进度 → 可预测的奖励 → 持续的行动动力**。

**Indirect — 灵气数值计算、境界需求曲线、吸收动画计时器是玩家不感知的基础设施。**

参考标杆: **Vampire Survivors** 的经验宝石——击杀后自动飞向玩家，填满条升级，升级时暂停画面选择武器。我们简化为自动突破（无需选择），保留"宝石飞向 player"的视觉满足感。**鬼谷八荒**的灵气条——每个境界需要不同数量灵气，突破时有仪式化动画。我们保留境界差异，简化为自动触发。

## Detailed Design

### Core Rules

**1. 灵气是局内资源**: 每局从 0 开始，死亡后不保留。局外永久解锁由 Meta-Progression 系统管理，本系统只管局内。

**2. 灵气获取流程**:
- 敌人死亡（`entity_died` 信号）→ 在敌人死亡位置生成灵气值（数字）
- 灵气值以金色粒子形式自动飘向玩家（0.5s 线性动画）
- 粒子到达玩家 → 加入玩家灵气池（`current_spirit += drop_amount`）
- **无需拾取**——灵气自动吸收，玩家零操作

**3. 灵气条与境界需求**:
- 灵气条: `current_spirit / spirit_required(current_realm)`
- 灵气条满（`current_spirit >= spirit_required`）→ 自动触发境界突破
- 境界突破后: `current_spirit = 0`，`current_realm += 1`

**4. 境界突破触发**:
- 灵气条满的同一帧，Run/Session 进入 `breakthrough` 状态
- 玩家进入 `immobile` 状态（不可移动，不可被攻击）
- 播放突破动画（art-bible Section 2 境界突破仪式，约 1.2s）
- 动画结束: 解锁新功法槽位（Technique System），恢复玩家控制

**5. 灵气掉落规则**:
- 杂兵: 1-2 灵气（按敌人类型）
- 精英: 3-5 灵气
- BOSS: 10-15 灵气
- 灵气掉落量固定，不随境界变化（境界递增由需求曲线承担）

**6. 灵气溢出处理**:
- 如果击杀 BOSS 导致灵气超过需求，多余灵气**不保留**
- 突破后 `current_spirit = 0`，无论溢出多少

### States and Transitions

**灵气条状态**:

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **filling** | 灵气从 0 增长到需求值 | 境界突破后 / 新局开始 | 灵气条满 |
| **full** | 灵气 = 需求值，触发突破 | filling 达到需求值 | 突破动画开始 |
| **breakthrough** | 播放突破动画，玩家无敌 | full 状态触发 | 动画结束（1.2s） |

**状态流转**: `filling → full → breakthrough → filling → ...`

### Interactions with Other Systems

**上游（本系统消费的数据）**:

| 上游 | 接口 | 频率 |
|------|------|------|
| **Damage/Health System** | 订阅 `entity_died(entity_id)` 信号，获取击杀事件 | 事件驱动 |
| **Run/Session Management** | 调用 `set_run_state("breakthrough")` 进入突破状态 | 每次突破 |

**下游（消费本系统数据的系统）**:

| 下游 | 接口 | 类型 |
|------|------|------|
| **Realm Progression** | 订阅 `realm_breakthrough(new_realm)` 信号，触发境界属性更新 | 信号 |
| **Technique System** | 订阅 `realm_breakthrough` 信号，解锁新功法槽位 | 信号 |
| **HUD** | 订阅 `spirit_changed(current, max)` 信号，更新灵气条显示 | 信号 |
| **VFX System** | 订阅 `spirit_absorbed(position, amount)` 信号，播放灵气飘向玩家动画 | 信号 |
| **Audio Manager** | 订阅 `realm_breakthrough` 信号，播放突破音效 | 信号 |
| **Player Controller** | 订阅 `realm_breakthrough` 信号，调用 `set_immobile(true/false)` | 信号 |

**Godot 信号契约**:
- `spirit_changed(current_spirit: int, required_spirit: int)` — 灵气变化时
- `realm_breakthrough(new_realm: int)` — 境界突破时
- `spirit_absorbed(position: Vector2, amount: int)` — 灵气被吸收时（供 VFX）

## Formulas

> **顶层设计**: 灵气需求曲线采用线性递增——早期快突破（玩家快速体验成长），后期慢突破（延长后期游戏时间）。数值规模小（100-700），玩家可心算。

---

### Formula 1: 境界灵气需求

```
spirit_required(R) = 100 + 100 × (R - 1) + 50 × (R - 1) × (R - 2) / 2
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| R | R | int | 1–5 | 当前境界（炼气=1，大乘=5） |
| spirit_required | — | int | 100–700 | 当前境界突破所需灵气 |

**Output Range**: [100, 700]。

**Worked Example:**

| R | 境界 | 灵气需求 | Δ |
|---|------|----------|---|
| 1 | 炼气→筑基 | 100 | — |
| 2 | 筑基→金丹 | 200 | +100 |
| 3 | 金丹→元婴 | 350 | +150 |
| 4 | 元婴→大乘 | 550 | +200 |
| 5 | 大乘→飞升 | 700 | +150 |

**Rationale**: R1 只需 100 灵气（约 50-100 个杂兵），5 分钟内可突破，让玩家快速体验第一次成长。R5 需要 700 灵气（约 350-700 个杂兵），需要 15-20 分钟，延长后期游戏时间。

---

### Formula 2: 灵气掉落量

```
spirit_drop(enemy_type) = base_drop[enemy_type]
```

**Variables:**

| Enemy Type | Base Drop | 说明 |
|------------|-----------|------|
| 杂兵（墨滴） | 1 | 最常见，稳定增长 |
| 杂兵（散墨/闷墨/飞墨/群墨） | 2 | 稍强杂兵给更多 |
| 精英 | 3–5 | 稀有，给显著灵气 |
| BOSS | 10–15 | 击杀 BOSS 是重大进展 |

**Rationale**: 杂兵掉 1-2，精英掉 3-5，BOSS 掉 10-15。数值小，玩家可心算"再杀 20 个就突破了"。

---

### Formula 3: 灵气吸收动画时长

```
absorb_duration = 0.5s (固定)
absorb_speed = distance(player, spirit_origin) / absorb_duration
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| distance | d | float | 0–500 px | 灵气生成位置到玩家的距离 |
| absorb_duration | T | float | 0.5s (固定) | 吸收动画时长 |
| absorb_speed | v | float | 0–1000 px/s | 灵气粒子飞行速度 |

**Rationale**: 固定时长保证视觉一致性——无论距离远近，灵气都在 0.5s 内到达玩家。近距离灵气飞得慢，远距离飞得快，但玩家感知是"每次击杀后半秒收到灵气"。

## Edge Cases

- **如果灵气条满但玩家正在 hitstun**: hitstun 结束后立即触发突破。不打断击退动画，但突破不会被延迟超过 hitstun 时长（最多 300ms）。
- **如果灵气条满但玩家已经死亡**: 突破不触发。灵气随死亡清零。下局从 0 开始。
- **如果多个敌人同时死亡导致灵气超过需求**: 灵气逐个累加，达到需求立即触发突破。多余灵气不保留（溢出截断）。
- **如果 BOSS 击杀导致灵气远超需求**: 同上——突破触发，多余灵气丢弃。BOSS 灵气是"快速推进"奖励，不是"囤积"资源。
- **如果玩家在灵气吸收动画中死亡**: 灵气粒子消失，不加入灵气池。死亡清零。
- **如果境界突破期间有新敌人生成**: 突破期间 Run/Session 处于 `breakthrough` 状态，Enemy Spawner 暂停生成。无新敌人。
- **如果 R5 大乘期灵气条满**: 触发飞升突破（终局），Run/Session 进入 `victory` 状态。

## Dependencies

### 上游依赖（本系统需要）

| 系统 | 依赖类型 | 接口 | 备注 |
|------|----------|------|------|
| **Damage/Health System** | Hard | `entity_died(entity_id)` 信号 | 灵气掉落的触发源。Damage 不存在则灵气无法获取。 |
| **Run/Session Management** | Hard | `set_run_state("breakthrough")` API | 境界突破时暂停游戏流程。 |

### 下游依赖（需要本系统的系统）

| 系统 | 依赖类型 | 接口 | 备注 |
|------|----------|------|------|
| **Realm Progression** | Hard | `realm_breakthrough(new_realm)` 信号 | 境界属性更新的触发源。 |
| **Technique System** | Hard | `realm_breakthrough` 信号 | 功法槽位解锁的触发源。 |
| **HUD** | Hard | `spirit_changed(current, max)` 信号 | 灵气条显示的数据源。 |
| **VFX System** | Soft | `spirit_absorbed(position, amount)` 信号 | 灵气飘向玩家的动画。MVP 可用 placeholder。 |
| **Audio Manager** | Soft | `realm_breakthrough` 信号 | 突破音效。MVP 可静音。 |
| **Player Controller** | Hard | `realm_breakthrough` 信号 | 突破期间设为 immobile。 |

## Tuning Knobs

| 旋钮 | 描述 | 安全范围 | 极端行为 |
|------|------|----------|----------|
| `spirit_required(R)` | 各境界灵气需求 | 50–1000 | <50: 突破太快，无成长感；>1000: 突破太慢，玩家失去耐心 |
| `spirit_drop.base` | 杂兵基础灵气掉落 | 1–3 | <1: 增长太慢；>3: 增长太快，境界突破失去重量感 |
| `spirit_drop.boss` | BOSS 灵气掉落 | 5–20 | <5: BOSS 击杀无进度奖励；>20: 单个 BOSS 跳过整个境界 |
| `absorb_duration` | 灵气吸收动画时长 | 0.3–1.0s | <0.3: 动画太快，无满足感；>1.0: 动画太慢，打断战斗节奏 |
| `breakthrough_duration` | 境界突破动画时长 | 0.8–2.0s | <0.8: 突破无仪式感；>2.0: 突破太长，打断游戏节奏 |

## Visual/Audio Requirements

**灵气粒子**:
- 色相: 金色（`#C8A055`，art-bible Section 4.1 Goldleaf）
- 形状: 小圆形光点（8×8 px），带微弱拖尾
- 运动: 从敌人死亡位置线性飘向玩家，0.5s 到达
- 到达瞬间: 微弱金色闪光（0.1s）

**灵气条**:
- HUD 顶部水平线（art-bible Section 7.1）
- 墨色填充由左至右晕开（卷轴展开效果）
- 突破节点: 未到达 = 淡墨轮廓，到达 = 朱砂红标记

**境界突破动画**:
- 0-200ms: 游戏世界减速至 30%，HUD 淡出
- 200-500ms: 墨色从屏幕中心扩张，覆盖全屏
- 500-800ms: 新境界名称以朱砂印章出现（如"筑基"）
- 800-1100ms: 境界描述文字出现
- 1100-1200ms: 墨色消散，画面切换到新境界色调

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:spirit-xp-system` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## UI Requirements

**灵气条**（HUD 顶部）:
- 位置: 顶部居中（art-bible Section 7.1 Top strip, 0.20-0.80, 0.02）
- 样式: 水平线，3px 高，墨色填充
- 突破节点: 在灵气条上标记 4-5 个节点（对应 R1-R5），已到达 = 朱砂红，未到达 = 淡墨
- 透明度: 常驻 α=0.5，战斗中 α=1.0

**境界标识**（HUD 右上角）:
- 朱砂印章，显示当前境界名称（如"炼气"）
- 突破时印章短暂放大 + 朱砂闪光

**突破确认**（无交互，自动触发）:
- 突破动画结束后自动恢复游戏
- 无需玩家点击确认

## Acceptance Criteria

- **GIVEN** 玩家在 R1 炼气期，**WHEN** 击杀 50 个杂兵（每个掉 2 灵气），**THEN** 灵气条满（100/100），自动触发筑基突破。
- **GIVEN** 灵气条满触发突破，**WHEN** 突破动画播放，**THEN** 玩家处于 immobile 状态，不可移动不可被攻击，持续约 1.2s。
- **GIVEN** 突破完成，**WHEN** 游戏恢复，**THEN** 功法槽位从 2 增加到 3，灵气条重置为 0/200（R2 需求）。
- **GIVEN** 玩家击杀 BOSS（掉 15 灵气），**WHEN** 灵气从 85 增加到 100（R1 需求），**THEN** 突破触发，多余灵气（0）不保留。
- **GIVEN** 玩家正在 hitstun 时灵气条满，**WHEN** hitstun 结束（300ms 内），**THEN** 立即触发突破。
- **GIVEN** 玩家死亡，**WHEN** 灵气为 50/100，**THEN** 灵气清零，下局从 0 开始。
- **GIVEN** R5 大乘期灵气条满，**WHEN** 突破触发，**THEN** Run/Session 进入 `victory` 状态（飞升通关）。

## Open Questions

- [ ] 灵气条是否显示具体数值（如"50/100"）还是只显示填充进度？当前设计: 只显示进度条，不显示数字（保持视觉简洁）。
- [ ] BOSS 灵气是否在击杀瞬间直接加入灵气池，还是也需要飘向玩家？当前设计: 也需要飘向玩家（保持视觉一致性）。
- [ ] 境界突破时是否暂停所有敌人行动？当前设计: 是，Run/Session 的 `breakthrough` 状态暂停 Enemy Spawner。
