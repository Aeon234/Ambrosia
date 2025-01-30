-- -- Create a new addon
-- local _, addon = ...

-- -- -- Create a frame for the progress bar
-- -- local progressBarFrame = CreateFrame("Frame", "ReadyCheckProgressBar", UIParent)
-- -- progressBarFrame:SetSize(300, 30) -- Set the size of the bar
-- -- progressBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Position in the center
-- -- progressBarFrame:Hide() -- Initially hidden

-- -- -- Add a background texture
-- -- local background = progressBarFrame:CreateTexture(nil, "BACKGROUND")
-- -- background:SetAllPoints()
-- -- background:SetColorTexture(0, 0, 0, 0.7) -- Dark background

-- -- -- Add a status bar (progress bar)
-- -- local statusBar = CreateFrame("StatusBar", nil, progressBarFrame)
-- -- statusBar:SetSize(300, 30)
-- -- statusBar:SetPoint("CENTER")
-- -- statusBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
-- -- statusBar:SetStatusBarColor(0, 0.7, 0, 1) -- Green color
-- -- statusBar:SetMinMaxValues(0, 100)
-- -- statusBar:SetValue(0)

-- -- -- Add a label for the bar
-- -- local barText = progressBarFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
-- -- barText:SetPoint("CENTER")
-- -- barText:SetText("Ready Check")

-- -- Variables for timing
-- local readyCheckDuration = 35 -- Default duration of a ready check (in seconds)
-- local timeElapsed = 0

-- -- Update function for the progress bar
-- local function UpdateProgressBar(self, elapsed)
-- 	timeElapsed = timeElapsed + elapsed
-- 	local progress = math.max(0, readyCheckDuration - timeElapsed)
-- 	self:SetValue((progress / readyCheckDuration) * 100)

-- 	if progress <= 0 then
-- 		self:Hide()
-- 		self:SetScript("OnUpdate", nil)
-- 	end
-- end

-- -- Event handler frame
-- local eventFrame = CreateFrame("Frame")

-- -- Event handler function
-- -- local function OnEvent(self, event, ...)
-- -- 	if event == "READY_CHECK" then
-- -- 		timeElapsed = 0
-- -- 		statusBar:SetValue(100)
-- -- 		progressBarFrame:Show()
-- -- 		progressBarFrame:SetScript("OnUpdate", UpdateProgressBar)
-- -- 	elseif event == "READY_CHECK_FINISHED" then
-- -- 		progressBarFrame:Hide()
-- -- 		progressBarFrame:SetScript("OnUpdate", nil)
-- -- 	end
-- -- end

-- -- -- Register events
-- -- eventFrame:RegisterEvent("READY_CHECK")
-- -- eventFrame:RegisterEvent("READY_CHECK_FINISHED")
-- -- eventFrame:SetScript("OnEvent", OnEvent)

-- -- =========================================
-- -- =========================================
-- -- =========================================
-- -- =========================================
-- -- =========================================

-- local GroupKeysFrame = CreateFrame("Button", nil, UIParent)
-- GroupKeysFrame:SetSize(380, 250)
-- GroupKeysFrame:SetPoint("CENTER")

-- GroupKeysFrame:Hide()

-- -- Register Frame for clicks to hide the frame if needed
-- GroupKeysFrame:SetPropagateMouseClicks(true)
-- GroupKeysFrame:RegisterForClicks("RightButtonUp")
-- GroupKeysFrame:SetScript("OnClick", function(self, button, down)
-- 	self:Hide()
-- end)

-- local Initiated_Text = GroupKeysFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
-- Initiated_Text:SetPoint("TOP", GroupKeysFrame, "TOP", 0, -10)
-- Initiated_Text:SetText("Ready Check Initiated")
-- Initiated_Text:SetFont(addon.DefaultFont, 36)

-- -- local ProgressBar_Bg = CreateFrame("Frame", "ReadyCheckProgressBar2", GroupKeysFrame)
-- -- ProgressBar_Bg:SetSize(380, 16) -- Set the size of the bar
-- -- ProgressBar_Bg:SetPoint("TOP", Initiated_Text, "BOTTOM", 0, 4) -- Position in the center
-- -- ProgressBar_Bg:Hide() -- Initially hidden

