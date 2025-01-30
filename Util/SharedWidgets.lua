local _, addon = ...
local API = addon.API

local PrintDebug = function(...)
	addon:PrintDebug(...)
end

local BUTTON_MIN_SIZE = 27

local Mixin = API.Mixin

local tinsert = table.insert
local ipairs = ipairs
local IsMouseButtonDown = IsMouseButtonDown
local GetMouseFocus = API.GetMouseFocus
local PlaySound = PlaySound
local C_Item = C_Item
local CreateFrame = CreateFrame
local UIParent = UIParent

local IsMouseButtonDown = IsMouseButtonDown
local PlaySound = PlaySound
local CreateFrame = CreateFrame

local function DisableSharpening(texture)
	texture:SetTexelSnappingBias(0)
	texture:SetSnapToPixelGrid(false)
end
API.DisableSharpening = DisableSharpening

do -- Checkbox
	local LABEL_OFFSET = 20
	local BUTTON_HITBOX_MIN_WIDTH = 120

	local SFX_CHECKBOX_ON = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856
	local SFX_CHECKBOX_OFF = SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or 857

	local CheckboxMixin = {}

	function CheckboxMixin:OnEnter()
		if IsMouseButtonDown() then
			return
		end

		if self.tooltip then
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.Label:GetText(), 1, 1, 1, true)
			GameTooltip:AddLine(self.tooltip, 1, 0.82, 0, true)
			GameTooltip:Show()
		end

		if self.onEnterFunc then
			self.onEnterFunc(self)
		end
	end

	function CheckboxMixin:OnLeave()
		GameTooltip:Hide()

		if self.onLeaveFunc then
			self.onLeaveFunc(self)
		end
	end

	function CheckboxMixin:OnClick()
		local newState

		if self.dbKey and ElvUI and self.dbKey == "UIScale" then
			-- newState = false
			addon.SetDBValue(self.dbKey, false)
			self:SetChecked(false)
		elseif self.dbKey then
			newState = not addon.GetDBValue(self.dbKey)
			addon.SetDBValue(self.dbKey, newState)
			self:SetChecked(newState)
		else
			newState = not self:GetChecked()
			self:SetChecked(newState)
		end

		if self.onClickFunc then
			self.onClickFunc(self, newState)
		end

		if self.checked then
			PlaySound(SFX_CHECKBOX_ON)
		else
			PlaySound(SFX_CHECKBOX_OFF)
		end

		GameTooltip:Hide()
	end

	function CheckboxMixin:GetChecked()
		return self.checked
	end

	function CheckboxMixin:SetChecked(state)
		state = state or false
		self.CheckedTexture:SetShown(state)
		self.checked = state
	end

	function CheckboxMixin:SetFixedWidth(width)
		self.fixedWidth = width
		self:SetWidth(width)
	end

	function CheckboxMixin:SetMaxWidth(maxWidth)
		--this width includes box and label
		self.Label:SetWidth(maxWidth - LABEL_OFFSET)
		self.SetWidth(maxWidth)
	end

	function CheckboxMixin:SetLabel(label)
		self.Label:SetText(label)
		local width = self.Label:GetWrappedWidth() + LABEL_OFFSET
		local height = self.Label:GetHeight()
		local lines = self.Label:GetNumLines()

		self.Label:ClearAllPoints()
		if lines > 1 then
			self.Label:SetPoint("TOPLEFT", self, "TOPLEFT", LABEL_OFFSET, -4)
		else
			self.Label:SetPoint("LEFT", self, "LEFT", LABEL_OFFSET, 0)
		end

		if self.fixedWidth then
			return self.fixedWidth
		else
			self:SetWidth(math.max(BUTTON_HITBOX_MIN_WIDTH, width))
			return width
		end
	end

	function CheckboxMixin:SetData(data)
		self.dbKey = data.dbKey
		self.tooltip = data.tooltip
		self.onClickFunc = data.onClickFunc
		self.onEnterFunc = data.onEnterFunc
		self.onLeaveFunc = data.onLeaveFunc

		if data.label then
			return self:SetLabel(data.label)
		else
			return 0
		end
	end

	local function CreateCheckbox(parent)
		local b = CreateFrame("Button", nil, parent)
		b:SetSize(BUTTON_MIN_SIZE, BUTTON_MIN_SIZE)

		b.Label = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		b.Label:SetJustifyH("LEFT")
		b.Label:SetJustifyV("TOP")
		b.Label:SetTextColor(1, 0.82, 0) --labelcolor
		b.Label:SetPoint("LEFT", b, "LEFT", LABEL_OFFSET, 0)

		b.Border = b:CreateTexture(nil, "ARTWORK")
		b.Border:SetTexture("Interface/AddOns/Ambrosia/Media/Button/Checkbox")
		b.Border:SetTexCoord(0, 0.5, 0, 0.5)
		b.Border:SetPoint("CENTER", b, "LEFT", 8, 0)
		b.Border:SetSize(36, 36)
		DisableSharpening(b.Border)

		b.CheckedTexture = b:CreateTexture(nil, "OVERLAY")
		b.CheckedTexture:SetTexture("Interface/AddOns/Ambrosia/Media/Button/Checkbox")
		b.CheckedTexture:SetTexCoord(0.5, 0.75, 0.5, 0.75)
		b.CheckedTexture:SetPoint("CENTER", b.Border, "CENTER", 0, 0)
		b.CheckedTexture:SetSize(18, 18)
		DisableSharpening(b.CheckedTexture)
		b.CheckedTexture:Hide()

		b.Highlight = b:CreateTexture(nil, "HIGHLIGHT")
		b.Highlight:SetTexture("Interface/AddOns/Ambrosia/Media/Button/Checkbox")
		b.Highlight:SetTexCoord(0, 0.5, 0.5, 1)
		b.Highlight:SetPoint("CENTER", b.Border, "CENTER", 0, 0)
		b.Highlight:SetSize(36, 36)
		--b.Highlight:Hide();
		DisableSharpening(b.Highlight)

		Mixin(b, CheckboxMixin)
		b:SetScript("OnClick", CheckboxMixin.OnClick)
		b:SetScript("OnEnter", CheckboxMixin.OnEnter)
		b:SetScript("OnLeave", CheckboxMixin.OnLeave)

		return b
	end

	local function CreateCustomCheckbox(parent, name, size)
		local b = CreateFrame("Button", name, parent)
		b:SetSize(size, size)

		b.Label = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		b.Label:SetJustifyH("LEFT")
		b.Label:SetJustifyV("TOP")
		b.Label:SetTextColor(1, 0.82, 0) --labelcolor
		b.Label:SetPoint("LEFT", b, "LEFT", LABEL_OFFSET, 0)

		b.Border = b:CreateTexture(nil, "ARTWORK")
		b.Border:SetTexture("Interface/AddOns/Ambrosia/Media/Button/Checkbox")
		b.Border:SetTexCoord(0, 0.5, 0, 0.5)
		b.Border:SetPoint("CENTER", b, "CENTER", 0, 0)
		b.Border:SetSize(size / 0.5, size / 0.5)
		DisableSharpening(b.Border)

		b.CheckedTexture = b:CreateTexture(nil, "OVERLAY")
		b.CheckedTexture:SetTexture("Interface/AddOns/Ambrosia/Media/Button/Checkbox")
		b.CheckedTexture:SetTexCoord(0.5, 0.75, 0.5, 0.75)
		b.CheckedTexture:SetPoint("CENTER", b.Border, "CENTER", 0, 0)
		b.CheckedTexture:SetSize(size / 1.5, size / 1.5)
		DisableSharpening(b.CheckedTexture)
		b.CheckedTexture:Hide()

		b.Highlight = b:CreateTexture(nil, "HIGHLIGHT")
		b.Highlight:SetTexture("Interface/AddOns/Ambrosia/Media/Button/Checkbox")
		b.Highlight:SetTexCoord(0, 0.5, 0.5, 1)
		b.Highlight:SetPoint("CENTER", b.Border, "CENTER", 0, 0)
		b.Highlight:SetSize(size / 0.5, size / 0.5)
		--b.Highlight:Hide();
		DisableSharpening(b.Highlight)

		Mixin(b, CheckboxMixin)
		b:SetScript("OnClick", CheckboxMixin.OnClick)
		b:SetScript("OnEnter", CheckboxMixin.OnEnter)
		b:SetScript("OnLeave", CheckboxMixin.OnLeave)

		return b
	end

	addon.CreateCheckbox = CreateCheckbox
	addon.CreateCustomCheckbox = CreateCustomCheckbox
