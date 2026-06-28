# ADR-0002: Object Pool Strategy

## Status
Accepted

## Date
2026-06-27

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core / Rendering |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/modules/rendering.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | MultiMeshInstance2D behavior with pooled entities |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Event Bus) |
| **Enables** | ADR-0004 (MultiMesh Rendering) |
| **Blocks** | Enemy Spawner, Technique System, Drop/Pickup |
| **Ordering Note** | Must be decided before Feature layer implementation |

## Context

### Problem Statement

Survivor-like game needs 150+ simultaneous enemies, projectiles, and particles. Godot's default `instance()`/`free()` pattern causes:
- Frame spikes from instantiation
- Memory fragmentation from repeated allocation
- GC pressure on Web platform

### Constraints

- 150+ enemies on screen (art-bible Section 5.3)
- 500+ particles on screen (technical-preferences.md)
- 16.6ms frame budget
- Web platform memory limit 256MB

### Requirements

- Enemies must be reusable without instantiation/free cycles
- Projectiles must be pooled (Technique System fires frequently)
- Particles must be pooled (spirit drops, VFX)
- Pool must handle signal cleanup on return-to-pool

## Decision

Use **pre-allocated object pools** for all frequently created/destroyed entities.

### Pool Categories

| Category | Initial Size | Max Size | Entity Type |
|----------|-------------|----------|-------------|
| Enemy Pool | 100 | 200 | CharacterBody2D |
| Projectile Pool | 50 | 100 | Area2D |
| Particle Pool | 100 | 200 | Node2D + GPUParticles2D |

### Pool API

```gdscript
# ObjectPool.gd — reusable template
class_name ObjectPool

var pool: Array[Node] = []
var pool_size: int = 0
var max_size: int = 0

func get_instance() -> Node:
    if pool.size() > 0:
        var instance = pool.pop_back()
        instance.visible = true
        instance.set_process(true)
        return instance
    elif pool_size < max_size:
        # Create new if under max
        pool_size += 1
        return _create_new()
    else:
        return null  # Pool exhausted

func return_instance(instance: Node) -> void:
    # Disconnect signals to prevent leaks
    _disconnect_all_signals(instance)
    instance.visible = false
    instance.set_process(false)
    instance.global_position = Vector2(-9999, -9999)  # Off-screen
    pool.push_back(instance)
```

### Signal Cleanup on Return-to-Pool

Critical: When an enemy returns to pool, all signals from DamageBus must be disconnected:

```gdscript
func _disconnect_all_signals(instance: Node) -> void:
    DamageBus.damage_dealt.disconnect(instance._on_damage_dealt)
    DamageBus.entity_died.disconnect(instance._on_entity_died)
    RunSession.run_state_changed.disconnect(instance._on_run_state_changed)
```

## Alternatives Considered

### Alternative 1: Instance/Free per Spawn

- **Description**: Standard Godot pattern, create and destroy nodes each time
- **Pros**: Simple, no pool management
- **Cons**: Frame spikes, memory fragmentation, Web GC pauses
- **Rejection Reason**: Unacceptable performance at 150+ entities

### Alternative 2: MultiMesh Only (No Individual Nodes)

- **Description**: Render all enemies as one MultiMesh, no individual nodes
- **Pros**: Best performance, single draw call
- **Cons**: No per-enemy collision, no per-enemy AI state, no per-enemy signals
- **Rejection Reason**: Each enemy needs Area2D collision and individual AI state

## Consequences

### Positive

- No instantiation spikes during gameplay
- Predictable memory usage (pre-allocated)
- Web-friendly (less GC pressure)
- Signal cleanup prevents connection leaks

### Negative

- More complex than instance/free
- Pool size must be tuned per platform
- Max size limits entity count (must be enforced by spawner)

### Risks

- **Risk**: Pool exhaustion if max_size too low
  - **Mitigation**: Enemy Spawner checks pool availability before spawning
- **Risk**: Signal reconnection on get_instance must be correct
  - **Mitigation**: Standardized connect/disconnect pattern in pool API

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| enemy-spawner-wave-manager.md | 150+ simultaneous enemies | Enemy pool max_size=200 |
| enemy-ai.md | Enemies return to pool on death | 0.15s dying animation -> return_instance |
| technique-system.md | Projectiles fire frequently | Projectile pool max_size=100 |
| drop-pickup-system.md | Spirit particles on screen | Particle pool max_size=200 |

## Performance Implications

- **CPU**: Pool get/return is O(1), no instantiation cost
- **Memory**: Pre-allocated ~200 enemies x ~2KB = ~400KB permanent
- **Load Time**: Pool initialization ~50ms at game start
- **Network**: N/A

## Validation Criteria

- No frame spikes >16.6ms during 150-enemy spawn wave
- Memory stays under 256MB after 30-minute play session
- No signal connection leaks after 1000 spawn/return cycles

## Related Decisions

- ADR-0001: Event Bus (signal connect/disconnect patterns)
- ADR-0004: MultiMesh Rendering (rendering optimization for pooled enemies)