-- -- -- Add a background texture
-- -- local background2 = ProgressBar_Bg:CreateTexture(nil, "BACKGROUND")
-- -- background2:SetAllPoints()
-- -- background2:SetColorTexture(0, 0, 0, 0.7) -- Dark background

-- local ProgressBar = CreateFrame("StatusBar", nil, GroupKeysFrame)
-- ProgressBar:SetPoint("TOP", Initiated_Text, "BOTTOM", 0, 4) -- Position in the center
-- -- ProgressBar:SetPoint("CENTER")
-- ProgressBar:SetSize(342, 12)
-- ProgressBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
-- ProgressBar:SetStatusBarColor(0, 0.7, 0, 1) -- Green color
-- ProgressBar:SetMinMaxValues(0, 100)
-- ProgressBar:SetValue(100)

-- --Create the label for Keystone's Dungeon Name Background
-- -- local Initiated_Text_Divider = CreateFrame("Frame", "AMT_Initiated_Text_Divider", GroupKeysFrame)
-- -- Initiated_Text_Divider:SetPoint("TOP", Initiated_Text, "BOTTOM", 0, 4)
-- -- Initiated_Text_Divider:SetSize(420, 19)
-- -- Initiated_Text_Divider.tex = Initiated_Text_Divider:CreateTexture(nil, "ARTWORK")
-- -- Initiated_Text_Divider.tex:SetAtlas("Adventure-MissionEnd-Line")
-- -- Initiated_Text_Divider.tex:SetSize(1, 1)
-- -- Initiated_Text_Divider.tex:SetAllPoints(Initiated_Text_Divider)

-- local GroupKeystones_Debug = {
-- 	{ playerRoleArt = "GM-icon-role-tank", player = " |c00C69B6DAeonwar|r", level = "32" },
-- 	{ playerRoleArt = "GM-icon-role-healer", player = " |c00F58CBAAeonheals|r", level = "17" },
-- 	{ playerRoleArt = "GM-icon-role-dps", player = " |c0069CCF0Kakmaddafaka|r", level = "14" },
-- 	{ playerRoleArt = "GM-icon-role-dps", player = " |c00C41F3BAeondeath|r", level = "7" },
-- 	{ playerRoleArt = "GM-icon-role-dps", player = " |c009482C9Aeonlock|r", level = "2" },
-- }

-- local PartyKeystones_NameFrame = {}
-- local PartyKeystones_KeyLevelFrame = {}

-- -- Create the Frames which will store the player name on the left and key level on the right
-- for i = 1, 5 do
-- 	PartyKeystones_NameFrame[i] = CreateFrame("Frame", nil, GroupKeysFrame)
-- 	PartyKeystones_NameFrame[i]:SetSize(Initiated_Text:GetUnboundedStringWidth() / 6 * 5, 36)

-- 	if i == 1 then
-- 		PartyKeystones_NameFrame[i]:SetPoint("TOPLEFT", GroupKeysFrame, "TOPLEFT", 10, -36 - 20)
-- 	else
-- 		PartyKeystones_NameFrame[i]:SetPoint("TOPLEFT", PartyKeystones_NameFrame[i - 1], "BOTTOMLEFT")
-- 	end

-- 	PartyKeystones_KeyLevelFrame[i] = CreateFrame("Frame", nil, GroupKeysFrame)
-- 	PartyKeystones_KeyLevelFrame[i]:SetSize(Initiated_Text:GetUnboundedStringWidth() / 6, 36)

-- 	if i == 1 then
-- 		PartyKeystones_KeyLevelFrame[i]:SetPoint("TOPRIGHT", GroupKeysFrame, "TOPRIGHT", -14, -36 - 20)
-- 	else
-- 		PartyKeystones_KeyLevelFrame[i]:SetPoint("TOPRIGHT", PartyKeystones_KeyLevelFrame[i - 1], "BOTTOMRIGHT")
-- 	end

-- 	local PlayerName = PartyKeystones_NameFrame[i]:CreateFontString(
-- 		"AMT_PartyKeystone_NameText" .. i,
-- 		"ARTWORK",
-- 		"GameFontNormalLarge"
-- 	)
-- 	PlayerName:SetPoint("LEFT", PartyKeystones_NameFrame[i], "LEFT")
-- 	PlayerName:SetText(CreateAtlasMarkup(GroupKeystones_Debug[i].playerRoleArt) .. GroupKeystones_Debug[i].player)
-- 	-- PlayerName:SetText("Temp Name")
-- 	PlayerName:SetFont(addon.DefaultFont, 28)

