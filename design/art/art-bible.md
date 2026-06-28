# Art Bible: 咫尺 (Within Reach)

*Created: 2026-06-25*
*Status: Complete*
*Game Concept: `design/gdd/game-concept.md`*
*Last Updated: 2026-06-25*

> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED — Lean review mode

---

## 1. Visual Identity Statement

**One-Line Rule**: **留白即焦点,墨色即秩序 (Negative space leads the eye; ink anchors the chaos).**

**Why this rule**: 修仙的视觉灵魂在水墨的"气韵"——但气韵不是笔触,而是**留白与浓墨的张力**。Survivor-like 的核心视觉危机是"满屏粒子淹没玩家的判断",而水墨美学恰好提供了天然解药:用大面积留白拉出焦点,用浓重墨色锚定层级。这条规则同时回答了三件事——下一个目标在哪(留白指向),玩家自己在哪(墨色定身),招式威能多大(留白被打破时的爆发感)。它不是一条美学偏好,是一条可读性纪律。

---

### Supporting Principle 1: 主角是墨,招式是泼彩 (The Hero is Ink, The Techniques are Splashed Color)

主角形象在所有境界都保持**克制的墨色剪影**——黑、白、灰为主,极少彩色,姿态凝练如工笔人物。但角色释放的功法、走过的剑气、踏出的步罡——可以是任何颜色、任何亮度、任何粒子密度。**主角越强,主角本身越静;招式越强,招式越狂。** 飞升期的玩家不是一个发光的人,而是一个一笔墨痕被五彩风暴环绕的"风暴之眼"。境界突破节点(筑基/金丹/元婴/大乘)只对剪影做**最小幅度**的进化:多一缕发丝、衣袂多一道飘带、脚下多一圈道纹——保持识别连续性,把视觉预算留给招式。

- **Serves Pillar**: 越战越强 (Only Growth, No Loss) + 自创流派 (Your Style, Your School)
- **Design Test**: 当**"这个新功法/特效应该有多亮、多大、多花"模糊时**,这条原则说**"招式可以无上限地华丽,但绝不允许借此让主角本身变得更复杂或更亮。主角的墨色是恒定的"**。当**美术想给元婴期主角加一圈持续光环**时,这条原则说**"光环属于招式层,不属于角色层——只在释放时出现,平静时收回"**。

---

### Supporting Principle 2: 下一目标永远拥有最深的墨 (The Next Goal Always Holds the Darkest Ink)

在任何一帧画面里,视觉权重的最高点必须是"玩家需要去的地方"——下一个 BOSS、下一个境界突破点、下一个掉落。**手段是反 Survivor-like 直觉的:不是让目标更亮,而是让目标周围更"空"、目标本身更"重"。** BOSS 出场时,周围粒子退潮、留白扩张,BOSS 以一笔最浓的墨锚定屏幕。掉落物不闪不抖,而是落在一小块"清水"留白里。境界突破节点在灵气条上以"未染墨"的空白格预告,墨色逐步浸染——玩家**看见**自己离突破还差几滴墨。混乱由玩家的招式制造,**秩序由目标的留白维持**。这是"近在咫尺"在视觉层的硬性翻译:目标永远可寻,因为目标永远在最安静的那片空白里。

- **Serves Pillar**: 近在咫尺 (Always Within Reach)
- **Design Test**: 当**"这个新粒子/特效会不会盖住 BOSS 或目标指示"模糊时**,这条原则说**"目标周围保留一圈强制留白半径(R_clearance),任何特效进入该半径必须降透明度或被剔除——留白是 UI,不是装饰"**。当**有人想给目标加发光描边来"更显眼"**时,这条原则说**"不,清空目标周围的视觉噪音才显眼。加法解决不了的可读性,减法可以"**。

---

### Supporting Principle 3: 流派是色相,不是形状 (Schools are Hues, Not Shapes)

"自创流派"必须**一眼可辨**——但 Web/50MB 不允许为每种流派搭配画独立美术。解决方案:**功法的形状语言保持一致(剑气是斜切笔锋,符箓是方印,掌法是泼墨圆斑),但色相、饱和度、轨迹密度由流派决定。** 火系流派是赤橙浓烈、轨迹喷溅;冰系是青白疏冷、轨迹凝滞;雷系是紫白高频闪烁、轨迹折线;混搭流派则在屏幕上呈现明确的色相混合(火+雷=洋红高频,而不是"火+雷=橙紫并存的视觉噪音")。**玩家的流派应该能在一张静帧截图里被另一个玩家说出名字——靠的是颜色的整体气质,不是图标的辨认。** 这同时压死了资产成本:一套基础笔形 × 多套色板 = 无限流派表达。

- **Serves Pillar**: 自创流派 (Your Style, Your School)
- **Design Test**: 当**"两种功法搭配后视觉打架"模糊时**,这条原则说**"检查色相是否融合而非堆叠——若融合后是新的可命名色调,通过;若只是两色并列闪烁,降低其中一方的饱和度让另一方主导,或在数据层定义该搭配的混合色"**。当**有人想给新功法画一套独家粒子贴图**时,这条原则说**"先问能不能用现有笔形 + 新色板做到——绝大部分情况可以"**。

---

## 2. Mood & Atmosphere

**Design Logic**: 留白在此节有三种功能性角色——低频留白(清怪/被招式填满)、战术留白(BOSS 周围强制空白=读招窗口)、仪式留白(突破时吞没一切)。境界色调决定背景 HSL,状态决定饱和度和对比度曲线。Web 渲染不靠 GI,靠两层色块叠加(背景层 + 状态色 Overlay)和粒子密度传达能量。六个状态在 HSL 空间各有不重叠的领地——只看屏幕色调就能识别当前状态。

---

### 平常清怪 (Wave Clearing)

- **Primary Emotion**: 沉浸的专注 (immersive flow) + 微微的贪婪 (mild greed — 灵气在涨)
- **Lighting Character**: 中性色温偏暖,中等对比度,无明确方向光(均质环境光),整体亮度中段(避免视觉疲劳)
- **Color Dominance**:
  - 主色:境界基调的中低饱和版本(炼气=雾绿、筑基=暮蓝、金丹=哑金、元婴=淡紫、大乘=珠白),占 60% 屏幕
  - 辅色:主角墨色剪影 + 当前功法的流派色相,占 25%
  - 点缀:敌人轮廓与灵气粒子(金色或基调互补色),占 15%
- **Atmosphere Descriptors**: 律动的 (rhythmic)、稠密的 (dense)、可读的 (legible)、可持续的 (sustainable)、有呼吸的 (breathing)
- **Energy Level**: **active**(持续但不耗竭)
- **Key Visual Element**: 灵气粒子的稳定上升流 — 从被击败的敌人飘向左上 HUD 灵气槽,形成视觉"经济循环"的可见证据
- **Transition**:
  - 进入:从菜单/突破的高对比度溶解为中等对比度,饱和度淡入 1.5 秒
  - 退出(进入 BOSS):屏幕边缘墨色渗入,中央留白扩张,持续 0.8 秒

---

### BOSS 战 (Boss Fight)

- **Primary Emotion**: 紧绷的解读 (tense decoding) — **不是"恐惧"**,是"我看得见你的招式"
- **Lighting Character**: 冷色温(即使在暖色境界,色温向冷端偏移 15-20%),高对比度,主角与 BOSS 各有一个隐性"聚光圈"(用粒子稀释而非真实光照)
- **Color Dominance**:
  - 主色:境界基调的高饱和+暗化版本(背景被压暗 30%),占 50%
  - 辅色:BOSS 的功法色相(将被夺取的那一招)在弹幕中爆发性出现,占 30%
  - 点缀:主角墨色 + BOSS 墨色轮廓,两个墨点在画面对峙,占 20%
- **Atmosphere Descriptors**: 锐利的 (sharp)、对峙的 (confrontational)、节拍化的 (metered)、危险但清晰的 (dangerous-yet-legible)
- **Energy Level**: **frenetic**(画面信息密度峰值,但留白确保读数)
- **Key Visual Element**: BOSS 周围 1.5 倍角色直径的强制留白圈 — **任何弹幕进入此圈会变成轮廓线**,确保玩家始终能读到 BOSS 的姿态(支柱"近在咫尺"的视觉化)
- **Transition**:
  - 进入:从 Wave Clearing 溶解约 1 秒,背景饱和度先掉至灰阶再升至高饱和,**给玩家一个"屏息瞬间"**
  - 退出(胜利):时间放慢 + 全屏白闪 0.2 秒,进入"夺取功法"
  - 退出(死亡):饱和度瞬间归零,转灰阶

---

### 夺取功法 (Technique Absorbed / Victory)

- **Primary Emotion**: 顿悟 (epiphany) + 占有的喜悦 (acquisitive joy)
- **Lighting Character**: 暖色温骤升(无论境界为何,此刻都向金色偏移),极高对比度(亮部过曝、暗部加深),光照向主角中心放射
- **Color Dominance**:
  - 主色:BOSS 的流派色相从 BOSS 残影向主角倾泻,**主色权暂时交给被夺取的功法**,占 50%
  - 辅色:金色/白色光晕作为"传承"符号,占 30%
  - 点缀:主角墨色被泼彩短暂"染色"再恢复,占 20%
- **Atmosphere Descriptors**: 静止的 (suspended)、辉煌的 (radiant)、铭刻的 (inscribed)、不可逆的 (irreversible)
- **Energy Level**: **still**(时间冻结 1.5-2 秒,游戏暂停以让玩家"看见"获得了什么)
- **Key Visual Element**: BOSS 招式的核心笔形以书法笔触从 BOSS 飘向主角并"印"入主角(支柱"越战越强"的仪式可视化)
- **Transition**:
  - 进入:接续 BOSS 战的白闪,白闪退去后画面悬停在该状态
  - 退出:笔形印完后,色彩饱和度回落,直接切到菜单(若是流程关卡)或回到 Wave Clearing(若还有波次)

---

### 境界突破 (Realm Breakthrough)

- **Primary Emotion**: 蜕变 (transfiguration) + 敬畏 (awe)
- **Lighting Character**: 从冷至暖的快速过渡(0.5 秒内色温从 4000K 跃至 6500K 再至 8000K),极低对比度归于极高对比度,主角自身成为光源
- **Color Dominance**:
  - 主色:**下一个境界的基调色**(这是唯一允许预告下一境界色的状态),占 70%
  - 辅色:纯白留白扩张,占 25%
  - 点缀:主角墨色保留,但**轮廓被金线勾勒**,占 5%
- **Atmosphere Descriptors**: 神圣的 (sacred)、空旷的 (vacated)、垂直的 (vertical — 视觉重心向上)、仪式化的 (ritualized)、单数的 (singular — 只有一个焦点)
- **Energy Level**: **contemplative**(画面几乎静止,但内部张力极高)
- **Key Visual Element**: 主角脚下展开的圆形书法符印 — 由当前境界已收集的所有功法笔形构成,是玩家"流派"的可视档案(支柱"自创流派"的回响)
- **Transition**:
  - 进入:Wave Clearing 中灵气槽满 → 全屏粒子上升 → 时间放慢至 0.3x → 状态进入
  - 退出:符印闪光后,画面用下一境界的色调重启 Wave Clearing,**这是境界色切换的唯一时刻**

---

### 死亡 (Death / Defeat)

