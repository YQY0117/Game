# ADR-0001: Event Bus Architecture

## Status
Accepted

## Date
2026-06-27

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.6 |
| **Domain** | Core / Scripting |
| **Knowledge Risk** | LOW |
| **References Consulted** | `docs/engine-reference/godot/modules/input.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | ADR-0002, ADR-0003 |
| **Blocks** | All Feature layer systems |
| **Ordering Note** | First ADR — all others depend on it |

## Context

### Problem Statement

13 MVP systems need loose-coupling communication. Key challenges:
- Damage/Health is the hub (3 upstream + 9 downstream)
- Run/Session broadcasts global state to all systems
- Cross-layer communication must not create circular dependencies
- Web performance: 150+ entities, signals must not be bottleneck

### Constraints

- Godot 4.6 Compatibility renderer + WebGL2
- 60fps / 16.6ms frame budget
- 50MB package limit
- 150+ simultaneous entities

### Requirements

- DamageBus must process damage events synchronously (same frame)
- Run/Session state changes must broadcast to all systems
- Signal delivery must be deterministic (no race conditions)
- Must support object-pooled entities (enemies, projectiles)

## Decision

Use **Autoload singletons for global event buses**, with **Godot native signals for local communication**.

### Two Global Autoloads

1. **DamageBus** — All damage events flow through `DamageBus.deal_damage(event)`
2. **RunSession** — Global state machine, broadcasts `run_state_changed`

### Why Autoload for these two

- DamageBus has 9 downstream subscribers — connecting them manually in scene tree is error-prone
- RunSession state must be accessible from any node at any time
- Autoloads persist across scene changes (menu -> battle -> menu)
- Both are truly global — no subsystem should own them

### Native Signals for Everything Else

- TechniqueSystem emits `technique_fired` — only VFX/Audio/HUD care
- BossAI emits `boss_hp_changed` — only HUD cares
- SpiritXP emits `spirit_changed` — only HUD cares
- These are **local** signals with 1-3 subscribers — no need for global bus

### Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                  AUTOLOADS                       │
│  ┌──────────────┐    ┌──────────────┐           │
│  │  DamageBus   │    │  RunSession   │           │
│  │  (singleton) │    │  (singleton)  │           │
│  └──────┬───────┘    └──────┬───────┘           │
│         │                   │                    │
└─────────┼───────────────────┼────────────────────┘
          │                   │
    ┌─────┴─────┐       ┌─────┴─────┐
    │  signals  │       │  signals  │
    └─────┬─────┘       └─────┬─────┘
          │                   │
  ┌───────┴───────────────────┴───────┐
  │          ALL SYSTEMS              │
  │  subscribe to relevant signals    │
  └───────────────────────────────────┘

Local signals (native):
  TechniqueSystem ──technique_fired──→ VFX, Audio, HUD
  BossAI ──boss_hp_changed──→ HUD
  SpiritXP ──spirit_changed──→ HUD
```

### Key Interfaces

```gdscript
# DamageBus.gd — Autoload
class_name DamageBus
signal damage_dealt(event: DamageEvent)
signal hp_changed(entity_id: int, new_hp: float, max_hp: float)
signal entity_died(entity_id: int)

static func deal_damage(event: DamageEvent) -> void

# RunSession.gd — Autoload
class_name RunSession
enum RunState { MENU, LOADING, PLAYING, PAUSED, BREAKTHROUGH, DYING, DEAD, VICTORY }
signal run_state_changed(old_state: RunState, new_state: RunState)
signal run_ended(run_data: RunData)

func set_run_state(new_state: RunState) -> void
```

## Alternatives Considered

### Alternative 1: Pure Native Signals

- **Description**: All systems connect via Godot native signals in scene tree
- **Pros**: No Autoloads, simpler node tree
- **Cons**: DamageBus needs 9 manual connections per enemy instance; scene changes break connections; no global access
- **Rejection Reason**: 150+ enemies x 9 connections = 1350+ signal connections; scene changes break everything

### Alternative 2: Single Global EventBus

- **Description**: One Autoload with ALL signals (damage, state, technique, boss, etc.)
- **Pros**: Single point of truth
- **Cons**: Godot signal limits (~100 signals per object); bloated singleton; naming collisions
- **Rejection Reason**: Violates separation of concerns; signal count will exceed practical limits

## Consequences

### Positive

- DamageBus and RunSession are available everywhere, no dependency injection needed
- Scene changes don't break connections (Autoloads persist)
- Clear ownership: DamageBus owns damage routing, RunSession owns state
- Native signals for local communication keep node tree clean

### Negative

- Autoloads create implicit global state (harder to test in isolation)
- Two Autoloads = two global dependencies every system has
- Signal names must be globally unique within each Autoload

### Risks

- **Risk**: Autoload initialization order matters
  - **Mitigation**: DamageBus and RunSession have no dependencies on each other; order doesn't matter
- **Risk**: Signal connection leaks if entities are pooled and reused
  - **Mitigation**: Object pool must disconnect signals on return-to-pool

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| damage-health-system.md | All damage through DamageBus.deal_damage() | DamageBus Autoload is the single entry point |
| damage-health-system.md | Synchronous processing (same frame) | Godot signals are synchronous by default |
| run-session-management.md | run_state_changed broadcast to all systems | RunSession Autoload with global signal |
| run-session-management.md | Scene changes preserve state | Autoloads persist across scenes |
| enemy-ai.md | 150+ entities subscribe to damage signals | Autoload handles mass subscriptions efficiently |
| hud.md | Subscribe to 6+ system signals | Autoloads provide stable signal sources |

## Performance Implications

- **CPU**: Signal dispatch is O(n) per subscriber. DamageBus with 9 subscribers = negligible
- **Memory**: Two Autoloads = ~2KB permanent memory
- **Load Time**: Autoloads load at startup, ~10ms each
- **Network**: N/A (single-player)

## Validation Criteria

- DamageEvent from TechniqueSystem reaches DamageBus and triggers VFX in same frame
- RunSession state change propagates to all 13 systems within 1 frame
- Scene change from menu to battle preserves DamageBus/RunSession state
- No signal connection leaks after 100 enemy spawn/despawn cycles

## Related Decisions

- ADR-0002: Object Pool Strategy (depends on this ADR's signal patterns)
- ADR-0003: Scene Management (depends on Autoload persistence)
