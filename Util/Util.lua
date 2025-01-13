local addonName, Ambrosia = ...

local _G = _G
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
