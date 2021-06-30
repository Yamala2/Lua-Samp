script_name('Event.lua by Yamala')
script_properties("Helper for Evolve")
script_version('3.0')

-- Библиотеки
require "lib.moonloader"
local ffi = require 'ffi'
local tag = "{E3294D}[Evolve Helper]: {FFFFFF}"
local ev = require 'samp.events'
local sampev = require 'lib.samp.events'
local dlstatus = require('moonloader').download_status

local encoding							= require "encoding"
encoding.default 						= "CP1251"
u8 										= encoding.UTF8

local inicfg = require "inicfg"
local memory = require "memory"
local imgui = require("imgui")
local vkeys	= require "lib.vkeys"
local main_window = imgui.ImBool(false)
local sw, sh = getScreenResolution()

local noErrorDialog = false

-- imgui update
local window_update = imgui.ImBool(false)
-- inicfg
local directIni	= "EvolveHelper\\settings.ini"

local mainIni = inicfg.load({
  settings =
  {
    style = 0,
	password = "",
	autologin = false
  }

}, directIni) 

tServers = {
	'185.169.134.67', -- 01
    "185.169.134.68", -- 02
	"185.169.134.91" -- 03
}

local style = imgui.ImInt(mainIni.settings.style)
local password = imgui.ImBuffer(tostring(mainIni.settings.password), 256)
autologin = false
local autologin = imgui.ImBool(mainIni.settings.autologin)
function checkServer(ip)
	for k, v in pairs(tServers) do
		if v == ip then 
			return true
		end
	end
	return false
end

