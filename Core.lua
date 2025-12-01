local addonName, Ambrosia = ...

local norm = format("|cff1eff00%s|r", "N")
local hero = format("|cff0070dd%s|r", "H")
local myth = format("|cffa335ee%s|r", "M")
local lfr = format("|cffff8000%s|r", "LFR")

Ambrosia.DefaultValues = {
	DebugMode = false,
	UIScale = false,
	UIScaleNum = 0.65,
	EscapeMenuScale = false,
	EscapeMenuScaleNum = 1.0,
	CantRelease = false,
	InstanceDifficulty = true,
	InstanceDifficultySettings = {
		enable = false,
		align = "TOPLEFT",
		fontSize = 12,
		fontOutline = "OUTLINE",
		offsetX = 0,
		offsetY = 0,
		difficulty = {
			custom = false,
			customStrings = {
				["PvP"] = format("|cffFFFF00%s|r", "PvP"),
				["5-player Normal"] = "5" .. norm,
				["5-player Heroic"] = "5" .. hero,
				["10-player Normal"] = "10" .. norm,
				["25-player Normal"] = "25" .. norm,
				["10-player Heroic"] = "10" .. hero,
				["25-player Heroic"] = "25" .. hero,
				["LFR"] = lfr,
				["Mythic Keystone"] = format("|cffff3860%s|r", "M+") .. "%mplus%",
				["40-player"] = "40",
				["Normal Scenario"] = format("%s %s", norm, "Scen"),
				["Heroic Scenario"] = format("%s %s", hero, "Scen"),
				["Mythic Scenario"] = format("%s %s", myth, "Scen"),
				["Normal Raid"] = "%numPlayers%" .. norm,
				["Heroic Raid"] = "%numPlayers%" .. hero,
				["Mythic Raid"] = "%numPlayers%" .. myth,
				["LFR Raid"] = "%numPlayers%" .. lfr,
				["Event Scenario"] = "EScen",
				["Mythic Party"] = "5" .. myth,
				["Timewalking"] = "TW",
				["World PvP Scenario"] = format("|cffFFFF00%s |r", "PvP"),
				["PvEvP Scenario"] = "PvEvP",
				["Timewalking Raid"] = "TW",
				["PvP Heroic"] = format("|cffFFFF00%s |r", "PvP"),
				["Warfronts Normal"] = "WF",
				["Warfronts Heroic"] = format("|cffff7d0aH|r%s", "WF"),
				["Normal Scaling Party"] = "NSP",
				["Visions of N'Zoth"] = "Visions",
				["Teeming Island"] = "Teeming",
				["Torghast"] = "Torghast",
				["Path of Ascension: Courage"] = "PoA",
				["Path of Ascension: Loyalty"] = "PoA",
				["Path of Ascension: Wisdom"] = "PoA",
				["Path of Ascension: Humility"] = "PoA",
				["World Boss"] = "WB",
				["Challenge Level 1"] = "CL1",
				["Follower"] = "Follower",
				["Delves"] = "Delves",
				["Quest"] = "Quest",
				["Story"] = "Story",
			},
		},
	},
	RaidMarkers = true,
	RaidMarkerSettings = {
		enable = true,
		mouseOver = false,
		tooltip = true,
		visibility = "DEFAULT", --"Always Display", "Default", "In Party"
		backdrop = true,
		backdropSpacing = 1,
		buttonSize = 32,
		buttonBackdrop = true,
		buttonSpacing = 3,
		orientation = 1,
		modifier = "shift",
		readyCheck = true,
		countDown = true,
		countDownTime = 12,
		inverse = false,
		PosX = nil,
		PosY = nil,
	},
	WorldMarkerCycler = true,
	WorldMarkerCyclerSettings = {
		WorldMarkerCycler_Order = { 5, 6, 3, 2, 7, 1, 4, 8 },
		Cycler_Star = true,
		Cycler_Circle = true,
		Cycler_Diamond = true,
		Cycler_Triangle = true,
		Cycler_Moon = true,
		Cycler_Square = true,
		Cycler_X = true,
		Cycler_Skull = true,
	},
	WhoseKey = true,
	WhoseKeySettings = {
		PosX = nil,
		PosY = nil,
	},
	AddonProfiler = true,
}
Ambrosia.API = {} --Custom APIs used by this addon
Ambrosia.DefaultFont = "Interface/AddOns/Ambrosia/Media/Expressway.TTF"

Ambrosia.WorldMarkers = {
	{ id = 1, icon = "Star", textAtlas = 8, wmID = 5 },
	{ id = 2, icon = "Circle", textAtlas = 7, wmID = 6 },
	{ id = 3, icon = "Diamond", textAtlas = 6, wmID = 3 },
	{ id = 4, icon = "Triangle", textAtlas = 5, wmID = 2 },
	{ id = 5, icon = "Moon", textAtlas = 4, wmID = 7 },
	{ id = 6, icon = "Square", textAtlas = 3, wmID = 1 },
	{ id = 7, icon = "X", textAtlas = 2, wmID = 4 },
	{ id = 8, icon = "Skull", textAtlas = 1, wmID = 8 },
}

-- ==============================
-- === Shortcuts and Keybinds ===
-- ==============================
_G["BINDING_NAME_CLICK WorldMarker_Placer:LeftButton"] = "World Marker Cycler"
_G["BINDING_NAME_CLICK WorldMarker_Remover:LeftButton"] = "World Marker Erase"

do
	local tocVersion = select(4, GetBuildInfo())
	tocVersion = tonumber(tocVersion or 0)

	Ambrosia.IsGame_11_0_0 = tocVersion >= 110000
end

function Ambrosia:LoadDatabase()
	Ambrosia_DB = Ambrosia_DB or {}
	self.db = Ambrosia_DB

	for dbKey, value in pairs(self.DefaultValues) do
		if self.db[dbKey] == nil then
			if ElvUI and dbKey == "UIScale" then
				self.db[dbKey] = false
			else
				self.db[dbKey] = value
			end
		end
	end

	local function GetDBValue(dbKeyPath)
		local keys = { strsplit(".", dbKeyPath) }
		local value = self.db

		for _, key in ipairs(keys) do
			value = value[key]
			if value == nil then
				return nil
			end
		end

		return value
	end
	self.GetDBValue = GetDBValue

	local function SetDBValue(dbKeyPath, newValue)
		local keys = { strsplit(".", dbKeyPath) }
		local dbRef = self.db

		for i = 1, #keys - 1 do
			local key = keys[i]
			dbRef = dbRef[key]
			if dbRef == nil then
				return false
			end
		end

		dbRef[keys[#keys]] = newValue
		return true
	end
	self.SetDBValue = SetDBValue

	self.DefaultValues = nil

	local width, height = GetPhysicalScreenSize()
	self.uiScaleCurrent = 768 / height
end

local ADDON_LOADED = CreateFrame("Frame")
ADDON_LOADED:RegisterEvent("ADDON_LOADED")
ADDON_LOADED:RegisterEvent("PLAYER_ENTERING_WORLD")

ADDON_LOADED:SetScript("OnEvent", function(self, event, ...)
	local name = ...
	if name == addonName then
		self:UnregisterEvent(event)
		Ambrosia:LoadDatabase()
		Ambrosia:PrintDebug("Database Loaded")
	end
end)
