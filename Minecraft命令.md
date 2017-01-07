Minecraft命令
---------------

tags: minecraft

* `/summon EntityHorse ~ ~-2.5 ~ {CustomName:"Right Click, sit down.",Type:0,Variant:7,Attributes:[{Name:generic.maxHealth,Base:1},{Name:generic.movementSpeed,Base:0.000}],Invulnerable:1,NoAI:1,Silent:1,NoGravity:1,Team:"NoCollision",Rotation:[90f,0f]}`
	- 隐形的马，当作座位
	- 无AI，无碰撞，无声音
	- 需要先创建一个队伍："NoCollision"，来实现无碰撞
		- `/scoreboard teams add NoCollision`
		- `/scoreboard teams option NoCollision collisionRule never`
	- `Type:0,Variant:7`
		- 这个Variant的马没有贴图

* `/give @p iron_sword 1 0 {display:{Name:"锟斤拷",Lore:["������锟斤拷锟斤拷锟斤拷","烫烫烫烫����屯屯���"]},AttributeModifiers:[{AttributeName:"generic.attackDamage",Name:"generic.attackDamage",Amount:100,Operation:0,UUIDMost:71006,UUIDLeast:367061}],HideFlags:4,Unbreakable:1,ench:[{id:20,lvl:10},{id:21,lvl:10},{id:34,lvl:1}]}`
	- 锟斤拷之剑

* `/summon Pig ~ ~-1 ~ {Invulnerable:1,NoAI:1,Silent:1,Team:"NoCollision",Rotation:[90f,0f],ActiveEffects:[{Id:14,Amplifier:1,Duration:99999999,ShowParticles:0b}]}`
	- 没有粒子效果的隐形猪
