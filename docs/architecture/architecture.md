# 咫尺 (Within Reach) — Master Architecture

## Document Status

| Field | Value |
|-------|-------|
| **Version** | 1.0 |
| **Last Updated** | 2026-06-27 |
| **Engine** | Godot 4.6 (Compatibility renderer) |
| **Language** | GDScript |
| **Platform** | Web (HTML5), desktop + mobile browsers |
| **GDDs Covered** | 13 MVP systems |
| **ADRs Referenced** | 0 (none yet) |
| **Technical Director Sign-Off** | Pending |
| **Lead Programmer Feasibility** | Pending |

---

## Engine Knowledge Gap Summary

| 风险 | 域 | 影响本项目? | 缓解 |
|------|-----|------------|------|
| HIGH | Jolt 默认 3D 物理 | 否（2D 游戏） | — |
| HIGH | D3D12 默认渲染 | 否（Web Compatibility） | — |
| HIGH | `@abstract` 装饰器 | 是（可选使用） | GDScript 4.5+ 新特性 |
| HIGH | UI 双焦点系统 | 是（HUD 触屏适配） | 需在 UI 实现中验证 |
| MEDIUM | Shader Baker | 是（Web 启动优化） | 可用于预编译粒子着色器 |
| LOW | 2D Physics/Rendering | 无重大变更 | 训练数据可靠 |

---

## System Layer Map

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION LAYER                                             │
│  HUD · VFX System · Audio Manager · Menu System                 │
├─────────────────────────────────────────────────────────────────┤
│  FEATURE LAYER                                                  │
│  Technique · Enemy AI · Boss AI · Spirit/XP · Enemy Spawner     │
│  Drop/Pickup · Realm Progression · Combo · Meta-Progression     │
├─────────────────────────────────────────────────────────────────┤
│  CORE LAYER                                                     │
│  Player Controller · Camera · Damage/Health · Run/Session       │
├─────────────────────────────────────────────────────────────────┤
│  FOUNDATION LAYER                                               │
│  Input System · Save System · Event Bus · Scene Manager         │
├─────────────────────────────────────────────────────────────────┤
│  PLATFORM LAYER                                                 │
│  Godot 4.6 Engine · Web Export · HTML5 APIs                     │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Assignment

| 系统 | 层级 | 原因 |
|------|------|------|
| Input System | Foundation | 所有系统的输入根，零依赖 |
| Player Controller | Core | 战斗核心，被 6+ 系统依赖 |
| Camera System | Core | 视觉反馈核心，跟随 PC |
| Damage/Health System | Core | 中枢神经，9 个下游系统 |
| Run/Session Management | Core | 全局状态机，协调所有系统 |
| Technique System | Feature | 战斗功能，依赖 Core 层 |
| Enemy AI | Feature | 敌人行为，依赖 Core 层 |
| Boss AI | Feature | BOSS 行为，依赖 Core + Feature |
| Spirit/XP System | Feature | 进度系统，依赖 Core |
| Enemy Spawner | Feature | 生成器，依赖 Feature 层 |
| Drop/Pickup | Feature | 掉落视觉，依赖 Feature |
| Realm Progression | Feature | 突破协调，依赖 Feature |
| HUD | Presentation | 信息显示，订阅所有层 |

---

## Module Ownership

### Foundation Layer

| 模块 | 拥有 | 暴露 | 消费 | Godot 节点类型 |
|------|------|------|------|----------------|
| **InputSystem** | 输入模式状态、语义动作映射 | `get_movement_vector()`, `is_action_pressed()`, `input_mode_changed` 信号 | 原始输入事件 | Autoload / Node |
| **EventBus** | 全局信号中继 | 所有跨层信号 | 各系统 emit | Autoload / Node |
| **SceneManager** | 场景加载/卸载 | `load_scene()`, `unload_scene()` | Run/Session 状态 | Autoload / Node |
| **SaveSystem** | LocalStorage 序列化 | `save()`, `load()`, `has_save()` | Meta-Progression 数据 | Autoload / Node |

### Core Layer