- **Primary Emotion**: 失重 (weightlessness) + 清醒的失败 (lucid defeat) — **不是悲怆**,Roguelite 死亡是循环常态
- **Lighting Character**: 完全脱色至灰阶(0.8 秒内),对比度先抬升再衰减(让主角的死亡瞬间被看清,再让世界"褪色"),无方向光
- **Color Dominance**:
  - 主色:灰阶(原境界色被抽离色相,只剩明度),占 80%
  - 辅色:主角墨色保留(唯一保留色彩信息),占 15%
  - 点缀:淡红色血墨或功法残色作为"最后一丝余温",占 5%
- **Atmosphere Descriptors**: 漂浮的 (drifting)、静默的 (muted)、悬置的 (suspended)、可重启的 (resettable)
- **Energy Level**: **still**
- **Key Visual Element**: 主角墨色剪影碎裂为若干墨点,缓慢向下漂浮(不爆炸、不消散 — "墨没有真的散")
- **Transition**:
  - 进入:BOSS 战或 Wave Clearing 的高饱和瞬间归零,0.4 秒快速脱色(避免拖沓)
  - 退出:灰阶世界淡出至纯黑约 1.5 秒,再淡入菜单

---

### 菜单/幕间 (Menus / Realm Select)

- **Primary Emotion**: 盘点的从容 (composed reckoning) + 选择的预期 (anticipatory choice)
- **Lighting Character**: 暖中性色温,低对比度(让 UI 文字最易读),柔和环境光,无戏剧性光照
- **Color Dominance**:
  - 主色:米白宣纸色/墨灰色为底 — **菜单脱离境界色**,作为"工作室"中性空间,占 50%
  - 辅色:玩家已解锁的所有功法的色相以**小色块**形式排列 — 图鉴本身就是装饰,占 35%
  - 点缀:当前选中项以**境界基调色**作为高亮,占 15%
- **Atmosphere Descriptors**: 静谧的 (quiet)、可读的 (legible)、收藏的 (curatorial)、目录式的 (archival)、可触碰的 (tactile)
- **Energy Level**: **contemplative**
- **Key Visual Element**: 横向的"功法图鉴卷轴" — 玩家收集的功法以书法笔形排列,鼠标悬停展开,既是导航又是成就墙
- **Transition**:
  - 进入:从死亡的纯黑或突破的高亮,通过纸张展开动效进入(0.6 秒)
  - 退出(开始新一局):卷轴卷起,屏幕被卷轴扫过的部分替换为下一局的境界色

---

### 状态色调速查表

| 状态 | 色温倾向 | 饱和度 | 对比度 | 留白角色 |
|---|---|---|---|---|
| Wave Clearing | 中性偏暖 | 中 | 中 | 低频/被填满 |
| Boss Fight | 偏冷 | 高 | 高 | 战术/集中在 BOSS 周围 |
| Technique Absorbed | 暖至金 | 极高 | 极高 | 被泼彩短暂占据 |
| Breakthrough | 冷→暖→白 | 低至无 | 极高 | 仪式/吞没一切 |
| Death | 灰阶 | 零 | 衰减 | 失重/漂浮 |
| Menus | 暖中性 | 低 | 低 | 收纳/作为底色 |

---

## 3. Shape Language

**Design Logic**: 形状服从墨色秩序,色彩负责招式狂欢。形状本身极简,所有花哨发生在色相和粒子层。目标的形状永远最"重",流派改色不改形。任何关键剪影必须在 32×32 像素下可读。

---

### 3.1 Character Silhouette Philosophy

**总策略**: 墨团骨架 + 飞白姿态。主角不是被"线条"描出来的,而是被"墨的重心 + 一两笔飞白"定义的。

#### 三类实体的笔形归属(混合策略)

| 实体 | 笔形体裁 | 墨色状态 | 独占特征 | 出现密度 |
|---|---|---|---|---|
| **玩家** | 书法体(毛笔写出的人形) | 浓墨 + 飞白(运动中的笔) | **飞白**(只有玩家拥有) | 1 |
| **杂兵** | 墨团(几何化墨滴) | 灰墨/淡墨(静止的墨滴) | 没有锋,没有方向 | 50-150 |
| **精英** | 墨团+一笔锋 | 中墨 + 一处焦墨 | 拥有一处"锋",但不动 | 3-10 |
| **BOSS** | 书法体(被放大到超人形/山形/兽形) | 泼彩(非墨) | 周围 1.5x 留白圈 + 泼彩晕染 | 1 |

**关键约定**: 玩家是唯一同时拥有"飞白 + 锋 + 方向"的实体。杂兵剥夺所有三项,BOSS 用泼彩跳出墨语言整体——三者永远不会被混淆。

#### 缩略图层级的可读性策略

| 距离 | 玩家剪影承载什么信息 | 失去什么 |
|---|---|---|
| 全屏俯视(Survivor 默认视角) | 一团向运动方向倾斜的墨,带 1-2 道飞白 | 五官、服饰细节 |
| 中距离(暂停/突破特写) | 墨团里能读出头、躯干、单手挥袖的姿态 | 表情 |
| 特写(过场/死亡) | 完整书法笔触构成的人形,可见衣纹、发丝飞白 | — |

**核心规则**: 玩家剪影永远偏离正圆。圆是敌人和波次的语言。玩家是有方向、有锋的不对称墨形。

#### 境界突破:笔法演化,轮廓不动

从炼气到大乘,玩家的**人形轮廓和比例完全不变**。变化只发生在"墨的状态":

| 境界 | 笔法状态 | 飞白密度 | 周身留白半径 | 配套泼彩(招式) |
|---|---|---|---|---|
| 炼气 | 淡墨速写,边缘虚 | 1 道飞白 | 0.5x 角色直径 | 极小,薄一层色 |
| 筑基 | 中墨,边缘清 | 2 道飞白 | 0.8x | 招式色相饱和度+30% |
| 金丹 | 浓墨,出现明显飞白 | 3-4 道飞白,袖摆出锋 | 1.2x | 招式开始有粒子拖尾 |
| 元婴 | 焦墨,边缘锋利 | 5+ 道飞白,衣纹可见 | 1.5x | 招式色彩可叠加 |
| 大乘 | 泼墨 + 留白法相(残影) | 飞白与本体融合 | 2.0x,留白本身形成法相轮廓 | 招式与角色共用泼彩晕染 |
| 飞升(终局) | 全身留白 + 几何符号化 | 飞白全部退去,转为**纯留白剪影** | 全屏留白 | 所有招式色彩通调为金白——出墨,入道 |

**不动的清单**: 头身比、站姿、武器位置、衣型轮廓。
**动的清单**: 墨的浓度、飞白数量、周身留白半径、与招式泼彩的边界融合度。

**服务于:支柱#2"越战越强"**(每次突破看得见自己的墨变浓) + **支柱#1"近在咫尺"**(轮廓不变=玩家任何时候 0.1 秒认出自己)。

---

### 3.2 Environment Geometry

**总策略**: 横向长卷,有机曲线主导,几何点缀。修仙地图遵循"山水长卷"结构而非"地牢矩形"。每境一卷,卷轴方向就是进度方向。

#### 五境 + 飞升的形状倾向

| 境界 | 主导几何 | 配角几何 | 视觉参考 |
|---|---|---|---|
| 炼气(凡间) | 平缓水平线 + 矮丘曲线 | 偶有方形屋顶/田埂 | 富春山居图(平远) |
| 筑基(山门) | 中等坡度曲线 + 阶梯 | 方形殿门、圆形月亮门 | 千里江山图局部 |
| 金丹(秘境) | 险峻锯齿山形 | 不规则岩石块面 | 溪山行旅图(高远) |
| 元婴(洞天) | 螺旋/漩涡曲线 | 悬浮几何法阵(圆/六边形) | 早春图(深远) + 抽象法阵 |
| 大乘(虚空) | 留白主导,曲线漂浮 | 几何符号孤立悬浮 | 八大山人的极简空间 |
| 飞升(终局) | 纯留白,无几何形 | 无 | 水墨的终极——"无" |

**关键约定:地图上没有画出来的路。** 玩家走在留白里。所有的墨都是"不能走的东西"。这是水墨题材最大的可读性红利——"凡有墨处皆障碍,凡有留白处皆可行"。

#### 为什么曲线主导服务"近在咫尺"

- 曲线引导视线:山势起伏天然把眼睛引向下一座峰——也就是下一个 BOSS
- 直线分割空间:矩形房间使方向感模糊,曲线长卷只有"向前/向后"
- 几何=人为目标标记:看到法阵和印章=知道这里有东西

#### 地图边界、障碍物、路径的形状规则

| 元素 | 形状规则 | 墨色 | 是否可破坏 |
|---|---|---|---|
| 地图边界 | 浓墨横笔,似宣纸卷轴边 | 焦墨 | 不可 |
| 不可破坏障碍 | 圆润岩石/树/山(自然有机形) | 中墨 | 不可 |
| 可破坏障碍 | 带锋的岩石/瓦片(尖角暗示脆弱) | 浓墨边缘 + 内部留白 | 可 |
| 主路径 | 不存在显式路径,留白本身就是路径 | — | — |
| 兴趣点(宝箱/事件) | 几何符号(印章方/法阵圆) | 朱砂红 | — |

---

### 3.3 UI Shape Grammar

**总策略**: 功能几何为骨,印章语言为皮。UI 不模仿毛笔笔触(那会读不清),也不走纯扁平(那会割裂)。UI 的本体是**印章**——方形红章和圆形闲章是修仙世界本来就有的几何语言,且天然适合做按钮。

#### UI 基本形状库

| 元素类型 | 形状 | 来源 | 为什么 |
|---|---|---|---|
| 主按钮 | 圆角矩形(方印) | 名章 | 印章是水墨世界的"功能 UI",天然几何 |
| 次按钮 | 圆形(闲章) | 闲章 | 视觉权重低于方印,层级清晰 |
| 模态/弹窗 | 矩形 + 四角微飞白磨损 | 宣纸边 | 几何主体保证读性,边缘水墨化保证氛围 |
| 进度条 | 直线矩形,墨色填充由左至右晕开 | 卷轴展开 | 几何形状,但填充用水墨晕染过渡 |
| 数字/文字 | 等宽几何字体为主,标题用书法体 | — | 数字必须可读,标题可氛围化 |
| 图标 | 小篆/楷书单字 + 极少符号 | 印文 | 一个字胜过一个图标,且符合题材 |
| 反馈(伤害飞字/拾取) | 等宽数字,无水墨化 | — | 战斗中信息必须 0 装饰 |

#### "呼而不乱"的三条规则

1. **形状几何,纹理水墨**: 形状本身是矩形/圆形,但描边和填充可以用墨色渐变和飞白。形状负责读性,纹理负责氛围。
2. **HUD 越战斗越克制,菜单越叙事越水墨**: 战斗 HUD 接近扁平几何;暂停菜单和功法面板允许大量水墨装饰;主菜单和过场是全水墨。
3. **红色独占强反馈**: 朱砂红(印章红)只用于"重要功能性 UI 元素"(主按钮、关键提示、突破确认)。世界里的红只用于敌方危险预警。两种红绝不在同屏同时高饱和出现。

#### UI 与世界的色彩隔离

UI 用**纯白(宣纸白)+ 浓墨黑 + 朱砂红**三色为主。世界用的所有泼彩(蓝、绿、紫、金等)**不出现在 UI 上**。这保证玩家任何时候看到彩色就知道"那是游戏世界",看到三原色就知道"那是系统"。

---

### 3.4 Hero Shapes vs. Supporting Shapes

#### 主角形状语言(Hero Shapes)

全游戏只属于五类对象:

