# Technique System (功法系统)

> **Status**: In Design
> **Author**: user + game-designer + systems-designer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 3 (自创流派 — 功法搭配是玩家表达自我的方式) + Pillar 2 (越战越强 — 功法槽位只增不减)
> **Priority**: MVP | **Layer**: Feature
> **Source Systems Index**: design/gdd/systems-index.md (Order #10)

## Overview

Technique System 管理玩家可装备的功法——从获取、装备、自动释放到命中结算的完整生命周期。每个功法是一个独立的"自动炮台"，按固定冷却周期在玩家周围自动释放弹幕，玩家无需手动操作。功法携带**元素标签**(火/冰/风/雷/剑/拳)和**笔形骨架**(剑气=斜切、掌法=泼墨圆斑、符箓=方印)，元素匹配产生 Combo 效果，笔形通过色相区分流派。

系统的核心设计约束: **流派是色相，不是形状**(art-bible Section 3.3)——一套基础笔形 × 多套色板 = 无限流派表达。功法槽位随境界突破只增不减(Pillar 2 "越战越强")，玩家从"有什么用什么"进化到"为某个 combo 专门规划一局路线"(Pillar 3 "自创流派")。

对玩家而言，这个系统同时是**构筑快感的来源**(搭配功法 combo 的策略乐趣)和**视觉爽感的引擎**(泼彩层满屏绽放)。对技术层而言，它是 `DamageEvent` 的生产者、元素相克矩阵的消费者、VFX/音频事件的触发源。

## Player Fantasy

**Direct — 功法释放是玩家每 30 秒都在感受的视觉+策略快感。**

玩家直接感受的: **泼彩满屏的视觉狂欢**。火球从角色右肩飞出，赤橙粒子拖尾；冰锥从左手凝结，蓝白碎片四散；雷弧从头顶折线劈下，紫金闪烁。每一招都是 art-bible 定义的"泼彩层"——主角越强越静，招式越强越狂。玩家不需要按任何键，但每一次功法释放都在告诉他们: **你的构筑在运转**。

策略层的直接感受: **"先打哪个 BOSS"的路线规划**。BOSS 头顶显示其持有的功法类型和元素标签——玩家看到"那个 BOSS 掉火系功法"，立刻在脑中计算"火+我已有的冰=冰火 combo"。这不是战斗中的操作决策，而是**战斗前的构筑决策**，是"自创流派"支柱的直接体验。

**Indirect — 自动释放计时器、冷却循环、弹幕碰撞检测是玩家不感知的基础设施。**

玩家不感知的: 每个功法的冷却倒计时精确到毫秒、弹幕的碰撞箱形状、元素相克的 1.5/0.7 倍率计算。这些在后台运转，玩家通过"火打冰怪多掉血"的直觉感受，而不需要知道倍率是 1.5。

参考标杆: **Vampire Survivors** 的武器自动释放——玩家从来不按攻击键，但每次武器升级时的"选哪个"决策让人上瘾。**鬼谷八荒**的功法搭配——看到功法的元素标签就能想象 combo 效果，"自创流派"的快感来自**在脑中完成构筑**。我们结合两者: VS 的零操作门槛 + 鬼谷的元素构筑深度。

## Detailed Design

### Core Rules

**1. 功法数据结构**: 每个功法是一个 `Technique` 资源，包含以下属性:
- `id: String` — 唯一标识
- `name: String` — 显示名（如"烈焰掌"）
- `element: Element` — 元素标签（火/冰/风/雷/剑/拳/无）
- `brush_shape: BrushShape` — 笔形骨架（sword_slash / palm_splash / seal_square / cone / arc / aoe_circle）
- `cooldown: float` — 冷却时间（秒）
- `base_damage: int` — 基础伤害（未经元素相克修正）
- `projectile_type: ProjectileType` — 弹幕类型（single / multi / cone / aoe / orbit）
- `projectile_count: int` — 弹幕数量（single=1, multi=3-5, aoe=1 大范围）
- `projectile_speed: float` — 弹幕速度（px/s）
- `projectile_range: float` — 弹幕最大距离（px）
- `knockback_tier: int` — 击退档位（0-4，映射到 Damage GDD F3）

**2. 自动释放机制**: 每个装备的功法维护独立冷却计时器。冷却结束时，功法自动释放弹幕:
- 目标选择: 自动瞄准最近的敌人（`global_position` 最小距离）
- 无敌人时不释放（冷却暂停在 0，不浪费弹幕）
- 释放原点: 玩家 `global_position`（Player Controller GDD 锁定）
- 释放方向: 从玩家指向目标的归一化向量

**3. 槽位系统**:
- 槽位数量: `slot_count = 2 + (R - 1)`，R = 当前境界（1-6）
- R1 炼气 = 2 槽，R2 = 3，R3 = 4，R4 = 5，R5 = 6，R6 飞升 = 7 槽
- 槽位随境界突破自动解锁，**不可退回、不可替换**（Pillar 2 "只增不减"）
- 已装备的功法**不可卸下**——一旦装备，永久占用槽位直到本局结束
- 新获得的功法自动装备到下一个空槽；无空槽时进入"候选列表"，玩家可在下次突破时选择装备

**4. 元素标签与 Combo 前置**:
- 每个功法携带一个元素标签（火/冰/风/雷/剑/拳/无）
- Combo 效果由装备中功法的元素组合触发（详见 Combo System GDD，本 GDD 只定义数据接口）
- MVP 阶段: 6 种基础功法，3 种 combo 效果

**5. 伤害结算流程**:
- 功法弹幕命中敌人 → 构造 `DamageEvent` → 提交 `DamageBus.deal_damage()`
- DamageEvent 包含: `attacker_id=player`, `raw_damage=technique.base_damage`, `element=technique.element`, `knockback_tier=technique.knockback_tier`
- 元素相克倍率由 Damage/Health System 处理（Formula 2），本系统不重复计算

**6. 笔形骨架规则**（art-bible Section 3.3 锁定）:
- 所有功法共享同一套笔形骨架（sword_slash / palm_splash / seal_square / cone / arc / aoe_circle）
- **流派区分完全靠色相**: 火=赤橙，冰=青白，雷=紫金，风=青绿，剑=墨色冷光，拳=墨色朱砂冲击
- 同一笔形换三套色板，形状骨架完全一致（QA 测试: Section 3 Shape Language QA-03）

**7. MVP 功法列表**（1 境界，3+1 BOSS，6 功法）:

| ID | 名称 | 元素 | 笔形 | 冷却 | 伤害 | 弹幕类型 | 掉落 BOSS |
|----|------|------|------|------|------|----------|-----------|
| T01 | 烈焰掌 | 火 | palm_splash | 1.2s | 5 | single, 扇形扩散 | BOSS-A |
| T02 | 冰锥术 | 冰 | cone | 1.8s | 4 | multi×3, 扇形 | BOSS-B |
| T03 | 雷霆斩 | 雷 | sword_slash | 1.0s | 6 | single, 直线穿透 | BOSS-C |
| T04 | 疾风刃 | 风 | arc | 0.8s | 3 | multi×2, 弧线 | BOSS-A |
| T05 | 破甲符 | 无 | seal_square | 2.0s | 8 | single, 直线慢速 | BOSS-B |
| T06 | 天罡剑诀 | 剑 | sword_slash | 1.5s | 7 | single, 直线快速 | 守护者 |

*注: 以上数值为初始设计值，需在原型阶段验证平衡。*

### States and Transitions

**单个功法的状态机**:

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **idle** | 冷却计时器暂停，不释放 | 装备到槽位但无敌人在范围内 | 检测到敌人进入范围 |
| **ready** | 冷却计时器归零，等待释放 | 冷却倒计时完成 | 自动触发释放 |
| **firing** | 构造弹幕实例，播放释放动画和音效 | ready 状态 + 检测到敌人 | 弹幕实例化完成（瞬时） |
| **cooldown** | 冷却计时器倒计时 | 释放完成 | 计时器归零 → ready |

**状态流转**: `idle → ready → firing → cooldown → ready → firing → ...`

**特殊情况**:
- 无敌人时: 冷却暂停在当前值（不归零也不继续），进入 idle；敌人出现后从暂停值继续
- 玩家死亡: 所有功法冻结，冷却计时器暂停
- 境界突破: 槽位数量增加，新槽位的功法从 ready 状态开始

### Interactions with Other Systems

**上游（本系统消费的数据）**:

| 上游 | 接口 | 频率 |
|------|------|------|
| **Player Controller** | 读取 `global_position` 作为释放原点；读取 `current_direction` 用于方向性功法 | 每释放时 |
| **Damage/Health System** | `DamageBus.deal_damage(event)` API — 提交伤害事件 | 每次命中 |
| **Input System** | 无直接交互（自动释放无需玩家输入） | — |
| **Run/Session Management** | 订阅 `run_state_changed` 信号，暂停/恢复冷却计时 | 事件驱动 |

**下游（消费本系统数据的系统）**:

| 下游 | 接口 | 类型 |
|------|------|------|
| **VFX System** | 订阅 `technique_fired(technique_id, position, direction)` 信号，播放释放特效（元素色板 + 笔形） | 信号 |
| **Audio Manager** | 订阅 `technique_fired` 信号，播放释放音效 | 信号 |
| **HUD** | 订阅 `technique_cooldown_update(technique_id, progress)` 信号，更新技能槽冷却显示 | 信号 |
| **Combo System** | 暴露 `get_equipped_elements() -> Array[Element]` 接口，供 Combo 系统查询当前装备的元素组合 | 直接读 |
| **Boss AI** | 间接——BOSS 被功法弹幕命中后通过 DamageBus 收到 DamageEvent | 间接 |
| **Realm Progression** | 订阅 `technique_acquired(technique_id)` 信号，记录功法解锁进度 | 信号 |

**Godot 信号契约**:
- `technique_fired(technique_id: String, position: Vector2, direction: Vector2)` — 功法释放时
- `technique_cooldown_update(technique_id: String, progress: float)` — 冷却进度变化（0.0-1.0）
- `technique_acquired(technique_id: String)` — 获得新功法时
- `technique_equipped(technique_id: String, slot_index: int)` — 功法装备到槽位时

## Formulas

> **顶层设计**: 功法系统不做伤害倍率计算（那是 Damage/Health 的职责），只计算自身运行时的冷却、DPS、和槽位进度。所有公式追求可预测性——玩家应该能从冷却时间和基础伤害推算出 DPS，不需要查表。

---

### Formula 1: 槽位数量（境界递增）

```
slot_count(R) = 2 + (R - 1)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| R | R | int | 1–6 | 当前境界（炼气=1，飞升=6） |
| slot_count | — | int | 2–7 | 当前可用功法槽位数 |

**Output Range**: [2, 7]。R1=2，R2=3，R3=4，R4=5，R5=6，R6=7。

**Worked Example**: 玩家在 R3 金丹期，slot_count = 2 + (3-1) = 4 槽。

**Rationale**: 每境界 +1 槽，玩家每突破一次都有可感知的力量增长。7 槽上限（而非 10+）确保每个槽位仍有策略意义——"6-7 个槽位时，屏幕可读性和策略深度的平衡点"（game-concept.md 风险缓解）。

---

### Formula 2: 单功法 DPS

```
DPS_per_technique = base_damage / cooldown
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| base_damage | D | int | 3–8 | 功法基础伤害（未经元素修正） |
| cooldown | C | float | 0.8–2.0 | 冷却时间（秒） |
| DPS_per_technique | DPS | float | 1.5–7.5 | 单功法每秒伤害 |

**Output Range**: [1.5, 7.5] DPS。低伤害快冷却（风刃 3/0.8=3.75）vs 高伤害慢冷却（破甲符 8/2.0=4.0）。

**Worked Example**: 烈焰掌 DPS = 5 / 1.2 = 4.17 DPS。

**Rationale**: DPS 差异不大（3.75 vs 4.0），但手感差异显著——快冷却给人"连射感"，慢冷却给人"重击感"。平衡锚点: 单功法 DPS ≈ 4.0，6 槽全装备 ≈ 24 DPS（不含元素修正），配合走位可清 R5 150+ 敌人。

---

### Formula 3: 弹幕目标选择（最近敌人）

```
target = argmin(distance(technique_origin, enemy.position) for enemy in enemies_in_range)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| technique_origin | — | Vector2 | — | 玩家 `global_position` |
| enemy.position | — | Vector2 | — | 敌人位置 |
| enemies_in_range | — | Array | 0–150+ | 弹幕射程内的敌人列表 |
| target | — | Enemy | null or Enemy | 最近敌人，无敌人时为 null |

**Edge Cases**:
- 无敌人: 不释放，冷却暂停在 0
- 同距离多个敌人: 按 entity_id 升序选择（确定性）
- 目标在弹幕飞行中死亡: 弹幕继续飞行，命中路径上第一个敌人（穿透型）或消失（非穿透型）

---

### Formula 4: 冷却暂停/恢复

```
if no enemies in range:
    cooldown_timer.paused = true
else:
    cooldown_timer.paused = false
    cooldown_timer continues from paused value
```

**Rationale**: 无敌人时暂停冷却，避免浪费弹幕。玩家不会在安全区域看到功法空放。这也意味着"冷却就绪"只在有敌人时有意义——HUD 显示就绪脉冲的触发条件是 `cooldown_remaining == 0 AND enemies_in_range > 0`。

## Edge Cases

- **如果玩家在功法释放瞬间死亡**: 所有进行中的弹幕立即消失，冷却计时器冻结。复活后从冷却归零重新开始。
- **如果玩家在功法释放瞬间被击退（hitstun）**: 弹幕正常释放，不受击退影响。功法释放是独立于玩家移动的事件——击退只影响位置，不影响已触发的弹幕。
- **如果两个功法同时冷却完成**: 按槽位索引顺序释放（slot 0 先于 slot 1），同帧内依次处理。不产生视觉重叠问题——弹幕有不同笔形和色相。
- **如果目标在弹幕飞行中死亡**: 非穿透型弹幕消失；穿透型弹幕（如雷霆斩）继续飞行，命中路径上第一个敌人。
- **如果玩家无装备功法（所有槽位为空）**: 不释放任何弹幕。冷却计时器不运行。HUD 技能槽区域显示为空。
- **如果新获得功法但无空槽**: 进入"候选列表"（内存中维护），下次境界突破解锁新槽位时，弹出选择界面让玩家挑选装备哪个功法。候选列表最多容纳 3 个功法（防止无限囤积）。
- **如果敌人在弹幕碰撞箱边缘（擦边）**: 命中判定使用 Godot 的 Area2D 重叠检测，不额外处理。擦边 = 命中，与中心命中等效。
- **如果玩家同时拥有 3 个同元素功法**: 正常装备，不触发额外效果。Combo 由元素组合决定，不是同元素叠加（详见 Combo System GDD）。
- **如果功法弹幕与敌人弹幕碰撞**: 不互相影响。玩家弹幕只检测敌人碰撞层，敌人弹幕只检测玩家碰撞层。弹幕之间无交互。

## Dependencies

### 上游依赖（本系统需要）

| 系统 | 依赖类型 | 接口 | 备注 |
|------|----------|------|------|
| **Player Controller** | Hard | `global_position`, `current_direction`, `state_changed` 信号 | 功法释放原点和方向。PC 不存在则功法无法释放。 |
| **Damage/Health System** | Hard | `DamageBus.deal_damage(event)` API, `DamageEvent` 结构体 | 所有伤害必须通过 DamageBus。Damage 不存在则功法无法造成伤害。 |
| **Input System** | Soft | 无直接交互 | 自动释放不需要玩家输入。但 Input 存在确保 PC 可移动。 |
| **VFX System** | Soft | （需假设接口） | 功法释放特效。MVP 可用 placeholder 色块替代。 |
| **Audio Manager** | Soft | （需假设接口） | 功法释放音效。MVP 可静音。 |
| **Run/Session Management** | Hard | `run_state_changed` 信号 | 暂停/恢复冷却计时器。 |

### 下游依赖（需要本系统的系统）

| 系统 | 依赖类型 | 接口 | 备注 |
|------|----------|------|------|
| **Combo System** | Hard | `get_equipped_elements() -> Array[Element]` | Combo 系统查询当前装备的元素组合以触发效果。 |
| **Boss AI** | Soft | 间接——BOSS 被功法弹幕命中后通过 DamageBus 收到事件 | 无直接接口。 |
| **Realm Progression** | Soft | `technique_acquired(technique_id)` 信号 | 记录功法解锁进度，用于局外 Meta-Progression。 |
| **HUD** | Hard | `technique_cooldown_update`, `technique_fired` 信号 | HUD 需要实时显示冷却状态和释放反馈。 |

### 系统边界

- **本系统不处理**: 元素相克计算（Damage 负责）、combo 效果触发（Combo System 负责）、局外解锁持久化（Meta-Progression 负责）、弹幕碰撞物理（Godot Area2D 引擎负责）
- **本系统拥有**: 功法定义数据、冷却计时器、槽位状态、弹幕实例化逻辑

## Tuning Knobs

| 旋钮 | 描述 | 安全范围 | 极端行为 |
|------|------|----------|----------|
| `technique.cooldown` | 单个功法的冷却时间 | 0.5–3.0s | <0.5s: 弹幕密度过高，性能崩塌；>3.0s: 玩家感觉"没在攻击" |
| `technique.base_damage` | 单个功法的基础伤害 | 2–12 | <2: 弹幕像装饰；>12: 单招秒杀杂兵，失去构筑意义 |
| `technique.projectile_speed` | 弹幕飞行速度 | 200–600 px/s | <200: 弹幕太慢，玩家感觉延迟；>600: 弹幕瞬间命中，失去"弹幕飞行"的视觉满足感 |
| `technique.projectile_range` | 弹幕最大距离 | 150–500 px | <150: 功法只在近身有用，限制构筑多样性；>500: 覆盖全屏，走位无意义 |
| `slot_count_max` | 最大槽位数（R6） | 5–8 | <5: 后期构筑深度不足；>8: 屏幕弹幕密度可读性崩塌 |
| `candidate_list_max` | 候选列表容量 | 2–5 | <2: 玩家选择受限；>5: 决策疲劳 |
| `auto_fire_range` | 自动释放检测范围 | 300–800 px | <300: 功法只在贴身时释放；>800: 功法在视野外就开始释放，浪费弹幕 |

## Visual/Audio Requirements

> **Art Bible 绑定**: 功法 VFX 属于"泼彩层"（Section 5.1），主角是"墨色层"。功法特效是玩家唯一被允许的视觉狂欢。

**释放 VFX**:
- 每个元素有独立色板（art-bible Section 4.5）: 火=赤橙渐变，冰=青白，雷=紫金，风=青绿流线，剑=墨色冷光，拳=墨色朱砂冲击
- 笔形骨架决定弹幕形状，色相决定流派识别
- 释放瞬间: 弹幕从玩家 `global_position` 向目标方向飞出，带元素色相的粒子拖尾
- 命中瞬间: 元素色相的短促爆发（0.2s），朱砂红点缀如果致死

**冷却反馈**:
- HUD 技能槽: 冷却中显示朱砂红径向擦除（顺时针从 12 点），就绪时 200ms 脉冲
- 释放音效: 按元素区分（火=爆裂，冰=碎裂，雷=劈裂，风=呼啸，剑=金属，拳=沉闷）

**境界进化**:
- R1: 弹幕小且薄，粒子拖尾短
- R3: 弹幕中等大小，粒子拖尾明显
- R5: 弹幕大且华丽，粒子拖尾长且密集，与主角泼彩层融合

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:technique-system` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## UI Requirements

> **HUD 绑定**: art-bible Section 7.1 已锁定技能槽规格。

**技能槽显示**:
- 4 槽（桌面）/ 2+2 槽（触屏），底部居中
- 方印形状（40×48 桌面，48×56 触屏），朱砂红 1px 边框
- 内容: 功法名称首字（楷体）
- 冷却中: 朱砂红径向擦除 + 字体变灰 50%
- 就绪: 200ms 脉冲（朱砂环外扩 4px + 字体闪白）
- 激活中（如果支持手动触发）: 槽位反转为朱砂实底 + 白字

**功法获取界面**:
- BOSS 击败后，中央显示功法印章（朱砂红 + 功法名 + 元素标签）
- 玩家点击确认夺取 → 功法自动装备到下一个空槽
- 无空槽时显示"候选列表"选择界面

**功法图鉴**（菜单层）:
- 横向卷轴，每个功法 = 方印 + 竖排描述
- 已获得: 朱砂实印
- 未获得: 淡墨轮廓，描述显示"——"

> **📌 UX Flag — Technique System**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for the technique slot HUD and acquisition screen before writing epics.

## Acceptance Criteria

- **GIVEN** 玩家在 R1 炼气期装备 2 个功法，**WHEN** 敌人进入范围，**THEN** 两个功法按各自冷却独立自动释放弹幕，弹幕命中敌人造成伤害。
- **GIVEN** 玩家装备火系功法，**WHEN** 弹幕命中冰系敌人，**THEN** 伤害 = base_damage × 1.5（元素相克），DamageBus 正确结算。
- **GIVEN** 玩家突破到 R2 筑基，**WHEN** 槽位从 2 增加到 3，**THEN** 新槽位解锁，玩家可装备新获得的功法。
- **GIVEN** 玩家已装备 6 个功法（R5），**WHEN** 再次获得新功法，**THEN** 新功法进入候选列表（最多 3 个），等待下次突破解锁槽位。
- **GIVEN** 场景内无敌人，**WHEN** 功法冷却计时器运行中，**THEN** 计时器暂停，不释放弹幕；敌人出现后从暂停值继续。
- **GIVEN** 玩家装备烈焰掌（火，1.2s CD，5 伤害）和冰锥术（冰，1.8s CD，4 伤害），**WHEN** 运行 10 秒，**THEN** 烈焰掌释放约 8 次（10/1.2），冰锥术释放约 5 次（10/1.8），总 DPS ≈ 33 + 20 = 53（不含元素修正）。
- **GIVEN** 玩家在功法释放瞬间被击退，**WHEN** hitstun 生效，**THEN** 弹幕正常释放，不受击退影响。
- **GIVEN** 两个功法同时冷却完成，**WHEN** 同帧检测到释放条件，**THEN** 按槽位索引顺序释放（slot 0 先于 slot 1）。

## Open Questions

- [ ] 功法弹幕是否支持穿透（命中第一个敌人后继续飞行）？当前设计: 雷霆斩穿透，其他不穿透。需原型验证。
- [ ] 候选列表的 UI 交互: 突破时弹出选择界面，还是在暂停菜单中随时可调？
- [ ] 功法释放时是否有短暂的"释放动画"（0.1s）打断玩家移动？当前设计: 不打断，弹幕从玩家位置直接飞出。
- [ ] Combo 效果的具体数值和触发条件，需在 Combo System GDD 中定义。
