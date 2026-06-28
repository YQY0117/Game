# Realm Progression (境界突破系统)

> **Status**: In Design
> **Author**: user + game-designer + systems-designer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 2 (越战越强 — 境界突破是力量跃迁的仪式) + Pillar 1 (近在咫尺 — 灵气条上可见下一个突破节点)
> **Priority**: MVP | **Layer**: Progression
> **Source Systems Index**: design/gdd/systems-index.md (Order #17)

## Overview

Realm Progression 是境界突破的**协调层**——它不拥有灵气数值（Spirit/XP 负责）或功法槽位（Technique 负责），而是监听 `realm_breakthrough` 信号，协调所有相关系统完成突破仪式: 播放动画、解锁槽位、切换基础速度、应用境界色调、通知下游系统。

本系统在 MVP 阶段是轻量桥接器——大部分"突破效果"已在其他 GDD 中定义（Player Controller F1 速度、Technique System 槽位数、Art Bible Section 2 动画）。Realm Progression 的价值在于**统一协调**，避免各系统各自监听突破信号导致时序问题。

## Player Fantasy

**Direct — 突破瞬间是每局最神圣的 1.2 秒。**

玩家感受的:**从凡人到仙人的质变跃迁**。灵气条满的瞬间，画面从浅绿变深蓝（R1→R2），墨色从屏幕中心扩张覆盖全屏，新境界名称以朱砂印章浮现——然后墨色消散，世界用新的色调重启。玩家感受到的不是"数字变大"，而是**世界本身改变了**。

这是 art-bible Section 2 境界突破仪式的直接翻译——"蜕变 + 敬畏"。每一次突破都是游戏给玩家的奖励: 你做到了，世界为你改变。

## Detailed Design

### Core Rules

**1. 突破触发**:
- 监听 Spirit/XP System 的 `realm_breakthrough(new_realm)` 信号
- 信号触发时，Run/Session 进入 `breakthrough` 状态
- 玩家进入 `immobile` 状态（不可移动，不可被攻击）

**2. 突破仪式序列**（art-bible Section 7.5 锁定，1.2s）:

| 时间 | 行为 | 系统 |
|------|------|------|
| 0-200ms | 游戏世界减速至 30%，HUD 淡出 α 1.0→0 | Run/Session, Camera, HUD |
| 200-500ms | 墨色从屏幕中心扩张，覆盖至全屏黑 | VFX (placeholder) |
| 500-800ms | 新境界名称以朱砂印章出现（如"筑基"） | VFX (placeholder) |
| 800-1100ms | 境界描述文字出现（一行，由 narrative 提供） | VFX (placeholder) |
| 1100-1200ms | 墨色消散，画面切换到新境界色调 | VFX, Camera |

**3. 突破效果**（在仪式期间应用）:

| 效果 | 时机 | 接口 |
|------|------|------|
| 槽位解锁 | 500ms（印章出现时） | Technique System: `unlock_slot(new_realm)` |
| 基础速度切换 | 500ms | Player Controller: `realm_transitioned(new_realm)` 信号 |
| 境界色调切换 | 1100ms（消散时） | Camera/World: 应用新境界 CanvasModulate |

**4. 境界数据**:

| 境界 | 名称 | 基调色 | 槽位 | 基础速度 | 灵气需求 |
|------|------|--------|------|----------|----------|
| R1 | 炼气 | `#4D7950` 松绿 | 2 | 88 px/s | 100 |
| R2 | 筑基 | `#3B5C78` 云青 | 3 | 100.4 px/s | 200 |
| R3 | 金丹 | `#B8933D` 金 | 4 | 109.2 px/s | 350 |
| R4 | 元婴 | `#5E426E` 紫霞 | 5 | 115.9 px/s | 550 |
| R5 | 大乘 | 流光渐变 | 6 | 120.5 px/s | 700 |
| R6 | 飞升 | 无色（墨+纸） | 7 | 124 px/s | — |

**5. 飞升突破（终局）**:
- R5 灵气条满 → 触发飞升突破
- 飞升突破使用更长仪式（8-15s，art-bible Section 6.3）
- 仪式结束后 Run/Session 进入 `victory` 状态
- 飞升无新境界色调（art-bible: "纯留白，无几何形"）

### States and Transitions

**突破状态机**:

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **idle** | 无突破进行中 | 突破完成 | 灵气条满 |
| **ceremony** | 1.2s 突破仪式 | `realm_breakthrough` 信号 | 1.2s 计时器结束 |
| **ascension** | 飞升仪式（8-15s） | R5 灵气条满 | 仪式结束 |

**状态流转**: `idle → ceremony → idle → ... → ascension`

### Interactions with Other Systems

**上游**:

| 上游 | 接口 | 频率 |
|------|------|------|
| **Spirit/XP System** | 订阅 `realm_breakthrough(new_realm)` 信号 | 每次突破 |
| **Run/Session Management** | 调用 `set_run_state("breakthrough")` / `notify_breakthrough_ended()` | 每次突破 |

**下游**:

| 下游 | 接口 | 类型 |
|------|------|------|
| **Technique System** | 调用 `unlock_slot(new_realm)` 解锁功法槽位 | API |
| **Player Controller** | emit `realm_transitioned(new_realm)` 信号，PC 切换基础速度 | 信号 |
| **Camera/World** | 应用新境界色调（CanvasModulate） | API |
| **HUD** | 订阅 `realm_changed(new_realm)` 信号，更新境界标识 | 信号 |
| **Enemy Spawner** | 订阅 `realm_changed` 信号，更新敌人密度配置 | 信号 |
| **Audio Manager** | 订阅 `realm_changed` 信号，播放突破音效 | 信号 |
| **VFX System** | 控制突破动画播放 | 委托 |

**Godot 信号契约**:
- `realm_changed(new_realm: int)` — 境界切换完成时（仪式结束后 emit）
- `breakthrough_started()` — 突破仪式开始
- `breakthrough_ended()` — 突破仪式结束

## Formulas

### Formula 1: 境界基础速度（引用 Player Controller GDD F1）

```
base_speed(R) = 88 + (124 - 88) × log(1 + 1.8 × (R - 1)) / log(1 + 1.8 × 5)
```

本系统不重复定义，引用 Player Controller GDD。突破时通知 PC 切换。

### Formula 2: 槽位数量（引用 Technique System GDD F1）

```
slot_count(R) = 2 + (R - 1)
```

本系统不重复定义，引用 Technique System GDD。突破时通知 Technique 解锁。

### Formula 3: 境界色调（引用 Art Bible Section 4.3）

| 境界 | 主色 | 色温 |
|------|------|------|
| R1 | `#4D7950` 松绿 | ~5500K 中性 |
| R2 | `#3B5C78` 云青 | ~6500K 冷 |
| R3 | `#B8933D` 金 | ~4200K 暖 |
| R4 | `#5E426E` 紫霞 | ~3800K 暖暮 |
| R5 | 流光渐变 | 变化/棱镜 |
| R6 | 无色 | 无色相 |

## Edge Cases

- **如果灵气条满但玩家正在 hitstun**: hitstun 结束后立即触发突破（Spirit/XP GDD 已定义）。
- **如果突破期间玩家被攻击**: 突破期间玩家处于 `immobile` 状态，Damage 系统的 i-frame 保护生效（理论上不会被攻击）。
- **如果突破期间 BOSS 仍存活**: 突破期间 Run/Session 处于 `breakthrough` 状态，所有 gameplay 暂停。BOSS 状态保留。
- **如果 R5 突破时灵气溢出**: 多余灵气不保留（Spirit/XP GDD 已定义）。
- **如果飞升仪式期间玩家死亡**: 飞升仪式期间玩家无敌，不会死亡。

## Dependencies

### 上游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Spirit/XP System** | Hard | `realm_breakthrough(new_realm)` 信号 |
| **Run/Session Management** | Hard | `set_run_state("breakthrough")` / `notify_breakthrough_ended()` |

### 下游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Technique System** | Hard | `unlock_slot(new_realm)` API |
| **Player Controller** | Hard | `realm_transitioned(new_realm)` 信号 |
| **Camera/World** | Hard | 境界色调 CanvasModulate |
| **HUD** | Hard | `realm_changed(new_realm)` 信号 |
| **Enemy Spawner** | Soft | `realm_changed` 信号 |
| **Audio Manager** | Soft | `realm_changed` 信号 |
| **VFX System** | Soft | 突破动画委托 |

## Tuning Knobs

| 旋钮 | 描述 | 安全范围 | 极端行为 |
|------|------|----------|----------|
| `ceremony_duration` | 突破仪式时长 | 0.8–2.0s | <0.8: 无仪式感；>2.0: 打断节奏 |
| `ascension_duration` | 飞升仪式时长 | 5–20s | <5: 飞升无重量感；>20: 等待太久 |
| `slowdown_factor` | 突破期间世界减速倍率 | 0.1–0.5 | <0.1: 几乎静止；>0.5: 不够慢 |
| `color_transition_duration` | 境界色调切换时长 | 0.3–1.0s | <0.3: 切换太突兀；>1.0: 切换太慢 |

## Visual/Audio Requirements

**突破动画**（art-bible Section 7.5 锁定）:
- 墨色从中心扩张覆盖全屏
- 新境界名称以朱砂印章出现
- 境界描述文字出现
- 墨色消散，画面切换到新境界色调

**境界色调**:
- 应用为 CanvasModulate（不重绘资产）
- 切换时使用 art-bible Section 4.3 的色温规范

**音效**:
- 突破开始: 低沉钟声
- 印章出现: 朱砂印泥声
- 色调切换: 环境音渐变

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:realm-progression` to produce breakthrough animation specs, color grade textures, and audio cue lists.

## UI Requirements

**境界标识**（HUD 右上角）:
- 朱砂印章，显示当前境界名称
- 突破时印章短暂放大 + 朱砂闪光

**灵气条突破节点**:
- 在灵气条上标记 4-5 个节点（对应 R1-R5）
- 已到达: 朱砂红
- 未到达: 淡墨轮廓

> **📌 UX Flag — Realm Progression**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for the realm indicator and breakthrough UI before writing epics.

## Acceptance Criteria

- **GIVEN** 灵气条满触发突破（R1→R2），**WHEN** `realm_breakthrough(2)` 信号接收，**THEN** Run/Session 进入 `breakthrough` 状态，玩家 immobile。
- **GIVEN** 突破仪式开始，**WHEN** 500ms 时，**THEN** 功法槽位从 2 解锁到 3，基础速度从 88 切换到 100.4 px/s。
- **GIVEN** 突破仪式完成（1.2s），**WHEN** 1100ms 时，**THEN** 画面色调从松绿切换到云青，Run/Session 恢复 `playing` 状态。
- **GIVEN** R5 灵气条满，**WHEN** 触发飞升，**THEN** 飞升仪式播放 8-15s，结束后 Run/Session 进入 `victory` 状态。
- **GIVEN** 突破期间 BOSS 仍存活，**WHEN** 突破进行中，**THEN** BOSS 状态冻结，突破结束后恢复。

## Open Questions

- [ ] 境界描述文字由谁提供？当前设计: narrative-director 在境界配置中预设。
- [ ] 飞升仪式的具体视觉规格是否需要单独定义？
- [ ] 突破时是否需要显示"新槽位已解锁"的提示文字？
