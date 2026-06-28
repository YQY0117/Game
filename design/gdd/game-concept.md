# Game Concept: 咫尺 (Within Reach)

*Created: 2026-06-25*
*Status: Draft*

---

## Elevator Pitch

> 这是一款修仙题材的 Survivor-like 网页游戏。你在敌群中走位穿梭,功法自动释放;
> 击败 BOSS 夺取其看家招式,自由搭配功法 combo,从炼气期一路突破到飞升。
> 下一个目标永远在你眼前——离无敌,只差一步。

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Survivor-like / Action Roguelike (修仙题材) |
| **Platform** | Web (HTML5), 后续可扩展 Steam |
| **Target Audience** | Survivor-like 玩家 + 修仙/武侠题材爱好者; 构筑型玩家和轻度动作玩家 |
| **Player Count** | 单人 |
| **Session Length** | 单局 30-40 分钟, 碎片化可分段 |
| **Monetization** | 待定 (初期 Web 免费, Steam 版 Premium) |
| **Estimated Scope** | 小 (2-4 个月, 单人) |
| **Comparable Titles** | Vampire Survivors, 暖雪, 鬼谷八荒 |

---

## Core Fantasy

你是一名初入仙途的散修。世界残酷,强者如云——但你的天赋是**夺取**。

击败一个对手,你不仅战胜了他,你**夺取了他的看家本领**。烈焰掌、雷霆剑、冰霜结界——每一个倒在你面前的敌人,都让你变得更强。从炼气期一路杀到飞升,到最后一个 BOSS 时,你已经是所有前人的融合体——无敌。

玩家选择这个游戏,是因为它能同时满足:
- **构筑快感**: 搭配功法 combo 的策略乐趣 (表达与创造)
- **碾压节奏**: 看着自己的构筑成型后满屏清怪的爽感 (放松与心流)
- **近在咫尺的驱动力**: 下一个 BOSS、下一个境界、下一个招式永远看得见、快够到

---

## Unique Hook

像 Vampire Survivors 的自动战斗 + 暖雪/鬼谷八荒的修仙体系, **AND ALSO** 每个 BOSS 的看家招式可以被你夺取并融入自己的功法构筑——你的成长不仅是数值变大,而是**你变成了你击败过的所有人的总和**。

核心差异化:
- **BOSS 招式夺取**: 不是随机掉装备,而是主动选择挑战哪个 BOSS 来获取想要的招式
- **境界突破式成长**: 不是线性升级,而是分境界的质变跃迁,每次突破都是战力天花板重置
- **功法 Combo 系统**: 元素标签 (火冰风雷剑拳) 匹配产生 synergies,没有唯一最优解

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 1 | 功法特效满屏绽放、BOSS 击败瞬间的视觉爆炸、境界突破的光效跃迁 |
| **Expression** (self-expression, creativity) | 2 | 功法自由搭配、combo 路线选择、每局不同构筑方向 |
| **Submission** (relaxation, comfort zone) | 3 | 自动战斗 + 走位,轻操作门槛,刷怪的节奏感 |
| **Fantasy** (make-believe, role-playing) | 4 | 修仙世界观、境界名称和仪式感、从散修到飞升的完整幻想 |
| **Challenge** (obstacle course, mastery) | 5 | BOSS 战策略、构筑理解深度、高境界生存压力 |
| **Discovery** (exploration, secrets) | 6 | 发现隐藏 combo、探索不同功法搭配、隐藏 BOSS |
| **Narrative** (drama, story arc) | 7 | 每个 BOSS 的碎片化故事,通过击败他们拼接世界观 |
| **Fellowship** (social connection) | N/A | 纯单人体验 (后续可考虑排行榜) |

### Key Dynamics