end

do --Slider
	local SliderFrameMixin = {}

	local TEXTURE_FILE = "Interface/AddOns/Ambrosia/Media/Button/Slider"
	local TEX_COORDS = {
		Thumb_Nomral = { 0, 0.5, 0, 0.25 },
		Thumb_Disable = { 0.5, 1, 0, 0.25 },
		Thumb_Highlight = { 0, 0.5, 0.25, 0.5 },

		Back_Nomral = { 0, 0.25, 0.5, 0.625 },
		Back_Disable = { 0.25, 0.5, 0.5, 0.625 },
		Back_Highlight = { 0.5, 0.75, 0.5, 0.625 },

		Forward_Nomral = { 0, 0.25, 0.625, 0.75 },
		Forward_Disable = { 0.25, 0.5, 0.625, 0.75 },
		Forward_Highlight = { 0.5, 0.75, 0.625, 0.75 },

		Slider_Left = { 0, 0.125, 0.875, 1 },
		Slider_Middle = { 0.125, 0.375, 0.875, 1 },
		Slider_Right = { 0.375, 0.5, 0.875, 1 },
	}

	local function SetTextureCoord(texture, key)
		texture:SetTexCoord(unpack(TEX_COORDS[key]))
	end

	local SharedMethods = {
		"GetValue",
		"SetValue",
		"SetMinMaxValues",
	}

	for k, v in ipairs(SharedMethods) do
		SliderFrameMixin[v] = function(self, ...)
			return self.Slider[v](self.Slider, ...)
		end
	end

	local SliderScripts = {}

	function SliderScripts:OnMinMaxChanged(min, max)
		if self.formatMinMaxValueFunc then
			self.formatMinMaxValueFunc(min, max)
		end
	end

	function SliderScripts:OnValueChanged(value, userInput)
		if value ~= self.value then
			self.value = value
		else
			return
		end

		self.ThumbTexture:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)

		if self.ValueText then
			if self.formatValueFunc then
				self.ValueText:SetText(self.formatValueFunc(value))
			else
				self.ValueText:SetText(value)
			end
		end

		if userInput then
			if self.onValueChangedFunc then
				self.onValueChangedFunc(value, true)
			end
		end
	end

	function SliderScripts:OnMouseDown()
		if self:IsEnabled() then
			self:LockHighlight()
		end
	end

	function SliderScripts:OnMouseUp()
		self:UnlockHighlight()
	end

	local function BackForwardButton_OnClick(self)
		if self.delta then
			self:GetParent():SetValueByDelta(self.delta, true)
		end
	end

	function SliderFrameMixin:OnLoad()
		for k, v in pairs(SliderScripts) do
			self.Slider:SetScript(k, v)
		end

		self.Back:SetScript("OnClick", BackForwardButton_OnClick)
		self.Forward:SetScript("OnClick", BackForwardButton_OnClick)

		self.Slider.Left:SetTexture(TEXTURE_FILE)
		self.Slider.Middle:SetTexture(TEXTURE_FILE)
		self.Slider.Right:SetTexture(TEXTURE_FILE)
		self.Slider.ThumbTexture:SetTexture(TEXTURE_FILE)
		self.Slider.ThumbHighlight:SetTexture(TEXTURE_FILE)
		SetTextureCoord(self.Slider.Left, "Slider_Left")
		SetTextureCoord(self.Slider.Middle, "Slider_Middle")
		SetTextureCoord(self.Slider.Right, "Slider_Right")
		SetTextureCoord(self.Slider.ThumbTexture, "Thumb_Nomral")
		SetTextureCoord(self.Slider.ThumbHighlight, "Thumb_Highlight")

		self.Back.Texture:SetTexture(TEXTURE_FILE)
		self.Back.Highlight:SetTexture(TEXTURE_FILE)
		SetTextureCoord(self.Back.Texture, "Back_Nomral")
		SetTextureCoord(self.Back.Highlight, "Back_Highlight")

		self.Forward.Texture:SetTexture(TEXTURE_FILE)
		self.Forward.Highlight:SetTexture(TEXTURE_FILE)
		SetTextureCoord(self.Forward.Texture, "Forward_Nomral")
		SetTextureCoord(self.Forward.Highlight, "Forward_Highlight")

		self:SetMinMaxValues(0, 100)
		self:SetValueStep(10)
		self:SetObeyStepOnDrag(true)
		self:SetValue(0)

		self:Enable()

		DisableSharpening(self.Slider.Left)
		DisableSharpening(self.Slider.Middle)
		DisableSharpening(self.Slider.Right)

		self:SetLabelWidth(144)

		local function OnEnter()
			self:OnEnter()
		end

		local function OnLeave()
			self:OnLeave()
		end

		self:SetScript("OnEnter", OnEnter)
		self:SetScript("OnLeave", OnLeave)
		self.Back:SetScript("OnEnter", OnEnter)
		self.Back:SetScript("OnLeave", OnLeave)
		self.Forward:SetScript("OnEnter", OnEnter)
		self.Forward:SetScript("OnLeave", OnLeave)
		self.Slider:SetScript("OnEnter", OnEnter)
		self.Slider:SetScript("OnLeave", OnLeave)
	end

	function SliderFrameMixin:Enable()
		self.Slider:Enable()
		self.Back:Enable()
		self.Forward:Enable()
		SetTextureCoord(self.Slider.ThumbTexture, "Thumb_Nomral")
		SetTextureCoord(self.Back.Texture, "Back_Nomral")
		SetTextureCoord(self.Forward.Texture, "Forward_Nomral")
		self.Label:SetTextColor(1, 1, 1)
		self.RightText:SetTextColor(1, 0.82, 0)
	end

	function SliderFrameMixin:Disable()
		self.Slider:Disable()
		self.Back:Disable()
		self.Forward:Disable()
		self.Slider:UnlockHighlight()
		SetTextureCoord(self.Slider.ThumbTexture, "Thumb_Disable")
		SetTextureCoord(self.Back, "Back_Disable")
		SetTextureCoord(self.Forward.Texture, "Forward_Disable")
		self.Label:SetTextColor(0.5, 0.5, 0.5)
		self.RightText:SetTextColor(0.5, 0.5, 0.5)
	end

	function SliderFrameMixin:SetValueByDelta(delta, userInput)
		local value = self:GetValue()
		self:SetValue(value + delta)

		if userInput then
			if self.onValueChangedFunc then
				self.onValueChangedFunc(self:GetValue())
			end
		end
	end

	function SliderFrameMixin:SetValueStep(valueStep)
		self.Slider:SetValueStep(valueStep)
		self.Back.delta = -valueStep
		self.Forward.delta = valueStep
	end

	function SliderFrameMixin:SetObeyStepOnDrag(obey)
		self.Slider:SetObeyStepOnDrag(obey)
		if not obey then
			local min, max = self.GetMinMaxValues()
			local delta = (max - min) * 0.1
			self.Back.delta = -delta
			self.Forward.delta = delta
		end
	end

	function SliderFrameMixin:SetLabel(label)
		self.Label:SetText(label)
	end

	function SliderFrameMixin:SetFormatValueFunc(formatValueFunc)
		self.Slider.formatValueFunc = formatValueFunc
		self.RightText:SetText(formatValueFunc(self:GetValue() or 0))
	end

	function SliderFrameMixin:SetOnValueChangedFunc(onValueChangedFunc)
		self.Slider.onValueChangedFunc = onValueChangedFunc
		self.onValueChangedFunc = onValueChangedFunc
	end

	function SliderFrameMixin:SetLabelWidth(width)
		self.Label:SetWidth(width)
		self:SetWidth(242 + width) --386
		self.Slider:SetPoint("LEFT", self, "LEFT", 28 + width, 0)
	end

	function SliderFrameMixin:OnEnter()
		if self.tooltip then
			local f = GameTooltip
			f:Hide()
			f:SetOwner(self, "ANCHOR_RIGHT")
			f:SetText(self.Label:GetText(), 1, 1, 1, true)
			f:AddLine(self.tooltip, 1, 0.82, 0, true)
			if self.tooltip2 then
				local tooltip2
				if type(self.tooltip2) == "function" then
					tooltip2 = self.tooltip2()
				else
					tooltip2 = self.tooltip2
				end
				if tooltip2 then
					f:AddLine(" ", 1, 0.82, 0, true)
					f:AddLine(tooltip2, 1, 0.82, 0, true)
				end
			end
			f:Show()
		end
	end

	function SliderFrameMixin:OnLeave()
		GameTooltip:Hide()
	end

	local function FormatValue(value)
		return value
	end

	local function CreateSlider(parent)
		local f = CreateFrame("Frame", nil, parent, "PlumberMinimalSliderWithControllerTemplate")
		Mixin(f, SliderFrameMixin)

		f.Slider.ValueText = f.RightText
		f.Slider.Back = f.Back
		f.Slider.Forward = f.Forward

		f:SetFormatValueFunc(FormatValue)
		f:OnLoad()

		return f
	end
	addon.CreateSlider = CreateSlider
