---------------------------------------------------------
-- Addon declaration
HandyNotes_Lorewalkers = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_Lorewalkers","AceEvent-3.0","AceHook-3.0")
local HL = HandyNotes_Lorewalkers
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")
-- local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_Lorewalkers", true)

local debugf = tekDebug and tekDebug:GetFrame("Lorewalkers")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end end

---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
    profile = {
        completed = false,
        icon_scale = 1.4,
        icon_alpha = 0.8,
    },
}

---------------------------------------------------------
-- Localize some globals
local next = next
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip
local HandyNotes = HandyNotes
local GetAchievementInfo = GetAchievementInfo
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo

---------------------------------------------------------
-- Constants

local get_icon
do
    local icons, backup_icon

    get_icon = function(achievement)
        if not icons then
            local function setupLandmarkIcon(left, right, top, bottom)
                return {
                    icon = [[Interface\Minimap\POIIcons]],
                    tCoordLeft = left,
                    tCoordRight = right,
                    tCoordTop = top,
                    tCoordBottom = bottom,
                }
            end
            icons = {
                [6856] = setupLandmarkIcon(GetPOITextureCoords(111)), -- Ballad of Liu Lang
                [6716] = setupLandmarkIcon(GetPOITextureCoords(112)), -- Between a Saurok and a Hard Place
                [6846] = setupLandmarkIcon(GetPOITextureCoords(113)), -- Fish Tails
                [6857] = setupLandmarkIcon(GetPOITextureCoords(114)), -- Heart of the Mantid Swarm
                [6850] = setupLandmarkIcon(GetPOITextureCoords(115)), -- Hozen in the Mist
                [7230] = setupLandmarkIcon(GetPOITextureCoords(116)), -- Legend of the Brewfathers
                [6754] = setupLandmarkIcon(GetPOITextureCoords(117)), -- The Dark Heart of the Mogu
                [6855] = setupLandmarkIcon(GetPOITextureCoords(118)), -- The Seven Burdens of Shaohao
                [6847] = setupLandmarkIcon(GetPOITextureCoords(119)), -- The Song of the Yaungol
                [6858] = setupLandmarkIcon(GetPOITextureCoords(120)), -- What is Worth Fighting For
                [8049] = setupLandmarkIcon(GetPOITextureCoords(112)), -- Zandalari Prophecy
                [8050] = setupLandmarkIcon(GetPOITextureCoords(113)), -- Rumbles of Thunder
                [8051] = setupLandmarkIcon(GetPOITextureCoords(114)), -- Gods and Monsters
            }
            backup_icon = setupLandmarkIcon(GetPOITextureCoords(111)) -- fallback
        end
        return icons[achievement] or backup_icon
    end
end