- 玩家会主动规划"这一局要打哪几个 BOSS,走什么功法路线"
- 玩家会在失败后立刻开始下一局——"差一点就到金丹期了"
- 玩家会反复尝试不同的功法 combo,寻找最佳 synergies
- 玩家之间会分享发现的 combo 配方和 BOSS 攻略
- 即使在没有主动操作时,玩家也会持续获得正反馈 (自动清怪 + 灵气收集)

### Core Mechanics

1. **自动战斗 + 走位系统**: 已装备功法自动释放,玩家控制角色走位躲避敌人和弹幕
2. **灵气收集与境界突破**: 击杀敌人掉落灵气,攒满后触发境界突破,解锁功法槽位 + 属性大幅跃迁
3. **BOSS 挑战与招式夺取**: 地图上可选择挑战 BOSS,击败后夺取其招牌功法
4. **功法搭配与 Combo 系统**: 多槽自由搭配,元素标签 (火冰风雷剑拳) 匹配产生额外 combo 效果
5. **局外 Meta-Progression**: 击败过的 BOSS 招式永久解锁,境界永久开放,图鉴收集

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | 选择挑战哪个 BOSS、走什么功法 combo 路线、何时突破境界 | Core |
| **Competence** (mastery, skill growth) | 走位技巧精进 + 构筑理解加深 + 境界攀升的成就感 | Core |
| **Relatedness** (connection, belonging) | BOSS 的碎片化叙事,通过击败他们了解世界和人物 | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: 境界突破、功法图鉴全收集、一局比一局走得更远
- [x] **Explorers** (discovery, understanding systems, finding secrets) — How: 发现隐藏 combo 配方、探索不同构筑路线、隐藏 BOSS
- [ ] **Socializers** (relationships, cooperation, community) — How: 纯单人体验,社区分享 combo 配方属于间接社交
- [ ] **Killers/Competitors** (domination, PvP, leaderboards) — How: 暂不涉及 (后续可加入排行榜)

### Flow State Design

- **Onboarding curve**: 第一局只开放炼气期 + 2 个基础 BOSS,功法自动装备,引导玩家理解"走位 + 自动战斗 + 灵气收集"基础循环
- **Difficulty scaling**: 境界越高敌人密度和强度越大;BOSS 机制复杂度逐境界递增;玩家功法槽位随境界增加,保持挑战-能力的动态平衡
- **Feedback clarity**: 灵气条可视化、境界突破有明确的光效和音效提示、功法 combo 触发时有醒目的视觉联动效果、BOSS 血量条 + 架势条清晰可见
- **Recovery from failure**: 死亡后立即显示"本局战绩"(到达境界、击败 BOSS、解锁功法),点击"再来一局"直接重开,无加载等待。局外永久解锁让每次失败都有收获

---

## Core Loop

### Moment-to-Moment (30 seconds)

玩家操控角色在敌群中走位穿行。已装备的功法按固定节奏自动释放——火球、剑影、冰锥在身边飞舞。击杀敌人掉落灵气珠,自动吸向角色。灵气条在 HUD 顶部缓缓增长,下一个境界突破的节点清晰可见。

**核心满足感**: 走位的节奏感 + 功法特效的视觉爽感 + 灵气条增长的持续正反馈。这 30 秒不需要思考,只需要流动。

### Short-Term (5-15 minutes)

在清怪攒灵气的过程中,地图上始终可见 2-3 个 BOSS 标记,每个 BOSS 头顶显示其持有的功法类型和属性标签。灵气达标后,玩家选择挑战一个 BOSS。BOSS 战是更高密度的弹幕 + 独特机制——击败后夺取其功法,功法自动加入槽位 (或新槽位解锁),战斗力立刻跃迁。然后回到清怪循环,为下一个 BOSS 或境界突破做准备。

**核心满足感**: "先打哪个 BOSS"的策略抉择 + 击败 BOSS 夺取招式后的即时战力提升 + "下一个目标永远在眼前"的驱动力。

### Session-Level (30-40 minutes)

