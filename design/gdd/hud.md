# HUD (抬头显示)

> **Status**: In Design
> **Author**: user + game-designer + ux-designer
> **Last Updated**: 2026-06-25
> **Implements Pillar**: Pillar 1 (近在咫尺 — 灵气条/BOSS 血条/技能槽让目标永远可见)
> **Priority**: MVP | **Layer**: Presentation
> **Source Systems Index**: design/gdd/systems-index.md (Order #19)

## Overview

HUD 是战斗界面的**信息汇总层**——它不拥有任何 gameplay 逻辑，只订阅各系统的信号并渲染可视化。MVP HUD 包含 4 个核心元素: 灵气条（Spirit/XP）、技能槽（Technique）、BOSS 血条（Boss AI）、境界标识（Realm Progression）。

所有 HUD 规格已在 Art Bible Section 7.1 中锁定。本 GDD 聚合各上游系统的 UI 需求，定义 HUD 的完整布局、透明度策略和输入模式切换。

## Player Fantasy

**Indirect — 好的 HUD 是玩家不注意的 HUD。**

玩家感受的:**战斗中 HUD 几乎透明，但需要时信息立刻可读**。灵气条在顶部淡入提醒"快突破了"，技能槽冷却脉冲告知"下一招就绪"，BOSS 血条在 BOSS 战时浮现——玩家不需要主动寻找信息，信息会在正确的时间出现在正确的位置。

参考标杆:**Vampire Survivors** 的极简 HUD——屏幕中央留给战斗，边缘留给数据。**Hades** 的 BOSS 血条——只在 BOSS 战时出现，平时隐藏。

## Detailed Design

### Core Rules

**1. HUD 元素清单（MVP）**:

| 元素 | 数据源 | 信号 | 位置 |
|------|--------|------|------|
| 灵气条 | Spirit/XP System | `spirit_changed(current, max)` | 顶部居中 (0.20-0.80, 0.02) |
| 技能槽 ×4 | Technique System | `technique_cooldown_update` | 底部居中 (0.50, 0.92) |
| BOSS 血条 | Boss AI | `boss_hp_changed` | 顶部居中 (0.50, 0.04) |
| 境界标识 | Realm Progression | `realm_changed` | 右上角 (0.96, 0.06) |

**2. 透明度策略**（art-bible Section 7.1 锁定）:

| 状态 | HUD 整体 α | 说明 |
|------|-----------|------|
| idle（无战斗） | 0.35 | 几乎不可见 |
| combat triggered | 1.0（0.2s 渐入） | 战斗时全显 |
| post-combat 3s | 0.35（渐回） | 战斗结束后淡出 |
| player hit | 闪红 120ms | 受击反馈 |

**例外**: 玩家锚定 HP 环的 α 由 HP 百分比驱动，不受全局透明度影响。

**3. 灵气条**:
- 水平线，3px 高，墨色填充由左至右晕开（卷轴展开效果）
- 突破节点: 在条上标记 4-5 个节点（对应 R1-R5），已到达=朱砂红，未到达=淡墨
- 常驻 α=0.5，战斗中 α=1.0
- 填充满时: 朱砂红闪光 200ms → 突破触发

**4. 技能槽**:
- 4 槽（桌面底部居中），方印形状 40×48px
- 内容: 功法名称首字（楷体）
- 冷却中: 朱砂红径向擦除（顺时针从 12 点）+ 字体变灰 50%
- 就绪: 200ms 脉冲（朱砂环外扩 4px + 字体闪白）
- Buff 徽章: 右上角 12×12px 小印章（最多 2 个）

**5. BOSS 血条**:
- 水平线，顶部居中（0.50, 0.04）
- 仅在 BOSS 战期间显示（boss_spawned → 显示，boss_died → 隐藏）
- 双层反馈: 前层即时（朱砂红），后层 200ms 延迟（白色）
- BOSS 名称: 血条上方，朱砂印章

**6. 境界标识**:
- 右上角朱砂印章，显示当前境界名称（如"炼气"）
- 突破时: 印章短暂放大 + 朱砂闪光

**7. 输入模式切换**（art-bible Section 7.1 锁定）:
- KBM 模式: 触屏控件完全隐藏，桌面技能槽布局
- Touch 模式: 摇杆+攻击圈 α=0.55（idle）/ α=1.0（pressed），触屏 2+2 技能槽布局
- 自动切换滞后: 2 个连续事件 或 500ms 持续输入

**8. Z-order**（art-bible Section 7.1 锁定）:

| 层级 | 内容 |
|------|------|
| 1 | 游戏世界（含世界 LUT） |
| 2 | 伤害飞字（世界层，元素色） |
| 3 | 屏幕后处理（震屏等） |
| 4 | **UI LUT 边界**（世界色到此为止） |
| 5 | HUD 持久层（灵气条、技能槽、境界标识） |
| 6 | HUD 瞬态层（脉冲、徽章动画） |
| 7 | 玩家锚定 HP 环（世界定位，UI 渲染） |
| 8 | 菜单/模态 |

**9. 玩家锚定 HP 环**（双重 HP 反馈的沉浸层）:
- ~80px 半径，围绕玩家角色
- 100% HP 时不可见
- 70-40% HP: α 0→0.4
- 40-20% HP: α 0.4→0.7
- <20% HP: α 0.7→1.0 + 每 1.2s 慢呼吸脉冲

### Interactions with Other Systems

**上游（HUD 订阅的信号）**:

| 上游 | 信号 | HUD 响应 |
|------|------|----------|
| **Spirit/XP System** | `spirit_changed(current, max)` | 更新灵气条填充 |
| **Technique System** | `technique_cooldown_update(id, progress)` | 更新技能槽冷却 |
| **Technique System** | `technique_fired(id, pos, dir)` | 技能槽就绪脉冲 |
| **Boss AI** | `boss_hp_changed(id, current, max)` | 更新 BOSS 血条 |
| **Boss AI** | `boss_died(id)` | 隐藏 BOSS 血条 |
| **Realm Progression** | `realm_changed(new_realm)` | 更新境界标识 |
| **Damage/Health System** | `hp_changed(player, new_hp, max_hp)` | 更新 HP 环 |
| **Player Controller** | `position_changed(pos)` | 更新 HP 环位置 |
| **Run/Session Management** | `run_state_changed(old, new)` | 切换 HUD 可见性 |
| **Enemy Spawner** | `wave_changed(wave, total)` | 更新波次显示（可选） |

**下游**: HUD 无下游——它是终端消费者。

## Formulas

### Formula 1: HUD 全局透明度

```
hud_alpha(state) = match state:
    idle → 0.35
    combat → 1.0 (0.2s ease-in)
    post_combat → 0.35 (3s delay, 0.5s ease-out)
    player_hit → flash 1.0 for 120ms, then back to combat α
```

### Formula 2: HP 环透明度（按 HP 百分比）

```
hp_ring_alpha(hp_pct) = match:
    hp_pct > 0.70 → 0.0 (invisible)
    0.40 < hp_pct ≤ 0.70 → lerp(0.0, 0.4, (0.70 - hp_pct) / 0.30)
    0.20 < hp_pct ≤ 0.40 → lerp(0.4, 0.7, (0.40 - hp_pct) / 0.20)
    hp_pct ≤ 0.20 → lerp(0.7, 1.0, (0.20 - hp_pct) / 0.20) + 1.2s breath pulse
```

## Edge Cases

- **如果 BOSS 战期间玩家同时处于 critical HP**: BOSS 血条和 HP 环同时显示，不冲突（不同位置）。
- **如果多个 BOSS 同时存在**: 只显示最近 BOSS 的血条。
- **如果技能槽为空（无功法装备）**: 槽位显示为空方印。
- **如果触屏模式下玩家旋转设备**: 输入模式自动切换（滞后机制处理）。
- **如果 HUD 元素重叠**: 按 Z-order 分层，不重叠（灵气条在上，BOSS 血条在上，技能槽在下）。

## Dependencies

### 上游

| 系统 | 依赖类型 | 接口 |
|------|----------|------|
| **Spirit/XP System** | Hard | `spirit_changed` 信号 |
| **Technique System** | Hard | `technique_cooldown_update`, `technique_fired` 信号 |
| **Boss AI** | Hard | `boss_hp_changed`, `boss_died` 信号 |
| **Realm Progression** | Hard | `realm_changed` 信号 |
| **Damage/Health System** | Hard | `hp_changed(player)` 信号 |
| **Player Controller** | Hard | `position_changed` 信号（HP 环定位） |
| **Run/Session Management** | Hard | `run_state_changed` 信号 |
| **Enemy Spawner** | Soft | `wave_changed` 信号（可选） |

### 下游

HUD 无下游——终端消费者。

## Tuning Knobs

| 旋钮 | 描述 | 安全范围 | 极端行为 |
|------|------|----------|----------|
| `hud_idle_alpha` | idle 时 HUD 透明度 | 0.2–0.5 | <0.2: 看不见；>0.5: 太明显 |
| `hud_combat_fade_in` | 战斗时渐入时长 | 0.1–0.5s | <0.1: 突兀；>0.5: 延迟 |
| `hp_ring_radius` | HP 环半径 | 60–120px | <60: 太近遮挡角色；>120: 太远脱离角色 |
| `cooldown_pulse_duration` | 技能槽就绪脉冲时长 | 100–400ms | <100: 看不见；>400: 太慢 |
| `boss_hp_delay` | BOSS 血条后层延迟 | 100–500ms | <100: 不明显；>500: 太慢 |

## Visual/Audio Requirements

所有视觉规格已在 Art Bible Section 7.1 中锁定，此处不重复。关键约束:

- HUD 使用 Trinity 色: 宣纸白 `#F0E8D8` + 墨黑 `#1A1D22` + 朱砂红 `#B8403A`
- 世界色不出现在 UI 上（art-bible Section 4.4 锁定）
- 数字使用等宽几何字体（JetBrains Mono）
- 技能槽使用楷体首字

## UI Requirements

本系统本身就是 UI。所有规格见上方 Detailed Design。

> **📌 UX Flag — HUD**: This system has comprehensive UI requirements. In Phase 4 (Pre-Production), run `/ux-design` to create a full UX spec for the battle HUD, including touch-mode layouts and accessibility considerations.

## Acceptance Criteria

- **GIVEN** 玩家进入战斗，**WHEN** 敌人进入范围，**THEN** HUD 从 α=0.35 渐入到 α=1.0（0.2s）。
- **GIVEN** 灵气条当前 50/100，**WHEN** `spirit_changed(60, 100)` 信号接收，**THEN** 灵气条填充从 50% 更新到 60%。
- **GIVEN** 技能槽冷却完成，**WHEN** `technique_cooldown_update(id, 0)` 信号接收，**THEN** 播放 200ms 就绪脉冲。
- **GIVEN** BOSS 生成，**WHEN** `boss_hp_changed` 信号首次接收，**THEN** BOSS 血条在顶部居中显示。
- **GIVEN** BOSS 死亡，**WHEN** `boss_died` 信号接收，**THEN** BOSS 血条隐藏。
- **GIVEN** 境界从 R1 突破到 R2，**WHEN** `realm_changed(2)` 信号接收，**THEN** 境界标识从"炼气"更新为"筑基"。
- **GIVEN** 玩家 HP 降到 15%（<20%），**WHEN** HP 环检测，**THEN** HP 环 α=0.85 + 慢呼吸脉冲每 1.2s。
- **GIVEN** 战斗结束 3 秒后无新敌人，**WHEN** 检测，**THEN** HUD 渐回 α=0.35。

## Open Questions

- [ ] 波次显示（"波 3/5"）是否包含在 MVP 中？当前设计: 可选，由 Enemy Spawner 信号驱动。
- [ ] 伤害飞字的具体规格（字体、大小、生命周期）是否需要在此 GDD 中定义？当前: 由 Damage/Health System 控制。
- [ ] 触屏模式的 2+2 技能槽布局是否需要单独 UX spec？
