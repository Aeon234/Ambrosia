local _, Ambrosia = ...

local EscapeMenuScale = CreateFrame("Frame")

local function EscapeMenuRescaler(value)
	GameMenuFrame:SetScale(value or Ambrosia.db.EscapeMenuScaleNum or 1.0)
	GameMenuFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end

local function Options_EscapeMenuScaleNum(value)
	Ambrosia.db.EscapeMenuScaleNum = value
	EscapeMenuRescaler(value)
end

local function Options_Slider_EscapeMenuScaleNum(value)
	return format("%.0f%%", value * 100)
end

local OPTIONS_SCHEMATIC = {
	title = "UI Rescaler Options",
	widgets = {
		{
			type = "Slider",
			label = "Font Size",
			tooltip = "Align the text to the top left or top right of the frame.",
			minValue = 0.5,
			maxValue = 1.5,
			valueStep = 0.1,
			onValueChangedFunc = Options_EscapeMenuScaleNum,
			formatValueFunc = Options_Slider_EscapeMenuScaleNum,
			dbKey = "EscapeMenuScaleNum",
		},
	},
}

function EscapeMenuScale:ShowOptions(state)
	if state then
		local forceUpdate = true
		self.OptionFrame = Ambrosia.SetupSettingsDialog(self, OPTIONS_SCHEMATIC, forceUpdate)
		self.OptionFrame:Show()
		self.OptionFrame:SetPoint("CENTER", UIParent, "CENTER", 500, -100)
	else
		if self.OptionFrame then
			self.OptionFrame:HideOption(self)
		end
	end
end

do
	local function EnableModule(state)
		if state then
			EscapeMenuRescaler(Ambrosia.db.EscapeMenuScaleNum)
		else
			EscapeMenuRescaler(1.0)
		end
	end

	local function OptionToggle_OnClick(self, button)
		if
			EscapeMenuScale.OptionFrame
			and EscapeMenuScale.OptionFrame:IsShown()
			and (EscapeMenuScale.OptionFrame:IsOwner(self) or EscapeMenuScale.OptionFrame:IsOwner(EscapeMenuScale))
		then
			EscapeMenuScale:ShowOptions(false)
		else
			EscapeMenuScale:ShowOptions(true)
		end
	end

	local moduleDate = {
		name = "Escape Menu Resizer",
		dbKey = "EscapeMenuScale",
		description = "Resizes the Escape Menu for better visual clarity.",
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 2,
		optionToggleFunc = OptionToggle_OnClick,
	}
	Ambrosia.Config:AddModule(moduleDate)
end