完整一局从炼气期开始,经历筑基→金丹→元婴→大乘,最终挑战飞升守护者。每个境界包含 2-3 个可选 BOSS + 1 个境界守护者(击败守护者才能突破到下一个境界)。飞升成功 = 本局通关。死亡则结束本局,但局外永久解锁进度保留。

**自然停止点**: 死亡时、击败境界守护者后、飞升通关后。但"再来一局"的按钮在死亡画面正中央。

**离线挂念**: "下次我要试试火+风 combo 打那个金丹期 BOSS" —— 构筑规划让玩家在游戏外也保持思考。

### Long-Term Progression

- **局外解锁**: 击败过的 BOSS 功法永久加入招式池,打过的境界永久开放,功法图鉴逐步填充
- **构筑深度扩展**: 越多的功法意味着越多的 combo 可能性,玩家从"有什么用什么"进化到"为某个 combo 专门规划一局路线"
- **完全通关**: 解锁全部境界 + 全部功法 + 至少一次飞升通关。预估 8-15 小时

### Retention Hooks

- **Curiosity**: "那个带雷属性的 BOSS 我还没打过,它的功法是什么?" / "火+雷有没有 combo?"
- **Investment**: 功法图鉴填充进度、最高境界记录、已解锁的构筑可能性
- **Mastery**: 从"勉强打过筑基守护者"到"轻松飞升"的成长曲线

---

## Game Pillars

### Pillar 1: 近在咫尺 (Always Within Reach)

玩家的下一个目标永远可见、可感知、只差一步。BOSS 位置在地图上标记,其招式类型清晰展示,境界突破节点在灵气条上可视化。

*Design test*: 如果纠结于"要不要隐藏下一个 BOSS 的信息制造神秘感",这条支柱说了:**展示它。**目标是可见的,驱动力才生效。

### Pillar 2: 越战越强 (Only Growth, No Loss)

力量只增不减。不删除已获得的功法,不削弱已有构筑,不回头走回头路。槽位随境界解锁,功法库只扩容不缩水。

*Design test*: 如果纠结于"要不要限制槽位让玩家做艰难取舍",这条支柱说了:**用解锁替代替换。**新槽位来自境界突破,不是删除旧功法换来的。

### Pillar 3: 自创流派 (Your Style, Your School)

功法搭配是玩家表达自我的方式。不同的元素组合、不同的 BOSS 挑战顺序、不同的构筑方向——没有唯一最优解,只有最适合你的流派。

*Design test*: 如果纠结于"要不要预设一套火系最强 combo",这条支柱说了:**让玩家自己去发现。**设计师定义规则和 synergies,玩家创造流派。

### Anti-Pillars (What This Game Is NOT)

- **NOT 手动连招**: 不需要搓招,不考验操作精度。核心是策略搭配和走位,不是 APM。如果加了手动连招,会破坏轻度操作的低门槛和心流体验。
- **NOT 随机挫败**: 失败应该来自策略失误或走位疏忽,不是被随机性耍了。每个 BOSS 招式可预见、可对策。如果加了纯随机负面事件,会破坏"越战越强"的成长感和玩家自主性。
- **NOT 枪战/瞄准**: 操作核心是走位,不涉及精确瞄准或射击。如果加了瞄准机制,会排斥目标受众中不擅长射击的玩家。

---

## Visual Identity Anchor

*本次 brainstorm 中,视觉方向未通过 Art Director 正式评审 (Lean 模式跳过 AD-CONCEPT-VISUAL)。以下为初步方向,将在 `/art-bible` 中正式确定。*

**初步方向**: 简洁 2D 手绘风 + 中国水墨/工笔元素