local points = {
    -- [mapfile] = { [coord] = { [achievement_id], [criteria_index] } }
    ["KunLaiSummit"] = {
        [71726302] = {6847, 3}, -- The Song of the Yaungol, Yaungoil
        [40904250] = {6855, 7}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 7
        [77559533] = {6716, 2}, -- Between a Saurok and a Hard Place, The Defiant
        [67764833] = {6855, 6}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 6
        [74488355] = {6846, 4}, -- Fish Tails, Role Call
        [44705237] = {7230, 3}, -- Legend of the Brewfathers, Ren Yun the Blind
        [50307930] = {6847, 1}, -- The Song of the Yaungol, Yaungol Tactics
        [50604805] = {6754, 1}, -- The Dark Heart of the Mogu, Valley of the Emperors
        [63044082] = {6858, 5}, -- What is Worth Fighting For, Victory in Kun-Lai
        [43825119] = {6855, 2}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 2
        [45766190] = {6850, 4}, -- Hozen in the Mist, The Hozen Ravage
        -- [53004650] = {6754, 1, "Entrance"}, -- The Dark Heart of the Mogu, Valley of the Emperors
    },
    ["TownlongWastes"] = {
        [84087286] = {6847, 4}, -- The Song of the Yaungol, Trapped in a Strange Land
        [37746291] = {6855, 5}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 5
        [65505010] = {6847, 2}, -- The Song of the Yaungol, Dominance
    },
    ["ValleyoftheFourWinds"] = {
        [34576387] = {6856, 3}, -- Ballad of Liu Lang, The Wandering Widow
        [20255586] = {6856, 1}, -- Ballad of Liu Lang, The Birthplace of Liu Lang
        [83192118] = {6850, 3}, -- Hozen in the Mist, Embracing the Passions
        [18843170] = {6858, 1}, -- What is Worth Fighting For, Pandaren Fighting Tactics
        [61223469] = {6846, 2}, -- Fish Tails, Waterspeakers
        [55094713] = {6856, 2}, -- Ballad of Liu Lang, A Most Famous Bill of Sale
    },
    ["DreadWastes"] = {
        [67506090] = {6716, 3}, -- Between a Saurok and a Hard Place, The Deserters
        [35533261] = {6857, 4}, -- Heart of the Mantid Swarm, The Empress
        -- [53611548] = {6857, 3, "Entrance"}, -- Heart of the Mantid Swarm, Amber
        [52521006] = {6857, 3}, -- Heart of the Mantid Swarm, Amber
        [48383285] = {6857, 1}, -- Heart of the Mantid Swarm, Cycle of the Mantid
        [59905470] = {6857, 2}, -- Heart of the Mantid Swarm, Mantid Society
    },
    ["Krasarang"] = {
        [50943169] = {6754, 2}, -- The Dark Heart of the Mogu, The Lost Dynasty
        [32782941] = {6716, 4}, -- Between a Saurok and a Hard Place, The Last Stand
        [40505662] = {6855, 4}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 4
        [52398766] = {6850, 2}, -- Hozen in the Mist, Hozen Maturiy
        [30553857] = {6846, 3}, -- Fish Tails, Origins
        [72213101] = {6856, 4}, -- Ballad of Liu Lang, Waiting for the Turtle
        [81431145] = {7230, 1}, -- Legend of the Brewfathers, Quan Tou Kou the Two Fisted
    },
    ["ValeofEternalBlossoms"] = {
        [26622149] = {6858, 4}, -- What is Worth Fighting For, Together, We Are Strong
        [40247748] = {6754, 4}, -- The Dark Heart of the Mogu, The Thunder King
        [52936865] = {6858, 2}, -- What is Worth Fighting For, Always Remember
        [68804422] = {6855, 8}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 8
    },
    ["TheJadeForest"] = {
        [35743046] = {6858, 3}, -- What is Worth Fighting For, The First Monks
        [47084514] = {6855, 1}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 1
        [26382833] = {6850, 1}, -- Hozen in the Mist, Hozen Speech
        [67722935] = {6716, 1}, -- Between a Saurok and a Hard Place, The Saurok
        [42261747] = {6754, 3}, -- The Dark Heart of the Mogu, Spirit Binders
        [37303012] = {7230, 2}, -- Legend of the Brewfathers, Xin Wo Yin the Broken Hearted
        [66018756] = {6846, 1}, -- Fish Tails, Watersmithing
        [55885685] = {6855, 3}, -- The Seven Burdens of Shaohao, The Emperor's Burden - Part 3
    },
    ["IsleoftheThunderKing"] = {
        [35107010] = {8049, 1}, -- Zandalari Prophecy, Coming of Age
        [68704580] = {8049, 2}, -- Zandalari Prophecy, For Council and King
        [36307040] = {8049, 3}, -- Zandalari Prophecy, Shadows of the Loa
        [52604140] = {8049, 4}, -- Zandalari Prophecy, The Dark Prophet Zul
        [40204060] = {8050, 1}, -- Rumbles of Thunder, Lei Shen
        [47005990] = {8050, 2}, -- Rumbles of Thunder, The Sacred Mount
        [34906560] = {8050, 3}, -- Rumbles of Thunder, Unity at a Price
        [60706880] = {8050, 4}, -- Rumbles of Thunder, The Pandaren Problem
        [35805470] = {8051, 1}, -- Gods and Monsters, Agents of Order
        [59202630] = {8051, 2}, -- Gods and Monsters, Shadow, Storm, and Stone
        [49902040] = {8051, 3}, -- Gods and Monsters, The Curse and the Silence
        [62503770] = {8051, 4}, -- Gods and Monsters, Age of a Hundred Kings
    },
}

local info_from_coord = function(mapFile, coord)
    mapFile = string.gsub(mapFile, "_terrain%d+$", "")
    local point = points[mapFile] and points[mapFile][coord]
    if point then
        local _, achievement = GetAchievementInfo(point[1])
        local criteria = GetAchievementCriteriaInfo(point[1], point[2])
        return achievement, criteria
    end
end

---------------------------------------------------------
-- Plugin Handlers to HandyNotes
local HLHandler = {}
local info = {}

function HLHandler:OnEnter(mapFile, coord)
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
    if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    local achievement, criteria = info_from_coord(mapFile, coord)
    if achievement then
        tooltip:SetText(("%s (%s)"):format(achievement, criteria))
        tooltip:Show()
    end
end

