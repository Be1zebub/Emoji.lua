local hasTones = {
	string.format("%x", 9757),
	string.format("%x", 9977),
	string.format("%x", 9994),
	string.format("%x", 9995),
	string.format("%x", 9996),
	string.format("%x", 9997),
	string.format("%x", 127877),
	string.format("%x", 127938),
	string.format("%x", 127939),
	string.format("%x", 127940),
	string.format("%x", 127943),
	string.format("%x", 127946),
	string.format("%x", 127947),
	string.format("%x", 127948),
	string.format("%x", 128066),
	string.format("%x", 128067),
	string.format("%x", 128070),
	string.format("%x", 128071),
	string.format("%x", 128072),
	string.format("%x", 128073),
	string.format("%x", 128074),
	string.format("%x", 128075),
	string.format("%x", 128076),
	string.format("%x", 128077),
	string.format("%x", 128078),
	string.format("%x", 128079),
	string.format("%x", 128080),
	string.format("%x", 128102),
	string.format("%x", 128103),
	string.format("%x", 128104),
	string.format("%x", 128105),
	string.format("%x", 128110),
	string.format("%x", 128112),
	string.format("%x", 128113),
	string.format("%x", 128114),
	string.format("%x", 128115),
	string.format("%x", 128116),
	string.format("%x", 128117),
	string.format("%x", 128118),
	string.format("%x", 128119),
	string.format("%x", 128120),
	string.format("%x", 128124),
	string.format("%x", 128129),
	string.format("%x", 128130),
	string.format("%x", 128131),
	string.format("%x", 128133),
	string.format("%x", 128134),
	string.format("%x", 128135),
	string.format("%x", 128170),
	string.format("%x", 128372),
	string.format("%x", 128373),
	string.format("%x", 128378),
	string.format("%x", 128400),
	string.format("%x", 128405),
	string.format("%x", 128406),
	string.format("%x", 128581),
	string.format("%x", 128582),
	string.format("%x", 128583),
	string.format("%x", 128587),
	string.format("%x", 128588),
	string.format("%x", 128589),
	string.format("%x", 128590),
	string.format("%x", 128591),
	string.format("%x", 128675),
	string.format("%x", 128692),
	string.format("%x", 128693),
	string.format("%x", 128694),
	string.format("%x", 128704),
	string.format("%x", 128716),
	string.format("%x", 129304),
	string.format("%x", 129305),
	string.format("%x", 129306),
	string.format("%x", 129307),
	string.format("%x", 129308),
	string.format("%x", 129309),
	string.format("%x", 129310),
	string.format("%x", 129311),
	string.format("%x", 129318),
	string.format("%x", 129328),
	string.format("%x", 129329),
	string.format("%x", 129330),
	string.format("%x", 129331),
	string.format("%x", 129332),
	string.format("%x", 129333),
	string.format("%x", 129334),
	string.format("%x", 129335),
	string.format("%x", 129336),
	string.format("%x", 129337),
	string.format("%x", 129341),
	string.format("%x", 129342),
	string.format("%x", 129489),
	string.format("%x", 129490),
	string.format("%x", 129491),
	string.format("%x", 129492),
	string.format("%x", 129493),
	string.format("%x", 129494),
	string.format("%x", 129495),
	string.format("%x", 129496),
	string.format("%x", 129497),
	string.format("%x", 129498),
	string.format("%x", 129500),
	string.format("%x", 129501),
}

local skinTones = {
	{"1f3fb", "light"},
	{"1f3fc", "medium-light"},
	{"1f3fd", "medium"},
	{"1f3fe", "medium-dark"},
	{"1f3ff", "dark"},
}

local isToned = {}
local untone = {}

for _, tone in ipairs(skinTones) do
	for _, emoji in ipairs(hasTones) do
		isToned[emoji .."-".. tone[1] ..".png"] = true
		untone[emoji .."-".. tone[1] ..".png"] = emoji ..".png"
	end
end

local fs = require("fs")


local src = "joypixels"
local dest = "../emoji-tones/joypixels"

fs.mkdirSync(dest)

for _, tone in ipairs(skinTones) do
	fs.mkdirSync(dest .."/".. tone[2])
end

for fname in fs.scandirSync(src) do
	if isToned[fname] then
		print(fname)
		fs.renameSync(src .."/".. fname, dest .."/".. tone2dir[fname] .. "/".. untone[fname])
	end
end