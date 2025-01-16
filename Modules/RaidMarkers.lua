local _, Ambrosia = ...

local PrintDebug = function(...)
	Ambrosia:PrintDebug(...)
end

local _G = _G
local GameTooltip = _G.GameTooltip
local API = Ambrosia.API
local DEFAULT_POSITION_Y = -5

local abs = abs
local format = format
local gsub = gsub
local strupper = strupper

local ClearRaidMarker = ClearRaidMarker
local CreateFrame = CreateFrame
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local SetRaidTarget = SetRaidTarget
local UnregisterStateDriver = UnregisterStateDriver

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local lastClear = 0

local TargetToWorld = {
	[1] = 5,
	[2] = 6,
	[3] = 3,
	[4] = 2,
	[5] = 7,
	[6] = 1,
	[7] = 4,
	[8] = 8,
}

local RM = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

function RM:UpdateBar()
	if not self.bar then
		return
	end

	if not self.db.enable then
		self.bar:Hide()
		return
	end

	local previousButton
	local numButtons = 0

	for i = 1, 11 do
		local button = self.bar.buttons[i]
		button:ClearAllPoints()
		button:SetSize(self.db.buttonSize, self.db.buttonSize)
		button.tex:SetSize(self.db.buttonSize, self.db.buttonSize)

		if (i == 10 and not self.db.readyCheck) or (i == 11 and not self.db.countDown) then
			button:Hide()
		else
			button:Show()
			if self.db.orientation == 2 then
				if i == 1 then
					button:SetPoint("TOP", 0, -self.db.backdropSpacing)
				else
					button:SetPoint("TOP", previousButton, "BOTTOM", 0, -self.db.buttonSpacing)
				end
			else
				if i == 1 then
					button:SetPoint("LEFT", self.db.backdropSpacing, 0)
				else
					button:SetPoint("LEFT", previousButton, "RIGHT", self.db.buttonSpacing, 0)
				end
			end
			previousButton = button
			numButtons = numButtons + 1
		end
	end

	local height = self.db.buttonSize + self.db.backdropSpacing * 2
	local width = self.db.backdropSpacing * 2
		+ self.db.buttonSize * numButtons
		+ self.db.buttonSpacing * (numButtons - 1)

	if self.db.orientation == 2 then
		width, height = height, width
	end

	self.bar:Show()
	self.bar:SetSize(width, height)
	self:SetSize(width, height)

	if self.db.backdrop then
		self.bar.backdrop:Show()
	else
		self.bar.backdrop:Hide()
	end
end

function RM:UpdateButtons()
	if not self.bar or not self.bar.buttons then
		return
	end

	self.modifierString = gsub(self.db.modifier, "^%l", strupper)

	for i = 1, 11 do
		local button = self.bar.buttons[i]

		if self.db.buttonBackdrop then
			button.backdrop:Show()
		else
			button.backdrop:Hide()
		end

		if button and button.backdrop.shadow then
			if self.db.backdrop then
				button.backdrop.shadow:Hide()
			else
				button.backdrop.shadow:Show()
			end
		end

		if button.isMarkButton then
			local button = self.bar.buttons[i]
			button:SetAttribute("shift-type*", nil)
			button:SetAttribute("alt-type*", nil)
			button:SetAttribute("ctrl-type*", nil)

			button:SetAttribute(format("%s-type*", self.db.modifier), "macro")

			if not self.db.inverse then
				button:SetAttribute("macrotext1", format("/tm %d", i))
				button:SetAttribute("macrotext2", "/tm 9")
				button:SetAttribute(format("%s-macrotext1", self.db.modifier), format("/wm %d", TargetToWorld[i]))
				button:SetAttribute(format("%s-macrotext2", self.db.modifier), format("/cwm %d", TargetToWorld[i]))
			else
				button:SetAttribute("macrotext1", format("/wm %d", TargetToWorld[i]))
				button:SetAttribute("macrotext2", format("/cwm %d", TargetToWorld[i]))
				button:SetAttribute(format("%s-macrotext1", self.db.modifier), format("/tm %d", i))
				button:SetAttribute(format("%s-macrotext2", self.db.modifier), "/tm 9")
			end
		end
	end