-- 	local KeyLevel = PartyKeystones_KeyLevelFrame[i]:CreateFontString(
-- 		"AMT_PartyKeystone_KeyLevelText" .. i,
-- 		"ARTWORK",
-- 		"GameFontNormalLarge"
-- 	)
-- 	KeyLevel:SetPoint("RIGHT", PartyKeystones_KeyLevelFrame[i], "RIGHT")
-- 	KeyLevel:SetText("+" .. GroupKeystones_Debug[i].level)
-- 	KeyLevel:SetFont(addon.DefaultFont, 28)
-- end

-- function GroupKeysFrame:ShowExampleText()
-- 	for i = 1, 5 do
-- 		local PlayerName = _G["AMT_PartyKeystone_NameText" .. i]
-- 		PlayerName:SetText(CreateAtlasMarkup(GroupKeystones_Debug[i].playerRoleArt) .. GroupKeystones_Debug[i].player)

-- 		local KeyLevel = _G["AMT_PartyKeystone_KeyLevelText" .. i]
-- 		KeyLevel:SetText("+" .. GroupKeystones_Debug[i].level)
-- 	end
-- 	GroupKeysFrame:Show()
-- end

-- local function OnEvent(self, event, ...)
-- 	if event == "READY_CHECK" then
-- 		print(Initiated_Text:GetWidth())
-- 		timeElapsed = 0
-- 		ProgressBar:SetValue(100)
-- 		GroupKeysFrame:ShowExampleText()
-- 		ProgressBar:Show()
-- 		ProgressBar:SetScript("OnUpdate", UpdateProgressBar)
-- 	elseif event == "READY_CHECK_FINISHED" then
-- 		GroupKeysFrame:Hide()
-- 		ProgressBar:Hide()
-- 		ProgressBar:SetScript("OnUpdate", nil)
-- 	end
-- end

-- -- Register events
-- eventFrame:RegisterEvent("READY_CHECK")
-- eventFrame:RegisterEvent("READY_CHECK_FINISHED")
-- eventFrame:SetScript("OnEvent", OnEvent)

-- Create a new addon
local addonName, addonTable = ...
-- Variables for timing
local readyCheckDuration = 35 -- Default duration of a ready check (in seconds)
local timeElapsed = 0

-- Create a frame for the progress bar
local progressBarFrame = CreateFrame("Frame", "ReadyCheckProgressBar", UIParent)
progressBarFrame:SetSize(300, 30) -- Set the size of the bar
progressBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Position in the center
progressBarFrame:Hide() -- Initially hidden

-- Add a background texture
local background = progressBarFrame:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints()
background:SetColorTexture(0, 0, 0, 0.7) -- Dark background

-- Add a gradient status bar (progress bar)
local statusBar = CreateFrame("StatusBar", nil, progressBarFrame)
statusBar:SetSize(300, 30)
statusBar:SetPoint("CENTER")
statusBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
statusBar:SetMinMaxValues(0, readyCheckDuration)
statusBar:SetValue(0)

-- Add a gradient texture for the status bar
local gradient = statusBar:CreateTexture(nil, "OVERLAY")
gradient:SetTexture("Interface/Buttons/WHITE8x8") -- Replace with your gradient texture path if using a custom one
gradient:SetAllPoints()
statusBar:SetStatusBarTexture(gradient)
gradient:SetGradient("HORIZONTAL", CreateColor(1, 0.71, 0.19, 1), CreateColor(1, 0.68, 0.22, 1)) -- Gradient from #FFB531 to #FFAE39

-- Add a label for the bar
local barText = progressBarFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
barText:SetPoint("CENTER")
barText:SetText("Ready Check")

-- Smooth progress function
local function SmoothProgress(currentValue, targetValue, deltaTime, speed)
	local diff = targetValue - currentValue
	if math.abs(diff) < 0.01 then
		return targetValue
	else
		return currentValue + diff * math.min(deltaTime * speed, 1)
	end
end

