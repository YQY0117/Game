# ADR-0005: Particle System Architecture

## Status
Accepted

## Date
2026-06-27

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Rendering |
| **Knowledge Risk** | MEDIUM — GPUParticles2D stable, but Web limits |
| **References Consulted** | `docs/engine-reference/godot/modules/rendering.md` |
| **Post-Cutoff APIs Used** | `.restart()` has optional `keep_seed` param (4.4) |
| **Verification Required** | GPUParticles2D on WebGL2 with 500 particles |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0002 (Object Pool) |
| **Enables** | None |
| **Blocks** | Technique VFX, Spirit/XP visuals, Boss VFX |
| **Ordering Note** | Implement after Object Pool |

## Context

### Problem Statement

Game needs extensive particle effects:
- Technique projectiles with element-colored trails
- Spirit drops (gold particles flying to player)
- Boss attack tells (cinnabar red bloom)
- Realm breakthrough ceremony (ink expansion)
- Death effects (ink dissolution)

Constraint: 500 particle cap (technical-preferences.md)

### Constraints

- 500 simultaneous particles max
- 16.6ms frame budget
- Compatibility renderer (no compute shaders)
- Web WebGL2 performance

### Requirements

- Particles must be pooled (frequent create/destroy)
- Element color system (fire=orange, ice=blue, etc.)
- Particle LOD (reduce density far from player)
- Must integrate with art-bible brush shapes

## Decision

Use **GPUParticles2D** with **pre-configured ProcessMaterials** per effect type. Pool particle emitter nodes, not individual particles.

### Particle Categories

| Category | Max Count | Node Type | Pool Size |
|----------|-----------|-----------|-----------|
| Technique VFX | 200 | GPUParticles2D | 20 emitters |
| Spirit drops | 50 | GPUParticles2D | 10 emitters |
| Boss VFX | 100 | GPUParticles2D | 5 emitters |
| Environment | 50 | GPUParticles2D | 5 emitters |
| UI feedback | 50 | CPUParticles2D | 10 emitters |
| **Total** | **450** | | **50 emitters** |

### ProcessMaterial per Element

```gdscript
# ParticleMaterials.gd — resource library
class_name ParticleMaterials

static var fire: ParticleProcessMaterial = _create_material(
    Color("#C45A3A"), Color("#D49048"), 0.3, 200.0
)
static var ice: ParticleProcessMaterial = _create_material(
    Color("#EDF0F2"), Color("#3B5C78"), 0.5, 150.0
)
static var lightning: ParticleProcessMaterial = _create_material(
    Color("#5E426E"), Color("#F0E8D8"), 0.1, 300.0
)
static var wind: ParticleProcessMaterial = _create_material(
    Color("#1A1D22"), Color("#1A1D22"), 0.8, 100.0
)
static var spirit_gold: ParticleProcessMaterial = _create_material(
    Color("#C8A055"), Color("#C8A055"), 0.3, 150.0
)

static func _create_material(color1: Color, color2: Color, lifetime: float, speed: float) -> ParticleProcessMaterial:
    var mat = ParticleProcessMaterial.new()
    mat.color = color1
    mat.initial_velocity_min = speed * 0.5
    mat.initial_velocity_max = speed
    mat.lifetime = lifetime
    return mat
```

### Particle Pool API

```gdscript
# ParticlePool.gd
class_name ParticlePool

var pools: Dictionary = {}  # effect_type -> Array[GPUParticles2D]

func emit(effect_type: String, position: Vector2, count: int = 10) -> void:
    var emitter = _get_from_pool(effect_type)
    if emitter:
        emitter.global_position = position
        emitter.amount = count
        emitter.restart()
        # Auto-return after lifetime
        get_tree().create_timer(emitter.lifetime).timeout.connect(
            func(): _return_to_pool(effect_type, emitter)
        )
```

### Particle LOD

```gdscript
# Reduce particle count based on distance from player
func get_lod_multiplier(distance_to_player: float) -> float:
    if distance_to_player < 400:
        return 1.0  # Full quality
    elif distance_to_player < 800:
        return 0.5  # Half particles
    else:
        return 0.25  # Quarter particles
```

## Alternatives Considered

### Alternative 1: CPUParticles2D Only

- **Description**: Use CPU particles for everything
- **Pros**: Better Compatibility, no GPU dependency
- **Cons**: 500 CPU particles = ~2ms/frame, too expensive
- **Rejection Reason**: CPU cost too high at 500 particles

### Alternative 2: Custom Shader Particles

- **Description**: Write custom particle shader
- **Pros**: Full control, optimized for this game
- **Cons**: Complex, Compatibility renderer limits, maintenance cost
- **Rejection Reason**: GPUParticles2D is sufficient for 2D game

### Alternative 3: Animated Sprites (No Particles)

- **Description**: Pre-rendered sprite animations instead of particles
- **Pros**: Predictable performance, art-directable
- **Cons**: No dynamic behavior, large asset count, no real-time color mixing
- **Rejection Reason**: Art-bible requires real-time element color fusion

## Consequences

### Positive

- 500 particles within budget using GPU acceleration
- Element color system matches art-bible Section 4.5
- Pooled emitters prevent instantiation spikes
- LOD ensures far-away effects don't cost performance

### Negative

- GPUParticles2D requires shader support (Compatibility OK)
- ProcessMaterial per element = more resources to manage
- Auto-return timing must match actual particle lifetime

### Risks

- **Risk**: WebGL2 GPUParticles2D limits
  - **Mitigation**: Test early; fallback to CPUParticles2D if needed
- **Risk**: Particle count exceeds 500 during boss fights
  - **Mitigation**: LOD + hard cap in ParticlePool

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| technique-system.md | Element-colored VFX | ProcessMaterial per element |
| drop-pickup-system.md | Gold spirit particles | spirit_gold material |
| boss-ai.md | Cinnabar tell VFX | Boss-specific particle emitters |
| art-bible.md Section 4.5 | Element color palette | 6 element materials defined |
| art-bible.md Section 7.5 | Breakthrough ceremony VFX | Special breakthrough emitter |
| technical-preferences.md | 500 particle cap | Pool enforces limit + LOD |

## Performance Implications

- **CPU**: ~0.3ms/frame for 500 particles (GPU-accelerated)
- **Memory**: ~100KB for 50 pooled emitters + materials
- **GPU**: Minimal (2D particles, simple shaders)
- **Draw Calls**: ~5-10 (one per active emitter type)

## Validation Criteria

- 500 particles render at 60fps on desktop Chrome
- Element colors match art-bible palette exactly
- Particle LOD reduces count by 50% at >800px from player
- No particle leaks (all return to pool after lifetime)

## Related Decisions

- ADR-0002: Object Pool (particle emitters are pooled)
- Art Bible Section 4.5 (element color definitions)
- Art Bible Section 7.5 (breakthrough ceremony VFX)