local function createWaypoint(button, mapFile, coord)
    local c, z = HandyNotes:GetCZ(mapFile)
    local x, y = HandyNotes:getXY(coord)
    local achievement, criteria = info_from_coord(mapFile, coord)
    if TomTom then
        local persistent, minimap, world
        if temporary then
            persistent = true
            minimap = false
            world = false
        end
        TomTom:AddZWaypoint(c, z, x*100, y*100, achievement, persistent, minimap, world)
    elseif Cartographer_Waypoints then
        Cartographer_Waypoints:AddWaypoint(NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, achievement))
    end
end

do
    local currentZone, currentCoord
    local function generateMenu(button, level)
        if (not level) then return end
        for k in pairs(info) do info[k] = nil end
        if (level == 1) then
            -- Create the title of the menu
            info.isTitle      = 1
            info.text         = "HandyNotes - Lorewalkers"
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)

            if TomTom or Cartographer_Waypoints then
                -- Waypoint menu item
                info.disabled     = nil
                info.isTitle      = nil
                info.notCheckable = nil
                info.text = "Create waypoint"
                info.icon = nil
                info.func = createWaypoint
                info.arg1 = currentZone
                info.arg2 = currentCoord
                UIDropDownMenu_AddButton(info, level);
            end

            -- Close menu item
            info.text         = "Close"
            info.icon         = nil
            info.func         = function() CloseDropDownMenus() end
            info.arg1         = nil
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level);
        end
    end
    local HL_Dropdown = CreateFrame("Frame", "HandyNotes_LorewalkersDropdownMenu")
    HL_Dropdown.displayMode = "MENU"
    HL_Dropdown.initialize = generateMenu

    function HLHandler:OnClick(button, down, mapFile, coord)
        if button == "RightButton" and not down then
            currentZone = string.gsub(mapFile, "_terrain%d+$", "")
            currentCoord = coord
            ToggleDropDownMenu(1, nil, HL_Dropdown, self, 0, 0)
        end
    end
end

function HLHandler:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

do
    -- This is a custom iterator we use to iterate over every node in a given zone
    local function iter(t, prestate)
        if not t then return nil end
        local state, value = next(t, prestate)
        while state do -- Have we reached the end of this zone?
            if value and (db.completed or not select(3, GetAchievementCriteriaInfo(value[1], value[2]))) then
                local icon = get_icon(value[1])
                Debug("iter step", state, icon, db.icon_scale, db.icon_alpha)
                return state, nil, icon, db.icon_scale, db.icon_alpha
            end
            state, value = next(t, state) -- Get next data
        end
        return nil, nil, nil, nil
    end
    function HLHandler:GetNodes(mapFile)
        mapFile = string.gsub(mapFile, "_terrain%d+$", "")
        return iter, points[mapFile], nil
    end
end

---------------------------------------------------------
-- Options table
local options = {
    type = "group",
    name = "Lorewalkers",
    desc = "Lorewalkers",
    get = function(info) return db[info[#info]] end,
    set = function(info, v)
        db[info[#info]] = v
        HL:SendMessage("HandyNotes_NotifyUpdate", "Lorewalkers")
    end,
    args = {
        desc = {
            name = "These settings control the look and feel of the icon.",
            type = "description",
            order = 0,
        },
        completed = {
            name = "Show completed",
            desc = "Show waypoints for lore you've already found?",
            type = "toggle",
            arg = "completed",
            order = 10,
        },
        icon_scale = {
            type = "range",
            name = "Icon Scale",
            desc = "The scale of the icons",
            min = 0.25, max = 2, step = 0.01,
            arg = "icon_scale",
            order = 20,
        },
        icon_alpha = {
            type = "range",
            name = "Icon Alpha",
            desc = "The alpha transparency of the icons",
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha",
            order = 30,
        },
    },
}


---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HL:OnInitialize()
    -- Set up our database
    self.db = LibStub("AceDB-3.0"):New("HandyNotes_LorewalkersDB", defaults)
    db = self.db.profile
    -- Initialize our database with HandyNotes
    HandyNotes:RegisterPluginDB("Lorewalkers", HLHandler, options)
end

function HL:OnEnable()
    self:RegisterEvent("CRITERIA_UPDATE", "Refresh")
    self:RegisterEvent("CRITERIA_EARNED", "Refresh")
    self:RegisterEvent("CRITERIA_COMPLETE", "Refresh")
    self:RegisterEvent("ACHIEVEMENT_EARNED", "Refresh")
end

function HL:Refresh()
    self:SendMessage("HandyNotes_NotifyUpdate", "Lorewalkers")
end