| 模块 | 拥有 | 暴露 | 消费 | Godot 节点类型 |
|------|------|------|------|----------------|
| **PlayerController** | 玩家位置、速度、状态机、clearance_radius | `global_position`, `current_direction`, `state_changed`, `realm_transitioned` 信号 | Input 向量, Damage 击退 | CharacterBody2D |
| **CameraSystem** | 相机跟随、震屏、微缩放 | `shake()`, `zoom_pulse()` | PC 位置, Damage 事件 | Camera2D |
| **DamageHealth** | DamageEvent 处理、HP 管理、元素相克 | `DamageBus.deal_damage()`, `damage_dealt`, `entity_died`, `hp_changed` 信号 | 各系统 DamageEvent | Node (Autoload) |
| **RunSession** | RunState 状态机、RunData 统计 | `run_state_changed`, `run_ended` 信号, `set_run_state()` | 各系统状态变更 | Node (Autoload) |

### Feature Layer

| 模块 | 拥有 | 暴露 | 消费 | Godot 节点类型 |
|------|------|------|------|----------------|
| **TechniqueSystem** | 功法定义、冷却计时器、槽位状态 | `technique_fired`, `technique_cooldown_update`, `get_equipped_elements()` | PC 位置, Damage 事件, Run 状态 | Node |
| **EnemyAI** | 敌人行为状态机、steering | `attack_started`, `hitstun_started`, `died` 信号 | PC 位置, Damage 事件, Run 状态 | CharacterBody2D (per enemy) |
| **BossAI** | BOSS 行为状态机、4 拍 Tell、攻击循环 | `boss_hp_changed`, `boss_attack_started`, `boss_died` 信号 | PC 位置, Damage 事件, Run 状态 | CharacterBody2D |
| **SpiritXP** | 灵气池、境界进度 | `spirit_changed`, `realm_breakthrough`, `spirit_absorbed` 信号 | entity_died 事件 | Node |
| **EnemySpawner** | 波次配置、生成逻辑、实体池 | `wave_changed`, `enemy_count_changed` 信号 | Run 状态, PC 位置 | Node |
| **DropPickup** | 灵气粒子实例化 | `spirit_absorbed` 信号 | entity_died 事件, Spirit 掉落量 | Node2D |
| **RealmProgression** | 突破仪式协调 | `realm_changed`, `breakthrough_started/ended` 信号 | SpiritXP 突破信号 | Node |

### Presentation Layer

| 模块 | 拥有 | 暴露 | 消费 | Godot 节点类型 |
|------|------|------|------|----------------|
| **HUD** | HUD 元素渲染 | 无（终端消费者） | SpiritXP, Technique, BossAI, Realm, Damage, Run 状态 | CanvasLayer + Control |
| **VFXSystem** | 粒子效果、视觉反馈 | `play_vfx()` | 各系统信号 | Node2D |
| **AudioManager** | 音效播放 | `play_sfx()`, `play_bgm()` | 各系统信号 | AudioStreamPlayer |

---

## Data Flow

### Flow 1: 击杀杂兵 → 灵气收集 → 境界突破

```
[Enemy] HP≤0
    │
    ▼
[DamageHealth] entity_died(id) ──────────────────────┐
    │                                                 │
    ├─→ [SpiritXP] spirit_drop(type) = 2              │
    │       │                                         │
    │       ▼                                         │
    │   [DropPickup] spawn particles at death_pos     │
    │       │                                         │
    │       ▼ (0.5s fly)                              │
    │   [SpiritXP] spirit_absorbed(pos, 2)            │
    │       │                                         │
    │       ▼                                         │
    │   [SpiritXP] current_spirit += 2                │
    │       │                                         │
    │       ▼ (if spirit >= required)                 │
    │   [SpiritXP] realm_breakthrough(R+1) ─────┐     │
    │                                           │     │
    │   [RealmProgression] ceremony start       │     │
    │       ├─→ [Technique] unlock_slot(R+1)    │     │
    │       ├─→ [PlayerController] realm_transitioned │
    │       ├─→ [Camera/World] color grade switch     │
    │       └─→ [RunSession] breakthrough state       │
    │                                                 │
    └─→ [RunSession] enemies_killed += 1              │
```

**通信方式**: 信号驱动（Godot signals），松耦合
**同步性**: 同步处理（DamageBus 同帧结算）

### Flow 2: BOSS 战 — 读招 → 输出 → 击杀 → 功法夺取

