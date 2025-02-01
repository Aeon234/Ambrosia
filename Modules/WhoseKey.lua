local _, Ambrosia = ...

local PrintDebug = function(...)
	Ambrosia:PrintDebug(...)
end

local WK = CreateFrame("Button", nil, UIParent)
local World_EventListenerFrame = CreateFrame("Frame")

WK.NameFrame = {}
WK.KeyLvlFrame = {}
WK.Name = {}
WK.KeyLvl = {}
WK.PartyKeystones = {}
WK.PartyKeystones_Text = {}
WK.PartyKeystones_Info = {}

local Prog_Width = 350
local Prog_Height = 16
local countdownTime = 30
local updateInterval = 0.01
local elapsedTime = countdownTime
local nextUpdate = updateInterval
local DEFAULT_POSITION_Y = 400

local WK_DEBUG = {
	{ playerRoleArt = "GM-icon-role-tank", player = " |c00C69B6DAeonwar|r", level = "32" },
	{ playerRoleArt = "GM-icon-role-healer", player = " |c00F58CBAAeonheals|r", level = "17" },
	{ playerRoleArt = "GM-icon-role-dps", player = " |c0069CCF0Aeonmagus|r", level = "14" },
	{ playerRoleArt = "GM-icon-role-dps", player = " |c00C41F3BAeondeath|r", level = "7" },
	{ playerRoleArt = "GM-icon-role-dps", player = " |c009482C9Aeonlock|r", level = "2" },
}

