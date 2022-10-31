local categories = {
	gorgeous = "Gorgeous Freeman",
	linear = "Linear emoji",
	memes = "Memes",
	neko = "Neko",
	pepe = "Pepe",
	roflan = "Roflans",
	vk = "Vkontakte"
}

local fs = require("fs")
local json = require("json")

for dir, type in fs.scandirSync(".") do
	if type == "directory" then
		local db = {}

		for file in fs.scandirSync(dir) do
			local uid = file:gsub(".png", "")

			db[#db + 1] = {
				uid = uid,
				aliases = {uid},
				category = categories[dir]
			}
		end

		fs.writeFileSync("../../db/elite-".. dir ..".json", json.encode({
			assets = {"elite/".. dir},
			emoji = db
		}))
	end
end