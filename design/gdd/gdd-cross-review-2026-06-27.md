# Cross-GDD Review Report

**Date**: 2026-06-27
**GDDs Reviewed**: 13
**Systems Covered**: Input, Player Controller, Camera, Damage/Health, Run/Session, Enemy AI, Technique, Spirit/XP, Enemy Spawner, Drop/Pickup, Boss AI, Realm Progression, HUD

---

## Consistency Issues

### Blocking (must resolve before architecture begins)

**🔴 B-1: Input System 自相矛盾 — 模式切换阈值**
- `input-system.md` Core Rule 4: 2 个连续事件 或 500ms 持续输入
- `input-system.md` Formula 2: 3 个连续事件 或 400ms 持续输入
- `input-system.md` AC-02: 引用 Formula 2 的 3/400 值
- **矛盾**: Core Rule 和 Formula 定义了不同的切换阈值
- **修复**: 统一为一个值（建议 2/500，更宽松）

**🔴 B-2: Enemy Spawner 公式与 Art-Bible 密度不匹配**
- `enemy-spawner-wave-manager.md` F3: `max_enemies(R) = 30 + 25 × (R - 1)` → R5=130
- `art-bible.md` Section 5.3: R5=120-150+
- **矛盾**: 公式上限 130 无法表达 art-bible 的 "150+"
- **修复**: 调整公式为 `30 + 30 × (R - 1)` → R5=150，或接受 130 为 MVP 上限

**🔴 B-3: Boss HP 公式 33× 巨大差异**
- `boss-ai.md` F1: `boss_hp = base_hp × (1.0 + 0.3 × (R-1))`，BOSS-A R1=80 HP
- `damage-health-system.md` F5: `boss_HP = 1000 × (1.0 + 1.2 × (R-1))`，R1=1000 HP
- **矛盾**: 同一 BOSS 在 R1 有 80 vs 1000 HP 的差异（12.5×），R5 更是 176 vs 5800（33×）
- **修复**: boss-ai.md 的 per-BOSS HP (80/120/100/150) 应为权威值，Damage GDD F5 的 1000 是错误的公式插图

### Warnings (should resolve, but won't block)

**⚠️ W-1: Damage GDD F5 BOSS HP 需要注释**
- `damage-health-system.md` F5 写 `base_HP[BOSS]=1000`，但这只是公式示例
- 实际 BOSS HP 由 boss-ai.md 定义（80-150）
- **建议**: 在 Damage GDD F5 添加注释："BOSS base_HP 由 Boss AI GDD 定义，此处仅为公式结构示例"

**⚠️ W-2: Enemy AI 引入 per-type HP 倍率未同步到 Damage GDD**
- `enemy-ai.md` 定义了 5 种杂兵类型，各有不同 HP
- `damage-health-system.md` F5 使用统一公式 `mob_HP = 10 × (1 + 0.45(R-1))^1.6`
- **建议**: 确认杂兵 HP 是否按类型区分，如果是，更新 Damage GDD

**⚠️ W-3: 波次时长与 Enemy Spawner 配置表不一致**
- `enemy-spawner-wave-manager.md` F1: W5=100s
- 同文件配置表: 波次 5=90s
- **建议**: 统一为 90s（配置表更具体）