-- Dungeon info by expansion
WK.SeasonalDungeons = {
	--The War Within
	{ abbr = "SF", name = "Priory of the Sacred Flame", spellID = 445444, mapID = 499, instanceID = 2649 }, -- Priory of the Sacred Flame
	{ abbr = "ROOK", name = "The Rookery", spellID = 445443, mapID = 500, instanceID = 2648 }, -- The Rookery
	{ abbr = "SV", name = "The Stonevault", spellID = 445269, mapID = 501, instanceID = 2652 }, -- The Stonevault
	{ abbr = "COT", name = "City of Threads", spellID = 445416, mapID = 502, instanceID = 2669 }, -- City of Threads
	{ abbr = "ARAK", name = "Ara-Kara, City of Echoes", spellID = 445417, mapID = 503, instanceID = 2660 }, -- Ara-Kara, City of Echoes
	{ abbr = "DC", name = "Darkflame Cleft", spellID = 445441, mapID = 504, instanceID = 2651 }, -- Darkflame Cleft
	{ abbr = "DAWN", name = "The Dawnbreaker", spellID = 445414, mapID = 505, instanceID = 2662 }, -- The Dawnbreaker
	{ abbr = "CM", name = "Cinderbrew Meadery", spellID = 445440, mapID = 506, instanceID = 2661 }, -- Cinderbrew Meadery
	--Dragonflight
	{ abbr = "RLP", name = "Ruby Life Pools", spellID = 393256, mapID = 399, instanceID = 2521 }, -- Ruby Life Pools
	{ abbr = "NO", name = "The Nokhud Offensive", spellID = 393262, mapID = 400, instanceID = 2516 }, -- The Nokhud Offensive
	{ abbr = "AV", name = "The Azure Vault", spellID = 393279, mapID = 401, instanceID = 2515 }, -- The Azure Vault
	{ abbr = "AA", name = "Algeth'ar Academy", spellID = 393273, mapID = 402, instanceID = 2526 }, -- Algeth'ar Academy
	{ abbr = "ULD", name = "Uldaman: Legacy of Tyr", spellID = 393222, mapID = 403, instanceID = 2451 }, -- Uldaman: Legacy of Tyr
	{ abbr = "NELT", name = "Neltharus", spellID = 393276, mapID = 404, instanceID = 2519 }, -- Neltharus
	{ abbr = "HOI", name = "Halls of Infusion", spellID = 393283, mapID = 406, instanceID = 2527 }, -- Halls of Infusion
	{ abbr = "BH", name = "Brackenhide Hollow", spellID = 393267, mapID = 405, instanceID = 2520 }, -- Brackenhide Hollow
	{
		abbr = "FALL",
		name = "Dawn of the Infinite: Galakrond's Fall",
		spellID = 424197,
		mapID = 463,
		instanceID = 2579,
	}, -- Dawn of the Infinite: Galakrond's Fall
	{ abbr = "RISE", name = "Dawn of the Infinite: Murozond's Rise", spellID = 424197, mapID = 464, instanceID = 2579 }, -- Dawn of the Infinite: Murozond's Rise
	--Shadowlands
	{ abbr = "MISTS", name = "Mist of Tirna Scithe", spellID = 354464, mapID = 375, instanceID = 2290 }, -- Mist of Tirna Scithe
	{ abbr = "NW", name = "Necrotic Wake", spellID = 354462, mapID = 376, instanceID = 2286 }, -- Necrotic Wake
	{ abbr = "DOS", name = "De Other Side", spellID = 354468, mapID = 377, instanceID = 2291 }, -- De Other Side
	{ abbr = "HOA", name = "Halls of Atonement", spellID = 354465, mapID = 378, instanceID = 2287 }, -- Halls of Atonement
	{ abbr = "PF", name = "Plaguefall", spellID = 354463, mapID = 379, instanceID = 2289 }, -- Plaguefall
	{ abbr = "SD", name = "Sanguine Depths", spellID = 354469, mapID = 380, instanceID = 2284 }, -- Sanguine Depths
	{ abbr = "SOA", name = "Spires of Ascension", spellID = 354466, mapID = 381, instanceID = 2285 }, -- Spires of Ascension
	{ abbr = "TOP", name = "Theater of Pain", spellID = 354467, mapID = 382, instanceID = 2293 }, -- Theater of Pain
	{
		abbr = "WNDR",
		name = "Tazavesh, the Veiled Market: Streets of Wonder",
		spellID = 367416,
		mapID = 391,
		instanceID = 2441,
	}, -- Tazavesh, the Veiled Market: Streets of Wonder
	{
		abbr = "GMBT",
		name = "Tazavesh, the Veiled Market: So'leah's Gambit",
		spellID = 367416,
		mapID = 392,
		instanceID = 2441,
	}, -- Tazavesh, the Veiled Market: So'leah's Gambit
	--Battle for Azeroth
	{ abbr = "AD", name = "Atal'Dazar", spellID = 424187, mapID = 244, instanceID = 1763 }, -- Atal'Dazar
	{ abbr = "FH", name = "Freehold", spellID = 410071, mapID = 245, instanceID = 1754 }, -- Freehold
	-- { abbr = "TD", name = "Tol Dagor", spellID = 445418, mapID = 246, instanceID=1771 }, -- Tol Dagor
	-- { abbr = "TM", name = "The MOTHERLODE!!", spellID = 445418, mapID = 247, instanceID=1594 }, -- The MOTHERLODE!!
	{ abbr = "WM", name = "Waycrest Manor", spellID = 424167, mapID = 248, instanceID = 1862 }, -- Waycrest Manor
	-- { abbr = "KR", name = "Kings' Rest", spellID = 445418, mapID = 249, instanceID=1762 }, -- Kings' Rest
	-- { abbr = "TS", name = "Temple of Sethraliss", spellID = 445418, mapID = 250, instanceID=1877 }, -- Temple of Sethraliss
	{ abbr = "UNDR", name = "The Underrot", spellID = 410074, mapID = 251, instanceID = 1841 }, -- The Underrot
	-- { abbr = "SS", name = "Shrine of the Storm", spellID = 445418, mapID = 252, instanceID=1864 }, -- Shrine of the Storm
	{ abbr = "SIEGE", name = "Siege of Boralus", spellID = 464256, mapID = 353, instanceID = 1822 }, -- Siege of Boralus
	{ abbr = "JY", name = "Operation: Mechagon: Junkyard", spellID = 373274, mapID = 369, instanceID = 2097 }, -- Operation: Mechagon: Junkyard
	{ abbr = "WS", name = "Operation: Mechagon: Workshop", spellID = 373274, mapID = 370, instanceID = 2097 }, -- Operation: Mechagon: Workshop
	--Legion
	{ abbr = "DHT", name = "Darkheart Thicket", spellID = 424163, mapID = 198, instanceID = 1466 }, -- Darkheart Thicket
	{ abbr = "BRH", name = "Black Rook Hold", spellID = 424153, mapID = 199, instanceID = 1501 }, -- Black Rook Hold
	{ abbr = "HOV", name = "Halls of Valor", spellID = 393764, mapID = 200, instanceID = 1477 }, -- Halls of Valor
	{ abbr = "NL", name = "Neltharion's Lair", spellID = 410078, mapID = 206, instanceID = 1458 }, -- Neltharion's Lair
	{ abbr = "COS", name = "Court of Stars", spellID = 393766, mapID = 210, instanceID = 1571 }, -- Court of Stars
	{ abbr = "LOWER", name = "Return to Karazhan: Lower", spellID = 373262, mapID = 277, instanceID = 1651 }, -- Return to Karazhan: Lower
	{ abbr = "UPPER", name = "Return to Karazhan: Upper", spellID = 373262, mapID = 234, instanceID = 1651 }, -- Return to Karazhan: Upper
	--Warlords of Draenor
	{ abbr = "SR", name = "Skyreach", spellID = 159898, mapID = 161, instanceID = 1209 }, -- Skyreach
	{ abbr = "BSM", name = "Bloodmaul Slag Mines", spellID = 159895, mapID = 163, instanceID = 1175 }, -- Bloodmaul Slag Mines
	{ abbr = "AUC", name = "Auchindoun", spellID = 159897, mapID = 164, instanceID = 1182 }, -- Auchindoun
	{ abbr = "SBG", name = "Shadowmoon Burial Grounds", spellID = 159899, mapID = 165, instanceID = 1176 }, -- Shadowmoon Burial Grounds
	{ abbr = "GD", name = "Grimrail Depot", spellID = 159900, mapID = 166, instanceID = 1208 }, -- Grimrail Depot
	{ abbr = "UBRS", name = "Upper Blackrock Spire", spellID = 159902, mapID = 167, instanceID = 1358 }, -- Upper Blackrock Spire
	{ abbr = "EB", name = "The Everbloom", spellID = 159901, mapID = 168, instanceID = 1279 }, -- The Everbloom
	{ abbr = "ID", name = "Iron Docks", spellID = 159896, mapID = 169, instanceID = 1195 }, -- Iron Docks
	--Mist of Pandaria
	{ abbr = "TJS", name = "Temple of the Jade Serpent", spellID = 131204, mapID = 2, instanceID = 960 }, -- Temple of the Jade Serpent
	--Cataclysm
	{ abbr = "VP", name = "The Vortex Pinnacle", spellID = 410080, mapID = 438, instanceID = 657 }, -- The Vortex Pinnacle
	{ abbr = "TOTT", name = "Throne of the Tides", spellID = 424142, mapID = 456, instanceID = 456 }, -- Throne of the Tides
	{ abbr = "GB", name = "Grim Batol", spellID = 445424, mapID = 507, instanceID = 670 }, -- Grim Batol
}

