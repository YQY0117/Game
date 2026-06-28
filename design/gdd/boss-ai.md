# Boss AI + State Machine (BOSS 行为状态机)

> **Status**: In Design
> **Author**: user + game-designer + ai-programmer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 1 (近在咫尺 — BOSS 是每局最高潮的事件) + Pillar 3 (自创流派 — 不同 BOSS 掉不同功法，驱动构筑选择)
> **Priority**: MVP | **Layer**: Feature
> **Source Systems Index**: design/gdd/systems-index.md (Order #16)

## Overview

Boss AI 定义每个 BOSS 的行为模式——攻击循环、移动策略、受击反馈、死亡序列。与杂兵的简单 seek 不同，BOSS 拥有**4 拍 Tell 节奏**（art-bible Section 5.2 锁定）和**2-3 种攻击模式**的固定循环。BOSS 是每局游戏的最高潮事件——它的出现意味着"这一局的终极挑战"。

MVP 阶段实现 4 个 BOSS（3 可选 + 1 守护者），每个 BOSS 有独立的攻击模式和视觉特征，但共享同一套状态机框架。

## Player Fantasy

**Direct — BOSS 战是每局最紧张的 90 秒。**

玩家感受的:**看得见的招式预告 + 读招成功的成就感**。BOSS 蓄力时朱砂红光芒聚集（Charge），闪光一瞬（Mid-charge），招式爆发（Strike），然后破绽（Recovery）——玩家在这 4 拍节奏中走位、判断、反击。BOSS 不是"血更厚的杂兵"，而是**需要读懂的对手**。

参考标杆:**Hades** 的 BOSS 战——每个 BOSS 有清晰的攻击预告和恢复窗口。**鬼谷八荒**的境界守护者——击败守护者是境界突破的仪式感。我们结合两者:Hades 的读招节奏 + 鬼谷的境界仪式。

## Detailed Design

### Core Rules

**1. BOSS 共享状态机框架**:

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **spawning** | 入场动画 1.0s（墨色浓聚 + 留白扩张），期间无敌 | Enemy Spawner 生成 | 1.0s 后 |
| **idle** | 缓慢追踪玩家，保持中距离（200-400px） | spawning 结束 / recovery 结束 | 攻击循环计时器触发 |
| **telegraph** | 4 拍 Tell 第 1-2 拍：朱砂红光芒聚集 + 闪光 | 攻击循环触发 | Tell 时长结束（1.0-1.5s） |
| **attacking** | 4 拍第 3 拍：释放攻击（弹幕/冲撞/AoE） | telegraph 结束 | 攻击动画完成 |
| **recovery** | 4 拍第 4 拍：破绽窗口，玩家可安全输出 | attacking 结束 | recovery 时长结束（1.5-2.0s） |
| **hitstun** | 被玩家功法击中，短暂击退 + AI 暂停 | 收到 `damage_dealt(victim=self)` | knockback duration 结束 |
| **phase_transition** | HP 阈值触发（50%/25%），短暂无敌 + 行为变化 | HP 降到阈值 | 过渡动画完成（1.0s） |
| **dying** | 死亡动画 2.0s（墨色溶解 + 泼彩消散），触发 `entity_died` | HP ≤ 0 | 2.0s 后移除 |

**优先级**: dying > phase_transition > hitstun > attacking > telegraph > idle > spawning

**2. 4 拍 Tell 节奏**（art-bible Section 5.2 锁定）:

| 拍 | 时长 | 视觉 | 音效 |
|----|------|------|------|
| Charge (1.0-1.5s) | 朱砂红光芒在攻击起点聚集，半径预览 AoE | 低沉蓄力声 |
| Mid-charge (0.5s) | 单帧纸白闪光 | 高频"叮"声 |
| Strike (瞬时) | 元素色沿预览形状爆发，朱砂红消耗 | 攻击音效 |
| Recovery (1.5-2.0s) | 身体恢复饱和度，留白圈重建 | 疲惫喘息声 |

**3. 攻击循环（固定顺序）**:
- 每个 BOSS 有 2-3 种攻击模式，按固定顺序循环
- 循环间隔: idle 状态 2-4 秒后触发下一次攻击
- 循环不被打断（hitstun 只暂停当前状态，不跳过攻击）

**4. 移动策略**:
- idle 状态: 缓慢追踪玩家，保持 200-400px 中距离
- telegraph 状态: 停止移动（或缓慢调整朝向）
- attacking 状态: 按攻击类型移动（冲撞型快速移动，弹幕型原地释放）
- recovery 状态: 停止移动（破绽窗口）

**5. BOSS 强制留白圈**（art-bible Section 5.2 锁定）:
- 半径: 2.0× BOSS bounding-box
- 杂兵在此范围内被推开（Enemy AI 已处理）
- 玩家弹幕正常穿过此圈
- 此圈是**视觉规则**，不是物理碰撞

### 4 个 MVP BOSS 设计

#### BOSS-A: 烈焰长老（超人形，火系）

| 属性 | 值 |
|------|-----|
| 体型 | 2.0× player |
| 元素 | 火 |
| HP | 80 |
| 掉落功法 | T01 烈焰掌 + T04 疾风刃 |

**攻击模式（3 种循环）**:

| 模式 | 描述 | Tell | Strike | Recovery |
|------|------|------|--------|----------|
| 火球连射 | 3 发火球，扇形展开 | 朱砂红在双手聚集 1.0s | 3 发火球以 15° 间隔飞出 | 2.0s |
| 火焰冲击 | 直线冲撞，路径留下火焰 | 朱砂红在脚下聚集 1.2s | 快速冲向玩家位置，路径 AoE | 1.5s |
| 火焰爆发 | 以自身为中心 AoE | 朱砂红环形扩散 1.5s | 全方向火球爆发 | 2.0s |

#### BOSS-B: 冰霜巨兽（兽形，冰系）

| 属性 | 值 |
|------|-----|
| 体型 | 3.0× player |
| 元素 | 冰 |
| HP | 120 |
| 掉落功法 | T02 冰锥术 + T05 破甲符 |

**攻击模式（2 种循环）**:

| 模式 | 描述 | Tell | Strike | Recovery |
|------|------|------|--------|----------|
| 冰锥雨 | 指定区域降下冰锥 | 地面出现青白色圆形预警 1.5s | 区域内多发冰锥从天而降 | 2.0s |
| 冰霜吐息 | 锥形范围持续伤害 | 嘴部朱砂红聚集 1.0s | 锥形冰霜喷射，持续 2s | 1.5s |

#### BOSS-C: 雷霆剑客（超人形，雷系）

| 属性 | 值 |
|------|-----|
| 体型 | 2.5× player |
| 元素 | 雷 |
| HP | 100 |
| 掉落功法 | T03 雷霆斩 + T06 天罡剑诀 |

**攻击模式（3 种循环）**:

| 模式 | 描述 | Tell | Strike | Recovery |
|------|------|------|--------|----------|
| 雷斩 | 直线快速斩击 | 剑身紫金闪烁 0.8s | 直线雷电斩击，穿透 | 1.5s |
| 瞬移斩 | 瞬移到玩家身边斩击 | 原地朱砂红闪光 0.5s | 瞬移到玩家位置 + 范围斩击 | 2.0s |
| 雷阵 | 地面布置雷电法阵 | 多个朱砂红标记点 1.5s | 标记点依次爆发雷电 | 1.5s |

#### BOSS-D: 境界守护者（山形，复合元素）

| 属性 | 值 |
|------|-----|
| 体型 | 4.0× player |
| 元素 | 无（中性） |
| HP | 150 |
| 掉落功法 | 无（击败后触发境界突破） |

**攻击模式（2 种循环）**:

| 模式 | 描述 | Tell | Strike | Recovery |
|------|------|------|--------|----------|
| 大地震击 | 全屏震动 + 地面 AoE | 双拳高举朱砂红聚集 2.0s | 全屏震动 + 地面裂纹 AoE | 2.5s |
| 墨潮涌动 | 召唤杂兵潮 | 身体墨色膨胀 1.5s | 生成 20-30 个杂兵 | 2.0s |

### Phase Transition（HP 阈值触发）

| 阈值 | 效果 | 时长 |
|------|------|------|
| 50% HP | 短暂无敌 + 攻击速度 +20% + 攻击模式循环加快 | 1.0s |
| 25% HP | 短暂无敌 + 攻击速度 +40% + 新增攻击变体 | 1.0s |

### Interactions with Other Systems

**上游**:

| 上游 | 接口 | 频率 |
|------|------|------|
| **Player Controller** | 读取 `global_position` 作为追踪/攻击目标 | 每 AI tick |
| **Damage/Health System** | 订阅 `damage_dealt(victim=self)` 进入 hitstun；HP ≤ 0 触发 dying | 事件驱动 |
| **Run/Session Management** | 订阅 `run_state_changed`，非 playing 状态暂停 AI | 事件驱动 |
| **Enemy Spawner** | 通过 `spawn(type, position, R)` API 实例化 | 波次 5 |

**下游**:

| 下游 | 接口 | 类型 |
|------|------|------|
| **Damage/Health System** | 攻击命中玩家时调 `DamageBus.deal_damage()` | API |
| **Technique System** | BOSS 死亡后触发功法夺取流程 | 信号 |
| **Spirit/XP System** | 通过 Damage `entity_died` 触发灵气掉落 | 间接 |
| **HUD** | `boss_hp_changed(boss_id, current_hp, max_hp)` 信号 | 信号 |
| **VFX System** | `boss_attack_started`, `boss_phase_changed` 信号 | 信号 |
| **Audio Manager** | 同上 | 信号 |
| **Realm Progression** | `entity_died(boss_id)` 判断守护者击败 | 间接 |

**Godot 信号契约**:
- `boss_hp_changed(boss_id: int, current_hp: int, max_hp: int)` — BOSS HP 变化
- `boss_attack_started(boss_id: int, attack_type: String)` — BOSS 攻击开始
- `boss_phase_changed(boss_id: int, phase: int)` — BOSS 阶段转换
- `boss_died(boss_id: int)` — BOSS 死亡（冗余于 entity_died，便于下游直接订阅）

## Formulas

### Formula 1: BOSS HP

```
boss_hp(base_hp, R) = round(base_hp × (1.0 + 0.3 × (R - 1)))
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| base_hp | H | int | 80–150 | BOSS 基础 HP（见各 BOSS 定义） |
| R | R | int | 1–5 | 当前境界 |
| boss_hp | — | int | 80–195 | 实际 HP |

**Rationale**: HP 随境界线性增长，但 MVP 只有 R1，所以实际 HP = base_hp。

### Formula 2: 攻击循环间隔

```
cycle_interval(base, phase) = base / (1 + 0.2 × (phase - 1))
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| base | B | float | 3.0–5.0 | 基础循环间隔（秒） |
| phase | P | int | 1–3 | 当前阶段（1=正常, 2=50%HP, 3=25%HP） |
| cycle_interval | I | float | 1.5–5.0 | 实际间隔 |

**Rationale**: 阶段越高，攻击越频繁。Phase 3 时间隔减半。

## Edge Cases

- **如果 BOSS 在 telegraph 状态被击杀**: 立即进入 dying，跳过 attacking 和 recovery。
- **如果 BOSS 在 phase_transition 状态被击杀**: 过渡动画中断，直接进入 dying。
- **如果 BOSS 攻击命中正在 hitstun 的玩家**: 伤害正常结算（hitstun 不提供无敌，只有 i-frame 提供）。
- **如果两个 BOSS 同时存在（理论上不可能）**: 第二个 BOSS 生成时第一个应已死亡。如果异常，两个 BOSS 独立运行。
- **如果 BOSS 留白圈与玩家距离过近**: 玩家可进入留白圈（无物理阻挡），但杂兵被推开。

## Dependencies

### 上游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Damage/Health System** | Hard | `DamageEvent`, `entity_died`, `damage_dealt` 信号 |
| **Player Controller** | Hard | `global_position`, `state_changed` 信号 |
| **Run/Session Management** | Hard | `run_state_changed` 信号 |
| **Enemy Spawner** | Hard | `spawn(type, position, R)` API |

### 下游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Damage/Health System** | Hard | `DamageBus.deal_damage()` API |
| **Technique System** | Hard | 功法夺取流程 |
| **HUD** | Hard | `boss_hp_changed` 信号 |
| **Realm Progression** | Soft | `entity_died(boss_id)` 信号 |
| **VFX System** | Soft | BOSS 攻击/阶段信号 |
| **Audio Manager** | Soft | BOSS 攻击/阶段信号 |

## Tuning Knobs

| 旋钮 | 描述 | 安全范围 | 极端行为 |
|------|------|----------|----------|
| `boss.base_hp` | BOSS 基础 HP | 50–200 | <50: 太容易；>200: 战斗太长 |
| `tell_duration` | Tell 时长 | 0.5–2.0s | <0.5: 读招太难；>2.0: 节奏太慢 |
| `recovery_duration` | Recovery 破绽窗口 | 1.0–3.0s | <1.0: 玩家无输出时间；>3.0: 太容易 |
| `cycle_interval_base` | 攻击循环基础间隔 | 2.0–6.0s | <2.0: 攻击太密集；>6.0: 节奏太慢 |
| `phase_speed_bonus` | 阶段转换攻击速度加成 | 10–50% | <10: 阶段差异不明显；>50: 不可读 |
| `clearance_radius_mult` | 留白圈倍率 | 1.5–3.0× | <1.5: 杂兵干扰 BOSS 读招；>3.0: 圈太大 |

## Visual/Audio Requirements

**BOSS 视觉**（art-bible Section 5.2 锁定）:
- 身体: 泼彩（splash-color），非墨色
- Tell 色: 朱砂红 `#B8403A`（全元素统一）
- 留白圈: 2.0× bounding-box 半径
- 死亡: 墨色溶解 2.0s + 泼彩消散

**4 拍 Tell VFX**:
- Charge: 朱砂红光芒聚集，半径预览 AoE
- Mid-charge: 单帧纸白闪光
- Strike: 元素色爆发
- Recovery: 身体恢复饱和度

**音效**:
- 入场: 低沉鼓声
- Tell: 蓄力声（按元素不同）
- Strike: 攻击音效
- Recovery: 疲惫喘息
- 死亡: 墨色溶解音

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:boss-ai` to produce per-boss visual descriptions, attack VFX specs, and audio cue lists.

## UI Requirements

**BOSS HP 条**（HUD 顶部居中）:
- 位置: art-bible Section 7.1 TC（0.50, 0.04）
- 样式: 水平线，朱砂红填充
- 仅在 BOSS 战期间显示
- HP 变化时: 双层反馈（前层即时，后层延迟）

**BOSS 名称**（HP 条上方）:
- 朱砂印章，显示 BOSS 名称（如"烈焰长老"）
- 入场时短暂放大 + 朱砂闪光

> **📌 UX Flag — Boss AI**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for the BOSS HP bar and name display before writing epics.

## Acceptance Criteria

- **GIVEN** BOSS-A 烈焰长老进入 idle 状态，**WHEN** 3 秒后攻击循环触发，**THEN** 进入 telegraph（朱砂红聚集 1.0s），然后 attacking（3 发火球），然后 recovery（2.0s）。
- **GIVEN** BOSS HP 降到 50%，**WHEN** phase_transition 触发，**THEN** BOSS 短暂无敌 1.0s，攻击速度 +20%。
- **GIVEN** BOSS 在 telegraph 状态被击杀，**WHEN** HP ≤ 0，**THEN** 跳过 attacking/recovery，直接进入 dying（2.0s）。
- **GIVEN** BOSS 死亡，**WHEN** dying 动画完成，**THEN** 触发 `entity_died(boss_id)` 和 `boss_died(boss_id)` 信号，Technique System 启动功法夺取流程。
- **GIVEN** BOSS 生成，**WHEN** spawning 动画播放，**THEN** BOSS 无敌 1.0s，周围留白圈建立。
- **GIVEN** 杂兵在 BOSS 留白圈内，**WHEN** 距离检测触发，**THEN** 杂兵被推开至圈外。

## Open Questions

- [ ] BOSS 攻击模式的循环顺序是否需要随机化还是完全固定？
- [ ] BOSS 死亡后是否需要"功法夺取"的专属动画（art-bible Section 2 已定义）？
- [ ] 守护者 BOSS 的"墨潮涌动"召唤杂兵是否有上限？
