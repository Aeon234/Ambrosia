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
		self.frame.text:SetText("")
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

function ID:SettingsExampleTest(state)
	local inInstance, instanceType = IsInInstance()

	if self.frame:IsShown() and inInstance then
		return
	elseif self.frame:IsShown() and not self.OptionFrame:IsShown() then
		self.frame:Hide()
	else
		self.frame.text:SetText("|cffff3860M+|r21")
		self.frame:Show()
		-- if ExampleTextTimer then
		-- 	ExampleTextTimer:Cancel()
		-- end
		-- ExampleTextTimer = C_Timer.NewTimer(10, function()
		-- 	self.frame:Hide()
		-- 	ExampleTextTimer = nil
		-- end)
	end
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
	-- text:SetPoint(self.db.align or "LEFT")
	text:SetPoint("LEFT")
	self.text = text

	self.frame = self
end

function ID:LoadPosition()
	if not self.db then
		return
	end

	local difficulty = _G.MinimapCluster.InstanceDifficulty
	local anchor = _G.MinimapCluster.BorderTop
	difficulty:ClearAllPoints()
	if self.db.align == "LEFT" then
		-- difficulty:SetPoint("TOPLEFT", _G.MinimapCluster, "TOPLEFT", 40, -20)
		difficulty:SetPoint("TOPLEFT", _G.MinimapCluster.MinimapContainer, "TOPLEFT", 0, 0)
		-- difficulty:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, -15)
	elseif self.db.align == "RIGHT" then
		difficulty:ClearAllPoints()
		difficulty:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 0, -15)
	end
	difficulty:SetPoint(
		self.db.align,
		_G.MinimapCluster.MinimapContainer,
		self.db.align,
		self.db.offsetX,
		self.db.offsetY
	)
end

function ID:ADDON_LOADED(_, addon)
	if addon == "Blizzard_Minimap" then
		self:UnregisterEvent("ADDON_LOADED")

		local difficulty = _G.MinimapCluster.InstanceDifficulty
		self:LoadPosition()
		for _, frame in pairs({ difficulty.Default, difficulty.Guild, difficulty.ChallengeMode }) do
			frame:SetAlpha(0)
		end
	end
end

ID.GROUP_ROSTER_UPDATE = Ambrosia.DelvesEventFix(ID.UpdateFrame)

function ID:SettingsUpdate()
	if not self.db then
		return
	end

	self:LoadPosition()
	self.text:SetFont(Ambrosia.DefaultFont, self.db.fontSize, self.db.fontOutline)
end

local function Options_IDAlign(value)
	Ambrosia.db.InstanceDifficultySettings.align = value
	Ambrosia.db.InstanceDifficultySettings.offsetX = 0
	Ambrosia.db.InstanceDifficultySettings.offsetY = 0
	if ID.OptionFrame then
		local sx = ID.OptionFrame:FindWidget("ID_OffsetX")
		if sx and sx.SetValue then
			sx:SetValue(0)
		end
		local sy = ID.OptionFrame:FindWidget("ID_OffsetY")
		if sy and sy.SetValue then
			sy:SetValue(0)
		end
	end
	ID:SettingsUpdate()
end

local function Options_IDTextSize(value)
	Ambrosia.db.InstanceDifficultySettings.fontSize = value
	ID:SettingsUpdate()
end

local function Options_IDOffsetX(value)
	Ambrosia.db.InstanceDifficultySettings.offsetX = value
	ID:SettingsUpdate()
end

local function Options_IDOffsetY(value)
	Ambrosia.db.InstanceDifficultySettings.offsetY = value
	ID:SettingsUpdate()
end

local function Options_Slider_FormatWholeValue(value)
	return format("%d", value)
end

local OPTIONS_SCHEMATIC = {
	title = "Instance Difficulty Options",
	widgets = {
		{
			type = "Dropdown",
			label = "Align",
			tooltip = "Align the text to the top left or top right of the frame.",
			options = { -- Dropdown options
				{ text = "Top Left", value = "TOPLEFT" },
				{ text = "Top Right", value = "TOPRIGHT" },
				{ text = "Bottom Left", value = "BOTTOMLEFT" },
				{ text = "Bottom Right", value = "BOTTOMRIGHT" },
			},
			onValueChangedFunc = Options_IDAlign,
			dbKey = "InstanceDifficultySettings.align",
		},
		{
			type = "Slider",
			label = "Font Size",
			minValue = 5,
			maxValue = 60,
			valueStep = 1,
			onValueChangedFunc = Options_IDTextSize,
			formatValueFunc = Options_Slider_FormatWholeValue,
			dbKey = "InstanceDifficultySettings.fontSize",
		},
		{
			type = "Slider",
			label = "Offset X",
			minValue = -50,
			maxValue = 50,
			valueStep = 1,
			onValueChangedFunc = Options_IDOffsetX,
			formatValueFunc = Options_Slider_FormatWholeValue,
			dbKey = "InstanceDifficultySettings.offsetX",
			widgetKey = "ID_OffsetX",
		},
		{
			type = "Slider",
			label = "Offset Y",
			minValue = -50,
			maxValue = 50,
			valueStep = 1,
			onValueChangedFunc = Options_IDOffsetY,
			formatValueFunc = Options_Slider_FormatWholeValue,
			dbKey = "InstanceDifficultySettings.offsetY",
			widgetKey = "ID_OffsetY",
		},
	},
}

function ID:ShowOptions(state)
	if state then
		local forceUpdate = true
		self.OptionFrame = Ambrosia.SetupSettingsDialog(self, OPTIONS_SCHEMATIC, forceUpdate)
		self.OptionFrame:Show()
		self.OptionFrame:SetScript("OnHide", function()
			ID:SettingsExampleTest(false)
		end)
		ID:SettingsExampleTest(state)
		if self.OptionFrame.requireResetPosition then
			self.OptionFrame.requireResetPosition = false
			self.OptionFrame:ClearAllPoints()
			local top = 1 or self.bar:GetTop()
			local left = 1 or self.bar:GetLeft()
			self.OptionFrame:SetPoint("CENTER", UIParent, "CENTER", 500, 100)
		end
	else
		if self.OptionFrame then
			self.OptionFrame:HideOption(self)
		end
	end
end

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

	self.enabled = true
end

function ID:Disable()
	if self.enabled then
		Ambrosia:ReloadPopUp()
		self.db.enable = false
	end
	self.enabled = false
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
		else
			ID:ShowOptions(true)
		end
	end

	local moduleData = {
		name = "Instance Difficulty",
		dbKey = "InstanceDifficulty",
		description = "Reskin the instance difficulty indicator in text style.",
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 4,
		optionToggleFunc = OptionToggle_OnClick,
	}

	Ambrosia.Config:AddModule(moduleData)
end