function WK:Initialize()
	PrintDebug("Initializing WK")
	-- General Frame
	self:SetSize(380, 250)
	self:Hide()
	self:SetPropagateMouseClicks(true)
	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", function(self, button, down)
		self:Hide()
		PrintDebug("Hiding WK")
	end)
	-- Title
	self.Title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	self.Title:SetPoint("TOP", self, "TOP", 0, -10)
	self.Title:SetText("Ready Check Initiated")
	self.Title:SetFont(Ambrosia.DefaultFont, 36)

	--Progress Bar
	self.ProgressBar = CreateFrame("Frame", nil, self)
	self.ProgressBar:SetSize(Prog_Width, Prog_Height)
	self.ProgressBar:SetPoint("TOP", self.Title, "BOTTOM", 0, -4)

	self.ProgressBar.bg = self.ProgressBar:CreateTexture(nil, "BACKGROUND")

	self.ProgressBar.bg:SetTexture("Interface/Buttons/WHITE8x8")
	self.ProgressBar.bg:SetAllPoints(self.ProgressBar)
	self.ProgressBar.bg:SetVertexColor(1, 1, 1, 0.5)

	Mixin(self.ProgressBar, BackdropTemplateMixin)
	self.ProgressBar:SetBackdrop({
		edgeFile = "Interface/BUTTONS/WHITE8X8",
		edgeSize = 1,
	})
	self.ProgressBar:SetBackdropBorderColor(0, 0, 0)

	self.ProgressBar.bar = CreateFrame("StatusBar", nil, self.ProgressBar)
	self.ProgressBar.bar:SetSize(Prog_Width - 2, Prog_Height - 2)
	self.ProgressBar.bar:SetPoint("CENTER")
	self.ProgressBar.bar:SetStatusBarTexture("Interface/Buttons/WHITE8x8")
	self.ProgressBar.bar:SetStatusBarColor(1, 0.7, 0.19)
	self.ProgressBar.bar:SetMinMaxValues(0, countdownTime)
	self.ProgressBar.bar:SetValue(countdownTime)

	self.ProgressBar.spark = self.ProgressBar.bar:CreateTexture(nil, "OVERLAY")
	self.ProgressBar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	self.ProgressBar.spark:SetBlendMode("ADD")
	self.ProgressBar.spark:SetSize(10, 30)
	self.ProgressBar.spark:SetPoint("CENTER", self.ProgressBar.bar, "LEFT", self.ProgressBar.bar:GetWidth(), 0)

	self.ProgressBar.bar:SetScript("OnValueChanged", function(self, value)
		local sparkPosition = (value / countdownTime) * self:GetWidth()
		WK.ProgressBar.spark:SetPoint("CENTER", WK.ProgressBar, "LEFT", sparkPosition, 0)
		local colorProgress = value / countdownTime
		local r = 1
		local g = 0.7 - (0.02 * (1 - colorProgress))
		local b = 0.19 + (0.03 * (1 - colorProgress))
		WK.ProgressBar.bar:SetStatusBarColor(r, g, b)
	end)

	self.ProgressBar.text = self.ProgressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.ProgressBar.text:SetJustifyH("LEFT")
	self.ProgressBar.text:SetPoint("RIGHT", self.ProgressBar.bar, "RIGHT", 0, 0)
	self.ProgressBar.text:SetTextColor(1, 1, 1, 1)

	-- Frames that hold Name & Key Levels
	for i = 1, 5 do
		self.NameFrame[i] = CreateFrame("Frame", nil, self)
		self.NameFrame[i]:SetSize(self.Title:GetUnboundedStringWidth() / 6 * 5, 36)
		if i == 1 then
			self.NameFrame[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -64)
		else
			self.NameFrame[i]:SetPoint("TOPLEFT", self.NameFrame[i - 1], "BOTTOMLEFT")
		end
		self.KeyLvlFrame[i] = CreateFrame("Frame", nil, self)
		self.KeyLvlFrame[i]:SetSize(self.Title:GetUnboundedStringWidth() / 6, 36)
		if i == 1 then
			self.KeyLvlFrame[i]:SetPoint("TOPRIGHT", self, "TOPRIGHT", -14, -64)
		else
			self.KeyLvlFrame[i]:SetPoint("TOPRIGHT", self.KeyLvlFrame[i - 1], "BOTTOMRIGHT")
		end

		self.Name[i] = self.NameFrame[i]:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		self.Name[i]:SetPoint("LEFT", self.NameFrame[i], "LEFT")
		self.Name[i]:SetText(CreateAtlasMarkup(WK_DEBUG[i].playerRoleArt) .. WK_DEBUG[i].player)
		self.Name[i]:SetFont(Ambrosia.DefaultFont, 28)

		self.KeyLvl[i] = self.KeyLvlFrame[i]:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		self.KeyLvl[i]:SetPoint("RIGHT", self.KeyLvlFrame[i], "RIGHT")
		self.KeyLvl[i]:SetText("+" .. WK_DEBUG[i].level)
		self.KeyLvl[i]:SetFont(Ambrosia.DefaultFont, 28)
	end

	-- Fade Out Animation
	self.fadeOut = self:CreateAnimationGroup()
	local fadeOut = self.fadeOut:CreateAnimation("Alpha")
	fadeOut:SetDuration(2)
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0)
	fadeOut:SetStartDelay(0)
	fadeOut:SetSmoothing("OUT")

	self.fadeOut:SetScript("OnFinished", function(self)
		WK:Hide()
	end)
