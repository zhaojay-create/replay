# replay

无限复印

平行时空

游戏不是“控制一个角色通关”，而是“在时间维度上编排多个自己完成关卡”。

- 时间回放
- Rogue
- 自我协作
- 自我干扰
  三层实体模型

1. Player（当前意识）

- 唯一可输入实体
- 只存在“当前时间线”

---

2. Ghost（历史执行体）

- 由上一轮输入 replay 生成
- 完全自动执行输入序列
- 不可控
  本质：
  “时间录像 + 可交互实体化”

---

3. Corpse（残留物）

- Ghost 死亡后的物理残留
- 静态存在
- 可交互（关键设计点）
  二、时间结构
  每一局 = 一条时间线分叉
  时间是叠加的，而不是替换。
  在同一张地图上增加新的时间层
  Run 1 → T1
  Run 2 → T2（包含 T1 Ghost）
  Run 3 → T3（包含 T1 + T2 Ghost）
  三、Ghost 行为规则

1. 完全的 replay: 只执行录制输入
2. 状态同步：和 player 共用，物理系统，碰撞规则，机关系统。就是一个玩家的 copy，只是会复制行为。
   玩家目标
   达到地图终点
   每一关，玩家会看到自己的 Ghost，上一局的自己开始重复之前的行为，例如：跑到左边，吸引炮塔，踩按钮，死亡。死亡后，会变成一个尸体。

---

## Collision Layer 分配

| Layer | 名称         | 说明                                 |
| ----: | ------------ | ------------------------------------ |
|     1 | Player       | 玩家物理体                           |
|     2 | Ghost        | Ghost 物理体（历史回放实体）         |
|     3 | Enemy        | 敌人物理体                           |
|     4 | PlayerAttack | 玩家远程攻击（子弹、飞行道具等）     |
|     5 | GhostAttack  | Ghost 远程攻击（回放中的攻击复现）   |
|     6 | EnemyAttack  | 敌人远程攻击（弹幕等）               |
|     7 | Environment  | 环境地形（地面、墙壁、平台）         |
|     8 | Trigger      | 触发区域（终点、机关按钮、事件触发） |

---

## 各实体的 Layer / Mask 配置

### 1. Player — `CharacterBody2D`

| 属性                | 值         | 说明                       |
| ------------------- | ---------- | -------------------------- |
| **collision_layer** | 1 (Player) | 自身所在层                 |
| **collision_mask**  | 3, 7       | 与敌人物理碰撞；被地形阻挡 |

> - Player **不 mask Ghost (2)**：Ghost 和 Player 互相穿透，不产生物理推挤
> - Player **不 mask EnemyAttack (6)**：敌人攻击用 Area2D，由攻击方主动检测 Player

### 2. Ghost — `CharacterBody2D`

| 属性                | 值        | 说明                       |
| ------------------- | --------- | -------------------------- |
| **collision_layer** | 2 (Ghost) | 自身所在层                 |
| **collision_mask**  | 3, 7      | 与敌人物理碰撞；被地形阻挡 |

> - Ghost **不 mask Player (1)**：与玩家互相穿透
> - Ghost **不 mask Ghost (2)**：多个 Ghost 之间也互相穿透
> - Ghost **mask Enemy (3)**：Ghost 可以吸引敌人、挡住敌人（关键玩法）

### 3. Enemy — `CharacterBody2D`

| 属性                | 值         | 说明                                       |
| ------------------- | ---------- | ------------------------------------------ |
| **collision_layer** | 3 (Enemy)  | 自身所在层                                 |
| **collision_mask**  | 1, 2, 3, 7 | 与玩家、Ghost 物理碰撞；敌人互推；被地形挡 |

> - 敌人 mask Player (1) + Ghost (2)：敌人视角下，Ghost 和 Player 是同等实体
> - 敌人 mask Enemy (3)：敌人之间互相推挤（可选，去掉则互相穿透）

### 4. PlayerAttack — `Area2D`

| 属性                | 值               | 说明               |
| ------------------- | ---------------- | ------------------ |
| **collision_layer** | 4 (PlayerAttack) | 自身所在层         |
| **collision_mask**  | 3                | 检测敌人，触发伤害 |

> 玩家攻击只打敌人

### 5. GhostAttack — `Area2D`

| 属性                | 值              | 说明               |
| ------------------- | --------------- | ------------------ |
| **collision_layer** | 5 (GhostAttack) | 自身所在层         |
| **collision_mask**  | 3               | 检测敌人，触发伤害 |

> Ghost 的攻击回放，效果与玩家攻击一致，也只打敌人

### 6. EnemyAttack — `Area2D`

| 属性                | 值              | 说明                       |
| ------------------- | --------------- | -------------------------- |
| **collision_layer** | 6 (EnemyAttack) | 自身所在层                 |
| **collision_mask**  | 1, 2            | 检测玩家和 Ghost，触发伤害 |

> 敌人攻击同时威胁 Player 和 Ghost（Ghost 可以替玩家挡子弹）

### 7. Environment — `StaticBody2D` / `TileMap`

| 属性                | 值              | 说明                 |
| ------------------- | --------------- | -------------------- |
| **collision_layer** | 7 (Environment) | 自身所在层           |
| **collision_mask**  | —               | 静态体不需要主动检测 |

> 地形只需被其他实体检测到（Player/Ghost/Enemy 都 mask 7）

### 8. Trigger — `Area2D`

| 属性                | 值          | 说明                          |
| ------------------- | ----------- | ----------------------------- |
| **collision_layer** | 8 (Trigger) | 自身所在层                    |
| **collision_mask**  | 1, 2        | 检测玩家和 Ghost 进入触发区域 |

> - 终点区域：检测 Player (1) 进入 → 通关
> - 机关按钮：检测 Player (1) + Ghost (2) → Ghost 也能踩按钮（核心玩法）

---

## 碰撞矩阵总览

| | Player | Ghost | Enemy | PAtk | GAtk | EAtk | Env | Trigger |
| | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| ------------ | :----: | :---: | :---: | :--: | :--: | :--: | :-: | :-----: |
| **Player** | | | ✅ | | | | ✅ | |
| **Ghost** | | | ✅ | | | | ✅ | |
| **Enemy** | ✅ | ✅ | ✅ | | | | ✅ | |
| **PAtk** | | | ✅ | | | | | |
| **GAtk** | | | ✅ | | | | | |
| **EAtk** | ✅ | ✅ | | | | | | |
| **Env** | | | | | | | | |
| **Trigger** | ✅ | ✅ | | | | | | |
