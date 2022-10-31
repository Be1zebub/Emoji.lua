local Emoji = {
	_VERSION = 2.0,
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
	]],
	config = {
		emoji = {
			assets = "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/master/assets/emoji/",
			db = "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/master/db/emoji.json",
			filename = "emoji-db.json",
			dir = "emoji"
		},
		custom = {
			{
				assets = "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/master/assets/custom/",
				db = "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/master/db/custom.json",
				filename = "emoji-db.json",
				dir = "custom"
			}
		}
	}
}

local function prepareAssoc()
	Emoji.aliases = {}

	for _, data in ipairs(Emoji.db) do
		for _, alias in ipairs(data.aliases) do
			Emoji.aliases[alias] = data.emoji
		end
	end
end

local function fetchDB(cfg, cback)
	if file.Exists("emoji.lua/".. cfg.filename, "DATA") then
		cback(
			util.JSONToTable(file.Read("emoji.lua/".. cfg.filename, "DATA"))
		)
	else
		local function Download()
			http.Fetch(cfg.db, function(json_db)
				local db = util.JSONToTable(json_db)

				file.Write("emoji.lua/".. cfg.filename, util.TableToJSON(db))
				cback(db)
			end)
		end

		if CurTime() == 0 then
			timer.Simple(0, Download) -- w8 4 1st tick
		else
			Download()
		end
	end
end

--[[
fetchDB(Emoji.config.emoji, function()
	if file.Exists("emoji.lua/db.json", "DATA") then
		Emoji.db = util.JSONToTable(file.Read("emoji.lua/db.json", "DATA"))
	end
end)

fetchDB(Emoji.config.custom, function()

end)
]]--

if file.Exists("emoji.lua/db.json", "DATA") then
	Emoji.db = util.JSONToTable(file.Read("emoji.lua/db.json", "DATA"))
	prepareAssoc()
else
	hook.Add("Think", "https://github.com/Be1zebub/Emoji.lua", function()
		hook.Remove("Think", "https://github.com/Be1zebub/Emoji.lua")

		http.Fetch("https://raw.githubusercontent.com/github/gemoji/master/db/emoji.json", function(json_db)
			local db = util.JSONToTable(json_db)

			for i, data in ipairs(db) do
				db[i] = {
					aliases = data.aliases,
					category = data.category,
					emoji = data.emoji
				}
			end

			file.Write("emoji.lua/db.json", util.TableToJSON(db))
			Emoji.db = db
			prepareAssoc()
		end)
	end)
end

function Emoji:Lookup(alias)
	return self.aliases[alias:gsub(":", "")]
end

-- "airplane" > "✈️"

