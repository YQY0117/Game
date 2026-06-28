# ADR-0004: MultiMesh Rendering

## Status
Accepted

## Date
2026-06-27

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Rendering |
| **Knowledge Risk** | MEDIUM — MultiMesh API stable, but Compatibility renderer limits |
| **References Consulted** | `docs/engine-reference/godot/modules/rendering.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | MultiMeshInstance2D performance with 150+ instances on WebGL2 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0002 (Object Pool) |
| **Enables** | None |
| **Blocks** | Enemy Spawner rendering layer |
| **Ordering Note** | Implement after Object Pool is working |

## Context

### Problem Statement

150+ enemies on screen each requiring individual draw calls. Standard approach:
- 150 Sprite2D nodes = 150 draw calls
- WebGL2 typical limit: ~200 draw calls before frame drops
- Leaves only 50 draw calls for player, VFX, UI, background

### Constraints

- 150+ enemies simultaneously (art-bible Section 5.3)
- 200 draw call limit (technical-preferences.md)
- Compatibility renderer (OpenGL 3.3 / WebGL2)
- 60fps target on desktop, 30fps minimum on mobile

### Requirements

- Enemy rendering must not exceed 50 draw calls for 150 enemies
- Per-realm enemy color variation (art-bible Section 5.3)
- Enemy spawning/despawning must update efficiently
- Must work with object pool (ADR-0002)

## Decision

Use **MultiMeshInstance2D** for regular enemies (5 mob types). Keep individual Sprite2D only for bosses and elites (rare, <10 on screen).

### Rendering Strategy

| Entity Type | Count | Render Method | Draw Calls |
|-------------|-------|---------------|------------|
| Regular mobs (5 types) | 30-150 | MultiMeshInstance2D per type | 5 total |
| Elites | 0-5 | Individual Sprite2D | 0-5 |
| Bosses | 0-1 | Individual Sprite2D | 0-1 |
| Player | 1 | Individual Sprite2D | 1 |
| Projectiles | 0-100 | MultiMeshInstance2D | 1-2 |
| **Total** | | | **~10-15** |

### MultiMesh Setup per Mob Type

```gdscript
# EnemyRenderer.gd — one per mob type
extends MultiMeshInstance2D

var multimesh: MultiMesh

func _ready() -> void:
    multimesh = MultiMesh.new()
    multimesh.instance_count = 0
    multimesh.use_custom_data = true  # Per-instance color
    multimesh.mesh = _create_quad_mesh()

func update_instances(enemies: Array[EnemyData]) -> void:
    multimesh.instance_count = enemies.size()
    for i in enemies.size():
        var transform = Transform2D(0, enemies[i].position)
        multimesh.set_instance_transform_2d(i, transform)
        multimesh.set_instance_custom_data(i, enemies[i].color)
```

### Per-Instance Custom Data

Use `set_instance_custom_data()` for:
- Color tinting (realm-specific greys)
- Animation frame selection
- Damage flash (white overlay)

## Alternatives Considered

### Alternative 1: Individual Sprite2D for All

- **Description**: Standard Godot approach, one node per enemy
- **Pros**: Simple, full per-entity control
- **Cons**: 150+ draw calls, performance collapse on WebGL2
- **Rejection Reason**: Exceeds draw call budget

### Alternative 2: CanvasItem Shader + Instancing

- **Description**: Custom shader with instance uniforms
- **Pros**: Flexible, per-instance control
- **Cons**: More complex than MultiMesh; Compatibility renderer limits
- **Rejection Reason**: MultiMesh is the standard solution for this use case

### Alternative 3: Viewport Rasterization

- **Description**: Render enemies to viewport, display as texture
- **Pros**: Single draw call
- **Cons**: Resolution loss, no per-enemy collision, complex pipeline
- **Rejection Reason**: Enemies need individual Area2D collision

## Consequences

### Positive

- 150 enemies rendered in ~5 draw calls (vs 150)
- Leaves 195 draw calls for VFX, UI, background
- Per-instance color/animation via custom data
- Compatible with object pool (update instances each frame)

### Negative

- No per-enemy animation (must use shader-based animation)
- MultiMesh update cost O(n) per frame for position sync
- More complex than simple Sprite2D approach

### Risks

- **Risk**: MultiMesh update O(n) may spike at 150 enemies
  - **Mitigation**: Only update positions that changed (dirty flag)
- **Risk**: Compatibility renderer MultiMesh limits
  - **Mitigation**: Test on WebGL2 early; fallback to Sprite2D if needed

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| enemy-ai.md | 150+ entities on screen | MultiMesh handles 150 in ~5 draw calls |
| art-bible.md Section 5.3 | Per-realm color variation | Custom data for color tinting |
| art-bible.md Section 8.6 | 200 draw call limit | 150 enemies = ~5 calls |
| enemy-spawner-wave-manager.md | Enemy density scaling | MultiMesh scales linearly |

## Performance Implications

- **CPU**: MultiMesh update ~0.5ms/frame at 150 enemies
- **Memory**: MultiMesh buffer ~50KB for 150 instances
- **Draw Calls**: 5 (vs 150 without MultiMesh)
- **GPU**: Negligible (2D sprites, no complex shaders)

## Validation Criteria

- 150 enemies render at 60fps on desktop Chrome
- 150 enemies render at 30fps on mobile Chrome
- Draw calls stay under 50 during peak combat
- No visual glitches when enemies spawn/despawn

## Related Decisions

- ADR-0002: Object Pool (enemy data feeds MultiMesh)
- Art Bible Section 5.3 (mob visual rules)
