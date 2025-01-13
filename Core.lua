local addonName, Ambrosia = ...

Ambrosia.DefaultValues = {
	DebugMode = true,
	UIScale = false,
	RaidMarkers = true,
	RaidMarkerSettings = {
		enable = true,
		mouseOver = false,
		tooltip = true,
		-- visibility = "DEFAULT",
		backdrop = true,
		backdropSpacing = 1,
		buttonSize = 32,
		buttonBackdrop = true,
		spacing = 3,
		orientation = "HORIZONTAL",
		-- modifier = "shift",
		readyCheck = true,
		countDown = true,
		countDownTime = 12,
		inverse = false,
		PosX = nil,
		PosY = nil,
	},
}
Ambrosia.API = {} --Custom APIs used by this addon
Ambrosia.DefaultFont = "Interface/AddOns/Ambrosia/Media/Expressway.TTF"

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
end

local ADDON_LOADED = CreateFrame("Frame")
ADDON_LOADED:RegisterEvent("ADDON_LOADED")
ADDON_LOADED:RegisterEvent("PLAYER_ENTERING_WORLD")

ADDON_LOADED:SetScript("OnEvent", function(self, event, ...)
	local name = ...
	if name == addonName then
		self:UnregisterEvent(event)
		Ambrosia:LoadDatabase()
		Ambrosia:PrintDebug("Unregistering " .. event)
	end
end)
