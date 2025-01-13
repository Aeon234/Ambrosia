local _, Ambrosia = ...

local PrintDebug = function(...)
	Ambrosia:PrintDebug(...)
end

local UI_RescalerEvent = CreateFrame("Frame")

local function UI_Rescaler(self, event, isLogin, isReload)
	if ElvUI then
		UI_RescalerEvent:Disable()
		return
	end
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		PrintDebug("Currently in combat. Waiting until Health Regen is enabled.")
	elseif isLogin or isReload or event == "PLAYER_REGEN_ENABLED" or event == "MANUAL_TOGGLE" then
		PrintDebug("Updating UI Scale")
		local width, height = GetPhysicalScreenSize()
		local ResScale = 0
		if height > 0 then
			ResScale = 768 / height
		end
		if ResScale > 0 then
			UIParent:SetScale(ResScale)
		end
		if ShadowUF then
			PrintDebug("Reloading ShadowedUnitFrame Layout")
			ShadowUF.Layout:Reload()
			if Grid2 then
				PrintDebug("Reloading Grid2 Layout")
				Grid2Layout:RestorePositions()
			end
		end
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		PrintDebug("Unregistering UI Scale Events")
	else
		return
	end
end

function UI_RescalerEvent:Enable()
	if self.enabled then
		return
	end
	UI_RescalerEvent:RegisterEvent("PLAYER_ENTERING_WORLD")
	UI_RescalerEvent:SetScript("OnEvent", UI_Rescaler)
	UI_Rescaler(UI_RescalerEvent, "MANUAL_TOGGLE", _, _)

	self.enabled = true
	PrintDebug("Enabled Rescaler")
end

function UI_RescalerEvent:Disable()
	if self.enabled then
		UI_RescalerEvent:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
	self.enabled = false
	PrintDebug("Disabled Rescaler")
end

function UI_RescalerEvent:ReloadPopUp()
	if not StaticPopupDialogs["AMBROSIA_RELOAD"] then
		StaticPopupDialogs["AMBROSIA_RELOAD"] = {
			text = "To finalize changes it's recommended that you reload the UI.\n\nWould you like to reload the UI right now?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
				C_UI.Reload()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
	end
	StaticPopup_Show("AMBROSIA_RELOAD")
end

do
	local function EnableModule(state)
		if ElvUI then
			UI_RescalerEvent.enabled = false
			PrintDebug("Detected ElvUI, Disabling Rescaler")
			return
		end
		if state then
			UI_RescalerEvent:Enable()
		else
			UI_RescalerEvent:Disable()
		end
		if SettingsPanel and SettingsPanel:IsShown() then
			UI_RescalerEvent:ReloadPopUp()
		end
	end

	local function OptionToggle_OnClick(self, button) end

	local moduleData = {
		name = (ElvUI and "|cffb0b0b0Pixel Perfect UI Scale|r" or "Pixel Perfect UI Scale"),
		dbKey = "UIScale",
		description = (
			ElvUI
				and "|cffff2020Automatically disabled since ElvUI is enabled. ElvUI provides its own Scaling Features.|r\n\nAutomatically adjust the UI Scale so it's pixel perfect to your resolution. Will also refresh the layouts of Shadowed Unit Frames and Grid2 if enabled."
			or "Automatically adjust the UI Scale so it's pixel perfect to your resolution. Will also refresh the layouts of Shadowed Unit Frames and Grid2 if enabled.\n\nAutomatically disabled if ElvUI is enabled."
		),
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 1,
		-- optionToggleFunc = OptionToggle_OnClick,
	}

	Ambrosia.Config:AddModule(moduleData)
end
