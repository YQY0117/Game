# Systems Index: 咫尺 (Within Reach)

> **Status**: Draft
> **Created**: 2026-06-25
> **Last Updated**: 2026-06-25
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

《咫尺》是修仙题材的 Survivor-like / Action Roguelike,网页 HTML5 平台。机械范围围绕三条支柱构建:
- **近在咫尺** → 系统层面表现为 Spirit/XP 视觉化、Boss 可见标记、Realm Progression 节点预告
- **越战越强** → 系统层面表现为 Technique 槽位只增不减、Meta-Progression 永久解锁
- **自创流派** → 系统层面表现为 Combo 元素融合、Technique 自由搭配

核心循环涉及 4 层依赖结构: Foundation(输入/音频/视效) → Core(角色/相机/伤害) → Feature(敌人/功法/进度) → Presentation(HUD/菜单)。共 21 个系统,其中 13 个为 MVP 必需。

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Input System | Core | MVP | Designed | design/gdd/input-system.md | — |
| 2 | Audio Manager (inferred) | Audio | Vertical Slice | Not Started | — | — |
| 3 | VFX System (inferred) | Presentation | Vertical Slice | Not Started | — | — |
| 4 | Save System (inferred) | Persistence | Vertical Slice | Not Started | — | — |
| 5 | Player Controller (inferred) | Core | MVP | Designed | design/gdd/player-controller.md | Input System |
| 6 | Camera System (inferred) | Core | MVP | Designed | design/gdd/camera-system.md | Player Controller |
| 7 | Damage/Health System (inferred) | Gameplay | MVP | Designed | design/gdd/damage-health-system.md | VFX System, Audio Manager |
| 8 | Run/Session Management (inferred) | Core | MVP | Designed | design/gdd/run-session-management.md | Save System |
| 9 | Settings (inferred) | Meta | Alpha | Not Started | — | Save System, Input System |
| 10 | Spirit/XP System | Progression | MVP | Designed | design/gdd/spirit-xp-system.md | Damage/Health |
| 11 | Drop/Pickup System (inferred) | Economy | MVP | Designed | design/gdd/drop-pickup-system.md | Spirit/XP, VFX System |
| 12 | Technique System (功法) | Gameplay | MVP | Designed | design/gdd/technique-system.md | Player Controller, Damage/Health, VFX, Audio |
| 13 | Combo System | Gameplay | Vertical Slice | Not Started | — | Technique System |
| 14 | Enemy AI | Gameplay | MVP | Designed | design/gdd/enemy-ai.md | Damage/Health, Player Controller |
| 15 | Enemy Spawner / Wave Manager (inferred) | Gameplay | MVP | Designed | design/gdd/enemy-spawner-wave-manager.md | Enemy AI, Run/Session |
| 16 | Boss AI + State Machine | Gameplay | MVP | Designed | design/gdd/boss-ai.md | Damage/Health, Player Controller, Technique, VFX |
| 17 | Realm Progression (境界突破) | Progression | MVP | Designed | design/gdd/realm-progression.md | Spirit/XP, Technique, VFX |
| 18 | Meta-Progression (局外成长) | Progression | Vertical Slice | Not Started | — | Save System, Boss AI, Realm Progression |
| 19 | HUD | UI | MVP | Designed | design/gdd/hud.md | Player Controller, Technique, Boss AI, Realm Progression, Spirit/XP, Wave Manager |
| 20 | Menu System (inferred) | UI | Vertical Slice | Not Started | — | Save System, Settings, Meta-Progression, Realm Progression |
| 21 | Localization (inferred) | Meta | Full Vision | Not Started | — | All UI |

---

## Categories

| Category | Description | Systems |
|----------|-------------|---------|
| **Core** | Foundation everything depends on | Input, Player Controller, Camera, Run/Session |
| **Gameplay** | Systems that make the game fun | Damage/Health, Enemy AI, Boss AI, Enemy Spawner, Technique, Combo |
| **Progression** | How player grows over time | Spirit/XP, Realm Progression, Meta-Progression |
| **Economy** | Resource creation and consumption | Drop/Pickup |
| **Persistence** | Save state and continuity | Save System |
| **UI** | Player-facing information | HUD, Menu System |
| **Audio** | Sound and music | Audio Manager |
| **Presentation** | Visual effects | VFX System |
| **Meta** | Outside core game loop | Settings, Localization |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for core loop to function | First playable (1 境界,3+1 BOSS,6 功法) | Design FIRST |
| **Vertical Slice** | Required for complete experience | Vertical slice (3 境界, combo, meta-progression) | Design SECOND |
| **Alpha** | All features in rough form | Alpha milestone | Design THIRD |
| **Full Vision** | Polish and nice-to-haves | Beta / Release | Design as needed |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. **Input System** — 键鼠/触屏输入抽象层,所有交互的根
2. **Audio Manager** — 音频总线/对象池,独立模块
3. **VFX System** — 粒子对象池/笔形资源管理
4. **Save System** — 序列化框架,LocalStorage 接口

### Core Layer (depends on foundation)

5. **Player Controller** — depends on: Input System
6. **Camera System** — depends on: Player Controller (follow target)
7. **Damage/Health System** — depends on: VFX (hit feedback), Audio (hit sound)
8. **Run/Session Management** — depends on: Save System
9. **Settings** — depends on: Save System, Input System

### Feature Layer (depends on core)