end

do -- Dropdown
	local DropdownFrameMixin = {}

	function DropdownFrameMixin:SetOnValueChangedFunc(func)
		self.onValueChangedFunc = func
	end

	function DropdownFrameMixin:OnEnter()
		if IsMouseButtonDown() then
			return
		end

		if self.tooltip then
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.Label:GetText(), 1, 1, 1, true)
			GameTooltip:AddLine(self.tooltip, 1, 0.82, 0, true)
			GameTooltip:Show()
		end

		if self.onEnterFunc then
			self.onEnterFunc(self)
		end
	end

	function DropdownFrameMixin:OnLeave()
		GameTooltip:Hide()

		if self.onLeaveFunc then
			self.onLeaveFunc(self)
		end
	end

	function DropdownFrameMixin:SetOptions(options)
		self.options = options
	end

	function DropdownFrameMixin:SetValue()
		local dbValue = addon.GetDBValue(self.dbKey)
		local setValue

		for _, option in ipairs(self.options) do
			if option.value == dbValue then
				setValue = option.text
			end
		end

		self:SetSelectionText(function()
			return setValue
		end)
	end

	function DropdownFrameMixin:SetLabel(label)
		self.Label:SetText(label)
		self.Label:SetWidth(154)
	end

	function DropdownFrameMixin:SetData(data)
		self.dbKey = data.dbKey
		self.tooltip = data.tooltip
		self.onClickFunc = data.onClickFunc
		self.onEnterFunc = data.onEnterFunc
		self.onLeaveFunc = data.onLeaveFunc

		if data.label then
			return self:SetLabel(data.label)
		else
			return 0
		end
	end

	-- Function to create the dropdown
	local function CreateDropdown(parent)
		local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		dropdown:SetPoint("RIGHT", UIParent, "RIGHT", 0, 0)
		dropdown:SetWidth(186)

		-- Label setup
		dropdown.Label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		dropdown.Label:SetJustifyH("LEFT")
		dropdown.Label:SetJustifyV("TOP")
		dropdown.Label:SetTextColor(1, 1, 1) --labelcolor
		dropdown.Label:SetPoint("RIGHT", dropdown, "LEFT", 0, 0)
		dropdown.Label:SetFontObject("GameFontHighlightMedium")

		Mixin(dropdown, DropdownFrameMixin)
		dropdown:SetScript("OnClick", DropdownFrameMixin.OnClick)
		dropdown:SetScript("OnEnter", DropdownFrameMixin.OnEnter)
		dropdown:SetScript("OnLeave", DropdownFrameMixin.OnLeave)

		return dropdown
	end

	addon.CreateDropdown = CreateDropdown
