local fs = require("fs")
local json = require("json")

local src = "fluent"
local dest = "fluent-done"
local dest_tones = "../emoji-tones/fluent"

local skinTones = {
	{"1f3fb", "light", "Light"},
	{"1f3fc", "medium-light", "Medium-Light"},
	{"1f3fd", "medium", "Medium"},
	{"1f3fe", "medium-dark", "Medium-Dark"},
	{"1f3ff", "dark", "Dark"},
}

fs.mkdirSync(dest)
fs.mkdirSync(dest_tones)

for _, tone in ipairs(skinTones) do
	fs.mkdirSync(dest_tones .."/".. tone[2])
end

for dir in fs.scandirSync(src) do
	local this = src .."/".. dir
	local meta = json.decode(
		fs.readFileSync(this .."/metadata.json")
	)

	if fs.existsSync(this .."/3D") then
		for img in fs.scandirSync(this .."/3D") do
			fs.renameSync(this .."/3D/".. img, dest .."/".. meta.unicode:gsub(" ", "-") ..".png")
		end
	elseif fs.existsSync(this .."/Default") then
		for img in fs.scandirSync(this .."/Default/3D") do
			fs.renameSync(this .."/3D/".. img, dest .."/".. meta.unicode:gsub(" ", "-") ..".png")
		end

		for _, tone in ipairs(skinTones) do
			if fs.existsSync(this .."/".. tone[3]) then
				local dir2 = this .."/".. tone[3] .."/3D"

				if fs.existsSync(dir2) then
					for img in fs.scandirSync(dir2) do
						fs.renameSync(dir2 .."/".. img, dest_tones .."/".. tone[2] .."/".. meta.unicode:gsub(" ", "-") ..".png")
					end
				end
			end
		end
	end
end