end

function RM:LoadPosition(frame)
	frame:ClearAllPoints()
	if self.db.PosX and self.db.PosY then
		if self.db.PosX > 0 then
			frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.PosX, self.db.PosY)
		else
			frame:SetPoint("TOP", UIParent, "BOTTOM", 0, self.db.PosY)
		end
	else
		frame:SetPoint("TOP", UIParent, "TOP", 0, DEFAULT_POSITION_Y)
	end
end

function RM:CreateBar()
	if self.bar then
		return
	end

	self:SetResizable(false)
	self:SetClampedToScreen(true)
	self:SetFrameStrata("LOW")
	CreateBackdrop(self, "Transparent")

	RM:LoadPosition(self)

	self.buttons = {}
	self.bar = self

	self:CreateButtons()
	self:ToggleSettings()
end

function RM:CreateButtons()
	self.modifierString = self.db.modifier:gsub("^%l", strupper)

	for i = 1, 11 do
		local button = self.bar.buttons[i]
		if not button then
			button = CreateFrame("Button", "amb_button", self.bar, "SecureActionButtonTemplate, BackdropTemplate")
			CreateBackdrop(button, "Transparent")
		end
		button:SetSize(self.db.buttonSize, self.db.buttonSize)

		local tex = button:CreateTexture(nil, "ARTWORK")
		tex:SetSize(self.db.buttonSize, self.db.buttonSize)
		tex:SetPoint("CENTER")
		button.tex = tex

		if i < 9 then
			tex:SetTexture(format("Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d", i))

			button:SetAttribute("type*", "macro")
			button:SetAttribute(format("%s-type*", self.db.modifier), "macro")

			self:UpdateCountDownButton()

			button.isMarkButton = true
		elseif i == 9 then
			tex:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")

			button:SetAttribute("type", "click")
			if not self.db.inverse then
				button:SetScript("OnClick", function(self)
					if _G[format("Is%sKeyDown", RM.modifierString)]() then
						ClearRaidMarker()
					else
						local now = GetTime()
						if now - lastClear > 1 then -- limiting
							lastClear = now
							for i = 8, 0, -1 do
								C_Timer.After((8 - i) * 0.34, function()
									SetRaidTarget("player", i)
								end)
							end
						end
					end
				end)
			else
				button:SetScript("OnClick", function(self)
					if _G[format("Is%sKeyDown", RM.modifierString)]() then
						local now = GetTime()
						if now - lastClear > 1 then -- limiting
							lastClear = now
							for i = 8, 0, -1 do
								E:Delay((8 - i) * 0.34, SetRaidTarget, "player", i)
							end
						end
					else
						ClearRaidMarker()
					end
				end)
			end
		elseif i == 10 then
			tex:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
			button:SetAttribute("type*", "macro")
			button:SetAttribute("macrotext1", "/readycheck")
			button:SetAttribute("macrotext2", "/combatlog")
		elseif i == 11 then
			tex:SetTexture("Interface\\Icons\\Spell_unused2")
			tex:SetTexCoord(0.25, 0.8, 0.2, 0.75)
			button:SetAttribute("type*", "macro")
			if C_AddOns_IsAddOnLoaded("BigWigs") then
				button:SetAttribute("macrotext1", "/pull " .. RM.db.countDownTime)
				button:SetAttribute("macrotext2", "/pull 0")
			elseif C_AddOns_IsAddOnLoaded("DBM-Core") then
				button:SetAttribute("macrotext1", "/dbm pull " .. RM.db.countDownTime)
				button:SetAttribute("macrotext2", "/dbm pull 0")
			else
				button:SetAttribute("macrotext1", _G.SLASH_COUNTDOWN1 .. " " .. RM.db.countDownTime)
				button:SetAttribute("macrotext2", _G.SLASH_COUNTDOWN1 .. " " .. -1)
			end
		end

		-- button:RegisterForClicks(W.UseKeyDown and "AnyDown" or "AnyUp")
		button:RegisterForClicks("AnyDown")

		local tooltipText = ""

		if i < 9 then
			if not self.db.inverse then
				tooltipText = format(
					"%s\n%s\n%s\n%s",
					"Left Click to mark the target with this mark.",
					"Right Click to clear the mark on the target.",
					format("%s + Left Click to place this worldmarker.", RM.modifierString),
					format("%s + Right Click to clear this worldmarker.", RM.modifierString)
				)
			else
				tooltipText = format(
					"%s\n%s\n%s\n%s",
					"Left Click to place this worldmarker.",
					"Right Click to clear this worldmarker.",
					format("%s + Left Click to mark the target with this mark.", RM.modifierString),
					format("%s + Right Click to clear the mark on the target.", RM.modifierString)
				)
			end
		elseif i == 9 then
			if not self.db.inverse then
				tooltipText = format(
					"%s\n%s",
					"Click to clear all marks." .. " (|cff2ecc71" .. "takes 3s" .. "|r)",
					format("%s + Click to remove all worldmarkers.", RM.modifierString)
				)
			else
				tooltipText = format(
					"%s\n%s",
					"Click to remove all worldmarkers.",
					format("%s + Click to clear all marks.", RM.modifierString)
				)
			end
		elseif i == 10 then
			tooltipText =
				format("%s\n%s", "Left Click to ready check.", "Right click to toggle advanced combat logging.")
		elseif i == 11 then
			tooltipText = format("%s\n%s", "Left Click to start count down.", "Right click to stop count down.")
		end

		local tooltipTitle = i <= 9 and "Raid Markers" or "Raid Utility"

		button:SetScript("OnEnter", function(self)
			-- local icon = Ambrosia.GetIconString(W.Media.Textures.smallLogo, 14)
			self:SetBackdropBorderColor(0.7, 0.7, 0)
			if RM.db.tooltip then
				GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
				-- GameTooltip:SetText(tooltipTitle .. " " .. icon)
				GameTooltip:SetText(tooltipTitle .. " ")
				GameTooltip:AddLine(tooltipText, 1, 1, 1)
				GameTooltip:Show()
			end
		end)

		button:SetScript("OnLeave", function(self)
			self:SetBackdropBorderColor(0, 0, 0)
			if RM.db.tooltip then
				GameTooltip:Hide()
			end
		end)

		button:HookScript("OnEnter", function()
			if not self.db.mouseOver then
				return
			end
			self.bar:SetAlpha(1)
			button:SetBackdropBorderColor(0.7, 0.7, 0)
		end)

		button:HookScript("OnLeave", function()
			if not self.db.mouseOver then
				return
			end
			self.bar:SetAlpha(0)
			button:SetBackdropBorderColor(0, 0, 0)
		end)

		self.bar.buttons[i] = button
	end