function Emoji:Search(query, is_pattern)
	is_pattern = is_pattern or false

	local out = {}

	for _, data in ipairs(Emoji.db) do
		for _, alias in ipairs(data.aliases) do
			if alias:find(query, 1, is_pattern) then
				out[#out + 1] = data.emoji
			end
		end
	end

	return out
end

-- "thumb" > {"👍", "👎"}

local skinTones = {
	"1f3fb", -- light
	"1f3fc", -- medium light
	"1f3fd", -- medium
	"1f3fe", -- medium dark
	"1f3ff" -- dark
}

function Emoji:Codepoints(emoji, skinTone)
	local out = {}

	for _, c in utf8.codes(self:Lookup(emoji) or emoji) do
		out[#out + 1] = string.format("%x", c)
	end

	out = table.concat(out, "-")

	if skinTone and skinTones[skinTone] then
		out = out .."-".. skinTones[skinTone]
	end

	return out
end

-- "✈️" > 2708-fe0f
-- "👍", 3 > 1f44d-1f3fd

function Emoji:Parse(text, skinTone)
	local out = {}

	for alias in text:gmatch(":[%w%p]+:") do
		local start, finish = text:find(alias)

		local pre = text:sub(1, start - 1)

		if #pre > 0 then
			out[#out + 1] = pre
		end

		text = text:sub(finish + 1)

		local emote = self:Lookup(alias)

		out[#out + 1] = emote and {
			emote,
			self:Codepoints(emote, skinTone)
		} or alias
	end

	if #text > 0 then
		out[#out + 1] = text
	end

	return out
end

-- :wave: world! I love 🌚️ > {{"👋", "1f44b"}, "world! I love", {"🌚", 1f31a"}, ":)"}

function Emoji:Path(name, provider, size)
	return (provider or "twitter") .."-".. (size or 64) .."/".. name ..".png"
end

-- "1f44d-1f3fd", "twitter", 72 > "twitter-72/1f44d-1f3fd.png"

function Emoji:URL(name, provider, size)
	return "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/emoji/".. self:Path(name, provider, size)
end

-- "1f44d-1f3fd", "google", 64, 3 > "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/emoji/google-64/1f44d-1f3fd.png"

function Emoji:Download(name, provider, size)
	local running = coroutine.running()

	http.Fetch(self:URL(name, provider, size), function(raw, _, _, code)
		if code ~= 200 or raw:find("<!DOCTYPE HTML>", 1, true) then
			coroutine.resume(running)
		else
			coroutine.resume(running, raw)
		end
	end)

	return coroutine.yield()
end

-- "1f44d-1f3fd", "twitter", 72, 3 > response from https://raw.githubusercontent.com/Be1zebub/Emoji.lua/main/emoji/twitter-72/1f44d-1f3fd.png

--[[
coroutine.wrap(function()
	local raw = Emoji:Download("1f44d-1f3fd", "twitter", 72, 3)
end)()
]]--

function Emoji:Material(name, provider, size, skinTone, flags)
	local path = self:Path(name, provider, size, skinTone)

	if file.Exists(path, "DATA") == false then
		local raw = self:Download(name, provider, size, skinTone)
		if raw == nil then return end

		file.Write(path, raw)
	end

	return Material("data/".. path, flags)
end

--[[
coroutine.wrap(function()
	local imaterial = Emoji:Material("1f44d-1f3fd", "apple", 64, 2, "smooth")
end)()
]]--

function Emoji:Debug()

	local menu = vgui.Create("DFrame")
	menu:SetSize(400, 240)
	menu:Center()
	menu:MakePopup()
	menu:SetTitle("Emoji.lua v".. (math.floor(self._VERSION) == self._VERSION and self._VERSION ..".0" or self._VERSION))
	menu:DockPadding(11, 26 + 11, 11, 11)
	menu.Paint = function(me, w, h)
		surface.SetDrawColor(54, 57, 63)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(32, 34, 37)
		surface.DrawRect(0, 0, w, 26)
	end

	local scroll = menu:Add("DScrollPanel")
	scroll:Dock(FILL)
	scroll.AddText = function(me, text)
		Msg(string.rep("\n", 2))
		print("\n> ".. text)
		PrintTable(Emoji:Parse(text))

		local msg = me:Add("EditablePanel")
		msg:Dock(TOP)
		msg:DockMargin(0, 8, 0, 0)

		coroutine.wrap(function()
			for _, part in ipairs(Emoji:Parse(text)) do
				if istable(part) then
					if inc_ui then
						local img = msg:Add("inc_ui/material")
						img:Dock(LEFT)
						img:SetSize(22, 22)
						img:SetIcon(Emoji:URL(part[2], "twitter", 64))
					else
						local img = msg:Add("DImage")
						img:Dock(LEFT)
						img:SetSize(22, 22)
						img:SetMaterial(Emoji:Material(part[2], "twitter", 64, 0, "smooth mips"))
					end
				else
					local txt = msg:Add("DLabel")
					txt:Dock(LEFT)
					txt:SetText(part)
					txt:SizeToContents()
				end
			end
		end)()
	end

	local entry = menu:Add("DTextEntry")
	entry:Dock(BOTTOM)
	entry:SetTall(32)
	entry:SetTextColor(Color(235, 235, 235))
	entry:SetCursorColor(Color(220, 220, 220))
	entry.OnEnter = function(me)
		scroll:AddText(me:GetValue())
	end
	entry.Paint = function(me, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(64, 68, 75))
		me:DrawTextEntryText(me:GetTextColor(), me:GetHighlightColor(), me:GetCursorColor())
	end

	scroll:AddText(":wave: world! I love :new_moon_with_face:")
	scroll:AddText("i have :medal_sports:, because im cool!")
end

Emoji:Debug()

-- todo:
-- Emoji:Add - add custom emoji

function Emoji:Add()

end

return Emoji