# Camera System

> **Status**: In Design
> **Author**: user + game-designer + ux-designer + gameplay-programmer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 1 (近在咫尺 — 相机决定下一目标可见性)
> **Priority**: MVP | **Layer**: Core
> **Source Systems Index**: design/gdd/systems-index.md (Order #3)

## Overview

Camera System 让玩家始终在屏幕中保持可读位置,并通过震屏/微缩放在击中、击退、境界突破等关键节点强化反馈。在 Survivor-like 视角下,Camera 不是叙事工具,而是**注意力管理工具**——它决定"玩家能看见多远的危险"、"BOSS 出现时画面如何让出空间"、"突破仪式时如何把世界推到次要位置"。

Camera 订阅 Player Controller 的 `position_changed` 信号(节流后),用平滑跟随的方式更新自身 transform,避免每帧严格锁定带来的"画面粘脸"。同时它暴露震屏 API,允许 Damage / Boss / Realm Progression 等系统在关键瞬间触发短促的视觉冲击。

这个系统不做剧情/分镜——本作没有过场对话,所有"分镜"都由 art-bible Section 2 的状态色温切换 + Camera 的微 zoom 联合完成。

## Player Fantasy

**Both — 玩家几乎不察觉 Camera 存在,但每一次"差点死掉"的瞬间它都在背后强化体感。**

art-bible Section 5.4 已锁定"玩家在 150+ 实体中 <100ms 可识别自己"——Camera 是这个契约的**默认守护者**:任何让玩家偏离屏幕中心超过 1/4 画面对角线的设计都会被否决。但同时 Camera 不能"硬绑"——粘脸式跟随会让走位失去"我看到自己往那边跑"的肌肉记忆。

参考标杆:**Vampire Survivors** 的几乎无平滑硬锁(玩家始终在画面正中)适合纯走位 Survivor,但失之于"无反馈";**Hades** 的微滞后 + 击中震屏 + BOSS 战微 zoom 给走位游戏带来电影感。我们选择**Hades 倾向**——日常硬锁不要,微滞后(60-80ms)保留运动感,关键节点触发额外效果。

Camera 的成功 = 玩家通关后**完全不记得相机存在过**,但他们会记得"那次击败 BOSS 时,画面震了一下又亮了一下,真爽"。它是反馈通道,不是表演通道。

> **Note**: `creative-director` not consulted — Lean mode; art-bible Section 5.4 (150-entity legibility) and Section 2 (mood by state) already lock the framing.

## Detailed Design

### Core Rules

1. **跟随 PC 的"软中心"**: Camera 的 target position = PC.global_position。Camera 自身位置以 follow_smoothing(F1)插值逼近 target,**永不直接 snap**(除非传送/复位)。
2. **死区(deadzone)**: PC 在 Camera 中心的 ±32px 矩形内移动时,Camera 不响应——避免玩家微小走位时画面整体抖动。超过死区后 Camera 才开始追随。
3. **位置更新节流**: 不订阅 PC 每物理帧的 `position_changed` 信号(60Hz),而是 Camera 自己在 `_process(delta)` 中读 PC.global_position(60Hz 渲染同步)。这解决 PC GDD Open Question #6 的节流问题——**信号在此场景下是"推"模型,容易过频;Camera 用"拉"模型更稳定**。
4. **震屏 API**: 暴露 `shake(magnitude: float, duration: float, frequency: float = 40)`——offset 在 [-magnitude, +magnitude] 范围内按 frequency Hz 随机抖动,duration 内线性衰减到 0。震屏不阻塞跟随。
5. **缩放(Zoom)状态切换**: Camera 维护一个 `zoom_target` 属性,在状态切换时(BOSS 进入、突破仪式、死亡)用 Tween 在 0.4s 内过渡到新值。zoom 范围 [0.8, 1.2],绝不大于 1.5(过缩 Web Compatibility 下 sub-pixel 失真严重)。
6. **传送/复位**: 暴露 `snap_to(pos: Vector2)` API,Camera 立即跳到 pos,清空震屏 offset,zoom 归 1.0。仅在境界突破开始 / 死亡复活 / 过场转场使用。
7. **强制可视范围**: Camera viewport 内必须始终包含 PC.global_position + clearance_radius(F4 from PC GDD)。如果跟随计算让 PC 即将出 viewport,跟随插值器被强制覆盖为硬跟随(防止 Web 浏览器极端掉帧时玩家"飞出"屏幕)。
8. **Pixel-perfect 对齐**: Camera 的实际渲染位置在每帧最终输出前被 `floor()` 到整数像素(Compatibility 渲染器要求),避免 sub-pixel jitter。但内部 target/插值用 float 计算,只在渲染最末一步取整。

### States and Transitions

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **following** | 平滑跟随 PC,zoom=1.0,无震屏 | 默认状态 / 退出其他状态后 | 任何其他状态触发 |
| **shaking** | 跟随 + offset 抖动叠加 | 收到 `shake()` 调用 | duration 结束 |
| **zoomed_boss** | 跟随 + zoom=1.1(轻微推近),Boss 进入时触发 | Boss Fight 状态信号 | Boss 战结束 |
| **zoomed_breakthrough** | snap 到 PC 中心 + zoom=0.9 拉远 + 渐次推回 1.0 | 境界突破仪式开始 | 突破仪式结束(art-bible 1200ms) |
| **frozen** | 完全停止响应(跟随和震屏都不更新),保持上一帧 transform | Death / 过场 / 暂停 / immobile | 状态触发者主动恢复 |

**状态优先级**(同帧多个进入条件):frozen > zoomed_breakthrough > zoomed_boss > shaking > following

**注意**: shaking 是**叠加状态**——它可以与 following / zoomed_boss / zoomed_breakthrough 并存。其他状态间互斥。

### Interactions with Other Systems

**上游(Camera 消费这些系统的数据/事件):**

| 上游 | 接口 | 类型 |
|------|------|------|
| **Player Controller** | 每 `_process` 读 `PC.global_position` | 拉模型 |
| **Damage/Health System** | 调用 `Camera.shake(magnitude, duration)` 触发命中震屏 | 事件驱动 |
| **Boss AI** | 订阅 `boss_engaged` / `boss_defeated` 信号,触发 zoomed_boss 状态切换 | 事件驱动 |
| **Realm Progression** | 调用 `Camera.start_breakthrough_zoom()` / `end_breakthrough_zoom()` | 事件驱动 |
| **Run/Session Management** | 调用 `Camera.freeze()` / `Camera.unfreeze()`(死亡/暂停/过场) | 事件驱动 |
| **Technique System (高品阶招式)** | 调用 `Camera.shake()` 强化释放反馈 | 事件驱动(MVP 可选) |

**下游(消费 Camera 数据):**

| 下游 | 接口 | 类型 |
|------|------|------|
| **HUD** | 假设 Camera viewport 框定屏幕,UI 元素以屏幕坐标定位,**不直接消费 Camera 数据** | (隐式契约) |
| **VFX System** | 屏幕空间特效(如 art-bible 中输入模式切换的"屏幕角落朱砂点闪烁")定位在 Camera viewport 边缘 | 直接读 `Camera.get_viewport_rect()` |
| **Spawn System** | 在玩家视野外生成敌人,需要查询 `Camera.get_visible_rect()` 来确定生成边界 | 直接读 |

**Godot 信号契约:**
- `camera_state_changed(new_state: String)` — 状态切换时
- `shake_started(magnitude: float, duration: float)` — 震屏开始时(供 Audio 同步震屏音)

### 击退/震屏与 Camera 的协调(重要)

**与 PC GDD F3 击退档位的映射(供 Damage System 参考)**:

| 击退档位 | 推荐震屏 magnitude (px) | 推荐 duration (ms) | 推荐 frequency (Hz) |
|---------|------------------------|--------------------|---------------------|
| 微 (80 px/s) | 2 | 100 | 50 |
| 轻 (150) | 4 | 130 | 45 |
| 中 (240) | 7 | 160 | 40 |
| 重 (360) | 12 | 200 | 35 |
| 极 (400) | 18 | 250 | 30 |

**Rationale**: magnitude 跟随击退力线性增加,duration 略短于击退本身(震屏先于击退结束,避免拖沓),frequency 随强度降低(强冲击=低频厚重感)。

> **Note**: Specialist agents (ux-designer, gameplay-programmer) not consulted at Section C — Lean mode. PC GDD and art-bible constraints已大量约束设计空间。

## Formulas

> **Critical**: All Camera formulas are **delta-aware** (use `1 - exp(-k * dt)` form, not `lerp(a, b, fixed_alpha)`). Web platform may drop to 30fps; naive lerp would halve effective follow speed at low framerates. Exponential decay produces frame-rate-independent behavior.

> **Godot 4.6 zoom semantics**: `Camera2D.zoom > 1.0` = 放大(看到更少世界),`< 1.0` = 缩小(看到更多世界)。所有公式以此为准。

---

### Formula 1: 跟随平滑(死区 + 指数 lerp)

```
delta_x = PC.x - Cam.x
delta_y = PC.y - Cam.y

target_offset_x = sign(delta_x) × max(0, |delta_x| - dead_zone)
target_offset_y = sign(delta_y) × max(0, |delta_y| - dead_zone)

target_x = Cam.x + target_offset_x
target_y = Cam.y + target_offset_y

alpha = 1 - exp(-follow_rate × dt)

Cam.x_next = Cam.x + (target_x - Cam.x) × alpha
Cam.y_next = Cam.y + (target_y - Cam.y) × alpha

render_x = floor(Cam.x_next)  # 仅最终绘制,不写回逻辑 Cam
render_y = floor(Cam.y_next)
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `dead_zone` | int | 32 (locked) | 死区半径(像素) |
| `follow_rate` | float | 8.0–14.0 (default 10.0) | 软跟随速率常数 |
| `dt` | float | 0.0083–0.0667 | 帧时间(60–15fps) |
| `alpha` | float | (0, 1) | 本帧 lerp 系数,从 dt 推导 |

**Output Range**: `Cam.x/y` 无界(跟随世界);`alpha ∈ (0, 1)` 自动 clamp。

**Worked Example** (`follow_rate=10`, PC 向右移动 100px,Cam 在原点):
- 60fps:`alpha ≈ 0.1535` → `Cam.x_next ≈ 10.44`
- 30fps:`alpha ≈ 0.2835` → `Cam.x_next ≈ 19.28`
- 4 帧 60fps vs 2 帧 30fps(同 1/15s):**两者均累计至 ~48.7%**,收敛一致

**Rationale**: 朴素 `lerp(a, b, 0.15)` 在 30fps 下会显著变慢。`1 - exp(-k*dt)` 是数值积分形式,帧率独立。`follow_rate=10` 半衰期 ≈ 69ms,贴合 PC 88-124 px/s 速度区间。死区在 *target 计算* 阶段过滤,而非 *后置* 过滤,避免抖动死锁。

---

### Formula 2: 震屏衰减(magnitude + Perlin noise)

```
t = current_time - shake_start_time
if t >= duration: shake_offset = (0, 0); end

progress = t / duration                  # ∈ [0, 1]
decay = (1 - progress)^3                 # ease-out cubic
mag_t = mag0 × decay

# Perlin 1D noise,每轴独立 seed
nx = perlin1d(seed_x + t × freq)         # ∈ [-1, 1]
ny = perlin1d(seed_y + t × freq)

shake_offset_x = nx × mag_t
shake_offset_y = ny × mag_t

# 最终渲染
final_x = floor(Cam.x_next + shake_offset_x)
final_y = floor(Cam.y_next + shake_offset_y)
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `mag0` | float | 2.0–18.0 px | 初始震屏幅度(击退档位决定) |
| `duration` | float | 0.08–0.40 s | 震屏持续时间 |
| `freq` | float | 22–28 Hz **(每次 shake 随机)** | 噪声采样频率 |
| `seed_x, seed_y` | float | 任意 | 每次 shake 不同(避免叠加共振) |
| `progress` | float | [0, 1] | 归一化进度 |
| `decay` | float | [0, 1] | ease-out cubic 衰减 |

**Output Range**: `shake_offset ∈ [-mag0, mag0]`,自然 clamp 到 18px。

**Worked Example** (mag0=10, duration=0.20s, freq=25Hz, t=0.05s):
- `progress=0.25`,`decay=0.75³=0.4219`,`mag_t=4.22`
- 设 `perlin1d(seed_x + 1.25)=0.6`,`perlin1d(seed_y + 1.25)=-0.4`
- `shake_offset = (2.53, -1.69)`

**击退档位 → 震屏参数映射**:

| 击退 (px/s) | mag0 (px) | duration (ms) | freq (Hz) |
|------------|----------|---------------|----------|
| 80 (微) | 2 | 100 | rand(22-28) |
| 150 (轻) | 4 | 130 | rand(22-28) |
| 240 (中) | 7 | 160 | rand(22-28) |
| 360 (重) | 12 | 200 | rand(22-28) |
| 400 (极) | 18 | 250 | rand(22-28) |

**Rationale**: ease-out cubic 让冲击集中在前 30%,尾部 30% 基本归零(避免拖沓)。Perlin > random:60Hz 下纯随机产生白噪声看起来像 bug;Perlin 25Hz 产生方向感(似手持相机)。**每次 shake 在 [22, 28] 随机 freq**,防止多 shake 叠加共振产生人工模式。每轴独立 seed 防止对角线视觉模式。

---

### Formula 3: Zoom 过渡(Tween 0.4s cubic in-out)

```
t = current_time - zoom_start_time
progress = clamp(t / zoom_duration, 0, 1)

# cubic in-out(对称的快-慢-快)
if progress < 0.5:
    eased = 4 × progress^3
else:
    eased = 1 - ((-2 × progress + 2)^3) / 2

zoom_current = zoom_from + (zoom_to - zoom_from) × eased
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `zoom_from` | float | [0.8, 1.2] | 起始 zoom |
| `zoom_to` | float | [0.8, 1.2] | 目标 zoom |
| `zoom_duration` | float | 0.4 (locked) | 过渡时长 |
| `eased` | float | [0, 1] | cubic in-out 曲线值 |

**Output Range**: `zoom_current ∈ [zoom_from, zoom_to]`。

**Worked Example** (zoom 1.0→1.2 战斗结束拉远,t=0.2s 中点):
- `progress=0.5`,`eased=0.5`,`zoom_current=1.10`
- t=0.1s(头部):`eased=0.0625`,zoom=1.0125(慢启动)
- t=0.3s(尾部):`eased=0.9375`,zoom=1.1875(慢停止)

**Interruption handling**(战斗中再次切换 zoom):
```
zoom_from := zoom_current      # 从当前值起算
zoom_start_time := current_time
zoom_to := new_target
```
**手写而非 Godot Tween 自带**: Tween 中断会回弹到原始 from 值;手写允许从 `zoom_current` 平滑过渡到新目标。

**Rationale**: cubic in-out(对称缓动)是"镜头语言"行为——起止都有"目的状态",对称缓动赋予两端重量感。Ease-out 在起步突兀,有"弹出感",不适合 zoom。

---

### Formula 4: Viewport 硬跟随覆盖(防 PC 出屏)

```
viewport_half_w = (1920 / 2) / zoom_current       # = 960 / zoom_current
viewport_half_h = (1080 / 2) / zoom_current

pc_screen_x = PC.x - Cam.x
pc_screen_y = PC.y - Cam.y

# 不对称 safety margin:Y 轴更宽(纵向视野更窄)
margin_x = 80   # 世界单位
margin_y = 120

overflow_x = max(0, |pc_screen_x| - (viewport_half_w - margin_x))
overflow_y = max(0, |pc_screen_y| - (viewport_half_h - margin_y))

if overflow_x > 0 or overflow_y > 0:
    Cam.x_next = PC.x - sign(pc_screen_x) × (viewport_half_w - margin_x)
    Cam.y_next = PC.y - sign(pc_screen_y) × (viewport_half_h - margin_y)
    # 本帧跳过软跟随,直接硬 snap 一次
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `zoom_current` | float | [0.8, 1.2] | 当前 zoom |
| `viewport_half_w/h` | float | 800–1200 / 450–675 | 半视口(世界单位) |
| `margin_x` | int | 80 (locked) | 横向 safety margin(像素) |
| `margin_y` | int | 120 (locked) | 纵向 safety margin(像素) |

**Output**: 触发时 `Cam` 直接 snap 到强制位置;否则不修改 lerp 结果。

**Worked Example** (zoom=1.0, PC 极速被击退向右):
- `viewport_half_w=960`,safety boundary 在 `±880`
- `PC.x=1000, Cam.x=100` → `pc_screen_x=900`
- `overflow_x=20 > 0` → **触发硬跟随**
- `Cam.x_next = 1000 - 880 = 120`(PC 此刻位于 viewport 右侧 880px 处)
- 下一帧软跟随接管

**Rationale**:
- 80/120 不对称 margin 协调 art-bible "屏幕中央 ±200px 禁 HUD" 区域,同时考虑纵向视野更窄的现实
- 触发条件 `overflow > 0`(提前 80/120px 介入)而非"PC 即将出屏"(事后补救),体感更柔和
- 硬 snap 而非提高 lerp 速率:中等击退也"猛追"会损失镜头稳定感

---

### 跨公式集成顺序(每帧固定执行)

```
1. 软跟随计算 Cam.x/y_next          (F1)
2. 检查硬跟随覆盖,可能覆写 Cam      (F4)
3. 更新 zoom_current                 (F3)
4. 计算 shake_offset                 (F2)
5. final = floor(Cam.x_next + shake_offset_x, Cam.y_next + shake_offset_y)
6. 应用到 Camera2D.global_position 和 zoom
```

**Critical**: `Cam.x/y` 在内存中保留浮点,**只在最终渲染步骤 floor**。否则浮点误差会让 Camera 在死区边缘抖动。

## Edge Cases

- **If PC 调用 `teleport_to()`(突破中心化/过场)**: Camera 同步调用 `snap_to(PC.global_position)`,清空震屏 offset 和 zoom 状态。无平滑过渡。
- **If 同帧收到 2+ 个 `shake()` 调用**: 多个 shake 状态叠加,每个独立维护自己的 (mag_t, decay, perlin offset),最终 `shake_offset = Σ all_shakes_offset`。但**总 offset clamp 到 ±30px**(避免极端叠加超出 viewport)。
- **If zoom Tween 进行中再次收到 zoom 切换请求**: 用 Formula 3 的 interruption handling——以 `zoom_current` 作为新的 `zoom_from`,重置 timer。不重新从 1.0 开始。
- **If 玩家在硬跟随触发的同帧又收到震屏**: 先完成 F4 硬 snap,再叠加 F2 shake offset。硬跟随优先,震屏永远是叠加层。
- **If Camera 在 frozen 状态期间收到 shake 请求**: 请求被忽略,但写入 shake queue。frozen 解除后,**queue 中超过 200ms 的请求丢弃**,新鲜的执行。
- **If 玩家死亡时震屏正在进行**: 立即清零震屏(死亡画面需要 art-bible Section 2 "灰阶脱色 + 缓慢漂浮"的克制感),不允许残留震屏污染死亡仪式。
- **If 境界突破期间(zoomed_breakthrough)接受到 shake 请求**: 请求被截断(突破期间是 immobile 状态,理论上 PC 不会被击中,但仍保护)。Damage System 在 PC immobile 时本就不应触发 knockback,这是双重保险。
- **If Web 帧率突然 <15fps(dt > 67ms)**: F1 alpha 计算 `1 - exp(-10×0.067) ≈ 0.487`,Camera 一帧追近 50%,玩家会感觉"画面跳跃"但不会"飞出屏幕"——F4 硬跟随兜底。
- **If 强制 zoom + 震屏 同时被触发**(BOSS 出场震屏 + zoom 推近): F3 和 F2 在不同变量上工作(zoom 改变 scale,shake 改变 offset),互不干扰。可以并行。
- **If PC 在 Camera viewport 完全外部(罕见,例如初始化错误)**: F4 立即触发硬跟随,1 帧内对齐。debug 模式额外 log warning。
- **If 屏幕尺寸变化(玩家全屏切换/旋转设备)**: viewport_half_w/h 重新计算,Camera 立即重新定位(可视为一次隐式 snap)。zoom 保持。

## Dependencies

### Upstream

| 上游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **Player Controller** | Hard | 读 `PC.global_position` (每 _process 拉模型) | 已设计 |
| **Damage/Health System** | Soft | 调 `Camera.shake(mag, dur, freq)` | 未设计 |
| **Boss AI** | Soft | 发 `boss_engaged` / `boss_defeated` 信号触发 zoom 状态 | 未设计 |
| **Realm Progression** | Soft | 调 `Camera.start_breakthrough_zoom()` / `end_breakthrough_zoom()` | 未设计 |
| **Run/Session Management** | Soft | 调 `Camera.freeze()` / `unfreeze()` | 未设计 |
| **Godot 4.6 Camera2D** | Hard | `global_position`, `zoom`, `offset` 属性 | 引擎核心 |

### Downstream

| 下游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **HUD** | Soft (隐式) | 假设 viewport 框定屏幕,UI 元素以屏幕坐标定位 | 未设计 |
| **VFX System (屏幕空间特效)** | Soft | 读 `Camera.get_viewport_rect()` 定位边缘特效 | 未设计 |
| **Spawn System** | Soft | 读 `Camera.get_visible_rect()` 在屏外生成敌人 | 包含在 Enemy Spawner GDD |

### External

- Godot 4.6 `Camera2D` 节点(零成本,引擎原生)
- Godot 4.6 `Tween` 节点(用于 zoom 过渡,可选——也可手写公式)

### Forbidden

- 其他系统**禁止**直接设置 `Camera2D.global_position` 或 `Camera2D.zoom`(必须走 API:`snap_to()` / `shake()` / state change signals)
- Camera **禁止**包含任何游戏逻辑(怪物生成/伤害判定等)——它只读取数据和应用变换

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 | 异常行为 |
|------|--------|----------|------|----------|
| `DEAD_ZONE` | 32 px | [16, 64] | PC 微移动时 Camera 是否响应 | 过低=画面抖;过高=PC "粘"在屏幕边缘 |
| `FOLLOW_RATE` | 10.0 | [8.0, 14.0] | F1 软跟随速率(半衰期 ≈ 1/k 秒) | 过低=松散;过高=粘脸 |
| `SHAKE_FREQ_RANGE` | [22, 28] Hz | [18, 35] | F2 噪声采样频率随机范围 | 过低=低频晃动(地震感);过高=采样混叠 |
| `SHAKE_MAG_TABLE` | [2,4,7,12,18] px | per-tier ±20% | F2 5档击退对应 magnitude | 单档过高=超出 viewport;过低=无反馈 |
| `SHAKE_DURATION_TABLE` | [100,130,160,200,250] ms | per-tier [80, 350] | F2 5档击退对应 duration | 过长=拖沓;过短=没察觉 |
| `SHAKE_TOTAL_CLAMP` | 30 px | [20, 50] | 多 shake 叠加上限(F2 edge case) | 过低=极端事件无反馈;过高=画面失控 |
| `ZOOM_DURATION` | 0.4 s | [0.2, 0.8] | F3 zoom 过渡时长 | 过短=突兀;过长=拖沓 |
| `ZOOM_RANGE` | [0.8, 1.2] | [0.7, 1.3] | F3 zoom 边界 | 超出会引起 Web Compatibility 渲染失真 |
| `BOSS_ZOOM_TARGET` | 1.1 | [1.05, 1.15] | BOSS 进入时的轻推近 | 过高=画面被锁死,玩家走位失去远视野 |
| `BREAKTHROUGH_ZOOM_OUT` | 0.9 | [0.85, 0.95] | 突破开始时的拉远 | 过低=拉过远画面溢出 |
| `MARGIN_X` | 80 px | [60, 120] | F4 横向 safety margin | 过低=PC 贴边缘;过高=Camera 总是硬跟随 |
| `MARGIN_Y` | 120 px | [80, 160] | F4 纵向 safety margin | 同上 |

**Knob 交互**:
- `FOLLOW_RATE` 与 `DEAD_ZONE` 协调——大死区 + 快速跟随会产生"PC 离开死区就猛追"的不连贯感;小死区 + 慢跟随产生"PC 总是偏中心"的固定 offset
- `SHAKE_MAG_TABLE` 与 PC 击退档位(`KNOCKBACK_FORCE_*` from PC GDD)耦合,**两表必须同步调整**
- `ZOOM_RANGE` 边界对 Web Compatibility 渲染器特别敏感,大幅修改需 technical-artist 验证

**调优优先级**:
- **Tier 1**(核心手感):`DEAD_ZONE`, `FOLLOW_RATE` — 极少调整
- **Tier 2**(节奏):`SHAKE_MAG_TABLE`, `SHAKE_DURATION_TABLE`, `BOSS_ZOOM_TARGET` — playtest 后微调
- **Tier 3**(技术参数):`SHAKE_FREQ_RANGE`, `MARGIN_X/Y`, `SHAKE_TOTAL_CLAMP` — 不需 designer 介入

## Visual/Audio Requirements

### Visual

Camera 本身不渲染任何东西——它只是变换矩阵。视觉表现完全靠它对世界的取景方式:

- **震屏可见性**: 震屏 offset 是 Camera 的隐性贡献,不需要额外 VFX 渲染。但震屏 + zoom 同时发生时(BOSS 击中),感官上是 Camera + VFX + Audio 的合奏
- **突破 zoom 拉远**: art-bible Section 7.5 的 1200ms 突破仪式开始时,Camera 拉远到 0.9,让玩家看见周围"被清场"的空间感
- **BOSS zoom 推近**: Boss Fight 状态下 1.1× 推近,art-bible Section 2 "tactical 留白 around BOSS" 的视觉强化

### Audio

Camera 不产生音效,但震屏 API 需要触发 Audio Manager 的协同响应:

- `shake_started(magnitude, duration)` 信号被 Audio 订阅,触发对应力度的击中音/低频震感
- 突破 zoom 拉远的同时,Audio 播放仪式音(由 Audio Manager 决定,不在 Camera GDD 范围)
- **Camera 不消费 Audio 信号**——单向输出

## UI Requirements

**Camera 不直接拥有 UI 元素**,但所有 UI 假设了 Camera 的存在:

- HUD 元素以**屏幕坐标**定位(art-bible Section 7.1 已锁定),不受 Camera transform 影响——靠 Godot 的 `CanvasLayer` 实现
- art-bible Section 7.1 "屏幕中央 ±200px 禁 HUD" 是 Camera 决定 viewport 中心后,HUD 围绕其布置的契约
- 震屏期间 HUD 也跟着抖吗?**不**——HUD 在 CanvasLayer,Camera 变换不影响。这是设计内行为(让玩家在震屏中仍能读 HP)

> **📌 UX Flag — Camera System**: 没有独立 UI。但 HUD 系统(Order #13)必须考虑 Camera 的震屏/zoom 不影响 UI 这一隐性契约,在 Pre-Production 运行 `/ux-design` 时验证。

## Acceptance Criteria

All AC follow GIVEN-WHEN-THEN. QA verifies each independently without reading the rest of this GDD. Priority: **[MVP]** = required for Concept Prototype; **[VS]** = Vertical Slice.

### AC-Cam-01 [MVP] Soft-follow never snaps under normal motion
- **GIVEN** PC at viewport center, Camera idle
- **WHEN** player presses direction and PC moves continuously for 2s at max walk speed
- **THEN** Camera position updates every frame with no single-frame Δpos > 8px; no `snap_to` called

### AC-Cam-02 [MVP] Deadzone suppresses Camera response
- **GIVEN** PC at deadzone center
- **WHEN** PC offsets by (+30, +30) — strictly inside ±32px deadzone
- **THEN** Camera position unchanged (Δ=0) across 60 frames; stepping to (+33, 0) causes Camera to begin moving on X only

### AC-Cam-03 [MVP] Follow is frame-rate independent (F1)
- **GIVEN** Camera following PC; PC teleported to fixed point 200px away
- **WHEN** scenario runs at locked 30fps and at locked 144fps for 1.0s simulated time
- **THEN** Camera position after 1.0s matches within ±2px between runs (verifies `alpha = 1 - exp(-10*dt)`); no NaN, no step > theoretical max

### AC-Cam-04 [MVP] Shake magnitude/duration match knockback table (F2)
- **GIVEN** PC in frozen state (so only shake offset observable)
- **WHEN** `shake()` invoked with each of 5 table entries (knockback 80/150/240/360/400)
- **THEN** peak measured offset within ±15% of mag0 (2/4/7/12/18 px); duration matches ±20ms

### AC-Cam-05 [MVP] Shake decays as cubic, not linear (F2)
- **GIVEN** `shake(mag0=12, duration=200ms, freq=25)` invoked
- **WHEN** offsets sampled at t = 50/100/150/200ms
- **THEN** envelope follows `(1-progress)^3` within ±15%: ≈ 5.06 / 1.5 / 0.19 / 0 px; t > 200ms contributes 0

### AC-Cam-06 [VS] Stacked shakes clamp to ±30px (Edge Case)
- **GIVEN** Camera at rest
- **WHEN** 3 simultaneous `shake(mag0=18, duration=250ms)` calls on same frame
- **THEN** sampled total offset never exceeds ±30px on either axis; logs report "shake clamp engaged"

### AC-Cam-07 [MVP] Zoom transitions complete in 0.4s with cubic in-out (F3)
- **GIVEN** Camera zoom = 1.0
- **WHEN** state transitions to `zoomed_boss` (target 0.9)
- **THEN** zoom at t=0.2s ∈ [0.94, 0.96] (cubic midpoint, not linear 0.95); reaches target ±0.005 at t = 0.4s ±20ms

### AC-Cam-08 [VS] Zoom interruption restarts from current, no rebound (F3)
- **GIVEN** `zoomed_boss` transition at t=0.15s (zoom_current ≈ 0.978)
- **WHEN** state transitions to `zoomed_breakthrough` (target 1.15) at that moment
- **THEN** sampled zoom **strictly monotonically increases** from 0.978 toward 1.15 across all frames; new transition completes 0.4s after interrupt

### AC-Cam-09 [MVP] snap_to bypasses smoothing (Core Rule 6)
- **GIVEN** Camera at (0,0), PC in deadzone
- **WHEN** `snap_to(Vector2(500, 300))` called
- **THEN** within 1 frame Camera position equals (500, 300) exactly; soft-follow resumes next frame from new origin

### AC-Cam-10 [VS] Forced hard-follow triggers before PC leaves viewport (F4)
- **GIVEN** soft-follow `alpha` artificially reduced so PC outpaces Camera
- **WHEN** `overflow = |pc.x - cam.x| - (viewport_half_w - 80)` > 0
- **THEN** Camera corrected same frame so overflow returns to 0; Y-axis behaves identically with margin_y=120 (asymmetric verified); PC never rendered outside viewport

### AC-Cam-11 [MVP] Final render position is integer-aligned (Core Rule 8)
- **GIVEN** Camera following PC, PC moves diagonally for 5s
- **WHEN** rendered Camera position read each frame via debug hook
- **THEN** every sampled x/y is integer (no fractional); visual capture shows zero sub-pixel jitter on 1-px reference grid

### AC-Cam-12 [VS] State priority resolves correctly under stacked triggers
- **GIVEN** Camera in `zoomed_boss` with active `shake()`
- **WHEN** game enters `frozen` next frame
- **THEN** Camera position + zoom held constant; shake offset = 0 during frozen (shakes queue per Edge Case); on `frozen` exit, `zoomed_boss` and queued shakes ≤200ms old resume; >200ms shakes discarded

### AC-Cam-13 [MVP] Death clears shake immediately (Edge Case)
- **GIVEN** `shake(mag0=18, duration=250ms)` issued 50ms ago, still active
- **WHEN** PC death signal fires
- **THEN** Camera shake offset returns to 0 within 1 frame; no shake during death sequence

### AC-Cam-14 [VS] Low-FPS (Web) safety: PC never escapes viewport
- **GIVEN** engine throttled to 12fps and PC dashes at max speed for 1.5s
- **WHEN** soft-follow alone would lag (per-frame dt large)
- **THEN** hard-follow (F4) engages each frame as needed; PC remains within viewport for every captured frame
- **Note**: If engine throttle harness unavailable, downgrade to documented manual playtest (BLOCKING)

### AC-Cam-15 [VS] Pull model: Camera reads PC, no signal subscriptions (Core Rule 3)
- **GIVEN** camera scene loaded; PC moved by external test harness
- **WHEN** PC's `position_changed` signal disconnected
- **THEN** Camera still tracks PC correctly (proves pull model); code grep on `camera.gd` shows zero `connect(...)` calls to PC position signals

---

### Test Evidence Classification

| AC | Type | Location | Gate |
|----|------|----------|------|
| AC-Cam-01 to 05, 07-09, 11, 13 | Logic | `tests/unit/camera/*.gd` | BLOCKING |
| AC-Cam-06, 12, 15 | Logic / Integration | `tests/unit/camera/` + integration | BLOCKING |
| AC-Cam-10, 14 | Integration | `tests/integration/camera/*.gd` | BLOCKING |
| AC-Cam-11 | Visual/Feel | `production/qa/evidence/camera_pixel_perfect_[date].png` + lead sign-off | ADVISORY (visual) |
| AC-Cam-04 | Logic | Tolerance ±15% on Perlin amplitude (tighten after first measurement) | BLOCKING |

**Coverage**: 8 Core Rules × 4 Formulas × 5 Edge Cases all mapped. MVP=9 AC, VS=+6 AC.

## Open Questions

1. **多 shake 的 Perlin seed 分配策略**: F2 提到每次 shake 用不同 seed 避免共振,但具体实现是 `seed = global_counter++` 还是 `seed = randf()`?**Owner**: gameplay-programmer。**Target**: 实现时决定。

2. **viewport 半尺寸的 zoom 适配**: F4 假设 `viewport_half_w = (1920/2) / zoom`,但实际 viewport 像素尺寸取决于窗口大小。Godot `Camera2D.get_viewport_rect()` 在 Web Compatibility 下如何处理动态窗口?**Owner**: gameplay-programmer + technical-artist。**Target**: 实现时验证。

3. **触屏旋转/横竖屏切换的 Camera 响应**: 设备旋转后 viewport 尺寸变化,Camera 是否需要触发某种过渡?目前 Edge Case 写"立即重新定位",但视觉感受可能突兀。**Owner**: ux-designer。**Target**: 移动 Web 测试阶段。

4. **boss_engaged 信号何时由谁 emit**: zoomed_boss 状态切换依赖此信号,但 Boss AI GDD 尚未设计。需在 Boss AI GDD 设计时明确 emit 时机(BOSS 进入战斗范围?BOSS 释放第一招?)。**Owner**: game-designer + ai-programmer。**Target**: Boss AI GDD 设计时(Order #11)。

5. **frozen 状态下震屏 queue 的最大长度**: 当前规则">200ms 丢弃",但没限制队列长度。极端情况(玩家暂停 10 分钟后回来,期间有 50 个 shake 请求积压)?**Owner**: gameplay-programmer。**Target**: 实现时加 max queue size = 5。