end

function RM:SettingsDriversUpdate()
	if RM.OptionFrame:IsShown() then
		--PrintDebug("Unregistering Driver for Editing")
		UnregisterStateDriver(self.bar, "visibility")
		-- self.bar:Show()
		self:Show()
	elseif not RM.OptionFrame:IsShown() then
		--PrintDebug("Registering Driver Again")
		if self.Selection then
			self.Selection:Hide()
		end
		-- self:Hide()

		RegisterStateDriver(
			self,
			"visibility",
			self.db.visibility == "DEFAULT" and "[noexists, nogroup] hide; show"
				or self.db.visibility == "ALWAYS" and "[petbattle] hide; show"
				or "[group] show; [petbattle] hide; hide"
		)
	end
end

-- Edit Mode
function RM:EnterEditMode()
	RM:SettingsDriversUpdate()
	if not self.enabled then
		return
	end

	if not self.Selection then
		local uiName = "Raid Markers"
		local hideLabel = false
		self.Selection = Ambrosia.CreateEditModeSelection(self, uiName, hideLabel)
	end

	self.isEditing = true
	self:SetScript("OnUpdate", nil)
	self.Selection:ShowHighlighted()
end

function RM:ExitEditMode()
	RM:SettingsDriversUpdate()
	if self.Selection then
		self.Selection:Hide()
	end
	self.isEditing = false
	self:Hide()