end

function WK:LoadPosition()
	self:ClearAllPoints()
	if self.db.PosX and self.db.PosY then
		if self.db.PosX > 0 then
			self:setPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.PosX, self.db.PosY)
		else
			self:SetPoint("TOP", UIParent, "BOTTOM", 0, self.db.PosY)
		end
	else
		self:SetPoint("CENTER", UIParent, "CENTER", 0, DEFAULT_POSITION_Y)
	end
end

function WK:GroupInfo()
	wipe(self.PartyKeystones_Info or {})
	if Details and not UnitInRaid("player") then
		self.OpenRaidLib = LibStub("LibOpenRaid-1.0", true)
		for i = 1, 5 do
			local unitID = i == 1 and "player" or "party" .. i - 1
			local data = self.OpenRaidLib.GetKeystoneInfo(unitID)
			local mapID = data and data.challengeMapID
			for _, dungeon in ipairs(self.SeasonalDungeons) do
				if dungeon.mapID == mapID then
					Keyname_abbr = dungeon.abbr
					if mapID and Keyname_abbr then
						local level = data.level
						local playerClass = UnitClassBase(unitID)
						local playerName = UnitName(unitID)
						local texture = select(4, C_ChallengeMode.GetMapUIInfo(tonumber(mapID)))
						local name = dungeon.name
						local instanceID = dungeon.instanceID

						tinsert(self.PartyKeystones_Info, {
							level = level,
							mapID = tonumber(mapID),
							instanceID = instanceID,
							abbr = Keyname_abbr,
							name = name,
							player = AMB_ClassColorString(playerName, playerClass),
							playerName = tostring(playerName),
							playerClass = playerClass,
							icon = texture,
						})
					end
				end
			end
		end
		--Sort the keys found from highest to lowest
		if #self.PartyKeystones_Info > 1 then
			table.sort(self.PartyKeystones_Info, function(a, b)
				return b.level < a.level
			end)
		end
	end