```
[EnemySpawner] wave 5 start
    │
    ▼ (2s delay)
[BossAI] spawn at 600px opposite player
    │
    ▼
[BossAI] idle → telegraph (朱砂红 1.0s) → attacking → recovery
    │                                                    │
    │ ← [Technique] projectiles hit boss ────────────────┘
    │       │
    │       ▼
    │   [DamageHealth] deal_damage(event)
    │       │
    │       ▼
    │   [BossAI] hitstun → recover → next attack cycle
    │       │
    │       ▼ (HP ≤ 0)
    │   [DamageHealth] entity_died(boss_id)
    │       │
    │       ├─→ [Technique] technique_acquired(T01)
    │       ├─→ [SpiritXP] spirit_drop(boss) = 15
    │       ├─→ [RunSession] bosses_defeated += 1
    │       └─→ [HUD] hide boss HP bar
```

### Flow 3: 玩家死亡 → 结算 → 重开

```
[DamageHealth] entity_died(player)
    │
    ▼
[RunSession] dying (0.4s) → dead (0.8s black + "殁")
    │
    ├─→ [PlayerController] set_immobile(true)
    ├─→ [Camera] freeze
    ├─→ [EnemySpawner] stop spawning
    ├─→ [EnemyAI] stop AI ticks
    ├─→ [HUD] show death screen
    │
    ▼ (player clicks "重来")
[RunSession] start_new_run()
    │
    ├─→ [SpiritXP] reset to 0
    ├─→ [Technique] clear all slots
    ├─→ [EnemySpawner] reset wave to 1
    └─→ [RunSession] loading → playing
```

### Flow 4: 帧更新路径

```
_physics_process(delta):
    [InputSystem] → get_movement_vector()
        │
        ▼
    [PlayerController] → move_and_slide()
        │
        ├─→ [Camera] follow PC position
        ├─→ [EnemyAI] read PC position for steering
        ├─→ [Technique] read PC position for fire origin
        └─→ [HUD] update HP ring position

_process(delta):
    [Technique] → update cooldowns → fire if ready
        │
        ▼
    [EnemySpawner] → check spawn timer → spawn if ready
        │
        ▼
    [BossAI] → update state machine → attack if ready
```

---

## API Boundaries

### DamageBus (核心枢纽)

```gdscript
# DamageHealth.gd — Autoload singleton
class_name DamageBus

# Entry point — ALL damage goes through here
static func deal_damage(event: DamageEvent) -> void

# Signals
signal damage_dealt(event: DamageEvent)
signal hp_changed(entity_id: int, new_hp: float, max_hp: float)
signal entity_died(entity_id: int)
signal iframe_started(entity_id: int, duration: float)
signal iframe_ended(entity_id: int)

# DamageEvent structure
class DamageEvent:
    var attacker_id: int      # -1 = environment
    var victim_id: int        # required
    var raw_damage: int       # [1, 30]
    var element: Element      # 火/冰/风/雷/剑/拳/无
    var knockback_tier: int   # 0-4
    var is_crit: bool         # VFX/Audio only, no damage multiplier
    var position: Vector2     # hit location
```

### PlayerController (位置源)

```gdscript
# PlayerController.gd — CharacterBody2D
class_name PlayerController

# Read-only for downstream
var global_position: Vector2
var current_direction: Vector2
var clearance_radius: float  # 0.5x-2.0x per realm

# Signals
signal position_changed(new_pos: Vector2)
signal velocity_changed(new_vel: Vector2)
signal state_changed(new_state: String)  # idle/running/hitstun/immobile
signal realm_transitioned(new_realm: int)

# APIs
func apply_knockback(direction: Vector2, force: float, duration: float) -> void
func teleport_to(pos: Vector2) -> void
func set_immobile(value: bool) -> void
```

### RunSession (状态广播器)

```gdscript
# RunSession.gd — Autoload singleton
class_name RunSession

enum RunState { MENU, LOADING, PLAYING, PAUSED, BREAKTHROUGH, DYING, DEAD, VICTORY, ABANDONED }

var current_state: RunState
var run_data: RunData

# Signals
signal run_state_changed(old_state: RunState, new_state: RunState)
signal run_started(run_id: int)
signal run_ended(run_data: RunData)

# APIs
func set_run_state(new_state: RunState) -> void
func start_new_run() -> void
func return_to_menu() -> void
func update_run_stat(field: String, value: Variant) -> void
```

