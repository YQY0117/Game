# Input System

> **Status**: In Design
> **Author**: user + game-designer + gameplay-programmer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 3 (自创流派 — 轻度操作让构筑成为表达) + Pillar 1 (近在咫尺 — 响应快=目标可达)
> **Priority**: MVP | **Layer**: Foundation
> **Source Systems Index**: design/gdd/systems-index.md (Order #1)

## Overview

Input System 是一个统一抽象层,把键盘/鼠标(桌面)、触屏(移动)、Gamepad(辅助)三类原始输入归一为一组**语义动作**(`move_up`、`move_down`、`move_left`、`move_right`、`pause`、`confirm`、`cancel`、`technique_slot_1..4`),供 Player Controller、HUD、Menu System 等下游系统消费。系统同时维护**当前活跃输入模式**(KBM / Touch / Gamepad / Auto),通过滞后机制(2 个连续事件 或 500ms 持续输入)自动切换,避免误触。

玩家不主动"使用"这个系统——它是基础设施。但当玩家在桌面浏览器和移动浏览器间切换设备时,UI 自动切换布局(art-bible Section 7.1 规定),正是这个系统在背后承担状态判定。轻度操作的核心需求(走位为唯一动词)让本系统不需要复杂的连招输入识别,但 Web 平台双输入并行的现实又决定了滞后切换机制是不可妥协的复杂度——这是本系统的核心设计权衡。

## Player Fantasy

**Indirect — the player feels what this system enables, not the system itself.**

优秀的输入系统是隐形的。玩家想往左走,角色就往左走;玩家在桌面上玩到一半盖上笔记本拿起手机,UI 切到触屏布局,继续走位——**没有学习曲线、没有切换提示、没有"你正在使用 XX 模式"的弹窗**。

这个系统服务的不是"操控的快感"(那是 Player Controller 的责任),而是"操控不存在的体验"。在 Survivor-like 这种持续 30-40 分钟、要求玩家长时间保持心流的游戏里,任何输入层面的摩擦——延迟、误触、模式混乱——都会把玩家从"风暴之眼"的幻想中拽出来,变回"一个在操作软件的人"。

输入系统的成功,是玩家结束一局后**不记得自己曾经按过任何键**。他们记得的是走位的节奏、夺取功法的瞬间、突破境界的光华。输入是道,Player Controller 才是术。

> **Note**: `creative-director` not consulted — Lean mode (Section B is not HIGH risk).

## Detailed Design

### Core Rules

1. **语义动作映射**: 所有下游系统只调用语义动作(`Input.is_action_pressed("move_up")` 等),绝不直接读取键码或触屏坐标。
2. **三类输入设备的并行监听**:
   - **键盘**: `InputEventKey` → 方向键/技能键
   - **鼠标**: `InputEventMouseMotion` → 模式判定信号(不直接产生 move,因为本作是走位 survivor)
   - **触屏**: `InputEventScreenTouch` + `InputEventScreenDrag` → 经虚拟摇杆中介转换为方向向量
   - **Gamepad**: `InputEventJoypadMotion` + `InputEventJoypadButton` → 直接映射(HTML5 Gamepad API 透过 Godot 桥接)
3. **输入模式状态机**: 维护当前 active mode ∈ {KBM, Touch, Gamepad}。模式切换驱动 HUD 布局变化(Player Controller 自身行为不变,只是数据来源不同)。
4. **滞后切换**: 不同设备类型的输入事件到达时,需满足 **至少 3 个连续事件 OR 该设备 400ms 内持续输入** 才触发模式切换(Touch 模式额外 +200ms 冷却防误触)。单个偶发事件被忽略(避免 Chromebook 笔记本误触发场景)。
5. **强制模式覆盖**: Settings 提供 `input_mode` 选项 ∈ {Auto, Force_KBM, Force_Touch}。非 Auto 时滞后机制 disabled,UI 永远显示该模式布局,但所有设备的语义动作仍响应(只是 UI 不变)。
6. **死区与平滑**: 虚拟摇杆和 Gamepad 摇杆共用死区配置(参见 Section D 公式),输出归一化的 Vector2 movement direction。
7. **无悬停依赖**: 任何 UI 元素禁止只通过鼠标悬停触发关键功能——触屏无 hover。悬停可以增强(显示提示),但不能是唯一交互。
8. **语义键位映射**: `pause` = Esc / 屏幕暂停按钮 / Start;`confirm` = Enter/Space / 点击 / A;`cancel` = Esc / 返回按钮 / B。

### States and Transitions

| 当前模式 | 触发事件 | 转换条件 | 目标模式 |
|---------|---------|----------|---------|
| KBM | 触屏事件到达 | 3 个连续触屏事件 OR 400ms 持续触屏输入(+200ms 冷却) | Touch |
| KBM | Gamepad 事件到达 | 3 个连续 Gamepad 事件 OR 400ms 持续 Gamepad 输入 | Gamepad |
| Touch | 键鼠事件到达 | 3 个连续键鼠事件 OR 400ms 持续键鼠输入 | KBM |
| Touch | Gamepad 事件到达 | 3 个连续 Gamepad 事件 OR 400ms 持续 Gamepad 输入 | Gamepad |
| Gamepad | 键鼠事件到达 | 3 个连续键鼠事件 OR 400ms 持续键鼠输入 | KBM |
| Gamepad | 触屏事件到达 | 3 个连续触屏事件 OR 400ms 持续触屏输入(+200ms 冷却) | Touch |
| 任意 | Settings 切换为 Force_KBM / Force_Touch | 立即(无滞后) | 强制模式 |
| 强制模式 | Settings 切换为 Auto | 立即转为 KBM 作为初始,后续按 Auto 规则 | Auto:KBM |

**初始模式**(游戏启动时):
1. 优先 **Gamepad** 如果检测到已连接的 Gamepad
2. 否则 **Touch** 如果运行环境是移动浏览器(`navigator.userAgent` 包含 mobile)
3. 否则 **KBM**(默认)

### Interactions with Other Systems

| 下游系统 | 数据接口 | 方向 | 接口所有者 |
|---------|---------|------|-----------|
| **Player Controller** | 读取 `get_movement_vector() -> Vector2`(归一化方向,死区处理后),`is_action_pressed("pause")` | Input → PC | Input System 暴露 |
| **HUD** | 订阅 `input_mode_changed(new_mode: String)` 信号,根据 mode 切换布局(桌面对称 vs 触屏 2+2) | Input → HUD | Input System 暴露 |
| **Menu System** | 同 HUD,布局切换 + `confirm`/`cancel` 语义动作 | Input → Menu | Input System 暴露 |
| **Settings** | 读取 `input_mode` 持久化值,写回 `set_force_mode(mode: String)` | Settings ↔ Input | Settings 拥有持久化,Input 拥有运行时状态 |
| **Technique System** | `is_action_just_pressed("technique_slot_N")` | Input → Technique | Input System 暴露 |

**Godot 信号契约**:
- `input_mode_changed(new_mode: String)` — 模式切换完成时触发
- `force_mode_applied(mode: String)` — Settings 强制覆盖时触发
- `device_disconnected(device: String)` — Gamepad 断开等场景

> **Note**: Specialist agents not consulted at Section C — Lean mode (C is not flagged HIGH risk; UX/touch concerns from art-bible Section 7 already incorporated).

## Formulas

### Per-Device Constants (查找表)

| 常量 | KBM(键盘) | Touch(虚拟摇杆) | Gamepad |
|------|------------|------------------|---------|
| `DEAD_ZONE` | N/A(数字输入) | 0.10 | 0.15 |
| `RESPONSE_CURVE_POWER` | 1.0(线性,数字) | 1.5(轻度非线性) | 1.0(物理形变已提供反馈) |
| 模式切换最小事件数 | 3 | 3 | 3 |
| 模式切换持续时长 (ms) | 400 | 400 | 400 |
| → 切换到该模式额外冷却 | 标准 | **+200ms**(更慢,防误触) | 标准 |

---

### Formula 1: Dead Zone & Magnitude Smoothing

**Variables:**
| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `raw` | r | Vector2 | [-1, 1] each axis | 原始摇杆向量(虚拟摇杆或 Gamepad analog) |
| `DEAD_ZONE` | d | float | [0, 1] | 死区半径(per-device,查上表) |
| `smoothed_magnitude` | m | float | [0, 1] | 归一化后的有效输出强度 |

```
if |raw| < DEAD_ZONE:
    movement_vector = Vector2.ZERO
else:
    m = clamp((|raw| - DEAD_ZONE) / (1 - DEAD_ZONE), 0, 1)
    movement_vector = raw.normalized() * pow(m, RESPONSE_CURVE_POWER)
```

**Output Range:** Vector2 with magnitude ∈ [0, 1]
**Example (Touch, raw=Vector2(0.3, 0))**: |raw|=0.3 > 0.10, m=(0.3-0.10)/(1-0.10)=0.222, output_magnitude=0.222^1.5=0.105, movement_vector=(0.105, 0)

---

### Formula 2: Mode Switching Hysteresis (per-direction)

**Variables:**
| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| `consecutive_events_count` | n | int | ≥0 | 同设备类型在 < 200ms 内连续触发事件数 |
| `continuous_duration_ms` | t | int | ≥0 | 该设备持续输入累计时长 |
| `MIN_EVENTS` | — | int | 3 | 最小连续事件数 |
| `MIN_DURATION_MS` | — | int | 400 | 最小持续时长(基础值) |
| `EXTRA_COOLDOWN_MS` | — | int | 200 | KBM/Gamepad → Touch 额外冷却 |

```
threshold_ms = MIN_DURATION_MS + (target_mode == Touch ? EXTRA_COOLDOWN_MS : 0)
should_switch = (n >= MIN_EVENTS) OR (t >= threshold_ms)
```

**Rationale:** Switching INTO Touch is the most error-prone direction (palm rest, accidental brush on Chromebook hybrid devices). Adding 200ms cooldown to inbound-Touch transitions reduces false flips significantly.

---

### Formula 3: Keyboard Direction Normalization

**Variables:** Boolean keyboard states for each direction action.

```
raw_x = (move_right ? 1 : 0) - (move_left ? 1 : 0)
raw_y = (move_down ? 1 : 0) - (move_up ? 1 : 0)
move_vec_raw = Vector2(raw_x, raw_y)

if move_vec_raw.length() > 0:
    movement_vector = move_vec_raw.normalized()
else:
    movement_vector = Vector2.ZERO
```

**Critical:** The `length() > 0` check prevents `normalized()` zero-vector divide. Without it, releasing all direction keys at the exact same frame produces NaN.

**Output Range:** Unit vector or zero. Diagonal movement = (±0.707, ±0.707), preventing the 1.414× diagonal speed bug.

---

### Formula 4: Mouse Movement Threshold (for mode switching)

**Variables:**
| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `mouse_delta_px` | float | ≥0 | 鼠标在 100ms 窗口内累计位移像素 |
| `MOUSE_ACTIVE_THRESHOLD` | int | 8 | 像素阈值 |

```
mouse_event_is_meaningful = (mouse_delta_px >= MOUSE_ACTIVE_THRESHOLD within 100ms window)
```

**Rationale:** Mouse pointer drift, table vibration, or accidental brushes produce sub-pixel motion. The 8px threshold filters noise without ignoring genuine intent (any deliberate hand movement easily exceeds 8px in 100ms).

---

### Formula 5: Floating Virtual Joystick Center

**Variables:**
| Variable | Type | Description |
|----------|------|-------------|
| `last_touch_time_ms` | int | 上次手指接触屏幕的时间戳 |
| `JOYSTICK_RESET_MS` | int = 100 | 无触摸后多久重置中心 |
| `joystick_center` | Vector2 | 摇杆视觉/逻辑原点 |

```
on new_touch_event(pos):
    if (current_time - last_touch_time_ms) > JOYSTICK_RESET_MS:
        joystick_center = pos  # 浮动摇杆 — 中心跟随手指首次落点
    last_touch_time_ms = current_time
```

**Rationale:** 固定虚拟摇杆要求玩家每次都精准落到屏幕左下角的某个圆,长时间游玩手指疲劳。浮动摇杆是 Survivor.io / Archero 标准实践,玩家手指首次落点即中心,后续位移产生方向向量。

---

### Formula 6: Input-to-Movement Latency Budget

**Variables:**
| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `input_to_movement_latency_ms` | float | ≥0 | 从硬件事件到 movement_vector 更新的延迟 |

```
input_to_movement_latency_ms <= 33ms  (2 frames @ 60fps)
```

**Rationale:** 这是性能契约,不是优化目标。超过 33ms 玩家会感到"输入粘滞",破坏 Player Fantasy 中的"操控不存在"体验。Web 平台需特别注意:浏览器事件队列处理 + Godot 信号传播 + Player Controller 物理 tick 全部叠加。

---

### Formula 7: Multi-Device Arbitration

**Variables:**
| Variable | Type | Description |
|----------|------|-------------|
| `last_event_time_ms[device]` | dict[String → int] | 每个设备类型的最近事件时间戳 |

```
active_device = argmax(last_event_time_ms over all devices that passed hysteresis)
```

**Rationale:** 当 Gamepad 接入桌面 + 键鼠同时活跃 + 笔记本触屏被碰触,系统必须有明确的仲裁规则。"最近通过滞后机制的设备胜出"是最直觉的方案——玩家最近操作的设备就是他正在使用的。

---

### Formula 8: Idle Detection

**Variables:**
| Variable | Type | Description |
|----------|------|-------------|
| `IDLE_THRESHOLD_MS` | int = 50 | 静止判定阈值 |

```
is_idle = (movement_vector == Vector2.ZERO for >= IDLE_THRESHOLD_MS continuous)
```

**Rationale:** 下游系统(回血、自动瞄准触发、HUD 透明度淡化、状态机回到 idle 等)经常需要"玩家是否真的静止"的判定。50ms 阈值过滤瞬时方向切换间隙(玩家从向左切到向右时,中间会有 1-2 帧的零向量),只在真正静止时触发 idle。

## Edge Cases

- **If 玩家在战斗中拔掉 Gamepad**: 模式立即降级为 KBM(无滞后,因为玩家失去了控制源不能等 400ms),触发 `device_disconnected` 信号供 UI 显示"Gamepad disconnected"提示。如果当前模式是 Gamepad 且玩家正在按方向键,movement_vector 立刻使用键盘输入,无中断。
- **If 玩家同时按下左右方向键**: raw_x = 0,玩家停止水平移动(对消),不报错。这是设计内行为,不是 bug——允许玩家"急停"。
- **If 触屏摇杆被多个手指同时触碰**: 只追踪 **第一个**触碰的手指作为摇杆控制源。第二个手指被忽略,直到第一个手指释放。
- **If 玩家在 Setting 强制模式下连接 Gamepad**: 不切换模式,但语义动作仍响应(玩家可以用 Gamepad 移动,但 UI 保持强制模式布局)。这是显式行为,Settings 优先于 Auto 检测。
- **If 浏览器失去焦点(切到其他标签页)**: 所有按键状态立即清零,movement_vector → Vector2.ZERO。防止 "stuck key" bug(切回来时角色还在走)。
- **If 玩家在虚拟摇杆区域之外开始触摸**: 第一个触点落点视为摇杆中心(Formula 5 浮动摇杆),即使该位置在屏幕中央。但**摇杆中心被限制在屏幕左半部分**——避免玩家右手操作功法按钮时误触发摇杆。
- **If 输入事件流过快(>200 events/sec)**: 这是设备故障或恶意输入,系统降级为 60Hz 采样(每 16.6ms 取最新事件),其余丢弃。
- **If Godot 启动时检测不到任何输入设备**: 默认 KBM 模式,等待第一个输入事件确定真实模式。不阻塞游戏启动。
- **If 多个键盘连接(罕见)**: Godot 把所有键盘输入合并处理,无需区分。InputMap 不区分多键盘。
- **If Gamepad analog stick 死区内有微弱漂移**: 由 Formula 1 死区处理,movement_vector 保持 Vector2.ZERO,玩家不会"自己漂移"。
- **If 玩家按住 technique_slot_N 不放**: `is_action_just_pressed` 只在首帧触发;`is_action_pressed` 持续返回 true。下游 Technique System 自己决定是否支持长按(MVP 阶段不支持)。
- **If pause 键在过场动画(如境界突破不可跳过仪式)被按下**: pause 事件被消费但不生效。事件不传递给下游 Menu System,art-bible Section 7.5 的"不接受任何输入跳过"约束在 Input 层就被截断。

## Dependencies

### Upstream (none — Foundation layer)

Input System 是 Foundation 层,无上游依赖。它直接消费 Godot 的 InputEvent 流,不依赖任何项目内部系统。

### Downstream (systems that depend on Input System)

| 下游系统 | 硬/软依赖 | 接口 | 备注 |
|---------|----------|------|------|
| **Player Controller** | Hard | `get_movement_vector() -> Vector2` | 没有 Input 就无法移动 |
| **HUD** | Soft | `input_mode_changed` 信号 | 没有信号 HUD 仍可显示默认布局(KBM) |
| **Menu System** | Hard | `confirm` / `cancel` 语义动作 + `input_mode_changed` 信号 | 菜单无输入无法导航 |
| **Settings** | Hard | `set_force_mode()` API + 读取持久化的 `input_mode` 值 | 双向接口 |
| **Technique System** | Hard | `is_action_just_pressed("technique_slot_N")` | 玩家手动激活功法时(MVP 暂不需要,但接口预留) |
| **Run/Session Management** | Soft | `pause` 语义动作 | 没有时无法暂停,但局可以正常进行 |

### External dependencies (Godot engine)

- **Godot 4.6 InputMap**: 在 `project.godot` 中定义所有语义动作
- **Godot 4.6 InputEvent 类家族**: InputEventKey / InputEventMouseMotion / InputEventScreenTouch / InputEventScreenDrag / InputEventJoypadMotion / InputEventJoypadButton
- **HTML5 Gamepad API**: 通过 Godot 自动桥接,无需直接调用

### Forbidden interactions

- 下游系统**禁止**直接调用 `Input.is_key_pressed(KEY_W)` 等键码级 API——必须走语义动作
- 下游系统**禁止**订阅原始 `InputEvent` 流——必须订阅 Input System 的封装信号
- Input System **禁止**包含任何业务逻辑(如"按下 X 时给玩家加血")——只做输入到语义的翻译

---

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 | 异常行为 |
|------|--------|----------|------|----------|
| `DEAD_ZONE_TOUCH` | 0.10 | [0.05, 0.20] | 虚拟摇杆死区 | 过低=手指颤抖触发漂移;过高=轻推无响应 |
| `DEAD_ZONE_GAMEPAD` | 0.15 | [0.10, 0.25] | Gamepad analog 死区 | 过低=摇杆漂移误移动;过高=轻推感觉粘滞 |
| `RESPONSE_CURVE_POWER_TOUCH` | 1.5 | [1.0, 2.0] | 虚拟摇杆响应曲线 | 过低=精细控制差;过高=慢推无效快推突变 |
| `RESPONSE_CURVE_POWER_GAMEPAD` | 1.0 | 锁定为 1.0 | Gamepad 响应曲线 | 必须线性,物理形变已提供反馈 |
| `MODE_SWITCH_MIN_EVENTS` | 3 | [2, 5] | 滞后最小连续事件数 | 过低=误触切换;过高=玩家感觉切换"卡" |
| `MODE_SWITCH_MIN_DURATION_MS` | 400 | [200, 800] | 滞后最小持续时长 | 过低=漂移触发;过高=玩家迫切切换被忽视 |
| `EXTRA_COOLDOWN_TO_TOUCH_MS` | 200 | [0, 500] | 切入 Touch 的额外冷却 | 过低=误触触屏导致 UI 闪烁;过高=真正切到触屏延迟 |
| `MOUSE_ACTIVE_THRESHOLD_PX` | 8 | [4, 16] | 鼠标位移触发模式判定的最小像素 | 过低=噪声触发;过高=轻微鼠标移动被忽略 |
| `JOYSTICK_RESET_MS` | 100 | [50, 300] | 浮动摇杆中心重置时长 | 过低=连续触摸被分割成多次摇杆;过高=玩家想换位置发现摇杆"粘住" |
| `INPUT_LATENCY_BUDGET_MS` | 33 | 性能契约,非可调 | 输入到移动的最大延迟 | 超过 = 玩家感受"输入粘滞",违反 Player Fantasy |
| `IDLE_THRESHOLD_MS` | 50 | [30, 100] | 静止判定阈值 | 过低=方向切换间隙被误判 idle;过高=下游系统响应慢 |

**Knob 交互**:
- `MODE_SWITCH_MIN_EVENTS` 和 `MODE_SWITCH_MIN_DURATION_MS` 是 OR 关系,降低任一即降低整体切换门槛
- `DEAD_ZONE_*` 和 `RESPONSE_CURVE_POWER_*` 配对调节——死区大时曲线幂应适度降低,避免"突然全速"的感觉

**Settings UI 暴露**:
- 默认配置面板:只暴露 Force Mode 切换(art-bible Section 7.2)
- 高级配置(隐藏菜单或调试模式):暴露 DEAD_ZONE 和 RESPONSE_CURVE_POWER 给硬核玩家自定义

## Visual/Audio Requirements

**Visual**: 本系统是纯基础设施,无独立视觉需求。下游 HUD 系统负责虚拟摇杆和触屏按钮的视觉呈现(art-bible Section 7.4 已规范)。

**Audio**: 无独立音效需求。下游 Menu System 负责按钮点击音、暂停音等。Input System 只产生语义事件,音效响应由消费者决定。

## UI Requirements

**虚拟摇杆**(art-bible Section 7.4 已规范):
- 触屏模式下显示在左下角(浮动中心,首次触摸点即圆心)
- 命中区: 屏幕左半部分
- 视觉: 内圆(手指位置) + 外圆(范围边界),宣纸白底 + 浓墨黑边
- 推到边缘时外环朱砂闪烁 + haptic 反馈

**模式切换提示**(art-bible 已约定):
- 输入模式自动切换时,屏幕角落短暂 8px 朱砂点闪烁 200ms
- 不显示文字提示(art-bible "没有学习曲线"原则)

**Settings 中的 Input 配置面板**:
- "输入模式" 切换器:Auto / 强制键鼠 / 强制触屏(三选一,圆章样式)
- 默认配置面板**不暴露** DEAD_ZONE / RESPONSE_CURVE 等高级参数
- 高级模式(隐藏菜单或调试构建)暴露 Tuning Knobs 表中标注的项

**📌 UX Flag — Input System**: 此系统有 UI 需求(虚拟摇杆、模式切换提示、Settings 面板)。在 Phase 4(Pre-Production),运行 `/ux-design` 为虚拟摇杆和 Settings Input 面板创建 UX 规范,然后才开始写 Story。

## Acceptance Criteria

> Note: Numerical constants (e.g. dead zone 0.10/0.15) below are GDD defaults; they may be overridden at runtime via `data/input_config.json` once tuning begins. AC must verify behavior under the defaults.

### AC-01 [MVP] All semantic actions can be triggered

**GIVEN** game in gameplay scene with InputManager initialized
**WHEN** QA triggers each of the 8 actions via KBM default bindings (WASD / Esc / Enter / Esc / 1-4)
**THEN** InputManager emits the corresponding semantic event within ≤1 frame, with exact event names `move_up/down/left/right/pause/confirm/cancel/technique_slot_1..4`

### AC-02 [MVP] Mode switch hysteresis (3 events OR 400ms)

**GIVEN** `active_mode == "kbm"` with no Touch events in last 400ms
**WHEN** Touch produces either 3 consecutive `touch_down` within 400ms OR a single `touch_down` held ≥400ms
**THEN** `active_mode` flips to `"touch"` and emits `input_mode_changed(touch)` once; below threshold mode remains `"kbm"`

### AC-03 [MVP] Per-device dead zones effective

**GIVEN** `active_mode == "touch"` (deadzone 0.10) and `"gamepad"` (deadzone 0.15)
**WHEN** stick vector magnitude is injected at 0.08 (Touch) / 0.12 (Gamepad) / 0.20 (either)
**THEN** first two cases output `(0,0)`; 0.20 case outputs non-zero vector with magnitude remapped to `[0,1]`

### AC-04 [MVP] Keyboard normalization and opposing-key stop

**GIVEN** `active_mode == "kbm"`
**WHEN** holding W+S simultaneously (or A+D)
**THEN** that axis output is `0.000`; diagonal W+D outputs vector with `magnitude == 1.000 ± 0.001` (normalized, no divide-by-zero)

### AC-05 [VS] Mouse movement triggers mode switch

**GIVEN** `active_mode == "gamepad"`
**WHEN** mouse accumulates ≥8px displacement within 100ms
**THEN** `active_mode` switches to `"kbm"`; displacement <8px or duration >100ms triggers no switch

### AC-06 [MVP] Floating joystick center + multi-finger filtering

**GIVEN** `active_mode == "touch"` with `touch_down` on left half of screen
**WHEN** first finger lands and becomes virtual joystick center, then a second finger lands and moves
**THEN** only first finger affects `move_vector`; after first finger releases and 100ms passes with no new touch, next touch resets center coordinates

### AC-07 [MVP] Idle detection: 50ms zero vector

**GIVEN** previous `move_vector ≠ 0`
**WHEN** input continuously outputs zero vector for ≥50ms
**THEN** InputManager emits `input_idle` once; no repeat emission until `move_vector` becomes non-zero again

### AC-08 [MVP] Force mode override

**GIVEN** Settings has `force_input_mode = "touch"`
**WHEN** Gamepad stick pushed to 1.0 sustained for 1 second
**THEN** UI hint elements stay Touch-styled, `active_mode` reports `"touch"`, but `move_vector` still responds to Gamepad with Gamepad deadzone/curve (action works, display unchanged)

### AC-09 [VS] Input latency budget + high-frequency downsampling

**GIVEN** stable 60fps with latency probe enabled
**WHEN** injecting 200 random key events and measuring time from injection to emit
**THEN** p95 ≤ 33ms; when input source frequency exceeds 60Hz, InputManager aggregates to 60Hz internally with event queue depth ≤ 2

### AC-10 [VS] Gamepad hot-disconnect immediate downgrade

**GIVEN** `active_mode == "gamepad"` with non-zero stick output
**WHEN** Gamepad disconnects (`Input.joy_connection_changed(false)`)
**THEN** `active_mode` switches to `"kbm"` in same frame (bypassing 400ms hysteresis), `move_vector` immediately zeros, emits `input_mode_changed(kbm)`

### AC-11 [MVP] Browser focus loss zeroes input

**GIVEN** any `active_mode` with keys held down
**WHEN** browser tab loses focus (`window.onblur` or Godot `NOTIFICATION_APPLICATION_FOCUS_OUT`)
**THEN** all key states set to `released`, `move_vector == (0,0)`, no stuck-key produced

### AC-12 [MVP] Pause emitted but PauseManager handles ritual exclusion

**GIVEN** `GameState == "breakthrough_ritual"`
**WHEN** player presses Esc (pause action)
**THEN** InputManager still emits `pause` (does NOT know game state — single responsibility); PauseManager (downstream consumer) does not open pause menu in this state

### AC-13 [VS] Keybind remapping persistence + minimum reserved keys

**GIVEN** user remaps `pause` from Esc to P in Settings and exits game
**WHEN** game restarts and enters gameplay
**THEN** P triggers pause, Esc no longer triggers pause; AND `pause` + `confirm` cannot be cleared simultaneously (UI rejects such binding — minimum reserved keys)

### AC-14 [VS] Cross-browser smoke matrix

**GIVEN** Chrome / Firefox / Safari latest stable versions
**WHEN** executing AC-01, AC-02, AC-06, AC-11 in each browser
**THEN** all 4 ACs pass; failures recorded to `production/qa/evidence/input-browser-matrix.md`

### AC-15 [MVP] Downstream consumer contract stability

**GIVEN** current commit's InputManager event signatures
**WHEN** running `tests/integration/input/test_input_contract.gd`
**THEN** 8 semantic action names + `input_mode_changed` + `input_idle` signal signatures match GDD Section C (Detailed Design); any renaming fails the assertion

---

### Test Evidence Allocation

| AC | Story Type | Evidence Location |
|----|-----------|-------------------|
| AC-01, 03, 04, 07 | Logic | `tests/unit/input/` |
| AC-02, 05, 10, 15 | Integration | `tests/integration/input/` |
| AC-06, 08, 09, 12 | Integration | `tests/integration/input/` + screen capture |
| AC-11, 14 | Integration | Manual + `production/qa/evidence/` |
| AC-13 | UI | Manual walkthrough doc |

## Open Questions

1. **多设备同时输入时的 movement_vector 仲裁细节**:Formula 7 定义了"最近通过滞后的设备胜出",但如果 KBM 和 Gamepad 都在持续输入,谁覆盖谁?目前假设是最近一帧的事件源决定,但未验证。**Owner**: gameplay-programmer。**Target**: Player Controller 设计完成后回归验证。

2. **HTML5 Gamepad API 在不同浏览器的实测兼容性**:特别是 Safari 移动端对 Gamepad 的支持。**Owner**: technical-artist。**Target**: 引擎集成 spike 完成后。

3. **是否需要支持 keybind 自定义重映射(完整版)**:MVP 阶段只支持 Force Mode 切换,不支持 per-key 重映射。AC-13 假定 VS 阶段实现,需要确认是否要做。**Owner**: ux-designer。**Target**: Settings GDD 设计时。

4. **触屏长按是否作为独立语义动作**:目前 `is_action_pressed` 持续返回 true,Technique System MVP 阶段不区分长按短按。Combo System 可能需要"持续按住功法槽"激活某种 charge 状态。**Owner**: game-designer。**Target**: Technique System / Combo System GDD 设计时。

5. **键盘重映射的最低保留键集**:AC-13 限定 `pause + confirm` 至少有一个绑定。`move_*` 需要保留吗?如果用户清空了所有方向键怎么办?**Owner**: ux-designer + qa-lead。**Target**: Settings GDD 设计时。