end

function WK:ShowFrame()
	wipe(self.PartyKeystones_Text or {})
	self:GroupInfo()
	local _, _, _, _, _, _, _, CurrentInstanceID, _, _ = GetInstanceInfo()
	local RelevantKeystones = {}
	--Grab relevant keystones into a separate table
	for _, key in ipairs(self.PartyKeystones_Info) do
		if key.instanceID == CurrentInstanceID then
			tinsert(RelevantKeystones, {
				level = key.level,
				mapID = key.mapID,
				instanceID = key.instanceID,
				name = key.name,
				player = key.player,
				playerName = key.playerName,
				playerClass = key.playerClass,
				playerRole = "",
				playerRoleArt = "",
			})
		end
	end
	--Sort the keys found from highest to lowest
	if #RelevantKeystones > 1 then
		table.sort(RelevantKeystones, function(a, b)
			return b.level < a.level
		end)
	end
	local GroupSize = GetNumGroupMembers()
	local SelectedPlayer = {}
	if GroupSize > 0 then
		for i = 1, GroupSize do
			if i == 1 then
				SelectedPlayer[i] = "player"
			else
				SelectedPlayer[i] = "party" .. i - 1
			end
		end
	end
	--Grab every players role (TANK, DAMAGER, HEALER)
	if #SelectedPlayer > 0 then
		for _, player in ipairs(RelevantKeystones) do
			for i = 1, #SelectedPlayer do
				local playerName, _ = UnitName(SelectedPlayer[i])
				local playerRole = UnitGroupRolesAssigned(SelectedPlayer[i])
				if playerName == player.playerName then
					player.playerRole = playerRole
				end
			end
		end
	end
	--Assign the atlas art that will be used alongside player names
	for _, player in ipairs(RelevantKeystones) do
		if player.playerRole == "TANK" then
			player.playerRoleArt = "GM-icon-role-tank"
		elseif player.playerRole == "HEALER" then
			player.playerRoleArt = "GM-icon-role-healer"
		elseif player.playerRole == "DAMAGER" then
			player.playerRoleArt = "GM-icon-role-dps"
		end
	end
	--Set the Player Name and Key Level Text
	for i = 1, 5 do
		local PlayerName = self.Name[i]
		local KeyLevel = self.KeyLvl[i]
		if RelevantKeystones[i] then
			PlayerName:SetText(CreateAtlasMarkup(RelevantKeystones[i].playerRoleArt) .. RelevantKeystones[i].player)
			KeyLevel:SetText("+" .. RelevantKeystones[i].level)
		else
			PlayerName:SetText("")
			KeyLevel:SetText("")
		end
	end
	if #RelevantKeystones > 0 then
		self:LoadPosition()
		self:Show()
	end