- **功法特效**: 粒子系统驱动,火(橙红粒子)、冰(蓝白碎片)、风(青绿流线)、雷(紫金闪电)
- **角色设计**: 简约但辨识度高的 Q 版修仙角色, BOSS 有独立立绘
- **UI 风格**: 水墨卷轴风,灵气条和境界标识融入仙侠视觉语言
- **场景**: 每个境界有独立背景色调 (炼气浅绿 → 筑基深蓝 → 金丹金黄 → 元婴紫霞 → 大乘流光)

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Vampire Survivors | 自动战斗 + 走位 + 构筑成长的底层循环 | 加入 BOSS 招式夺取和境界突破系统,替换武器升级树为功法 combo | 验证了轻度操作 + 构筑深度的巨大市场 |
| 暖雪 | 修仙世界观 + Roguelike 动作 + 圣物搭配系统 | Survivor-like 而非手动动作,更低操作门槛,更强构筑自由度 | 验证了修仙 Roguelike 在华语市场的接受度 |
| 鬼谷八荒 | 境界突破的仪式感、修仙幻想的完整度 | 精简为 Survivor-like,去掉沙盒/社交,聚焦战斗构筑循环 | 验证了境界系统作为核心进度的强驱动力 |
| Mega Man | BOSS 击败后获取其武器的经典模式 | 改为功法风格,且可多槽同时装备搭配 combo | 验证了"夺取敌人能力"这个心理模型的长期吸引力 |

**非游戏灵感**: 修仙网文 (凡人修仙传、遮天) 的境界体系 —— 每个境界都是一次脱胎换骨,这种"质变跃迁"的感觉是我们境界突破系统的情感锚点。

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18-35 |
| **Gaming experience** | Mid-core (玩过游戏但不是硬核动作玩家) |
| **Time availability** | 碎片化时间,一次 15-40 分钟 |
| **Platform preference** | 网页优先,能直接在浏览器打开就能玩 |
| **Current games they play** | Vampire Survivors / 暖雪 / 鬼谷八荒 / DNF / 崩坏: 星穹铁道 |
| **What they're looking for** | 不需要高度专注也能享受的构筑乐趣,看得见的成长,修仙幻想的满足感 |
| **What would turn them away** | 太高的操作门槛,漫长的教程,强制社交,Pay-to-Win |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4.6 — Web HTML5 导出出色,原生 2D 引擎,轻量级,完美匹配 Survivor-like 需求 |
| **Key Technical Challenges** | 1) Web 端多功法粒子特效性能 (浏览器渲染上限) 2) 功法 combo 系统的事件架构 3) 大量敌人的 AI 和碰撞性能 |
| **Art Style** | 2D 手绘 + 粒子特效,中国水墨/工笔风味 |
| **Art Pipeline Complexity** | Low-Medium (自定义 2D 素材,约 15-20 个 BOSS + 主角 + 功法特效粒子) |
| **Audio Needs** | Moderate (功法音效、BOSS 语音/音效、境界突破仪式音、背景音乐) |
| **Networking** | None (纯单机) |
| **Content Volume** | 3 境界 × (3 BOSS + 1 守护者) = 12 个 BOSS, 15-20 种功法, 5-8 种 combo 效果, 单局 30-40 分钟 |
| **Procedural Systems** | 敌人波次生成 (按境界配置密度和类型)、地图随机布局 (每个境界一张小型地图) |

---

## Risks and Open Questions

### Design Risks
- **功法 combo 平衡**: 如何确保不存在一套碾压所有其他选择的构筑,导致"自创流派"支柱失效
  - *缓解方案*: 通过属性相克 (火克冰、冰克雷、雷克风、风克火) 和 BOSS 抗性机制确保不同路线在不同场景各有优劣
- **"只增不减"导致的决策扁平化**: 如果槽位过多,后期功法选择失去策略性
  - *缓解方案*: 限制最终槽位数 (6-7 个),确保每局玩家仍需要做出路线规划

### Technical Risks
- **Web 端粒子特效性能**: 满屏功法特效 + 敌人 + 浏览器渲染可能掉帧
  - *缓解方案*: 对象池管理 + 粒子数量上限 + Godot 的 MultiMesh 批量渲染 + 早期性能测试
