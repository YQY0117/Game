# Run/Session Management

> **Status**: In Design
> **Author**: user + game-designer + systems-designer + qa-lead
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 1 (近在咫尺 — 死亡画面的"再来一局"按钮是核心 retention 机制)
> **Priority**: MVP | **Layer**: Core
> **Source Systems Index**: design/gdd/systems-index.md (Order #5)

## Overview

Run/Session Management 管理"一局游戏"的完整生命周期——从主菜单进入战斗,到死亡或飞升通关,再到结算和返回菜单。它是**游戏的总调度器**,负责协调场景加载/卸载、各系统的初始化和清理、暂停/恢复、过场动画的进入/退出、以及局结束时统计数据的汇总。

具体而言,它维护一个全局的 `RunState` 状态机(menu / loading / playing / paused / breakthrough / dying / dead / victory / abandoned),所有 gameplay 系统订阅状态变化来决定自己是否运行(例如 PC 在 `paused` 期间不响应输入,Enemy Spawner 在 `breakthrough` 期间停止生成)。它也跟踪本局的统计数据(开始时间、击败 BOSS 列表、解锁的功法、最终境界等),供死亡画面和 Meta-Progression 消费。

这个系统**不做任何 gameplay 逻辑**——它只是一个状态广播器和过渡协调器。"玩家被击败后该做什么"由其他系统通过订阅信号自行决定;Run/Session 只负责说"我们现在是 dead 状态"。

## Player Fantasy

**Both — 玩家通过死亡画面直接感受这个系统,但中间的状态转换是隐性基础设施。**

玩家直接感受的:**"再来一局"按钮的心理冲动**。Roguelite 的核心 retention 就是这个按钮——死亡画面 800ms 黑场 + "殁"字 + 简短战绩(art-bible Section 2 死亡仪式)+ 中央的"重来"按钮。玩家会下意识地点它,因为他们"差一点就到金丹期了"——而这个数据(本局最高境界)正是 Run/Session 系统在跟踪。

玩家不会察觉的:暂停时 SceneTree 怎么冻结、场景切换怎么过渡、Web 浏览器切到后台时的自动暂停——这些应该"自然发生",玩家不需要学习。

参考标杆: **Hades** 的死亡画面节奏——失败时的"屋外光景"过场是仪式,但回到死神之家又是无缝衔接的;玩家既感到死亡的重量,又不会被流程阻碍。**Vampire Survivors** 的死亡画面更简短:数字结算 + 重开按钮,降低重开成本。我们走 Hades 倾向——art-bible 已锁定 800ms 死亡仪式不可跳过,但仪式结束后立即可点"重来"。

这个系统的成功 = 玩家死了 50 次,**每一次都立刻按重来**——因为他们记得本局的最高境界、本局解锁的新功法、和"下一局我要走火 combo 路线"的下一步规划。

> **Note**: `creative-director` not consulted — Lean mode; art-bible Section 2 (death ritual) + game-concept MVP (single-run + meta-unlock + "再来一局"按钮在死亡画面正中央) 已锁定 Player Fantasy 核心。

## Detailed Design

### Core Rules

1. **全局 RunState 状态机**: 维护一个全局枚举 `RunState ∈ {menu, loading, playing, paused, breakthrough, dying, dead, victory, abandoned}`。所有 gameplay 系统订阅 `run_state_changed(new_state)` 信号决定自身行为。
2. **状态切换是单向广播**: Run/Session 不主动停止或启动其他系统——它发出状态信号,各系统自行响应。但 Run/Session 控制 `SceneTree.paused`(对所有标记为 PROCESS_MODE_PAUSABLE 的节点生效)。
3. **Run 数据快照**: 维护本局的 `RunData` 结构体,包含:
   - `start_time_ms: int` (本局开始时间戳)
   - `current_realm: int` (1-6, 来自 Realm Progression 信号)
   - `bosses_defeated: Array[int]` (本局击败的 BOSS ID)
   - `techniques_acquired: Array[int]` (本局获取的功法 ID)
   - `enemies_killed: int`
   - `total_damage_dealt: float`
   - `total_damage_taken: float`
   - `total_spirit_collected: float`
4. **暂停的范围**: `paused` 状态下 `SceneTree.paused = true`,所有 PAUSABLE 节点冻结。但**菜单 UI 必须可交互**(`PROCESS_MODE_ALWAYS`)。Camera 已锁定 frozen 行为,PC 已锁定 immobile 行为——本系统只是开关。
5. **死亡序列**: `entity_died(player)` 信号触发后:
   - 立即切换到 `dying` 状态(art-bible 0.4s 快速脱色期间,gameplay 仍跑但 Audio Manager 已开始死亡音过渡)
   - 0.4s 后切换到 `dead` 状态(`SceneTree.paused = true` 但死亡画面 UI 可交互)
   - art-bible 800ms 黑场 + "殁"字仪式期间不接受任何输入(`pause` 也被截断)
   - 800ms 后死亡画面 UI 出现,接受"重来"/"回主菜单"/"观看回放"输入
6. **胜利序列**: Realm Progression 报告飞升完成时,切换到 `victory` 状态。播放飞升仪式(由 VFX 处理),然后进入结算屏。
7. **场景转换协调**: `start_new_run()` → `loading` → 实例化战斗场景 → `playing`。`return_to_menu()` → 卸载战斗场景 → `menu`。**场景切换使用 art-bible Section 7.5 "墨色横扫转场" 300ms 覆盖 + 200ms 消散**。
8. **暂停期间禁止 Run 数据写入**: `paused`/`breakthrough`/`dying`/`dead`/`victory` 期间,gameplay 系统**禁止**修改 RunData 字段(由 RunData 本身的 setter 守卫)。这保证统计数据在状态切换时是稳定的。
9. **Meta-Progression 仅在 dead/victory 状态写存档**: 局结束时(进入 dead 或 victory),Run/Session emit `run_ended(RunData)` 信号供 Meta-Progression 消费。**Meta-Progression 决定写哪些字段**(本系统不管)。
10. **浏览器后台自动暂停**: 监听 Web `visibilitychange` 事件,标签隐藏 → 立即切换到 paused 状态。返回标签 → 显示恢复 UI(玩家确认后切回 playing,避免突然恢复战斗)。

### States and Transitions

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **menu** | 主菜单,gameplay 系统未实例化 | 启动游戏 / `return_to_menu()` 调用 | 玩家点击"开始" |
| **loading** | 实例化战斗场景,展示加载 UI | `start_new_run()` 调用 | 资源加载完成 (≤2s 软目标) |
| **playing** | 正常 gameplay,所有系统活跃 | loading 结束 / paused 取消 / breakthrough 结束 | pause 输入 / 突破触发 / 玩家死亡 / 飞升 |
| **paused** | SceneTree 冻结,暂停菜单可交互 | playing 中 `pause` 输入 / 浏览器后台 | 玩家点击"恢复" / `return_to_menu()` |
| **breakthrough** | 突破仪式期间,Realm Progression 控制流程 | Realm Progression 报告突破开始 | 突破仪式结束(art-bible 1200ms) |
| **dying** | 死亡仪式开始,art-bible 0.4s 脱色阶段 | `entity_died(player)` 信号 | 0.4s 后自动切换 |
| **dead** | 死亡画面显示,art-bible 800ms 黑场 + "殁"字 + 结算 | dying 结束 | 玩家点击"重来"/"回主菜单"/"观看回放" |
| **victory** | 飞升仪式完成,展示通关画面 | Realm Progression 报告飞升 | 玩家点击"继续"返回菜单 |
| **abandoned** | 玩家主动放弃当前局 | paused 中点击"回主菜单" | 自动切换到 menu |

**状态优先级与转换约束**:
- `dying` → `dead` 转换是**强制**的(0.4s 计时器,无法被打断)
- `breakthrough` 期间收到 `entity_died(player)`:**被丢弃**(immobile 状态保护,理论上不会发生,art-bible Section 2 已锁定)
- `paused` 期间收到 `entity_died(player)`:**进入队列,恢复时立即处理**(罕见,但安全)
- `dead`/`victory` 状态**不会**自动回到 menu,必须玩家主动操作
- 任何状态下 `quit_game()` 调用立即返回 menu(开发/紧急用)

### Interactions with Other Systems

**上游(发送事件给 Run/Session):**

| 上游 | 接口 | 方向 |
|------|------|------|
| **Damage/Health System** | 订阅 `entity_died(victim_id)`,if victim==player 触发 dying 状态 | 信号驱动 |
| **Realm Progression** | 调 `Run.notify_breakthrough_started(new_realm)` 和 `notify_breakthrough_ended()` | API |
| **Realm Progression** | 调 `Run.notify_ascension()` 触发胜利序列 | API |
| **Input System** | 订阅 `pause` 语义动作,playing → paused 切换 | 信号驱动 |
| **Spirit/XP** | 更新 RunData.total_spirit_collected | API (`Run.update_run_stat(field, value)`) |
| **Damage System** | 更新 RunData.total_damage_dealt/taken/enemies_killed | API |
| **Technique System** | 更新 RunData.techniques_acquired (BOSS 招式夺取时) | API |

**下游(订阅 Run/Session 信号):**

| 下游 | 接口 | 类型 |
|------|------|------|
| **Player Controller** | 订阅 `run_state_changed`,paused/dying/dead/breakthrough 时调 `set_immobile(true)`;playing 恢复时 `set_immobile(false)` | 信号 |
| **Camera System** | 订阅 `run_state_changed`,paused/dying/dead/breakthrough/victory 时调 `Camera.freeze()`;playing 时 `unfreeze()` | 信号 |
| **Enemy Spawner** | 订阅 `run_state_changed`,非 playing 状态停止生成新敌人 | 信号 |
| **Enemy AI** | 订阅 `run_state_changed`,paused/dying 等状态停止 AI tick | 信号 |
| **Boss AI** | 同上 | 信号 |
| **Audio Manager** | 订阅 `run_state_changed` 切换 BGM(menu/playing/death/victory 各自音轨) | 信号 |
| **HUD** | 订阅 `run_state_changed` 决定显示哪个 UI 层(战斗 HUD/暂停菜单/死亡画面/胜利画面) | 信号 |
| **Meta-Progression** | 订阅 `run_ended(RunData)` 写入持久化进度 | 信号 |

**Godot 信号契约:**
- `run_state_changed(old_state: RunState, new_state: RunState)` — 状态变化时
- `run_started(run_id: int)` — 新局开始时(run_id 用于区分 session)
- `run_ended(run_data: RunData)` — 局结束时(进入 dead/victory)
- `run_paused(reason: String)` — 暂停时,reason ∈ {"player", "browser_hidden"}
- `run_resumed()` — 恢复时
- `breakthrough_started(new_realm: int)` — 突破开始
- `breakthrough_ended(realm: int)` — 突破结束

> **Note**: Specialist agents not consulted at Section C — Lean mode. 上下文约束(art-bible + 4 个已设计 GDD)已足够。

## Formulas

> **Note**: Run/Session 主要是状态机和事件协调,几乎不涉及数学公式。本节列出**时长常数**和**统计计算**——它们在 Tuning Knobs 中可调整,但每个有明确范围和理由。

---

### Formula 1: 死亡仪式总时长(art-bible 锁定)

```
death_ritual_total_ms = T_decolor + T_blackfade + T_seal_appear + T_min_wait
                      = 400 + 800 + 500 + 300
                      = 2000 ms
```

**Variables:**

| Variable | Type | Value | Description |
|----------|------|-------|-------------|
| `T_decolor` | int | 400 ms (locked) | art-bible Section 2 快速脱色阶段 |
| `T_blackfade` | int | 800 ms (locked) | art-bible Section 2 黑场淡入 |
| `T_seal_appear` | int | 500 ms | "殁"字篆书缩放出现(60% → 100%) |
| `T_min_wait` | int | 300 ms | 最小输入冻结期(避免误触"重来") |

**Output Range**: 固定 2000 ms 不可跳过。死亡画面 UI 在 t=2000ms 后可交互。

**Rationale**: art-bible Section 7.5 已锁定死亡仪式不可跳过。`T_min_wait` 300ms 是防止玩家在仪式刚结束的"殁"字出现瞬间误触"重来"按钮——给玩家 300ms 看清结算数据。

---

### Formula 2: 突破仪式总时长(art-bible Section 7.5 锁定)

```
breakthrough_ritual_total_ms = T_slowdown + T_inkbloom + T_seal_appear + T_description + T_disperse
                             = 200 + 300 + 300 + 300 + 100
                             = 1200 ms
```

**Variables:**

| Variable | Type | Value | Description |
|----------|------|-------|-------------|
| `T_slowdown` | int | 200 ms | 游戏世界缓速至 30% + HUD 淡出 |
| `T_inkbloom` | int | 300 ms | 中心向外水墨晕染扩散覆盖全屏黑 |
| `T_seal_appear` | int | 300 ms | 新境界名朱砂篆书缩放(60% → 100%) |
| `T_description` | int | 300 ms | 楷书小字浮现境界描述 |
| `T_disperse` | int | 100 ms | 墨色消散返回游戏世界,HUD 淡入 |

**Output Range**: 固定 1200 ms 不可跳过(art-bible 硬约束)。

**Rationale**: 在突破期间,Run/Session 处于 `breakthrough` 状态,Enemy Spawner/Enemy AI/Boss AI 全部停止。PC immobile。Camera frozen 在 zoomed_breakthrough 状态。

---

### Formula 3: 浏览器后台暂停的恢复确认时长

```
resume_confirm_delay_ms = 500
```

**Variables:**

| Variable | Type | Value | Description |
|----------|------|-------|-------------|
| `resume_confirm_delay_ms` | int | 500 ms | 玩家点击"恢复"后,gameplay 真正恢复的延迟 |

**Output Range**: 500ms 倒计时 UI(显示 "3-2-1"或类似指示),然后 paused → playing。

**Rationale**: Web 端玩家切回标签时,可能正在打字或操作其他东西。给 500ms 缓冲避免"立刻被弹幕击中"。

---

### Formula 4: 局时长计算(统计用)

```
run_duration_ms = current_time_ms - run_data.start_time_ms - paused_total_ms

其中 paused_total_ms 是本局累计暂停时长(每次进入 paused 状态时累计)
```

**Variables:**

| Variable | Type | Range | Description |
|----------|------|-------|-------------|
| `start_time_ms` | int | unix timestamp | 本局开始时间 |
| `paused_total_ms` | int | ≥0 | 累计暂停时长 |
| `current_time_ms` | int | unix timestamp | 当前时间 |
| `run_duration_ms` | int | [0, 40 min ≈ 2.4M ms] | 局实际游戏时长 |

**Output Range**: 正常一局 ≤ 40 分钟。死亡画面显示此值作为"坚持时长"。

**Rationale**: 排除暂停时长,只统计实际游戏时间——更公平,且符合玩家直觉("我玩了 25 分钟,不是我开着游戏挂机 2 小时")。

---

### Formula 5: 加载场景的软超时

```
scene_load_timeout_ms = 5000   # 加载场景超过 5s 触发错误处理
scene_load_soft_target_ms = 2000  # 目标值
```

**Rationale**:
- 2s 软目标:Web 平台首次加载可能稍慢,但同 session 后续加载应已缓存
- 5s 硬超时:超过 5s 显示错误提示并提供"重试"/"回主菜单"选项

> **Note**: Run/Session 的"公式"实际上是**时长常量 + 统计计算**。没有玩家可感知的伤害/速度/HP 类数值。systems-designer not consulted — Lean mode 决策(此 Section D 含义不同于其他 GDD 的数值公式,不适合 spawn)。

## Edge Cases

- **If 浏览器标签隐藏(visibilitychange)**: 立即切换到 paused 状态,显示"游戏已暂停,因为您切换了标签"。返回前台时显示"恢复"按钮(不自动恢复,避免突然被攻击)。
- **If 浏览器在 dying 状态时隐藏**: 当前 dying 是 0.4s 自动过渡,无法暂停。允许过渡完成进入 dead,然后死亡画面 UI 等待玩家返回。
- **If 浏览器在 breakthrough 仪式期间隐藏**: 突破仪式同样不可暂停(art-bible 锁定不可跳过 = 不可中断)。允许仪式完成,然后切换到 paused。
- **If 玩家在 dead 状态关闭浏览器**: 本局 RunData 已通过 `run_ended` 信号写入 Meta-Progression(在 dying → dead 过渡时触发)。无数据丢失。
- **If localStorage 写入失败(配额满或浏览器禁用)**: Meta-Progression 应处理这个错误,Run/Session 只保证发出 `run_ended` 信号。如果存档失败,Meta-Progression 通知玩家"本局进度未保存"——这是 Meta-Progression GDD 的责任。
- **If 玩家在主菜单点击多次"开始"**: state machine 锁定,从 menu → loading 是单向转换。重复点击在 loading 期间无效(按钮 disable)。
- **If 同帧收到 entity_died(player) 和 ascension 信号**: ascension 优先(victory 优于 dying)。这是设计内 — 飞升瞬间玩家不应该死亡。
- **If 暂停期间玩家死亡延迟到达**: paused 期间收到 entity_died 进入队列。恢复 (playing) 时立即处理,触发 dying。这种场景罕见,但确保数据不丢失。
- **If 死亡画面期间玩家点击多次"重来"**: 第一次点击立即切换到 loading 状态(开始新局)。后续点击在 loading 期间被忽略(按钮 disable)。
- **If RunData 字段在 dead 状态被外部修改(违反 Core Rule 8)**: setter 守卫拒绝并 emit warning 日志。统计数据保持稳定。
- **If 玩家在突破仪式期间按下 pause 输入**: Input GDD 已锁定 pause 事件被 PauseManager(本系统的暂停管理子模块)截断——breakthrough 状态下 pause 输入被忽略,**不会切换到 paused**。
- **If 加载场景超时(>5s)**: 显示错误 UI + "重试"/"回主菜单"选项。错误日志记录原因(资源未找到/网络慢/解析失败)。
- **If 玩家在 victory 状态等待 10 分钟**: 没有自动转换。Victory 画面持续显示直到玩家主动操作。

## Dependencies

### Upstream

| 上游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **Save System** | Hard | 读取上次的 settings 和 meta progression(初始化时) | 未设计 |
| **Damage/Health System** | Hard | 订阅 `entity_died(player)` 触发 dying 状态 | 已设计 |
| **Input System** | Hard | 订阅 `pause` 语义动作 | 已设计 |
| **Realm Progression** | Hard | `notify_breakthrough_started/ended/ascension` API | 未设计 |
| **Godot 4.6 SceneTree** | Hard | `paused` 属性、`reload_current_scene()` | 引擎核心 |
| **Web visibilitychange** | Hard | 浏览器标签可见性事件 | 平台核心 |

### Downstream

| 下游 | 硬/软 | 接口 | 备注 |
|------|------|------|------|
| **Player Controller** | Hard | 订阅 `run_state_changed`,管理 immobile | 已设计 |
| **Camera System** | Hard | 订阅 `run_state_changed`,管理 freeze | 已设计 |
| **Enemy Spawner** | Hard | 订阅 `run_state_changed`,非 playing 停止生成 | 未设计 |
| **Enemy AI** | Hard | 同上,停止 tick | 未设计 |
| **Boss AI** | Hard | 同上 | 未设计 |
| **Audio Manager** | Hard | 切换 BGM | 未设计 |
| **HUD** | Hard | 决定显示 UI 层 | 未设计 |
| **Meta-Progression** | Hard | 订阅 `run_ended(RunData)` 写存档 | 未设计 |
| **VFX System** | Soft | 订阅 `breakthrough_started` 触发清场脉冲 | 未设计 |

### External

- Godot 4.6 `SceneTree.paused` 全局暂停
- Godot 4.6 `process_mode` (PROCESS_MODE_PAUSABLE / ALWAYS / INHERIT)
- Web JavaScript bridge: `document.visibilityState` 监听

### Forbidden

- 其他系统**禁止**直接修改 `RunState` 全局枚举(必须走 Run/Session 暴露的 API)
- 其他系统**禁止**直接调用 `SceneTree.paused = true/false`(必须由 Run/Session 协调)
- 其他系统**禁止**在 dead/victory 状态写入 RunData(setter 守卫)
- Run/Session **禁止**包含任何 gameplay 逻辑(伤害/移动/AI 等)——它只是调度器

## Tuning Knobs

| 参数 | 默认值 | 安全范围 | 影响 | 异常行为 |
|------|--------|----------|------|----------|
| `DEATH_RITUAL_TOTAL_MS` | 2000 | art-bible 锁定,不可调 | F1 死亡仪式总时长 | 修改 = 违反 art-bible 契约 |
| `T_DECOLOR_MS` | 400 | [300, 600] | F1 死亡脱色阶段 | 过短=突兀;过长=拖沓 |
| `T_BLACKFADE_MS` | 800 | [600, 1200] | F1 黑场淡入 | 过短=情绪不足;过长=玩家烦躁 |
| `T_SEAL_APPEAR_MS` | 500 | [300, 800] | F1 殁字浮现 | 关键仪式感参数 |
| `T_MIN_WAIT_MS` | 300 | [200, 500] | F1 死亡画面 UI 出现后的输入冻结 | 过低=误触重来;过高=玩家急躁 |
| `BREAKTHROUGH_RITUAL_TOTAL_MS` | 1200 | art-bible 锁定 | F2 突破仪式 | 同 DEATH_RITUAL |
| `RESUME_CONFIRM_DELAY_MS` | 500 | [200, 1500] | F3 浏览器后台恢复后的倒计时 | 过低=被秒;过高=烦躁 |
| `SCENE_LOAD_TIMEOUT_MS` | 5000 | [3000, 10000] | F5 加载超时 | 过低=正常加载误判失败 |
| `SCENE_TRANSITION_INK_SWEEP_MS` | 300+200 | [200+150, 500+300] | art-bible Section 7.5 墨扫转场 | 与 art-bible 协调 |

**Knob 交互**:
- 所有"art-bible 锁定"的 knob 在调整时必须与 art-director 协商
- `DEATH_RITUAL_TOTAL_MS` 的子段(T_decolor, T_blackfade 等)必须加起来 = 总长度 - T_min_wait

**调优优先级**:
- **Tier 1**(用户感知关键): RESUME_CONFIRM_DELAY_MS, SCENE_LOAD_TIMEOUT_MS
- **Tier 2**(仪式感): T_DECOLOR_MS, T_BLACKFADE_MS, T_SEAL_APPEAR_MS — 需 playtest
- **Tier 3**(技术参数): SCENE_TRANSITION_INK_SWEEP_MS

## Visual/Audio Requirements

### Visual(VFX/HUD 系统响应 Run 状态信号)

**死亡仪式**(art-bible Section 2 锁定,Run 触发):
- t=0: dying 开始,屏幕色温脱色至灰阶 (0.4s)
- t=400ms: 进入 dead,art-bible Section 7.5 黑底淡入开始 (800ms)
- t=1200ms: 中央朱砂篆字"殁"/"归"浮现(60% → 100% 缩放,500ms)
- t=1700ms: 楷书小字浮现本局战绩(坚持时长/敌人数/解锁功法)
- t=2000ms: "重来"/"回主菜单"/"观看回放" 三按钮可交互

**胜利仪式**:
- art-bible Section 2 描述了大乘期"流光"和飞升的视觉处理,Realm Progression 控制 0-1200ms 的过渡
- Run/Session 在飞升过渡完成后切换到 victory 状态,显示通关画面(MVP 简单:大字"飞升 · 通关"+ 战绩 + 继续按钮)

**暂停画面**:
- 背景: 当前 gameplay 画面降至 α=0.3 + 灰度处理
- 暂停菜单 UI: art-bible Section 7.2 描述的"宣纸边矩形模态"
- 浏览器后台恢复时:覆盖一个倒计时 UI"3-2-1"

**场景转换**(art-bible Section 7.5 锁定):
- "墨色横扫转场":一道浓墨从右至左横扫覆盖屏幕 300ms,覆盖完成瞬间切换内容,墨色再从左至右消散 200ms
- 应用于:menu→loading, loading→playing, dead→menu, victory→menu, paused→menu(放弃)

### Audio(Audio Manager 响应 Run 状态信号)

| RunState | Audio 行为 |
|----------|------------|
| menu | 主菜单 BGM(舒缓修仙氛围) |
| playing | 战斗 BGM(按境界切换音轨) |
| paused | 当前 BGM 音量降至 -12dB |
| breakthrough | 突破仪式音(1200ms 三段) |
| dying | 0.4s 内 BGM 快速衰减到 silence |
| dead | 死亡仪式音(800ms 黑场 + 篆字音效) |
| victory | 飞升音 + 完整 BGM 高潮 |

> **📌 Asset Spec** — Visual/Audio requirements 已定义。在 art-bible approved 后,运行 `/asset-spec system:run-session-management` 产出 per-state audio cue 规格。

## UI Requirements

**Run/Session 协调以下 UI 的显示/隐藏**(由 HUD 系统实际渲染):

| RunState | 显示 UI |
|----------|---------|
| menu | 主菜单(art-bible Section 7.2: 大尺度水墨画 + 竖排楷书菜单项) |
| loading | 加载 UI(简单进度条 + "正在飞升..."或类似文本) |
| playing | 战斗 HUD(art-bible Section 7.1 完整布局) |
| paused | 暂停菜单模态(art-bible Section 7.2: 宣纸边矩形) |
| breakthrough | 突破仪式 UI(art-bible Section 7.5 全屏特效,无标准 HUD) |
| dying | 战斗 HUD 淡出 |
| dead | 死亡画面(art-bible Section 2: 黑底+殁字+战绩+3 按钮) |
| victory | 通关画面(MVP 简单:大字+战绩+继续) |
| abandoned | 短暂过渡到 menu |

> **📌 UX Flag — Run/Session Management**: 没有独立 UI 系统但协调 9 种 UI 状态的切换。在 Pre-Production 运行 `/ux-design` 时,**为每个 RunState 设计独立的 UX 规范文件**(menu, loading, paused, dead, victory 至少 5 个)。

## Acceptance Criteria

> All AC follow GIVEN-WHEN-THEN. Time assertions allow ±1 frame (16.67ms @ 60fps). **[MVP]** = R1 跑通必需,**[VS]** = 完整体验。

### 状态机基本正确性

### AC-RUN-01 [MVP] menu → loading → playing 转换链
- **GIVEN** 玩家位于主菜单 (RunState == menu)
- **WHEN** 玩家点击"开始" → `Run.start_new_run()` 被调用
- **THEN** 状态依次切换 `menu → loading → playing`,`run_state_changed` 信号发射 2 次,`run_started(run_id)` 在进入 playing 时发射 1 次;loading ≤ 2000ms 软目标,5000ms 硬超时

### AC-RUN-02 [MVP] 暂停切换 (playing ↔ paused)
- **GIVEN** RunState==playing,场景有 PROCESS_MODE_PAUSABLE 敌人和 PROCESS_MODE_ALWAYS 暂停菜单
- **WHEN** Input System 发射 `pause` 信号
- **THEN** RunState → paused,SceneTree.paused==true,敌人 AI tick 停止,暂停菜单仍响应输入,`run_paused("player")` 发射;再次按 pause 恢复 playing,`run_resumed` 发射

### AC-RUN-03 [MVP] dying → dead 强制不可中断 (F1)
- **GIVEN** RunState==playing
- **WHEN** Damage System 发射 `entity_died(player_id)`
- **THEN** 立即进入 dying;0.4s 后强制进入 dead;期间任何输入(除 quit_game)被吞;dead 状态再持续 800ms 后死亡画面 UI 才接受输入。整个仪式 = 2000ms (F1: 400+800+500+300)。1999ms 点击"重来"→不响应;2001ms→响应

### 多系统协调

### AC-RUN-04 [MVP] run_state_changed 广播 — Player Controller 响应
- **GIVEN** PC 已订阅 `run_state_changed`, `PC.is_immobile==false`
- **WHEN** RunState 切到 paused/dying/dead/breakthrough 中任一
- **THEN** PC 在同一帧内调 `set_immobile(true)`;切回 playing 时调 `set_immobile(false)`

### AC-RUN-05 [MVP] run_state_changed 广播 — Camera 响应
- **GIVEN** Camera 已订阅 `run_state_changed`, `Camera.is_frozen==false`
- **WHEN** RunState 切到 paused/dying/dead/breakthrough/victory
- **THEN** Camera 调 `freeze()`;切回 playing 时 `unfreeze()`

### AC-RUN-06 [VS] run_state_changed 广播 — 4 下游联动
- **GIVEN** Enemy Spawner / Enemy AI / Audio Manager / HUD 均订阅 `run_state_changed`
- **WHEN** RunState 切到 paused
- **THEN** Spawner 停止生成 / Enemy AI tick==0 / Audio BGM 切换 / HUD 显示暂停层。每项独立可测

### 突破期间状态隔离

### AC-RUN-07 [MVP] breakthrough 期间 pause 输入被忽略
- **GIVEN** RunState==breakthrough (F2 1200ms 仪式中)
- **WHEN** 玩家按下 pause
- **THEN** RunState 保持 breakthrough,**不**进入 paused,无 run_paused 信号;1200ms 后正常切回 playing

### AC-RUN-08 [VS] breakthrough 期间 entity_died(player) 被丢弃
- **GIVEN** RunState==breakthrough
- **WHEN** 测试注入 `entity_died(player_id)` 信号(异常)
- **THEN** 信号被丢弃,RunState 保持 breakthrough,无 dying 转换;WARNING 日志 +1

### 浏览器后台暂停 (Core Rule 10, F3)

### AC-RUN-09 [MVP] 浏览器 visibilitychange 立即暂停
- **GIVEN** RunState==playing,运行于 Web
- **WHEN** 浏览器标签隐藏 (`document.visibilityState=="hidden"` 触发)
- **THEN** RunState 同一帧内切到 paused,`run_paused("browser_hidden")` 发射,**reason 字段必须 "browser_hidden" 非 "player"**

### AC-RUN-10 [MVP] 前台恢复需 RESUME_CONFIRM_DELAY 倒计时 (F3=500ms)
- **GIVEN** RunState==paused, reason=="browser_hidden"
- **WHEN** 浏览器标签恢复
- **THEN** 显示恢复确认 UI,**不**自动 → playing;玩家点击"恢复"后倒计时 500ms → 切到 playing 并发射 `run_resumed`。499ms 时 RunState 仍 paused,501ms 时 playing

### AC-RUN-11 [VS] 浏览器在 dying/breakthrough 期间隐藏 — 允许过渡完成
- **GIVEN** RunState==dying (死亡仪式中)
- **WHEN** 浏览器标签隐藏
- **THEN** **不立即** pause,允许 dying→dead 自然完成(0.4s),进入 dead 后才暂停;breakthrough 同理(允许 1200ms 仪式完成后暂停)

### RunData 防篡改

### AC-RUN-12 [MVP] 暂停期间 RunData 写入被拒绝
- **GIVEN** RunState ∈ {paused, breakthrough, dying, dead, victory},`RunData.enemies_killed==10`
- **WHEN** 任意 gameplay 系统调 `Run.update_run_stat("enemies_killed", 11)`
- **THEN** 写入被 setter 守卫拒绝,enemies_killed 仍==10,WARNING 日志"attempted write in state X"

### 死亡/胜利/Meta-Progression

### AC-RUN-13 [MVP] dead/victory 触发 run_ended 且不自动回 menu
- **GIVEN** RunState==playing
- **WHEN** 玩家死亡完成 2000ms 仪式 (F1) 进入 dead;或 Realm Progression 报告飞升进入 victory
- **THEN** `run_ended(RunData)` 信号发射**一次**,Meta-Progression 收到 snapshot;30 秒内 RunState 保持 dead/victory 不变,**绝不**自动切回 menu;仅玩家主动操作才转换。验证 `run_duration_ms > 0 且 == current - start - paused_total` (F4)

### 暂停期间死亡延迟

### AC-RUN-14 [VS] 暂停期间 entity_died 进队列,恢复时处理 (Edge Case)
- **GIVEN** RunState==paused
- **WHEN** Damage System 在 paused 期间发射 `entity_died(player_id)`(罕见但可能)
- **THEN** 信号进入队列,RunState 保持 paused;玩家点击"恢复" → RunState 切到 playing 同一帧,队列中的 entity_died 立即触发 dying;数据不丢失

### 场景转换/边界

### AC-RUN-15 [VS] 多次点击"开始"防抖
- **GIVEN** RunState==menu
- **WHEN** 玩家在 100ms 内连续点击"开始"按钮 5 次
- **THEN** `start_new_run()` 只执行一次(后续点击被吞);最终仅进入一次 playing,`run_started` 信号计数==1

---

### Test Evidence Classification

| AC | Type | Evidence Location |
|----|------|-------------------|
| AC-RUN-01, 02 | Integration | `tests/integration/run_session/state_transition_test.gd`, `pause_test.gd` |
| AC-RUN-03 | Logic | `tests/unit/run_session/death_ritual_test.gd` |
| AC-RUN-04, 05 | Logic | `tests/unit/run_session/{pc,camera}_response_test.gd` |
| AC-RUN-06 | Integration | `tests/integration/run_session/broadcast_test.gd` |
| AC-RUN-07, 08, 11, 12, 14 | Logic | `tests/unit/run_session/*.gd` |
| AC-RUN-09, 10 | Integration | `tests/integration/run_session/browser_pause_test.gd` + manual web-pause evidence |
| AC-RUN-13 | Integration | `tests/integration/run_session/run_ended_test.gd` |
| AC-RUN-15 | UI | `production/qa/evidence/start-debounce-[date].md` 手动 walkthrough |

**统计**: 15 AC = 10 MVP + 5 VS,**全部 BLOCKING**;14/15 自动化(93%),AC-RUN-15 手动 UI。

**Coverage**: 10 Core Rules × 9 RunState 状态转换 × 5 Formulas × 关键 Edge Cases 全覆盖。

## Open Questions

1. **加载场景的 progress 反馈**: Web 平台资源加载可能不可见(浏览器缓存命中时几乎即时;首次加载可能 1-3s)。是否需要显式进度条还是简单的"飞升..."旋转图标?**Owner**: ux-designer。**Target**: Pre-Production UX 设计阶段。

2. **本局回放(观看回放按钮)**: 死亡画面 art-bible Section 2 提到 3 按钮"重来/回主菜单/观看回放",但回放系统未列入 systems-index。是否 MVP 实现?**Owner**: game-designer + producer。**Target**: MVP 边界决定 — 建议**推迟到 VS 阶段**,MVP 死亡画面仅 2 按钮。

3. **多次开始/重来的输入防抖窗口**: AC-RUN-15 定义了 100ms 防抖,但实际 Web 平台可能有触屏长按事件。是否需要更长的防抖窗口?**Owner**: gameplay-programmer。**Target**: 实测后调整。

4. **Web 关闭浏览器的数据保存**: 玩家在 playing 中直接关闭浏览器(不通过菜单),`run_ended` 不会触发,本局进度丢失。是否需要 periodic save(每 30s 自动写存档)?或者认为 Roguelite 本身允许这种丢失?**Owner**: game-designer + producer。**Target**: Meta-Progression GDD 设计时(Order #18)。

5. **victory 状态下是否允许继续 playing**: 飞升通关后是否进入"无尽模式"?MVP 决策:**结束**,玩家点击"继续"回 menu。VS 阶段如有需求,加 "+infinity mode"。**Owner**: game-designer。**Target**: VS 设计阶段。

6. **abandoned 状态的处理**: 玩家在 paused 中点击"回主菜单"时,本局算"失败"还是"放弃"?是否触发 `run_ended` 写存档?**MVP 决策**: 触发 `run_ended(RunData with status='abandoned')`,Meta-Progression 决定是否记录。**Owner**: Meta-Progression designer。**Target**: Meta-Progression GDD 设计时。
