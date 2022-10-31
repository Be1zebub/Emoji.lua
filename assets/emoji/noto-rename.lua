local fs = require("fs")


local src = "noto"

for fname in fs.scandirSync(src) do
	fs.renameSync(src .."/".. fname, src .."/".. fname:gsub("emoji_u", ""):gsub("_", "-"))
end