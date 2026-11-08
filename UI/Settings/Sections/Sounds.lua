-- Settings: Sounds (UI/Settings/Page.lua lists the sections; the controls
-- are UI/Settings/Kit.lua's): the foe alert.

local addonName, ns = ...

local Style = ns.Style
local FONT = Style.FONT
local SettingsUI = ns.UI.Settings
local Kit = SettingsUI.Kit
local Switch = Kit.Switch
local INDENT = Kit.INDENT

-- The foe alert (Core/Reunions.lua), with a sample to hear what it sounds
-- like before switching it on.
local function BuildSounds(pane, c)
    local page = SettingsUI.page

    c:Heading(ns.L("World PvP"))
    page.foeAlert = Switch(c, ns.L("Sound a raid warning when a foe comes into view"), "foeAlert", nil, nil,
        ns.L("Tag someone foe in your diary, e.g. for World PVP."))

    page.foeSample = Style.Link(pane, FONT.body, function() ns.UI.Toast.PlayFoeAlert() end)
    page.foeSample:SetText(ns.L("Hear it"))
    c:Place(page.foeSample, 18, INDENT)
end

SettingsUI.RegisterSection("sounds", { order = 30, label = ns.L("Sounds"),
    about = ns.L("A warning when a foe comes into view"), build = BuildSounds })
