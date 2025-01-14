local _, Ambrosia = ...

local PrintDebug = function(...)
	Ambrosia:PrintDebug(...)
end

local _G = _G
local ceil = ceil
local floor = floor
local min = min
local pairs = pairs
local print = print
local sort = sort
local strfind = strfind
local strlen = strlen
local strsub = strsub
local tinsert = tinsert
local tremove = tremove
local type = type
local unpack = unpack

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture

local IgnoreList = {
	full = {
		"AsphyxiaUIMinimapHelpButton",
		"AsphyxiaUIMinimapVersionButton",
		"ElvConfigToggle",
		"ElvUIConfigToggle",
		"ElvUI_ConsolidatedBuffs",
		"HelpOpenTicketButton",
		"ElvUI_MinimapHolder",
		"DroodFocusMinimapButton",
		"TimeManagerClockButton",
		"MinimapZoneTextButton",
	},
	libDBIcon = {},
	startWith = {
		"Archy",
		"GatherMatePin",
		"GatherNote",
		"GuildInstance",
		"HandyNotesPin",
		"MinimMap",
		"Spy_MapNoteList_mini",
		"ZGVMarker",
		"poiMinimap",
		"GuildMap3Mini",
		"LibRockConfig-1.0_MinimapButton",
		"NauticusMiniIcon",
		"WestPointer",
		"Cork",
		"DugisArrowMinimapPoint",
		"TTMinimapButton",
		"QueueStatusButton",
	},
	partial = {
		"Node",
		"Note",
		"Pin",
		"POI",
	},
}

local TexCoordIgnoreList = {
	["Narci_MinimapButton"] = true,
	["ZygorGuidesViewerMapIcon"] = true,
}

local whiteList = {}

local acceptedFrames = {
	"BagSync_MinimapButton",
}

local moveButtons = {}

local MB = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")

function MB:OnButtonSetShown(button, shown)
	local btnName = button:GetName()

	for i, moveButtonName in pairs(moveButtons) do
		if btnName == moveButtonName then
			if shown then
				return -- already in the list
			end
			tremove(moveButtons, i)
			break
		end
	end

	if shown then
		tinsert(moveButtons, btnName)
	end

	self:UpdateLayout()
end

function MB:HandleLibDBIconButton(button, name)
	if not strsub(name, 1, strlen("LibDBIcon")) == "LibDBIcon" then
		return true
	end

	if not button.Show or not button.Hide or not button.IsShown then
		return true
	end

	self:SecureHook(button, "Hide", function()
		self:OnButtonSetShown(button, false)
	end)

	self:SecureHook(button, "Show", function()
		self:OnButtonSetShown(button, true)
	end)

	self:SecureHook(button, "SetShown", "OnButtonSetShown")

	return button:IsShown()
end

do
	local modified = false
	function MB:UpdateExpansionLandingPageMinimapIcon(icon)
		icon = icon or _G.ExpansionLandingPageMinimapButton

		if not icon then
			return
		end
		icon:SetIgnoreParentScale(true)
		icon:SetScale(E.uiscale)

		local box = _G.GarrisonLandingPageTutorialBox
		if box then
			box:SetScale(E.uiscale)
			box:SetClampedToScreen(true)
		end

		if not modified then
			icon.AlertText:Hide()
			icon.AlertText:SetAlpha(0)
			icon.AlertText.Show = E.noop
			icon.AlertText.Hide = E.noop

			icon.AlertBG:SetAlpha(0)
			icon.AlertBG:Hide()
			icon.AlertBG.Show = E.noop
			icon.AlertBG.Hide = E.noop

			icon.AlertText.SetText = function(_, text)
				if text then
					-- print(F.CreateColorString(icon.title or "Garrison", E.db.general.valuecolor) .. ": " .. text)
				end
			end

			modified = true
		end

		self:UpdateLayout()
	end
end

function MB:Enable()
	self.db.enable = true
	if self.enabled then
		return
	end
	-- if self.db.enable and not self.bar then
	-- 	PrintDebug("Creating RM Bar")
	-- 	self:CreateBar()
	-- elseif self.db.enable and self.bar then
	-- 	self:ToggleSettings()
	-- end

	self.enabled = true
	PrintDebug("Minimap Button Container Enabled")
end

function MB:Disable()
	if self.enabled then
		self.db.enable = false
		-- self:ToggleSettings()
	end
	self.enabled = false
	PrintDebug("Minimap Button Container Disabled")
end

do
	local function EnableModule(state)
		if not MB.db then
			MB.db = Ambrosia.db.RaidMarkerSettings
		end
		if state then
			MB:Enable()
		else
			MB:Disable()
		end
	end

	local function OptionToggle_OnClick(self, button)
		if
			MB.OptionFrame
			and MB.OptionFrame:IsShown()
			and (MB.OptionFrame:IsOwner(self) or MB.OptionFrame:IsOwner(MB))
		then
			MB:ShowOptions(false)
			MB:ExitEditMode()
		else
			MB:ShowOptions(true)
			MB:EnterEditMode()
		end
	end

	local moduleData = {
		name = "Minimap Buttons Bar",
		dbKey = "MinimapButtons",
		description = "Contain all addon minimap buttons in a separate bar.",
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 2,
		optionToggleFunc = OptionToggle_OnClick,
	}

	Ambrosia.Config:AddModule(moduleData)
end
