# Enemy Spawner / Wave Manager (敌人生成器/波次管理器)

> **Status**: In Design
> **Author**: user + game-designer + systems-designer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 1 (近在咫尺 — 敌人潮涌制造紧迫感，BOSS 在最后一波出现)
> **Priority**: MVP | **Layer**: Feature
> **Source Systems Index**: design/gdd/systems-index.md (Order #15)

## Overview

Enemy Spawner / Wave Manager 控制敌人何时、何地、以何种配置生成。每局游戏分为固定波次（每境界 5 波），波次内敌人按配置持续生成，波次间有短暂休息。最后一波包含该境界的 BOSS 战。系统同时管理同屏实体上限（art-bible 锁定 150+），在性能预算内最大化战斗密度。

对玩家而言，波次是**游戏节奏的骨架**——"第 3 波了，BOSS 快来了"的预判感。对技术层而言，它是 Enemy AI 的实例化工厂、Run/Session 的 playing 状态消费者、HUD 波次信息的数据源。

## Player Fantasy

**Indirect — 玩家通过敌人密度和波次推进感受节奏，不直接感知生成逻辑。**

玩家感受的:**潮水般的压迫感 + BOSS 出现前的预判紧张**。第 1 波稀疏的墨滴让玩家热身，第 3 波散墨和闷墨开始包夹，第 5 波屏幕边缘涌出密集墨潮——然后 BOSS 从留白中浮现。玩家不需要知道"波次管理器"存在，但他们会记住"第 4 波最难熬"和"BOSS 总在最后一波"。

参考标杆:**Vampire Survivors** 的持续生成——敌人密度随时间递增，无明确波次划分。我们选择**固定波次**因为: (1) 给玩家节奏锚点，(2) BOSS 出现有明确预告，(3) 波次间休息允许玩家评估构筑。

## Detailed Design

### Core Rules

**1. 波次结构**:
- 每境界 5 波，波次编号 1-5
- 波次 1-4: 杂兵 + 精英，密度逐波递增
- 波次 5: BOSS 战（BOSS + 杂兵护卫）
- 波次间休息: 3 秒（无敌人生成，灵气继续飘向玩家）

**2. 敌人生成规则**:
- 生成位置: 玩家周围 400-800px 的屏幕外随机位置（极坐标: 角度随机，距离 400-800px）
- 生成频率: 每 0.5-2.0 秒生成一批（3-8 个），具体数值由波次配置决定
- 生成上限: 同屏敌人 ≤ 150（art-bible Section 5.3 锁定），超过上限时暂停生成
- 生成暂停: Run/Session 非 `playing` 状态时停止生成

**3. 波次配置表**（MVP R1 炼气期）:

| 波次 | 时长 | 杂兵类型 | 密度 | 精英 | BOSS |
|------|------|----------|------|------|------|
| 1 | 60s | 墨滴为主 | 30-40 | 0 | 无 |
| 2 | 70s | 墨滴 + 散墨 | 40-50 | 0-1 | 无 |
| 3 | 80s | 墨滴 + 散墨 + 闷墨 | 50-60 | 1 | 无 |
| 4 | 90s | 全类型 | 60-80 | 1-2 | 无 |
| 5 | 90s | 全类型 + BOSS | 70-90 | 2 | BOSS-A/B/C |

**4. 境界密度递增**（art-bible Section 5.3 锁定）:

| 境界 | 最大同屏敌人 | 精英频率 |
|------|-------------|----------|
| R1 | 30-50 | 0-1 |
| R2 | 50-80 | 1-2 |
| R3 | 80-110 | 2-3 |
| R4 | 100-130 | 3-4 |
| R5 | 120-150+ | 4-5 |

**5. BOSS 生成规则**:
- BOSS 在第 5 波开始时生成（波次切换后 2 秒延迟）
- BOSS 生成位置: 玩家对面方向，距离 600px（保证玩家看到 BOSS 入场）
- BOSS 生成后，杂兵继续生成但密度降低 30%（BOSS 是主角，杂兵是陪衬）

**6. 精英生成规则**:
- 精英在波次中随机出现（不固定时间点）
- 精英生成位置: 同杂兵规则（屏幕外 400-800px）
- 精英类型: 随机选择（top=远程, side=冲撞, bottom=AoE）
- 每波精英数量有上限（见配置表）

**7. 实体池管理**:
- 敌人使用对象池（非 SceneTree 直接实例化/释放）
- 死亡敌人 0.15s 后返回对象池
- 对象池初始大小: 100，最大 200
- BOSS 不入池（每个 BOSS 唯一实例）

### States and Transitions

**波次状态机**:

| 状态 | 行为 | 进入条件 | 退出条件 |
|------|------|----------|----------|
| **wave_active** | 按配置持续生成敌人 | 波次开始 / 休息结束 | 波次时长结束 / BOSS 击杀（第 5 波） |
| **wave_rest** | 3 秒休息，无敌人生成 | wave_active 时长结束 | 3 秒计时器结束 |
| **boss_active** | BOSS 存活，杂兵密度降低 | 第 5 波 BOSS 生成 | BOSS 死亡 |
| **wave_complete** | 波次完成，准备下一波 | boss_active BOSS 死亡 / wave_rest 结束 | 自动进入下一波 |

**状态流转**: `wave_active → wave_rest → wave_active → ... → boss_active → wave_complete`

### Interactions with Other Systems

**上游**:

| 上游 | 接口 | 频率 |
|------|------|------|
| **Run/Session Management** | 订阅 `run_state_changed`，非 playing 状态停止生成 | 事件驱动 |
| **Enemy AI** | 调用 `spawn(type, position, R)` API 实例化敌人 | 每次生成 |
| **Player Controller** | 读取 `global_position` 计算生成位置 | 每次生成 |

**下游**:

| 下游 | 接口 | 类型 |
|------|------|------|
| **HUD** | 订阅 `wave_changed(wave_number, total_waves)` 信号 | 信号 |
| **HUD** | 订阅 `enemy_count_changed(current, max)` 信号 | 信号 |
| **Run/Session Management** | 调用 `Run.update_run_stat("enemies_killed", +1)` 更新统计 | API |
| **VFX System** | 订阅 `enemy_spawned(enemy_id, position)` 信号，播放生成特效 | 信号 |

**Godot 信号契约**:
- `wave_changed(wave_number: int, total_waves: int)` — 波次切换时
- `enemy_count_changed(current: int, max: int)` — 同屏敌人数变化时
- `enemy_spawned(enemy_id: int, position: Vector2)` — 敌人生成时
- `boss_spawned(boss_id: int, position: Vector2)` — BOSS 生成时

## Formulas

### Formula 1: 波次时长

```
wave_duration(wave_num) = 60 + 10 × (wave_num - 1)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| wave_num | W | int | 1–5 | 波次编号 |
| wave_duration | T | int | 60–100 | 波次时长（秒） |

**Output Range**: [60, 100] 秒。W1=60s, W2=70s, W3=80s, W4=90s, W5=100s。

*注: 配置表中 W5=90s 为 BOSS 战专用时长（BOSS 生成有 2s 延迟，实际可用 88s）。*

**Rationale**: 早期波次短（快速热身），后期波次长（更多战斗时间）。BOSS 波最长（100s），给玩家足够时间击败 BOSS。

### Formula 2: 敌人生成频率

```
spawn_interval(base, wave_num) = base / (1 + 0.2 × (wave_num - 1))
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| base | B | float | 1.0–2.0 | 基础生成间隔（秒） |
| wave_num | W | int | 1–5 | 波次编号 |
| spawn_interval | I | float | 0.5–2.0 | 实际生成间隔 |

**Output Range**: [0.5, 2.0] 秒。W1=2.0s, W3=1.25s, W5=1.0s。

**Rationale**: 后期波次生成更快，敌人密度更高。但不超过 0.5s 下限（避免性能问题）。

### Formula 3: 同屏敌人上限

```
max_enemies(R) = 30 + 30 × (R - 1)
```

**Variables:**

| Variable | Symbol | Type | Range | Description |
|----------|--------|------|-------|-------------|
| R | R | int | 1–5 | 当前境界 |
| max_enemies | M | int | 30–130 | 同屏敌人上限 |

**Output Range**: [30, 150]。R1=30, R2=60, R3=90, R4=120, R5=150。

**Rationale**: 匹配 art-bible Section 5.3 的密度规范。超过上限时暂停生成，等敌人死亡后再恢复。

## Edge Cases

- **如果同屏敌人达到上限（150）**: 暂停生成，等敌人死亡数 ≥ 5 后恢复。不丢弃待生成队列。
- **如果 BOSS 在第 5 波开始前被击杀（理论上不可能）**: 波次正常结束，进入休息。
- **如果玩家在波次休息期间死亡**: Run/Session 进入 dying 状态，波次冻结。
- **如果玩家在 BOSS 战期间死亡**: 同上，波次冻结，BOSS 状态保留（复活后继续）。
- **如果所有敌人都被瞬间击杀（AOE 清屏）**: 生成器继续按配置生成，不补偿缺失密度。
- **如果 BOSS 生成时玩家正好在屏幕边缘**: BOSS 生成在玩家对面方向（600px），可能部分在屏幕外——BOSS 入场动画会处理。
- **如果波次配置中精英数量为 0**: 该波不生成精英，正常。

## Dependencies

### 上游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Enemy AI** | Hard | `spawn(type, position, R)` API |
| **Run/Session Management** | Hard | `run_state_changed` 信号 |
| **Player Controller** | Hard | `global_position`（计算生成位置） |

### 下游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **HUD** | Hard | `wave_changed`, `enemy_count_changed` 信号 |
| **Run/Session Management** | Soft | `Run.update_run_stat()` API |
| **VFX System** | Soft | `enemy_spawned` 信号 |

## Tuning Knobs

| 旋钮 | 描述 | 安全范围 | 极端行为 |
|------|------|----------|----------|
| `wave_count` | 每境界波次数 | 3–7 | <3: 节奏太快；>7: 疲劳 |
| `wave_duration_base` | 基础波次时长 | 45–120s | <45: 太短无感；>120: 疲劳 |
| `spawn_distance_min/max` | 生成距离范围 | 300–1000px | <300: 突然出现；>1000: 太远无压迫感 |
| `spawn_batch_size` | 每批生成数量 | 2–10 | <2: 密度增长慢；>10: 突然涌入 |
| `rest_duration` | 波次间休息时长 | 2–5s | <2: 无喘息；>5: 节奏断裂 |
| `boss_spawn_delay` | BOSS 生成延迟 | 1–5s | <1: 无预告；>5: 等待焦虑 |

## Visual/Audio Requirements

**敌人生成 VFX**:
- 生成位置: 墨色渐现 0.2s（art-bible "墨从纸上渗出"风格）
- 无爆炸、无闪光——敌人是"天气"，不是"事件"

**BOSS 入场 VFX**:
- 生成位置: 墨色浓聚 1.0s，周围留白扩张
- BOSS 名称以朱砂印章出现在屏幕边缘
- 音效: 低沉鼓声 + 墨色音效

**波次切换**:
- HUD 波次编号变化: 朱砂闪光 150ms
- 休息期间: 屏幕边缘微弱墨色消散（暗示"下一波即将到来"）

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible is approved, run `/asset-spec system:enemy-spawner-wave-manager` to produce per-asset visual descriptions, dimensions, and generation prompts from this section.

## UI Requirements

**波次显示**（HUD 右上角）:
- 位置: art-bible Section 7.1 TR-2（0.96, 0.11）
- 样式: 等宽数字，墨色，"波 3/5"
- 波次切换时: 朱砂闪光 150ms

**敌人计数**（可选，HUD 左下角）:
- 显示当前同屏敌人数量
- 透明度: 常驻 α=0.3，战斗中 α=0.8

> **📌 UX Flag — Enemy Spawner / Wave Manager**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a UX spec for the wave display HUD before writing epics.

## Acceptance Criteria

- **GIVEN** 玩家在 R1 炼气期开始新局，**WHEN** 第 1 波开始，**THEN** 墨滴在屏幕外 400-800px 处每 2 秒生成一批（3-5 个）。
- **GIVEN** 第 1 波进行 60 秒，**WHEN** 时长结束，**THEN** 停止生成，3 秒休息后进入第 2 波。
- **GIVEN** 第 5 波开始，**WHEN** 2 秒延迟后，**THEN** BOSS 在玩家对面方向 600px 处生成，杂兵密度降低 30%。
- **GIVEN** 同屏敌人达到 150 上限，**WHEN** 新敌人待生成，**THEN** 暂停生成，等敌人死亡 ≥ 5 后恢复。
- **GIVEN** Run/Session 进入 paused 状态，**WHEN** 波次正在进行，**THEN** 停止生成，波次计时器暂停。
- **GIVEN** BOSS 被击杀，**WHEN** 第 5 波结束，**THEN** 波次完成，进入休息（或境界突破）。
- **GIVEN** R3 金丹期第 3 波，**WHEN** 生成精英，**THEN** 精英类型随机（top/side/bottom），数量 ≤ 3。

## Open Questions

- [ ] 波次配置是否需要支持随机化（如敌人类型随机选择）还是完全预设？
- [ ] BOSS 生成时是否需要全屏预告（如墨色横扫）还是直接出现？
- [ ] 波次间休息是否显示"下一波即将到来"的提示？
