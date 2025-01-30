local addonName, Ambrosia = ...

local _G = _G
local C_Timer_After = C_Timer.After
local ceil = ceil
local format = format
local strlower = strlower
local strupper = strupper

--Debugging Prints
function Ambrosia:PrintDebug(str)
	if not self.db.DebugMode then
		return
	end
	print("|cffffd200Ambrosia|r Debug: " .. str)
end

function Ambrosia:ReloadPopUp()
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
	local function CreateClosure(func, data)
		return function()
			func(unpack(data))
		end
	end

	function Ambrosia:Delay(delay, func, ...)
		if type(delay) ~= "number" or type(func) ~= "function" then
			return false
		end

		local args = { ... } -- delay: Restrict to the lowest time that the API allows us
		C_Timer_After(delay < 0.01 and 0.01 or delay, (#args <= 0 and func) or CreateClosure(func, args))

		return true
	end
end

do
	local cuttedIconTemplate = "|T%s:%d:%d:0:0:64:64:5:59:5:59|t"
	local cuttedIconAspectRatioTemplate = "|T%s:%d:%d:0:0:64:64:%d:%d:%d:%d|t"
	local textureTemplate = "|T%s:%d:%d|t"
	local aspectRatioTemplate = "|T%s:0:aspectRatio|t"
	local textureWithTexCoordTemplate = "|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t"
	local s = 14

	function GetIconString(icon, height, width, aspectRatio)
		if aspectRatio and height and height > 0 and width and width > 0 then
			local proportionality = height / width
			local offset = ceil((54 - 54 * proportionality) / 2)
			if proportionality > 1 then
				return format(cuttedIconAspectRatioTemplate, icon, height, width, 5 + offset, 59 - offset, 5, 59)
			elseif proportionality < 1 then
				return format(cuttedIconAspectRatioTemplate, icon, height, width, 5, 59, 5 + offset, 59 - offset)
			end
		end

		width = width or height
		return format(cuttedIconTemplate, icon, height or s, width or s)
	end

	function Ambrosia.GetTextureString(texture, height, width, aspectRatio)
		if aspectRatio then
			return format(aspectRatioTemplate, texture)
		else
			width = width or height
			return format(textureTemplate, texture, height or s, width or s)
		end
	end

	function Ambrosia.GetTextureStringFromTexCoord(texture, width, size, texCoord)
		width = width or size

		return format(
			textureWithTexCoordTemplate,
			texture,
			ceil(width * (texCoord[4] - texCoord[3]) / (texCoord[2] - texCoord[1])),
			width,
			0,
			0,
			size.x,
			size.y,
			texCoord[1] * size.x,
			texCoord[2] * size.x,
			texCoord[3] * size.y,
			texCoord[4] * size.y
		)
	end
end

function Ambrosia.DelvesEventFix(original, func)
	local isWaiting = false

	return function(...)
		local difficulty = select(3, GetInstanceInfo())
		if not difficulty or difficulty ~= 208 then
			return original(...)
		end

		if isWaiting then
			return
		end

		local f = GenerateFlatClosure(original, ...)

		RunNextFrame(function()
			if not isWaiting then
				isWaiting = true
				Ambrosia:Delay(3, function()
					f()
					isWaiting = false
				end)
			end
		end)
	end
end

-- ElvUI CreateBackdrop() Adaptation

-- Define some constants for colors and textures
local DEFAULT_BACKDROP_COLOR = { 0, 0, 0, 0.5 } -- RGBA
local DEFAULT_BORDER_COLOR = { 0, 0, 0, 1 } -- RGBA
local DEFAULT_EDGE_FILE = "Interface\\Buttons\\WHITE8X8"

-- Utility Functions

local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 0
	yOffset = yOffset or 0
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then
		obj:ClearAllPoints()
	end
	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

function CreateBackdrop(frame, template)
	local backdrop = frame.backdrop or CreateFrame("Frame", nil, frame, "BackdropTemplate")
	if not frame.backdrop then
		frame.backdrop = backdrop
	end

	backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)

	-- Default Backdrop Settings
	backdrop:SetBackdrop({
		bgFile = DEFAULT_EDGE_FILE,
		edgeFile = DEFAULT_EDGE_FILE,
		edgeSize = 1,
	})

	if template == "Transparent" then
		backdrop:SetBackdropColor(unpack(DEFAULT_BACKDROP_COLOR))
		backdrop:SetBackdropBorderColor(unpack(DEFAULT_BORDER_COLOR))
	else
		backdrop:SetBackdropColor(0, 0, 0, 1)
		backdrop:SetBackdropBorderColor(1, 1, 1, 1)
	end

	SetOutside(backdrop, frame, 1, 1)
end

function Ambrosia:CreateOptionsPane(name)
	local f = CreateFrame("Frame", name, UIParent)
	f:Hide()
	f:SetSize(440, 150)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:RegisterForDrag("LeftButton")
	f:SetDontSavePosition(true)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(200)
	f:EnableMouse(true)
	f:SetScript("OnDragStart", function(self, button)
		self:StartMoving()
	end)
	f:SetScript("OnDragStop", function(self, button)
		self:StopMovingOrSizing()
	end)

	f.Border = CreateFrame("Frame", nil, f, "DialogBorderTranslucentTemplate")
	f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonNoScripts")
	f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	f.CloseButton:SetScript("OnClick", function()
		f:Hide()
		f:ClearAllPoints()
		f.requireResetPosition = true
		if f.parent then
			if f.parent.Selection then
				f.parent.Selection:ShowHighlighted()
			end
			if f.parent.ExitEditMode and not API.IsInEditMode() then
				f.parent:ExitEditMode()
			end
			f.parent = nil
		end
	end)
	f.Title = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	f.Title:SetPoint("TOP", f, "TOP", 0, -16)

	f.Divider = f:CreateTexture(nil, "OVERLAY")
	f.Divider:SetTexture("Interface/AddOns/AdvancedMythicTracker/Media/Frame/Divider_NineSlice")
	f.Divider:SetTextureSliceMargins(48, 4, 48, 4)
	f.Divider:SetTextureSliceMode(0)
	f.Divider:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -34)
	f.Divider:SetHeight(8)
	f.Divider:SetWidth(f:GetWidth() - (20 * 2))
	tinsert(UISpecialFrames, f:GetName())
	return f
end

-- Convert RGB to Hex
function AMB_RGBtoHexConversion(r, g, b, header, ending)
	r = r <= 1 and r >= 0 and r or 1
	g = g <= 1 and g >= 0 and g or 1
	b = b <= 1 and b >= 0 and b or 1
	return format("%s%02x%02x%02x%s", header or "|cff", r * 255, g * 255, b * 255, ending or "")
end

-- Color Text to appropriate Color Name
function AMB_ClassColorString(text, ClassName)
	local r, g, b = GetClassColor(ClassName)
	local hexcolor = r and g and b and AMB_RGBtoHexConversion(r, g, b) or "|cffffffff"
	return hexcolor .. text .. "|r"
end

--Strip a string of it's color wrapping
function AMB_StripColorText(coloredString)
	local color, text = coloredString:match("|c(%x%x%x%x%x%x%x%x)(.-)|r")
	return text
end