function setInterfaceStyle(id)
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	if id == 0 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(2, 0, 0, 230):GetVec4() -- 04
		colors[clr.FrameBg]     	          = imgui.ImColor(150, 10, 10, 100):GetVec4() -- 01
		colors[clr.FrameBgHovered]         = imgui.ImColor(150, 10, 10, 180):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(150, 10, 10, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(150, 20, 20, 235):GetVec4() -- 01
		colors[clr.TitleBgActive]          = imgui.ImColor(150, 20, 20, 235):GetVec4() -- 01
		colors[clr.Button]                 = imgui.ImColor(150, 10, 10, 235):GetVec4() -- 01
		colors[clr.ButtonHovered]          = imgui.ImColor(150, 10, 10, 180):GetVec4() -- 01
		colors[clr.ButtonActive]           = imgui.ImColor(120, 10, 10, 180):GetVec4() -- 01
	elseif id == 1 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(2, 1, 3, 230):GetVec4() -- 04
		colors[clr.FrameBg]    	 		  = imgui.ImColor(70, 21, 135, 100):GetVec4() -- 02
		colors[clr.FrameBgHovered]         = imgui.ImColor(70, 18, 115, 180):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(70, 21, 135, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(70, 21, 135, 235):GetVec4() -- 02
		colors[clr.TitleBgActive]          = imgui.ImColor(70, 21, 135, 235):GetVec4() -- 02
		colors[clr.Button]                 = imgui.ImColor(70, 21, 135, 235):GetVec4() -- 02
		colors[clr.ButtonHovered]          = imgui.ImColor(70, 21, 135, 170):GetVec4() -- 02
		colors[clr.ButtonActive]           = imgui.ImColor(55, 18, 115, 170):GetVec4() -- 02
	elseif id == 2 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(0, 2, 0, 230):GetVec4() -- 03
		colors[clr.FrameBg] 				   = ImVec4(0.2, 0.79, 0.14, 0.24) -- 03
		colors[clr.FrameBgHovered]         = ImVec4(0.2, 0.79, 0.14, 0.4)
		colors[clr.FrameBgActive]          = ImVec4(0.15, 0.59, 0.14, 0.39)
		colors[clr.TitleBg]                = ImVec4(0.05, 0.35, 0.05, 0.95) -- 03
		colors[clr.TitleBgActive]          = ImVec4(0.05, 0.35, 0.05, 0.95) -- 03
		colors[clr.Button]                 = ImVec4(0.2, 0.79, 0.14, 0.59) -- 03
		colors[clr.ButtonHovered]          = ImVec4(0.2, 0.79, 0.14, 0.4) -- 03
		colors[clr.ButtonActive]           = ImVec4(0.15, 0.59, 0.14, 0.39) -- 03
	elseif id == 3 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(0, 1, 2, 230):GetVec4() -- 04
		colors[clr.FrameBg]    	 		  = imgui.ImColor(2, 182, 193, 100):GetVec4() -- 04
		colors[clr.FrameBgHovered]         = imgui.ImColor(0, 182, 193, 140):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(0, 182, 193, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(0, 123, 135, 232):GetVec4() -- 04
		colors[clr.TitleBgActive]          = imgui.ImColor(0, 123, 138, 232):GetVec4() -- 04
		colors[clr.Button]                 = imgui.ImColor(0, 172, 183, 163):GetVec4() -- 04
		colors[clr.ButtonHovered]          = imgui.ImColor(0, 182, 193, 100):GetVec4() -- 04
		colors[clr.ButtonActive]           = imgui.ImColor(0, 122, 133, 100):GetVec4() -- 04
	elseif id == 4 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(0, 0, 0, 230):GetVec4()
		colors[clr.FrameBg]    	 		  = imgui.ImColor(40, 40, 40, 100):GetVec4()
		colors[clr.FrameBgHovered]         = imgui.ImColor(95, 95, 95, 140):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(95, 95, 95, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(7, 7, 7, 232):GetVec4()
		colors[clr.TitleBgActive]          = imgui.ImColor(7, 7, 7, 232):GetVec4()
		colors[clr.Button]                 = imgui.ImColor(30, 30, 30, 163):GetVec4()
		colors[clr.ButtonHovered]          = imgui.ImColor(95, 95, 95, 100):GetVec4()
		colors[clr.ButtonActive]           = imgui.ImColor(50, 50, 50, 100):GetVec4()
	elseif id == 5 then
		colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.Text]                   = ImVec4(0.9, 0.9, 0.9, 1.00)
		colors[clr.WindowBg]               = imgui.ImColor(3, 3, 0, 230):GetVec4()
		colors[clr.FrameBg]    	 		  = imgui.ImColor(210, 210, 0, 100):GetVec4()
		colors[clr.FrameBgHovered]         = imgui.ImColor(210, 210, 0, 140):GetVec4()
		colors[clr.FrameBgActive]          = imgui.ImColor(210, 210, 0, 70):GetVec4()
		colors[clr.TitleBg]                = imgui.ImColor(120, 120, 0, 232):GetVec4()
		colors[clr.TitleBgActive]          = imgui.ImColor(120, 120, 0, 232):GetVec4()
		colors[clr.Button]                 = imgui.ImColor(180, 180, 0, 163):GetVec4()
		colors[clr.ButtonHovered]          = imgui.ImColor(180, 180, 0, 100):GetVec4()
		colors[clr.ButtonActive]           = imgui.ImColor(100, 100, 0, 100):GetVec4()
	elseif id == 6 then
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 7 then
	 colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
      colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
      colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
      colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
      colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
      colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
      colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
      colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
      colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
      colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
      colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
      colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
      colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
      colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
      colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
      colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
      colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
      colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
      colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
      colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
      colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
      colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
      colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
      colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
      colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
      colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
      colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
      colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
      colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
      colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
      colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
      colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
      colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
      colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
      colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
	  elseif id == 8 then
	  colors[clr.Text] = ImVec4(0.860, 0.930, 0.890, 0.78)
  colors[clr.TextDisabled] = ImVec4(0.860, 0.930, 0.890, 0.28)
  colors[clr.WindowBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
  colors[clr.ChildWindowBg] = ImVec4(0.200, 0.220, 0.270, 0.58)
  colors[clr.PopupBg] = ImVec4(0.200, 0.220, 0.270, 0.9)
  colors[clr.Border] = ImVec4(0.31, 0.31, 1.00, 0.00)
  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
  colors[clr.FrameBgHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
  colors[clr.FrameBgActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.TitleBg] = ImVec4(0.232, 0.201, 0.271, 1.00)
  colors[clr.TitleBgActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
  colors[clr.TitleBgCollapsed] = ImVec4(0.200, 0.220, 0.270, 0.75)
  colors[clr.MenuBarBg] = ImVec4(0.200, 0.220, 0.270, 0.47)
  colors[clr.ScrollbarBg] = ImVec4(0.200, 0.220, 0.270, 1.00)
  colors[clr.ScrollbarGrab] = ImVec4(0.09, 0.15, 0.1, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.CheckMark] = ImVec4(0.71, 0.22, 0.27, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.47, 0.77, 0.83, 0.14)
  colors[clr.SliderGrabActive] = ImVec4(0.71, 0.22, 0.27, 1.00)
  colors[clr.Button] = ImVec4(0.47, 0.77, 0.83, 0.14)
  colors[clr.ButtonHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
  colors[clr.ButtonActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.Header] = ImVec4(0.455, 0.198, 0.301, 0.76)
  colors[clr.HeaderHovered] = ImVec4(0.455, 0.198, 0.301, 0.86)
  colors[clr.HeaderActive] = ImVec4(0.502, 0.075, 0.256, 1.00)
  colors[clr.ResizeGrip] = ImVec4(0.47, 0.77, 0.83, 0.04)
  colors[clr.ResizeGripHovered] = ImVec4(0.455, 0.198, 0.301, 0.78)
  colors[clr.ResizeGripActive] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.PlotLines] = ImVec4(0.860, 0.930, 0.890, 0.63)
  colors[clr.PlotLinesHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.860, 0.930, 0.890, 0.63)
  colors[clr.PlotHistogramHovered] = ImVec4(0.455, 0.198, 0.301, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.455, 0.198, 0.301, 0.43)
  colors[clr.ModalWindowDarkening] = ImVec4(0.200, 0.220, 0.270, 0.73)
  elseif id == 9 then
    colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 0.95)
  colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
  colors[clr.ChildWindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
  colors[clr.PopupBg] = ImVec4(0.05, 0.05, 0.05, 0.94)
  colors[clr.Border] = ImVec4(0.53, 0.53, 0.53, 0.46)
  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ImVec4(0.00, 0.00, 0.00, 0.85)
  colors[clr.FrameBgHovered] = ImVec4(0.22, 0.22, 0.22, 0.40)
  colors[clr.FrameBgActive] = ImVec4(0.16, 0.16, 0.16, 0.53)
  colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
  colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.00, 1.00)
  colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.MenuBarBg] = ImVec4(0.12, 0.12, 0.12, 1.00)
  colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
  colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.48, 0.48, 0.48, 1.00)
  colors[clr.ComboBg] = ImVec4(0.24, 0.24, 0.24, 0.99)
  colors[clr.CheckMark] = ImVec4(0.79, 0.79, 0.79, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.48, 0.47, 0.47, 0.91)
  colors[clr.SliderGrabActive] = ImVec4(0.56, 0.55, 0.55, 0.62)
  colors[clr.Button] = ImVec4(0.50, 0.50, 0.50, 0.63)
  colors[clr.ButtonHovered] = ImVec4(0.67, 0.67, 0.68, 0.63)
  colors[clr.ButtonActive] = ImVec4(0.26, 0.26, 0.26, 0.63)
  colors[clr.Header] = ImVec4(0.54, 0.54, 0.54, 0.58)
  colors[clr.HeaderHovered] = ImVec4(0.64, 0.65, 0.65, 0.80)
  colors[clr.HeaderActive] = ImVec4(0.25, 0.25, 0.25, 0.80)
  colors[clr.Separator] = ImVec4(0.58, 0.58, 0.58, 0.50)
  colors[clr.SeparatorHovered] = ImVec4(0.81, 0.81, 0.81, 0.64)
  colors[clr.SeparatorActive] = ImVec4(0.81, 0.81, 0.81, 0.64)
  colors[clr.ResizeGrip] = ImVec4(0.87, 0.87, 0.87, 0.53)
  colors[clr.ResizeGripHovered] = ImVec4(0.87, 0.87, 0.87, 0.74)
  colors[clr.ResizeGripActive] = ImVec4(0.87, 0.87, 0.87, 0.74)
  colors[clr.CloseButton] = ImVec4(0.45, 0.45, 0.45, 0.50)
  colors[clr.CloseButtonHovered] = ImVec4(0.70, 0.70, 0.90, 0.60)
  colors[clr.CloseButtonActive] = ImVec4(0.70, 0.70, 0.70, 1.00)
  colors[clr.PlotLines] = ImVec4(0.68, 0.68, 0.68, 1.00)
  colors[clr.PlotLinesHovered] = ImVec4(0.68, 0.68, 0.68, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.90, 0.77, 0.33, 1.00)
  colors[clr.PlotHistogramHovered] = ImVec4(0.87, 0.55, 0.08, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.47, 0.60, 0.76, 0.47)
  colors[clr.ModalWindowDarkening] = ImVec4(0.88, 0.88, 0.88, 0.35)
  elseif id == 10 then
    colors[clr.Text]                 = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.44, 0.44, 0.44, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.06, 0.06, 0.06, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.81, 0.83, 0.81, 1.00)
    colors[clr.CheckMark]            = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.Button]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.Header]               = ImVec4(0.51, 0.36, 0.15, 1.00)
    colors[clr.HeaderHovered]        = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.HeaderActive]         = ImVec4(0.93, 0.65, 0.14, 1.00)
    colors[clr.Separator]            = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.21, 0.21, 0.21, 1.00)
    colors[clr.ResizeGripHovered]    = ImVec4(0.91, 0.64, 0.13, 1.00)
    colors[clr.ResizeGripActive]     = ImVec4(0.78, 0.55, 0.21, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.47, 0.47, 0.47, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 11 then
	 colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.96)
    colors[clr.Border]                 = ImVec4(0.73, 0.36, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.65, 0.32, 0.00, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.15, 0.11, 0.09, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.15, 0.11, 0.09, 0.51)
    colors[clr.MenuBarBg]              = ImVec4(0.62, 0.31, 0.00, 1.00)
    colors[clr.CheckMark]              = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.84, 0.41, 0.00, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.49, 0.00, 1.00)
    colors[clr.Button]                 = ImVec4(0.73, 0.36, 0.00, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.73, 0.36, 0.00, 1.00)
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.50, 0.00, 1.00)
    colors[clr.Header]                 = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.70, 0.35, 0.01, 1.00)
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.49, 0.24, 0.00, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.49, 0.24, 0.00, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.48, 0.23, 0.00, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.78, 0.38, 0.00, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.49, 0.00, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.83, 0.41, 0.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.99, 0.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.93, 0.46, 0.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.33, 0.33, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.39, 0.39, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.48, 0.48, 0.48, 1.00)
    colors[clr.CloseButton]            = colors[clr.FrameBg]
    colors[clr.CloseButtonHovered]     = colors[clr.FrameBgHovered]
    colors[clr.CloseButtonActive]      = colors[clr.FrameBgActive]
	elseif id == 12 then
	colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
	elseif id == 13 then
	 colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
    colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
    colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
    colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
    colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
    colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
    colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
    colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
    colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
    colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
    colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
    colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
    colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
    colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
	elseif id == 14 then
	 colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.00, 0.00, 0.00, 0.94)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.26, 0.37, 0.98, 0.54)
    colors[clr.FrameBgHovered]       = ImVec4(0.33, 0.33, 0.93, 0.40)
    colors[clr.FrameBgActive]        = ImVec4(0.44, 0.44, 0.99, 0.67)
    colors[clr.TitleBg]              = ImVec4(0.30, 0.33, 0.95, 0.67)
    colors[clr.TitleBgActive]        = ImVec4(0.00, 0.16, 1.00, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.22, 0.19, 1.00, 0.67)
    colors[clr.MenuBarBg]            = ImVec4(0.39, 0.56, 1.00, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.30, 0.41, 0.99, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.52, 0.52, 0.97, 1.00)
    colors[clr.Button]               = ImVec4(0.11, 0.13, 0.93, 0.65)
    colors[clr.ButtonHovered]        = ImVec4(0.41, 0.57, 1.00, 0.65)
    colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.Header]               = ImVec4(0.15, 0.19, 1.00, 0.54)
    colors[clr.HeaderHovered]        = ImVec4(0.03, 0.24, 0.57, 0.65)
    colors[clr.HeaderActive]         = ImVec4(0.36, 0.40, 0.95, 0.00)
    colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.SeparatorHovered]     = ImVec4(0.20, 0.42, 0.98, 0.54)
    colors[clr.SeparatorActive]      = ImVec4(0.20, 0.40, 0.93, 0.54)
    colors[clr.ResizeGrip]           = ImVec4(0.01, 0.17, 1.00, 0.54)
    colors[clr.ResizeGripHovered]    = ImVec4(0.21, 0.51, 0.98, 0.45)
    colors[clr.ResizeGripActive]     = ImVec4(0.04, 0.55, 0.95, 0.66)
    colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.10, 0.21, 0.98, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.02, 0.26, 1.00, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(0.18, 0.15, 1.00, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 15 then
	 colors[clr.Text]                 = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.22, 0.22, 0.22, 1.00)
    colors[clr.WindowBg]             = ImVec4(1.00, 1.00, 1.00, 0.71)
    colors[clr.ChildWindowBg]        = ImVec4(0.92, 0.92, 0.92, 0.00)
    colors[clr.PopupBg]              = ImVec4(1.00, 1.00, 1.00, 0.94)
    colors[clr.Border]               = ImVec4(1.00, 1.00, 1.00, 0.50)
    colors[clr.BorderShadow]         = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.77, 0.49, 0.66, 0.54)
    colors[clr.FrameBgHovered]       = ImVec4(1.00, 1.00, 1.00, 0.40)
    colors[clr.FrameBgActive]        = ImVec4(1.00, 1.00, 1.00, 0.67)
    colors[clr.TitleBg]              = ImVec4(0.76, 0.51, 0.66, 0.71)
    colors[clr.TitleBgActive]        = ImVec4(0.97, 0.74, 0.88, 0.74)
    colors[clr.TitleBgCollapsed]     = ImVec4(1.00, 1.00, 1.00, 0.67)
    colors[clr.MenuBarBg]            = ImVec4(1.00, 1.00, 1.00, 0.54)
    colors[clr.ScrollbarBg]          = ImVec4(0.81, 0.81, 0.81, 0.54)
    colors[clr.ScrollbarGrab]        = ImVec4(0.78, 0.28, 0.58, 0.13)
    colors[clr.ScrollbarGrabHovered] = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.71, 0.39, 0.39, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.76, 0.51, 0.66, 0.46)
    colors[clr.Button]               = ImVec4(0.78, 0.28, 0.58, 0.54)
    colors[clr.ButtonHovered]        = ImVec4(0.77, 0.52, 0.67, 0.54)
    colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.Header]               = ImVec4(0.78, 0.28, 0.58, 0.54)
    colors[clr.HeaderHovered]        = ImVec4(0.78, 0.28, 0.58, 0.25)
    colors[clr.HeaderActive]         = ImVec4(0.79, 0.04, 0.48, 0.63)
    colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.SeparatorHovered]     = ImVec4(0.79, 0.44, 0.65, 0.64)
    colors[clr.SeparatorActive]      = ImVec4(0.79, 0.17, 0.54, 0.77)
    colors[clr.ResizeGrip]           = ImVec4(0.87, 0.36, 0.66, 0.54)
    colors[clr.ResizeGripHovered]    = ImVec4(0.76, 0.51, 0.66, 0.46)
    colors[clr.ResizeGripActive]     = ImVec4(0.76, 0.51, 0.66, 0.46)
    colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.76, 0.46, 0.64, 0.71)
    colors[clr.CloseButtonActive]    = ImVec4(0.78, 0.28, 0.58, 0.79)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(0.92, 0.92, 0.92, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 16 then
	   colors[clr.Text]                 = ImVec4(0.83, 0.83, 0.83, 1.00)
                colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.73, 1.00)
                colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
                colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
                colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
                colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
                colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
                colors[clr.FrameBg]              = ImVec4(0.43, 0.71, 0.39, 0.54)
                colors[clr.FrameBgHovered]       = ImVec4(0.66, 0.84, 0.66, 0.40)
                colors[clr.FrameBgActive]        = ImVec4(0.68, 0.84, 0.66, 0.67)
                colors[clr.TitleBg]              = ImVec4(0.24, 0.47, 0.22, 0.67)
                colors[clr.TitleBgActive]        = ImVec4(0.28, 0.47, 0.22, 1.00)
                colors[clr.TitleBgCollapsed]     = ImVec4(0.26, 0.47, 0.22, 0.67)
                colors[clr.MenuBarBg]            = ImVec4(0.18, 0.34, 0.16, 1.00)
                colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
                colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
                colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
                colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
                colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
                colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
                colors[clr.SliderGrab]           = ImVec4(0.45, 0.71, 0.39, 1.00)
                colors[clr.SliderGrabActive]     = ImVec4(0.70, 0.84, 0.66, 1.00)
                colors[clr.Button]               = ImVec4(0.27, 0.47, 0.22, 0.65)
                colors[clr.ButtonHovered]        = ImVec4(0.39, 0.71, 0.39, 0.65)
                colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
                colors[clr.Header]               = ImVec4(0.39, 0.71, 0.41, 0.54)
                colors[clr.HeaderHovered]        = ImVec4(0.68, 0.84, 0.66, 0.65)
                colors[clr.HeaderActive]         = ImVec4(0.66, 0.84, 0.66, 0.00)
                colors[clr.Separator]            = ImVec4(0.43, 0.50, 0.43, 0.50)
                colors[clr.SeparatorHovered]     = ImVec4(0.39, 0.71, 0.42, 0.54)
                colors[clr.SeparatorActive]      = ImVec4(0.43, 0.71, 0.39, 0.54)
                colors[clr.ResizeGrip]           = ImVec4(0.46, 0.71, 0.39, 0.54)
                colors[clr.ResizeGripHovered]    = ImVec4(0.66, 0.84, 0.66, 0.66)
                colors[clr.ResizeGripActive]     = ImVec4(0.67, 0.84, 0.66, 0.66)
                colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
                colors[clr.CloseButtonHovered]   = ImVec4(0.42, 0.98, 0.36, 1.00)
                colors[clr.CloseButtonActive]    = ImVec4(0.38, 0.98, 0.36, 1.00)
                colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
                colors[clr.PlotLinesHovered]     = ImVec4(0.52, 1.00, 0.35, 1.00)
                colors[clr.PlotHistogram]        = ImVec4(0.16, 0.90, 0.00, 1.00)
                colors[clr.PlotHistogramHovered] = ImVec4(0.13, 1.00, 0.00, 1.00)
                colors[clr.TextSelectedBg]       = ImVec4(0.30, 0.98, 0.26, 0.35)
                colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
				elseif id == 17 then
				 colors[clr.FrameBg]                = ImVec4(0.76, 0.6, 0, 0.74)--
    colors[clr.FrameBgHovered]         = ImVec4(0.84, 0.68, 0, 0.83)--
    colors[clr.FrameBgActive]          = ImVec4(0.92, 0.77, 0, 0.87)--
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)--
    colors[clr.TitleBgActive]          = ImVec4(0.92, 0.77, 0, 0.85)--
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)--
    colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Button]                 = ImVec4(0.76, 0.6, 0, 0.85)
    colors[clr.ButtonHovered]          = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Header]                 = ImVec4(0.84, 0.68, 0, 0.75)
    colors[clr.HeaderHovered]          = ImVec4(0.84, 0.68, 0, 0.90)
    colors[clr.HeaderActive]           = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.84, 0.68, 0, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.76, 0.6, 0, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.84, 0.68, 0, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.92, 0.77, 0, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.52, 0.34, 0, 0.85)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 18 then
	 colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.PopupBg]              = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.FrameBgHovered]       = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.MenuBarBg]            = ImVec4(0.12, 0.05, 0.06, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.ScrollbarGrab]        = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.14, 0.06, 0.07, 1.00)
    colors[clr.Button]               = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ButtonHovered]        = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.Header]               = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.HeaderHovered]        = ImVec4(1.00, 0.15, 0.29, 0.75)
    colors[clr.HeaderActive]         = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.Separator]            = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.SeparatorHovered]     = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.SeparatorActive]      = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ResizeGrip]           = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.ResizeGripHovered]    = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.ResizeGripActive]     = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.CloseButton]          = ImVec4(0.25, 0.01, 0.04, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.15, 0.29, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 19 then
	 colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
    colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
    colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
    colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
    colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	end
end
setInterfaceStyle(mainIni.settings.style)

local styles = {u8"Красный", u8"Фиолетовый", u8"Зеленый", u8"Голубой", u8"Черный", u8"Желтый", u8"Синий", u8"Серая", u8"Вишневая", u8"Светло-Серая", u8"Темно-Оранжевая", u8"Оранжевая", u8"Темно-Красная", u8"Темно-Зеленая", u8"Ярко-Синяя", u8"Розовая", u8"Темно-Зеленая 2", u8"Жетлая 2", u8"Ярко-Красная", u8"Пурпурная"}

local upd = [[
27.05.2021 | 1.0 | Релиз скрипта.

1.Разработка скрипта


]]


local fontsize = nil
function imgui.BeforeDrawFrame()
    if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end

text_update = ""

function imgui.OnDrawFrame()

   if main_window.v then
	local btn_size = imgui.ImVec2(-0.1, 0)
		imgui.LockPlayer = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/2, sh/2.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Evolve Helper 1.0 | Nick: "..sampGetPlayerNickname(id).. " | Id: "..id, main_window)
	
	
	  imgui.BeginChild('##Select Setting', imgui.ImVec2(sw/8.4, sh/2.79), true)
        if imgui.Selectable(u8"Настройки", beginchild == 1) then beginchild = 1 end
    
        if imgui.Selectable(u8"Лог обновлений", beginchild == 2) then beginchild = 2 end
      
        if imgui.Selectable(u8"Характеристики ПК", beginchild == 3) then beginchild = 3 end
		
        if imgui.Selectable(u8"Информация", beginchild == 4) then beginchild = 4 end
      
        imgui.EndChild()
		imgui.SameLine()
		
		if beginchild == 1 then
		imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 if imgui.Button(u8"Перезагрузить") then
			sampAddChatMessage(tag .. "Скрипт перезагружается.")
			thisScript():reload()
		end
		
	imgui.SameLine()
	if imgui.Button(u8"Отключить") then
			lua_thread.create(function ()
			imgui.Process = false
			wait(200)
			imgui.ShowCursor = false
		thisScript():unload()
	end)
end

imgui.SameLine() 
if imgui.Button(u8"Сбросить настройки") then
mainIni.settings.style = 0
mainIni.settings.password = ""
save()
thisScript():reload()
end


imgui.SameLine() 
if imgui.Button(u8"Очистить чат") then
ClearChat()
end

if imgui.Checkbox(u8"Автологин", autologin) then
mainIni.settings.autologin = autologin.v
save()
end
imgui.PushItemWidth(190)

if autologin.v then
imgui.SameLine()
if imgui.InputText(u8"Пароль от акаунта", password) then
mainIni.settings.password = password.v
save()
end
end

if imgui.Combo(u8"Style Edit", style, styles) then
			mainIni.settings.style = style.v
			setInterfaceStyle(mainIni.settings.style)
			save()
		end


		imgui.EndChild()
		end
		
		
		if beginchild == 2 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 imgui.TextWrapped(u8(upd))
		
		imgui.EndChild()
		end
		
        

		if beginchild == 3 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		 -- Column 1
		  imgui.Text(u8"Память:")
		  imgui.Text("")
		for i, k in ipairs{'C', 'D'} do
  local free, all = getHardDiskMemory(k)
  imgui.Text(u8'Диcк '..k..':')
  imgui.Text(u8'- Свободно: '..('%.02f'):format( free / 1024 / 1024 ).. u8(' ГБ'))
  imgui.Text(u8'- Занято: '..('%.02f'):format( ( all / 1024 / 1024 ) - ( free / 1024 / 1024 ) ).. u8(' ГБ'))
  imgui.Text(u8'- Всего: '..('%.02f'):format( all / 1024 / 1024 ).. u8(' ГБ'))
end
-- column 2

local ffi = require("ffi")
local qwords = ffi.typeof("uint64_t[?]")
local dwords = ffi.typeof("uint32_t *")
local cpuid_EAX_EDX = ffi.cast("__cdecl uint64_t (*)(uint32_t)", "\x53\x0F\xA2\x5B\xC3")
local cpuid_EBX_ECX = ffi.cast("__cdecl uint64_t (*)(uint32_t)", "\x53\x0F\xA2\x91\x92\x93\x5B\xC3")

local function cpuid(n)
   local arr = ffi.cast(dwords, qwords(2, cpuid_EAX_EDX(n), cpuid_EBX_ECX(n)))
   return ffi.string(arr, 4), ffi.string(arr + 2, 4), ffi.string(arr + 3, 4), ffi.string(arr + 1, 4)
end

local s1 = ""
for n = 0x80000002, 0x80000004 do
   local eax, ebx, ecx, edx = cpuid(n)
   s1 = s1..eax..ebx..ecx..edx
end
s1 = s1:gsub("^%s+", ""):gsub("%z+$", "")

local eax, ebx, ecx, edx = cpuid(0)
local s2 = ebx..edx..ecx
s2 = s2:gsub("^%s+", ""):gsub("%z+$", "")

imgui.Text("")
imgui.Text(u8"Процесор:")
imgui.Text("")
imgui.Text(u8(s1.." "..s2))
		
		imgui.EndChild()
		end
		
		
		
	
		
		if beginchild == 4 then
		  imgui.BeginChild("##Standart", imgui.ImVec2(sw/2.75, sh/2.79), true)
		  imgui.CenterText(u8''..script.this.name.. " | "..script.this.version)
		  

		  
		 if imgui.Button(u8"Группа скрипта") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/coding.lua_yamada"))
end
		  
		 if imgui.Button(u8"Автор скрипта") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/scr_vrd"))
end

 if imgui.Button(u8"Поддержать разработку скрипта") then
    os.execute(('explorer.exe "%s"'):format("https://www.donationalerts.com/r/dashok_"))
end

 if imgui.Button(u8"Написать идею для разработки скрипта") then
    os.execute(('explorer.exe "%s"'):format("https://vk.com/topic-197475953_47698647"))
end
		 
		 

 imgui.Text(u8'Если ваш Nick или ваш Id не соответствуют оригинальному... \n ...то нажмите на кнопку "Перезагрузить" во вкладке "Настройки"')		 

		
		imgui.EndChild()
		end
		
		
		
		imgui.End()
		end
	
	
		
	

	
	if window_update.v then
	local btn_size = imgui.ImVec2(-0.1, 0)
		imgui.LockPlayer = false
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
		imgui.SetNextWindowSize(imgui.ImVec2(sw/2, sh/2.5), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Проверка обновления", window_update)
		 imgui.PushFont(fontsize)
        imgui.CenterText(u8"Идет проверка обновления.")
		imgui.Separator()
		imgui.CenterText(u8(text_update))
    imgui.PopFont()
	
	imgui.End()
	end
	end

function onReceiveRpc(id,bitStream)
    if id == 61 then
        dialogId = raknetBitStreamReadInt16(bitStream)
        style = raknetBitStreamReadInt8(bitStream)
        str = raknetBitStreamReadInt8(bitStream)
        title = raknetBitStreamReadString(bitStream, str)
        if title:find("Авторизация") and autologin.v then
		sampSendDialogResponse(dialogId, 1, 0, u8:decode(password.v)) 
		return false
		end
    end
	
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        if not sampIsDialogActive() then
            showCursor(false, false)
        end
  
        if not noErrorDialog then
        	sampShowDialog(131313, "{E3294D}[ Evolve Helper ] Скрипт завершил свою работу", [[
{E3294D}                                                           Что делать если не работает скрипт?{FFC973}

1. Скрипт должен быть установлен строго по инструкции.
 - Даже если у вас ранее были установлены какие-то файлы вы должны их обязательно заменить.

2. Если вы устанавили и запустили скрипт впервые, то скорее всего он просто скачал
 нужные ему библиотеки. От вас лиш требуется нажать CTRL + R, в 90 процентах случаях
 это помогает

3. Если у вас установлен MVD Helper, то вам нужно его удалить, он использует старую
 версию MonnLoader 0.25, а данный скрипт работает на последней стабильной версии 0.26
 Удалите MVD Helper и повтороно установите Bank Helper

4. Возможно у вас установлены конфликтующие программы
 - Анти-стиллеры
 - Анти-вирусы
 - Файлы Samp Addon
 - Другие LUA/CLEO/SF/ASI

5. Для работы скрипта нужны следующие файлы:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26
 - Библиотеки (lib)

6. Если данный скрипт работал ранее и вдруг появилась эта ошибка, то попробуйте удалить настройки
- В папке moonloader > Удаляем папку Config
- В папке moonloader > Удаляем папку EvolveHelper

7. Если данные действия не помогли, то попробуйте установить скрипт на другую сборку
]], "Понял", _, 0)
        	setClipboardText('')
	    end
    end
end

function ClearChat()
    local memory = require "memory"
    memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

ffi = require 'ffi'
ffi.cdef[[
typedef uint32_t DWORD;

typedef union _ULARGE_INTEGER {
  struct {
    DWORD LowPart;
    DWORD HighPart;
  };
  struct {
    DWORD LowPart;
    DWORD HighPart;
  } u;
  unsigned __int64 QuadPart;
} ULARGE_INTEGER, *PULARGE_INTEGER;

bool __stdcall GetDiskFreeSpaceExA(
  char* lpDirectoryName,
  int lpFreeBytesAvailable,
  int lpTotalNumberOfBytes,
  int lpTotalNumberOfFreeBytes
);
]]

function getHardDiskMemory(disk)
  local free_p = ffi.cast('intptr_t', ffi.cast('ULARGE_INTEGER*', ffi.new('ULARGE_INTEGER', {})))
  local all_p = ffi.cast('intptr_t', ffi.cast('ULARGE_INTEGER*', ffi.new('ULARGE_INTEGER', {})))
  ffi.C.GetDiskFreeSpaceExA(ffi.cast('char*', disk..':/'), free_p, all_p, 0)

  local free = ffi.new('DWORD[1]', ffi.cast('ULARGE_INTEGER*', free_p).QuadPart / 1024)
  local all = ffi.new('DWORD[1]', ffi.cast('ULARGE_INTEGER*', all_p).QuadPart / 1024)
  return free[0], all[0]
end

function save()
inicfg.save(mainIni, directIni)
end


function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end



function main()
	 if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

	result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	 id_player = sampGetPlayerIdByCharHandle(PLAYER_PED)
	
	imgui.Process = false
	
	
	imgui.ShowCursor = false
   sampAddChatMessage(tag .. "Идет проверка сервера.")
	wait(1000)
	  if not checkServer(select(1, sampGetCurrentServerAddress())) then
		sampAddChatMessage(tag .. "Скрипт работает только на серверах Evolve RP!")
		wait(1000)
		thisScript():unload()
	end
	 wait(1000)
	if not doesDirectoryExist(getWorkingDirectory() .. "/config") then
       sampAddChatMessage(tag .. "У вас отсутствует папка config, создаю папку.")
		createDirectory(getWorkingDirectory() .. "/config")
		wait(600)
		sampAddChatMessage(tag .. "Папка создана.")
end
	
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/EvolveHelper") then
	    sampAddChatMessage(tag .. "Создаю папку EvolveHelper")
		createDirectory(getWorkingDirectory() .. "/config/EvolveHelper")
		wait(300)
		 sampAddChatMessage(tag .. "Папка EvolveHelper создана.")
	end
	
	window_update.v = true
	text_update = "Проверка..."
	func_update()
	
	 sampRegisterChatCommand('ehelp', function() 
	 main_window.v = not main_window.v
	 end)
     

	
	lua_thread.create(function()
	while true do
		wait(0)
	
	
	
   imgui.Process = main_window.v or window_update.v
	
	if wasKeyPressed(122) and not sampIsChatInputActive() and not sampIsDialogActive() then
	   main_window.v = not main_window.v	
	end
	
	end
	
	
	end)
end

function func_update()
lua_thread.create(function()
wait(3000)
update()
wait(5000)
window_update.v = false
end)

end
function update()
  local fpath = os.getenv('TEMP') .. '\\testing_version.json' -- куда будет качаться наш файлик для сравнения версии
  downloadUrlToFile('https://raw.githubusercontent.com/Yamala2/Lua-Samp/main/update.json', fpath, function(id, status, p1, p2) -- ссылку на ваш гитхаб где есть строчки которые я ввёл в теме или любой другой сайт
    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
    local f = io.open(fpath, 'r') -- открывает файл
    if f then
      local info = decodeJson(f:read('*a')) -- читает
      updatelink = info.updateurl
      if info and info.latest then
        version = tonumber(info.latest) -- переводит версию в число
        if version > tonumber(thisScript().version) then -- если версия больше чем версия установленная то...
          lua_thread.create(goupdate) -- апдейт
        else -- если меньше, то
          update = false -- не даём обновиться 
          text_update = 'У вас и так последняя версия скрипта!\nОтменяю обновление.'
        end
      end
    end
  end
end)
end
--скачивание актуальной версии
function goupdate()
text_update = 'Обнаружено новое обновление. Обновляюсь...\n Текущая версия: '..thisScript().version..". Новая версия: "..version
wait(3000)
downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- качает ваш файлик с latest version
  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
  wait(3000)
  text_update = 'Обновление завершено! Ознакомится с ним можно в меню скрипта: \n /event > Лог обновлений'
  wait(4000)
  thisScript():reload()
end
end)
end

function ShowMessage(text, title, style)
    ffi.cdef [[
        int MessageBoxA(
            void* hWnd,
            const char* lpText,
            const char* lpCaption,
            unsigned int uType
        );
    ]]
    local hwnd = ffi.cast('void*', readMemory(0x00C8CF88, 4, false))
    ffi.C.MessageBoxA(hwnd, text,  title, style and (style + 0x50000) or 0x50000)
end