end

do -- Common Frame with Header (and close button)
	local function CloseButton_OnClick(self)
		local parent = self:GetParent()
		if parent.CloseUI then
			parent:CloseUI()
		else
			parent:Hide()
		end
	end

	local function CloseButton_ShowNormalTexture(self)
		self.Texture:SetTexCoord(0, 0.5, 0, 0.5)
		self.Highlight:SetTexCoord(0, 0.5, 0.5, 1)
	end

	local function CloseButton_ShowPushedTexture(self)
		self.Texture:SetTexCoord(0.5, 1, 0, 0.5)
		self.Highlight:SetTexCoord(0.5, 1, 0.5, 1)
	end

	local function CreateCloseButton(parent)
		local b = CreateFrame("Button", nil, parent)
		b:SetSize(BUTTON_MIN_SIZE, BUTTON_MIN_SIZE)

		b.Texture = b:CreateTexture(nil, "ARTWORK")
		b.Texture:SetTexture("Interface/AddOns/Ambrosia/Media/Button/CloseButton")
		b.Texture:SetPoint("CENTER", b, "CENTER", 0, 0)
		b.Texture:SetSize(32, 32)
		DisableSharpening(b.Texture)

		b.Highlight = b:CreateTexture(nil, "HIGHLIGHT")
		b.Highlight:SetTexture("Interface/AddOns/Ambrosia/Media/Button/CloseButton")
		b.Highlight:SetPoint("CENTER", b, "CENTER", 0, 0)
		b.Highlight:SetSize(32, 32)
		DisableSharpening(b.Highlight)

		CloseButton_ShowNormalTexture(b)

		b:SetScript("OnClick", CloseButton_OnClick)
		b:SetScript("OnMouseUp", CloseButton_ShowNormalTexture)
		b:SetScript("OnMouseDown", CloseButton_ShowPushedTexture)
		b:SetScript("OnShow", CloseButton_ShowNormalTexture)

		return b
	end

	local CategoryDividerMixin = {}

	function CategoryDividerMixin:HideDivider()
		self.Divider:Hide()
	end

	local function CreateCategoryDivider(parent, alignCenter)
		local fontString = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		if alignCenter then
			fontString:SetJustifyH("CENTER")
		else
			fontString:SetJustifyH("LEFT")
		end

		fontString:SetJustifyV("TOP")
		fontString:SetTextColor(1, 1, 1)

		local divider = parent:CreateTexture(nil, "OVERLAY")
		divider:SetHeight(4)
		--divider:SetWidth(240);
		divider:SetPoint("TOPLEFT", fontString, "BOTTOMLEFT", 0, -4)
		divider:SetPoint("RIGHT", parent, "RIGHT", -8, 0)

		divider:SetTexture("Interface/AddOns/Ambrosia/Media/Frame/Divider_Gradient_Horizontal")
		divider:SetVertexColor(0.5, 0.5, 0.5)
		DisableSharpening(divider)

		Mixin(fontString, CategoryDividerMixin)

		return fontString
	end

	addon.CreateCategoryDivider = CreateCategoryDivider

	local HeaderFrameMixin = {}

	function HeaderFrameMixin:SetCornerSize(a) end

	function HeaderFrameMixin:ShowCloseButton(state)
		self.CloseButton:SetShown(state)
	end

	function HeaderFrameMixin:SetTitle(title)
		self.Title:SetText(title)
	end

	function HeaderFrameMixin:GetHeaderHeight()
		return 18
	end

	local function CreateHeaderFrame(parent, showCloseButton)
		local f = CreateFrame("Frame", nil, parent)
		f:ClearAllPoints()

		local p = {}
		f.pieces = p

		f.Title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		f.Title:SetJustifyH("CENTER")
		f.Title:SetJustifyV("MIDDLE")
		f.Title:SetTextColor(1, 0.82, 0)
		f.Title:SetPoint("CENTER", f, "TOP", 0, -8 - 1)

		f.CloseButton = CreateCloseButton(f)
		f.CloseButton:SetPoint("CENTER", f, "TOPRIGHT", -9, -9)
		-- 1 2 3
		-- 4 5 6
		-- 7 8 9

		local tex = "Interface/AddOns/Ambrosia/Media/Frame/CommonFrameWithHeader_Opaque"

		for i = 1, 9 do
			p[i] = f:CreateTexture(nil, "BORDER")
			p[i]:SetTexture(tex)
			DisableSharpening(p[i])
			p[i]:ClearAllPoints()
		end

		p[1]:SetPoint("CENTER", f, "TOPLEFT", 0, -8)
		p[3]:SetPoint("CENTER", f, "TOPRIGHT", 0, -8)
		p[7]:SetPoint("CENTER", f, "BOTTOMLEFT", 0, 0)
		p[9]:SetPoint("CENTER", f, "BOTTOMRIGHT", 0, 0)
		p[2]:SetPoint("TOPLEFT", p[1], "TOPRIGHT", 0, 0)
		p[2]:SetPoint("BOTTOMRIGHT", p[3], "BOTTOMLEFT", 0, 0)
		p[4]:SetPoint("TOPLEFT", p[1], "BOTTOMLEFT", 0, 0)
		p[4]:SetPoint("BOTTOMRIGHT", p[7], "TOPRIGHT", 0, 0)
		p[5]:SetPoint("TOPLEFT", p[1], "BOTTOMRIGHT", 0, 0)
		p[5]:SetPoint("BOTTOMRIGHT", p[9], "TOPLEFT", 0, 0)
		p[6]:SetPoint("TOPLEFT", p[3], "BOTTOMLEFT", 0, 0)
		p[6]:SetPoint("BOTTOMRIGHT", p[9], "TOPRIGHT", 0, 0)
		p[8]:SetPoint("TOPLEFT", p[7], "TOPRIGHT", 0, 0)
		p[8]:SetPoint("BOTTOMRIGHT", p[9], "BOTTOMLEFT", 0, 0)

		p[1]:SetSize(16, 32)
		p[3]:SetSize(16, 32)
		p[7]:SetSize(16, 16)
		p[9]:SetSize(16, 16)

		p[1]:SetTexCoord(0, 0.25, 0, 0.5)
		p[2]:SetTexCoord(0.25, 0.75, 0, 0.5)
		p[3]:SetTexCoord(0.75, 1, 0, 0.5)
		p[4]:SetTexCoord(0, 0.25, 0.5, 0.75)
		p[5]:SetTexCoord(0.25, 0.75, 0.5, 0.75)
		p[6]:SetTexCoord(0.75, 1, 0.5, 0.75)
		p[7]:SetTexCoord(0, 0.25, 0.75, 1)
		p[8]:SetTexCoord(0.25, 0.75, 0.75, 1)
		p[9]:SetTexCoord(0.75, 1, 0.75, 1)

		Mixin(f, HeaderFrameMixin)
		f:ShowCloseButton(showCloseButton)
		f:EnableMouse(true)

		return f
	end

	addon.CreateHeaderFrame = CreateHeaderFrame