- **Web 导出兼容性**: 不同浏览器/设备的 HTML5 导出表现差异
  - *缓解方案*: 早期在 Chrome/Firefox/Safari 上持续测试,使用 Godot 4.6 的兼容渲染器

### Market Risks
- **Survivor-like 赛道拥挤**: Vampire Survivors 之后大量同类产品涌入
  - *缓解方案*: 修仙题材 + BOSS 招式夺取的差异化足够明显,目标华语修仙玩家群体,蓝海市场

### Scope Risks
- **BOSS 设计工作量**: 12 个 BOSS 需要 12 种独立机制和招式,设计 + 美术 + 实现可能超出单人时间预算
  - *缓解方案*: MVP 先做 1 境界 (3+1 BOSS),验证循环后再扩展。部分 BOSS 可共享基础行为模板,差异在招式机制

### Open Questions
- [ ] 网页版如何变现? (Steam 版 Premium + Web 版广告/免费?) — 等原型验证后决定
- [ ] BOSS 招式是否支持升级/强化? — 原型阶段先不做,专注获取和搭配
- [ ] 是否需要剧情/文本量? — BOSS 击败后的一段简短描述即可,不做完整叙事
- [ ] 多人/排行榜? — 不在 MVP 范围内,等核心循环验证后评估

---

## MVP Definition

**Core hypothesis**: 玩家会觉得 "击败 BOSS → 夺取其招式 → 搭配 combo → 变得更强 → 挑战下一个 BOSS" 这个循环有趣到愿意重复 30+ 分钟,并且愿意重新开始下一局。

**Required for MVP**:
1. 1 个完整境界 (炼气期),3 个可选 BOSS + 1 个境界守护者
2. 6 种基础功法 (每个 BOSS 掉落 1 个,守护者掉落 1 个额外功法),3 种 combo 效果
3. 自动战斗系统 + 走位操作 + 灵气收集 + 境界突破循环
4. 功法槽位系统 (起始 2 槽,突破后解锁到 4 槽)
5. 基础局外解锁 (击败过的 BOSS 功法下次可用)
6. 基础 HUD (灵气条、功法展示、BOSS 标记、境界标识)
7. Web HTML5 导出,在浏览器可运行

**Explicitly NOT in MVP** (defer to later):
- 炼气期以外的境界
- 完整的功法图鉴系统
- BOSS 碎片化叙事
- 音效与音乐
- 排行榜/成就系统
- Steam 版导出

### Scope Tiers

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 1 境界, 3+1 BOSS, 6 功法 | Core loop only | 2 周 |
| **Target** | 3 境界, 9+3 BOSS, 15-20 功法, combo 系统, 局外成长 | Core + progression + meta | 6-10 周 |
| **Polish** | 全内容 + 音效 + 特效打磨 + 浏览器兼容 | Full + audio + juice | 2-4 周 |
| **Full Vision** | + 隐藏 BOSS + 功法图鉴 + 成就 + Steam 版 | All features, polished | 额外 4-8 周 |

---

## Next Steps

- [ ] Run `/setup-engine` to configure Godot 4.6 and populate version-aware reference docs
- [ ] Run `/art-bible` to establish visual identity — do this BEFORE writing GDDs
- [ ] Use `/design-review design/gdd/game-concept.md` to validate concept completeness
- [ ] Run `/prototype [core-mechanic]` to validate the core loop before writing any GDDs
- [ ] If prototype PROCEEDS: Run `/map-systems` to decompose concept into individual systems
- [ ] Author per-system GDDs with `/design-system [system-name]`
- [ ] Run `/create-architecture` to produce the master architecture blueprint
- [ ] Run `/architecture-decision (×N)` for key technical decisions
- [ ] Run `/architecture-review` to bootstrap TR registry
- [ ] Validate readiness with `/gate-check`
