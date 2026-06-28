# Player Controller

> **Status**: In Design
> **Author**: user + game-designer + gameplay-programmer + ux-designer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 3 (自创流派 — 走位是玩家唯一主动表达) + Pillar 1 (近在咫尺 — 位置决定可达性)
> **Priority**: MVP | **Layer**: Core
> **Source Systems Index**: design/gdd/systems-index.md (Order #2)

## Overview

Player Controller 把 Input System 提供的归一化方向向量转换为角色在 2D 世界中的实际位移,管理角色的运动状态机(idle / running / hitstun / immobile),并通过信号广播自身位置和速度供下游消费者(Camera、Enemy AI、Boss AI 寻路目标、Technique 释放原点、HUD HP 环)使用。

它是玩家"风暴之眼"幻想的执行层——art-bible 约定主角是克制的墨色剪影,但 Player Controller 决定这墨色如何移动:加速度感、急停响应、击退恢复、境界突破时基础速度的跃迁。在轻度操作设计下,走位是玩家唯一持续的主动表达,所以这个系统的"手感"直接决定 30-40 分钟一局心流是否可持续。慢一点钝一点,玩家会感到挫败;急一点滑一点,玩家又会失去精确闪避的能力。

这个系统不做任何攻击逻辑——攻击属于 Technique System。Player Controller 只负责"我在哪、我朝哪走、我现在是什么状态",其他系统问它要这些信息。

## Player Fantasy

**Direct — 玩家的指尖与角色之间应该没有翻译。**

art-bible 把主角定为"风暴之眼"——主角越强越静,招式越强越狂。Player Controller 是把这个意象做实的执行层:**当玩家的手指拨动方向,墨痕同帧响应;松开,墨痕同帧停下;碰到敌人冲撞,墨痕震一下、退一步、回中——一切发生在玩家有意识思考前。**

这个系统的成功条件是玩家在 R5 大乘期面对 150 个敌人弹幕时,**他们的失败永远归咎于自己的判断,而不是控制器的反应**。他们说"我应该再早 0.2 秒往左走",而不是"角色卡了一下"。

走位是 survivor 玩家唯一持续在做的事情。如果走位钝、滑、慢、迟疑——玩家会在第一个 10 分钟就放弃游戏。如果走位锋利、果断、可预测——玩家会在第 50 局还说"这游戏手感真好"。这是本作能否长期留存玩家的**地基**,没有之一。

参考标杆: 《Hyper Light Drifter》的瞬时响应、《吸血鬼幸存者》的归一化匀速移动、《死亡细胞》的可预测加减速曲线。我们不做"惯性丰富"的现实物理,做"思维即位置"的工具感。

> **Note**: `creative-director` not consulted — Lean mode; art-bible Section 1.1 (主角是墨, 招式是泼彩) already establishes the player fantasy framework. This GDD inherits that direction without re-litigation.

## Detailed Design

### Core Rules

1. **方向输入即移动**: 每帧从 Input System 读取 `get_movement_vector() -> Vector2`(已归一化、已过死区),乘以当前境界基础速度 + 状态修饰,得到 velocity。无加速度延迟、无惯性滑行。
2. **轻度加减速**: 静止→运动用 60ms 短缓动达到全速(防止视觉抽搐);运动→静止 30ms 缓动归零(防滑步)。这是"思维即位置"和"画面不抽搐"的最小妥协。
3. **境界基础速度**: 6 个境界,基础速度按公式逐境提升(详见 Section D Formula 1)。speed 增益是 art-bible "越战越强"在 PC 层的体现。
4. **无主动闪避/无冲刺**: 走位是唯一移动方式。设计上拒绝额外的位移能力(art-bible Pillar "轻度操作"硬约束)。
5. **击退由外部驱动**: Player Controller 不主动产生位移以外的运动。击退、击飞、震屏由 Damage/Health System 调用 `apply_knockback(direction, force, duration)` API 触发,期间进入 hitstun 状态。
6. **位置只能由 PC 自己写**: 其他系统读 `global_position` 但**不允许直接设置**。需要传送/复位的场景(境界突破中心化、过场)通过 `teleport_to(pos)` API,会同步重置 velocity 和状态。
7. **碰撞与穿透**: PC 使用 `CharacterBody2D` + `move_and_slide()`。墙体/边界使用 collision_layer 1(world),敌人使用 collision_layer 2(player 与敌人**不碰撞**——敌人是 trigger,接触由 Damage 系统监听)。
8. **强制留白圈是数据,不是物理**: art-bible 提到的 0.5x-2.0x 半径强制留白圈,由 PC 暴露 `clearance_radius` 数据属性,但**不强制清空粒子**——粒子剔除逻辑由 VFX System 订阅 PC 信号实现。PC 自己只声明半径数值。
9. **delta-time 弹性**: 使用 `_physics_process(delta)` 处理移动,Web 平台掉帧时 delta 自动扩大,玩家位移以"每秒像素数"为单位而非"每帧像素数",保证不同帧率下移动距离一致。

### States and Transitions

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **idle** | velocity=0,飞白回到境界基准数 | 输入零向量持续 ≥50ms(Input Formula 8) | 任何非零方向输入 |
| **running** | velocity = direction × current_speed(含加减速曲线) | 收到非零方向输入 | 输入归零或被 hitstun 中断 |
| **hitstun** | velocity 由击退覆盖,玩家输入暂时无效,持续 knockback_duration | 收到 `apply_knockback()` 调用 | 击退时长结束 |
| **immobile** | velocity=0,所有玩家输入被忽略 | 进入境界突破仪式 / 死亡 / 过场 / 暂停 | 状态触发者主动调用 `set_immobile(false)` |

**状态优先级**(同时满足多个进入条件时):immobile > hitstun > running > idle

### Interactions with Other Systems

**上游:**

| 上游 | 接口 | 频率 |
|------|------|------|
| **Input System** | `Input.get_movement_vector() -> Vector2` | 每 `_physics_process` 一次 |
| **Damage/Health System** | `apply_knockback(direction: Vector2, force: float, duration: float)` API | 事件驱动 |
| **Run/Session Management** | `set_immobile(bool)` API | 状态切换时 |

**下游(消费 PC 数据):**

| 下游 | 接口 | 类型 |
|------|------|------|
| **Camera System** | 读取 `global_position`,订阅 `position_changed` 信号 | 信号 + 直接读 |
| **Enemy AI** | 读取 `global_position` 作为寻路目标 | 直接读(每 AI tick) |
| **Boss AI** | 同上 + 订阅 `state_changed(new_state)` 用于读招判定 | 信号 + 直接读 |
| **Technique System** | 读取 `global_position` 作为功法释放原点;读取 `current_direction` 用于方向性功法 | 直接读 |
| **HUD HP Ring** | 订阅 `global_position` 变化以渲染玩家锚定圆环 | 信号 |
| **VFX System** | 订阅 `velocity_changed` 用于飞白密度调整;读 `clearance_radius` 用于粒子剔除 | 信号 |

**Godot 信号契约:**
- `position_changed(new_pos: Vector2)` — 每物理帧 PC 位置变化时
- `velocity_changed(new_vel: Vector2)` — velocity 变化超过阈值时(避免过频)
- `state_changed(new_state: String)` — idle/running/hitstun/immobile 切换时
- `realm_transitioned(new_realm: int)` — 境界突破完成后 PC 基础属性切换时

> **Note**: Specialist agents not consulted at Section C — Lean mode. Art-bible and Input GDD have already constrained the design space tightly.

## Formulas

> **Design philosophy** (systems-designer recommendation, accepted): Speed跨度小(88→124 px/s)+ 留白跨度大(0.5x→2.0x)+ 机制层承担主要"越战越强"。Survivor-like 走位安全区不能因玩家速度增长而崩溃,但每个境界仍要有可感知的爽感——所以让"留白半径"和"突破清场"承担更多力量感投射。

---

### Formula 1: 境界基础速度曲线(对数饱和)

```
base_speed(R) = S_min + (S_max - S_min) × log(1 + k × (R - 1)) / log(1 + k × 5)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| R | R | int | 1–6 | 当前境界(炼气=1, 飞升=6) |
| S_min | — | float | 88 px/s | 炼气基础速度(Survivor-like 锚点) |
| S_max | — | float | 124 px/s | 飞升基础速度(软上限) |
| k | k | float | 1.8 | 曲线弯曲系数 |
| base_speed | v_base | float | 88–124 px/s | 当前境界的基础移动速度 |

**Output Range**: [88, 124] px/s。绝对不超过 130 px/s(否则 R5 同屏 150+ 实体可读性崩塌)。

**Worked Example:**

| R | 境界 | base_speed | Δ |
|---|------|------------|---|
| 1 | 炼气 | 88.0 | — |
| 2 | 筑基 | 100.4 | +14% |
| 3 | 金丹 | 109.2 | +9% |
| 4 | 元婴 | 115.9 | +6% |
| 5 | 大乘 | 120.5 | +4% |
| 6 | 飞升 | 124.0 | +3% |

**Rationale**: 早期突破 +14% 超过韦伯-费希纳感知下限(玩家"感觉得到"),后期收敛保护 Survivor-like 平衡。质感跳跃(墨态)+ 速度平滑 = 稳定肌肉记忆。

---

### Formula 2: 加减速缓动曲线

```
启动: v(t) = v_target × (1 - (1 - t/T_start)³),  t ∈ [0, 60ms]  (ease-out cubic)
停止: v(t) = v_initial × (1 - (t/T_stop)²),       t ∈ [0, 30ms]  (ease-in quad)
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| t | float | 0 – T_start/T_stop ms | 缓动经过时间 |
| T_start | float | 60 ms (锁定) | 静→动达到全速时间 |
| T_stop | float | 30 ms (锁定) | 动→静归零时间 |
| v_target | float | 88–124 px/s | 当前 base_speed |
| v_initial | float | 0–124 px/s | 停止开始时的速度 |

**Output Range**: 0 – base_speed。

**Worked Example (R1, 启动)**: t=20ms → v=61.6 px/s (70%);t=40ms → v=84.9 px/s (96.5%);t=60ms → v=88 px/s。

**Consistency with Input GDD F6**: 按下方向键第 2 帧 (33ms) 玩家位移达全速的 84%,符合 ≤33ms 输入→移动契约。

**Rationale**:
- 启动 ease-out:前帧大位移 = 灵敏感(HLD 标杆)
- 停止 ease-in:前段温和、后段果断归零 = 不冲过目标
- 全境界统一,缓动不随境界变化(护肌肉记忆)

---

### Formula 3: 击退公式(瞬时初速度 + 二次衰减)

```
knockback_velocity(t) = force × (1 - t/D)²,  t ∈ [0, D]
effective_velocity(t) = knockback_velocity(t) × dir_knockback
                      + player_input_speed × (1 - knockback_velocity(t) / force) × dir_input
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| force | float | 80–400 px/s | 初始击退速度(Damage 决定) |
| D | float | 100–300 ms | 击退持续时间 |
| t | float | 0 – D | 已经过时间 |
| dir_knockback | Vector2 | 单位向量 | 击退方向 |
| dir_input | Vector2 | 单位向量/0 | 玩家当前输入 |

**Output Range**: knockback_v 在 t=D 时归零;effective_v 在 t=0 时最高 ≈ force + S_max ≈ 524 px/s(短瞬间)。

**Damage System 击退档位(参考)**:

| 档位 | force | D | 总位移 | 用途 |
|------|-------|-----|--------|------|
| 微 | 80 | 100 | 2.7 px | 小怪平 A |
| 轻 | 150 | 150 | 7.5 | 普通弹幕 |
| 中 | 240 | 200 | 16 | 精英怪 |
| 重 | 360 | 250 | 30 | BOSS 重击 |
| 极 | 400 | 300 | 40 | BOSS 终结 |

**Rationale**:
- 瞬时初速度 = 高冲击感(被打飞 ≠ 被推走)
- Quad 衰减平衡爆发感与恢复速度
- **击退期间玩家输入权随击退衰减恢复**(修仙"被打也能挣扎"的体感投射,区别于 Vampire Survivors 完全锁玩家)
- D 上限 300ms,超过会感觉"被定身"

**击退结束后**: velocity 通过 Formula 2 启动缓动重新加速,而非瞬时回到 base_speed。

---

### Formula 4: 强制留白半径(分段表 + 突破脉冲)

```
clearance_radius(R) = char_diameter × multiplier(R)

multiplier 表:
R=1 炼气: 0.5x   R=4 元婴: 1.3x
R=2 筑基: 0.7x   R=5 大乘: 1.65x
R=3 金丹: 1.0x   R=6 飞升: 2.0x

突破脉冲: visual_radius(t) = current × (1 + 0.5 × sin(π × t / 600ms))
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| R | int | 1–6 | 当前境界 |
| char_diameter | float | 32 px (assumed) | 玩家角色精灵直径 |
| clearance_radius | float | 16–64 px | 实际留白半径(碰撞应用) |
| T_pulse | float | 600 ms (锁定) | 突破视觉脉冲时长 |
| visual_radius | float | 16–96 px | 视觉峰值半径(t=300ms 时 1.5× clearance) |

**Output Range**: clearance 离散 16–64 px;visual peak 96 px。

**突破清场(决定的设计)**: 600ms 视觉脉冲期间,clearance_radius 作为真实碰撞应用,**清除范围内所有非 BOSS 单位**。这是修仙"破境一刻"的核心爽点。BOSS 不受影响。

**与 Formula 1 的反向耦合**: speed 早期陡峭、后期饱和;clearance 早期克制、后期大幅扩张。两条曲线**故意错位**,让每境界都有不同的"变强主题":
- 早期(R1-R3): 速度跳跃感最强,留白小,需谨慎走位
- 后期(R4-R6): 速度饱和,留白大幅扩张,踩到哪都清场

---

### Formula 5: 斜向移动位移幅值守卫

```
desired_displacement = input_vector × current_speed × delta_time
expected_magnitude = current_speed × delta_time

if |desired_displacement.length() - expected_magnitude| > ε:
    desired_displacement = desired_displacement.normalized() × expected_magnitude
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| input_vector | Vector2 | length ≤ 1.0 | Input GDD F1 输出(已归一化) |
| current_speed | float | 0 – S_max | F1+F2+F3 计算后的当前速度 |
| delta_time | float | ~16.67 ms | 物理帧间隔 |
| ε | float | 0.5 px | 浮点容差 |

**Rationale**: Input GDD 已归一化,理论上 PC 不需要重做。但 Survivor-like 玩家**对斜向速度差异极度敏感**(肌肉记忆根基)。守卫式校验在 ε 范围内零开销,**只在击退/缓动叠加导致幅值偏离时触发修正**。

**击退期间豁免**: 若 `is_in_knockback == true`,跳过守卫(允许 effective_velocity 短瞬间超过 base_speed)。

---

### Formula 6: 边界墙滑动

```
collision_normal = normal_at_collision_point
slide_velocity = velocity - (velocity · collision_normal) × collision_normal
```

**Variables:**

| Variable | Type | Description |
|----------|------|-------------|
| velocity | Vector2 | 期望速度 |
| collision_normal | Vector2 | 碰撞面法线(单位向量) |
| slide_velocity | Vector2 | 沿墙滑动的实际速度 |

**Rationale**: BOSS 战房间边界或地图墙体存在时,玩家撞墙不应"卡死",而应保留切向速度。Godot `move_and_slide()` 内置此行为,公式在此显式声明契约。

---

### Formula 7: 移动状态查询接口(对外契约)

PC 暴露的查询属性,供 VFX/Audio/Animation/墨态系统消费:

| 属性 | 类型 | 公式 | 用途 |
|------|------|------|------|
| `is_moving` | bool | `current_speed > MOVING_THRESHOLD` (MOVING_THRESHOLD = 5 px/s) | 动画/音频切换 |
| `movement_intensity` | float | `current_speed / S_max` ∈ [0, 1] | 墨态浓度/飞白密度 |
| `is_in_knockback` | bool | knockback duration 未结束 | 跳过 F5 守卫,VFX 震屏 |
| `knockback_remaining_t` | float | `D - t` ms | UI 击退指示器(MVP 暂不需要) |
| `current_realm` | int | 1–6 | 决定 base_speed 和 clearance_radius |
| `clearance_radius` | float | F4 计算结果 | 供 Spawn / VFX 系统消费 |

---

### Formula 8: 战斗中速度乘数(预留接口,R0 不实现)

```
final_speed = base_speed(R) × ∏ modifier_i,  其中 modifier_i ∈ [0.2, 2.0]
final_speed_clamped = clamp(final_speed, 0.2 × base_speed, 2.0 × base_speed)
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| modifier_i | float | 0.2 – 2.0 | 来自被动/装备/BOSS 招式的速度系数 |
| final_speed | float | 17.6 – 248 px/s | 修正后速度 |

**MVP 不实现**: 接口预留,默认所有 modifier = 1.0。Vertical Slice 阶段如需要"减速 buff"/"加速 buff"可激活此公式。

**Clamp 必要性**: [0.2x, 2.0x] 是 Survivor-like 不可妥协的护栏——减速过低玩家等死,加速过高屏幕拥挤度失控。

---

### 公式耦合关系

```
Input GDD (F1 归一化 + F6 ≤33ms)
        ↓
Formula 5 (位移幅值守卫)
        ↓
Formula 1 (境界基础速度) ←─── Formula 8 (速度乘数,预留)
        ↓
Formula 2 (加减速缓动) ──→ current_speed
        ↓
Formula 3 (击退覆盖) ←── Damage System.apply_knockback()
        ↓
Formula 6 (墙滑动)
        ↓
Formula 7 (状态接口) → VFX / Audio / Animation / 墨态系统

独立链:
Formula 4 (留白半径) → Spawn System + VFX + 突破清场
```

## Edge Cases

- **If 玩家在击退期间被再次击中**: 新击退覆盖旧击退(用新的 force/duration 替换),玩家不会"叠加"被击退距离。Damage System 决定是否抑制连击(本 GDD 不管)。
- **If 玩家在境界突破仪式中被攻击**: immobile 状态优先级最高,knockback 被忽略。突破结束后回到正常状态,即使理论上"应该"被击退也不补偿。
- **If 玩家速度因 F8 修饰器降到 < MOVING_THRESHOLD (5 px/s)**: `is_moving` 返回 false,触发 idle 状态。下游(墨态/飞白)按 idle 渲染。这是"减速 buff 过强 = 视觉等同静止"的设计内行为。
- **If 玩家被持续推到地图边界,velocity 为零但 input 不为零**: state 保持 running(玩家有意图移动,虽然撞墙)。VFX/Audio 可基于 input 而非 actual velocity 继续渲染走位反馈。
- **If 玩家死亡瞬间**: 立即设置 immobile=true,velocity=Vector2.ZERO,忽略所有后续 knockback/input。死亡场景由 Run/Session Management 控制视觉。
- **If 玩家在境界突破清场脉冲期间撞到 BOSS**: BOSS 不受清场影响(F4 明确),玩家依然可被 BOSS 攻击。突破不是无敌时刻,只是清场时刻。
- **If 玩家在过场动画(如夺取功法 1.5-2s 时间冻结)期间被攻击**: immobile=true,所有伤害和击退被截断。游戏帧暂停,即使物理 tick 仍在跑,velocity 强制为零。
- **If Web 平台帧率突然跌到 < 30fps(delta_time > 33ms)**: 守卫(F5)防止单帧位移过大造成"瞬移";如果连续 5 帧 delta > 50ms,触发降级通知(可选 UI 提示)。
- **If 玩家在炼气期(R1)第一帧 input 不为零**: 不进入 idle,直接进入 running 状态启动缓动。游戏开始即可移动,无"启动锁"。
- **If 两个 knockback 在同一帧同时到达(罕见但可能)**: 取 force 更大者,丢弃较小者。不做向量平均(会产生奇怪的对角击退方向)。
- **If 玩家在边界滑动时速度因投影后变为 0(法向直接对准 velocity)**: state 保持 running 但 actual velocity = 0。玩家手指松开后正常进入 idle。
- **If clearance_radius 由 F4 突破脉冲扩展到 96 px,但恰好玩家在 BOSS 战房间(房间 < 200 px 直径)**: 清场范围被房间边界裁剪,只清除房间内非 BOSS 单位。视觉脉冲仍渲染完整 96 px(可能溢出房间边界,允许)。

## Dependencies

### Upstream

| 上游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **Input System** | Hard | `Input.get_movement_vector() -> Vector2` (每物理帧),`is_action_pressed("pause")` | 已设计 (`design/gdd/input-system.md`) |
| **Damage/Health System** | Hard | `apply_knockback(direction, force, duration)` API | 未设计,接口提议见 Section C |
| **Run/Session Management** | Hard | `set_immobile(bool)`,死亡/暂停/过场状态切换 | 未设计,接口提议见 Section C |
| **Realm Progression** | Hard | 订阅其 `realm_changed(new_realm)` 信号,触发 base_speed + clearance_radius 切换 | 未设计 |
| **Godot 4.6 CharacterBody2D** | Hard | `move_and_slide()` API | 引擎核心 |

### Downstream

| 下游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **Camera System** | Hard | 读 `global_position` + 订阅 `position_changed` | 未设计 (Order #3) |
| **Enemy AI** | Hard | 读 `global_position` 作寻路目标 | 未设计 (Order #6) |
| **Boss AI** | Hard | 读 `global_position` + 订阅 `state_changed` | 未设计 (Order #11) |
| **Technique System** | Hard | 读 `global_position` + `current_direction` 作释放原点 | 未设计 (Order #10) |
| **HUD HP Ring** | Hard | 订阅 `position_changed` 渲染玩家锚定圆环 | 未设计 (Order #13) |
| **VFX System** | Soft | 订阅 `velocity_changed`(飞白密度),读 `clearance_radius`(粒子剔除),读 `movement_intensity`(墨态浓度) | 未设计 (Order #14 VS-tier) |
| **Spawn System** | Soft | 读 `clearance_radius` 在生成实体时避开 | 包含在 Enemy Spawner GDD 内 |

### External

- Godot 4.6 `_physics_process(delta)` tick(默认 60Hz)
- Godot 4.6 `CharacterBody2D` + `move_and_slide()`
- Godot 4.6 `collision_layer` / `collision_mask`(layer 1=world, layer 2=enemies-as-triggers)

### Forbidden

- 其他系统**禁止**直接设置 PC 的 `global_position`(必须走 `teleport_to()` API)
- 其他系统**禁止**直接修改 `velocity`(必须走 `apply_knockback()` API)
- PC **禁止**包含任何攻击/伤害/招式逻辑(那是 Technique System 的领地)

---

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 | 异常行为 |
|------|--------|----------|------|----------|
| `S_MIN` (R1 base_speed) | 88 px/s | [80, 95] | 早期走位手感 | 过低=拖沓;过高=R1 平衡崩 |
| `S_MAX` (R6 base_speed) | 124 px/s | [115, 130] | 末游走位手感 | 过高=威胁圈识别失败,R5/R6 难度梯度崩 |
| `SPEED_CURVE_K` | 1.8 | [1.2, 2.5] | 境界递增曲率 | 过低=接近线性;过高=早期突破过爽,后期太平 |
| `T_START_MS` | 60 | [40, 100] | 启动缓动时长 | 过低=视觉抽搐;过高="延迟"感 |
| `T_STOP_MS` | 30 | [20, 60] | 停止缓动时长 | 过低=视觉硬切;过高=滑步感 |
| `MOVING_THRESHOLD` | 5 px/s | [2, 10] | idle 判定阈值 | 过低=方向切换间隙误判 idle;过高=慢推时被视为静止 |
| `KNOCKBACK_FORCE_*` (5档) | 80/150/240/360/400 | ±20% | 击退强度档 | 单档调过高=玩家被推飞屏幕外;过低=没击退感 |
| `KNOCKBACK_DURATION_MS_*` | 100/150/200/250/300 | [80, 350] | 击退持续时长 | 过低=击退感不明显;过高=玩家觉得"被定身" |
| `CLEARANCE_MULTIPLIER` (R1-R6) | 0.5 / 0.7 / 1.0 / 1.3 / 1.65 / 2.0 | 离散值,可调整曲率 | 留白半径与境界耦合 | R1 过高=早期就清场无难度;R6 过低=飞升期没爽感 |
| `BREAKTHROUGH_PULSE_MS` | 600 | [400, 1000] | 突破清场脉冲时长 | 过低=爽感不足;过高=战斗节奏被打断 |
| `BREAKTHROUGH_PULSE_PEAK_MULT` | 1.5 | [1.2, 2.0] | 视觉脉冲峰值倍率 | 与 art-bible Section 7.5 仪式时长协调 |
| `CHAR_DIAMETER` | 32 px | 锁定(美术资产决定) | 角色精灵尺寸 | 影响所有 clearance 计算 |
| `EPSILON_GUARD` | 0.5 px | 锁定 | F5 浮点容差 | 调整应基于浮点性能测试 |

**Knob 交互**:
- `S_MIN`/`S_MAX` 决定速度跨度,`SPEED_CURVE_K` 决定速度感知节奏
- `CLEARANCE_MULTIPLIER` 与 base_speed 反向耦合——故意错位,见 F4 Rationale
- `T_START_MS`/`T_STOP_MS` 全境界统一,**不可per-境界调整**(肌肉记忆护栏)

**调优优先级**:
1. **Tier 1** (核心手感): S_MIN, S_MAX, T_START_MS, T_STOP_MS — 极少调整,锁定后不改
2. **Tier 2** (节奏): SPEED_CURVE_K, KNOCKBACK 各档, CLEARANCE_MULTIPLIER — playtest 后微调
3. **Tier 3** (技术参数): MOVING_THRESHOLD, EPSILON_GUARD — 不需要 designer 介入

## Visual/Audio Requirements

### Visual (由 VFX/Animation 系统消费 PC 状态信号)

**Player silhouette**(art-bible Section 5.1 已锁定):
- 头身比 1:5.5,前倾 8°,后袖比前袖大 1.3x
- 不对称纵向墨团,永远偏离正圆
- 墨色填充 `Mò #1A1D22`,无元素色染色

**飞白(运动证据)** — 由 PC 暴露 `movement_intensity` 驱动:
- R1 静止:1 道飞白(后袖)
- R{n} 静止:n 道飞白(art-bible R1=1, R2=2, R3=3-4, R4=5+, R5 融合, R6 全留白)
- 移动中:飞白数量 ×2,持续到运动结束 + 0.2s tail-out
- **渲染层**: shader-driven texture mask on silhouette,**不是粒子**(150+ 实体场景下粒子预算给不起)

**留白圈** — 由 VFX 系统订阅 `clearance_radius`:
- R1=16px → R6=64px(F4 离散表)
- 视觉表现:目标周围 1.5x radius 强制留白(粒子降透明度或剔除)
- **碰撞应用仅在突破脉冲 600ms 期间**(F4 决定)

**境界突破特效**:
- 突破触发时,visual_radius 按 F4 公式扩散(峰值 1.5× clearance)
- art-bible Section 7.5 规范 1200ms 完整仪式(光速→暖光→新境界色名→回归)
- PC 在仪式期间 immobile,velocity=0

**击退反馈**:
- art-bible Section 5.2 BOSS Tell 节奏中,击退是 Strike 阶段的玩家端响应
- 击退方向 + force 通过 VFX 震屏 + 主角短暂泼彩染色(art-bible Section 4.5 元素色)表现

### Audio (由 Audio Manager 消费 PC 状态信号)

- `state_changed → idle`:静止环境音 fade in
- `state_changed → running`:布料摩擦/地面踏音 loop start
- `state_changed → hitstun`:击中声(由 Damage System 决定具体音效)
- `state_changed → immobile`:中断当前 SFX(死亡/暂停场景)
- `realm_transitioned`:境界突破仪式音(由 Audio Manager 设计)

> **📌 Asset Spec** — Visual/Audio requirements 已定义。在 art bible approved 后,运行 `/asset-spec system:player-controller` 产出 per-asset 视觉描述、尺寸和生成 prompt。

## UI Requirements

**Player Controller 不直接拥有 UI 元素**——所有 UI 由下游 HUD 系统消费 PC 数据:

- **玩家锚定 HP 环**(art-bible Section 7.1):HUD 订阅 `position_changed` 实时跟随玩家
- **方向指示器**(若境界突破时需要):由突破系统在玩家身上叠加,PC 提供 `current_direction` 数据
- **击退指示**(可选 VS):AC-PC-21 视觉评审,可能需要短暂震屏 + 边缘红光(由 VFX 处理)

> **📌 UX Flag — Player Controller**: 没有独立 UI 屏幕。但下游 HUD 系统(Order #13)消费 PC 数据渲染玩家锚定圆环,需在 Pre-Production 阶段运行 `/ux-design` 设计 HUD 时考虑 PC 信号的频率和带宽。

## Acceptance Criteria

### H.1 Movement Core (Core Rules 1, 2, 7, 9)

**AC-PC-01 [MVP] Input-to-velocity determinism**
- **GIVEN** PC is in `idle` at R1 (base_speed=88 px/s)
- **WHEN** player holds "right" for exactly 1.0s
- **THEN** displacement = 88 × (1.0 − 0.060/2) ± 0.5px; velocity = (88, 0) ± 0.1 after startup ease completes

**AC-PC-02 [MVP] Startup ease curve (F2)**
- **GIVEN** PC is `idle`, no input held
- **WHEN** player taps direction and holds it
- **THEN** speed reaches 50% at t≈30ms, 90% at t≈48ms, 100% at t=60ms (cubic ease-out tolerance ±5%)

**AC-PC-03 [MVP] Stop ease curve (F2)**
- **GIVEN** PC is `running` at full base_speed
- **WHEN** player releases all directional input
- **THEN** velocity reaches 0 within 30ms (ease-in quad); no overshoot, no residual drift beyond ε=0.5px

**AC-PC-04 [MVP] No inertia, no dash**
- **GIVEN** PC is `running`
- **WHEN** player reverses input (e.g., right → left)
- **THEN** velocity flips after stop+start ease (≤90ms total); no slide-through; no dash skill triggerable from any input

### H.2 境界 Progression (Core Rule 3, F1)

**AC-PC-05 [VS] Base speed table per境界 (F1)**
- **GIVEN** PC at R{n}, n ∈ [1..6]
- **WHEN** measuring base_speed via 1s horizontal run on open ground
- **THEN** speed matches table within ±1 px/s: R1=88, R2=100, R3=109, R4=116, R5=121, R6=124

### H.3 Knockback & Hitstun (Core Rule 5, F3)

**AC-PC-06 [MVP] Knockback API contract**
- **GIVEN** PC is `running` or `idle`
- **WHEN** Damage System calls `apply_knockback(direction=(1,0), force=240, duration=0.25)`
- **THEN** PC enters `hitstun`, peak velocity ≈240 px/s along direction at t=0, decays via quad to 0 at t=duration; player input authority recovers proportionally

**AC-PC-07 [MVP] Knockback override (Edge Case)**
- **GIVEN** PC is in `hitstun` from knockback A (force=150) at t=0.1s
- **WHEN** new `apply_knockback` arrives with force=360
- **THEN** A fully replaced by B; no force-stacking

**AC-PC-08 [VS] Same-frame knockback resolution**
- **GIVEN** PC receives two `apply_knockback` in same `_physics_process`
- **WHEN** call A force=240, call B force=400
- **THEN** only B takes effect (max force wins); A discarded; logged for QA

### H.4 Movement State Machine

**AC-PC-09 [MVP] State priority enforcement**
- **GIVEN** PC is in `hitstun`
- **WHEN** breakthrough cutscene triggers `set_immobile(true)`
- **THEN** state → `immobile` immediately; further knockbacks during immobile are **ignored** and logged

**AC-PC-10 [MVP] Death state lock**
- **GIVEN** PC HP reaches 0
- **WHEN** death signal fires
- **THEN** state = `immobile`, velocity = (0,0) within 1 frame; only `teleport_to()` permitted

### H.5 Collision & Physics (Core Rules 6, 7, F6)

**AC-PC-11 [MVP] Position write-authority**
- **GIVEN** external system attempts to write `PC.position` directly
- **WHEN** the write occurs
- **THEN** change is reverted next frame OR caught by debug assertion; only `teleport_to()` API persists. (Implementation strategy: lead-programmer decides setter-trap vs. CI grep test.)

**AC-PC-12 [MVP] Enemy trigger non-collision**
- **GIVEN** PC is `running` toward an enemy unit
- **WHEN** PC hitbox overlaps enemy hitbox
- **THEN** PC passes through (enemy is trigger), no `move_and_slide` collision response

**AC-PC-13 [VS] Wall slide on boundary (F6)**
- **GIVEN** PC `running` diagonally into a vertical wall
- **WHEN** collision occurs
- **THEN** velocity component along wall normal is zeroed; tangential preserved; PC slides without sticking or jittering >0.5px

### H.6 Clearance Radius & Breakthrough VFX (Core Rule 8, F4)

**AC-PC-14 [MVP] Clearance radius data exposure**
- **GIVEN** PC at R{n}
- **WHEN** VFX subsystem queries `get_clearance_radius()`
- **THEN** returns: R1=16, R2=22.4, R3=32, R4=41.6, R5=52.8, R6=64 px (32 × multiplier from F4)

**AC-PC-15 [VS] Breakthrough clearance pulse (F4)**
- **GIVEN** PC triggers境界 breakthrough (e.g., R3→R4)
- **WHEN** breakthrough event fires
- **THEN** within 600ms, real cleanup AoE pulses at PC origin, removing all non-BOSS enemies inside new clearance_radius; BOSS units survive; pulse VFX visible

### H.7 Numerical Safety Guards (F5)

**AC-PC-16 [MVP] Diagonal displacement guard (F5)**
- **GIVEN** PC at R1 running diagonally (input=(1,1) normalized)
- **WHEN** measuring per-frame |Δposition| at 60fps and at simulated 15fps
- **THEN** |Δposition| ≤ expected_speed × delta + ε(0.5px); no teleport spike; guard exempt during active knockback

### H.8 Status Query Interface (F7)

**AC-PC-17 [VS] Query API correctness**
- **GIVEN** PC in known state combinations (idle / running / hitstun / immobile)
- **WHEN** external systems call `is_moving()`, `movement_intensity()`, `is_in_knockback()`
- **THEN** returns match published truth table; `movement_intensity` ∈ [0.0, 1.0] proportional to current_speed/base_speed

### H.9 Combat Speed Multiplier (F8)

**AC-PC-18 [VS] Speed multiplier clamp (F8)**
- **GIVEN** combat system sets `combat_speed_multiplier` to extreme values (-1.0, 0.0, 0.1, 5.0)
- **WHEN** PC computes effective speed
- **THEN** multiplier clamped to [0.2, 2.0]; out-of-range inputs logged as warnings

### H.10 Performance & Cross-Browser

**AC-PC-19 [MVP] 60fps performance budget**
- **GIVEN** vertical slice build on baseline hardware (TBD by technical-artist)
- **WHEN** PC moves continuously for 60s with 8 enemies on screen
- **THEN** frame time ≤16.67ms p95, ≤20ms p99; PC `_physics_process` self-time ≤0.5ms/frame

**AC-PC-20 [MVP] Cross-browser parity**
- **GIVEN** identical input recording played in Chrome 120+, Firefox 120+, Safari 17+
- **WHEN** PC completes a 5-second fixed movement script
- **THEN** final position differs ≤2px across browsers; no browser exhibits stutter >1% of frames

**AC-PC-21 [VS] Knockback feel sign-off**
- **GIVEN** all 5 knockback force tiers (80/150/240/360/400) deliverable in test scene
- **WHEN** game-designer + creative-director playtest each tier
- **THEN** signed-off in `production/qa/evidence/pc-knockback-feel-[date].md` with video; subjective ≥4/5 on "weight/readability"

---

### Test Evidence Classification

| AC | Type | Evidence Path | Gate |
|----|------|---------------|------|
| AC-PC-01/02/03/04/05 | Logic | `tests/unit/player_controller/movement_test.gd` + ease/realm specific | BLOCKING |
| AC-PC-06/07/08 | Logic+Integration | `tests/unit/player_controller/knockback_*.gd` + mock Damage | BLOCKING |
| AC-PC-09/10 | Integration | `tests/integration/player_controller/state_*.gd` | BLOCKING |
| AC-PC-11/12/13 | Integration | `tests/integration/player_controller/collision_*.gd` | BLOCKING |
| AC-PC-14 | Logic | `tests/unit/player_controller/clearance_test.gd` | BLOCKING |
| AC-PC-15 | Visual+Integration | Integration test + screenshot + lead sign-off | BLOCKING(logic) + ADVISORY(visual) |
| AC-PC-16/17/18 | Logic | `tests/unit/player_controller/*.gd` | BLOCKING |
| AC-PC-19/20 | Performance | `production/qa/evidence/pc-perf-[date]/` + cross-browser report | BLOCKING |
| AC-PC-21 | Visual/Feel | Video + signed feel review doc | ADVISORY |

**Coverage**: 9 Core Rules × 8 Formulas × Edge Cases all mapped. MVP = 13 AC, VS = +8 AC.

## Open Questions

1. **char_diameter 锁定值**: F4 假设 32px,但实际角色精灵尺寸需 art-director 在 sprite spec 阶段确定。**Owner**: art-director。**Target**: `/asset-spec system:player-controller` 时锁定。

2. **击退 force 5 档的实际数值**: 80/150/240/360/400 px/s 是 systems-designer 提议值,需在原型/Vertical Slice 阶段 playtest 微调。**Owner**: game-designer + qa-tester。**Target**: VS 阶段 AC-PC-21 feel sign-off。

3. **Performance baseline 硬件**: AC-PC-19 假定"基准硬件",但未指定。需 technical-artist 在 spike 阶段定义 minspec(MacBook 集成显卡?中端 Android 手机?)。**Owner**: technical-artist。**Target**: 引擎集成 spike 完成后。

4. **R5 大乘期飞白融合的具体渲染**: art-bible Section 5.1 描述"飞白与本体融合,边缘溶入纸",但需 shader 实现细节。**Owner**: art-director + technical-artist。**Target**: VFX System GDD 设计时。

5. **Web 平台帧率 <30fps 时的降级 UI 提示**: Edge Case 提到连续 5 帧 delta > 50ms 触发降级通知,但 UI 形式未定。**Owner**: ux-designer。**Target**: Settings GDD 设计时。

6. **PC 与 Camera System 的位置同步**: 当前设计 Camera 订阅 `position_changed`,但每物理帧 emit 可能造成性能问题。是否需要节流?**Owner**: gameplay-programmer + technical-artist。**Target**: Camera System GDD 设计时(Order #3)。