end

do --EditMode
	local Round = API.Round
	local EditModeSelectionMixin = {}

	function EditModeSelectionMixin:OnDragStart()
		self.parent:OnDragStart()
	end

	function EditModeSelectionMixin:OnDragStop()
		self.parent:OnDragStop()
	end

	function EditModeSelectionMixin:ShowHighlighted()
		--Blue
		if not self.parent:IsShown() then
			return
		end
		self.isSelected = false
		self.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Frame/EditModeHighlighted")
		self:Show()
		self.Label:Hide()
	end

	function EditModeSelectionMixin:ShowSelected()
		--Yellow
		if not self.parent:IsShown() then
			return
		end
		self.isSelected = true
		self.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Frame/EditModeSelected")
		self:Show()

		if not self.hideLabel then
			self.Label:Show()
		end
	end

	function EditModeSelectionMixin:OnShow()
		local offset = API.GetPixelForWidget(self, 6)
		self.Background:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, offset)
		self.Background:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset)
		self:RegisterEvent("GLOBAL_MOUSE_DOWN")
	end

	function EditModeSelectionMixin:OnHide()
		self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
	end

	local function IsMouseOverOptionToggle()
		local obj = GetMouseFocus()
		if obj and obj.isAMBEditModeToggle then
			return true
		else
			return false
		end
	end

	function EditModeSelectionMixin:OnEvent(event, ...)
		if event == "GLOBAL_MOUSE_DOWN" then
			if self:IsShown() and not (self.parent:IsFocused() or IsMouseOverOptionToggle()) then
				self:ShowHighlighted()
				self.parent:ShowOptions(false)

				if self.parent.ExitEditMode and not API.IsInEditMode() then
					self.parent:ExitEditMode()
				end
			end
		end
	end

	function EditModeSelectionMixin:OnMouseDown()
		self:ShowSelected()
		self.parent:ShowOptions(true)

		if EditModeManagerFrame and EditModeManagerFrame.ClearSelectedSystem then
			EditModeManagerFrame:ClearSelectedSystem()
		end
	end

	local function CreateEditModeSelection(parent, uiName, hideLabel)
		local f = CreateFrame("Frame", nil, parent)
		f:Hide()
		f:SetAllPoints(true)
		f:SetFrameStrata(parent:GetFrameStrata())
		f:SetToplevel(true)
		f:SetFrameLevel(999)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetIgnoreParentAlpha(true)

		f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
		f.Label:SetText(uiName)
		f.Label:SetJustifyH("CENTER")
		f.Label:SetPoint("CENTER", f, "CENTER", 0, 0)

		f.Background = f:CreateTexture(nil, "BACKGROUND")
		f.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Frame/EditModeHighlighted")
		f.Background:SetTextureSliceMargins(16, 16, 16, 16)
		f.Background:SetTextureSliceMode(0)
		f.Background:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
		f.Background:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

		Mixin(f, EditModeSelectionMixin)

		f:SetScript("OnShow", f.OnShow)
		f:SetScript("OnHide", f.OnHide)
		f:SetScript("OnEvent", f.OnEvent)
		f:SetScript("OnMouseDown", f.OnMouseDown)
		f:SetScript("OnDragStart", f.OnDragStart)
		f:SetScript("OnDragStop", f.OnDragStop)

		parent.Selection = f
		f.parent = parent
		f.hideLabel = hideLabel

		return f
	end
	addon.CreateEditModeSelection = CreateEditModeSelection

	local EditModeSettingsDialog
	local DIALOG_WIDTH = 460

	local EditModeSettingsDialogMixin = {}

	function EditModeSettingsDialogMixin:Exit()
		self:Hide()
		self:ClearAllPoints()
		self.requireResetPosition = true
		if self.parent then
			if self.parent.Selection then
				self.parent.Selection:ShowHighlighted()
			end
			if self.parent.ExitEditMode and not API.IsInEditMode() then
				self.parent:ExitEditMode()
			end
			self.parent = nil
		end
	end

	function EditModeSettingsDialogMixin:ReleaseAllWidgets()
		for _, widget in ipairs(self.activeWidgets) do
			if widget.isCustomWidget then
				widget:Hide()
				widget:ClearAllPoints()
			end
		end
		self.activeWidgets = {}

		self.checkboxPool:ReleaseAll()
		self.sliderPool:ReleaseAll()
		self.dropdownPool:ReleaseAll()
		self.uiPanelButtonPool:ReleaseAll()
		self.texturePool:ReleaseAll()
		self.fontStringPool:ReleaseAll()
		self.keybindButtonPool:ReleaseAll()
	end

	function EditModeSettingsDialogMixin:Layout()
		local leftPadding = 20
		local topPadding = 48
		local bottomPadding = 20
		local OPTION_GAP_Y = 8 --consistent with ControlCenter
		local height = topPadding
		local widgetHeight
		local contentWidth = DIALOG_WIDTH - 2 * leftPadding
		local preOffset, postOffset

		for order, widget in ipairs(self.activeWidgets) do
			if widget.isGap then
				height = height + 8 + OPTION_GAP_Y
			else
				if widget.widgetType == "Divider" then
					preOffset = 2
					postOffset = 2
				elseif widget.widgetType == "Custom" then
					preOffset = 0
					postOffset = 2
				else
					preOffset = 0
					postOffset = 0
				end

				height = height + preOffset
				widget:ClearAllPoints()
				if widget.align and widget.align ~= "left" then
					if widget.align == "center" then
						if widget.effectiveWidth then
							widget:SetPoint(
								"TOPRIGHT",
								self,
								"TOPRIGHT",
								-0.5 * (contentWidth - widget.effectiveWidth) - leftPadding,
								-height
							)
						else
							widget:SetPoint("TOP", self, "TOP", 0, -height)
						end
					else
						widget:SetPoint("TOPRIGHT", self, "TOPRIGHT", -leftPadding, -height)
					end
				elseif widget.widgetType == "Dropdown" then
					widget:SetPoint("TOPLEFT", self, "TOPLEFT", leftPadding + 155, -height)
				else
					widget:SetPoint("TOPLEFT", self, "TOPLEFT", leftPadding, -height)
				end
				widgetHeight = Round(widget:GetHeight())
				height = height + widgetHeight + OPTION_GAP_Y + postOffset
				if widget.matchParentWidth then
					widget:SetWidth(contentWidth)
				end
			end
		end

		height = height - OPTION_GAP_Y + bottomPadding
		self:SetHeight(height)
	end

	function EditModeSettingsDialogMixin:AcquireWidgetByType(type)
		local widget

		if type == "Checkbox" then
			widget = self.checkboxPool:Acquire()
		elseif type == "Slider" then
			widget = self.sliderPool:Acquire()
		elseif type == "Dropdown" then
			widget = self.dropdownPool:Acquire()
		elseif type == "UIPanelButton" then
			widget = self.uiPanelButtonPool:Acquire()
		elseif type == "Texture" then
			widget = self.texturePool:Acquire()
			widget.matchParentWidth = nil
		elseif type == "FontString" then
			widget = self.fontStringPool:Acquire()
			widget.matchParentWidth = true
		elseif type == "Keybind" then
			widget = self.keybindButtonPool:Acquire()
		end

		return widget
	end

	function EditModeSettingsDialogMixin:CreateCheckbox(widgetData)
		local checkbox = self:AcquireWidgetByType("Checkbox")

		checkbox.Label:SetFontObject("GameFontHighlightMedium") --Fonts in EditMode and Options are different
		checkbox.Label:SetTextColor(1, 1, 1)

		checkbox:SetData(widgetData)
		checkbox:SetChecked(addon.GetDBValue(checkbox.dbKey))

		return checkbox
	end

	function EditModeSettingsDialogMixin:CreateSlider(widgetData)
		local slider = self:AcquireWidgetByType("Slider")

		slider:SetLabel(widgetData.label)
		slider:SetMinMaxValues(widgetData.minValue, widgetData.maxValue)

		if widgetData.valueStep then
			slider:SetObeyStepOnDrag(true)
			slider:SetValueStep(widgetData.valueStep)
		else
			slider:SetObeyStepOnDrag(false)
		end

		if widgetData.formatValueFunc then
			slider:SetFormatValueFunc(widgetData.formatValueFunc)
		else
			slider:SetFormatValueFunc(function(value)
				return value
			end)
		end

		slider:SetOnValueChangedFunc(widgetData.onValueChangedFunc)
		slider.tooltip = widgetData.tooltip

		if widgetData.dbKey and addon.GetDBValue(widgetData.dbKey) then
			slider:SetValue(addon.GetDBValue(widgetData.dbKey))
		end

		return slider
	end

	function EditModeSettingsDialogMixin:CreateDropdown(widgetData)
		local dropdown = self:AcquireWidgetByType("Dropdown")

		dropdown:SetLabel(widgetData.label)
		dropdown:SetOptions(widgetData.options)
		dropdown:SetOnValueChangedFunc(widgetData.onValueChangedFunc)
		dropdown.dbKey = widgetData.dbKey
		dropdown.tooltip = widgetData.tooltip

		dropdown:SetupMenu(function(owner, rootDescription)
			-- for _, option in ipairs(dropdown.options) do
			for i = 1, #dropdown.options do
				rootDescription:CreateButton(dropdown.options[i].text, function()
					addon.SetDBValue(dropdown.dbKey, dropdown.options[i].value)
					-- dropdown:OnClick(dropdown.options[i].value)
					dropdown.onValueChangedFunc(dropdown.options[i].value)
					dropdown:SetSelectionText(function()
						return dropdown.options[i].text
					end)
				end)
			end
		end)

		dropdown:SetValue()

		return dropdown
	end

	function EditModeSettingsDialogMixin:CreateUIPanelButton(widgetData)
		local button = self:AcquireWidgetByType("UIPanelButton")
		button:SetButtonText(widgetData.label)
		button:SetScript("OnClick", widgetData.onClickFunc)
		if (not widgetData.stateCheckFunc) or (widgetData.stateCheckFunc()) then
			button:Enable()
		else
			button:Disable()
		end
		button.matchParentWidth = true
		return button
	end

	function EditModeSettingsDialogMixin:CreateDivider(widgetData)
		local texture = self:AcquireWidgetByType("Texture")
		texture:SetTexture("Interface/AddOns/Ambrosia/Media/Frame/Divider_NineSlice")
		texture:SetTextureSliceMargins(48, 4, 48, 4)
		texture:SetTextureSliceMode(0)
		texture:SetHeight(4)
		texture.matchParentWidth = true
		DisableSharpening(texture)
		return texture
	end

	function EditModeSettingsDialogMixin:CreateHeader(widgetData)
		local fontString = self:AcquireWidgetByType("FontString")
		fontString:SetJustifyH("CENTER")
		fontString:SetJustifyV("TOP")
		fontString:SetSpacing(2)
		fontString.matchParentWidth = true
		fontString:SetText(widgetData.label)
		return fontString
	end

	function EditModeSettingsDialogMixin:CreateKeybindButton(widgetData)
		local button = self:AcquireWidgetByType("Keybind")
		button.dbKey = widgetData.dbKey
		button.tooltip = widgetData.tooltip
		button:SetKeyText(addon.GetDBValue(widgetData.dbKey))
		button:SetLabel(widgetData.label)
		return button
	end

	function EditModeSettingsDialogMixin:SetupOptions(schematic)
		self:ReleaseAllWidgets()
		self:SetTitle(schematic.title)

		if schematic.widgets then
			for order, widgetData in ipairs(schematic.widgets) do
				local widget
				if (not widgetData.validityCheckFunc) or (widgetData.validityCheckFunc()) then
					if widgetData.type == "Checkbox" then
						widget = self:CreateCheckbox(widgetData)
					elseif widgetData.type == "RadioGroup" then
					elseif widgetData.type == "Slider" then
						widget = self:CreateSlider(widgetData)
					elseif widgetData.type == "Dropdown" then
						widget = self:CreateDropdown(widgetData)
					elseif widgetData.type == "UIPanelButton" then
						widget = self:CreateUIPanelButton(widgetData)
					elseif widgetData.type == "Divider" then
						widget = self:CreateDivider(widgetData)
					elseif widgetData.type == "Header" then
						widget = self:CreateHeader(widgetData)
					elseif widgetData.type == "Keybind" then
						widget = self:CreateKeybindButton(widgetData)
					elseif widgetData.type == "Custom" then
						widget = widgetData.onAcquire()
						if widget then
							widget:SetParent(self)
							widget:ClearAllPoints()
							widget:Show()
							widget.isCustomWidget = true
							widget.align = widgetData.align or "center"
						end
					end

					if widget then
						tinsert(self.activeWidgets, widget)
						widget.widgetKey = widgetData.widgetKey
						widget.widgetType = widgetData.type
					end
				end
			end
		end
		self:Layout()
	end

	function EditModeSettingsDialogMixin:FindWidget(widgetKey)
		if self.activeWidgets then
			for _, widget in pairs(self.activeWidgets) do
				if widget.widgetKey == widgetKey then
					return widget
				end
			end
		end
	end

	function EditModeSettingsDialogMixin:OnDragStart()
		self:StartMoving()
	end

	function EditModeSettingsDialogMixin:OnDragStop()
		self:StopMovingOrSizing()
		self:ConvertAnchor()
	end

	function EditModeSettingsDialogMixin:ConvertAnchor()
		--Convert any anchor to the top left
		--so that changing frame height don't affect the positions of most buttons
		local left = self:GetLeft()
		local top = self:GetTop()
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	end

	function EditModeSettingsDialogMixin:SetTitle(title)
		self.Title:SetText(title)
	end

	function EditModeSettingsDialogMixin:IsOwner(parent)
		return parent == self.parent
	end

	function EditModeSettingsDialogMixin:IsFromSchematic(schematic)
		return schematic and self.schematic == schematic
	end

	function EditModeSettingsDialogMixin:HideOption(parent)
		if (not parent) or self:IsOwner(parent) then
			self:Hide()
		end
	end

	local function SetupSettingsDialog(parent, schematic, forceUpdate)
		if not EditModeSettingsDialog then
			local f = CreateFrame("Frame", nil, UIParent)
			EditModeSettingsDialog = f
			f:Hide()
			f:SetSize(DIALOG_WIDTH, 350)
			f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			f:SetMovable(true)
			f:SetClampedToScreen(true)
			f:RegisterForDrag("LeftButton")
			f:SetDontSavePosition(true)
			f:SetFrameStrata("DIALOG")
			f:SetFrameLevel(200)
			f:EnableMouse(true)

			f.activeWidgets = {}
			f.requireResetPosition = true

			Mixin(f, EditModeSettingsDialogMixin)

			f.Border = CreateFrame("Frame", nil, f, "DialogBorderTranslucentTemplate")
			f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonNoScripts")
			f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
			f.CloseButton:SetScript("OnClick", function()
				f:Exit()
			end)
			f.Title = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
			f.Title:SetPoint("TOP", f, "TOP", 0, -16)
			f.Title:SetText("Title")

			f:SetScript("OnDragStart", f.OnDragStart)
			f:SetScript("OnDragStop", f.OnDragStop)

			local function CreateCheckbox()
				return addon.CreateCheckbox(f)
			end
			f.checkboxPool = API.CreateObjectPool(CreateCheckbox)

			local function CreateSlider()
				return addon.CreateSlider(f)
			end
			f.sliderPool = API.CreateObjectPool(CreateSlider)

			local function CreateDropdown()
				return addon.CreateDropdown(f)
			end
			f.dropdownPool = API.CreateObjectPool(CreateDropdown)

			local function CreateUIPanelButton()
				return addon.CreateUIPanelButton(f)
			end
			f.uiPanelButtonPool = API.CreateObjectPool(CreateUIPanelButton)

			local function CreateTexture()
				return f:CreateTexture(nil, "OVERLAY")
			end
			f.texturePool = API.CreateObjectPool(CreateTexture)

			local function CreateFontString()
				return f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			end
			f.fontStringPool = API.CreateObjectPool(CreateFontString)

			local function CreateKeybindButton()
				return addon.CreateKeybindButton(f)
			end
			f.keybindButtonPool = API.CreateObjectPool(CreateKeybindButton)
		end

		if EditModeSettingsDialog:IsShown() and not EditModeSettingsDialog:IsOwner(parent) then
			EditModeSettingsDialog:Exit()
		end

		if schematic ~= EditModeSettingsDialog.schematic then
			EditModeSettingsDialog.requireResetPosition = true
			EditModeSettingsDialog.schematic = schematic
			EditModeSettingsDialog:ClearAllPoints()
			EditModeSettingsDialog:SetupOptions(schematic)
		elseif forceUpdate then
			EditModeSettingsDialog.schematic = schematic
			EditModeSettingsDialog:SetupOptions(schematic)
		end

		EditModeSettingsDialog.parent = parent

		return EditModeSettingsDialog
	end
	addon.SetupSettingsDialog = SetupSettingsDialog

	local function ToggleSettingsDialog(parent, schematic, forceUpdate)
		if EditModeSettingsDialog and EditModeSettingsDialog:IsShown() and EditModeSettingsDialog:IsOwner(parent) then
			EditModeSettingsDialog:Exit()
		else
			local f = SetupSettingsDialog(parent, schematic, forceUpdate)
			if f then
				f:Show()
				f:ClearAllPoints()
				f:SetPoint("LEFT", UIParent, "CENTER", 256, 0)
				return f
			end
		end
	end
	addon.ToggleSettingsDialog = ToggleSettingsDialog
