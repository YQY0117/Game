# Control Manifest

> **Engine**: Godot 4.6 (Compatibility renderer)
> **Last Updated**: 2026-06-27
> **Manifest Version**: 2026-06-27
> **ADRs Covered**: ADR-0001, ADR-0002, ADR-0003, ADR-0004, ADR-0005
> **Status**: Active — regenerate with `/create-control-manifest update` when ADRs change

---

## Foundation Layer Rules

*Applies to: scene management, event architecture, save/load, engine initialisation*

### Required Patterns

- **DamageBus 和 RunSession 必须为 Autoload 单例** — 全局可访问，跨场景持久 — source: ADR-0001
- **其他系统间通信使用 Godot 原生信号** — 1-3 个订阅者的局部信号不需要全局总线 — source: ADR-0001
- **DamageBus.deal_damage() 是唯一的伤害入口** — 所有伤害必须通过此函数，不允许直接修改 HP — source: ADR-0001
- **场景切换使用 SceneManager Autoload** — 墨色横扫转场 (300ms cover + 200ms dissipate) — source: ADR-0003

### Forbidden Approaches

- **Never 使用单一全局 EventBus** — Godot 信号限制 (~100 signals/object)，违反关注点分离 — source: ADR-0001
- **Never 绕过 DamageBus 直接修改 HP** — 破坏伤害事件一致性 — source: ADR-0001
- **Never 在场景切换时手动连接/断开信号** — Autoloads 自动持久，手动操作易出错 — source: ADR-0003

### Performance Guardrails

- **DamageBus**: 9 个下游订阅者，信号分发 O(n) — 可忽略 — source: ADR-0001
- **场景加载**: <2s (4G 网络) — source: ADR-0003

---

## Core Layer Rules

*Applies to: core gameplay loop, main player systems, physics, collision*

### Required Patterns

- **敌人、弹幕、粒子必须使用对象池** — 预分配，不允许运行时 instance()/free() — source: ADR-0002
- **返回池时必须断开所有信号连接** — 防止信号泄漏 — source: ADR-0002
- **对象池耗尽时返回 null** — 调用方必须检查，不允许强制实例化 — source: ADR-0002

### Forbidden Approaches

- **Never 在运行时使用 instance()/free() 创建/销毁敌人或弹幕** — 帧尖峰、内存碎片、Web GC 暂停 — source: ADR-0002
- **Never 跳过信号清理直接返回池** — 信号连接泄漏导致内存增长 — source: ADR-0002

### Performance Guardrails

- **敌人池**: 初始 100, 最大 200 — source: ADR-0002
- **弹幕池**: 初始 50, 最大 100 — source: ADR-0002

---

## Feature Layer Rules

*Applies to: secondary mechanics, AI systems, secondary features*

### Required Patterns

- **敌人渲染使用 MultiMeshInstance2D** — 150 敌人只需 ~5 draw calls — source: ADR-0004
- **BOSS 和精英使用独立 Sprite2D** — 数量少 (<10)，允许单独渲染 — source: ADR-0004
- **MultiMesh 使用 set_instance_custom_data() 做颜色/动画** — 每实例数据 — source: ADR-0004

### Forbidden Approaches

- **Never 用独立 Sprite2D 渲染普通杂兵** — 150+ draw calls 超出预算 — source: ADR-0004
- **Never 用 Viewport 栅格化替代 MultiMesh** — 分辨率损失，无碰撞，复杂管线 — source: ADR-0004

### Performance Guardrails

- **MultiMesh 更新**: ~0.5ms/frame @ 150 enemies — source: ADR-0004
- **Draw calls**: 杂兵 5 + 精英 5 + BOSS 1 + 玩家 1 + 弹幕 2 ≈ 14 — source: ADR-0004

---

## Presentation Layer Rules

*Applies to: rendering, audio, UI, VFX, shaders, animations*

### Required Patterns

- **粒子使用 GPUParticles2D + ProcessMaterial** — 按元素分色 (火/冰/风/雷/剑/拳) — source: ADR-0005
- **粒子发射器池化** — 池化发射器节点，不是单个粒子 — source: ADR-0005
- **粒子 LOD**: 距离 >800px 减少 50%，>1200px 减少 75% — source: ADR-0005
- **UI 使用 Trinity 色**: 宣纸白 + 墨黑 + 朱砂红 — 世界色不出现在 UI 上 — source: Art Bible

### Forbidden Approaches

- **Never 用 CPUParticles2D 渲染大量粒子** — 500 CPU 粒子 ≈ 2ms/frame，太贵 — source: ADR-0005
- **Never 用自定义着色器替代 GPUParticles2D** — 复杂度高，Compatibility 限制 — source: ADR-0005
- **Never 在 UI 上使用世界泼彩色** — UI 三色隔离 (art-bible Section 4.4) — source: Art Bible

### Performance Guardrails

- **粒子上限**: 500 同屏 — source: ADR-0005
- **粒子 CPU**: ~0.3ms/frame @ 500 particles (GPU 加速) — source: ADR-0005
- **Draw calls**: 粒子 5-10 — source: ADR-0005

---

## Global Rules (All Layers)

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `PlayerController`, `BossSpawner` |
| Variables/Functions | snake_case | `move_speed`, `take_damage()` |
| Signals/Events | snake_case past tense | `health_changed`, `boss_defeated` |
| Files | snake_case matching class | `player_controller.gd` |
| Scenes | PascalCase matching root node | `PlayerController.tscn` |
| Constants | UPPER_SNAKE_CASE | `MAX_HEALTH`, `BASE_MOVE_SPEED` |

### Performance Budgets

| Target | Value |
|--------|-------|
| Framerate | 60 fps (桌面), 30 fps 最低 (移动) |
| Frame budget | 16.6 ms / frame |
| Draw calls | ≤ 200 / frame |
| Memory ceiling | 256 MB |
| Particle cap | ≤ 500 同屏 |
| Enemy cap | ≤ 200 同屏 |

### Approved Libraries / Addons

- GdUnit4 — 测试框架
- Godot 内置 2D Physics — 不使用外部物理引擎

### Forbidden APIs (Godot 4.6)

These APIs are deprecated or unverified for Godot 4.6:

| Deprecated | Use Instead | Since |
|------------|-------------|-------|
| `TileMap` | `TileMapLayer` | 4.3 |
| `yield()` | `await signal` | 4.0 |
| `connect("signal", obj, "method")` | `signal.connect(callable)` | 4.0 |
| `instance()` | `instantiate()` | 4.0 |
| `OS.get_ticks_msec()` | `Time.get_ticks_msec()` | 4.0 |
| `Texture2D` in shaders | `Texture` base type | 4.4 |
| Manual post-process viewport chains | `Compositor` + `CompositorEffect` | 4.3 |

### Forbidden Patterns

- **Never 用 `$NodePath` in `_process()`** — 用 `@onready var` 缓存引用 — source: deprecated-apis.md
- **Never 用 untyped Array/Dictionary** — 用 `Array[Type]`, typed variables — source: deprecated-apis.md
- **Never 用 string-based connect()** — 用 typed signal connections — source: deprecated-apis.md

### Cross-Cutting Constraints

- 所有技术决策必须在 Compatibility 渲染器 + WebGL2 下验证
- 不使用 Forward+ 独有特性
- 50MB 包体限制
- 所有 UI 必须支持触屏 (44×44px 最小目标)
