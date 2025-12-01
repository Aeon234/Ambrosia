local _, Ambrosia = ...

local CantRelease = CreateFrame("Frame")
local releaseText = _G["DEATH_RELEASE"] or "Release Spirit"
local crTrigger = 0

local REGISTERED_EVENTS = {
	PLAYER_DEAD = true,
	PLAYER_UNGHOST = true,
	PLAYER_ALIVE = true,
	PLAYER_ENTERING_WORLD = true,
}

StaticPopupDialogs["AMBROSIA_WANT_TO_RELEASE"] = {
	text = "Do you want to release your spirit?",
	button1 = YES,
	OnAccept = function()
		crTrigger = 1
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
	preferredIndex = 3,
}

local function CantReleaseSetup()
	CantRelease:SetScript("OnEvent", function(_, e, ...)
		if e == "PLAYER_DEAD" and UnitIsDeadOrGhost("player") and StaticPopup1Button1:GetText() == releaseText then
			crTrigger = 0
			StaticPopup_Show("AMBROSIA_WANT_TO_RELEASE")
		elseif e == "PLAYER_UNGHOST" or e == "PLAYER_ALIVE" then
			StaticPopup_Hide("AMBROSIA_WANT_TO_RELEASE")
		end
	end)

	CantRelease:SetScript("OnUpdate", function()
		if StaticPopup1:IsShown() then
			local btn = StaticPopup1Button1
			if btn and btn:GetText() == releaseText and btn:GetButtonState() == "NORMAL" then
				if crTrigger == 0 then
					btn:Disable()
				else
					btn:Enable()
				end
			end
		end
	end)
end

do
	local function EnableModule(state)
		if state then
			for event, enabled in pairs(REGISTERED_EVENTS) do
				if enabled then
					CantRelease:RegisterEvent(event)
				end
			end
			CantReleaseSetup()
		else
			CantRelease:UnregisterAllEvents()
			CantRelease:SetScript("OnEvent", nil)
			CantRelease:SetScript("OnUpdate", nil)
		end
	end

	local moduleDate = {
		name = "Can't Release Button",
		dbKey = "CantRelease",
		description = "Create an additonal button you must press before you can press the Release button when dead.",
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 3,
	}
	Ambrosia.Config:AddModule(moduleDate)
end