end

function RM:IsFocused()
	return (self.bar:IsShown() and self.bar:IsMouseOver())
		or (self.OptionFrame and self.OptionFrame:IsShown() and self.OptionFrame:IsMouseOver())
end

local function Options_ResetPosition_ShouldEnable(self)
	if Ambrosia.db.RaidMarkerSettings.PosX and Ambrosia.db.RaidMarkerSettings.PosY then
		return true
	else
		return false
	end
end

local function Options_ResetPosition_OnClick(self)
	self:Disable()
	RM.db.PosX = nil
	RM.db.PosY = nil
	Ambrosia.db.RaidMarkerSettings.PosX = nil
	Ambrosia.db.RaidMarkerSettings.PosY = nil
	RM:LoadPosition(RM)
end

local function Options_Slider_FormatWholeValue(value)
	return format("%d", value)
end

local function Options_InverseMode()
	Ambrosia.db.RaidMarkerSettings.inverse = not Ambrosia.db.RaidMarkerSettings.inverse
	RM.db.inverse = not RM.db.inverse
	RM:UpdateButtons()
	RM:UpdateBar()
end

local function Options_Tooltip()
	Ambrosia.db.RaidMarkerSettings.tooltip = not Ambrosia.db.RaidMarkerSettings.tooltip
	RM.db.tooltip = not RM.db.tooltip
end

local function Options_Mouseover()
	Ambrosia.db.RaidMarkerSettings.mouseOver = not Ambrosia.db.RaidMarkerSettings.mouseOver
	RM.db.mouseOver = not RM.db.mouseOver
	RM:ToggleSettings()
end

local function Options_BarOrientation(value)
	Ambrosia.db.RaidMarkerSettings.orientation = value
	RM.db.orientation = value
	RM:UpdateBar()
end

local function Options_BarOrientation_FormatValue(value)
	return value == 1 and "Horizontal" or "Vertical"
end

local function Options_BarBackdrop()
	Ambrosia.db.RaidMarkerSettings.backdrop = not Ambrosia.db.RaidMarkerSettings.backdrop
	RM.db.backdrop = not RM.db.backdrop
	RM:UpdateBar()
end

local function Options_BarBackdropSpacing(value)
	Ambrosia.db.RaidMarkerSettings.backdropSpacing = value
	RM.db.backdropSpacing = value
	RM:UpdateBar()
end

local function Options_ButtonBackdrop()
	Ambrosia.db.RaidMarkerSettings.buttonBackdrop = not Ambrosia.db.RaidMarkerSettings.buttonBackdrop
	RM.db.buttonBackdrop = not RM.db.buttonBackdrop
	RM:UpdateButtons()
end

local function Options_ButtonSize(value)
	Ambrosia.db.RaidMarkerSettings.buttonSize = value
	RM.db.buttonSize = value
	RM:UpdateButtons()
	RM:UpdateBar()
end

local function Options_ButtonSpacing(value)
	Ambrosia.db.RaidMarkerSettings.buttonSpacing = value
	RM.db.buttonSpacing = value
	RM:UpdateButtons()
	RM:UpdateBar()
end

local function Options_ReadyCheck()
	Ambrosia.db.RaidMarkerSettings.readyCheck = not Ambrosia.db.RaidMarkerSettings.readyCheck
	RM.db.readyCheck = not RM.db.readyCheck
	RM:UpdateButtons()
	RM:UpdateBar()
end

local function Options_Countdown()
	Ambrosia.db.RaidMarkerSettings.countDown = not Ambrosia.db.RaidMarkerSettings.countDown
	RM.db.countDown = not RM.db.countDown
	RM:UpdateButtons()
	RM:UpdateBar()
end