| Hero Shape | 拥有者 | 用法 |
|---|---|---|
| **飞白笔触** | 玩家 + 玩家招式 | 任何有飞白的形状=玩家相关 |
| **泼彩晕染** | BOSS + BOSS 招式 + 突破特效 | 任何彩色晕开的形状=高威胁/高奖励 |
| **强制留白圈** | 下一目标 + BOSS + 玩家(突破瞬间) | 周围有空的形状=注意它 |
| **朱砂红印章** | 关键 UI + 突破确认 | 红方块=必须点 |
| **几何法阵** | 兴趣点 + 事件触发器 | 看到几何在世界里=有事可做 |

#### Survivor-like 满屏混乱下的形状层级保持

当屏幕上有 150+ 实体时,以下规则强制执行:

**规则 1: Hero Shape 数量上限**
- 全屏同时只能有 **1 个**强制留白圈(下个目标或 BOSS,二选一)
- 全屏同时只能有 **1-3 处**泼彩晕染(BOSS 本体 + BOSS 当前招式,杂兵招式不准用泼彩)
- 飞白只属于玩家,杂兵招式即使密集也是实心墨

**规则 2: 杂兵的"配角税"**
- 杂兵剪影**禁止**使用以下任一特征:飞白、泼彩、锐角、不对称、几何法阵纹饰
- 杂兵的颜色饱和度上限为 30%
- 杂兵的尺寸不能超过玩家的 0.8x(BOSS 例外,2-3x)

**规则 3: 招式的色彩独占 vs 形状共享**
- 所有招式(玩家+BOSS)共享同一套笔形骨架(流派是色相不是形状)
- 区分敌我完全靠颜色:玩家招式用流派色板,BOSS 招式用红/紫/黑警示色
- 唯一形状区分:玩家招式起笔处有飞白,BOSS 招式起笔处有泼彩晕染
- 混合流派(如火+雷):笔形不变,色相在屏幕上融合成新的可命名色调(火+雷=洋红)

**规则 4: 留白即层级**
- 任何一个 Hero Shape 周围必须有最小留白半径(目标=1.5x,BOSS=2x,玩家=0.5-2x 随境界)
- Supporting Shape 不准有强制留白圈
- 当多个 Hero Shape 试图同时出现,系统强制压低优先级低的一方

---

### Shape Language QA Tests (Section 8 Asset Standards 中将作为验收标准)

每一个新美术资产必须通过:

1. **32×32 缩略图测试**: 玩家/BOSS/杂兵在 32 像素下是否仍可区分?
2. **150 实体压力测试**: 模拟满屏战斗,玩家剪影是否在 0.2 秒内可识别?
3. **流派切换测试**: 同一招式换三套色板,形状骨架是否完全一致?
4. **境界对比测试**: 并排展示炼气-飞升六形态,轮廓是否一致、墨的状态是否阶梯式递增?
5. **UI/世界隔离测试**: UI 元素和世界元素并排展示,是否能立刻分辨"哪个是系统、哪个是世界"?

---

## 4. Color System

> **Pillar bind**: Color is governed by the One-Line Rule. The world may sing in pigment, but the player remains a sliver of ink, and the UI remains paper. Color is **information**, not decoration — every hue earns its place by saying something the line cannot.

---

### 4.1 Primary Palette (Master 7 + Player)

The game's entire visual signal is built from seven core hues plus the silhouette ink. Every other color in the project must be a tint, shade, or low-saturation derivative of these. No off-palette hues without Art Director sign-off.

| Role | Name | Hex (conservative) | Where it lives | What it says |
|---|---|---|---|---|
| **Player Ink** | Mò (墨) | `#1A1D22` | Player silhouette, ally outlines, calligraphic strokes, scene framing | "You. The line. The reader's eye." Pure value, near-zero chroma — anchors hierarchy. |
| **Paper** | Xuān Bái (宣纸白) | `#F0E8D8` | World background, UI panel base, negative space | Stillness, possibility, breath. Not pure white — paper has warmth. |
| **Cinnabar** | Zhū Shā (朱砂) | `#B8403A` | Seals, BOSS tells, critical UI, blood-moment punctuation | Danger, intention, the master's seal. **Scarce by law** (see 4.2). |
| **Cloud Indigo** | Yún Qīng (云青) | `#3B5C78` | Sky washes, water, foundation-realm aura | Depth, distance, Daoist sky. |
| **Pine Green** | Sōng Lǜ (松绿) | `#4D7950` | Early-realm world tint, herb/qi pickups, forest washes | Origin, qi nascent, the mortal ground. |
| **Goldleaf** | Jīn (金) | `#B8933D` | Golden-core realm, breakthrough flashes, treasure | Achievement, the inner pill, sacred metal. |
| **Twilight Violet** | Zǐ Xiá (紫霞) | `#5E426E` | Nascent-soul aura, dusk skies, sect mystery | Spirit, the soul stepping outside flesh. |
| **Spectrum Light** | Liú Guāng (流光) | Baked gradient: `#8DC4CF→#E4C8D6→#F0E4C0` | Mahayana ambient (R5), late-game world wash | Realm-5 chromatic shift. See Fallback Spec below. |

**Palette laws:**
- Player and allies **never** use any color from this palette as fill. They are always `Mò` ink on `Xuān Bái` paper.
- BOSSES use the **opposite** rule: they are saturated splash-color (泼彩) on the paper world. The contrast IS the threat.
- Pickups borrow exactly one hue from the master palette and use it pure — readability over prettiness.
- **Conservative hex values**: All swatches respect sRGB safe range (chroma ≤50, lightness L18-L92, no clipping near gamut edges). Godot 4.6 Compatibility renderer Web export handles this range reliably.

---

### 4.2 Semantic Color Vocabulary

Color in 《咫尺》 is a **language**, not a mood board. Each hue means one thing, enforced across every system.

| Hue | Meaning | Permitted uses | Forbidden uses |
|---|---|---|---|
| **Red (朱砂)** | *Lethal intent.* Something is about to kill you or be killed. | BOSS wind-up tells, crit numbers, low-HP vignette, "danger" UI states | Never a "pretty accent." Never on neutral pickups. Never on friendly NPCs. |
| **Blue (云青)** | *Distance, stillness, water/sky/qi.* | Sky, water bodies, Foundation-realm aura, defensive shields | Not for "info" UI (use ink). Not for cold damage — cold is **white** here (see 4.5). |
| **Green (松绿)** | *Origin, growth, mortal-realm life.* | Herbs, qi pickups, Realm-1 ambient, healing | Not for "go"/"confirm" UI — use ink+paper. |
| **Gold (金)** | *Sanctity, achievement, the inner pill.* | Realm-up moments, legendary drops, breakthrough flash, Golden Core aura | Never on common UI buttons. Budget it like a special effect. |
| **White (宣纸/留白)** | *Breath, focus, the unwritten.* | Negative space, paper base, ice/frost element, divine ambient | Never as fill on the player. Empty space is a deliberate compositional act. |
| **Black (墨)** | *Order, self, structure, the line.* | Player, UI text, world strokes, ally outlines | Never as "danger" cue (red owns that). Every black mark must mean something. |
| **Purple (紫霞)** | *Spirit, soul-stuff, the uncanny.* | Nascent Soul-tier enemies, soul/mind effects, dream/illusion | Not for "magic in general" — magic colors are element-specific (4.5). |

**The Cinnabar Budget (guidance)**: A single screen should contain **no more than ~5% red pixels** under normal play. When red exceeds 15%, the player should *feel* the room turn hostile. This is a compositional guideline, not a hard gate — use judgment.

---

### 4.3 Per-Realm Color Temperature

The cultivation ladder is also a **color ladder**. Each realm shifts the world's ambient color grade so the player feels their rise without reading.

| Realm | Name | Primary | Secondary | Temp | Saturation rule |
|---|---|---|---|---|---|
| **R1** | 炼气 Qi-Refining | `#4D7950` Pine Green | `#9CAD8E` faded sage | ~5500K neutral | Low (chroma 20-35) |
| **R2** | 筑基 Foundation | `#3B5C78` Cloud Indigo | `#7A96A8` mist | ~6500K cool | Low-mid (chroma 30-45) |
| **R3** | 金丹 Golden Core | `#B8933D` Goldleaf | `#DCC07A` warm wash | ~4200K warm | Mid (chroma 45-55) |
| **R4** | 元婴 Nascent Soul | `#5E426E` Twilight Violet | `#8C72A0` dusk | ~3800K warm dusk | Mid-high (chroma 50-60) |
| **R5** | 大乘 Mahayana | Baked prismatic gradient (see Fallback) | — | Shifting / prismatic | High but desaturated |
| **R6** | 飞升 Ascension | Paper + Ink — only the line remains | — | Hueless | Zero saturation |

**Realm grade application**: Applied as a **screen-space CanvasModulate tint**, not by repainting assets. Keeps asset pipeline single-source while giving each realm a distinct emotional temperature.

**Realm transition VFX**: At each breakthrough, the screen briefly washes to the *next* realm's primary color, then resolves to that realm's full grade. A literal hue-shift you can feel.

**Liú Guāng Fallback Spec (Realm 5)**: True iridescence requires per-pixel hue rotation not available in Godot 4.6 Compatibility renderer. The **default ship path** uses a 3-stop baked prismatic gradient (`#8DC4CF → #E4C8D6 → #F0E4C0`) as a static CanvasModulate texture, cycling at 0.05 Hz. No HDR, no runtime shader. The true iridescent version is documented as an aspirational stretch for Forward+ renderer / Steam build.

---

### 4.4 UI Palette (Isolation Strategy)

**The hard rule**: *World pigment never crosses into UI. UI pigment never crosses into world.*

| Token | Hex | Use |
|---|---|---|
| **UI Paper** | `#F0E8D8` (matches world Xuān Bái but flat, no LUT, no texture) | Panel base, tooltips, menu backgrounds |
| **UI Ink** | `#1A1D22` | All text, icons, borders, line elements |
| **UI Cinnabar** | `#B8403A` | Only: critical alerts, low-HP, BOSS-incoming, destructive confirmations |

That is the *entire* UI palette. No greens for "go". No greys for "disabled" (use ink at 40% opacity). No blues for "info".

**Why UI white ≠ world white**: World paper is filtered through realm LUT and ambient. UI paper is a flat, unlit, ungraded surface that ignores the realm LUT — it renders **after** the CanvasModulate pass. Same hex, different semantic register.

**UI accent budget (guidance)**: Cinnabar is the only chromatic UI color. It should occupy <3% of UI pixels at rest. Damage numbers float in the **world layer** (not UI), following element color (4.5).

---

### 4.5 Technique Element Palette

Each combat element has a dedicated hue. Element identification must be readable in <100ms — color does most of that work.

| Element | Color | Hex | Visual character |
|---|---|---|---|
| **Fire (火)** | Cinnabar-warmed | `#C45A3A → #D49048` gradient | Splash-ink feathered edges, warm halo |
| **Ice (冰)** | Paper-white + faint indigo edge | `#EDF0F2` core, `#3B5C78` edge | Crystalline strokes — uses the page's white as the threat |
| **Wind (风)** | Near-colorless ink wash | `#1A1D22` at 25% opacity | Calligraphic sweeps — visible only by what it moves |
| **Lightning (雷)** | Violet + paper flash | `#5E426E` arcs, `#F0E8D8` flash core | Hard zig-zag ink, single-frame paper-white flash |
| **Sword (剑)** | Pure ink + cold edge | `#1A1D22` blade, `#D8DEE4` gleam | The cleanest, sharpest line in the game |
| **Fist (拳)** | Ink with cinnabar impact | `#1A1D22` motion, `#B8403A` impact | Heavy ink mass, dust kicks, single red splash on contact |

