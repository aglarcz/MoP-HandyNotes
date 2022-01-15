--[[
Things to do
 Lump close dungeon/raids into one, (nexus/oculus/eoe)
 Maybe implement lockout info on tooltip (Don't know if I want too, better addons for tracking it exist)
]]--

local DEBUG = false

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

local iconDefault = "Interface\\Addons\\HandyNotes_DungeonLocations\\merged.tga"
local iconDungeon = "Interface\\Addons\\HandyNotes_DungeonLocations\\dungeon.tga"
local iconRaid = "Interface\\Addons\\HandyNotes_DungeonLocations\\raid.tga"
local iconMerged = "Interface\\Addons\\HandyNotes_DungeonLocations\\merged.tga"

local db
local mapToContinent = { }
local nodes = { }
local minimap = { } -- For nodes that need precise minimap locations but would look wrong on zone or continent maps
--local lockouts = { }

local MERGED_DUNGEONS = 5 -- Where extra dungeon/raids ids start for merging

if (DEBUG) then
 HNDL_NODES = nodes
 HNDL_MINIMAP = minimap
 --HNDL_LOCKOUTS = lockouts
end

local internalNodes = {  -- List of zones to be excluded from continent map
 ["BlackrockMountain"] = true,
 ["CavernsofTime"] = true,
 ["DeadminesWestfall"] = true,
 ["Dalaran"] = true,
 ["MaraudonOutside"] = true,
 ["NewTinkertownStart"] = true,
 ["ScarletMonasteryEntrance"] = true,
 ["WailingCavernsBarrens"] = true,
}

-- [COORD] = { Dungeonname/ID, Type(Dungeon/Raid/Merged), hideOnContinent(Bool), nil placeholder for id later, other dungeons }
-- VANILLA
nodes["AhnQirajTheFallenKingdom"] = {
 [43808980] = { 71533, "Dungeon", "Andre" }, -- Sleeping Dragon
}
nodes["Ashenvale"] = {
 [16501100] = { 227, "Dungeon", "Blackfathom Deeps" }, -- Blackfathom Deeps 14101440 May look more accurate
}
nodes["Badlands"] = {
 [41801130] = { 239, "Dungeon", "Uldaman" }, -- Uldaman
}
nodes["Barrens"] = {
[42106660] = { 240, "Dungeon", "Wailing Caverns" }, -- Wailing Caverns
}
nodes["BurningSteppes"] = {
 [20303260] = { 66, "Merged", "Blackrock Dungeons, MC and BWL/BWD" },
}
nodes["DeadwindPass"] = {
 [46907470] = { 745, "Raid", "Karazhan" }, -- Karazhan
}
nodes["Desolace"] = {
 [29106250] = { 232, "Dungeon", "Maraudon" }, -- Maraudon 29106250 Door at beginning
}
nodes["DunMorogh"] = {
 [29903560] = { 231, "Dungeon", "Gnomeregan" }, -- Gnomeregan
}
nodes["Dustwallow"] = {
 [52907770] = { 760, "Raid", "Onyxia's Lair" }, -- Onyxia's Lair
}
nodes["EasternPlaguelands"] = {
 [27201160] = { 236, "Dungeon", "Stratholme" }, -- Stratholme World 52902870
}
nodes["Feralas"] = {
 [65503530] = { 230, "Dungeon", "Dire Maul" }, -- Dire Maul
}
nodes["Orgrimmar"] = {
 [52405800] = { 226, "Dungeon", "Ragefire Chasm" }, -- Ragefire Chasm Cleft of Shadow 70104880
}
nodes["SearingGorge"] = {
 [41708580] = { 66, "Merged", "Blackrock Dungeons, MC and BWL/BWD" },
}
nodes["Silithus"] = {
 [36208420] = { 743, "Raid", "Ruins of Ahn'Qiraj" }, -- Ruins of Ahn'Qiraj
 [23508620] = { 744, "Raid", "Temple of Ahn'Qiraj" }, -- Temple of Ahn'Qiraj
}
nodes["Silverpine"] = {
 [44806780] = { 64, "Dungeon", "Shadowfang Keep" }, -- Shadowfang Keep
}
nodes["SouthernBarrens"] = {
 [40909450] = { 234, "Dungeon", "Razorfen Kraul" }, -- Razorfen Kraul
}
nodes["StormwindCity"] = {
 [50406640] = { 238, "Dungeon", "The Stockade" }, -- The Stockade
}
nodes["StranglethornJungle"] = {
 [72203290] = { 76, "Dungeon", "Zul'Gurub" }, -- Zul'Gurub
}
nodes["StranglethornVale"] = { -- Jungle and Cape are subzones of this zone (weird)
 [63402180] = { 76, "Dungeon", "Zul'Gurub" }, -- Zul'Gurub
}
nodes["SwampOfSorrows"] = {
 [69505250] = { 237, "Dungeon", "The Temple of Atal'hakkar" }, -- The Temple of Atal'hakkar
}
nodes["ThousandNeedles"] = {
 [47402360] = { 233, "Dungeon", "Razorfen Downs" }, -- Razorfen Downs
}
nodes["Tanaris"] = {
 [65604870] = { 279, "Merged", "Caverns of Time Dungeons" },
 [57004990] = { 456, "Raid", "The Battle for Mount Hyjal" },
 [61705100] = { 187, "Raid", "Dragon Soul" },
 [62705000] = { 186, "Merged", "Hour of Twilight HC dungeons" },
 [39202130] = { 241, "Dungeon", "Zul'Farrak" },
}
nodes["Tirisfal"] = {
 [85303220] = { 311, "Dungeon", "Scarlet Halls" }, -- Scarlet Halls
 [84903060] = { 316, "Dungeon", "Scarlet Monastery" }, -- Scarlet Monastery
}
nodes["WesternPlaguelands"] = {
 [69007290] = { 246, "Dungeon", "Scholomance" }, -- Scholomance World 50903650
}
nodes["Westfall"] = {
 [38307750] = { 63, "Dungeon", "Deadmines" }, -- Deadmines 43707320  May look more accurate
}

nodes["BlackrockMountain"] = {
 [71305340] = { 66, "Dungeon", "Blackrock Caverns" }, -- Blackrock Caverns
 [38701880] = { 228, "Dungeon", "Blackrock Depths" }, -- Blackrock Depths
 [80504080] = { 229, "Dungeon", "Lower Blackrock Spire" }, -- Lower Blackrock Spire
 [79003350] = { 559, "Dungeon", "Upper Blackrock Spire" }, -- Upper Blackrock Spire
 [54208330] = { 741, "Raid", "Molten Core" }, -- Molten Core
 [64207110] = { 742, "Raid", "Blackwing Lair" }, -- Blackwing Lair
}
nodes["CavernsofTime"] = {
 [57608260] = { 279, "Dungeon", "The Culling of Stratholme" }, -- The Culling of Stratholme
 [36008400] = { 255, "Dungeon", "The Black Morass" }, -- The Black Morass
 [26703540] = { 251, "Dungeon", "Old Hillsbrad Foothills" }, -- Old Hillsbrad Foothills
 [35601540] = { 750, "Raid", "The Battle for Mount Hyjal" }, -- The Battle for Mount Hyjal
 [57302920] = { 184, "Dungeon", "End Time" }, -- End Time
 [22406430] = { 185, "Dungeon", "Well of Eternity" }, -- Well of Eternity
 [67202930] = { 186, "Dungeon", "Hour of Twilight" }, -- Hour of Twilight
 [61702640] = { 187, "Raid", "Dragon Soul" }, -- Dragon Soul
}
nodes["DeadminesWestfall"] = {
 [25505090] = { 63, "Dungeon", "Deadmines" }, -- Deadmines
}
nodes["MaraudonOutside"] = {
 [52102390] = { 232, "Dungeon", "Purple Entrance" }, -- Maraudon 30205450 
 [78605600] = { 232, "Dungeon", "Orange Entrance" }, -- Maraudon 36006430
 [44307680] = { 232, "Dungeon", "Earth Song Falls Entrance" },  -- Maraudon
}
nodes["NewTinkertownStart"] = {
 [31703450] = { 231, "Dungeon", "Gnomeregan" }, -- Gnomeregan
}
nodes["ScarletMonasteryEntrance"] = {
 [68802420] = { 316, "Dungeon", "Scarlet Monastery" }, -- Scarlet Monastery
 [78905920] = { 311, "Dungeon", "Scarlet Halls" }, -- Scarlet Halls
}
nodes["WailingCavernsBarrens"] = {
 [55106640] = { 240, "Dungeon", "Wailing Caverns" }, -- Wailing Caverns
}

-- OUTLAND
nodes["BladesEdgeMountains"] = {
 [69302370] = { 746, "Raid", "Gruul's Lair" }, -- Gruul's Lair World 45301950
}
nodes["Ghostlands"] = {
 [85206430] = { 77, "Dungeon", "Zul'Aman" }, -- Zul'Aman World 58302480
}
nodes["Hellfire"] = {
 [47505210] = { 747, "Raid", "Magtheridon's Lair" }, -- Magtheridon's Lair World 56705270
 [47605360] = { 248, "Dungeon", "Hellfire Ramparts" }, -- Hellfire Ramparts World 56805310 Stone 48405240 World 57005280
 [47505200] = { 259, "Dungeon", "The Shattered Halls" }, -- The Shattered Halls World 56705270
 [46005180] = { 256, "Dungeon", "The Blood Furnace" }, -- The Blood Furnace World 56305260
}
nodes["Netherstorm"] = {
 [71705500] = { 257, "Dungeon", "The Botanica" }, -- The Botanica
 [70606980] = { 258, "Dungeon", "The Mechanar" }, -- The Mechanar World 65602540
 [74405770] = { 254, "Dungeon", "The Arcatraz" }, -- The Arcatraz World 66802160
 [73806380] = { 749, "Raid", "The Eye" }, -- The Eye World 66602350
}
nodes["TerokkarForest"] = {
 [34306560] = { 247, "Dungeon", "Auchenai Crypts" }, -- Auchenai Crypts World 44507890
 [39705770] = { 250, "Dungeon", "Mana-Tombs" }, -- Mana-Tombs World 46107640
 [44906560] = { 252, "Dungeon", "Sethekk Halls" }, -- Sethekk Halls World 47707890  Summoning Stone For Auchindoun 39806470, World: 46207860 
 [39607360] = { 253, "Dungeon", "Shadow Labyrinth" }, -- Shadow Labyrinth World 46108130
}
nodes["ShadowmoonValley"] = {
 [71004660] = { 751, "Raid", "Black Temple" }, -- Black Temple World 72608410
}
nodes["Sunwell"] = {
 [61303090] = { 249, "Dungeon", "Magisters' Terrace" }, -- Magisters' Terrace
 [44304570] = { 752, "Raid", "Sunwell Plateau" }, -- Sunwell Plateau World 55300380
}
nodes["Zangarmarsh"] = {
[51904120] = { 262, "Dungeon", "Underbog" },
[48804120] = { 260, "Dungeon", "Slave Pens" },
[50203870] = { 748, "Raid", "Serpentshrine Cavern" },
}

-- NORTHREND (16 Dungeons, 9 Raids)
nodes["BoreanTundra"] = {
 [27602660] = { 282, "Merged", "The Oculus, The Nexus, The Eye of Eternity"}
}
nodes["CrystalsongForest"] = {
 [28203640] = { 283, "Dungeon", "The Violet Hold" },
}
nodes["Dragonblight"] = {
 [28505170] = { 271, "Dungeon", "Ahn'kahet: The Old Kingdom" },
 [26005090] = { 272, "Dungeon", "Azjol-Nerub" }, -- Azjol-Nerub
 [87305100] = { 754, "Raid", "Naxxramas" }, -- Naxxramas
 [61305260] = { 761, "Raid", "The Ruby Sanctum" }, -- The Ruby Sanctum
 [60005690] = { 755, "Raid", "The Obsidian Sanctum" }, -- The Obsidian Sanctum
}
nodes["HowlingFjord"] = {
 [58005000] = { 285, "Dungeon", "Utgarde Keep" }, -- Utgarde Keep
 [57204660] = { 286, "Dungeon", "Utgarde Pinnacle" }, -- Utgarde Pinnacle
}
nodes["IcecrownGlacier"] = {
 [53808720] = { 758, "Raid", "Icecrown Citadel" }, -- Icecrown Citadel
 [54908980] = { 280, "Dungeon", "The Forge of Souls" }, -- The Forge of Souls
 [55409080] = { 276, "Dungeon", "Halls of Reflection" }, -- Halls of Reflection
 [54809180] = { 278, "Dungeon", "Pit of Saron" }, -- Pit of Saron 54409070 Summoning stone in the middle of last 3 dungeons
 [75202180] = { 757, "Raid", "Trial of the Crusader" }, -- Trial of the Crusader
 [74202040] = { 284, "Dungeon", "Trial of the Champion" }, -- Trial of the Champion
}
nodes["LakeWintergrasp"] = {
 [50001160] = { 753, "Raid", "Vault of Archavon" }, -- Vault of Archavon
}
nodes["TheStormPeaks"] = {
 [45302140] = { 275, "Dungeon", "Halls of Lightning" }, -- Halls of Lightning
 [39602690] = { 277, "Dungeon", "Halls of Stone" }, -- Halls of Stone
 [41601770] = { 759, "Raid", "Ulduar" }, -- Ulduar
}
nodes["ZulDrak"] = {
 [28508700] = { 273, "Dungeon", "Drak'Tharon Keep" }, -- Drak'Tharon Keep 17402120 Grizzly Hills
 [76202110] = { 274, "Dungeon", "Gundrak Left Entrance" }, -- Gundrak Left Entrance
 [81302900] = { 274, "Dungeon", "Gundrak Right Entrance" }, -- Gundrak Right Entrance
}
nodes["Dalaran"] = {
 [68407000] = { 283, "Dungeon", "The Violet Hold" }, -- The Violet Hold
}

-- CATACLYSM
nodes["Deepholm"] = {
 [46905210] = { 888, "Dungeon", "The Stonecore" },
}
nodes["Hyjal"] = {
 [47307810] = { 78, "Raid", "Firelands" }, -- Firelands
}
nodes["TolBarad"] = {
 [46104790] = { 75, "Raid", "Baradin Hold" }, -- Baradin Hold
}
nodes["TwilightHighlands"] = {
 [19105390] = { 71, "Dungeon", "Grim Batol" }, -- Grim Batol World 53105610
 [34007800] = { 72, "Raid", "The Bastion of Twilight" }, -- The Bastion of Twilight World 55005920
}
nodes["Uldum"] = {
 [76808450] = { 68, "Dungeon", "The Vortex Pinnacle" }, -- The Vortex Pinnacle
 [60506430] = { 69, "Dungeon", "Lost City of Tol'Vir" }, -- Lost City of Tol'Vir
 [69105290] = { 70, "Dungeon", "Halls of Origination" }, -- Halls of Origination
 [38308060] = { 74, "Raid", "Throne of the Four Winds" }, -- Throne of the Four Winds
}
nodes["Vashjir"] = {
 [48204040] =  { 65, "Dungeon", "Throne of Tides" }, -- Throne of Tides
}
nodes["VashjirDepths"] = {
 [69302550] = { 65, "Dungeon", "Throne of Tides" }, -- Throne of Tides
}
-- PANDARIA
nodes["DreadWastes"] = {
 [38803500] = { 330, "Raid", "Heart of Fear" }, -- Heart of Fear
}
nodes["IsleoftheThunderKing"] = {
 [63603230] = { 362, "Raid", "Throne of Thunder" }, -- Throne of Thunder
}
nodes["KunLaiSummit"] = {
 [59503920] = { 317, "Raid", "Mogu'shan Vaults" }, -- Mogu'shan Vaults
 [36704740] = { 312, "Dungeon", "Shado-Pan Monastery" }, -- Shado-Pan Monastery
}
nodes["TheHiddenPass"] = {
 [48306130] = { 320, "Raid", "Terrace of Endless Spring" }, -- Terrace of Endless Spring
}
nodes["TheJadeForest"] = {
 [56205790] = { 313, "Dungeon", "Temple of the Jade Serpent" },
}
nodes["TownlongWastes"] = {
 [34708150] = { 324, "Dungeon", "Siege of Niuzao Temple" }, -- Siege of Niuzao Temple
}
nodes["ValeofEternalBlossoms"] = {
 [15907410] = { 303, "Dungeon", "Gate of the Setting Sun" }, -- Gate of the Setting Sun
 [80803270] = { 321, "Dungeon", "Mogu'shan Palace" }, -- Mogu'shan Palace
 [74104200] = { 369, "Raid", "Siege of Orgrimmar" }, -- Siege of Orgrimmar
}
nodes["ValleyoftheFourWinds"] = {
 [36106920] = { 302, "Dungeon", "Stormstout Brewery" }, -- Stormstout Brewery
}

-- PANDARIA Continent, For things that should be shown or merged only at the continent level
nodes["Pandaria"] = {
 [23100860] = { 362, "Raid", "Throne of Thunder" }, -- Throne of Thunder, looked weird so manually placed on continent
}

local continents = {
	["Azeroth"] = true, -- Eastern Kingdoms
	["Expansion01"] = true, -- Outland
	["Kalimdor"] = true,
	["Northrend"] = true,
	["Pandaria"] = true,
}


local pluginHandler = { }
function pluginHandler:OnEnter(mapFile, coord) -- Copied from handynotes
 --GameTooltip:AddLine("text" [, r [, g [, b [, wrap]]]])
 -- Maybe check for situations where minimap and node coord overlaps
    local nodeData = nil
    --if (not nodes[mapFile][coord]) then return end
	if (minimap[mapFile] and minimap[mapFile][coord]) then
	 nodeData = minimap[mapFile][coord]
	end
	if (nodes[mapFile] and nodes[mapFile][coord]) then
	 nodeData = nodes[mapFile][coord]
	end
	if (not nodeData) then return end
	
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

	if (nodeData[3] ~= nil) then
	 tooltip:AddLine(nodeData[3], nil, nil, nil, true)
     else tooltip:AddLine(nodes[mapFile][coord][2])
	end
	
	--if (lockouts[nodeData[1]]) then
	-- for i,v in pairs(lockouts[nodeData[1]]) do
	-- local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(i)
	--  tooltip:AddLine(name .. " - (" .. v[1] .. "/" .. v[2] .. ")")
	-- end
	--end
	tooltip:Show()
end

function pluginHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

do
 local scale, alpha = 1, 1
 local function iter(t, prestate)
 if not t then return nil end
		
 local state, value = next(t, prestate)
 while state do
  local icon
  if (value[2] == "Dungeon") then
   icon = iconDungeon
  elseif (value[2] == "Raid") then
   icon = iconRaid
  elseif (value[2] == "Merged") then
   icon = iconMerged
  else
   icon = iconDefault
  end
		
   return state, nil, icon, scale, alpha
   --state, value = next(t, state)
  end
 end
 function pluginHandler:GetNodes(mapFile, isMinimapUpdate, dungeonLevel)
  if (DEBUG) then print(mapFile) end
  local isContinent = continents[mapFile]
  scale = isContinent and db.continentScale or db.zoneScale
  alpha = isContinent and db.continentAlpha or db.zoneAlpha

  if (isMinimapUpdate and minimap[mapFile]) then
   return iter, minimap[mapFile]
  end
  if (isContinent and not db.continent) then
   return iter
  else
   return iter, nodes[mapFile]
  end
 end
end

local waypoints = {}
local function setWaypoint(mapFile, coord)
	local dungeon = nodes[mapFile][coord]

	local waypoint = nodes[dungeon]
	if waypoint and TomTom:IsValidWaypoint(waypoint) then
		return
	end

	local title = dungeon[1]
	local zone = HandyNotes:GetMapFiletoMapID(mapFile)
	local x, y = HandyNotes:getXY(coord)
	waypoints[dungeon] = TomTom:AddMFWaypoint(zone, nil, x, y, {
		title = dungeon[1],
		persistent = nil,
		minimap = true,
		world = true
	})
end

function pluginHandler:OnClick(button, pressed, mapFile, coord)
 if (not pressed) then return end
 if (button == "RightButton" and db.tomtom and TomTom) then
  setWaypoint(mapFile, coord)
  return
 end
 if (button == "LeftButton" and db.journal) then
  if (not EncounterJournal_OpenJournal) then
   UIParentLoadAddOn('Blizzard_EncounterJournal')
  end
  local dungeonID = nodes[mapFile][coord][1]
  local name, _, _, _, _, _, _, link = EJ_GetInstanceInfo(dungeonID)
  local difficulty = 1
  nodeData = nodes[mapFile][coord] 
  if (not dungeonID or not difficulty) then return end
  if (nodeData[2] == "Raid") then EncounterJournal_OpenJournal(4, dungeonID)
  else if (nodeData[2] == "Merged") then EncounterJournal_OpenJournal(2, dungeonID)
  else EncounterJournal_OpenJournal(1, dungeonID)
  end
  end
 end
end

local defaults = {
 profile = {
  zoneScale = 2,
  zoneAlpha = 1,
  continentScale = 2,
  continentAlpha = 1,
  continent = true,
  tomtom = true,
  dungeon = false,
  journal = true
 },
}

local options = {
 type = "group",
 name = "DungeonLocations",
 desc = "Locations of dungeon and raid entrances.",
 get = function(info) return db[info[#info]] end,
 set = function(info, v) db[info[#info]] = v HandyNotes:SendMessage("HandyNotes_NotifyUpdate", "DungeonLocations") end,
 args = {
  desc = {
   name = "Continent icons are not working yet.",
   type = "description",
   order = 0,
  },
  zoneScale = {
   type = "range",
   name = "Zone Scale",
   desc = "The scale of the icons shown on the zone map",
   min = 0.2, max = 12, step = 0.1,
   order = 10,
  },
  zoneAlpha = {
   type = "range",
   name = "Zone Alpha",
   desc = "The alpha of the icons shown on the zone map",
   min = 0, max = 1, step = 0.01,
   order = 20,
  },
  continentScale = {
   type = "range",
   name = "Continent Scale",
   desc = "The scale of the icons shown on the continent map",
   min = 0.2, max = 12, step = 0.1,
   order = 10,
  },
  continentAlpha = {
   type = "range",
   name = "Continent Alpha",
   desc = "The alpha of the icons shown on the continent map",
   min = 0, max = 1, step = 0.01,
   order = 20,
  },
  continent = {
   type = "toggle",
   name = "Show on Continent",
   desc = "Show icons on continent map",
   order = 1,
  },
  tomtom = {
   type = "toggle",
   name = "Enable TomTom integration",
   desc = "Allow right click to create waypoints with TomTom",
   order = 2,
  },
  journal = {
   type = "toggle",
   name = "Journal Integration",
   desc = "Allow left click to open journal to dungeon or raid",
   order = 2,
  },
 },
}


local Addon = CreateFrame("Frame")
Addon:RegisterEvent("PLAYER_LOGIN")
Addon:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function Addon:PLAYER_LOGIN()
 HandyNotes:RegisterPluginDB("DungeonLocations", pluginHandler, options)
 self.db = LibStub("AceDB-3.0"):New("HandyNotes_DungeonLocationsDB", defaults, true)
 db = self.db.profile
 
 local continents = { GetMapContinents() }
 local temp = { } -- I switched to the temp table because modifying the nodes table while iterating over it sometimes stopped it short for some reason
 
 --self:UpdateLockouts()
end

-- Looked to see what events SavedInstances was using, seems far more involved than what I am willing to do
--[[function Addon:UpdateLockouts()
 table.wipe(lockouts)
 
 for i=1,GetNumSavedInstances() do
  local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
  if (locked) then
   if (not lockouts[name]) then lockouts[name] = { } end
   lockouts[name][difficulty] = { encounterProgress, numEncounters }
  end
 end
end ]]--