end

-- Edit Mode
function WK:ShowExampleText()
	for i = 1, 5 do
		local PlayerName = self.Name[i]
		PlayerName:SetText(CreateAtlasMarkup(WK_DEBUG[i].playerRoleArt) .. WK_DEBUG[i].player)

		local KeyLevel = self.KeyLvl[i]
		KeyLevel:SetText("+" .. WK_DEBUG[i].level)
	end
	self:LoadPosition()
	self:Show()
end

function WK:EnterEditMode()
	if not self.enabled then
		return
	end

	if not self.Selection then
		local uiName = "Whose Key"
		local hideLabel = true
		self.Selection = Ambrosia.CreateEditModeSelection(self, uiName, hideLabel)
	end

	self:ShowExampleText()
	self.isEditing = true
	self:SetScript("OnUpdate", nil)
	self.Selection:ShowHighlighted()
end

function WK:ExitEditMode()
	if self.Selection then
		self.Selection:Hide()
	end
	self.isEditing = false
	self:Hide()
end

function WK:OnDragStart()
	self:SetMovable(true)
	self:SetDontSavePosition(true)
	self:SetClampedToScreen(true)
	self:StartMoving()
end

function WK:OnDragStop()
	self:StopMovingOrSizing()

	local centerX = self:GetCenter()
	local uiCenter = UIParent:GetCenter()
	local left = self:GetLeft()
	local top = self:GetTop()

	left = Round(left)
	top = Round(top)

	self:ClearAllPoints()

	--Convert anchor and save position
	if math.abs(uiCenter - centerX) <= 48 then
		--Snap to centeral line
		self:SetPoint("TOP", UIParent, "BOTTOM", 0, top)
		Ambrosia.db.WhoseKeySettings.PosX = -1
		self.db.PosX = -1
	else
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		Ambrosia.db.WhoseKeySettings.PosX = left
		self.db.PosX = left
	end
	Ambrosia.db.WhoseKeySettings.PosY = top
	self.db.PosY = top

	if self.OptionFrame and self.OptionFrame:IsOwner(self) then
		local button = self.OptionFrame:FindWidget("ResetButton")
		if button then
			button:Enable()
		end
	end
end

function WK:IsFocused()
	return (self:IsShown() and self:IsMouseOver())
		or (self.OptionFrame and self.OptionFrame:IsShown() and self.OptionFrame:IsMouseOver())
end

local function Options_ResetPosition_ShouldEnable(self)
	if Ambrosia.db.WhoseKeySettings.PosX and Ambrosia.db.WhoseKeySettings.PosY then
		return true
	else
		return false
	end
end

local function Options_ResetPosition_OnClick(self)
	self:Disable()
	WK.db.PosX = nil
	WK.db.PosY = nil
	Ambrosia.db.WhoseKeySettings.PosX = nil
	Ambrosia.db.WhoseKeySettings.PosY = nil
	WK:LoadPosition(WK)
end

local OPTIONS_SCHEMATIC = {
	title = "Relevant Mythic+ Keystones",
	widgets = {
		{ type = "Divider" },
		{
			type = "UIPanelButton",
			label = "Reset To Default Position",
			onClickFunc = Options_ResetPosition_OnClick,
			stateCheckFunc = Options_ResetPosition_ShouldEnable,
			widgetKey = "ResetButton",
		},
	},
}

function WK:ShowOptions(state)
	if state then
		local forceUpdate = true
		self.OptionFrame = Ambrosia.SetupSettingsDialog(self, OPTIONS_SCHEMATIC, forceUpdate)
		self.OptionFrame:Show()
		if self.OptionFrame.requireResetPosition then
			self.OptionFrame.requireResetPosition = false
			self.OptionFrame:ClearAllPoints()
			local top = 1 or self:GetTop()
			local left = 1 or self:GetLeft()
			self.OptionFrame:SetPoint("CENTER", UIParent, "CENTER", 500, 100)
		end
	else
		if self.OptionFrame then
			self.OptionFrame:HideOption(self)
		end
	end
end