local function Options_CountdownTime(value)
	Ambrosia.db.RaidMarkerSettings.countDownTime = value
	RM.db.countDownTime = value
	RM:UpdateCountDownButton()
end

function RM:UpdateCountDownButton()
	if not (self.db and self.bar and self.bar.buttons and self.bar.buttons[11]) then
		return
	end

	local button = self.bar.buttons[11]
	if C_AddOns_IsAddOnLoaded("BigWigs") then
		button:SetAttribute("macrotext1", "/pull " .. self.db.countDownTime)
		button:SetAttribute("macrotext2", "/pull 0")
	elseif C_AddOns_IsAddOnLoaded("DBM-Core") then
		button:SetAttribute("macrotext1", "/dbm pull " .. self.db.countDownTime)
		button:SetAttribute("macrotext2", "/dbm pull 0")
	else
		button:SetAttribute("macrotext1", _G.SLASH_COUNTDOWN1 .. " " .. self.db.countDownTime)
		button:SetAttribute("macrotext2", _G.SLASH_COUNTDOWN1 .. " " .. -1)
	end
end

function RM:ToggleSettings()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:SetScript("OnEvent", RM:ToggleSettings())

		return
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if self.bar and not self.db.enable then
		UnregisterStateDriver(self, "visibility")
		self:Hide()
		--PrintDebug("UnregisterStateDriver")
		return
	end

	self:UpdateButtons()
	self:UpdateBar()

	if self.bar and self.db and self.db.visibility then
		--PrintDebug("Registering State Driver")
		RegisterStateDriver(
			self,
			"visibility",
			self.db.visibility == "DEFAULT" and "[noexists, nogroup] hide; show"
				or self.db.visibility == "ALWAYS" and "[petbattle] hide; show"
				or "[group] show; [petbattle] hide; hide"
		)
	end

	if self.db.mouseOver then
		self.bar:SetScript("OnEnter", function(self)
			self:SetAlpha(1)
		end)

		self.bar:SetScript("OnLeave", function(self)
			self:SetAlpha(0)
		end)

		self.bar:SetAlpha(0)
	else
		self.bar:SetScript("OnEnter", nil)
		self.bar:SetScript("OnLeave", nil)
		self.bar:SetAlpha(1)
	end
end

function RM:OnDragStart()
	self:SetMovable(true)
	self:SetDontSavePosition(true)
	self:SetClampedToScreen(true)
	self:StartMoving()
end

function RM:OnDragStop()
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
		Ambrosia.db.RaidMarkerSettings.PosX = -1
		self.db.PosX = -1
	else
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		Ambrosia.db.RaidMarkerSettings.PosX = left
		self.db.PosX = left
	end
	Ambrosia.db.RaidMarkerSettings.PosY = top
	self.db.PosY = top

	if self.OptionFrame and self.OptionFrame:IsOwner(self) then
		local button = self.OptionFrame:FindWidget("ResetButton")
		if button then
			button:Enable()
		end
	end
end

function RM:Enable()
	self.db.enable = true
	if self.enabled then
		return
	end
	if self.db.enable and not self.bar then
		--PrintDebug("Creating RM Bar")
		self:CreateBar()
	elseif self.db.enable and self.bar then
		self:ToggleSettings()
	end

	self.modifierString = self.db.modifier:gsub("^%l", strupper)

	self.enabled = true
	--PrintDebug("Raid Markers Enabled")
end

function RM:Disable()
	if self.enabled then
		self.db.enable = false
		self:ToggleSettings()
	end
	self.enabled = false
	--PrintDebug("Raid Markers Disabled")
end

