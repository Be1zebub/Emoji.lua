local Emoji = {
	_VERSION = 1.0,
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

-- string: emoji name (+1, thumbsup, e.t.c)
-- string: provider (twitter, google, apple, facebook)
-- number: size (64, 72, 96, e.t.c) - use 64 if you didnt know whats sizes avaiable for this provider
-- number: skinTone (see skin-tones there: https://github.com/Be1zebub/Emoji.lua/blob/main/skinTones.jpg)
function Emoji.Get(name, provider, size, skinTone) -- Emoji.GetURL("thumbsup", "twitter", 64)
	local dir = provider .."-".. size
	local file =  dir .."/".. name
	if skinTone then
		file = file .. "_".. skinTone
	end
	return file ..".png", dir
end

function Emoji.GetPath(emoji)
	return "emoji.lua/".. emoji)
end

function Emoji.GetURL(emoji)
	return "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/map/".. emoji ..".png"
end

-- same args as in Emoji.GetPath, but with callback (on success downloading)
function Emoji.Download(name, provider, size, skinTone, cback, retry_count)
	local emoji, dir = Emoji.Get(name, provider, size, skinTone)
	local path = Emoji.GetPath(emoji)

	if file.Exists(path) then
		return cback(path)
	end

	local function download(isRetry)
		if isRetry then
	        if retry_count and retry_count > 0 then
	            retry_count = retry_count - 1
	            download(true)
	        end
	    else
	    	file.CreateDir(dir)
			http.Fetch(Emoji.GetURL(emoji), function(img, _, _, code)
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
end

-- same args as in Emoji.Download
function Emoji.GetMaterial(name, provider, size, skinTone, cback, retry_count)
	Emoji.Download(name, provider, size, skinTone, function(path)
		cback(Material(path))
	end, retry_count)
end

return Emoji