#### Element Fusion Rules

| Fusion | Result | Color | Rationale |
|---|---|---|---|
| Fire + Lightning | Heavenly Fire (天火) | `#DCC07A` gold-violet shimmer | Alchemist's flame |
| Fire + Wind | Conflagration (烈焰) | `#D27040` saturated orange, wider spread | Wind feeds fire |
| Fire + Ice | Steam Burst (蒸气) | `#EBE4D4` warm fog, low chroma | Cancellation — both lose chroma |
| Ice + Wind | Blizzard (霜风) | `#D4DEE4` pale blue-white | Both quiet amplify |
| Ice + Lightning | Frost Shock (霜雷) | `#A0ACC0` pale violet-blue | Rarest cold |
| Lightning + Wind | Heaven's Roar (天怒) | `#5E426E` deeper violet, wider arcs | Pure spirit-storm |
| Sword + (any) | Imbued Blade | Blade stays ink; edge gleam shifts to element hex | Sword is structurally ink |
| Fist + (any) | Imbued Strike | Ink motion + impact bloom shifts to element hex | Mirror of Sword's rule |
| 3-element | Liú Guāng | Spectrum Light (see 4.3 Fallback) | Ultimate — realm-gated |

---

### 4.6 Colorblind Safety

#### Known risk pairs

| Pair | Risk type | Backup cue |
|---|---|---|
| **Pine Green ↔ Cinnabar** | Deuteranopia / Protanopia | Herbs use **leaf-shape outline** + upward float; danger uses **pulsing radial vignette** + audio sting |
| **Goldleaf ↔ Pine Green** | Deuteranopia | Gold breakthrough uses **radial burst shape** unique to it; herbs keep leaf outline |
| **Twilight Violet ↔ Cloud Indigo** | Tritanopia | Nascent Soul enemies carry **soul-wisp particle trail**; sky is non-interactive backdrop |
| **Cinnabar ↔ ink** | Low value-contrast on some monitors | BOSS tells always include **1-frame paper-white flash + screen-shake + audio cue** |
| **Spectrum Light** | Unpredictable across CVD types | R5 gameplay-critical signals fall back to Trinity (paper/ink/cinnabar) + element shapes |

#### Universal CVD Rules

1. **No signal is color-only.** Every threat, pickup, and state change has at least one of: shape, motion, position, value contrast, audio cue.
2. **Value contrast first, hue second.** All critical UI passes a grayscale test.
3. **Cinnabar protected.** The Cinnabar Budget is also a CVD-friendliness rule — red surrounded by paper-white reads under red-green blindness as a value spike.
4. **Accessibility toggle (deferred to ux-designer)**: Planned "High Contrast Ink Mode" replaces realm LUT with flat paper+ink+single-accent palette, accent hue user-selectable.

---

## 5. Character Design Direction

> **Pillar bind**: How do 150+ entities coexist on screen without breaking the "player is ink, everything else is its weather" reading? The answer: stratify what each entity is allowed to do with ink. Players own flying-white (飞白). Bosses own splash-color (泼彩). Mobs own neither. Elites borrow one drop of one. No exceptions.

---

### 5.1 Player Character Visual Archetype

**Archetype**: A calligraphic figure — a brushed human shape, not a drawn one. The player **is** the brush-stroke.

**Base proportions (locked across all six realms)**:

| Attribute | Spec | Why locked |
|---|---|---|
| Head-to-body ratio | 1 : 5.5 (slightly stylized, not chibi, not realistic) | Reads at 32px; adult cultivator register |
| Stance posture | Forward-leaning ~8°, weight on front foot, trailing sleeve extended back | Always pointing toward progress (偏离正圆 rule) |
| Silhouette aspect | Tall ovoid skewed forward (1 : 1.4 W:H, never circular) | Circle = enemy/wave language. Player = direction |
| Weapon position | Right hand low and forward, never above shoulder at rest | Head-shoulder mass is the brightest mò mass |
| Sleeve volume | Both sleeves loose, trailing sleeve ~1.3× leading sleeve | Trailing sleeve is the 飞白 carrier |

**Per-Realm Ink State (the only thing that changes)**:

| Realm | Mò density | 飞白 count & location | Edge | Halo radius |
|---|---|---|---|---|
| **R1 炼气** | 60% (washy) | 1 stroke, trailing sleeve only | Soft feathered | 0.5× |
| **R2 筑基** | 75% | 2 strokes (sleeve + back hem) | Defined | 0.8× |
| **R3 金丹** | 88% | 3-4 strokes (add hairline + leading cuff) | Crisp, broken edge | 1.2× |
| **R4 元婴** | 100% (焦墨) | 5+ strokes, garment folds legible | Razor, single-pixel | 1.5× |
| **R5 大乘** | 100% body + 60% dharma residue trailing 0.4s | Flying-white fuses with body | Edges dissolve into paper | 2.0× — halo IS silhouette |
| **R6 飞升** | 0% body, 100% halo | All flying-white retracted — figure is paper-shaped void outlined in 1px gold | None — figure is absence | Full screen |