**⚠️ W-4: Combo System 未设计 — 元素组合效果未定义**
- Technique System 定义了元素标签和 combo 前置接口
- 但 Combo System (#13) 状态为 "Not Started"
- **影响**: 无法验证 "自创流派" 支柱是否成立

**⚠️ W-5: Meta-Progression 未设计 — 长期留存钩子缺失**
- game-concept.md 的 "再来一局" retention 依赖局外解锁
- Meta-Progression (#18) 状态为 "Not Started"
- **影响**: VS gate 需要此设计

**⚠️ W-6: "越战越强" 支柱适用范围需要澄清**
- 支柱名暗示玩家持续变强
- 但 HP 不递增（Damage GDD F3），玩家实际在 runtime 变弱（HP 只减不增）
- **建议**: 在 game-concept.md 明确说明 "越战越强" 指永久能力（槽位、速度、功法），非当前状态

**⚠️ W-7: 功法不可卸下 + BOSS 掉落 = 元素组合被锁定**
- Technique System: 已装备功法不可卸下
- 如果第一个 BOSS 掉落的功法元素不好，整局构筑受限
- **建议**: 考虑允许在突破时替换功法（而非仅新增）

**⚠️ W-8: HP 指数 1.6 未与 DPS 曲线验证**
- Damage GDD F5: `mob_HP = 10 × (1 + 0.45(R-1))^1.6`
- 但玩家 DPS 取决于未定义的 combo 效果
- **建议**: Combo System 设计后验证此耦合

### Info

**ℹ️ I-1: 所有核心数值一致**
- Player HP=20, 元素倍率 1.5/0.7, 槽位 2+(R-1), 速度 88-124, i-frame 600ms, 留白圈 2.0× — 全部一致

**ℹ️ I-2: 击退力道 5 档完全一致**
- PC/Damage/Enemy AI/Camera 四个 GDD 的击退档位完全匹配

**ℹ️ I-3: 无循环依赖**
- 依赖图是干净的 DAG

**ℹ️ I-4: Damage/Health 是枢纽系统**
- 3 上游 + 9 下游，接口变更影响全系统

**ℹ️ I-5: 杂兵速度比保证玩家总能逃脱**
- 5 种杂兵速度 0.55-0.95× player speed，始终 <1.0

---

## Game Design Issues

### Blocking

**🔴 D-1: Combo System 未设计 — 支柱 3 无法验证**
- "自创流派" 的核心机制是功法 combo 搭配
- Combo System (#13) 状态 "Not Started"
- 没有 combo 数据，无法判断是否存在主导策略
- **建议**: 优先设计 Combo System

### Warnings

**⚠️ D-2: Meta-Progression 未设计 — 长期留存风险**
- "再来一局" 的驱动力来自局外解锁
- MVP 可自给自足，但 VS gate 需要此设计

**⚠️ D-3: HP 无恢复 vs "越战越强" 期望**
- Survivor-like 标准设计，但支柱名称可能误导玩家
- **建议**: 明确支柱范围

**⚠️ D-4: 功法永久装备 + BOSS 掉落 = 早期选择锁定构筑**
- 如果 combo 偏好特定元素组合，第一个 BOSS 选择成为主导策略决策
- 需要 combo 数据验证

**⚠️ D-5: 自动释放 vs "夺取" 主动语言的幻想张力**
- game-concept 用 "夺取了他的看家本领" 的主动语言
- 但功法自动释放，玩家零操作
- Survivor-like 正确设计，但与 Mega Man 参考有差异

---

## Cross-System Scenario Walkthrough

### Scenario 1: 击杀杂兵 → 灵气收集 → 境界突破

| 步骤 | 系统 | 行为 | 数据流 |
|------|------|------|--------|
| 1 | Damage | 杂兵 HP≤0 → `entity_died(id)` | signal |
| 2 | Spirit/XP | 监听信号 → 生成灵气值 | `spirit_drop(type)` |
| 3 | Drop/Pickup | 实例化金色粒子 → 0.5s 飘向玩家 | visual |
| 4 | Spirit/XP | `spirit_absorbed` → 累加灵气 | `current_spirit += amount` |
| 5 | Spirit/XP | 灵气满 → `realm_breakthrough(R+1)` | signal |
| 6 | Realm Progression | 监听 → 进入 ceremony 状态 | coordination |
| 7 | Technique | 解锁新槽位 | `unlock_slot(R+1)` |
| 8 | Player Controller | 切换基础速度 | `realm_transitioned(R+1)` |
| 9 | Camera/World | 切换境界色调 | CanvasModulate |
| 10 | Run/Session | 恢复 playing 状态 | `run_state_changed` |

**✅ 无问题** — 数据流清晰，时序由 Realm Progression 统一协调。

### Scenario 2: BOSS 战 — 读招 → 输出 → 击杀 → 功法夺取

| 步骤 | 系统 | 行为 | 潜在问题 |
|------|------|------|----------|
| 1 | Enemy Spawner | 第 5 波 BOSS 生成 | ✅ |
| 2 | Boss AI | 进入 telegraph（朱砂红聚集） | ✅ |
| 3 | Player | 走位躲避 | ✅ |
| 4 | Technique | 功法弹幕命中 BOSS → DamageEvent | ✅ |
| 5 | Damage | 结算伤害 → `damage_dealt` | ✅ |
| 6 | Boss AI | hitstun → 恢复 → 下一轮攻击 | ✅ |
| 7 | Damage | BOSS HP≤0 → `entity_died(boss_id)` | ✅ |
| 8 | Technique | 功法夺取流程启动 | ⚠️ 需要确认夺取 UI |
| 9 | Spirit/XP | 灵气掉落（10-15） | ✅ |
| 10 | Realm Progression | 如果灵气满 → 突破 | ⚠️ BOSS 击杀 + 突破可能同帧 |

**⚠️ Warning**: BOSS 击杀给予大量灵气（10-15），可能在击杀同帧触发突破。突破期间玩家 immobile，但功法夺取 UI 也需要交互。**需要确认功法夺取和境界突破的优先级**。

### Scenario 3: 玩家死亡 → 结算 → 重开

| 步骤 | 系统 | 行为 | 潜在问题 |
|------|------|------|----------|
| 1 | Damage | 玩家 HP≤0 → `entity_died(player)` | ✅ |
| 2 | Run/Session | 进入 dying → dead 状态 | ✅ |
| 3 | HUD | 显示死亡画面（800ms 黑场） | ✅ |
| 4 | Spirit/XP | 灵气清零 | ✅ |
| 5 | Player | 点击"重来" | ✅ |
| 6 | Run/Session | 新局开始，所有状态重置 | ✅ |

**✅ 无问题** — 死亡流程清晰。

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| `input-system.md` | Core Rule 4 vs Formula 2 自相矛盾 | Consistency | Blocking |
| `enemy-spawner-wave-manager.md` | F3 公式与 art-bible 密度不匹配 + F1 与配置表时长不一致 | Consistency | Blocking |
| `boss-ai.md` / `damage-health-system.md` | BOSS HP 公式 33× 差异 | Consistency | Blocking |
| `damage-health-system.md` | F5 BOSS HP 需要注释 | Consistency | Warning |
| `systems-index.md` | Combo System 需要优先设计 | Design | Warning |

---

## Verdict: CONCERNS

3 个 Blocking 一致性问题需要修复，但都是数值/公式的简单修正，不涉及架构变更。Game Design 层面的核心风险是 **Combo System 未设计**，但这不阻塞 MVP 实现——可以先实现基础框架，combo 效果后续叠加。

### 修复优先级

1. **B-1**: Input System 统一阈值（30 秒编辑）
2. **B-3**: Boss HP 公式统一（boss-ai.md 为权威）
3. **B-2**: Enemy Spawner 公式调整或接受 130 为 MVP 上限
4. **W-3**: 波次时长统一为配置表值
5. **W-1**: Damage GDD 添加 BOSS HP 注释