end

do --UIPanelButton
	local UIPanelButtonMixin = {}

	function UIPanelButtonMixin:OnClick(button) end

	function UIPanelButtonMixin:OnMouseDown(button)
		if self:IsEnabled() then
			self.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Button/UIPanelButton-Down")
		end
	end

	function UIPanelButtonMixin:OnMouseUp(button)
		if self:IsEnabled() then
			self.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Button/UIPanelButton-Up")
		end
	end

	function UIPanelButtonMixin:OnDisable()
		self.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Button/UIPanelButton-Disabled")
	end

	function UIPanelButtonMixin:OnEnable()
		self.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Button/UIPanelButton-Up")
	end

	function UIPanelButtonMixin:OnEnter() end

	function UIPanelButtonMixin:OnLeave() end

	function UIPanelButtonMixin:SetButtonText(text)
		self:SetText(text)
	end

	local function CreateUIPanelButton(parent)
		local f = CreateFrame("Button", nil, parent)
		f:SetSize(144, 24)
		Mixin(f, UIPanelButtonMixin)

		f:SetScript("OnMouseDown", f.OnMouseDown)
		f:SetScript("OnMouseUp", f.OnMouseUp)
		f:SetScript("OnEnter", f.OnEnter)
		f:SetScript("OnLeave", f.OnLeave)
		f:SetScript("OnEnable", f.OnEnable)
		f:SetScript("OnDisable", f.OnDisable)

		f.Background = f:CreateTexture(nil, "BACKGROUND")
		f.Background:SetTexture("Interface/AddOns/Ambrosia/Media/Button/UIPanelButton-Up")
		f.Background:SetTextureSliceMargins(32, 16, 32, 16)
		f.Background:SetTextureSliceMode(1)
		f.Background:SetAllPoints(true)
		DisableSharpening(f.Background)

		f.Highlight = f:CreateTexture(nil, "HIGHLIGHT")
		f.Highlight:SetTexture("Interface/AddOns/Ambrosia/Media/Button/UIPanelButton-Highlight")
		f.Highlight:SetTextureSliceMargins(32, 16, 32, 16)
		f.Highlight:SetTextureSliceMode(0)
		f.Highlight:SetAllPoints(true)
		f.Highlight:SetBlendMode("ADD")
		f.Highlight:SetVertexColor(0.5, 0.5, 0.5)

		f:SetNormalFontObject("GameFontNormal")
		f:SetHighlightFontObject("GameFontHighlight")
		f:SetDisabledFontObject("GameFontDisable")
		f:SetPushedTextOffset(0, -1)

		return f
	end
	addon.CreateUIPanelButton = CreateUIPanelButton
end
