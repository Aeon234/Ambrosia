local _, Ambrosia = ...

local PrintDebug = function(...)
	Ambrosia:PrintDebug(...)
end

local UIScale = CreateFrame("Frame")
local ElvUI = ElvUI
local ShadowUF = ShadowUF
local Grid2 = Grid2
local Grid2Layout = Grid2Layout
local CurrentScale = 0
local REGISTERED_EVENTS = {
	PLAYER_ENTERING_WORLD = true,
	UI_SCALE_CHANGED = true,
	DISPLAY_SIZE_CHANGED = true,
	EDIT_MODE_LAYOUTS_UPDATED = true,
	PLAYER_REGEN_ENABLED = true,
}

local function LogonRescaler(self, event, isLogin, isReload, ...)
	if ElvUI then
		UIScale:Disable()
		return
	end
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	elseif isLogin or isReload or event == "SET_SCALE" or REGISTERED_EVENTS[event] then
		CurrentScale = Ambrosia.db.UIScaleNum
		if CurrentScale > 0 then
			UIParent:SetScale(CurrentScale)
			self.uiScaleCurrent = CurrentScale
		end
		if ShadowUF then
			ShadowUF.Layout:Reload()
			if Grid2 then
				Grid2Layout:RestorePositions()
			end
		end
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	else
		return
	end
	if UIScale.OptionFrame then
		local header = UIScale.OptionFrame:FindWidget("CurrentScaleHeader")
		if header then
			header:SetText(
				"Current UI Scale: " .. tostring(UIScale.uiScaleCurrent or CurrentScale or Ambrosia.db.UIScaleNum)
			)
		end
	end
end

local function UIScaleRescaler(targetHeight)
	return function(self)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			return
		end

		local width, height = GetPhysicalScreenSize()
		local scale

		if targetHeight and type(targetHeight) == "number" then
			scale = 768 / targetHeight
		else
			if height and height > 0 then
				scale = 768 / height
			end
		end

		if scale and scale > 0 then
			CurrentScale = scale
			UIParent:SetScale(scale)
			UIScale.uiScaleCurrent = scale

			if ShadowUF then
				ShadowUF.Layout:Reload()
				if Grid2 then
					Grid2Layout:RestorePositions()
				end
			end

			Ambrosia.db.UIScaleNum = scale

			if UIScale.OptionFrame then
				local header = UIScale.OptionFrame:FindWidget("CurrentScaleHeader")
				if header then
					header:SetText("Current UI Scale: " .. tostring(scale))
				end
			end
		end
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		Ambrosia:ReloadPopUp()
	end
end

function UIScale:Enable()
	if self.enabled and ElvUI then
		self.enabled = false
		return
	elseif self.enabled then
		return
	end

	LogonRescaler(UIScale, "SET_SCALE", _, _)

	self.enabled = true
end

function UIScale:Disable()
	if self.enabled then
		UIScale:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
	self.enabled = false
end

local OPTIONS_SCHEMATIC = {
	title = "UI Rescaler Options",
	widgets = {
		{
			type = "Header",
			label = "Current UI Scale: " .. CurrentScale,
			widgetKey = "CurrentScaleHeader",
		},
		{
			type = "UIPanelButton",
			label = "Pixel Perfect Scaling",
			tooltip = "Sets the UI Scale to the pixel perfect value for your current resolution.",
			buttonText = "Set Pixel Perfect",
			onClickFunc = UIScaleRescaler(nil),
			widgetKey = "PPScaleButton",
		},
		{
			type = "UIPanelButton",
			label = "1080p Scaling",
			tooltip = "Sets the UI Scale to the pixel perfect value for 1080p resolution.",
			buttonText = "Set Pixel Perfect",
			onClickFunc = UIScaleRescaler(1080),
			widgetKey = "PPScaleButton_1080",
		},
		{
			type = "UIPanelButton",
			label = "1440p Scaling",
			tooltip = "Sets the UI Scale to the pixel perfect value for 1440p resolution.",
			buttonText = "Set Pixel Perfect",
			onClickFunc = UIScaleRescaler(1440),
			widgetKey = "PPScaleButton_1440",
		},
		{
			type = "UIPanelButton",
			label = "4K Scaling",
			tooltip = "Sets the UI Scale to the pixel perfect value for 4K resolution.",
			buttonText = "Set Pixel Perfect",
			onClickFunc = UIScaleRescaler(2160),
			widgetKey = "PPScaleButton_4k",
		},
	},
}

function UIScale:ShowOptions(state)
	if state then
		local forceUpdate = true
		if OPTIONS_SCHEMATIC and OPTIONS_SCHEMATIC.widgets and OPTIONS_SCHEMATIC.widgets[1] then
			OPTIONS_SCHEMATIC.widgets[1].label = "Current UI Scale: "
				.. tostring(UIScale.uiScaleCurrent or CurrentScale or Ambrosia.db.UIScaleNum)
		end
		self.OptionFrame = Ambrosia.SetupSettingsDialog(self, OPTIONS_SCHEMATIC, forceUpdate)
		self.OptionFrame:Show()
		self.OptionFrame:SetPoint("CENTER", UIParent, "CENTER", 500, 100)
	else
		if self.OptionFrame then
			self.OptionFrame:HideOption(self)
		end
	end
end

do
	local function EnableModule(state)
		if ElvUI then
			UIScale.enabled = false
			return
		end
		if state then
			for event, enabled in pairs(REGISTERED_EVENTS) do
				if enabled then
					UIScale:RegisterEvent(event)
				end
			end
			UIScale:SetScript("OnEvent", LogonRescaler)
			LogonRescaler(UIScale, "SET_SCALE", _, _)
		else
			UIScale:Disable()
		end
		if SettingsPanel and SettingsPanel:IsShown() then
			Ambrosia:ReloadPopUp()
		end
	end

	local function OptionToggle_OnClick(self, button)
		if
			UIScale.OptionFrame
			and UIScale.OptionFrame:IsShown()
			and (UIScale.OptionFrame:IsOwner(self) or UIScale.OptionFrame:IsOwner(UIScale))
		then
			UIScale:ShowOptions(false)
		else
			UIScale:ShowOptions(true)
		end
	end

	local moduleData = {
		name = (ElvUI and "|cffb0b0b0UI Scale Modification|r" or "UI Scale Modification"),
		dbKey = "UIScale",
		description = (
			ElvUI
				and "|cffff2020Automatically disabled since ElvUI is enabled. ElvUI provides its own Scaling Features.|r\n\nAutomatically adjust the UI Scale so it's pixel perfect to your resolution. Will also refresh the layouts of Shadowed Unit Frames and Grid2 if enabled."
			or "Automatically adjust the UI Scale so it's pixel perfect to your resolution. Will also refresh the layouts of Shadowed Unit Frames and Grid2 if enabled.\nType '/amb suf' to reload SUF Layout.\n\nAutomatically disabled if ElvUI is enabled."
		),
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 1,
		optionToggleFunc = OptionToggle_OnClick,
	}

	Ambrosia.Config:AddModule(moduleData)
end

function Ambrosia:SUFreload()
	if ShadowUF then
		ShadowUF.Layout:Reload()
		if Grid2 then
			Grid2Layout:RestorePositions()
		end
		PrintDebug("SUF Reloaded")
	end
end
