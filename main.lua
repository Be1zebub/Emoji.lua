local Emoji = {
	_VERSION = 1.0,
	_Async   = true,
	_URL 	 = "https://github.com/Be1zebub/Emoji.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2022 incredible-gmod.ru
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}

file.CreateDir("emoji.lua/_map")
file.CreateDir("emoji.lua/apple-64")
file.CreateDir("emoji.lua/apple-160")
file.CreateDir("emoji.lua/facebook-64")
file.CreateDir("emoji.lua/facebook-96")
file.CreateDir("emoji.lua/google-64")
file.CreateDir("emoji.lua/google-136")
file.CreateDir("emoji.lua/twitter-64")
file.CreateDir("emoji.lua/twitter-72")

local list = {}
function Emoji.Get(name, skinTone, cback)
	local uid = name
	if skinTone and skinTone > 1 then
		uid = uid .. "_".. skinTone
	end
	
	if list[uid] then
		cback(list[uid])
	elseif file.Exists("emoji.lua/_map/".. uid ..".txt", "DATA") then
		list[uid] = file.Read("emoji.lua/_map/".. uid ..".txt")
		cback(list[uid])
	else
		print("https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/map/".. uid ..".txt")
		http.Fetch("https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/map/".. uid ..".txt", function(emoji, _, _, code)
			if code ~= 200 then return end

			file.Write("emoji.lua/_map/".. uid ..".txt", emoji)
			list[uid] = emoji
			cback(emoji)
		end)
	end
end

function Emoji.GetPath(name, provider, size, skinTone, cback)  -- Emoji.GetPath("thumbsup", "twitter", 64, 4, print)
	Emoji.Get(name, skinTone, function(emoji)
		local upath = provider .."-".. size .."/".. emoji ..".png"
		cback("emoji.lua/".. upath, upath)
	end)
end

function Emoji.Download(name, provider, size, skinTone, cback, retry_count)
	Emoji.GetPath(name, provider, size, skinTone, function(path, upath)
		if file.Exists(path, "DATA") then
			cback(path)
			return
		end

		local function download(isRetry)
			if isRetry then
		        if retry_count and retry_count > 0 then
		            retry_count = retry_count - 1
		            download(true)
		        end
		    else
		    	print("https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/emoji/" .. upath)
				http.Fetch("https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/emoji/".. upath, function(img, _, _, code)
					if code ~= 200 or img:find("<!DOCTYPE HTML>", 1, true) then
						download(true)
					else
						file.Write(path, img)
						cback(path)
					end
				end, download)
		    end
		end

		download()
	end)
end

function Emoji.IsDownloaded(name, provider, size, skinTone, cback)
	Emoji.GetPath(name, provider, size, skinTone, function(path)
		cback(file.Exists(path))
	end)
end

function Emoji.GetMaterial(name, provider, size, skinTone, cback, retry_count)
	return Emoji.Download(name, provider, size, skinTone, function(path)
		cback(Material("data/".. path))
	end, retry_count)
end

--[[ Example:
Emoji.GetMaterial("thumbsup", "twitter", 64, math.random(0, 6), function(mat)
    hook.Add("HUDPaint", "Thumbsup-emoji", function()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(16, 16, 64, 64)
    end)
end)
]]--
