local _, Ambrosia = ...

local PrintDebug = function(...)
	Ambrosia:PrintDebug(...)
end

local AddonProfiler = CreateFrame("Frame")

local function AddonProfilerToggle()
	local disabled = AddonProfiler.enabled and 0 or 1
	if not AddonProfiler.Initialized then
		PrintDebug("Initializing addonProfilerEnabled CVar")
		C_CVar.RegisterCVar("addonProfilerEnabled", "1")
		AddonProfiler.Initialized = true
	end
	C_CVar.SetCVar("addonProfilerEnabled", disabled)
	local status = (disabled == 0) and "|c3fff2114disabled|r" or "|cff19ff19enabled|r"
	PrintDebug("Addon CPU Profiling has been " .. status)
end

function AddonProfiler:Enable()
	if self.enabled then
		return
	end

	self.enabled = true
	AddonProfilerToggle()
	-- PrintDebug("Enabled Addon Profiler Togggle")
end

function AddonProfiler:Disable()
	self.enabled = false
	AddonProfilerToggle()
	-- PrintDebug("Disabled Addon Profiler Togggle")
end

do
	local function EnableModule(state)
		if state then
			AddonProfiler:Enable()
		else
			AddonProfiler:Disable()
		end
	end

	local moduleData = {
		name = "Disable Addon Profiler on Login",
		dbKey = "AddonProfiler",
		description = "Turn off Blizzard's Addon CPU Profiling introduced in Patch 11.1 every time you log in.",
		toggleFunc = EnableModule,
		categoryID = 1,
		uiOrder = 2,
	}

	Ambrosia.Config:AddModule(moduleData)
end