local OPTIONS_SCHEMATIC = {
	title = "Raid Markers Options",
	widgets = {
		{
			type = "Checkbox",
			label = "Inverse",
			onClickFunc = Options_InverseMode,
			dbKey = "RaidMarkerSettings.inverse",
			tooltip = "Swap the functionality of normal click and click with modifier keys.",
		},
		{
			type = "Checkbox",
			label = "Tooltip",
			onClickFunc = Options_Tooltip,
			dbKey = "RaidMarkerSettings.tooltip",
			tooltip = "Show the tooltip when hovering over the buttons.",
		},
		{
			type = "Checkbox",
			label = "Mouseover",
			onClickFunc = Options_Mouseover,
			dbKey = "RaidMarkerSettings.mouseOver",
			tooltip = "Show the bar only when hovering over it.",
		},
		{
			type = "Slider",
			label = "Bar Orientation",
			minValue = 1,
			maxValue = 2,
			valueStep = 1,
			onValueChangedFunc = Options_BarOrientation,
			formatValueFunc = Options_BarOrientation_FormatValue,
			dbKey = "RaidMarkerSettings.orientation",
		},
		{ type = "Divider" },
		{ type = "Header", label = "Visibility" },
		{
			type = "Checkbox",
			label = "Bar Backdrop",
			onClickFunc = Options_BarBackdrop,
			dbKey = "RaidMarkerSettings.backdrop",
			tooltip = "Show a backdrop for the bar",
		},
		{
			type = "Slider",
			label = "Backdrop Spacing",
			tooltip = "Spacing between the backdrop and the buttons.",
			minValue = 1,
			maxValue = 30,
			valueStep = 1,
			onValueChangedFunc = Options_BarBackdropSpacing,
			formatValueFunc = Options_Slider_FormatWholeValue,
			dbKey = "RaidMarkerSettings.backdropSpacing",
		},
		{ type = "Divider" },
		{ type = "Header", label = "Buttons" },
		{
			type = "Checkbox",
			label = "Button Backdrop",
			onClickFunc = Options_ButtonBackdrop,
			dbKey = "RaidMarkerSettings.buttonBackdrop",
			tooltip = "Show a backdrop for each individual button.",
		},
		{
			type = "Slider",
			label = "Button Size",
			tooltip = "Size of the buttons.",
			minValue = 15,
			maxValue = 60,
			valueStep = 1,
			onValueChangedFunc = Options_ButtonSize,
			formatValueFunc = Options_Slider_FormatWholeValue,
			dbKey = "RaidMarkerSettings.buttonSize",
		},
		{
			type = "Slider",
			label = "Button Spacing",
			tooltip = "Spacing between the buttons.",
			minValue = 1,
			maxValue = 30,
			valueStep = 1,
			onValueChangedFunc = Options_ButtonSpacing,
			formatValueFunc = Options_Slider_FormatWholeValue,
			dbKey = "RaidMarkerSettings.buttonSpacing",
		},
		{ type = "Divider" },
		{ type = "Header", label = "Ready Check / Countdown" },
		{
			type = "Checkbox",
			label = "Ready Check / Advance Combat Logging",
			onClickFunc = Options_ReadyCheck,
			dbKey = "RaidMarkerSettings.readyCheck",
			tooltip = "Left Click to ready check.\nRight click to toggle advanced combat logging.",
		},
		{
			type = "Checkbox",
			label = "Countdown",
			onClickFunc = Options_Countdown,
			dbKey = "RaidMarkerSettings.countDown",
			tooltip = "Trigger a Countdown",
		},
		{
			type = "Slider",
			label = "Countdown Time",
			tooltip = "Countdown time in seconds.",
			minValue = 1,
			maxValue = 30,
			valueStep = 1,
			onValueChangedFunc = Options_CountdownTime,
			formatValueFunc = Options_Slider_FormatWholeValue,
			dbKey = "RaidMarkerSettings.countDownTime",
		},
		-- {
		-- 	type = "Checkbox",
		-- 	label = L["LootUI Option Owned Count"],
		-- 	onClickFunc = nil,
		-- 	dbKey = "LootUI_ShowItemCount",
		-- },
		-- {
		-- 	type = "Checkbox",
		-- 	label = L["LootUI Option New Transmog"],
		-- 	onClickFunc = nil,
		-- 	dbKey = "LootUI_NewTransmogIcon",
		-- 	tooltip = L["LootUI Option New Transmog Tooltip"]:format(
		-- 		"|TInterface/AddOns/Plumber/Art/LootUI/NewTransmogIcon:0:0|t"
		-- 	),
		-- 	validityCheckFunc = Validation_TransmogInvented,
		-- },

		-- { type = "Divider" },
		-- {
		-- 	type = "Checkbox",
		-- 	label = L["LootUI Option Force Auto Loot"],
		-- 	onClickFunc = Options_ForceAutoLoot_OnClick,
		-- 	validityCheckFunc = Options_ForceAutoLoot_ValidityCheck,
		-- 	dbKey = "LootUI_ForceAutoLoot",
		-- 	tooltip = L["LootUI Option Force Auto Loot Tooltip"],
		-- 	tooltip2 = Tooltip_ManualLootInstruction,
		-- },
		-- {
		-- 	type = "Checkbox",
		-- 	label = L["LootUI Option Loot Under Mouse"],
		-- 	onClickFunc = nil,
		-- 	dbKey = "LootUI_LootUnderMouse",
		-- 	tooltip = L["LootUI Option Loot Under Mouse Tooltip"],
		-- },
		-- {
		-- 	type = "Checkbox",
		-- 	label = L["LootUI Option Replace Default"],
		-- 	onClickFunc = nil,
		-- 	dbKey = "LootUI_ReplaceDefaultAlert",
		-- 	tooltip = L["LootUI Option Replace Default Tooltip"],
		-- 	validityCheckFunc = Validation_IsRetail,
		-- },
		-- {
		-- 	type = "Checkbox",
		-- 	label = L["LootUI Option Use Hotkey"],
		-- 	onClickFunc = Options_UseHotkey_OnClick,
		-- 	dbKey = "LootUI_UseHotkey",
		-- 	tooltip = L["LootUI Option Use Hotkey Tooltip"],
		-- },
		-- {
		-- 	type = "Keybind",
		-- 	label = L["Take All"],
		-- 	dbKey = "LootUI_HotkeyName",
		-- 	tooltip = L["LootUI Option Use Hotkey Tooltip"],
		-- 	defaultKey = "E",
		-- },

		-- { type = "Divider" },
		-- {
		-- 	type = "Checkbox",
		-- 	label = L["LootUI Option Use Default UI"],
		-- 	onClickFunc = nil,
		-- 	dbKey = "LootUI_UseStockUI",
		-- 	tooltip = L["LootUI Option Use Default UI Tooltip"],
		-- 	tooltip2 = Tooltip_ManualLootInstruction,
		-- },

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

function RM:ShowOptions(state)
	if state then
		local forceUpdate = true
		self.OptionFrame = Ambrosia.SetupSettingsDialog(self, OPTIONS_SCHEMATIC, forceUpdate)
		self.OptionFrame:Show()
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

		-- if not API.IsInEditMode() then
		-- 	RM:SettingsDriversUpdate()
		-- end
	end
end

do
	local function EnableModule(state)
		if not RM.db then
			RM.db = Ambrosia.db.RaidMarkerSettings
		end
		if state then
			RM:Enable()
		else
			RM:Disable()
		end
	end

	local function OptionToggle_OnClick(self, button)
		if
			RM.OptionFrame
			and RM.OptionFrame:IsShown()
			and (RM.OptionFrame:IsOwner(self) or RM.OptionFrame:IsOwner(RM))
		then
			RM:ShowOptions(false)
			RM:ExitEditMode()
		else
			RM:ShowOptions(true)
			RM:EnterEditMode()
		end
	end

	local moduleData = {
		name = "Raid Markers Bar",
		dbKey = "RaidMarkers",
		description = "Raid Markers Bar for ease of access.\nProvides all target and world markers in addition to Ready Check and Pull Timer.\n\nUse /amb rm for quick settings.",
		toggleFunc = EnableModule,
		categoryID = 2,
		uiOrder = 1,
		optionToggleFunc = OptionToggle_OnClick,
	}

	Ambrosia.Config:AddModule(moduleData)
end
