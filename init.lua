local Emoji = {
	_VERSION = 2.1,
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

local fs, httpGET, jsonDecode

if gmod then
	fs, httpGET, jsonDecode = file, http.Fetch, util.JSONToTable
elseif process and process.argv and (function()
	for _, arg in pairs(process.argv) do
		if arg:find("luvit", 1, true) then
			return true
		end
	end

	return false
end)() then
	fs = {
		Write 		= require("fs").writeFileSync,
		Read 		= require("fs").readFileSync,
		CreateDir 	= require("fs").mkdirSync
	}

	local request = require("coro-http").request

	httpGET = function(url, cback)
		local success, res, response = pcall(request, "GET", url)
		if success then
			cback(response)
		end
	end

	jsonDecode = require("json").decode
end

fs.CreateDir("emoji.lua")
fs.CreateDir("emoji.lua/db")
fs.CreateDir("emoji.lua/assets")

local function ReadOrFetch(path, url, cback)
	if fs.Exists(path, "DATA") then
		cback(fs.Read(path, "DATA"))
		return true
	else
		httpGET(url, function(response)
			fs.Write(path, response)
			cback(response)
		end)
	end
end

setmetatable(Emoji, {
	__call = function(self, repo, dbName, defaultAssets, branch)
		local running = coroutine.running()

		local instance = setmetatable({
			dbName = dbName,
			db = {},
			aliases = {},
			assets = {},
			raw = "https://raw.githubusercontent.com/".. repo .."/".. (branch or "master") .."/"
		}, self)

		if ReadOrFetch("emoji.lua/db/".. dbName ..".json", instance.raw .."db/".. dbName ..".json", function(json)
			local db = jsonDecode(json)

			instance.assets = db.assets
			instance.db = db.emoji
			instance.defaultAssets = defaultAssets or db.defaultAssets or instance.assets[1]

			for _, dir in ipairs(instance.assets) do
				fs.CreateDir("emoji.lua/assets/".. dir)
			end

			for _, data in ipairs(instance.db) do
				for _, alias in ipairs(data.aliases) do
					instance.aliases[alias] = data.uid
				end
			end

			coroutine.resume(running, instance)
		end) then
			return instance
		end

		return coroutine.yield()
	end
})

--—————————————————— Emote meta ——————————————————--

local Emote = {}

Emote.__index = Emote
Emote.IsEmoji = true

function Emote:Path(assetPack)
	return self.parent:Path(self.uid, assetPack)
end

function Emote:URL(assetPack)
	return self.parent:URL(self.uid, assetPack)
end

function Emote:Download(assetPack)
	return self.parent:Download(self.uid, assetPack)
end

if gmod then
	function Emote:Material(assetPack, flags)
		return self.parent:Material(self.uid, assetPack, flags)
	end
end

function Emote:__tostring()
	return string.format("Emote(%q, %q)", self.parent.dbName, self.uid)
end

--—————————————————— Emoji meta ——————————————————--

Emoji.__index = Emoji

function Emoji:Lookup(alias)
	local emote = self.aliases[alias:gsub(":", "")]

	if emote then
		emote = setmetatable({parent = self, uid = emote}, Emote)
	end

	return emote
end

-- ":airplane:" > Emote("emoji", "2708-fe0f")

function Emoji:Search(query, isPattern, storage)
	isPattern = isPattern or false

	storage = storage or {}

	for _, data in ipairs(self.db) do
		for _, alias in ipairs(data.aliases) do
			if alias:find(query, 1, isPattern) then
				storage[#storage + 1] = self:Lookup(alias)
			end
		end
	end

	return storage
end

-- "thumb" > {Emote("emoji", "1f44d"), Emote("emoji", "1f44e")}

function Emoji:Parse(text)
	local out = {}

	for alias in text:gmatch(":[%w%p]+:") do
		local emote = self:Lookup(alias)
		if emote then
			local start, finish = text:find(alias)

			local pre = text:sub(1, start - 1)

			if #pre > 0 then
				out[#out + 1] = pre
			end

			text = text:sub(finish + 1)

			out[#out + 1] = emote
		end
	end

	if #text > 0 then
		out[#out + 1] = text
	end

	return out
end

-- ":wave: world! I love :new_moon:️" > {Emoji("emoji", "1f44b"), "world! I love", Emoji("emoji", "1f311")}

function Emoji:Path(uid, assetPack)
	assetPack = isstring(assetPack) and assetPack or (
		self.assets[assetPack] or
		self.defaultAssets
	)

	return "assets/".. assetPack .."/".. uid ..".png"
end

-- "1f44d-1f3fd", "twitter" > "emoji/twitter/1f44d-1f3fd.png"

function Emoji:URL(uid, assetPack)
	return self.raw .. self:Path(uid, assetPack)
end

-- "1f44d-1f3fd", "google" > "https://raw.githubusercontent.com/Be1zebub/Emoji.lua/assets/emoji/google/1f44d-1f3fd.png"

function Emoji:Download(uid, assetPack)
	local running = coroutine.running()

	httpGET(self:URL(uid, assetPack), function(raw, _, _, code)
		if code ~= 200 or raw:find("<!DOCTYPE HTML>", 1, true) then
			coroutine.resume(running)
		else
			coroutine.resume(running, raw)
		end
	end)

	return coroutine.yield()
end

-- "1f44d-1f3fd", "twitter" > response from https://raw.githubusercontent.com/Be1zebub/Emoji.lua/assets/emoji/google/1f44d-1f3fd.png

--[[
coroutine.wrap(function()
	local raw = Emoji:Download("1f44d-1f3fd", "twitter")
end)()
]]--

if gmod then
	function Emoji:Material(uid, assetPack, flags)
		local running = coroutine.running()
		local path = self:Path(uid, assetPack)

		ReadOrFetch(path, self:URL(uid, assetPack), function()
			coroutine.resume(running, Material("data/".. path, flags or "smooth mips"))
		end)

		return coroutine.yield()
	end
end

--[[
coroutine.wrap(function()
	local imaterial = Emoji:Material("1f44d-1f3fd", "apple")
end)()
]]--

--—————————————————— Emoji helpers ——————————————————--

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

--—————————————————— Collection ——————————————————--

local Collection = {}

Collection.__index = Collection

setmetatable(Collection, {
	__call = function(self, ...)
		local instance = setmetatable({list = {}}, self)

		if ... then
			for _, emotes in ipairs({...}) do
				instance:Add(emotes)
			end
		end

		return instance
	end
})

function Collection:Add(emotes)
	self.list[#self.list + 1] = emotes
	return self
end

function Collection:Lookup(alias)
	for _, emotes in ipairs(self.list) do
		local emote = emotes:Lookup(alias)
		if emote then
			return emote
		end
	end
end

function Collection:Search(query, isPattern, storage)
	storage = storage or {}

	for _, emotes in ipairs(self.list) do
		emotes:Search(query, isPattern, storage)
	end

	return storage
end

function Collection:Parse(text)
	return self.list[1].Parse(self, text)
end

function Emoji:Collection(...)
	return Collection(...)
end

--—————————————————— Debug menu ——————————————————--

function Emoji:Debug()
	surface.CreateFont("Emoji.lua", {
		size = 24,
		font = "Roboto",
		extended = true,
		antialias = true
	})

	coroutine.wrap(function()
		local emojis = Emoji:Collection()
		:Add(Emoji("Be1zebub/Emoji.lua", "emoji", "emoji/noto"))
		:Add(Emoji("Be1zebub/Emoji.lua", "elite-pepe"))
		:Add(Emoji("Be1zebub/Emoji.lua", "elite-gorgeous"))
		:Add(Emoji("Be1zebub/Emoji.lua", "elite-roflan"))

		local menu = vgui.Create("DFrame")
		menu:SetSize(440, 300)
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
			--Msg(string.rep("\n", 2))
			--print("\n> ".. text)
			--PrintTable(emojis:Parse(text))

			local msg = me:Add("EditablePanel")
			msg:Dock(TOP)
			msg:DockMargin(0, 8, 0, 0)

			coroutine.wrap(function()
				for _, part in ipairs(emojis:Parse(text)) do
					if part.IsEmoji then
						if inc_ui then
							local img = msg:Add("inc_ui/material")
							img:Dock(LEFT)
							img:SetWide(msg:GetTall())
							img:SetIcon(part:URL())
						else
							local img = msg:Add("DImage")
							img:Dock(LEFT)
							img:SetWide(msg:GetTall())
							img:SetMaterial(part:Material(nil, "smooth mips"))
						end
					else
						local txt = msg:Add("DLabel")
						txt:Dock(LEFT)
						txt:SetText(part)
						txt:SetFont("Emoji.lua")
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

		scroll:AddText(":wtf: Gorgeous freeman :pleasure: emote pack :not_bad:")
		scroll:AddText(":wave: world! I love :new_moon_with_face:")
		scroll:AddText("i have :medal_sports:, because im cool :owo:")
		scroll:AddText(":hmm: hmm, seems good :very_dovolen:")
	end)()
end

--Emoji:Debug()

return Emoji