-- Update function for the progress bar
local function UpdateProgressBar(self, elapsed)
	timeElapsed = timeElapsed + elapsed
	local progress = math.max(0, readyCheckDuration - timeElapsed)
	statusBar:SetValue((progress / readyCheckDuration) * 100)

	if progress <= 0 then
		self:Hide()
		self:SetScript("OnUpdate", nil)
	end
end

-- Event handler frame
local eventFrame = CreateFrame("Frame")

-- Event handler function
local function OnEvent(self, event, ...)
	if event == "READY_CHECK" then
		timeElapsed = 0
		statusBar:SetValue(readyCheckDuration)
		progressBarFrame:Show()
		progressBarFrame:SetScript("OnUpdate", UpdateProgressBar)
	elseif event == "READY_CHECK_FINISHED" then
		progressBarFrame:Hide()
		progressBarFrame:SetScript("OnUpdate", nil)
	end
end

-- Register events
eventFrame:RegisterEvent("READY_CHECK")
eventFrame:RegisterEvent("READY_CHECK_FINISHED")
eventFrame:SetScript("OnEvent", OnEvent)

-- 386x16
-- Interface\CastingBar\UI-CastingBar-Spark spark w-10 h-30 blendmode-glow color=white
-- #FFB531 to #FFAE39
-- Solid texture
-- FFFFFF background at 50% alpha
-- White text to the right displaying time in 0.0s
-- 1x1 square full white black border

local countdownTime = 35
local updateInterval = 0.01
local elapsedTime = countdownTime
local nextUpdate = updateInterval

local ProgressBar = CreateFrame("Frame", nil, UIParent)
ProgressBar:SetSize(386, 16)
ProgressBar:SetPoint("CENTER")

ProgressBar.bg = ProgressBar:CreateTexture(nil, "BACKGROUND")

ProgressBar.bg:SetTexture("Interface/Buttons/WHITE8x8")
ProgressBar.bg:SetAllPoints(ProgressBar)
ProgressBar.bg:SetVertexColor(1, 1, 1, 0.5)

Mixin(ProgressBar, BackdropTemplateMixin)
ProgressBar:SetBackdrop({
	edgeFile = "Interface/BUTTONS/WHITE8X8",
	edgeSize = 1,
})
ProgressBar:SetBackdropBorderColor(0, 0, 0)

ProgressBar.bar = CreateFrame("StatusBar", nil, ProgressBar)
ProgressBar.bar:SetSize(384, 14)
ProgressBar.bar:SetPoint("CENTER")
ProgressBar.bar:SetStatusBarTexture("Interface/Buttons/WHITE8x8")
ProgressBar.bar:SetStatusBarColor(1, 0.7, 0.19)
ProgressBar.bar:SetMinMaxValues(0, countdownTime)
ProgressBar.bar:SetValue(countdownTime)

ProgressBar.spark = ProgressBar.bar:CreateTexture(nil, "OVERLAY")
ProgressBar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
ProgressBar.spark:SetBlendMode("ADD")
ProgressBar.spark:SetSize(10, 30)
ProgressBar.spark:SetPoint("CENTER", ProgressBar.bar, "LEFT", ProgressBar.bar:GetWidth(), 0)

ProgressBar.bar:SetScript("OnValueChanged", function(self, value)
	local sparkPosition = (value / countdownTime) * self:GetWidth()
	ProgressBar.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0)
	local colorProgress = value / countdownTime
	local r = 1
	local g = 0.7 - (0.02 * (1 - colorProgress))
	local b = 0.19 + (0.03 * (1 - colorProgress))
	ProgressBar.bar:SetStatusBarColor(r, g, b)
end)

ProgressBar.text = ProgressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ProgressBar.text:SetJustifyH("LEFT")
ProgressBar.text:SetPoint("RIGHT", ProgressBar.bar, "RIGHT", 0, 0)
ProgressBar.text:SetTextColor(1, 1, 1, 1)

ProgressBar:SetScript("OnUpdate", function(self, elapsed)
	nextUpdate = nextUpdate - elapsed
	if nextUpdate <= 0 then
		elapsedTime = elapsedTime - updateInterval
		if elapsedTime <= 0 then
			elapsedTime = 0
			ProgressBar:SetScript("OnUpdate", nil)
		end
		ProgressBar.bar:SetValue(elapsedTime)
		ProgressBar.text:SetText(string.format("%.1f", elapsedTime))
		nextUpdate = updateInterval
	end
end)
