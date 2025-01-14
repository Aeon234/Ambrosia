local _, Ambrosia = ...

local PrintDebug = function(...)
	Ambrosia:PrintDebug(...)
end

local _G = _G
local format = format
local gsub = gsub
local pairs = pairs
local select = select

local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_ChallengeMode_GetActiveKeystoneInfo = C_ChallengeMode.GetActiveKeystoneInfo

local ID = CreateFrame("Frame", "InstanceDifficultyFrame", _G.Minimap)
ID:SetScript("OnEvent", function(self, event, ...)
	self:UpdateFrame()
end)

function ID:UpdateFrame()
	local inInstance, instanceType = IsInInstance()
	local difficulty = select(3, GetInstanceInfo())
	local numplayers = select(9, GetInstanceInfo())
	local mplusdiff = select(1, C_ChallengeMode_GetActiveKeystoneInfo()) or ""

	if difficulty == 0 then
		self.frame.text:SetText("test")
	elseif instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		local text = ID:GetTextForDifficulty(difficulty, false)

		if not text then
			self:Log("debug", format("difficutly %s not found", difficulty))
			text = ""
		end

		text = gsub(text, "%%mplus%%", mplusdiff)
		text = gsub(text, "%%numPlayers%%", numplayers)
		self.frame.text:SetText(text)
	elseif instanceType == "pvp" or instanceType == "arena" then
		self.frame.text:SetText(ID:GetTextForDifficulty(-1, false))
	else
		self.frame.text:SetText("")
	end

	self.frame:SetShown(inInstance)
end

function ID:GetTextForDifficulty(difficulty, useDefault)
	local db = self.db.difficulty.customStrings
	local text = {
		[-1] = db["PvP"],
		[1] = db["5-player Normal"],
		[2] = db["5-player Heroic"],
		[3] = db["10-player Normal"],
		[4] = db["25-player Normal"],
		[5] = db["10-player Heroic"],
		[6] = db["25-player Heroic"],
		[7] = db["LFR"],
		[8] = db["Mythic Keystone"],
		[9] = db["40-player"],
		[11] = db["Heroic Scenario"],
		[12] = db["Normal Scenario"],
		[14] = db["Normal Raid"],
		[15] = db["Heroic Raid"],
		[16] = db["Mythic Raid"],
		[17] = db["LFR Raid"],
		[18] = db["Event Scenario"],
		[19] = db["Event Scenario"],
		[20] = db["Event Scenario"],
		[23] = db["Mythic Party"],
		[24] = db["Timewalking"],
		[25] = db["World PvP Scenario"],
		[29] = db["PvEvP Scenario"],
		[30] = db["Event Scenario"],
		[32] = db["World PvP Scenario"],
		[33] = db["Timewalking Raid"],
		[34] = db["PvP Heroic"],
		[38] = db["Normal Scenario"],
		[39] = db["Heroic Scenario"],
		[40] = db["Mythic Scenario"],
		[45] = db["PvP"],
		[147] = db["Warfronts Normal"],
		[149] = db["Warfronts Heroic"],
		[150] = db["Normal Scaling Party"],
		[151] = db["LFR"],
		[152] = db["Visions of N'Zoth"],
		[153] = db["Teeming Island"],
		[167] = db["Torghast"],
		[168] = db["Path of Ascension: Courage"],
		[169] = db["Path of Ascension: Loyalty"],
		[170] = db["Path of Ascension: Wisdom"],
		[171] = db["Path of Ascension: Humility"],
		[172] = db["World Boss"],
		[192] = db["Challenge Level 1"],
		[205] = db["Follower"],
		[208] = db["Delves"],
		[216] = db["Quest"],
		[220] = db["Story"],
	}

	return text[difficulty]
end

function ID:ConstructFrame()
	if not self.db then
		return
	end

	local difficulty = _G.MinimapCluster.InstanceDifficulty

	self:SetSize(30, 20)
	self:SetPoint("CENTER", difficulty, "CENTER", 0, 0)

	local text = self:CreateFontString(nil, "OVERLAY")
	text:SetFont(Ambrosia.DefaultFont, self.db.fontSize, self.db.fontOutline)
	text:SetPoint(self.db.align or "LEFT")
	self.text = text

	self.frame = self
end

function ID:HideBlizzardDifficulty(difficultyFrame, isShown)
	if not self.db or not self.db.hideBlizzard or not isShown then
		return
	end

	difficultyFrame:Hide()
end

function ID:ADDON_LOADED(_, addon)
	if addon == "Blizzard_Minimap" then
		self:UnregisterEvent("ADDON_LOADED")

		local difficulty = _G.MinimapCluster.InstanceDifficulty
		AMBTest = _G.MinimapCluster
		difficulty:ClearAllPoints()
		difficulty:SetPoint("TOPLEFT", _G.MinimapCluster, "TOPLEFT", 40, -20)
		for _, frame in pairs({ difficulty.Default, difficulty.Guild, difficulty.ChallengeMode }) do
			frame:SetAlpha(0)
		end
	end
end

ID.GROUP_ROSTER_UPDATE = Ambrosia.DelvesEventFix(ID.UpdateFrame)

function ID:Initialize() end

function ID:Enable()
	self.db.enable = true

	if not self.db or not self.db.enable or self.enabled then
		return
	end

	self:ConstructFrame()

	ID:RegisterEvent("PLAYER_ENTERING_WORLD")
	ID:RegisterEvent("CHALLENGE_MODE_START")
	ID:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	ID:RegisterEvent("CHALLENGE_MODE_RESET")
	ID:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
	ID:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
	ID:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	ID:RegisterEvent("GROUP_ROSTER_UPDATE")

	if C_AddOns_IsAddOnLoaded("Blizzard_Minimap") then
		self:ADDON_LOADED("ADDON_LOADED", "Blizzard_Minimap")
	else
		self:RegisterEvent("ADDON_LOADED")
	end

	self:UpdateFrame()

	-- if self.db.enable and not self.bar then
	-- 	PrintDebug("Creating RM Bar")
	-- 	self:CreateBar()
	-- elseif self.db.enable and self.bar then
	-- 	self:ToggleSettings()
	-- end

	self.enabled = true
	PrintDebug("Minimap Button Container Enabled")
end

function ID:Disable()
	if self.enabled then
		self.db.enable = false
		-- self:ToggleSettings()
	end
	self.enabled = false
	PrintDebug("Minimap Button Container Disabled")
end

do
	local function EnableModule(state)
		if not ID.db then
			ID.db = Ambrosia.db.InstanceDifficultySettings
			AMBTest = ID.db
		end
		if state then
			ID:Enable()
		else
			ID:Disable()
		end
	end

	local function OptionToggle_OnClick(self, button)
		if
			ID.OptionFrame
			and ID.OptionFrame:IsShown()
			and (ID.OptionFrame:IsOwner(self) or ID.OptionFrame:IsOwner(ID))
		then
			ID:ShowOptions(false)
			ID:ExitEditMode()
		else
			ID:ShowOptions(true)
			ID:EnterEditMode()
		end
	end

	local moduleData = {
		name = "Instance Difficulty",
		dbKey = "InstanceDifficulty",
		description = "Reskin the instance difficulty indicator in text style.",
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 3,
		optionToggleFunc = OptionToggle_OnClick,
	}

	Ambrosia.Config:AddModule(moduleData)
end