function WK:Enable()
	if self.enabled then
		return
	end
	if not WK.ProgressBar then
		WK:Initialize()
		WK:LoadPosition()
	end
	World_EventListenerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	if Details then
		World_EventListenerFrame:RegisterEvent("READY_CHECK")
		World_EventListenerFrame:RegisterEvent("READY_CHECK_FINISHED")
		World_EventListenerFrame:RegisterEvent("WORLD_STATE_TIMER_START")
		PrintDebug("Registering READY_CHECK, READY_CHECK_FINISHED WORLD_STATE_TIMER_START")
	else
		PrintDebug("Details not detected")
	end
	self.enabled = true
end

function WK:Disable()
	if self.enabled then
		World_EventListenerFrame:UnregisterAllEvents()
	end
	self.enabled = false
end

do
	local EDITMODE_HOOKED = false

	local function EditMode_Enter()
		if ENABLE_MODULE then
			WK:EnterEditMode()
		end
	end

	local function EnableModule(state)
		-- if not Details then
		-- 	WK.enabled = false
		-- 	WK:Disable()
		-- 	PrintDebug("Details Missing, Disabling Whose Key")
		-- 	return
		-- end
		if not WK.db then
			WK.db = Ambrosia.db.WhoseKeySettings
		end
		if state then
			ENABLE_MODULE = true
			WK:Enable()
			if not EDITMODE_HOOKED then
				EDITMODE_HOOKED = true
				EventRegistry:RegisterCallback("EditMode.Enter", EditMode_Enter)
				EventRegistry:RegisterCallback("EditMode.Exit", WK.ExitEditMode, WK)
			end
		else
			ENABLE_MODULE = false
			WK:Disable()
		end
	end

	local function OptionToggle_OnClick(self, button)
		if WK.OptionFrame and WK.OptionFrame:IsShown() then
			WK:ShowOptions(false)
			WK:ExitEditMode()
		else
			WK:ShowOptions(true)
			WK:EnterEditMode()
		end
	end

	local moduleData = {
		name = "Show Relevant Mythic+ Keys",
		dbKey = "WhoseKey",
		description = "When a ready check is initated while inside of a dungeon, if you or party members have an eligible Mythic+ Keystone the list of these players and key levels will be displayed on screen\nRight click the pop-up to hide it.",
		toggleFunc = EnableModule,
		categoryID = 2,
		uiOrder = 3,
		optionToggleFunc = OptionToggle_OnClick,
	}

	Ambrosia.Config:AddModule(moduleData)
end

local function EventHandler(self, event, ...)
	PrintDebug(event .. " triggered")
	if event == "PLAYER_ENTERING_WORLD" then
		if Details then
			self:RegisterEvent("READY_CHECK")
			self:RegisterEvent("READY_CHECK_FINISHED")
			self:RegisterEvent("WORLD_STATE_TIMER_START")
			PrintDebug("Registering READY_CHECK, READY_CHECK_FINISHED WORLD_STATE_TIMER_START")
		else
			self:UnregisterAllEvents()
			PrintDebug("Unregistering all events due to missing Details! addon")
			return
		end
	end

	local inInstance, instanceType = IsInInstance()

	if event == "READY_CHECK" and inInstance and IsInGroup() and not IsInRaid() then
		elapsedTime = countdownTime
		local startTime = GetTime() -- Store the start time
		WK.ProgressBar.bar:SetValue(elapsedTime)
		WK:SetScript("OnUpdate", function(self, elapsed)
			local currentTime = GetTime()
			elapsedTime = countdownTime - (currentTime - startTime) -- Calculate exact elapsed time
			if elapsedTime <= 0 then
				elapsedTime = 0
				WK:SetScript("OnUpdate", nil)
				WK.fadeOut:Play()
				PrintDebug("Hiding WK Frame")
			end
			WK.ProgressBar.bar:SetValue(elapsedTime)
			WK.ProgressBar.text:SetText(string.format("%.1f", elapsedTime))
		end)
		WK:ShowFrame()
		PrintDebug("Showing WK Frame")
	elseif event == "WORLD_STATE_TIMER_START" or event == "READY_CHECK_FINISHED" then
		if not WK.fadeOut:IsPlaying() and WK.Frame:IsShown() then
			WK.fadeOut:Play()
			PrintDebug("Hiding WK Frame")
		end
	end
end

World_EventListenerFrame:SetScript("OnEvent", EventHandler)