**Flying-White Language (飞白 — player's exclusive sign)**:

1. **Direction**: Every stroke points opposite movement vector — the wake of motion.
2. **Density couples to velocity**: At rest = realm baseline count. At max dash = doubled for motion duration + 0.2s tail-out.
3. **Strokes ≠ particles**: Rendered as shader-driven texture mask on silhouette, not as spawned VFX. One drawcall.
4. **No flying-white on enemies, ever.** The hardest rule in the project.

**Player palette (locked)**:
- Fill: `Mò #1A1D22`
- Edge gleam (R3+ weapon only): `#D8DEE4`
- Breakthrough-moment outline: `Jīn #B8933D`
- **No element color ever stains the player body.**

---

### 5.2 Boss Visual Hierarchy

**Archetype**: A boss is the same brush language scaled to the size of weather.

**Universal Boss Rules**:

| Rule | Spec |
|---|---|
| **Scale** | 2.0-3.0× player (humanoid); up to 5.0× (mountain/beast) |
| **Silhouette** | Calligraphic — same brush body as player, at landscape scale |
| **Color rule** | Body is **泼彩** (splash-color) — NOT mò. The negation of player identity |
| **Forced ring** | 2.0× boss bounding-box radius cleared of mob/projectile clutter |
| **Tell color** | Always `Zhū Shā #B8403A`, regardless of element |
| **Element wash** | Boss's primary element saturates 60-70% of splash body |

**Three Boss Body Archetypes**:

| Archetype | Form | Movement | Suitable realms |
|---|---|---|---|
| **超人形 (Superhuman)** | Giant calligraphic humanoid, 2.0-2.5× player | Anchored, deliberate poses | R1, R2, R4 |
| **山形 (Mountain-form)** | Landscape-scaled mass, 4-5× player | Slow-shifting bulk, limbs extrude/retract | R3, R5 |
| **兽形 (Beast-form)** | Calligraphic beast, 3-3.5× player | High velocity, sweeping arc-attacks | R2, R3, R4 |

**Realm Assignment**:

| Realm | Boss archetype | Element | Notes |
|---|---|---|---|
| R1 炼气 | 超人形 (rival sect elder) | Fist/Sword | First real enemy, stays close to player scale |
| R2 筑基 | 兽形 (corrupted spirit-beast) | Wind + Ice | First time scale exceeds 3× |
| R3 金丹 | 山形 (fallen elder's pill furnace) | Fire + Lightning (天火) | Mountain-form matches jagged realm geometry |
| R4 元婴 | 超人形 (player's discarded soul-fragment) | Lightning + soul-wisp | **Mirror-of-player**: same silhouette, splash instead of mò |
| R5 大乘 | 山形 (previous cultivator who failed ascension) | Liú Guāng | Boss IS the prismatic wash |
| R6 飞升 | *Deferred to narrative-director* | — | Cinematic, not Survivor encounter |

> **R4 note**: If narrative has a different antagonist locked, swap concept but keep the mirror archetype mechanic — same silhouette skeleton, mò↔splash inversion. The visual load-bearing role is what matters.

**Boss Tell Hierarchy (universal 4-beat rhythm)**:

1. **Charge (1.0-1.5s before)**: Cinnabar splash blooms at strike origin. Bloom radius previews AoE.
2. **Mid-charge (0.5s before)**: Single 1-frame paper-white flash.
3. **Strike**: Element color fires along previewed shape. Cinnabar consumed.
4. **Recovery**: Body resaturates; 2.0× ring re-establishes.

---

### 5.3 Enemy/Mob Identity Rules

**Archetype**: Mobs are **ink drips** — the calligrapher's brush flicked too hard. Not characters; weather. Density, direction-as-a-swarm, color-temperature, but no individuality.

**The Mob Contract (配角税)**: A mob surrenders all five:
1. No 飞白 (player's sign)
2. No 泼彩 (boss's sign)
3. No acute angles (player+boss own asymmetry)
4. No bilateral asymmetry (mobs are round/blobby/radially symmetric)
5. No geometric ritual marks (interest points, not entities)

**5 Mob Types — differentiated by motion behavior, not static silhouette**:

| Type | Silhouette | Size | Color | Movement |
|---|---|---|---|---|
| **墨滴 (Ink Drop)** | Circle | 0.6× player | `#4A4D52` | Linear drift toward player |
| **散墨 (Scattered Ink)** | Half-circle | 0.4× player | `#6A6D72` | Curved swarm pathing |
| **闷墨 (Sluggish Ink)** | Lumpy ovoid | 0.8× player | `#3E3A36` | Slow, predictable line |
| **飞墨 (Flying Ink)** | Teardrop, rounded point | 0.5× player | Realm-tinted grey | Hover at range, project drips |
| **群墨 (Cluster Ink)** | Bunch of circles (3-5) | 0.7× player | Mid-grey | Drift; scatter on hit as 散墨 |

> **Cap at 5 types.** If gameplay needs more variety, add modifier behaviors to existing types (e.g. "ink drop with knockback aura"), not a 6th archetype.

**Elite Mobs** — the ONE exception to the contract:
- Exactly one sharp ink-stroke (一笔锋) — fixed, static, asymmetric mark
- Stroke position encodes threat: top=ranged, side=charge, bottom=AoE
- Size: 1.0× player (between mob 0.8× and boss 2.0×)
- Color: `#5A5D62` body + one drop of element hex in the stroke only

**Realm Density**:

| Realm | Mob density | Elite frequency |
|---|---|---|
| R1 | 30-50 | 0-1 |
| R2 | 50-80 | 1-2 |
| R3 | 80-110 | 2-3 |
| R4 | 100-130 | 3-4 |
| R5 | 120-150+ | 4-5 |

---

### 5.4 Visual Distinguishability at Scale

**The 150-entity legibility problem**: Player must locate themselves in <100ms. Three independent signals, any one sufficient:

| Signal | Mechanism | Works even when... |
|---|---|---|
| **1. Flying-white wake** | 1-5 white strokes opposite motion, shader on silhouette (not particles) | Peak density, screen shake, partial splash coverage |
| **2. Forced negative-space halo** | 0.5-2.0× radius cleared zone; mobs/particles culled or transparent | Stationary, flying-white retracted, screen saturated |
| **3. Mò value-spike** | Only `#1A1D22` entity on screen; mobs ≤ `#3E3A36`; boss is splash-color | Grayscale, colorblind, poor monitor |

All three must fail simultaneously for the player to become unreadable — impossible in valid game state.

**Boss Recognition Triad**: Scale (2-5× all else), Splash-color (only >30% chroma entity), 2.0× ring.

**Stress-Test Scenarios**:

| Scenario | Pass criterion |
|---|---|
| R5 peak fight | Player+boss findable in <2s by new viewer in static screenshot |
| Player at rest, boss casting | Player findable in <100ms via halo + mò value-spike |
| Grayscale conversion | Player remains darkest value; boss remains highest-contrast silhouette mass |
| 32px thumbnail | Player = directional asymmetric mark; boss = largest, ringed-by-emptiness mass |
| New player | "Which one is me" answerable in first frame without instruction |

**Mass-Scaling Discipline**:
1. **No new visual signal class.** New enemy = motion behavior or size variant, never new color tier/flying-white/splash.
2. **Splash rationed by entity count** — max 1 boss splash + 1 player splash simultaneously.
3. **Negative-space rings non-negotiable.** If spawn density violates the boss ring, **spawn density is wrong**, not the ring. Hard line — escalate to creative-director if pushed.

---

## 6. Environment Design Language

> **Core positioning**: Post-Cultivation Ruin Aesthetic. The world is not thriving immortal sects — it's the traces left by those who once cultivated here. Architecture and nature follow one rule: **man-made things are being softened by time**. Right angles weather into curves, roof tiles are swallowed by moss, railings are pulled into arcs by vines.

---

### 6.1 Architectural Style & Cultural Language

**Cultural references (by weight)**:

1. **Song Dynasty landscape painting's negative-space narrative** — Dominant reference. 70% of the map belongs to emptiness (mist, water, sky, open ground); 30% is identifiable objects.
2. **Southeast Asian ruin aesthetics** — Angkor Wat's tree-strangled towers. Used in R3's "broken cave dwelling" texture.
3. **Daoist temple de-axialization** — Deliberately broken symmetry. Cultivators need no object of worship, so architecture has no center — only paths.
4. **Tang/Song poetry's "human-absent realm"** — "Empty mountain, no person seen, yet human voices echo." Spatial presence over object presence.

**Architectural element dictionary**:

| Element | Realms | Visual role |
|---|---|---|
| Broken steles (wordless, half-buried) | R1-R5 | Path anchor — eye hook in the white space |
| Wood/stone bridges (often broken) | R1, R2 | Hints "once passable, now severed" |
| Temple remnant walls (one wall, no roof) | R2, R3 | "Door to nothing" — open-ended narrative |
| Furnaces / incense burners (toppled/half-buried) | R3, R4 | Hints cultivators once paused here |
| Floating broken stones (unsupported rock masses) | R4, R5 | Physical impossibility signals realm elevation |
| Void fissures (wounds in space itself) | R5 | "Not-white" within the white — black negative form |
| Nothing (pure space) | Ascension | The withdrawal of elements IS the element |

**Forbidden elements**: Wuxia-style flying eaves, photorealistic brick textures (budget + curve-dominant conflict), any "intact" building, modern xianxia floating islands + crystal towers.

**World-lore binding**: The player is a **latecomer cultivator**. Every environment they see is traces left by predecessors. This narratively mirrors the Survivor-like "alone against the tide" — you are the only living person in this landscape.

---

### 6.2 Texture Philosophy

**Core approach: Flat-shaded with Procedural Noise Overlays**.

**Why not photorealistic PBR**:
1. 50MB cap — one PBR material set (4 channels × 1024²) ≈ 4MB; five realms' textures would eat 40MB+
2. Web/Compatibility renderer — PBR computation cost in WebGL2 is significant; GPU budget belongs to enemies and particles
3. Conflicts with curve-dominant philosophy — photorealistic textures pull the eye to surface detail; players should read silhouettes, not materials

**Implementation**:
- **Base color**: One flat color per mesh, no texture. Colors from Section 4.3 realm palettes.
- **Variation layer**: Single-channel noise texture (256×256, ~64KB) shared across the entire game for color variation, moss spots, weathering.
- **Fake lighting**: Gradient vertex colors painted on meshes — the Compatibility backend's cheapest "3D feel".
- **Outline**: Key silhouette elements (steles, broken bridges, furnaces) use subtle backface outline pass.

**Texture budget (of 12-15MB sub-budget within 50MB total)**:

| Category | Budget |
|---|---|
| Shared noise textures (×3 variants) | ~200KB |
| Realm color LUTs (×6) | ~50KB |
| Character/enemy sprites | ~6MB |
| Environment element textures | ~3MB |
| UI / VFX | ~3MB |
| Buffer | ~2MB |

**Consistency rule**: Within a realm, all environment elements share 4-6 flat colors. Noise overlay intensity is a **realm variable**: R1=strong (more natural impurities), R5=weak (purer white space). No single prop gets its own independent texture style.

---

### 6.3 Per-Realm Environment Specs

**Universal rule**: All scenes implemented as **2D CG background images** with parallax layers. Characters and enemies are 2D sprites overlaid. Each background: 1920×1080 WEBP (~300KB), split into 3-5 parallax layers (far mountains / mid-ground / near-ground / foreground silhouette / mist particles).

---

#### R1 炼气 (Qi Refining) — Píngyuǎn curves · mountain mist ink-wash

**Elements**: 3-5 distant mountain silhouettes fading in ink density (Fan Kuan method), 1-2 bamboo grove silhouettes (pure black, no internal detail), scattered mossy stones, 1-2 wordless steles, broken tree stumps. Single-color pale green ground with 30% procedural mist at screen bottom. Large paper-white sky with slight cream warmth.

**Visual density**: Very low (20% screen info). 70% is mist/sky/ground.

**Landmarks**: The Wordless Stele ("someone was here, you don't know who"). The Broken Bridge (outcrop hinting passage once existed).

**Palette**: `#E8E4D8` paper / `#A8B5A0` pale sage / `#4A4A48` ink.

**Production**: 2 hero backgrounds (mist-morning / mist-dusk), 6-8 shared props.

---

#### R2 筑基 (Foundation) — Mountain curves · somber pine-echo

**Elements**: Towering peak clusters with sharper ridges (still curves, not R3's jagged). Old pine silhouettes (trunk curves visible, needles in clusters). Temple remnant wall (one face only), toppled stone lanterns, furnace fragments. Moss-covered stone steps pulled and warped by vegetation. Overcast sky — clouds have weight (2× R1's cloud density).

**Visual density**: Low-mid (30%). Man-made things begin appearing.

**Landmarks**: "Roof-less temple" — a single remnant wall in the mountains, doorway opens to void. "Toppled furnace" — predecessor's failed pill refinement.

**Palette**: `#5C6B5C` moss / `#6B5F4D` aged wood / `#2E2E2E` dark ink.

**Production**: 2 hero backgrounds (dawn/night), 8-10 shared props.

---

#### R3 金丹 (Golden Core) — Jagged transition · ruined cave dwelling

**Elements**: **First appearance of sharp rock contours** — serrated cliff lines. Broken cave entrance (stone door half-collapsed, vines draping), suspended plank-way fragments. Scattered implement fragments (broken sword in the ground, bronze mirror shards), dark red altar lines. Cracked stone floor with dark red vein traces (hinting battle). Deep dusk sky — clouds cut by jagged mountain silhouettes.

**Visual density**: Medium (45%). "Hostility" hints appear.

**Landmarks**: "Broken Sword in Earth" — an ownerless sword, blade-down in rock. "Blood Altar" — circular formation, center empty, hinting sacrifice.

**Palette**: `#8C4A3E` rust-red / `#3C3530` deep brown / `#D4A574` gold highlight (implement fragments only).

**Production**: 3 hero backgrounds, 12-15 shared props.

---

#### R4 元婴 (Nascent Soul) — Spiral geometry · reality/unreality boundary

**Elements**: **Physical impossibility** — floating mountain rocks, inverted waterfalls, spiraling cloud columns. Floating broken-stone "paths", hanging bells (no ropes), rotating array projections. Semi-transparent phantoms (not enemies — spatial folds themselves), light pillars. Some areas have **no ground** — player walks on abstract geometric platforms. Multiple sky layers misaligned (one day, one night, one star).

**Visual density**: Mid-high (50%). Information is **graphic**, not "object".

**Landmarks**: "Hanging Bell" — a bronze bell with no rope, slowly rotating. "Spiral Staircase" — leading to a nowhere-height.

**Palette**: `#3D4F8C` deep violet-blue / `#C9A8E0` pale purple / `#FFE8B0` faint gold (sacred).

**Production**: 3 hero backgrounds, 10-12 shared props + procedural geometric particles.

---

#### R5 大乘 (Mahayana) — Ultimate negative space · the Dao births one

**Elements**: **Almost nothing** — an extremely faint horizontal line (horizon, maybe not). One lonely tree / one lonely stone / one wall — **choose exactly one, never all**. Player's circular shadow beneath (could be array, could be water reflection). Single-color pure plane (milky white / extreme pale grey / extreme pale gold, realm sub-branch determines). Sky: 100% negative space, no clouds.

**Visual density**: Extremely low (10%). But **enemy density is 120-150+** — visual density comes from the enemy tide, not the environment. This is the key contrast tension: emptiness frames the oppression.

**Landmarks**: The "Lone" series (random each run): Lone Tree / Lone Stele / Lone Gate / Lone Mirror. "The Circle beneath the player" — the only persistent visual anchor.

**Palette**: `#F5F2EA` milk-white / `#1A1A1A` player + enemy silhouette / `#C8A055` single warm gold highlight. Minimalist.

**Production**: 1 hero background + 4 lone-element variants. 4-5 shared props. **Counter-intuitive**: highest realm has the lowest environment production cost.

---

#### 飞升 (Ascension) — Nothing

No figurative elements. Screen: pure white gradient (extremely subtle warm gold from center outward). Player silhouette gradually disperses into particles. Enemies: do not exist. Visual density: 0%. Not a level — an 8-15 second visual resolution. Production: 0 backgrounds, pure shader/particle expression (see Section 7 VFX).

---

### 6.4 Prop Density & Visual Clutter Rules

**First principle**: Environment is ground, entities are figure. Environment elements must never compete with combat entities for visual attention.

**Density inverse rule (inverse to Section 5 mob density)**:

| Realm | Mob density | Environment prop density | Max screen entities |
|---|---|---|---|
| R1 | 30-50 | High (8-12 visible) | ~60 |
| R2 | 50-80 | Mid (5-8 visible) | ~85 |
| R3 | 70-110 | Mid-low (4-6 visible) | ~115 |
| R4 | 90-130 | Low (3-5, but high visual impact) | ~135 |
| R5 | 120-150+ | Minimal (1-2) | ~152 |

**Rationale**: R1 player has low operational pressure and bandwidth to appreciate environment; R5 demands peak reaction — any extra visual noise is lethal. **Environment density yields to gameplay density.**

**Readability enforcement rules**:
1. **Environment value contrast ≤ 30%** — environment must never be "brighter" than enemies/player. Realm primary vs. enemy silhouette value difference ≥ 50%.
2. **No saturated colors in environment** — saturation ceiling 0.35. Saturation reserved for: player technique VFX, enemy tells, pickups.
3. **Static vs. dynamic layering** — 90% static. Allowed motion: distant mist, foreground grass, lone tree gentle sway. **Any environment animation speed ≤ 0.3× combat animation speed**.
4. **Pickup visual privilege** — pickups use realm-contrast color + persistent micro-motion + soft glow. Across all realms: gold `#C8A055` — muscle memory consistency.
5. **Danger tell clear zone** — screen center ±200px circular area **contains zero props**, reserved for combat signals.

---

### 6.5 Environmental Storytelling

**Core proposition**: 《咫尺》has no NPCs, no dialogue, no quest text. **100% of the world's story must be communicated visually.**

**Five narrative layers (most explicit → most implicit)**:

#### 1. Trace Narrative — Objects left by predecessors

| Element | Implication | Realm |
|---|---|---|
| Wordless Stele | Someone tried to leave a name; time erased it | R1 |
| Broken Bridge | Once passable here, now severed | R1, R2 |
| Toppled Furnace | Predecessor died in failed pill refinement | R2, R3 |
| Broken Sword in Earth | Battle happened here; outcome unknown | R3 |
| Blood Altar | A sacrifice was made; price unknown | R3, R4 |
| Hanging Bell (no rope) | Physics weakens — not "built", but "manifested" | R4 |
| Lone Tree | After all things return to one, only a witness remains | R5 |

Each object presents, never explains. Players piece together the world's former prosperity and decline across repeated runs.

#### 2. Realm Progression Narrative — The cost of cultivation

R1→R2: Nature increases, man-made decreases → the cultivator departs the mortal world. R2→R3: Violence traces appear → cultivation's cost is struggle. R3→R4: Physical impossibility → power transcends world rules. R4→R5: All things dissipate → power's end is solitude. R5→Ascension: Self dissolves → the ultimate "completion" IS "nothingness." **This is the game's largest narrative arc — without a single word.**

#### 3. Negative-Space Narrative — What isn't drawn matters more

- Map has no drawn roads — player walks in white space → "the path forward is walked by yourself" (core solo-cultivation metaphor)
- Remnant walls have no roof → "What's beyond the door? The sky."
- The bridge is broken → "What's on the other side? You'll never know."
- R5 has no mountains → "You've transcended landscape."
- Gestalt Law of Closure: the player's brain completes the missing parts.

#### 4. Palette Narrative — Color as emotional curve

R1 cool pale green = lucid, solitary beginning. R2 somber moss = cultivation's weight. R3 rust-red = first taste of blood. R4 violet-gold = divinity's temptation. R5 milk-white = approaching-endpoint void. Ascension pure white = liberation / erasure (deliberately ambiguous).

#### 5. Negative-Space Definition — What is deliberately absent

No other living people → you are the last latecomer. No sect banners → organizations have dissolved. No intact buildings → time is long enough for everything to fall. No writing (stelae are wordless, plaques are blank) → knowledge has dissipated. No seasons (each realm has a fixed time-of-day) → time stands still here. After ascension, no "heaven" → perhaps there was never a destination.

These absences are deliberate designer choices. Every new prop proposal must be checked: **"Adding this object — which absence does it break?"**

---

## 7. UI/HUD Visual Direction

> **Core principle**: HUD is a tool, not decoration. In-combat HUD approaches pure flat geometry — trinity colors + lines + rectangles/circles, no ink brush texture, no gradients, no paper grain. Ink-wash aesthetic enters only at the menu layer (see 7.2).

---

### 7.1 HUD Layout Philosophy

**Dual-layer HP feedback**:
- **Top-left bars (precision layer)**: 8px wide, 22% screen height vertical strips for deliberate checking
- **Player-anchored Cinnabar Ring (immersive layer)**: ~80px radius around avatar, always follows character. Invisible at 100% HP. Fades in as HP drops: 70-40% = α 0→0.4, 40-20% = α 0.4→0.7, <20% = α 0.7→1.0 + slow breath pulse every 1.2s. Allows HP awareness without looking away from action.

**Coordinate anchors (16:9 baseline, scales to touch and ultrawide)**:

| Zone | Anchor | Content | Weight |
|------|--------|---------|--------|
| Top strip | 0.20-0.80, 0.02 | **XP bar** — ink-fill horizontal line (3px), below realm indicator | Low |
| Top-left (TL) | 0.04, 0.06 | HP/Qi vertical bars (8px × 22%) | High |
| Top-right (TR) | 0.96, 0.06 | Realm indicator — single cinnabar seal character | Medium |
| TR-2 | 0.96, 0.11 | **Wave timer** — mono text "波 3/5", ink black | Medium |
| Bottom-center (BC) | 0.50, 0.92 | Technique slots × 4 (desktop symmetric; see spec below) | High |
| Top-center (TC) | 0.50, 0.04 | Boss HP bar (combat only) — single horizontal stroke | High |
| Player-anchored | Avatar center | Cinnabar HP ring (80px radius) | Dynamic |
| Bottom-left/right | 0.04/0.96, 0.94 | Touch virtual joystick + attack circle (touch mode only) | Medium |
| Center (CC) | 0.50, 0.50 | **NO HUD** — reserved for gameplay | — |

**Technique slot spec (desktop vs mobile)**:

| Platform | Layout | Slot size | Gap |
|---|---|---|---|
| Desktop (KBM) | Bottom-center, 4 slots symmetric | 40 × 48px | 12px |
| Mobile (touch) | **2+2 thumb-zone split**: left 2 above joystick (0.04-0.18, 0.78); right 2 above attack circle (0.82-0.96, 0.78) | 48 × 56px | 16px |

**Technique slot visual details**:
- Body: square seal rectangle, ink-black 1px border, paper-white interior
- Content: single regular-script character (technique name's first character)
- **On cooldown**: cinnabar radial wipe clockwise from 12-o'clock; character dims to 50% grey
- **Cooldown complete**: 200ms "ready pulse" — cinnabar ring expands outward 4px then fades; character briefly flashes to paper-white-on-cinnabar
- **Active (held)**: slot inverts to cinnabar solid fill + character reverses to white
- **Buff badges**: when technique carries active buff, top-right corner shows 12×12px mini-seal (regular script + cinnabar base). Max 2 buffs; stacking offset 3px.

**Transparency strategy**:
- Idle: HUD overall α = 0.35, nearly invisible
- Combat triggered: 0.2s fade to α = 1.0
- Post-combat 3s: fade back to 0.35
- On player hit: top-left HP edges flash cinnabar (120ms); HP ring also intensifies briefly
- XP bar: constant α = 0.5 (always visible, never distracting)
- **Exception**: player-anchored cinnabar HP ring ignores global HUD transparency — its α is driven solely by HP percentage

**Damage numbers (world layer, NOT UI layer)**:
- Rendered BEFORE UI LUT pass, in world space following camera
- Colors follow Section 4.5 element palettes — **deliberate exception** to UI trinity
- Monospace geometric font with subtle world-lighting influence

**Z-order (lowest → highest)**:
1. Game world (with world LUT applied)
2. Damage numbers + world-space floating text (still in world LUT, element colors active)
3. Screen post-processing (rain, hit-shake)
4. **UI LUT boundary (color palette switches here — world pigment stops)**
5. HUD persistent layer (HP, realm, techniques, XP, wave)
6. HUD transient layer (toasts, ready pulses, buff badge animations)
7. Player-anchored HP ring (special — world-space positioning, UI palette rendering)
8. Menus + modals (on pause)
9. Cutscene mask + realm breakthrough (highest priority)

**Input mode switching (with hysteresis)**:
- KBM mode: touch joystick/buttons FULLY HIDDEN; desktop slot layout
- Touch mode: joystick + attack circle at α=0.55 idle, α=1.0 pressed; mobile 2+2 slot layout
- **Auto-switching hysteresis**: mode flips only when EITHER: 2+ events from same device class consecutively, OR 500ms of consistent input from that class
- Transition uses 200ms cross-fade
- **Settings toggle**: "Input mode: Auto / Force KBM / Force Touch" accessible from main menu + pause menu

---

### 7.2 Menu & Screen Design

Visual personality of each screen controlled by "ink-wash intensity." Combat = most restrained; narrative screens = most indulgent.

**Main Menu**
- Background: single large-scale ink-wash painting (distant mountains / lone boat / plum branch)
- Menu items: **vertical regular-script** ("开始"/"继续"/"图鉴"/"设置"/"退出"), no frames, only a cinnabar underline appears on hover
- Title "咫尺": seal-script stamp, cinnabar red, top-left white space
- Ink-wash intensity: **maximum** — this is the game's front door

**Technique Compendium (horizontal scroll)**
- Full-screen paper background, horizontal scroll (mouse wheel / touch swipe)
- Each technique = square seal + vertical description below
- Learned: full-color seal (cinnabar solid)
- Unlearned: **faded ink outline**, description reads "——"
- Scroll edges dissolve naturally with ink wash to hint "unfinished scroll"
- Top thin-line progress indicator: current / total (e.g. 12 / 36)
- **Both navigation and trophy wall** — blank un-stamped positions invite exploration
- Ink-wash intensity: **high**

**Realm Select / Level Entry**
- Vertical equally-spaced circle seals (one per realm), bottom-to-top
- Completed: cinnabar solid seal + realm name in regular script
- Currently challengeable: cinnabar seal + **slow breathing glow** (α 0.6→1.0, 2s cycle)
- Locked: faded ink ghost-seal, name hidden
- Seals connected by single fine ink line — solid for completed segments, dashed for locked
- Ink-wash intensity: **medium**

**Death Screen (ritual — no skip)**
- Full screen fades to dense ink black (800ms)
- Central cinnabar seal-script character: "殁" or "归" (designer-configured by death context)
- Below: regular-script run stats (duration survived, enemies defeated, techniques unlocked)
- Three action options ("重来"/"回主菜单"/"观看回放") as horizontal square-seal buttons
- **No red-damage flash transition** — direct black field, ritual over stimulus
- **Hard constraint**: entire ritual accepts no skip input. Earliest input accepted at 800ms mark (when black fully covers, seal character begins revealing)
- Ink-wash intensity: **medium-high**

**Settings**
- Paper-edge rectangular modal floating above gameplay (background dimmed to α 0.3 + desaturated)
- Left categories (Audio/Video/Input/Accessibility): vertical regular-script
- Right settings: minimal geometric controls — sliders = horizontal fine line + small circle seal as handle
- "Input" category includes "Input Mode" toggle (Auto / Force KBM / Force Touch)
- Ink-wash intensity: **minimum** (tool screen, readability priority)

---

### 7.3 Typography Direction

**Three-tier font structure**:

| Use | Font class | Recommended (open-source / web-safe) | Web fallback chain |
|---|---|---|---|
| **Titles / Seals / Realm names** | Seal script or imitation Song bold | Noto Serif CJK SC Black | `Noto Serif SC` → `serif` |
| **Body / Menu items / Narrative** | Regular script or Song | Noto Serif CJK SC Regular | `Noto Serif SC` → `Songti SC` → `serif` |
| **Numbers / HUD data / Debug** | Monospace geometric | JetBrains Mono, IBM Plex Mono | `JetBrains Mono` → `monospace` |

**When to use each**:
- Any **numbers** (damage, HP, timer, "波 3/5") → **monospace**, NEVER seal/regular script
- Any **emotional text** (technique names, realm names, narrative lines) → **regular script / Song**
- Any **decorative single character** (seals, title, death-screen "殁") → **seal script**

**Size hierarchy (1080p baseline; touch ×1.3)**:

| Level | Use | Size | Line height |
|---|---|---|---|
| H1 | Main menu title, realm breakthrough | 96px | 1.0 |
| H2 | Modal titles, chapter names | 48px | 1.2 |
| H3 | Menu items, technique names | 28px | 1.4 |
| Body | Description text, dialogue | 18px | 1.6 |
| Caption | Tooltips, copyright, wave timer | 14px | 1.4 |
| Data | HUD numbers, debug | 20px mono | 1.0 |

**Web font loading**: Preload regular script Regular + monospace Regular with `font-display: swap`. Seal script loaded on-demand only when title/death/breakthrough screens needed. Fallback must be serif — never sans-serif.

---

### 7.4 Iconography System

**Core principle: Single character > abstract symbol.**

1. **Preferred**: single regular-script or seal-script character ("攻"/"防"/"气"/"丹"/"剑")
2. **Secondary**: minimal geometric symbols (gear=settings, arrow=back — only universally understood semantics)
3. **Avoid**: skeuomorphic icons, multi-color icons, emoji style

**Font use by icon tier**:
- **Seal script**: permanent, sacred icons — realm markers, technique seals, achievement stamps
- **Regular script**: functional, interactive icons — slot characters, menu buttons, buff badges

**Size spec**:

| Use | Desktop | Touch | Container |
|---|---|---|---|
| HUD technique slots | 40×48 | 48×56 | Square seal (2px corner radius) |
| Technique buff badges | 12×12 | 16×16 | Mini seal |
| Menu primary buttons | any width × 40h | any width × 64h | Square seal rectangle |
| Menu secondary buttons | 32×32 | 56×56 | Circle seal |
| Modal close / small icon | 16×16 | 32×32 | No container |
| Achievement seals | 64×64 | 64×64 | Square seal |

**Touch target compliance (W3C / Apple HIG)**:
- Minimum hit area 44×44px for any clickable element (extends beyond visual size if needed)
- Minimum 8px spacing between adjacent clickable elements
- Visual elements <32px auto-enlarge to 32px in touch mode
- Joystick and attack circle hit area = visual size + 16px overshoot
- Mobile 2+2 slot groups: **minimum 50% screen width gap** between left and right groups

**Color usage**: Icons use only trinity colors (paper-white / ink-black / cinnabar-red). State changes via color swaps:
- Normal: ink black
- Hover: cinnabar red
- Disabled: 50% grey ink
- Active/selected: paper-white base + cinnabar character

---

### 7.5 UI Animation & Feedback

**Core rhythm**: restrained, crisp, breathing. Ink-wash dynamic language = "stroke arrives, then stops" — fast completion, precise ending, breath-pause after.

**Duration baseline**:

| Action | Duration | Easing |
|---|---|---|
| Button hover | 80ms | ease-out |
| Button press | 60ms | linear |
| Modal fade-in | 200ms | ease-out |
| Modal fade-out | 150ms | ease-in |
| Screen transition | 300ms | ease-in-out |
| Number scroll | 400ms | ease-out + end-bounce |
| Technique ready pulse | 200ms | ease-out |
| Input mode auto-switch | 200ms | ease-in-out |
| Realm breakthrough | 1200ms | custom staged curve |

**Button animation**: Hover = 0→15% cinnabar overlay, no movement/no scale. Press = instant 1px sink + 40% cinnabar, 60ms rebound. Disabled = 40% grey, no hover response. **Never**: shadow, 3D rotation, bounce-scale.

**Technique slot feedback**:
- Cooldown: cinnabar radial wipe clockwise (angle = elapsed/total × 360°)
- Ready pulse (200ms): 0-100ms ring expands 4px + fade; 50-150ms character flashes; 100-200ms slot brightens briefly
- Buff badge appear: pop-out from top-right + cinnabar flash 100ms
- Buff badge disappear: α 1→0, 120ms, no movement

**State transitions**:
- Screen-to-screen: **ink sweep** — dense ink sweeps right-to-left (300ms cover), content switches at full cover, ink dissipates left-to-right (200ms)
- Modal appear: center 95%→100% scale + α 0→1, 200ms
- Modal disappear: α 1→0, 150ms, no scale

**Data change feedback**:
- XP bar: ink fills left-to-right linearly (400ms); full → cinnabar flash 200ms → reset + continue
- HP bar decrease: **dual-layer** — front instant drop (red), back 200ms-delayed drop (white), creates brief "ghost" showing damage magnitude. HP ring syncs per 7.1 rules.
- Wave number change ("波 2/5"→"波 3/5"): shake + cinnabar flash 150ms
- **Damage numbers belong to world layer** (see 7.1), their animation is out of UI scope

**Realm breakthrough (high-ritual moment, no skip)**:
1. **0-200ms**: game world slows to 30%, HUD α 1.0→0
2. **200-500ms**: ink bloom expands from screen center, covers to full dense black
3. **500-800ms**: cinnabar seal-script new realm name emerges center (60%→100% scale)
4. **800-1100ms**: regular-script realm description appears below (one line, provided by narrative designer)
5. **1100-1200ms**: ink dissolves from center outward, returns to game world, HUD fades back in
6. **Hard constraint**: entire process accepts NO input skip — this is a non-negotiable narrative moment

**Touch-specific feedback**:
- Touch press: haptic 10ms light, 30ms heavy (technique release)
- Joystick at edge: additional haptic + joystick outer ring cinnabar flash
- Input mode auto-switch: light haptic + brief 8px cinnabar dot flash in screen corner (200ms)

---

## 8. Asset Standards

> **Purpose**: Production-grade specifications. Specific enough that an outsourcing team can follow without additional briefing.

---

### 8.1 File Format Standards

| Category | Format | Color space | Alpha | Notes |
|---|---|---|---|---|
| Hero backgrounds | WebP (lossy q=85) | sRGB | No | 1920×1080, ≤300KB target, ≤450KB peak |
| Parallax layers (mid/far) | WebP (lossy q=80) | sRGB | Yes | Alpha silhouette/mist layers, ≤120KB |
| Player sprite | WebP (lossy q=90), PNG fallback | sRGB | Yes | ≤512×512 per frame; sprite sheet ≤400KB |
| Enemy sprites | WebP (lossy q=85) | sRGB | Yes | ≤256×256 per frame; per-realm atlas |
| Props | WebP (lossy q=85) | sRGB | Yes | ≤256×256, packed into per-realm atlas |
| Shared noise texture | PNG (8-bit grayscale) | Linear | No | 256×256, ~64KB, singleton — global reuse |
| Particle brush textures | WebP (lossy q=80) | sRGB | Yes | 64×64 or 128×128, ≤8KB each |
| UI icons | WebP (lossy q=90), SVG preferred | sRGB | Yes | Vector-first; rasterized at 64×64 / 128×128 |
| UI decorative frames | WebP (lossy q=85) + 9-slice | sRGB | Yes | 9-slice source ≤128×128 |
| Fonts | WOFF2 (subset) | — | — | Noto Serif CJK SC subset (game-occurring characters only) |

**Rules**: WebP is default. PNG only for compatibility fallback or noise texture. **No JPG** (no alpha, WebP smaller at same quality). **No GIF** (sprite sheets for frame animation). All assets run through `cwebp -q [quality] -m 6 -mt` before commit. Half-res fallback set: NOT recommended (50MB cap won't allow it).

---

### 8.2 Naming Convention

**Directory structure** (`assets/art/`):

```
assets/art/
├── env/                  # Environment / backgrounds
│   ├── realm_01_qihai/
│   ├── realm_02_zhuji/
│   └── shared/           # Cross-realm shared
├── char/                 # Character sprites
│   ├── player/
│   └── enemy/
│       └── realm_01_qihai/
├── vfx/                  # VFX textures
│   ├── particles/        # Brush shapes
│   └── palettes/         # Palette textures
├── ui/
│   ├── icons/
│   ├── frames/           # 9-slice borders
│   └── decorations/
├── fonts/
└── shared/
    └── noise_256.png     # Global singleton noise texture
```

**File naming (mandatory)**: `[category]_[name]_[variant]_[size].[ext]`

| Prefix | Example |
|---|---|
| `env_` | `env_qihai_cliffside_hero_1080p.webp` |
| `char_` | `char_player_idle_sheet.webp` |
| `prop_` | `prop_qihai_lantern_static.webp` |
| `vfx_` | `vfx_brush_swoosh_loop_64.webp` |
| `ui_` | `ui_btn_primary_hover.webp` |
| `font_` | `font_notoserifcjksc_subset.woff2` |

**Rules**:
- All lowercase, snake_case (matches GDScript naming, avoids Win/Linux case-sensitivity bugs)
- Action variants: `idle / run / attack01 / hit / death / charge`
- Sprite sheets suffixed `_sheet`; single frames suffixed `_01 / _02...`
- Realms use number + pinyin: `realm_01_qihai` — numbers guarantee sort stability
- **Forbidden**: spaces, Chinese characters, hyphens, uppercase, version suffixes (`_v2 / _final / _new` — use git)

---

### 8.3 Texture & Sprite Resolution Tiers

Allocated by "frequency × screen coverage," not by category.

| Tier | Use | Max resolution | Max disk per asset | Typical assets |
|---|---|---|---|---|
| **T0 — Hero** | Full-screen focus, cutscenes, realm hero backgrounds | 1920×1080 | 300KB (450KB peak) | Realm backgrounds, title screen, boss room |
| **T1 — Featured** | Main interactive objects, player action frames | 1024×1024 or 512×1024 | 200KB | Player sprite sheets, narrative NPCs, key props |
| **T2 — Standard** | Regular enemies, repeatable props, parallax mid-ground | 512×512 | 100KB | Enemy sprites, lanterns, rocks, mist |
| **T3 — Small** | Small repeated elements, large UI icons | 256×256 | 40KB | Projectiles, particle sources, buff icons |
| **T4 — Tiny** | Small UI icons, particle brush shapes, decorative accents | 128×128 or 64×64 | 8KB | Skill icons, brush textures |

**Sprite sheet packing**:
- Single sheet ≤2048×2048 (Web/mobile GPU safe ceiling)
- All frames of one action MUST be on one sheet (no runtime texture switching)
- Per-realm enemies merged by character into shared atlas (reduces draw calls)
- Frame padding ≥2px (prevents mipmap/scale bleeding)

**Parallax layer resolution**:
- Far (slowest): 1024×576, horizontally tileable
- Mid: 1920×1080, with alpha
- Near: 1920×1080, limited to short ribbon strips (height ≤540)

---

### 8.4 Export Settings & Compression

**Godot 4.6 import settings (`.import` file key params)**:

| Category | Compress Mode | Mipmaps | Filter | Repeat | Fix Alpha Border |
|---|---|---|---|---|---|
| Hero backgrounds (WebP) | Lossless | Off | Linear | Off | — |
| Parallax alpha | Lossless | Off | Linear | On/Off | **On** |
| Character sprite sheets | Lossless | Off | Nearest/Linear | Off | **On** |
| Noise texture | Lossless | Off | Linear | **On** | — |
| Particle brush | Lossless | Off | Linear | Off | **On** |
| UI icons | Lossless | Off | Linear | Off | **On** |

**Critical**:
- **All mipmaps OFF** — 2D game doesn't need them, saves 33% VRAM
- **Compress Mode = Lossless** — files already WebP lossy; secondary VRAM compression (BPTC/ETC2) unstable on Compatibility renderer
- **Fix Alpha Border = ON** for all alpha assets — prevents sprite edge black halos
- **Filter**: Nearest for pixel-art characters; Linear for all else

**Web export optimization** (`export_presets.cfg`):
- All assets packed into `.pck`, single HTTP fetch
- **Preload manifest** (`preload.json`): fonts + global noise + first realm hero background + UI atlas
- **Lazy load**: realm 2+ assets packaged separately, async pre-fetch before first access
- **⚠️ Spike needed**: verify Godot 4.6 Web split-`.pck` support before committing to this strategy

**Forbidden**:
- BPTC / S3TC / ASTC texture compression on Web — Compatibility renderer support limited, and compressed textures are larger than WebP
- Runtime `Image.compress()` — unacceptable CPU cost

---

### 8.5 Asset Budget Allocation

**50MB total (compressed, on disk)**:

| Category | Budget | % | Notes |
|---|---|---|---|
| **Backgrounds (env)** | 18 MB | 36% | See breakdown below |
| **Character sprites (char)** | 12 MB | 24% | Player + enemies + bosses |
| **VFX particle textures** | 1.5 MB | 3% | ~30 brush shapes × ~30KB |
| **UI (icons/frames/decor)** | 3 MB | 6% | Atlas-packed |
| **Fonts** | 2.5 MB | 5% | Noto Serif CJK SC subset + JetBrains Mono |
| **Audio** (non-art, placeholder) | 8 MB | 16% | Governed by audio-director |
| **Code + Godot runtime** | 4 MB | 8% | Web export baseline |
| **Buffer** | 1 MB | 2% | Emergency reserve |
| **TOTAL** | **50 MB** | 100% | |

**Environment breakdown (18 MB)**:

| Item | Qty | Per-item | Subtotal |
|---|---|---|---|
| Hero backgrounds (6 realms × 2.5 avg) | 15 | 300KB | 4.5 MB |
| Parallax mid (3/realm) | 18 | 150KB | 2.7 MB |
| Parallax far (1-2/realm, tileable) | 10 | 100KB | 1.0 MB |
| Props (avg 10/realm) | 60 | 60KB | 3.6 MB |
| Prop atlas overhead | — | — | +1.0 MB |
| Shared/generic environment | — | — | 5.2 MB |

**Characters breakdown (12 MB)**:

| Item | Qty | Per-sheet | Subtotal |
|---|---|---|---|
| Player action sheets (idle/run/attack×3/hit/death/charge) | 8 | 400KB | 3.2 MB |
| Regular enemies (4 types × 6 realms) | 24 | 200KB | 4.8 MB |
| Elites (1/realm × 6) | 6 | 350KB | 2.1 MB |
| Bosses (1/realm) | 6 | 300KB | 1.8 MB |
| Buffer | — | — | 0.1 MB |

**Hard rules**:
- Per-realm assets ≤6 MB (env + char + vfx combined) — keeps split packages uniform
- Any single asset >500KB requires mandatory review
- Asset budget tool (`tools/asset_budget_check.py`) to be implemented by ci-engineer

---

### 8.6 Quality Assurance Tests

Executable specifications for Section 3 QA requirements:

| ID | Test | Method | Pass | Fail Response |
|---|---|---|---|---|
| **QA-01** | 60fps desktop / 30fps mobile | Stress scene (R3, 150 enemies + player max techniques), 60s run, `Performance.get_monitor(TIME_PROCESS)` | Desktop 95% ≤16.6ms, Mobile 95% ≤33.3ms | Check draw calls → particles → sprite switching |
| **QA-02** | Draw calls ≤200 | Godot `RENDER_TOTAL_DRAW_CALLS_IN_FRAME` at stress peak | Peak ≤200, avg ≤150 | Check realm atlas merge, UI CanvasLayer |
| **QA-03** | Particles ≤500 | Aggregate all `GPUParticles2D`/`CPUParticles2D` `amount` fields | Peak ≤500 | Enable particle LOD: reduce density 50% at >800px from player |
| **QA-04** | Memory ≤256MB | `OS.get_static_memory_usage()` + `RENDER_VIDEO_MEM_USED` | 30-min run ≤256MB, no linear growth (no leak) | Check texture release on realm transition, signal disconnects |
| **QA-05** | Package ≤50MB | CI build check: `index.pck` + `index.wasm` + `index.js` + fonts total | ≤50MB gzipped | Run `tools/asset_budget_check.py` per 8.5 table |
| **QA-06** | First load ≤8s (4G) | Chrome DevTools throttled "Fast 3G", cold load to interactive | ≤8s | Shrink preload manifest, trim font subset, verify lazy-load |
| **QA-07** | Visual consistency (Lantern Test) | Screenshot each realm hero scene, side-by-side vs. art-bible color+stroke reference | art-director + creative-director subjective ≥4/5 | Return to Section 4 palette + Section 5 stroke spec |
| **QA-08** | Asset naming compliance | CI script scan `assets/art/`, regex: `^[a-z0-9_]+\.(webp\|png\|woff2\|svg)$`, prefix ∈ {env,char,prop,vfx,ui,font} | 0 violations | Block PR, require rename |

> **Open items**: Godot 4.6 Web split-package feasibility (spike before committing to 8.5). Font subset size depends on narrative-designer character lexicon estimate. Audio 8MB cap to be confirmed by audio-director.

---

## 9. Reference Direction

### 9.1 《Sable》(Shedworks, 2021)

- **What we take**:
  - **粗黑轮廓线 + 大色块平涂** cel-shading: 角色与场景共享 1-2px 等宽墨线轮廓,内部扁平色块填充,几乎无渐变。直接对应"几何化水墨"中矢量线 + 纯色块的技术核心。
  - **远景大面积留白/单一柔色填充**的构图: 天空、远山常只是一片浅米色或淡青,把视觉重心完全交给中近景剪影。验证了"留白即焦点"在商业作品中成立。
  - **极简但情绪饱满的废墟感** — 残破飞船、巨像骨架,用最少形状描述失落文明。对应"后修仙时代废墟美学"。
- **What we avoid**: 法式漫画线条质感(Mœbius 风开放笔触);沙漠暖黄主调(我们用境界色链);开放探索式慢节奏镜头。
- **Why this reference**: 商业游戏中"极简平涂 + 文明废墟"最成熟的样本,验证了 One-Line Rule 的可行性。

### 9.2 《Mini Motorways》/《Mini Metro》(Dinosaur Polo Club)

- **What we take**:
  - **Web 友好的纯矢量渲染管线** — 全部 SDF/线段/圆形/多边形,无位图贴图。是 HTML5 + Godot Web 导出性能预算下最现实的视觉策略。
  - **功能色编码系统** — 每条线路一个标识色,玩家 0.3 秒可读。直接映射到境界色调链作为瞬时可读语义。
  - **静态构图通过粒子/小元素流动产生"活感"** — 画面 90% 静止,但微动让画面"呼吸"。对应留白中靠灵气粒子点活场景。
- **What we avoid**: 全饱和明色调和白底;完全抽象的符号化;无叙事/无角色的纯系统美学。
- **Why this reference**: 矢量水墨在 Web 端落地的技术可行性证明。不靠 4K 贴图、不靠复杂着色器,仅用线段+多边形+少量粒子就能产出商业级视觉。

### 9.3 《Hyper Light Drifter》(Heart Machine, 2016)

- **What we take**:
  - **"剪影优先"的角色可读性原则** — 主角纯黑/纯色剪影 + 一抹标志色,即使在最混乱弹幕场景中 100% 可定位。对应"玩家=墨色剪影(风暴之眼)"。
  - **战斗特效纯色块爆炸 + 短促闪光**而非粒子云。每个攻击 2-4 帧高对比形状。对应"招式=泼彩"——单帧高冲击、来去明快。
  - **环境色温剧烈切换作为分区标记** — 不同区域用完全不同整体色调,色温即区域名片。对应境界色调链跨场景应用。
- **What we avoid**: 像素艺术媒介;赛博朋克+生物腐烂的色彩污染美学;密集的细节叠加(每像素都有信息)。
- **Why this reference**: 俯视/斜俯视动作游戏中"剪影 + 标志色"方案最成功的标杆。证明在高密度战斗中玩家依然能识别自己。

### 9.4 《Vampire Survivors》(poncle, 2022) — UI/信息层限定

- **What we take**(严格限定在 UI/信息层,不取美术):
  - 屏幕中央留给战斗、边缘留给数据的 HUD 分区。验证了注意力分配方案。
  - 伤害数字"飘出-缩放-消失"动效曲线(0.4s 生命周期)作为飘字基准。
  - 技能升级时画面短暂暂停 + 中央卡片的节奏断点——把"获得新技能"作为仪式化瞬间。
- **What we avoid**: **明确不取它的任何美术风格** — 像素位图、密集 UI 图标、霓虹弹幕、饱和原色,全部对立。不取整屏被特效淹没的视觉混乱。
- **Why this reference**: **这是类型可玩性基准,不是美术参考**。把它写出来正是为了**预防团队的"VS-like 默认审美"惯性**——别人做 VS-like 默认走像素+霓虹,我们走水墨+留白,差异化必须被前置声明。

### 9.5 《GRIS》(Nomada Studio, 2018)

- **What we take**:
  - **"色彩即叙事/进度"的整局结构** — 游戏开始无色灰白,随旅程依次解锁色阶。这是境界色调链的最直接精神原型。
  - **大尺度色块 + 半透明叠加层**模拟水彩晕染——多层半透明矢量形状的乘法/叠加混合。是"几何化水墨"做"泼彩"瞬间的技术路径。
  - **角色周围视觉缓冲区** — 主角周围常有一圈留白,即使背景华丽也不喧宾夺主。
- **What we avoid**: 水彩柔边和粉彩饱和度(我们用硬切矢量边缘);抽象至完全无敌的玩法层(我们是 Survivor-like);线性叙事关卡式色彩节奏。
- **Why this reference**: "色彩作为叙事货币"的最高范本。如果境界色链做对了,玩家会在多年后依然记得"从浅绿升到深蓝那一刻"。

### 9.6 Non-Game References

#### 徐冰《天书》与《背后的故事》(当代艺术)

- **What we take**:
  - **"伪汉字 / 几何化书法"的视觉策略** — 看似汉字实为虚构字形,构建"可读但不可解"的画面。对应 BOSS 设计——BOSS 身体可放大到占屏 40% 的笔画结构,玩家认得是"字",不必真读出来。
  - 《背后的故事》中枯枝/碎片在毛玻璃后形成水墨山水的"幻视"手法——启发"废墟即山水":残剑、断塔、浮石在远景剪影中拼成一幅山水构图。
- **What we avoid**: 学术性/概念性的冷峻感。
- **Why this reference**: 唯一能同时锚定"汉字美学"和"废墟美学"的非游戏参考。提供当代中国艺术语境下的水墨。

#### 八大山人(朱耷)册页

- **What we take**:
  - **"一鸟一石占满整页留白"的极简构图** — 留白占画面 85% 以上。One-Line Rule "留白即焦点"的**历史正统出处**——告诉团队这不是西方极简主义的舶来,而是水墨自身的核心语法。
  - **墨色"焦/浓/重/淡/清"五级灰阶** — 整幅画只用黑+灰不同浓度制造层次。对应基础场景的 5 档墨色灰阶系统。
  - **剪影中的关键识别点**("白眼")— 鸟鱼一眼可辨因为剪影上有一个高对比小白点。对应玩家剪影应有 1-2 个标志性高对比锚点。
- **What we avoid**: 传统水墨的毛笔飞白质感和宣纸渗化效果——要水墨的**"骨"(构图、留白、墨色层次)**,不是水墨的**"皮"(笔触、纸张)**。
- **Why this reference**: **整个艺术圣经的美学源头锚。** 当团队对设计决策有分歧时,问一句"八大山人会这么画吗?"通常能直接得出答案。它不是参考,它是**祖宗**。