10. **Spirit/XP System** — depends on: Damage (kill triggers drop)
11. **Drop/Pickup System** — depends on: Spirit/XP, VFX
12. **Technique System (功法)** — depends on: Player Controller, Damage, VFX, Audio
13. **Combo System** — depends on: Technique System
14. **Enemy AI** — depends on: Damage/Health, Player Controller
15. **Enemy Spawner / Wave Manager** — depends on: Enemy AI, Run/Session
16. **Boss AI + State Machine** — depends on: Damage/Health, Player Controller, Technique, VFX
17. **Realm Progression** — depends on: Spirit/XP, Technique, VFX
18. **Meta-Progression** — depends on: Save System, Boss AI, Realm Progression

### Presentation Layer (depends on features)

19. **HUD** — depends on: Player, Technique, Boss AI, Realm, Spirit/XP, Wave Manager
20. **Menu System** — depends on: Save, Settings, Meta-Progression, Realm Progression

### Polish Layer (depends on everything)

21. **Localization** — depends on: All UI

---

## Recommended Design Order

Combining dependency sort and priority tiers — design in this order. **MVP Foundation → MVP Core → MVP Feature → MVP Presentation → VS layer → Alpha → Full Vision.**

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Input System | MVP | Foundation | game-designer + godot-specialist | S |
| 2 | Player Controller | MVP | Core | game-designer + gameplay-programmer | M |
| 3 | Camera System | MVP | Core | game-designer + gameplay-programmer | S |
| 4 | Damage/Health System | MVP | Core | systems-designer + gameplay-programmer | M |
| 5 | Run/Session Management | MVP | Core | game-designer | S |
| 6 | Enemy AI | MVP | Feature | ai-programmer + game-designer | M |
| 7 | Enemy Spawner / Wave Manager | MVP | Feature | game-designer + systems-designer | M |
| 8 | Spirit/XP System | MVP | Feature | economy-designer + systems-designer | S |
| 9 | Drop/Pickup System | MVP | Feature | systems-designer | S |
| 10 | Technique System (功法) | MVP | Feature | game-designer + systems-designer | L |
| 11 | Boss AI + State Machine | MVP | Feature | ai-programmer + game-designer | L |
| 12 | Realm Progression | MVP | Feature | game-designer + systems-designer | M |
| 13 | HUD | MVP | Presentation | ui-programmer + ux-designer | M |
| 14 | VFX System | Vertical Slice | Foundation | technical-artist + art-director | M |
| 15 | Audio Manager | Vertical Slice | Foundation | audio-director + sound-designer | S |
| 16 | Save System | Vertical Slice | Foundation | gameplay-programmer | S |
| 17 | Combo System | Vertical Slice | Feature | systems-designer + game-designer | M |
| 18 | Meta-Progression | Vertical Slice | Feature | economy-designer + game-designer | M |
| 19 | Menu System | Vertical Slice | Presentation | ui-programmer + ux-designer | M |
| 20 | Settings | Alpha | Core | ui-programmer | S |
| 21 | Localization | Full Vision | Polish | localization-lead | M |

Effort estimates: **S** = 1 session, **M** = 2-3 sessions, **L** = 4+ sessions.

**Note on ordering**: Although VFX/Audio/Save are Foundation layer technically, they're MVP-deferred — MVP can use placeholder colored rects and silent gameplay. They're Vertical Slice priority because the game must feel complete by then.

---

## Circular Dependencies

**None found.** ✅

The dependency graph is a clean DAG. Three bottleneck systems carry most weight:
- **Damage/Health System** — 7+ downstream dependents
- **Technique System** — Combo, Boss AI, Realm Progression all depend on it
- **Player Controller** — Camera, Enemy AI, Boss AI, Technique all depend on it

These three are the **highest-risk-of-rework** if their interfaces change. Design carefully, expose clean APIs.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| **Technique System** | Design | Combo balance — risk of dominant strategy violating pillar "自创流派" | Element rock-paper-scissors (火克冰/冰克雷/雷克风/风克火) + Boss resistances |
| **Technique System** | Technical | Auto-fire timing on Web with 150 entities may exceed frame budget | Object pool + technique tick batching + early profiling |
| **Boss AI** | Design | 12+ unique boss behaviors,each needs distinct mechanics | Shared 4-beat tell template + element wash variation reduces unique-asset cost |
| **Enemy Spawner / Wave Manager** | Technical | 150+ entities on Web could blow draw call / particle budget | MultiMeshInstance2D for mob renders, particle LOD by distance |
| **Realm Progression** | Design | "Only Growth, No Loss" pillar means slot count grows — at R5 with 6+ slots, screen could saturate | Cap final slot count at 6-7; ensure each slot's auto-fire timing scales |
| **VFX System** | Technical | Particle budget on Godot 4.6 Compatibility / Web could fail Section 8 QA-03 (≤500 particles) | Hard cap + LOD scaling + early performance spike before MVP locked |
| **Meta-Progression** | Design | What persists vs. resets per run could affect "feels fresh each run" — too much persistence = no roguelite tension | Only boss-defeated-once + technique-unlocked-once persist; everything else resets |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 21 |
| Design docs started | 13 |
| Design docs reviewed | 13 |
| Design docs approved | 13 |
| MVP systems designed | 13/13 |
| Vertical Slice systems designed | 0/6 |

---

## Next Steps

- [ ] Review and approve this systems enumeration
- [ ] Design MVP-tier systems first (use `/design-system [system-name]`)
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check pre-production` when all MVP GDDs are complete
- [ ] Validate the highest-risk systems (Technique, Boss AI, VFX) before committing to Production

---

> **Review Mode**: Lean — TD-SYSTEM-BOUNDARY, PR-SCOPE, CD-SYSTEMS director gates skipped. These can be invoked via `/gate-check systems-design` for formal sign-off when needed.
