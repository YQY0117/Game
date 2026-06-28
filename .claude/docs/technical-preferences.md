# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6
- **Language**: GDScript
- **Rendering**: Compatibility (HTML5/WebGL2 兼容渲染器, 适配 Web 导出)
- **Physics**: Godot 内置 2D Physics (Survivor-like 多敌人场景下使用 Area2D + 自定义碰撞分组,避免 RigidBody2D 性能开销)

## Input & Platform

<!-- Written by /setup-engine. Read by /ux-design, /ux-review, /test-setup, /team-ui, and /dev-story -->
<!-- to scope interaction specs, test helpers, and implementation to the correct input methods. -->

- **Target Platforms**: Web (HTML5, 桌面浏览器 + 移动浏览器), 后续可扩展 Steam (PC)
- **Input Methods**: Keyboard/Mouse, Touch
- **Primary Input**: Keyboard/Mouse (桌面 Web 主要输入)
- **Gamepad Support**: Partial (HTML5 Gamepad API 可用, 但非主要输入)
- **Touch Support**: Full (移动 Web 必须支持; 虚拟摇杆 + 触屏 UI)
- **Platform Notes**:
  - 所有 UI 必须支持触屏点击和键盘/鼠标双输入, 触屏目标尺寸 ≥ 44×44px
  - 自动战斗 + 走位的轻度操作设计降低了输入精度要求, 触屏体验良好
  - Web 导出体积控制在 50MB 以下以保证浏览器加载体验
  - 不使用悬停 (hover-only) 交互, 触屏无法支持

## Naming Conventions

- **Classes**: PascalCase (e.g., `PlayerController`, `BossSpawner`, `SpiritGatherer`)
- **Variables/Functions**: snake_case (e.g., `move_speed`, `take_damage()`)
- **Signals/Events**: snake_case past tense (e.g., `health_changed`, `boss_defeated`, `realm_breakthrough_triggered`)
- **Files**: snake_case matching class (e.g., `player_controller.gd`, `boss_spawner.gd`)
- **Scenes**: PascalCase matching root node (e.g., `PlayerController.tscn`, `BossArena.tscn`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`, `BASE_MOVE_SPEED`, `SPIRIT_GAIN_PER_KILL`)

## Performance Budgets

- **Target Framerate**: 60 fps (桌面 Web), 30 fps 最低可接受 (移动 Web 弱机)
- **Frame Budget**: 16.6 ms / frame (60fps)
- **Draw Calls**: ≤ 200 / frame (Web 浏览器 WebGL 上限考虑; 用 MultiMeshInstance2D 批量渲染敌人和粒子)
- **Memory Ceiling**: 256 MB (浏览器堆内存, Web 平台关键约束)
- **Particle Cap**: ≤ 500 同屏粒子 (功法特效满屏时, 使用对象池 + 粒子数量动态调节)
- **Enemy Cap**: ≤ 200 同屏敌人 (Survivor-like 高密度战斗)

## Testing

- **Framework**: GUT (Godot Unit Test) — Godot 4.6 生态成熟, 支持 CI/CD headless 运行
- **Minimum Coverage**: 70% for 核心系统 (功法公式、境界突破、灵气收集)
- **Required Tests**: 平衡公式 (功法伤害、combo 系数、境界跃迁数值), 游戏系统 (BOSS 状态机、走位输入处理), Web 导出兼容性 (浏览器手动测试)

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [None configured yet — add as architectural decisions are made]

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- [None configured yet — add as dependencies are approved]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]

## Engine Specialists

<!-- Written by /setup-engine when engine is configured. -->
<!-- Read by /code-review, /architecture-decision, /architecture-review, and team skills -->
<!-- to know which specialist to spawn for engine-specific validation. -->

- **Primary**: godot-specialist
- **Language/Code Specialist**: godot-gdscript-specialist (all .gd files)
- **Shader Specialist**: godot-shader-specialist (.gdshader files, VisualShader resources)
- **UI Specialist**: godot-specialist (no dedicated UI specialist — primary covers all UI)
- **Additional Specialists**: godot-gdextension-specialist (GDExtension / native C++ bindings only)
- **Routing Notes**: Invoke primary for architecture decisions, ADR validation, and cross-cutting code review. Invoke GDScript specialist for code quality, signal architecture, static typing enforcement, and GDScript idioms. Invoke shader specialist for material design and shader code. Invoke GDExtension specialist only when native extensions are involved.

### File Extension Routing

<!-- Skills use this table to select the right specialist per file type. -->
<!-- If a row says [TO BE CONFIGURED], fall back to Primary for that file type. -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (.gd files) | godot-gdscript-specialist |
| Shader / material files (.gdshader, VisualShader) | godot-shader-specialist |
| UI / screen files (Control nodes, CanvasLayer) | godot-specialist |
| Scene / prefab / level files (.tscn, .tres) | godot-specialist |
| Native extension / plugin files (.gdextension, C++) | godot-gdextension-specialist |
| General architecture review | godot-specialist |
