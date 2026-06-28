# Damage/Health System

> **Status**: In Design
> **Author**: user + game-designer + systems-designer + qa-lead
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 2 (越战越强 — 伤害是力量感载体) + Pillar 1 (近在咫尺 — "差点死掉")
> **Priority**: MVP | **Layer**: Core
> **Source Systems Index**: design/gdd/systems-index.md (Order #4)
> **Hub Status**: 枢纽系统 — 被 7+ 下游系统依赖,接口稳定性最关键

## Overview

Damage/Health System 是游戏中**所有伤害事件的统一处理中心**——任何实体(玩家/敌人/BOSS)受到伤害都经过它的事件总线,任何 HP 变化都由它发出信号供下游消费。它定义"伤害事件"的数据结构(攻击者/受害者/原始伤害/元素/击退档位/暴击标志),处理元素相克倍率、护盾扣减、无敌帧、致命判定,并触发 PC 击退、Camera 震屏、VFX 命中、Audio 击中音的一连串下游响应。

这个系统是本作的"中枢神经"——Technique 系统通过它造成伤害,Enemy/Boss AI 通过它攻击玩家,Realm Progression 通过它响应玩家死亡,Spirit/XP 通过它监听击杀事件。**它的接口稳定性决定整个游戏的可维护性**。

因为是 Foundation+ 层,Damage 系统本身**不知道伤害的来源是什么"招式"、敌人是什么"种类"**——它只处理伤害事件本身,语义留给上游(谁触发了 deal_damage)。这种解耦让本作未来加入新功法/新敌人时,Damage 系统不需要修改。

## Player Fantasy

**Both — 玩家直接感受伤害反馈,但伤害公式本身是隐性基础设施。**

玩家直接感受的: 每一次受伤都是**清晰的因果链**——红光闪、HP 数字飞、震屏、击退、音效。受伤一定有视觉/听觉/触觉(震屏)的同步反馈,绝不让玩家"忽然 HP 少了一半却不知道发生了什么"。这是 Survivor-like 在 150+ 实体场景下的**生存契约**:玩家可以接受被打死,但不能接受"莫名其妙死掉"。

参考标杆: **Hades** 的命中反馈——每一次"差一点就死"都被视觉特效强化,胜利时玩家记得每一次心跳。**Vampire Survivors** 的伤害数字飞字——每一次击杀都是奖励反馈。我们结合两者:玩家受伤要有 Hades 的"重量感",造成伤害要有 VS 的"快感"。

伤害公式本身玩家不察觉(没人看着 HP 条心算"我还能扛 3 次中等火球"),但功法的"火属性 vs 冰属性 BOSS"的策略选择全部基于这个系统的元素相克——所以玩家**间接通过构筑感受**这个系统的存在。

> **Note**: `creative-director` not consulted — Lean mode; art-bible Sections 2 (Boss Fight mood: tense decoding) + 4.2 (cinnabar = lethal intent) + 5.2 (BOSS Tell rhythm) already lock the feedback framework.

## Detailed Design

### Core Rules

1. **DamageEvent 是统一接口**: 所有伤害都通过 `DamageEvent` 结构体表达,该结构体包含:
   - `attacker_id: int`(攻击者实体 ID,可为 -1 表示环境/无主)
   - `victim_id: int`(必填)
   - `raw_damage: float`(原始伤害,未经修正)
   - `element: Element`(火/冰/风/雷/剑/拳/无,art-bible Section 4.5)
   - `knockback_tier: int`(0-4,对应 PC GDD F3 五档击退)
   - `is_crit: bool`(暴击标志,影响 VFX/Audio 而非伤害值——本作 MVP 无暴击伤害倍率)
   - `position: Vector2`(伤害发生位置,供 VFX 定位)

2. **HP 范围设计**: **玩家 MVP HP = 20**(中档,允许容错但保持生存压力)。HP 不会随境界递增——力量感由功法 + 留白半径承担(PC GDD F1 已锁定)。敌人/精英/BOSS HP 由各自 GDD 决定。

3. **无护盾(MVP)**: 受伤直接扣 HP,无中间缓冲层。VS 阶段如需要再加可再生护盾系统。

4. **元素相克(art-bible Section 4.5 锁定)**:
   - 火克冰、冰克雷、雷克风、风克火(四元素循环,相克 ×1.5)
   - 反向(被克)×0.7
   - 同元素 ×1.0
   - 无元素互动(剑/拳/无 vs 火/冰/风/雷)×1.0
   - 详见 Section D Formula 2

5. **无敌帧(i-frame)**: 玩家受伤后获得 600ms 无敌帧(详见 Formula 3),期间所有 DamageEvent 命中玩家被忽略(但仍触发命中 VFX/Audio,以反馈玩家"差点死掉"的感受)。敌人/BOSS **无无敌帧**——可被连续命中(否则连击/AOE 功法没意义)。

6. **伤害事件的中央总线**: 所有伤害通过 `DamageBus.deal_damage(event)` 静态函数(或 Autoload 单例,实现细节)进入总线。总线**同步处理**:验证 → 应用元素相克 → 扣 HP → emit 信号 → 触发副作用(击退/VFX/Audio)。**不允许任何系统绕过总线直接修改 HP**。

7. **死亡判定**: HP ≤ 0 触发死亡。Damage 系统 emit `entity_died(victim_id)` 信号。下游(PC for 玩家死亡画面,Enemy/Boss for 掉落/招式夺取)各自响应。Damage 系统**不知道**"死亡后该做什么",只发出事件。

8. **DamageBus 单帧排序**: 单帧内多个 DamageEvent 进入同一受害者的处理顺序: **按 attacker_id 升序处理**(决定性,可重现)。Tie-break: 按 raw_damage 升序(避免高伤害提前致死后,低伤害事件还要计算)。

9. **过量伤害(overkill)截断**: 致死攻击的 `actual_damage = min(raw_damage_after_resist, current_HP)`,但 `DamageEvent.dealt_damage` 字段仍记录截断后的实际伤害(供 Spirit/XP 系统精算)。**不允许负 HP**——HP 严格在 [0, max_HP]。

10. **碰撞→伤害的桥接**: PC 与敌人不碰撞(PC GDD 锁定),但敌人 Area2D `body_entered`(玩家)时触发 DamageEvent。`Enemy.contact_damage` 是数据,Damage 系统不存这些值。

### States and Transitions(玩家健康状态)

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **healthy** | 默认。HP > 0 且 HP > 25% max | 复活 / HP 恢复到 25% 以上 | HP ≤ 25% / HP ≤ 0 |
| **critical** | HP ≤ 25%。触发 art-bible Section 7.1 玩家锚定环 α=1.0 + 1.2s 慢呼吸脉冲 | HP 从 healthy 下降到 ≤ 25% | HP 回升 > 25% / HP ≤ 0 |
| **invulnerable** | 无敌帧期间,所有 DamageEvent 被忽略(但触发 VFX) | 受伤后 i-frame 600ms | 600ms 结束 |
| **dead** | HP = 0。Damage 系统冻结此实体的所有事件 | HP 降到 0 | 仅通过外部 `resurrect()` API |

**critical 和 invulnerable 是叠加状态**:玩家可同时在 critical + invulnerable(刚被击中至残血)。
**healthy/critical 是 HP 数值的派生状态**——不是独立状态,只是 art-bible 触发条件。

### Interactions with Other Systems

**上游(发送 DamageEvent 给 Damage):**

| 上游 | 方向 | 接口 |
|------|------|------|
| **Technique System** | → Damage | 功法释放命中敌人时 emit DamageEvent |
| **Enemy AI** | → Damage | 敌人攻击命中玩家时 emit DamageEvent(包含 contact_damage 或 attack_damage) |
| **Boss AI** | → Damage | BOSS 招式命中玩家时 emit DamageEvent(招式 4 拍 Strike 阶段) |

**下游(消费 Damage 信号):**

| 下游 | 类型 | 信号/接口 |
|------|------|----------|
| **Player Controller** | Hard | 订阅 `damage_dealt(event)`,如果 victim==player,调用 `apply_knockback()`;订阅 `entity_died(player)` 触发死亡序列 |
| **Camera System** | Hard | 订阅 `damage_dealt(event)`,根据 knockback_tier 调用 `Camera.shake()` |
| **Spirit/XP System** | Hard | 订阅 `entity_died(enemy_id)` 触发灵气掉落 |
| **Drop/Pickup System** | Hard | 订阅 `entity_died(enemy_id)`(包含 BOSS)触发掉落 |
| **VFX System** | Hard | 订阅 `damage_dealt(event)` 渲染命中粒子(元素色板 + 朱砂红 if 致命) + 飞字 |
| **Audio Manager** | Hard | 订阅 `damage_dealt(event)` 播放击中音(按元素 + knockback_tier 选择) |
| **HUD** | Hard | 订阅 `hp_changed(entity_id, new_hp, max_hp)` 更新血条 + 玩家锚定环;`entity_died` 触发死亡画面 |
| **Boss AI** | Soft | 订阅 `damage_dealt(victim=boss_self)` 判定 phase 切换(HP 阈值触发) |
| **Realm Progression** | Soft | 订阅 `entity_died(boss_id)` 判定境界守护者击败 |

**Godot 信号契约:**
- `damage_dealt(event: DamageEvent)` — 伤害已结算(HP 已扣),供下游响应
- `hp_changed(entity_id: int, new_hp: float, max_hp: float)` — HP 变化时(包括恢复)
- `entity_died(entity_id: int)` — 实体死亡时(HP 触 0 同帧 emit)
- `iframe_started(entity_id: int, duration: float)` — 无敌帧开始
- `iframe_ended(entity_id: int)` — 无敌帧结束

## Formulas

> **顶层判断**: 玩家 HP=20 固定不递增,力量感由功法+留白半径承担。境界递增由 (1) 敌人伤害 (2) 敌人 HP 承担——杂兵幂次递增(突破后被构筑碾压),BOSS 线性递增(始终是事件)。MVP 不引入暴击伤害倍率(避免随机伤害方差稀释构筑核心);is_crit 只影响 VFX/Audio。

---

### Formula 1: 最终伤害计算

```
final_damage = round_half_up(
    raw_damage × element_mult(atk_elem, def_elem) × (1 - mitigation)
)
final_damage = clamp(final_damage, 1, max_HP)   # 最低 1,过量截断
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `raw_damage` | int | [1, 30] | 攻击事件基础伤害 |
| `atk_elem`, `def_elem` | enum | {火,冰,风,雷,剑,拳,无} | 攻击/防御元素 |
| `element_mult` | float | {0.7, 1.0, 1.5} | 查 F2 矩阵 |
| `mitigation` | float | [0.0, 0.8] | 减伤(MVP=0, VS 接入构筑/功法) |
| `final_damage` | int | [1, max_HP] | 写入 HP |

**Output Range**: [1, 20] for player (clamp to max_HP);1 是硬地板防止"无效命中"困惑。

**Worked Example**: 火球 raw=6, 攻火 vs 防冰 → 6 × 1.5 × 1.0 = 9。HP=20 玩家被命中后 HP=11。

**Rationale**: 无暴击保留确定性,玩家可从受击次数倒推危险。round_half_up 避免 0.5 偏差。

---

### Formula 2: 元素相克倍率(固定三档)

| 攻\\防 | 火 | 冰 | 雷 | 风 | 剑 | 拳 | 无 |
|--------|----|----|----|----|----|----|----|
| **火** | 1.0 | **1.5** | 1.0 | **0.7** | 1.0 | 1.0 | 1.0 |
| **冰** | **0.7** | 1.0 | **1.5** | 1.0 | 1.0 | 1.0 | 1.0 |
| **雷** | 1.0 | **0.7** | 1.0 | **1.5** | 1.0 | 1.0 | 1.0 |
| **风** | **1.5** | 1.0 | **0.7** | 1.0 | 1.0 | 1.0 | 1.0 |
| **剑/拳/无** | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 |

**Rationale**:
- 1.5 让"打对元素"明显多打掉 1 跳 HP(raw=6 → 9)
- 0.7 让"打错"惩罚温和但可感(raw=6 → 4),不至于硬克到打不动
- 不用 1.5/0.5 对称,0.5 过度惩罚单元素构筑(自动战斗无法实时换属性)
- 剑/拳/无 全中性——art-bible Section 4.5 设定

---

### Formula 3: 玩家最大 HP

```
max_HP = 20   # 全局常量,不随境界变化
```

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `max_HP` | int | {20} | 玩家最大生命 |

**Rationale**: HP 不递增是核心设计契约——让 R5 的 6 点单击始终"3 击死",玩家始终保持危险感。如果 HP 随境界递增,后期容错变高,违反 art-bible "朱砂红致命意图"的紧张感。

---

### Formula 4: 敌人伤害 × 境界递增(线性)

```
mob_damage(R, tier) = round( base_dmg[tier] × (1.0 + 0.45 × (R - 1)) )
```

**Base damage 表 (R1)**:

| Tier | base_dmg |
|------|----------|
| 杂兵 | 2 |
| 精英 | 4 |
| 守护者 | 6 |
| BOSS | 8 |

**实际伤害矩阵**(玩家 HP=20 → 受击次数):

| Tier \\ R | R1 | R2 | R3 | R4 | R5 | R6 |
|-----------|----|----|----|----|----|----|
| 杂兵 | 2 (10击) | 3 (7) | 4 (5) | 5 (4) | 6 (3) | 7 (3) |
| 精英 | 4 (5) | 6 (3) | 7 (3) | 9 (3) | 12 (2) | 13 (2) |
| 守护者 | 6 (3) | 9 (3) | 11 (2) | 14 (2) | 17 (2) | 20 (1) |
| BOSS | 8 (3) | 12 (2) | 14 (2) | 18 (2) | 22 (1) | 26 (1) |

**Worked Example**: R5 精英无元素 raw=12,玩家防御无元素,mitigation=0 → final=12,HP 20→8。

**Rationale**:
- 杂兵 R1/R3/R5 = 2/4/6 命中"心智模型"
- BOSS R5+ 单击 22 > HP → "一击秒杀"成立,匹配 art-bible 朱砂红
- 守护者 R6 = 20 是有意"满血一击死"阈值,"看见就走"的强信号

---

### Formula 5: 敌人 HP × 境界(杂兵幂次 / BOSS 线性)

```
enemy_HP(R, tier) = round( base_HP[tier] × realm_HP_curve(R, tier) )

realm_HP_curve(R, tier) =
    R^1.6                  if tier ∈ {杂兵, 精英}     # 幂次,被构筑碾压
    1.0 + 1.2 × (R - 1)    if tier ∈ {守护者, BOSS}    # 线性,保留挑战
```

**Base HP 表 (R1)**:

| Tier | base_HP |
|------|---------|
| 杂兵 | 10 |
| 精英 | 50 |
| 守护者 | 300 |
| BOSS | 见 Boss AI GDD（80-150，per-BOSS 定义） |

> **注**: BOSS base_HP 不使用此表的统一值。每个 BOSS 有独立 HP（BOSS-A=80, BOSS-B=120, BOSS-C=100, 守护者=150），详见 `boss-ai.md` 的 MVP BOSS 设计。本公式的 `base_HP[BOSS]=1000` 仅为公式结构的历史示例，已废弃。

**实际 HP 矩阵**:

| Tier \\ R | R1 | R2 | R3 | R4 | R5 | R6 |
|-----------|------|------|------|------|------|------|
| 杂兵 | 10 | 30 | 62 | 105 | 158 | 220 |
| 精英 | 50 | 152 | 309 | 524 | 791 | 1102 |
| 守护者 | 300 | 660 | 1020 | 1380 | 1740 | 2100 |
| BOSS | 1000 | 2200 | 3400 | 4600 | 5800 | 7000 |

**Rationale**:
- **杂兵幂次 1.6**: R6/R1 = 22 倍 HP,vs BOSS 仅 7 倍——杂兵越后期越"装饰品",玩家构筑要碾压;BOSS 始终是"事件"。Survivor-like 核心节奏
- **BOSS 线性**: 避免后期 BOSS HP 爆炸到玩家打不动,保证 30-40 分钟一局可达
- **指数 1.6 非 2.0**: 2.0 会让 R6 杂兵 = 360 HP 可能超过玩家清屏 DPS,1.6 提供"碾压但需构筑"张力

---

### Formula 6: 无敌帧时长

```
i_frame_duration = 600 ms   # 玩家受击后无敌
enemy_i_frame = 0 ms        # 敌人无 i-frame
```

**Rationale**:
- 敌人 knockback duration 100-250ms (PC F3),i-frame 600ms ≈ knockback 中位数 3-6 倍 → 单敌击退恢复后不会立刻二次命中,玩家有"被打→安全→走位"清晰循环
- 多敌人重叠场景(Survivor 后期数十敌人):若 i-frame < 400ms,玩家被瞬间连击秒杀(20HP @ R5 = 3击死,3×400ms = 1.2s);600ms 保证连击间隔 ≥ 0.6s 给反应窗口
- 不建议 > 800ms:让"挨打反而安全"成立(BOSS 时代故意吃伤换 i-frame),违反走位优先

**视觉**: i-frame 期间角色半透明 alpha=0.6 + art-bible Section 4.2 朱砂红边缘 120ms 闪烁(后者只在被命中瞬间)。

---

### Formula 耦合关系

```
R (境界 1-6) → F4 mob_damage  ←─┐
              → F5 enemy_HP     │
                                │
DamageEvent.raw → F2 element_mult → F1 final_damage
                                          ↓
                                    HP -= final_damage
                                          ↓
                                    F6 i_frame (600ms 锁伤害)
                                          ↓
                                    F3 max_HP=20 (常量)
```

**关键耦合点 / 风险**:
1. **F4 × F3**: HP 固定,F4 slope 0.45 决定"R5 必须 3 击死"。slope 调高到 0.6 → R5 杂兵 7 伤害 → 2 击死,容错过低。**0.45 是下限**
2. **F5 × 外部玩家 DPS**: 杂兵幂次 1.6 假设玩家 DPS 也按类似曲线增长。如功法系统 DPS 不达标,1.6 需调到 1.4。**最敏感 tuning knob**
3. **F1 clamp 下限 1**: 与 F2 反向 0.7 耦合——防止 raw=1 × 0.7 = 0 的"打不疼"事件
4. **F6 × F4**: 600ms i-frame 保证 BOSS R5+(22 伤)击中后玩家有 0.6s 走位机会,**否则被连续触摸秒杀**

## Edge Cases

- **If 同帧多个 DamageEvent 命中同一玩家**: 第一个事件触发 i-frame,后续事件被 i-frame 截断(emit `damage_blocked_iframe` 信号供 VFX 渲染但不扣 HP)。**Damage 系统单帧排序按 attacker_id 升序**(Core Rule 8),确定性。
- **If 同帧多个玩家功法击杀同一敌人**: 第一个事件结算后敌人进入 dead 状态,后续事件被 dead 状态截断。**Spirit/XP 系统只收到 1 个 entity_died 信号**——不会重复掉灵气。
- **If 玩家在 i-frame 期间触碰大量敌人**: 所有事件被 i-frame 截断,玩家在 i-frame 600ms 内可以"穿越敌群"。这是设计内行为(走位高手的奖励)。
- **If 致命伤害 + 玩家正在突破仪式(immobile)**: PC GDD 已锁定 immobile 期间所有 knockback 被忽略,但 Damage 是否也忽略?**MVP 决策**: immobile 期间 DamageEvent 被截断(emit `damage_blocked_immobile` 信号但不扣 HP),保护突破仪式不被 RNG 致死。
- **If raw_damage = 0(零伤害事件,如 Technique 标记 marker 无伤害)**: F1 clamp 下限 1 强制最小伤害为 1。如果设计真需要"零伤害事件"(纯触发 buff),用专门的 `EffectEvent` 而非 DamageEvent——**这是开放问题**。
- **If 玩家 HP 已为 0 但 DamageEvent 持续到达**: 第一个致死事件 emit `entity_died`,实体进入 dead 状态,后续事件被截断。
- **If element 是新元素(MVP 之外的扩展)**: F2 矩阵查表失败时返回 1.0(无相克)。**警告日志**写入,等架构阶段补充。
- **If 敌人 HP 因元素相克 ×0.7 后变成 0.7 还不到 1**: F1 clamp 下限 1,敌人受 1 点伤害。这是"打不疼但不会无效"的最低反馈契约。
- **If 致命伤害刚好等于 HP**: HP 设为 0,触发死亡。F1 clamp 上限 max_HP 保证不会出现负 HP。
- **If DamageEvent 的 attacker_id == victim_id(自伤)**: MVP 不支持自伤,Damage 系统忽略此事件并 emit warning。VS 阶段如有"反伤"类机制,需在此扩展处理逻辑。
- **If 玩家受伤瞬间正在进行境界突破清场(F4 from PC GDD)**: 突破清场是 PC 自身能力,玩家在突破 600ms 内是 immobile,无敌(参考上文)。清场期间敌人靠近的瞬间被清除,不会产生 DamageEvent。
- **If 玩家死亡瞬间正好有飞行中的 DamageEvent(延迟 emit)**: 玩家进入 dead 状态后,后续 DamageEvent 被截断。死亡画面不显示"被打了"的红光闪烁——这是设计内行为(art-bible Section 2 死亡是仪式不是连续战斗)。

## Dependencies

### Upstream(发送 DamageEvent 给 Damage)

| 上游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **Technique System** | Hard | `DamageBus.deal_damage(event)` API,功法命中敌人时调用 | 未设计 (Order #10) |
| **Enemy AI** | Hard | 敌人攻击命中玩家时调用 `DamageBus.deal_damage()` | 未设计 (Order #6) |
| **Boss AI** | Hard | BOSS 招式 Strike 阶段调用 `DamageBus.deal_damage()`(art-bible Section 5.2 4 拍节奏) | 未设计 (Order #11) |

### Downstream

| 下游 | 硬/软 | 接口 | 类型 |
|------|------|------|------|
| **Player Controller** | Hard | 订阅 `damage_dealt(event)`,if victim==player 调 `apply_knockback()`;订阅 `entity_died(player)` 触发死亡 | 信号 |
| **Camera System** | Hard | 订阅 `damage_dealt`,按 knockback_tier 调 `Camera.shake()` | 信号 |
| **Spirit/XP System** | Hard | 订阅 `entity_died(enemy_id)` 触发灵气掉落 | 信号 |
| **Drop/Pickup System** | Hard | 订阅 `entity_died` 触发掉落 | 信号 |
| **VFX System** | Hard | 订阅 `damage_dealt` 渲染命中粒子 + 飞字 | 信号 |
| **Audio Manager** | Hard | 订阅 `damage_dealt` 播放击中音 | 信号 |
| **HUD** | Hard | 订阅 `hp_changed(entity_id, new_hp, max_hp)` 更新血条 | 信号 |
| **Boss AI** | Soft | 订阅 `damage_dealt(victim=boss_self)` 判定 phase 切换 | 信号 |
| **Realm Progression** | Soft | 订阅 `entity_died(boss_id)` 判定境界守护者击败 | 信号 |

### External

- Godot 4.6 信号系统(`signal` 关键字)
- Godot 4.6 `Area2D.body_entered` / `area_entered` 用于碰撞检测(Damage 不直接处理,但敌人侧依赖)

### Forbidden

- 其他系统**禁止**直接修改实体的 HP 属性(必须走 `DamageBus.deal_damage(event)`)
- 其他系统**禁止**绕过 DamageBus 发送伤害信号(防止规避 i-frame / element mult)
- Damage 系统**禁止**包含任何"敌人种类/招式名称/功法效果"的语义逻辑——只处理事件本身

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 | 异常行为 |
|------|--------|----------|------|----------|
| `MAX_HP_PLAYER` | 20 | [15, 25] | 受击次数心智模型 | 过低=R5 容错崩;过高=失去紧张感 |
| `ELEMENT_MULT_ADVANTAGE` | 1.5 | [1.3, 1.7] | 元素构筑收益感 | 过低=元素策略无意义;过高=单元素构筑超模 |
| `ELEMENT_MULT_DISADVANTAGE` | 0.7 | [0.6, 0.85] | 错配惩罚强度 | 过低=元素硬克难受;过高=元素无策略 |
| `REALM_DMG_SLOPE` | 0.45 | [0.35, 0.55] | F4 后期玩家容错 | 过高=R5 玩家瞬秒;过低=后期无紧张 |
| `MOB_HP_EXPONENT` | 1.6 | [1.4, 1.8] | F5 "突破清场"强度 | 过高=后期杂兵打不动;过低=越后期越无威胁 |
| `BOSS_HP_SLOPE` | 1.2 | [1.0, 1.5] | F5 BOSS 战时长 | 过高=BOSS 战 5 分钟;过低=BOSS 秒死 |
| `I_FRAME_DURATION_MS` | 600 | [500, 800] | F6 多敌人连击容错 | 过低=后期被秒;过高=玩家滥用挨打 |
| `BASE_DMG_TABLE` | [2,4,6,8] (杂兵/精英/守护者/BOSS) | per-tier ±20% | F4 R1 基础伤害 | 锁定为整数,可单档调 |
| `BASE_HP_TABLE` | [10,50,300,1000] | per-tier ±30% | F5 R1 基础 HP | 锁定为整数 |
| `CRIT_MULTIPLIER` | (V1.1 预留) | — | 暴击倍率,MVP 不启用 | VS 阶段如做"构筑词条"再启 |
| `MITIGATION_FLOOR` | 0.0 | [0.0, 0.0] (MVP 锁定 0) | 减伤下限 | VS 接入构筑后可开放 [0.0, 0.5] |
| `MIN_FINAL_DAMAGE` | 1 | 锁定 | F1 最低伤害地板 | 防止"无效命中"困惑 |

**Knob 交互**:
- `MAX_HP_PLAYER` 与 `REALM_DMG_SLOPE` 强耦合——调一个必须调另一个(否则受击次数心智模型崩溃)
- `MOB_HP_EXPONENT` 隐含假设玩家 DPS 也按类似曲线增长——**和 Technique System 功法升级曲线必须同步设计**
- `I_FRAME_DURATION_MS` 必须 ≥ 敌人最高 knockback duration (250ms) 的 2x,否则单击退结束后立刻二次命中

**调优优先级**:
- **Tier 1**(核心契约): MAX_HP_PLAYER, REALM_DMG_SLOPE, I_FRAME_DURATION_MS
- **Tier 2**(平衡): ELEMENT_MULT_*, MOB_HP_EXPONENT, BOSS_HP_SLOPE, BASE_DMG_TABLE
- **Tier 3**(扩展): CRIT_MULTIPLIER, MITIGATION_FLOOR(VS 阶段开放)

## Visual/Audio Requirements

### Visual(VFX System 消费 Damage 信号)

**伤害命中反馈**(每个 `damage_dealt(event)` 信号触发):
- **元素粒子爆炸**: 在 `event.position` 渲染对应元素色板的粒子(art-bible Section 4.5):
  - 火 = `#C45A3A → #D49048` 喷溅
  - 冰 = `#EDF0F2` 核心 + `#3B5C78` 边缘碎片
  - 风 = `#1A1D22 @ 25%` 风刃笔触
  - 雷 = `#5E426E` 折线 + 单帧 `#F0E8D8` 白闪
  - 剑 = `#1A1D22` 锋利切线 + `#D8DEE4` 光泽
  - 拳 = `#1A1D22` 钝击 + `#B8403A` 撞击溅红
- **伤害飞字**: 等宽几何字体,颜色按元素;暴击(is_crit=true)字体 ×1.5 缩放 + 朱砂红描边

**玩家受击反馈**(victim == player):
- **HP 条朱砂红短闪**: 左上 HP 条边缘 120ms 朱砂红闪(art-bible Section 7.1)
- **玩家锚定环额外强闪**: 即使 HP > 70%,被击时也短暂闪到 α=1.0
- **i-frame 期间**: 玩家角色半透明 alpha=0.6,持续 600ms
- **critical 状态(HP ≤ 25%)**: 玩家锚定环常亮 + 1.2s 慢呼吸脉冲(art-bible Section 7.1 已锁定)

**死亡反馈**(`entity_died` 玩家):
- art-bible Section 2 死亡仪式: 0.4s 快速脱色至灰阶 → 玩家剪影碎裂为墨点向下漂浮 → 1.5s 淡入黑底"殁"字
- 死亡瞬间清空所有进行中的震屏/VFX(Camera GDD Edge Case 已规范)

**BOSS Phase 切换反馈**(`damage_dealt(victim=boss_self)` 触发 HP 阈值):
- 在 Boss AI GDD 中定义具体 phase 视觉,本 GDD 只保证 `hp_changed` 信号供其消费

### Audio(Audio Manager 消费)

- **击中音**: 按 `(element, knockback_tier)` 组合查表,每元素 5 档(对应 5 档击退力度)
- **暴击音**: is_crit=true 时叠加一层金属脆响
- **HP 警报音**: 进入 critical 状态时低频心跳脉冲,直到 HP > 25%
- **死亡音**: art-bible Section 7.5 死亡仪式音(由 Audio Manager 决定具体 SFX)

> **📌 Asset Spec** — Visual/Audio requirements 已定义。在 art bible approved 后,运行 `/asset-spec system:damage-health-system` 产出 per-asset 粒子描述/飞字字体/声效具体规格。

## UI Requirements

**Damage 系统不直接拥有 UI 屏幕**,但下游 HUD 系统(Order #13)消费 Damage 信号渲染所有血量相关 UI:

- **玩家 HP 条**(art-bible Section 7.1): 左上竖窄条 + 玩家锚定朱砂环(critical 触发)
- **BOSS HP 条**(art-bible Section 7.1): 顶部中央横线,Boss Fight 状态出现
- **敌人头顶 HP**(可选,MVP 不做): 普通敌人不显示血条,精英可显示
- **伤害飞字**: 世界层,跟随相机投影(art-bible UI Section 7.1 锁定)

> **📌 UX Flag — Damage/Health System**: 没有独立 UI 屏幕,但与 HUD 系统(Order #13)有重度数据耦合。在 Pre-Production 运行 `/ux-design` 设计 HUD 时,验证血条频率/动画/critical 触发条件与本 GDD 一致。

## Acceptance Criteria

> **Interface contracts (locked decisions)**: `attacker_id`/`victim_id` = Godot InstanceID (int);DamageBus 是 signal 总线(非函数);Element 是 GDScript `enum`;**i-frame 起点 = DamageEvent 处理完成后**;immobile 状态由 DamageBus 订阅 PC `state_changed` 信号维护本地 flag;`entity_died(victim_id: int, final_event: DamageEvent)` 让下游知道谁杀的、什么元素杀的。

### 接口契约层(枢纽稳定性 — 最先冻结)

### AC-DMG-01 [MVP] DamageEvent 字段契约
- **GIVEN** 任意系统构造一个 DamageEvent
- **WHEN** 检查其字段
- **THEN** 必须且仅包含 7 个字段: `attacker_id: int`, `victim_id: int`, `raw_damage: float`, `element: Element`, `knockback_tier: int`, `is_crit: bool`, `position: Vector2`;字段缺失或多余 → 测试 fail

### AC-DMG-02 [MVP] DamageBus 是唯一总线(静态扫描)
- **GIVEN** 项目代码库
- **WHEN** grep `victim.hp -=` / `take_damage(` 等绕过 DamageBus 的写法
- **THEN** 除 DamageBus 内部实现文件外,匹配数 = 0(CI 静态检查)

### AC-DMG-03 [MVP] entity_died 信号签名稳定
- **GIVEN** DamageBus 加载完成
- **WHEN** 检查 `entity_died` 信号
- **THEN** 签名 = `entity_died(victim_id: int, final_event: DamageEvent)`;至少 1 个测试用例验证 Spirit/Drop/VFX/Audio 能正确解包此 payload

### 核心规则层

### AC-DMG-04 [MVP] 玩家 max_HP = 20 常量
- **GIVEN** 任意境界 R ∈ [1, 6]、任意游戏状态
- **WHEN** 查询 `Player.max_hp`
- **THEN** 返回值恒为 20;grep `max_hp =` 仅出现在初始化代码

### AC-DMG-05 [MVP] 单帧多事件确定性排序
- **GIVEN** 同一物理帧内 3 个 DamageEvent 同时入队,attacker_id = [300, 100, 200]
- **WHEN** DamageBus.flush() 执行
- **THEN** 处理顺序 = [100, 200, 300] 升序;连续 100 次运行结果一致

### AC-DMG-06 [MVP] HP≤0 触发 entity_died 一次(防重复掉落)
- **GIVEN** 敌人当前 HP = 5
- **WHEN** 同帧两个 DamageEvent 各造成 10 伤害命中
- **THEN** `entity_died` 仅触发 1 次;第二个 DamageEvent 被识别为 "victim already dead" 并丢弃

### AC-DMG-07 [MVP] 过量伤害截断
- **GIVEN** 玩家 HP = 3
- **WHEN** 收到 raw_damage = 999 的 DamageEvent
- **THEN** final_damage 截断为 3,HP → 0,触发 entity_died

### 公式层

### AC-DMG-08 [MVP] F1 final_damage 计算 + clamp
- **GIVEN** raw=10, element_mult=1.5, mitigation=0.2
- **WHEN** F1 计算
- **THEN** `final = round(10 × 1.5 × 0.8) = 12`;raw=0 时 final clamp 下限 1;raw=100 命中 max_HP=20 玩家时 clamp 上限 20

### AC-DMG-09 [MVP] F2 元素矩阵完整覆盖(7×7 参数化)
- **GIVEN** 元素相克矩阵 7×7 = 49 个组合
- **WHEN** 遍历所有 (atk_elem, def_elem) 对
- **THEN** 火→冰/冰→雷/雷→风/风→火 = 1.5(4 对);反向 = 0.7(4 对);其余 41 对 = 1.0;查表失败 → 1.0 + WARNING 日志

### AC-DMG-10 [MVP] F4 mob_damage 境界递增(线性 0.45)
- **GIVEN** base_dmg[杂兵] = 2 (per Section D)
- **WHEN** R=1..6 代入 `damage = 2 × (1 + 0.45×(R-1))`
- **THEN** 序列 = [2, 3, 4, 5, 6, 7] (round后,±1 容差);base_dmg[BOSS]=8 时序列 = [8, 12, 14, 18, 22, 26]

### AC-DMG-11 [VS] F5 enemy_HP 境界递增(杂兵幂次 vs BOSS 线性)
- **GIVEN** 杂兵 base_HP=10, BOSS base_HP=1000
- **WHEN** R=1..6 代入 F5
- **THEN** 杂兵 `10 × R^1.6` → [10, 30, 62, 105, 158, 220] ±1%;BOSS `1000 × (1 + 1.2×(R-1))` → [1000, 2200, 3400, 4600, 5800, 7000] ±1%

### AC-DMG-12 [MVP] F6 i-frame 时长
- **GIVEN** 玩家被 DamageEvent 命中
- **WHEN** 检查 `invulnerable` 状态持续时间
- **THEN** 时长 = 600ms ±16ms(单帧容差);**起点 = DamageEvent 处理完成时**;敌人 i-frame = 0ms

### 状态机层

### AC-DMG-13 [MVP] critical 阈值转换
- **GIVEN** 玩家 max_HP=20
- **WHEN** HP 从 6 降到 5(降到 25% 边界)
- **THEN** state 从 `healthy` 转为 `critical`;HP 回到 6 时转回 `healthy`(无滞回);触发 art-bible 玩家锚定环 α=1.0 + 1.2s 慢呼吸脉冲

### AC-DMG-14 [MVP] dead 状态不可逆
- **GIVEN** 玩家 state = dead
- **WHEN** 任意"治疗"调用尝试设置 HP > 0
- **THEN** state 保持 dead, HP 保持 0,操作被拒绝并 WARNING 日志;仅外部 `resurrect()` API 可解除

### Edge Case 层

### AC-DMG-15 [MVP] i-frame 在多敌人同帧场景
- **GIVEN** 玩家 HP=20, healthy,同帧 4 个敌人 Area2D 同时触发玩家
- **WHEN** DamageBus.flush() 处理
- **THEN** **仅第一个**(按 attacker_id 升序)生效;HP 减少 1 次;其余 3 个被 i-frame 截断;i-frame 计时仅启动 1 次(600ms)

### AC-DMG-16 [MVP] immobile 期间伤害截断(突破仪式保护)
- **GIVEN** 玩家 state 包含 `immobile`(突破期间)
- **WHEN** DamageBus 收到任意 DamageEvent victim=player
- **THEN** 事件被截断(HP 不变);INFO 日志 `event dropped: victim immobile`;**不**触发 i-frame
- **Mechanism**: DamageBus 订阅 PC `state_changed` 信号维护本地 flag

### AC-DMG-17 [VS] raw=0 强制最小伤害下限
- **GIVEN** raw_damage = 0(刮蹭或浮点误差产生)
- **WHEN** F1 计算
- **THEN** final = clamp(0, 1, max_HP) = 1;事件正常处理(不静默丢弃)

### AC-DMG-18 [MVP] 碰撞→伤害桥接(敌人 Area2D)
- **GIVEN** 敌人挂 Area2D,玩家挂受击 Area2D
- **WHEN** 两者 `area_entered` 触发
- **THEN** 桥接器构造 DamageEvent 并 emit 到 DamageBus,**不直接**修改 HP;集成测试通过场景验证

---

### Test Evidence Classification

| AC | Type | Evidence Location | Gate |
|----|------|-------------------|------|
| AC-DMG-01, 04, 05, 07, 08, 09, 10, 11, 12, 13, 14, 17 | Logic | `tests/unit/damage/*.gd` | BLOCKING |
| AC-DMG-02 | Static CI | `tools/ci/check_damage_bus_bypass.sh` (grep-based) | BLOCKING |
| AC-DMG-03, 06, 15, 16, 18 | Integration | `tests/integration/damage/*.gd` | BLOCKING |

**统计**: 18 AC = 16 MVP + 2 VS;全部 BLOCKING(枢纽系统无 ADVISORY)。Logic 13 / Integration 5。

**Coverage**: 10 Core Rules × 6 Formulas × 关键 Edge Cases × 7 hard downstream 接口契约 全覆盖。

## Open Questions

1. **零伤害事件的处理**: F1 clamp 下限 1 强制最小伤害,但如果设计真需要"零伤害事件"(纯触发 buff/状态,无伤害),需要专门的 `EffectEvent` 类型。**Owner**: game-designer + Technique designer。**Target**: Technique System GDD 设计时(Order #10)。

2. **元素相克的额外触发(如冰/雷融合产生霜雷)**: art-bible Section 4.5 定义了 7 个元素融合,但 MVP DamageEvent 只支持单元素。是否需要 `secondary_element` 字段?**Owner**: game-designer。**Target**: Combo System GDD 设计时(Order #17)。

3. **i-frame 的特殊覆盖**: 是否有"穿透 i-frame"的招式(如 BOSS 大招)?当前 MVP 没有,VS 阶段如需要要在 DamageEvent 加 `bypass_iframe: bool` 字段。**Owner**: game-designer。**Target**: Boss AI GDD 设计时(Order #11)。

4. **伤害号溢出 max_HP**: F1 clamp 上限 max_HP,但 BOSS HP 在 R5/R6 是 5800/7000——单击 20+ 伤害对 BOSS 来说极少。是否需要单独限制玩家造成的最大单击伤害(防极端 OP combo)?**Owner**: systems-designer + game-designer。**Target**: Technique/Combo GDD 设计完成后回归。

5. **持续伤害(DoT)**: MVP 没设计,但火/雷元素自然适合 DoT。如果加入,DamageBus 需支持 `tick_damage(victim, dmg_per_sec, duration)` API。**Owner**: game-designer。**Target**: VS 阶段功法扩展时。

6. **多攻击者同帧击杀的灵气归属**: AC-DMG-06 规定只 emit 1 个 entity_died,但 final_event 是"按 attacker_id 升序的第一个 attacker"。这是否符合玩家直觉?如果玩家功法 A 打 9 伤、敌人毒 1 伤同帧致死,玩家会觉得"我杀的"但 entity_died.attacker 可能是毒(取决于 ID 顺序)。**Owner**: game-designer + qa-tester。**Target**: 实测验证后决定是否改为"按 dealt_damage 降序"取最大伤害归属。
