风扇控制程序
============

tags: fan, linux, acpi, lua;

最近不知怎么的，“自动控制”下的风扇若是发觉低于一定温度会完全关闭，然后当热量累积的时候又打开，打开的瞬间会发出巨大而可怕的响声，若是普通程度的工作，风扇就会开关开关来回切换，非常吓人。然而并看不懂那个fancontrol的配置文件和它含混不清的文档，pwmconfig又根本无法使用。

于是写了一个lua程序来干这事，让风扇不要完全关闭。（我不是lua专家，不准喷代码风格）

适用于ThinkPad X230。

```lua
#!/usr/bin/env lua5.1

s = require("socket")

temperature = 100
level = 7

function read_temperature()
	ft = io.open("/sys/class/hwmon/hwmon2/temp1_input")
	t = ft:read("*number")
	ft:close()
	return t/1000
end

function write_level(level)
	fan = io.open("/proc/acpi/ibm/fan", "w")
	fan:write("level ", level)
	fan:close()
end

write_level(7)
while true do
	temperature = read_temperature()
	level = math.floor((temperature - 45) / 4)
	if level > 7 then
		level = 7
	elseif level < 1 then
		level = 1
	end
	write_level(level)
	io.stdout:write("T=", temperature, ", level=", level, "\n")
	s.sleep(2)
end
```
