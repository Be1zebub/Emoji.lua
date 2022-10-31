local fs = require("fs")

local resize = "ffmpeg -i %q -pix_fmt rgba -vf \"format=rgba,scale=iw*min(64/iw\\,64/ih):ih*min(64/iw\\,64/ih),pad=64:64:(64-iw)/2:(64-ih)/2:black@0.0\" %q"

fs.mkdirSync("tmp")

for dir in fs.scandirSync("src") do
	fs.mkdirSync("tmp/".. dir)

	for file in fs.scandirSync("src/".. dir) do
		local src = "src/".. dir .."/".. file
		local dest = "tmp/".. dir .."/".. file

		if fs.existsSync(dest) == false then
			local cmd = resize:format(src, dest)
			print(cmd)
			os.execute(cmd)
		end
	end
end