### TechniqueSystem (功法管理)

```gdscript
# TechniqueSystem.gd — Node
class_name TechniqueSystem

# Signals
signal technique_fired(technique_id: String, position: Vector2, direction: Vector2)
signal technique_cooldown_update(technique_id: String, progress: float)
signal technique_acquired(technique_id: String)
signal technique_equipped(technique_id: String, slot_index: int)

# APIs
func get_equipped_elements() -> Array[String]
func unlock_slot(new_realm: int) -> void
```

### SpiritXP (灵气系统)

```gdscript
# SpiritXP.gd — Node
class_name SpiritXP

# Signals
signal spirit_changed(current: int, required: int)
signal realm_breakthrough(new_realm: int)
signal spirit_absorbed(position: Vector2, amount: int)

# Data
var current_spirit: int
var current_realm: int
```

---

## ADR Audit

当前无 ADR。以下决策需要 ADR 记录:

### 必须在编码前创建

| ADR | 覆盖需求 | 域 |
|-----|----------|-----|
| 事件总线架构 | DamageBus、Run/Session 信号路由 | Foundation |
| 对象池策略 | 敌人、弹幕、灵气粒子的池化管理 | Core |
| 场景管理与加载 | 战斗场景/菜单场景切换 | Foundation |
| Web 导出优化 | 50MB 限制、分包加载、性能预算 | Platform |

### 应在相关系统构建前创建

| ADR | 覆盖需求 | 域 |
|-----|----------|-----|
| MultiMesh 批量渲染 | 150+ 敌人渲染性能 | Rendering |
| 粒子系统架构 | 功法 VFX、灵气粒子的对象池 | Rendering |
| HUD CanvasLayer 分层 | Z-order、UI LUT 边界 | UI |

### 可推迟到实现阶段

| ADR | 覆盖需求 | 域 |
|-----|----------|-----|
| 着色器策略 | 境界色调 CanvasModulate vs 自定义着色器 | Rendering |
| 音频总线架构 | BGM/SFX 分层、Web 音频限制 | Audio |

---

## Architecture Principles

1. **信号驱动，松耦合**: 系统间通过 Godot signals 通信，不直接引用。DamageBus 是唯一允许的"全局信号中继"。

2. **数据所有权清晰**: 每个模块拥有自己的数据，其他模块只读或通过 API 修改。不允许跨模块直接写入状态。

3. **性能预算优先**: 150+ 同屏实体、500 粒子、200 draw calls 是硬约束。对象池、MultiMesh、LOD 是实现策略。

4. **Web 导出兼容**: 所有技术决策必须在 Godot 4.6 Compatibility 渲染器 + WebGL2 下验证。不使用 Forward+ 独有特性。

5. **渐进式实现**: Foundation → Core → Feature → Presentation 的依赖顺序。每个层级必须稳定后再构建下一层。

---

## Open Questions

| ID | 摘要 | 优先级 | 解决路径 |
|----|------|--------|----------|
| QQ-01 | Godot 4.6 Web split-pck 可行性 | High | 需 spike 验证 |
| QQ-02 | 双焦点系统对 HUD 触屏的影响 | Medium | 实现阶段验证 |
| QQ-03 | MultiMeshInstance2D 的 2D 粒子支持 | Medium | 需引擎文档确认 |
| QQ-04 | Shader Baker 在 Web 导出中的效果 | Low | 可选优化 |

---

## Required ADRs

### Foundation Layer (编码前必须)

1. **`/architecture-decision "Event Bus Architecture"`** — 定义 DamageBus、Run/Session 的信号路由策略
2. **`/architecture-decision "Object Pool Strategy"`** — 定义敌人、弹幕、粒子的池化管理方案
3. **`/architecture-decision "Scene Management"`** — 定义战斗/菜单场景切换和加载策略

### Core Layer

4. **`/architecture-decision "MultiMesh Rendering"`** — 定义 150+ 敌人的批量渲染方案

### Feature Layer

5. **`/architecture-decision "Particle System Architecture"`** — 定义功法 VFX 和灵气粒子的对象池
