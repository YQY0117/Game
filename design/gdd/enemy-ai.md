# Enemy AI

> **Status**: In Design
> **Author**: user + game-designer + ai-programmer + systems-designer + qa-lead
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 1 (近在咫尺 — 敌人逼近创造紧迫感) + Pillar 3 (自创流派 — 不同流派应对不同杂兵)
> **Priority**: MVP | **Layer**: Feature
> **Source Systems Index**: design/gdd/systems-index.md (Order #6)

## Overview

Enemy AI 实现 5 种杂兵类型 + 精英变种的运动行为、感知决策和攻击逻辑。它**不**负责生成敌人(那是 Enemy Spawner 的事),也**不**直接处理伤害(走 DamageBus),只决定"这个敌人此刻做什么":朝玩家走、追击、悬停射击、爆裂分裂、攻击间隔。

art-bible Section 5.3 已锁定 5 种杂兵的视觉和运动**关键词**(墨滴=linear drift, 散墨=curved swarm, 闷墨=slow predictable, 飞墨=hover & range, 群墨=drift then split)——本 GDD 把这些关键词翻译成可实现的 AI 行为规范。同时定义精英(1.0× 玩家大小,带"一笔锋"标记位置编码威胁类型:top=远程, side=冲撞, bottom=AoE)的具体行为。

**核心设计哲学**: 每种杂兵的"个性"完全由**运动行为**而非静态剪影定义(art-bible Section 5.3 锁定)。150+ 实体同屏时,玩家在 0.3 秒内通过运动模式识别威胁类型——所以每种类型的运动必须**视觉上独特、机械上简单**。

## Player Fantasy

**Both — 玩家直接感受被"墨潮"包围的压迫感,但 AI 决策逻辑是隐性的。**

玩家直接感受的:**有方向感的混乱**。art-bible Section 5.3 把杂兵定义为"weather, not characters"——它们是天气,不是角色。玩家看到的不是 150 个"敌人",而是一片向自己涌来的墨色潮水,**但这片潮水里能识别出 5 种不同的"水流形态"**。墨滴是直线推进的步兵潮,散墨是斜向包夹的游击,闷墨是缓慢移动的肉盾墙,飞墨是远距离的雨点,群墨是会爆裂的炸弹团。

玩家不会察觉的:每个敌人的具体决策逻辑、寻路成本、感知半径——这些是隐性基础设施。**好的 AI 让玩家觉得"敌人很聪明",实际是"敌人的运动模式让玩家能预测但又来不及完全应对"**。

参考标杆: **Vampire Survivors** 的杂兵几乎只做单一行为(linear chase),靠数量制造压力——我们 5 种类型提供更多变化,但每种类型本身仍极简。**Brotato** 的快速冲锋/远程/分裂等多类敌人组合——我们的目标类似,但**通过 art-bible 锁定每种类型的运动语言保证视觉一致性**。

这个系统的成功 = 玩家能在 R5 大乘期 150 敌人混战中说"该死,飞墨在头顶,我得先打掉它们再冲过去那群闷墨"——他们**用类型名思考**,而不是"我得打那个红色的"或"打远的那个"。

> **Note**: `creative-director` not consulted — Lean mode; art-bible Section 5.3 (5 mob types, weather-not-characters) 已锁定 Player Fantasy 核心。

## Detailed Design

### Core Rules

1. **Steering Behaviors 而非 A* 寻路**: 杂兵直接朝 `PC.global_position` 方向移动,加上各类型独有的 steering modifier(curve、hover、cluster 等)。Survivor-like 极简地图无复杂障碍,steering 足够且 150 实体可负担。
2. **Pull 模型读 PC 位置**: 每个敌人在 `_physics_process` 中读 `PlayerController.global_position`,不订阅 `position_changed` 信号(避免 150 个订阅者的开销)。
3. **运动是身份**: 每种杂兵类型通过**独特的 steering modifier** 实现 art-bible Section 5.3 锁定的运动语言:
   - **墨滴**: 纯 seek behavior,直接朝玩家
   - **散墨**: seek + 侧向正弦偏移(curved swarm pathing)
   - **闷墨**: seek + 速度限制 + 加减速延迟(slow, predictable)
   - **飞墨**: 保持距离 stay-at-range + 周期性 projectile 发射
   - **群墨**: 慢速 seek;受击后**爆裂为 3-5 个散墨**(art-bible 锁定行为)
4. **AI tick LOD**: 距离 PC > 600px 的敌人 AI tick 降频(每 2 帧 tick 一次);> 1200px 每 4 帧 tick;离 viewport 太远的暂停 tick(直到回到视野内)。
5. **感知半径硬上限**: 杂兵感知半径 = 整个地图(总是知道玩家位置)——art-bible 锁定"墨潮"特征,杂兵不会"丢失"玩家。但攻击半径有限制(见 Section D)。
6. **Boss 留白圈避让**: 杂兵在 BOSS 周围 2.0× 角色直径半径内**强制清除**或推开(art-bible Section 5.2 锁定)。Enemy AI 检测距离 BOSS 距离,如果在范围内则触发 emergency steering 推开。
7. **敌人之间不碰撞**: 敌人之间用 `boids` 风格的 separation(轻微推开),但允许重叠——150+ 实体严格碰撞性能不可接受。
8. **击退由 PC 应用**: 敌人不主动产生位移以外的运动。受到玩家攻击时,Damage System emit `damage_dealt(victim=this_enemy)`,Enemy AI 订阅此信号并应用短时间击退(基于攻击者的 knockback_tier)。
9. **精英特殊行为**: 精英 = 大杂兵(1.0× player size)+ 标记位置决定威胁类型:
   - **Top mark**(远程): 类似飞墨,保持距离,周期攻击
   - **Side mark**(冲撞): 周期性 dash 攻击(快速直冲玩家然后停下)
   - **Bottom mark**(AoE): 缓慢靠近,到攻击范围后释放地面 AoE
10. **死亡触发 Damage 信号**: 敌人 HP ≤ 0 时,**Damage System 已 emit `entity_died`**——Enemy AI 自己只需要从 SceneTree 移除(或返回对象池)。下游响应(掉落、Spirit、VFX)由 Damage 系统的信号驱动。

### States and Transitions

每个敌人是简单状态机:

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **spawning** | 渐现 0.2s(art-bible "墨从纸上渗出"风格),期间不可被攻击,velocity=0 | Enemy Spawner 实例化 | 0.2s 后自动 |
| **active** | 默认状态,按类型 steering + 攻击玩家 | spawning 结束 / hitstun 结束 | 进入 hitstun / HP≤0 / 进入 special |
| **hitstun** | 被玩家功法击中,短暂击退 + AI 暂停 | 收到 `damage_dealt(victim=self)` | knockback duration 结束 |
| **special** | 群墨爆裂、精英大招、飞墨发射等独有动作期间 | 类型特定触发(如群墨 HP≤0 触发爆裂) | 动作完成 |
| **dying** | (短暂)死亡动画 0.15s,期间不响应输入,touch damage 禁用 | HP ≤ 0 (Damage 已发 entity_died) | 0.15s 后从场景移除/回对象池 |

**优先级**(同时满足多个进入条件): dying > hitstun > special > active > spawning

### Interactions with Other Systems

**上游(Enemy AI 消费这些系统的数据/事件):**

| 上游 | 接口 | 类型 |
|------|------|------|
| **Player Controller** | 读 `PC.global_position`(每 AI tick)、`PC.current_realm`(决定 R 值) | 拉模型 |
| **Damage System** | 订阅 `damage_dealt(victim=self)` 进入 hitstun;订阅 `entity_died(self)` 进入 dying | 信号 |
| **Run/Session** | 订阅 `run_state_changed`,非 playing 状态停止 AI tick | 信号 |
| **Enemy Spawner** | 通过 `spawn(type, position, R)` API 实例化 | API |
| **Boss AI** | 读 `Boss.global_position` 和 `Boss.clearance_radius` 触发 emergency steering | 拉模型 |

**下游(消费 Enemy AI 数据/事件):**

| 下游 | 接口 | 类型 |
|------|------|------|
| **Damage System** | 接触玩家时调 `DamageBus.deal_damage()`(攻击者=self, victim=player, raw_damage=mob_damage[tier, R], element=配置, knockback_tier=配置) | API |
| **Spirit/XP** | 通过 Damage `entity_died` 接收事件,触发灵气掉落 | 间接(经 Damage) |
| **VFX System** | 订阅 Enemy AI 的 `attack_started`、`hitstun_started`、`died` 信号渲染特效 | 信号 |
| **Audio Manager** | 订阅同上 | 信号 |

**Godot 信号契约**:
- `attack_started(enemy_id, target_pos: Vector2)` — 攻击动作开始(供 VFX 渲染攻击预警)
- `hitstun_started(enemy_id, knockback_dir: Vector2, duration: float)` — 进入 hitstun
- `died(enemy_id, killer_id: int)` — 死亡(冗余于 Damage 的 entity_died,但便于 VFX 直接订阅)
- `cluster_split(parent_id, child_count: int)` — 群墨爆裂时(供 VFX 渲染爆裂效果)

### 5 种杂兵类型的具体行为规范

#### 1. 墨滴 (Ink Drop)

**行为**: 纯 seek。velocity = (PC.global_position - self.position).normalized() × move_speed。
**攻击**: 接触玩家时触发 DamageEvent(touch damage)。无独立攻击动作。
**特点**: 数量最多,后期屏幕主力。

#### 2. 散墨 (Scattered Ink)

**行为**: seek + 侧向正弦偏移。`velocity = seek_dir × move_speed + perpendicular(seek_dir) × sin(time × oscillate_freq) × oscillate_strength`。
**攻击**: 接触玩家时触发 DamageEvent。
**特点**: 比墨滴小、快,通过侧摆制造"游击包夹"视觉。

#### 3. 闷墨 (Sluggish Ink)

**行为**: seek + 加减速延迟。velocity 通过 `lerp(current_velocity, target_velocity, 0.05)` 缓慢逼近目标速度(感觉钝重)。move_speed 是杂兵最低。
**攻击**: 接触玩家时触发 DamageEvent。HP 最高(同等境界下),是肉盾。
**特点**: 缓慢但难杀,玩家必须绕过去。

#### 4. 飞墨 (Flying Ink)

**行为**: 距离 < range_min(默认 200px)时反向远离;距离 > range_max(默认 400px)时 seek 接近;之间 hover(velocity=0)。每 attack_cooldown(默认 1.5s)向玩家方向投射 1 个墨滴 projectile。
**攻击**: 投射物在飞行中触发 DamageEvent(touch),自身**不**触发 touch damage(它在远处)。
**特点**: 远程,玩家被迫先打它或近身。

#### 5. 群墨 (Cluster Ink)

**行为**: 慢速 seek(类似闷墨但更快)。
**特殊**: HP ≤ 0 时**不立即 dying**,先进入 special 状态,emit `cluster_split(self, 3-5)` 信号,然后从场景移除。Enemy Spawner 订阅 cluster_split 立即在原位生成 3-5 个**散墨**(art-bible Section 5.3 锁定行为)。
**攻击**: 接触玩家时触发 DamageEvent。

### 精英 (Elite) — 6 境界各 1 种

精英是大杂兵 + 一笔锋标记。标记位置决定威胁:

#### Top Mark (远程精英)
- 类似飞墨,但 range_min/max 更大(300/600px),attack_cooldown 更短(1.0s)
- 投射物伤害 = mob_damage[精英, R]

#### Side Mark (冲撞精英)
- 默认 seek;每 dash_cooldown(默认 3.0s)选择当前玩家位置作为 dash target,**短暂 telegraph 0.4s**(art-bible 红色 tell)后 1.0× dash 冲过去
- Dash 期间无法转向;dash 结束后停止 0.5s 恢复
- 接触触发 DamageEvent + 重击退

#### Bottom Mark (AoE 精英)
- 缓慢 seek 直到距玩家 < aoe_range(150px)
- 停下 + 0.6s telegraph(art-bible 红色圆圈预警范围)+ 释放圆形 AoE
- AoE 期间精英自身不可移动,玩家可踏出范围躲避

### Realm Progression 的影响

杂兵基础属性按 R 缩放(Damage GDD F4 + F5 已锁定):

| R | 杂兵 HP | 精英 HP | 杂兵伤害 | 精英伤害 |
|---|---------|---------|----------|----------|
| R1 | 10 | 50 | 2 | 4 |
| R2 | 30 | 152 | 3 | 6 |
| R3 | 62 | 309 | 4 | 7 |
| R4 | 105 | 524 | 5 | 9 |
| R5 | 158 | 791 | 6 | 12 |
| R6 | 220 | 1102 | 7 | 13 |

Enemy AI 在 spawn 时从 Realm Progression 读取 current_R,通过 Damage GDD 的 F4/F5 计算 HP 和 contact_damage。

> **Note**: Specialist agents (ai-programmer, systems-designer) not consulted at Section C — Lean mode. art-bible Section 5.3 + Damage GDD F4/F5 已经把 5 种类型 + 数值锁死,设计空间几乎完全确定。

## Formulas

> **跨系统注意**: 本节引入了"per-mob-type HP 倍率"作为新事实——基于 Damage GDD F5 的 base mob HP,每种杂兵类型有不同倍率。这扩展了 Damage GDD 的 base 表(原始只区分 tier=杂兵/精英/守护者/BOSS)。**待 entity registry 阶段固化,可能需要回归更新 Damage GDD**。

---

### Formula 1: 杂兵基础移动速度

```
mob_speed(type, R) = player_base_speed(R) × speed_ratio[type]
```

**Per-type ratios:**

| Type | speed_ratio | R1 px/s | R6 px/s | Rationale |
|------|-------------|---------|---------|-----------|
| 墨滴 | 0.72 | 63.4 | 89.3 | 比玩家慢但能追上慢走玩家;数量制造压力 |
| 散墨 | 0.95 | 83.6 | 117.8 | 最快,但侧摆使有效推进 ≈ 0.75×;视觉"游击" |
| 闷墨 | 0.55 | 48.4 | 68.2 | 最慢,玩家可绕过;肉盾定位 |
| 飞墨 | 0.65 | 57.2 | 80.6 | 主要 hover,进/退用此速度 |
| 群墨 | 0.80 | 70.4 | 99.2 | 介于闷墨和散墨之间 |

**Output Range**: 48-118 px/s。所有非 hover 状态杂兵速度 ≤ 0.95× player_speed,保证 R5 玩家始终能"逃出去再杀回来"。

**Rationale**: 5 种类型的速度梯度是其"运动语言"的核心 — 玩家从屏幕信息就能识别"那是闷墨"(慢)、"那是散墨"(快但晃)。

---

### Formula 2: 散墨侧向正弦偏移

```
v_lateral = perpendicular(seek_dir) × sin(t × ω + φ_self) × A
v_total = seek_dir × mob_speed + v_lateral
```

**Variables:**

| Variable | Value | Description |
|----------|-------|-------------|
| `ω` (oscillate_freq) | 2π × 1.2 rad/s ≈ 7.54 | 周期 ≈ 0.83s |
| `A` (oscillate_strength) | 30 px/s | 侧向幅度,~0.30× mob_speed |
| `φ_self` | random [0, 2π) per-mob | 每个散墨独立相位,避免集体同步摆动 |

**Output Range**: lateral 分量 ∈ [-30, +30] px/s。

**Worked Example**: R1 散墨 mob_speed=83.6, lateral 峰值 30 → 合成速度峰值 ≈ √(83.6² + 30²) ≈ 88.8 px/s,与玩家速度持平,呈现"几乎跟上的游击"。

**Rationale**: 1.2 Hz 频率在玩家可识别但不可精确预测窗口。> 2 Hz 会变抖动,< 0.5 Hz 会变"长波"。

---

### Formula 3: 闷墨加减速 Lerp

```
current_velocity = lerp(current_velocity, target_velocity, k_accel × (delta / 0.016667))
```

**Variables:**

| Variable | Value | Description |
|----------|-------|-------------|
| `k_accel` | 0.06 per 60fps frame | 加速 lerp 系数 |
| `target_velocity` | seek_dir × mob_speed | |

**Output Range**: 0 → mob_speed,达到 95% 用时 ≈ 0.81s。

**Worked Example**: R1 闷墨从静止启动,t=0.5s 时 velocity ≈ 35.8 px/s(74%);t=1.0s 时 ≈ 47 px/s(97%)。玩家反转方向时闷墨需 ~1.6s 完全反向 = 钝重感。

**Rationale**: 玩家 PC F2 启动 60ms 达 95%,闷墨 810ms — 玩家比闷墨快 13×。这个比例决定"无法转弯,绕过去就好"的玩法。

---

### Formula 4: 飞墨保距 + 投射物

```
if dist < range_min:     velocity = -seek_dir × mob_speed × 0.7   (后退稍慢)
elif dist > range_max:   velocity = seek_dir × mob_speed
else:                    velocity = 0   (hover)

projectile_velocity = seek_dir_to_player × proj_speed
```

**Variables:**

| Variable | Value (R1→R6) | Description |
|----------|---------------|-------------|
| `range_min` | 200 px | 太近反向 |
| `range_max` | 380 px | 太远接近 |
| `hover_band` | 180 px | range_max - range_min |
| `attack_cooldown` | 1.6s → 1.2s linear by R | 投射间隔 |
| `proj_speed` | 180 px/s | 玩家 R1 速度 ×2.0 |
| `proj_lifetime` | 2.5s | 最大射程 ~450 px |
| `proj_damage` | mob_damage[飞墨, R] | 同 contact 但通过 projectile |

**Worked Example**: R3 玩家 base_speed=109, 距离飞墨 280 px(hover 中央)。玩家朝飞墨冲刺:80 px / (109-(-37)) = 0.55s 进入 range_min,飞墨切换后退 → 玩家相对速度 = 146 px/s 拉近。投射物 180 px/s vs 玩家 109 px/s,玩家可垂直闪避。

**Rationale**: hover_band 180px 大于飞墨自身位移 × 1 帧 (3 px),避免抖动边界切换。

---

### Formula 5: 群墨爆裂数量

```
burst_count(R) = floor(3 + (R - 1) × 0.4)
```

**输出**: R1=3, R2=3, R3=4, R4=4, R5=4, R6=5。

**子代规范**:
- Type: 散墨(art-bible Section 5.3 锁定)
- HP: 散墨_HP[R] × 0.5(半血,避免极端死锁)
- 初速度: mob_speed[散墨, R] × 0.5,0.3s 内 lerp 到 1.0×
- 分布: 均匀圆周

**Rationale**: 玩家击杀群墨瞬间被 3-5 个比自己快的散墨四散包围,**强制立即拉开距离**。

---

### Formula 6: 精英 Side Mark Dash

```
dash_velocity = dash_target_dir × player_base_speed(R) × 2.5
dash_distance = dash_velocity × dash_duration ≈ 100-140 px
```

**Variables:**

| Variable | Value | Description |
|----------|-------|-------------|
| `dash_speed_mult` | 2.5 × player_speed | R1: 220 / R6: 310 px/s |
| `dash_duration` | 0.45s | 冲刺时长 |
| `telegraph_duration` | 0.4s | art-bible 红色 tell |
| `recovery_duration` | 0.5s | 冲后僵直 |
| `dash_cooldown` | 3.0s | 下次 dash 间隔 |
| `knockback_tier` | 4 (force=360) | 重击退 |

**Worked Example**: R3 dash_velocity = 272.5 px/s × 0.45 = 122.6 px。telegraph 0.4s 期间玩家移动 = 43.6 px,够横向走出 dash 路径(精英直径 32px,需侧移 ≥ 24px,19.6 px 余量)。

**Rationale**: 2.5× 倍率玩家无法跑赢必须侧移;0.4s telegraph 给反应窗。

---

### Formula 7: 精英 Bottom Mark AoE

```
aoe_trigger_range = 150 px
aoe_radius = 80 px
telegraph_duration = 0.6s
aoe_damage = mob_damage_elite[R] × 1.5
```

**Worked Example**: R3 AoE = 7 × 1.5 = 10.5 → 11。R3 玩家 HP 20,AoE 命中 = 55% 血。telegraph 0.6s × 109 = 65.4 px 玩家位移,小于 80px 边界 → 玩家需要看到圈瞬间开始走。

**Rationale**: telegraph 半径 = 伤害半径,**所见即所测**,无视觉欺骗。

---

### Formula 8: Boids Separation(敌人之间)

```
sep_force = Σ (self.pos - other.pos).normalized() × max(0, (sep_radius - dist) / sep_radius) × sep_strength
v_total = v_steering + sep_force × delta
```

**Variables:**

| Variable | Value | Description |
|----------|-------|-------------|
| `sep_radius` | 24 px | 影响半径(~1.5× 杂兵直径) |
| `sep_strength` | 40 px/s² | 加速度量级 |
| Max sep | 30% × mob_speed | 防止极端推开 |

**Performance**: 4-邻居 cap(每个杂兵只考虑最近 4 个邻居),O(n × 4) 而非 O(n²)。spatial hash 加速。

**Rationale**: 视觉分离感 + 性能可控。**允许重叠**(art-bible Section 5.3 杂兵不进 BOSS 留白圈但相互可重叠)。

---

### Formula 9: AI Tick LOD

```
tick_interval(dist) = {
    1 frame   if dist ≤ 800 px,
    2 frames  if 800 < dist ≤ 1400 px,
    4 frames  if 1400 < dist ≤ viewport + 200 px,
    paused    if outside viewport + 200 px
}
```

**Variables:**

| Variable | Value | Description |
|----------|-------|-------------|
| `near_threshold` | 800 px | > 视野半径(960px),保证视野内全速 |
| `far_threshold` | 1400 px | 视野外软过渡 |
| `off_screen_margin` | viewport + 200 px | 视野外缓冲 |

**Performance**(R5 假设 150 实体): 近(<800px) ≈40 全速;中(800-1400) ≈70 半速;远(1400+) ≈40 1/4 速 → **约 85 ticks/frame vs naive 150,降幅 43%**。

**Rationale**: 800/1400 比 600/1200 更安全(覆盖视野范围),性能差异极小。

---

### Formula 10: 击退映射(杂兵 contact → PC)

| 杂兵 | knockback_force | duration | Rationale |
|------|----------------|----------|-----------|
| 墨滴 | 80 | 0.10s | 最轻,数量多;堆叠会让玩家飞天 |
| 散墨 | 80 | 0.10s | 同墨滴 |
| 闷墨 | 240 | 0.20s | 钝重感 |
| 飞墨 projectile | 150 | 0.15s | 中等,远程 sting |
| 群墨 | 150 | 0.15s | 中等 |
| 群墨子代散墨 | 80 | 0.10s | 同散墨 |
| 精英 Top (projectile) | 240 | 0.20s | 中重 |
| 精英 Side (dash) | 360 | 0.30s | 重击 |
| 精英 Bottom (AoE) | 400 | 0.35s | 最重,art-bible Section 4.2 朱砂红 |

**保护**: PC GDD F3 "新击退如果 force 更大则覆盖,否则丢弃"防止 R5 围困时玩家被推飞天。

---

### Per-Mob-Type HP 倍率(新事实,需 entity registry)

基于 Damage GDD F5 的 base mob HP:

| Type | HP 倍率 | R1 HP | R5 HP | Rationale |
|------|---------|-------|-------|-----------|
| 墨滴 | 1.0× | 10 | 158 | 基线 |
| 散墨 | 0.6× | 6 | 95 | 最脆,快速被清 |
| 闷墨 | 2.5× | 25 | 395 | 肉盾 |
| 飞墨 | 0.8× | 8 | 126 | 远程,接触脆 |
| 群墨 | 1.5× | 15 | 237 | 半盾,死后散开是核心威胁 |

> **跨系统标记**: 这扩展了 Damage GDD F5 的 base mob HP(原本只 1.0×)。需在 entity registry 阶段固化此倍率表,并可能需要 update Damage GDD。

---

### R1 教学 / R5 威胁 — 致死次数分析

| 威胁 @ R1 | 单次伤害 | 致死次数 | 教学价值 |
|----------|---------|---------|---------|
| 墨滴/散墨 | 2 | 10 击 | 新手可被打几次再学会 |
| 飞墨 projectile | 2 | 10 (1.6s/发 = 16s) | 学习破坏远程 |
| 精英 Side dash | 4 | 5 失误 | 学习看 telegraph |
| 精英 Bottom AoE | 6 (4×1.5) | 4 命中 | 学习躲圈 |

| 威胁 @ R5 | 单次伤害 | 致死次数 | 紧张感 |
|----------|---------|---------|--------|
| 墨滴/散墨 | 6 | 4 击 | 严峻 |
| 飞墨 projectile | 6 | 4 发 | 必须破坏 |
| 群墨 burst | 6+4×6 子代 | 极快 | 进入半径几乎必死 |
| 精英 Side dash | 12 | 2 失误 | 必须躲 telegraph |
| 精英 Bottom AoE | 18 (12×1.5) | 2 命中 | 一次失血 90% |

**梯度**: 从"被打了能学"(R1 致死 ~10 次)变成"不能被打"(R5 精英 1-2 次失误即死)。Survivor-like 典型后期紧张。

## Edge Cases

- **If 玩家死亡时还有敌人活着**: Run/Session 切到 dying 状态 → Enemy AI tick 停止(Run GDD 锁定),敌人冻结在原位。dead 状态后场景重置或保留供观看回放(Open Question)。
- **If 突破清场期间敌人在玩家 clearance_radius 内**: PC GDD F4 锁定 600ms 视觉脉冲期间真实清场。敌人收到来自 PC 的 "instant kill" 事件(zero-damage 但触发 entity_died),Enemy AI 进入 dying 状态,不触发 cluster_split(群墨爆裂)。
- **If 群墨在被清场时爆裂**: 上一条 edge case 中,群墨**不触发 cluster_split**(被强制清除而非"击杀")。这保留突破清场的爽感(不会爆出一群散墨打脸玩家)。
- **If 敌人卡在墙边无法朝玩家移动**: Steering 行为产生贴墙力,Godot `move_and_slide()` 内置墙滑动。敌人贴墙跟着玩家方向滑行。无需特殊处理。
- **If 飞墨投射物在 proj_lifetime(2.5s)后未命中**: 自动销毁。**不延迟**——超过 lifetime 立刻从场景移除并对象池回收。
- **If 精英 Side dash 朝玩家冲撞但玩家在 telegraph 期间消失(死亡/突破 immobile)**: Dash 仍按原方向冲撞完成,然后进入 recovery。不会"自动改向"。
- **If 同帧多个敌人击中玩家**: Damage GDD AC-DMG-05 锁定按 attacker_id 升序处理。Enemy AI 不管这个,只负责 emit DamageEvent。
- **If 群墨子代刚出生就接触玩家**: 子代有 0.3s 初速度 lerp 期(F5),期间触发 DamageEvent 仍按散墨规则(80 force 击退,mob_damage[散墨, R] 伤害)。
- **If 精英 Bottom AoE telegraph 时玩家逃出范围**: AoE 仍按既定范围爆,只是玩家不在内 = 无伤害。这是设计内行为(art-bible "看到圈就能躲")。
- **If R6 杂兵 HP > 玩家整个 run 的功法 DPS**: 杂兵 R6 HP=220,玩家功法需要 ~20-30 秒清掉单个。这设计意图——R6 杂兵是"装饰品"(Damage GDD F5 Rationale),玩家用 AOE 范围功法清屏而非单点。
- **If AI tick LOD 在 paused 状态时玩家进入视野**: 玩家恢复 playing → AI 立即恢复 tick,但**不重置敌人位置**(它在 paused 期间冻结在原位)。
- **If 大量散墨同时使用相同 `φ_self`**: 这不应发生(每个 spawn 时随机),但若发生,集体同步摆动会视觉违和。**Enemy Spawner 必须保证 φ_self 在 spawn 时初始化为 `randf() × TAU`**——这是 Enemy AI 对 Spawner 的硬约束。
- **If 群墨被功法击败但 cluster_split 信号发出前 player 突破**: 突破清场期间 cluster_split 信号被 Enemy Spawner 忽略(Spawner 自己处理这个 edge case)。

## Dependencies

### Upstream

| 上游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **Player Controller** | Hard | 读 `PC.global_position`(每 AI tick), `PC.current_realm` | 已设计 |
| **Damage/Health System** | Hard | 订阅 `damage_dealt(victim=self)` 触发 hitstun;订阅 `entity_died(self)` 触发 dying;调 `DamageBus.deal_damage()` 攻击玩家 | 已设计 |
| **Run/Session Management** | Hard | 订阅 `run_state_changed`,非 playing 状态停止 AI tick | 已设计 |
| **Enemy Spawner** | Hard | `spawn(type, position, R)` API + 通过 `φ_self` 初始化散墨摆动相位 + 订阅 `cluster_split` 信号生成子代 | 未设计 (Order #7) |
| **Boss AI** | Hard | 读 `Boss.global_position` 和 `Boss.clearance_radius` 触发 emergency steering | 未设计 (Order #11) |
| **Realm Progression** | Soft | 通过 PC.current_realm 间接获取 R 值;无直接接口 | 未设计 (Order #12) |

### Downstream

| 下游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **VFX System** | Hard | 订阅 `attack_started`, `hitstun_started`, `died` 信号渲染特效 | 未设计 |
| **Audio Manager** | Hard | 订阅同上播放音效 | 未设计 |
| **Enemy Spawner** | Hard | 订阅 `cluster_split(parent_id, child_count)` 信号生成子代散墨 | 未设计 |
| **Spirit/XP** | Soft | 间接(通过 Damage `entity_died`)接收死亡事件触发灵气掉落 | 未设计 |

### External

- Godot 4.6 `Area2D` + `body_entered` / `area_entered` 用于接触检测
- Godot 4.6 `move_and_slide()`(每个敌人是 CharacterBody2D,简化版)或 MultiMeshInstance2D 批量渲染(art-bible Section 8 锁定 R5 性能)

### Forbidden

- 其他系统**禁止**直接修改敌人的 HP(必须走 DamageBus)
- 其他系统**禁止**订阅 `position_changed` 信号(若敌人 emit 的话,150 实体广播过频);**敌人不 emit position 信号**——其他系统按需 pull
- Enemy AI **禁止**包含伤害计算逻辑(走 DamageBus)或玩家位置预测(直接读)

## Tuning Knobs

### 全局参数

| 参数 | 默认值 | 安全范围 | 影响 |
|------|--------|----------|------|
| `AI_TICK_NEAR_THRESHOLD` | 800 px | [600, 1000] | F9 全速 tick 距离 |
| `AI_TICK_FAR_THRESHOLD` | 1400 px | [1200, 1800] | F9 1/4 速 tick 距离 |
| `SEP_RADIUS` | 24 px | [16, 32] | F8 boids 分离半径 |
| `SEP_STRENGTH` | 40 px/s² | [20, 60] | F8 分离力度 |
| `SEP_NEIGHBOR_CAP` | 4 | [2, 8] | F8 每个敌人最多考虑邻居数 |
| `MOB_KNOCKBACK_RESIST` | 1.0 | [0.5, 2.0] | (预留)杂兵被击退的倍率,MVP 全 1.0 |

### Per-type 参数

| 杂兵 | speed_ratio | hp_multiplier | 独有参数 |
|------|-------------|---------------|----------|
| **墨滴** | 0.72 | 1.0× | — |
| **散墨** | 0.95 | 0.6× | `oscillate_freq=2π×1.2`, `oscillate_strength=30` |
| **闷墨** | 0.55 | 2.5× | `k_accel=0.06` per 60fps frame |
| **飞墨** | 0.65 | 0.8× | `range_min=200`, `range_max=380`, `attack_cooldown=1.6→1.2s by R`, `proj_speed=180`, `proj_lifetime=2.5s` |
| **群墨** | 0.80 | 1.5× | `burst_count(R)=floor(3 + (R-1)×0.4)`, `burst_child_hp_mult=0.5` |

### 精英参数

| 精英类型 | size | 独有参数 |
|---------|------|----------|
| **Top (远程)** | 1.0× player | `range_min=300, range_max=600, attack_cooldown=1.0s` |
| **Side (冲撞)** | 1.0× player | `dash_speed_mult=2.5`, `dash_duration=0.45s`, `telegraph=0.4s`, `recovery=0.5s`, `dash_cooldown=3.0s` |
| **Bottom (AoE)** | 1.0× player | `aoe_trigger_range=150`, `aoe_radius=80`, `telegraph=0.6s`, `aoe_damage_mult=1.5` |

### Knob 交互

- `speed_ratio` 和 `mob_damage_curve`(Damage F4)共同决定"R 提升时杂兵威胁感"——调一个必须同步审视另一个
- `hp_multiplier` × Damage F5 base_HP 决定实际 HP,任何 multiplier 调整都需要同步检查 Damage GDD
- `oscillate_freq`(散墨)与 `mob_speed`(散墨)耦合——速度增大时频率不变会让侧摆"幅度感"下降

### 调优优先级

- **Tier 1**(核心手感): speed_ratio per type, hp_multiplier per type — playtest 确定
- **Tier 2**(节奏): oscillate_freq, k_accel, burst_count, dash params — 视手感微调
- **Tier 3**(技术): AI_TICK thresholds, SEP_* — 性能优化时调

## Visual/Audio Requirements

### Visual(VFX 系统消费 Enemy AI 信号)

art-bible Section 5.3(杂兵) + Section 5.2(精英)已锁定:

**杂兵剪影**:
- 墨滴: Circle, `#4A4D52`, 0.6× player
- 散墨: Half-circle, `#6A6D72`, 0.4× player
- 闷墨: Lumpy ovoid, `#3E3A36`, 0.8× player
- 飞墨: Teardrop rounded point, realm-tinted grey, 0.5× player
- 群墨: Bunch of circles (3-5), mid-grey, 0.7× player(整体)
- **禁止特征**(art-bible 锁定): 飞白、泼彩、锐角、不对称、几何法阵纹饰

**精英剪影**(1.0× player size):
- 一笔锋(static asymmetric mark)位置编码威胁:top=ranged, side=charge, bottom=AoE
- 颜色: `#5A5D62` 灰墨 + 元素色 only on the stroke

**渲染**(art-bible Section 8 锁定):
- 杂兵用 MultiMeshInstance2D 批量渲染(150+ 实体性能必需)
- 精英单独渲染(只有少数,允许 individual draw)

**特殊 VFX**:
- **spawning 状态**: 渐现 0.2s,art-bible "墨从纸上渗出"风格
- **hitstun 状态**: 短暂明度提升或边缘红光(art-bible Section 4.2 受击视觉)
- **dying 状态**: 0.15s 墨色溶解(art-bible Section 2 死亡视觉简化版)
- **cluster_split 信号**: VFX 渲染爆裂动画(墨色四散喷溅)
- **飞墨 projectile**: 小型 trail,颜色按当前境界
- **精英 telegraph**: art-bible Section 4.2 红色圆圈或线条预警(side=直线 dash 轨迹,bottom=圆形 AoE 范围,top=瞄准玩家的红线)

### Audio(Audio Manager 消费 Enemy AI 信号)

- **spawn**: 简短"墨滴落下"音效(per type 不同音色)
- **attack_started**: 攻击预警音(精英 telegraph 必须有清晰可识别音效;杂兵 contact 无预警音)
- **hitstun_started**: 受击音(per type 不同力度)
- **died**: 击杀确认音(per type 不同)
- **cluster_split**: 爆裂音(脆响)

> **📌 Asset Spec** — Visual/Audio 需求已定义。在 art-bible approved 后,运行 `/asset-spec system:enemy-ai` 产出 per-type 精灵规格 + 攻击 telegraph VFX + audio cue 列表。

## UI Requirements

Enemy AI **不直接拥有 UI 元素**。但下游 HUD/UX 系统可能消费以下数据:

- **精英头顶 HP 条**(可选,MVP 不做): art-bible Section 5.3 锁定"普通敌人不显示血条,精英可显示"
- **BOSS 头顶 HP 条**: 由 Boss AI GDD 控制,Enemy AI 不涉及
- **伤害飞字**: 由 Damage System 控制(art-bible UI Section 7.1)

> **No UX Flag** — Enemy AI 自身无 UI 需求。精英 HP 条由 HUD GDD 设计时决定。

## Acceptance Criteria

> **Story Type Tags**: [L]=Logic (unit test BLOCKING), [I]=Integration (集成测试或 playtest BLOCKING), [V]=Visual/Feel (截图+lead sign-off ADVISORY), [P]=Performance (基准测试 BLOCKING).
> **Scope Tags**: [MVP]=R1 跑通主要类型必需; [VS]=完整体验需要全部.

### AC-EAI-01 [MVP] [L] 墨滴 — 纯 seek 行为
- **GIVEN** R1 墨滴 spawn 在 (200, 0),玩家在 (0, 0) 静止
- **WHEN** 物理 tick 1 秒后
- **THEN** 墨滴速度向量方向 = unit(player_pos - mob_pos) ± 1°;|velocity| ∈ [62, 65] px/s(F1 R1=63.4 ±2.5%);位置朝玩家移动 ≈ 63 px ±5%

### AC-EAI-02 [MVP] [L] 散墨 — seek + 正弦侧摆
- **GIVEN** R1 散墨 spawn, φ_self=0, 玩家正东方向
- **WHEN** t = 0.83s (一个 ω 周期)
- **THEN** 侧向位移穿越 0→+30→0→-30→0,峰值 ∈ [28, 32] px/s (F2 A=30 ±5%);合成 |velocity| 峰值 ≈ 88.8 px/s ±5%

### AC-EAI-03 [VS] [L] 散墨 — φ_self 独立性(防集体同步)
- **GIVEN** 100 只散墨同帧 spawn(Spawner 用 `randf() × TAU` 初始化 φ_self)
- **WHEN** 收集所有散墨 φ_self
- **THEN** 分布在 [0, 2π) 方差 ≥ 2.5(均匀分布期望 π²/3 ≈ 3.29,允许 25% 偏差);任意两只 |Δφ| < 0.01 的对数 < 2

### AC-EAI-04 [MVP] [L] 闷墨 — 加减速 Lerp 钝重启动
- **GIVEN** R1 闷墨从 velocity=(0,0) 静止启动
- **WHEN** delta=1/60s 固定 tick
- **THEN** t=0.5s |velocity| ∈ [33, 38] px/s (F3 35.8 ±10%);t=1.0s ∈ [44, 49] px/s (97%);t=2.0s ≥ 48 px/s (>99% 终态)

### AC-EAI-05 [VS] [L] 飞墨 — Hover 距离带状态机
- **GIVEN** R1 飞墨,玩家固定 (0, 0)
- **WHEN** 飞墨放在 dist=150 / dist=280 / dist=500 px
- **THEN**
  - dist=150: 远离玩家,|v| ≈ 40 px/s ±5% (F4 后退 0.7×)
  - dist=280: |v| < 1 px/s (hover)
  - dist=500: 朝玩家,|v| ≈ 57.2 px/s ±5%

### AC-EAI-06 [VS] [L] 飞墨 — 投射物速度 + 生命周期
- **GIVEN** R1 飞墨触发 cooldown 投射
- **WHEN** projectile 实例化
- **THEN** 方向 = unit(player_pos - mob_pos) ± 1°;|velocity| ∈ [175, 185] px/s (F4 proj_speed=180);spawn 后 2.5s ± 1 frame 自动移除;未命中也销毁

### AC-EAI-07 [MVP] [L] 群墨 — HP≤0 触发 cluster_split
- **GIVEN** R1 群墨 HP=15,收到 damage_dealt(victim=self, amount=15)
- **WHEN** Damage emit entity_died(self)
- **THEN** 群墨进入 special 状态(非直接 dying);emit `cluster_split(self_id, child_count=3)` (F5 R1→3);从场景移除;状态优先级 dying > special

### AC-EAI-08 [VS] [I] 群墨子代散墨 — 状态机 + 初速度 lerp
- **GIVEN** R3 群墨被击杀,Spawner 在原位生成 4 只散墨 (F5 R3→4)
- **WHEN** 子代 spawn 后 0.3s 内
- **THEN** type=散墨;HP = 散墨_HP[R3] × 0.5;圆周均匀分布(角度间隔 90° ±5°);t=0 初速度 = mob_speed[散墨, R3] × 0.5,t=0.3s 至 1.0× ±10%;子代 φ_self 独立随机

### AC-EAI-09 [VS] [L] 精英 Top — 远程参数对比飞墨
- **GIVEN** R3 精英 Top 与 R3 飞墨同场景
- **WHEN** 比较参数
- **THEN** 精英 Top: range_min=300, range_max=600, attack_cooldown=1.0s(对比飞墨 200/380/1.4s);projectile damage = mob_damage_elite[R3] = 7(对比飞墨 mob_damage[R3] = 4)

### AC-EAI-10 [VS] [L] 精英 Side — Dash 速度 + Telegraph 时序
- **GIVEN** R3 精英 Side dash 触发,玩家固定 (0, 0)
- **WHEN** dash 完整周期
- **THEN**
  - Telegraph: 0.4s ± 1 frame, velocity ≈ 0, 红色 tell emit
  - Dash: |velocity| ∈ [266, 280] px/s (F6 R3=272.5);dash_duration=0.45s ± 1 frame;方向锁定
  - Recovery: 0.5s velocity=0
  - 下次 dash 至少 dash_cooldown=3.0s 后

### AC-EAI-11 [VS] [L] 精英 Bottom — AoE 范围 + 伤害倍率
- **GIVEN** R3 精英 Bottom 距玩家 < 150 px 触发 AoE
- **WHEN** Telegraph 0.6s 后释放
- **THEN**
  - Telegraph: velocity=0;红色圆 emit,半径=80px(F7 所见即所测)
  - 释放: AoE 圆心 80px 内 PC 受 damage = mob_damage_elite[R3] × 1.5 = 11
  - 玩家在 80px 外 → 无伤害(Edge Case)

### AC-EAI-12 [MVP] [L] 击退映射 — Per-type knockback_force
- **GIVEN** 玩家被各类型敌人击中
- **WHEN** Enemy AI emit DamageEvent
- **THEN** knockback_tier 严格匹配 F10:墨滴/散墨=80/0.10s, 闷墨=240/0.20s, 飞墨 proj=150/0.15s, 群墨=150/0.15s, 子代散墨=80/0.10s, 精英 Top proj=240/0.20s, 精英 Side dash=360/0.30s, 精英 Bottom AoE=400/0.35s

### AC-EAI-13 [VS] [L] HP 倍率表 — Per-type hp_multiplier
- **GIVEN** R1 各类型敌人 spawn,Damage F5 base mob HP=10
- **WHEN** 读取初始 HP
- **THEN** 墨滴=10, 散墨=6, 闷墨=25, 飞墨=8, 群墨=15;R5 base=158 应得 158/95/395/126/237

### AC-EAI-14 [VS] [P] AI tick LOD — 距离分桶 + 性能
- **GIVEN** 150 实体场景:近(<800)40 / 中(800-1400)70 / 远(1400+)40
- **WHEN** 物理帧运行
- **THEN**
  - 近 40 个:每帧 tick;中 70 个:每 2 帧;远 40 个:每 4 帧
  - 视野外(viewport+200)实体:0 tick
  - 总 ticks/frame ≤ 90 (F9 期望 85,允许 ±5)
  - 60 FPS 维持 (frame_time ≤ 16.67ms),naive 150-tick 对比降幅 ≥ 35%

### AC-EAI-15 [VS] [I] 玩家死亡 — AI 冻结
- **GIVEN** Run/Session playing,150 实体活跃
- **WHEN** Run/Session emit `run_state_changed(dying)`
- **THEN** Enemy AI 所有 tick 立即停止;位置/velocity/状态机冻结(±0.01 px);LOD paused 实体保持 paused

### AC-EAI-16 [VS] [I] 突破清场 — 群墨不爆裂特例
- **GIVEN** 突破清场期间 PC clearance_radius 内 5 只群墨 R3
- **WHEN** PC F4 触发 600ms 视觉脉冲,群墨收到 instant kill 事件
- **THEN** 5 只群墨直接进入 dying(跳过 special);**不 emit cluster_split**;Spawner 不生成子代;清场后视野内无散墨爆出

### AC-EAI-17 [VS] [L] 同帧多敌人击中 — DamageEvent 委托
- **GIVEN** 同帧 5 只墨滴(不同 attacker_id)接触玩家
- **WHEN** Enemy AI 各自 emit DamageEvent → DamageBus
- **THEN** Enemy AI 端无去重(委托 Damage AC-DMG-05 处理);DamageBus 收 5 个 DamageEvent;emit 顺序与处理顺序解耦

### AC-EAI-18 [VS] [I] Boss 留白圈 — Emergency Steering
- **GIVEN** Boss 在 (0, 0), clearance_radius=64px;3 只杂兵在 (30, 0)
- **WHEN** 物理 tick
- **THEN** 杂兵触发 emergency steering(径向向外);1 秒内所有杂兵移出 64px 圈外;移出后恢复正常 seek 玩家

---

### Test Evidence Classification

| AC | Type | Location |
|----|------|----------|
| AC-EAI-01, 02, 03, 04 | Logic | `tests/unit/enemy_ai/{ink_drop,scattered_ink,sluggish_ink}_test.gd` |
| AC-EAI-05, 06 | Logic | `tests/unit/enemy_ai/flying_ink_test.gd` |
| AC-EAI-07 | Logic | `tests/unit/enemy_ai/cluster_ink_test.gd` |
| AC-EAI-08 | Integration | `tests/integration/enemy_ai/cluster_split_test.gd` |
| AC-EAI-09, 10, 11 | Logic | `tests/unit/enemy_ai/elite_{top,side,bottom}_test.gd` |
| AC-EAI-12, 13 | Logic | `tests/unit/enemy_ai/{knockback,hp}_mapping_test.gd` |
| AC-EAI-14 | Performance | `tests/performance/enemy_ai/lod_bench_test.gd` |
| AC-EAI-15, 16, 18 | Integration | `tests/integration/enemy_ai/*.gd` |
| AC-EAI-17 | Logic | `tests/unit/enemy_ai/damage_event_emit_test.gd` |

**Coverage**: 8 archetypes × 10 Formulas × 关键 Edge Cases 全覆盖。18 AC = 4 MVP + 14 VS。

**MVP Gate(R1 跑通)**: AC-01, 04, 07, 12 必须通过(墨滴/闷墨/群墨核心 + 击退表)。
**VS Gate(完整)**: 18 条全通过 + 性能基准达标。

## Open Questions

1. **Per-mob-type HP 倍率的 Damage GDD 影响**: 本 GDD 引入了 hp_multiplier(墨滴 1.0× / 散墨 0.6× / 闷墨 2.5× / 飞墨 0.8× / 群墨 1.5×),这扩展了 Damage GDD F5 的 base mob HP 定义。**需在 entity registry 阶段(`design/registry/entities.yaml`)注册此表,并可能需要更新 Damage GDD F5 说明**。**Owner**: game-designer + systems-designer。**Target**: entity registry 创建时回归。

2. **AI 寻路 LOD 800/1400 阈值**: F9 选择 800/1400 而非 systems-designer 原提议的 600/1200。需要 Camera GDD 确认玩家屏幕位置(摄像机是否硬居中)。如果摄像机有滞后让玩家偏一侧,800px 可能不够。**Owner**: gameplay-programmer + technical-artist。**Target**: 引擎集成 spike 完成后实测。

3. **MultiMeshInstance2D 与 Area2D 触发的兼容性**: art-bible Section 8 锁定杂兵用 MultiMeshInstance2D 批量渲染,但 Area2D 是每个实体一个节点 — 二者如何协同?可能需要"渲染层"和"逻辑层"分离。**Owner**: gameplay-programmer + technical-artist。**Target**: 引擎集成阶段。

4. **散墨子代(群墨爆裂出的)是否参与下一次爆裂**: 当前设计 burst_child_hp_mult=0.5,确保子代血量低不会被再次击杀爆裂(因为爆裂的是群墨,散墨不爆)。但如果未来加入"爆裂传染"机制,需要预留接口。**Owner**: game-designer。**Target**: VS 阶段如有新机制再决定。

5. **精英 spawn 时机**: Enemy AI 不管 spawn,但精英在场景中的"出现频率"由 Enemy Spawner 控制。F4 设计意图 R1-R6 精英每境界 1 种类型,但每局出现几只?**Owner**: game-designer + Enemy Spawner designer。**Target**: Enemy Spawner GDD 设计时(Order #7)。

6. **AI tick LOD 与摄像机震屏的交互**: AI tick 假设玩家位置 = `PC.global_position`,但 Camera 震屏会让玩家"视觉上"位置抖动。AI 用逻辑位置不用视觉位置 — 这正确,但确认下游 VFX 不会因此错位。**Owner**: gameplay-programmer。**Target**: 实现时验证。
