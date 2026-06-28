# ADR-0003: Scene Management

## Status
Accepted

## Date
2026-06-27

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core |
| **Knowledge Risk** | LOW |
| **References Consulted** | None (scene management is stable) |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Event Bus — Autoload persistence) |
| **Enables** | ADR-0005 (Particle System) |
| **Blocks** | Run/Session Management, Menu System |
| **Ordering Note** | Must be decided before Run/Session implementation |

## Context

### Problem Statement

Game has two main scene contexts:
1. **Menu scene** — main menu, settings, technique compendium
2. **Battle scene** — actual gameplay with 150+ entities

Transitions between them must:
- Preserve Autoload state (DamageBus, RunSession)
- Unload all battle entities cleanly
- Play art-bible "ink sweep" transition (300ms cover + 200ms dissipate)
- Not cause memory spikes

### Constraints

- Web platform: scene loading must be fast (<2s target)
- Autoloads persist across scenes (Godot default behavior)
- 50MB total package (no lazy loading in MVP)

### Requirements

- Menu -> Battle: load battle scene, initialize all pools
- Battle -> Menu: unload battle scene, return all pooled entities
- Scene transitions use art-bible ink sweep animation
- Run/Session state machine drives transitions

## Decision

Use **Godot's built-in scene tree** with **SceneManager Autoload** for transitions.

### Scene Structure

```
/Main (Node2D) — persistent root
├── Autoloads (always present)
│   ├── DamageBus
│   ├── RunSession
│   ├── SceneManager
│   └── InputSystem
├── CurrentScene (Node2D) — swapped per context
│   ├── MenuScene.tscn (when in menu)
│   └── BattleScene.tscn (when in battle)
```

### SceneManager API

```gdscript
# SceneManager.gd — Autoload
class_name SceneManager

signal transition_started()
signal transition_completed()

func change_scene(scene_path: String, transition: String = "ink_sweep") -> void:
    # 1. Emit transition_started
    transition_started.emit()
    # 2. Play ink sweep cover (300ms)
    await _play_transition_cover(transition)
    # 3. Swap scene
    get_tree().change_scene_to_file(scene_path)
    # 4. Play ink sweep dissipate (200ms)
    await _play_transition_dissipate(transition)
    # 5. Emit transition_completed
    transition_completed.emit()
```

### Battle Scene Initialization

```gdscript
# BattleScene.gd — attached to BattleScene.tscn root
func _ready() -> void:
    # Initialize object pools
    EnemyPool.initialize(100, 200)
    ProjectilePool.initialize(50, 100)
    ParticlePool.initialize(100, 200)
    # Notify RunSession
    RunSession.set_run_state(RunSession.RunState.PLAYING)
```

### Battle Scene Cleanup

```gdscript
func _exit_tree() -> void:
    # Return all pooled entities
    EnemyPool.return_all()
    ProjectilePool.return_all()
    ParticlePool.return_all()
    # Disconnect all signals
    # (pool handles this internally)
```

## Alternatives Considered

### Alternative 1: Single Scene with State Switching

- **Description**: Keep one scene, show/hide menu vs battle nodes
- **Pros**: No scene loading, instant transitions
- **Cons**: All battle entities in memory during menu; complex state management
- **Rejection Reason**: Memory waste; battle entities should not exist in menu

### Alternative 2: Resource Threaded Loading

- **Description**: Load battle scene in background thread
- **Pros**: No loading screen
- **Cons**: Web platform threading limited; complex error handling
- **Rejection Reason**: MVP scope; 50MB package loads fast enough without threading

## Consequences

### Positive

- Clean separation of menu and battle state
- Autoloads persist automatically (Godot feature)
- Scene tree handles memory management
- Simple implementation

### Negative

- Scene change causes brief pause (~100-200ms)
- Must ensure all signals disconnected before scene change
- Object pools must be re-initialized per scene

### Risks

- **Risk**: Signal disconnection missed -> memory leak
  - **Mitigation**: Pools handle cleanup in _exit_tree
- **Risk**: Scene change pause visible to player
  - **Mitigation**: Ink sweep animation covers the pause

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| run-session-management.md | Scene transitions use ink sweep | SceneManager.change_scene with transition param |
| run-session-management.md | Autoloads persist | Godot default behavior |
| run-session-management.md | start_new_run() / return_to_menu() | SceneManager.change_scene to battle/menu |
| hud.md | HUD on separate CanvasLayer | Battle scene has HUD CanvasLayer |

## Performance Implications

- **CPU**: Scene change ~100-200ms one-time cost
- **Memory**: Battle scene ~50MB loaded; menu scene ~5MB
- **Load Time**: Scene load <2s on 4G (50MB package)
- **Network**: N/A

## Validation Criteria

- Menu -> Battle transition completes in <2s
- Battle -> Menu returns all memory (no leaks)
- Ink sweep animation plays smoothly during transition
- Autoload state preserved after 10 menu<->battle transitions

## Related Decisions

- ADR-0001: Event Bus (Autoload persistence)
- ADR-0002: Object Pool (pool initialization per scene)
