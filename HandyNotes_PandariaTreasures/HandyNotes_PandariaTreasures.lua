PandariaTreasures = LibStub("AceAddon-3.0"):NewAddon("PandariaTreasures", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)

if not HandyNotes then return end

local iconDefaults = {
    default = "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS",
    unknown = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\chest_normal_daily.tga",
    swprare = "Interface\\Icons\\Trade_Archaeology_Fossil_SnailShell",
    shrine = "Interface\\Icons\\inv_misc_statue_02",
    glider = "Interface\\Icons\\inv_feather_04",
    rocket = "Interface\\Icons\\ability_mount_rocketmount",
    skull_blue = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\RareIconBlue.tga",
    skull_green = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\RareIconGreen.tga",
    skull_grey = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\RareIcon.tga",
    skull_orange = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\RareIconOrange.tga",
    skull_purple = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\RareIconPurple.tga",
    skull_red = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\RareIconRed.tga",
    skull_yellow = "Interface\\Addons\\HandyNotes_PandariaTreasures\\Artwork\\RareIconYellow.tga",
	ritual_stone = "Interface\\Icons\\inv_qiraj_jewelglyphed",
}

local PlayerFaction, _ = UnitFactionGroup("player")
PandariaTreasures.nodes = { }

local nodes = PandariaTreasures.nodes
local isTomTomloaded = false
local isDBMloaded = false

if (IsAddOnLoaded("TomTom")) then 
    isTomTomloaded = true
end

if (IsAddOnLoaded("DBM-Core")) then 
    isDBMloaded = true
end

-- idx 1 -> Warscout, idx 2 -> Warbringer, follows achievement criteria order
if (zul_again == nil) then
	zul_again = { -1, -1}
end

-- {toyID, npcID}
local pandaria_toys = {
	{86588, 50817},
	{86589, 50821},
	{86593, 50836},
	{86571, 50349},
	{86581, 50769},
	{86575, 50359},
	{86568, 50336},
	{86573, 50354},
	{86586, 50806},
	{104302, 73171},
	{104309, 72896},
	{104262, 72970},
	{104294, 73281},
	{104331, 73169},
	{86582, 50780},
	{86590, 50822},
	{86578, 50739},
	{86584, 50789},
	{86594, 50840},
	{86583, 50783},
	{134023, 50749},
	{90067, 66900},
	{86565, 51059},
}

-- {assetID, name} using glorious to fill the table
local elite_names = {[66900] = "Huggalon the Heart Watcher",
					 [72896] = "Eternal Kilnmaster",
					 [68321] = "Kar Warmaker",
					 [68318] = "Dalan Nightbreaker",
					 [68322] = "Muerta",
					 [68319] = "Disha Fearwarden",
					 [68320] = "Ubunti the Shade",
					 [68317] = "Mavis Harms",
					}
for i=1,56 do
	local desc, _, _, _, _, _, _, assetID, _, _ = GetAchievementCriteriaInfo(7439, i)
	elite_names[assetID] = desc
end

for i=1,31 do
	local desc, _, _, _, _, _, _, assetID, _, _ = GetAchievementCriteriaInfo(8714, i)
	elite_names[assetID] = desc
end

--local pandaria_mounts = {
--	{94229, "Zandalari Warbringer"},
--	{94230, "Zandalari Warbringer"},
--	{94231, "Zandalari Warbringer"},
--	{90655, "Alani <The Stormborn>"},
--	{104269, "Huolon"},
--}

rare_elites = {
	-- [NPC ID] = { array of possible coords, questid, notes, icontype, zone}
	--the jade forest
	[50750] = {{33605080}, "", "skull_rare", "rare_tjf", "970003"},
	[51078] = {{56404880, 53604960, 53804560, 52204440, 54204240}, "", "skull_rare", "rare_tjf", "970004"},
	[50338] = {{44007500}, "", "skull_rare", "rare_tjf", "970005"},
	[50363] = {{39606260}, "", "skull_rare", "rare_tjf", "970006"},
	[50350] = {{48202060, 48001860, 46601680, 42601620, 42201760, 40801520}, "", "skull_rare", "rare_tjf", "970007"},
	[50782] = {{64607420}, "", "skull_rare", "rare_tjf", "970008"},
	[50808] = {{57407140}, "", "skull_rare", "rare_tjf", "970009"},
	[50823] = {{42603880}, "", "skull_rare", "rare_tjf", "970010"},
	
	--valley of four winds
	[50828] = {{16604100, 14003820, 19003580, 16803520, 15603200}, "", "default", "rare_fw", "970011"},
	[50364] = {{09206060, 09204740, 12604880, 08205960}, "", "default", "rare_fw", "970012"},
	[51059] = {{32806280, 37806060, 34605960, 39605760}, "", "default", "rare_fw", "970013"},
	[50811] = {{88601800}, "", "default", "rare_fw", "970014"},
	[50351] = {{18607760}, "", "default", "rare_fw", "970015"},
	[50339] = {{37002560}, "", "default", "rare_fw", "970016"},
	[50783] = {{67605960, 71005240, 74605180, 75804640}, "", "default", "rare_fw", "970017"},
	[50766] = {{52802860, 54003160, 54603660, 57603380, 59003860}, "", "skull_rare", "rare_fw", "970018"},
	[50339] = {{37002560}, "", "skull_rare", "rare_fw", "970019"},
	
	--krasarang
	[50787] = {{56204680}, "", "skull_rare", "rare_kra", "970020"},
	[50768] = {{30603820}, "", "skull_rare", "rare_kra", "970021"},
	[50340] = {{53603880}, "", "skull_rare", "rare_kra", "970022"},
	[50331] = {{39602900}, "", "skull_rare", "rare_kra", "970023"},
	[50352] = {{67202300}, "", "skull_rare", "rare_kra", "970024"},
	[50816] = {{39405520, 41605520}, "", "skull_rare", "rare_kra", "970025"},
	[50830] = {{52208800}, "", "skull_rare", "rare_kra", "970026"},
	[50388] = {{15203560}, "", "skull_rare", "rare_kra", "970027"},

	--kun-lai summit
	[50817] = {{40804240}, "", "default", "rare_ks", "970028"},
	[50769] = {{73207640,73807740,74407920}, "", "default", "rare_ks", "970029"},
	[50733] = {{36607960}, "", "default", "rare_ks", "970030"},
	[50354] = {{59207380, 57007580, 57607500}, "", "default", "rare_ks", "970031"},
	[50831] = {{47206300, 46206180, 44806360, 44806520}, "Chance to drop item that increases reputation with all Pandaria's factions by 1000.", "default", "rare_ks", "970032"},	
	[50341] = {{56004340}, "", "skull_rare", "rare_ks", "970033"},
	[50332] = {{51608100, 47408120}, "", "skull_rare", "rare_ks", "970034"},
	[50789] = {{63801380}, "", "default", "rare_ks", "970035"},
	
	--townlong steppes
	[50772] = {{68808920, 67808760, 66408680, 65408760}, "", "skull_rare", "rare_ts", "970036"},
	[50355] = {{63003560}, "", "skull_rare", "rare_ts", "970037"},
	[50734] = {{46407440, 42007840, 47608420, 47808860}, "", "skull_rare", "rare_ts", "970038"},
	[50333] = {{66804440, 67805080, 64204980}, "", "skull_rare", "rare_ts", "970039"},
	[50344] = {{54006340}, "", "skull_rare", "rare_ts", "970040"},
	[50791] = {{59208560}, "", "skull_rare", "rare_ts", "970041"},
	[50832] = {{67607440}, "", "skull_rare", "rare_ts", "970042"},
	[50820] = {{32006180}, "", "skull_rare", "rare_ts", "970043"},
	[66900] = {{37205760}, "", "default", "rare_ts", "970120"},
	
	--dread wastes
	[50836] = {{55406340, 55206380}, "", "default", "rare_dw", "970044"},
	[50821] = {{34802320}, "", "default", "rare_dw", "970045"},
	[50356] = {{73602360, 74002080, 73202040, 73002220}, "Drops item that increases experience gains by 300% for 1 hour. Does not work above level 84.", "default", "rare_dw", "970046"},
	[50776] = {{64205860}, "Drops battle pet Aqua Strider", "default", "rare_dw", "970047"},
	[50334] = {{25202860}, "", "skull_rare", "rare_dw", "970048"},
	[50739] = {{39204180, 37802960, 35603080}, "", "default", "rare_dw", "970049"},
	[50347] = {{71803760}, "", "skull_rare", "rare_dw", "970050"},
	[50805] = {{39606180, 36606460, 39605840, 36806060}, "", "skull_rare", "rare_dw", "970051"},
	
	--valley of eternal blossoms
	[50822] = {{42606900}, "", "default", "rare_eb", "970052"},
	[50359] = {{39802500}, "", "default", "rare_eb", "970053"},
	[50806] = {{35206180, 43805180, 39005340, 36805780,43405340}, "Roams in the old river between the location points.", "default", "rare_eb", "970054"},
	[50749] = {{14005860, 14005820}, "", "default", "rare_eb", "970055"},
	[50349] = {{15003560}, "", "default", "rare_eb", "970056"},
	[50336] = {{87804460}, "", "default", "rare_eb", "970057"},
	[50780] = {{69603080}, "", "default", "rare_eb", "970058"},
	[64403] = {{51404300, 38806560, 16804040}, "Giant serpent dragon flying arround the Vale. Needs Sky Crystal to remove immunity.", "default", "rare_eb", "970059"},
	[50840] = {{31009160}, "", "default", "rare_eb", "970060"},
	
	--timeless isle
	[72898] = {{35003240, 34802940, 45002600, 49603360, 50602340, 57602640, 55803560}, "", "skull_grey", "rare_ti", "970061"},
	[73171] = {{59605280, 62804360, 66004260, 70604580, 70805260, 68005740}, "", "default", "rare_ti", "970062"},
	[72896] = {{35603620, 68803440, 56005960, 56003820, 54002400, 41603020}, "", "default", "rare_ti", "970063"},
	[72970] = {{61606360}, "", "default", "rare_ti", "970064"},
	[73281] = {{25802320}, "", "default", "rare_ti", "970065"},
	[73169] = {{53608300}, "", "default", "rare_ti", "970066"},
	[73167] = {{65605680}, "", "default", "rare_ti", "970067"},
	[73666] = {{50202290}, "", "skull_grey", "rare_ti", "970068"},
	[73174] = {{34803120}, "", "skull_grey", "rare_ti", "970114"},
	[72775] = {{63807300}, "", "skull_grey", "rare_ti", "970069"},
	[72045] = {{25203600}, "", "skull_grey", "rare_ti", "970070"},
	[72049] = {{43806960}, "", "skull_grey", "rare_ti", "970071"},
	[73158] = {{31004920}, "", "skull_grey", "rare_ti", "970072"},
	[73279] = {{72808480}, "", "skull_grey", "rare_ti", "970073"},
	[73172] = {{46603960}, "", "skull_grey", "rare_ti", "970074"},
	[73282] = {{64602860}, "", "skull_grey", "rare_ti", "970075"},
	[72970] = {{61606400}, "", "skull_grey", "rare_ti", "970076"},
	[73161] = {{24605760}, "", "skull_grey", "rare_ti", "970077"},
	[72909] = {{40607960}, "", "skull_grey", "rare_ti", "970078"},
	[73163] = {{34207340}, "", "skull_grey", "rare_ti", "970079"},
	[73160] = {{29804560}, "", "skull_grey", "rare_ti", "970080"},
	[72193] = {{33808580}, "", "skull_grey", "rare_ti", "970081"},
	[73277] = {{67604400}, "", "skull_grey", "rare_ti", "970082"},
	[73166] = {{22803240}, "", "skull_grey", "rare_ti", "970083"},
	[72048] = {{60608780}, "", "skull_grey", "rare_ti", "970084"},
	[73157] = {{44203100}, "Inside cave\n", "skull_grey", "rare_ti", "970085"},
	[71864] = {{59004880}, "", "skull_grey", "rare_ti", "970086"},
	[72769] = {{44803880}, "Inside cave\n", "skull_grey", "rare_ti", "970087"},
	[73704] = {{71408140}, "", "skull_grey", "rare_ti", "970088"},
	[72808] = {{54204280}, "", "skull_grey", "rare_ti", "970089"},
	[73173] = {{44202660}, "", "skull_grey", "rare_ti", "970090"},
	[73170] = {{57607720}, "", "skull_grey", "rare_ti", "970091"},
	[72245] = {{47608780}, "", "skull_grey", "rare_ti", "970092"},
	[71919] = {{37807720}, "", "skull_grey", "rare_ti", "970093"},
	[73175] = {{54005240}, "", "skull_grey", "rare_ti", "970094"},
	[73854] = {{43806960}, "", "skull_grey", "rare_ti", "970121"},
	
	--thunder isle
	[50358] = {{39608120}, "", "ritual_stone", "rare_it", "970095"},
	[69996] = {{37608300}, "", "skull_grey", "rare_it", "970096"},
	[69998] = {{53705310}, "", "skull_grey", "rare_it", "970097"},
	[69664] = {{35006200}, "", "skull_grey", "rare_it", "970098"},
	[69999] = {{61604980}, "", "skull_grey", "rare_it", "970099"},
	[70000] = {{44602960}, "", "skull_grey", "rare_it", "970100"},
	[70001] = {{48202560}, "", "skull_grey", "rare_it", "970101"},
	[70002] = {{54403580}, "", "skull_grey", "rare_it", "970102"},
	[70003] = {{63404900}, "", "skull_grey", "rare_it", "970103"},
	[69997] = {{51007120}, "", "skull_grey", "rare_it", "970113"},
	[69471] = {{35706380}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970104"},
	[69633] = {{30705860}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970105"},
	[69341] = {{55208770}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970106"},
	[69339] = {{44506100}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970107"},
	[69749] = {{48002600}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970108"},
	[69767] = {{55304790}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970109"},
	[70080] = {{68903930}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970110"},
	[69396] = {{57907920}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970111"},
	[69347] = {{49902070}, "Needs 3x[Shan'ze Ritual Stone] to summon", "skull_grey", "rare_it", "970112"},
	
	--5.1 killing your dudes elites
	[68318] = {{85002760}, "", "skull_grey", "rare_kra", "970115"},
	[68317] = {{84603100}, "", "skull_grey", "rare_kra", "970116"},
	[68319] = {{87402920}, "", "skull_grey", "rare_kra", "970117"},
	[68321] = {{14805720}, "", "skull_grey", "rare_kra", "970118"},
	[68320] = {{13206600}, "", "skull_grey", "rare_kra", "970119"},
	[68322] = {{10605700}, "", "skull_grey", "rare_kra", "970120"},
}

nodes["TheJadeForest"] = {
	--Mobs
	[52601900] = { "970000", "Zandalari Warbringer", "Mounts.", "The color of the NPC mount will determine the dropped mount's color.", "default", "rare_ks", "94229", "94230", "94231"},
	
	--Map Treasures
	[26203240] = { "31400", "Ancient Pandaren Tea Pot", "Grey item worth 100g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tjf", ""},
	[31902780] = { "31401", "Lucky Pandaren Coin", "Grey item worth 95g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tjf", ""},
	[23503500] = { "31404", "Pandaren Ritual Stone", "Grey item worth 105g", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tjf", ""},
	[50709990] = { "31396", "Ship's Locker", "Chest with 96g", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tjf", ""},
	[24605320] = { "31864", "Chest of Supplies", "Chest with 10g", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tjf", ""},
	[46308070] = { "31865", "Offering of Remembrance", "Item with 30g and buff", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tjf", ""},
	[62402750] = { "31866", "Stash of Gems", "Chest with 96g and gems", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tjf", ""}
}

nodes["KunLaiSummit"] = {
	--Mobs
	[75006760] = { "970000", "Zandalari Warbringer", "Mounts.", "The color of the NPC mount will determine the dropped mount's color.", "default", "rare_ks", "94229", "94230", "94231"},
	
	--Map Treasures
	[64204520] = { "31420", "Ancient Mogu Tablet", "Grey item worth 95g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""},
	[49505940] = { "31414", "Hozen Treasure Cache", "Item with 95g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""},
	[36707980] = { "31418", "Lost Adventurer's Belongings", "Item with ~97g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""},
	[52605150] = { "31419", "Rikktik's Tiny Chest", "Grey item worth 105g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""},
	[72003390] = { "31416", "Statue of Xuen", "Grey item worth 100g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""},
	[59505290] = { "31415", "Stolen Sprite Treasure", "Item with ~100g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""},
	[57807630] = { "31422", "Terracotta Head", "Grey item worth 100g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""},
	[47807350] = { "31868", "Mo-Mo's Treasure Chest", "Item with 9g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ks", ""}
}

nodes["DreadWastes"] = {
	[47206160] = { "970000", "Zandalari Warbringer", "Mounts.", "The color of the NPC mount will determine the dropped mount's color.", "default", "rare_dw", "94229", "94230", "94231"}
}

nodes["ValeofEternalBlossoms"] = {
}

nodes["ValleyoftheFourWinds"] = {
	--Map Treasures
	[23802850] = { "31405", "Virmen Treasure Cache", "Item with ~99g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_fw", ""},
	[92003900] = { "31869", "Boat-Building Instructions", "Grey item worth 10g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_fw", ""}
}

nodes["TimelessIsle"] = {
	--Mobs
	
}

--The Veiled Stair
nodes["TheHiddenPass"] = {
	--Map Treasures
	[75107640] = { "31428", "The Hammer Folly", "Grey item worth 100g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tvs", ""},
	[54607260] = { "31867", "Forgotten Lockbox", "Chest with ~9g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_tvs", ""}
}

nodes["Krasarang"] = {
	--Mobs
	[38806760] = { "970000", "Zandalari Warbringer", "Mounts.", "The color of the NPC mount will determine the dropped mount's color.", "default", "rare_kra", "94229", "94230", "94231"},
	
	--Map Treasures
	[68600760] = { "31408", "Saurok Stone Tablet", "Grey item worth 100g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_kra", ""},
	[52107340] = { "31863", "Stack of Papers", "Grey item worth 15g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_kra", ""}
}

nodes["TownlongWastes"] = {
	--Mobs
	[36608560] = { "970000", "Zandalari Warbringer", "Mounts.", "The color of the NPC mount will determine the dropped mount's color.", "default", "rare_ts", "94229", "94230", "94231"},
	
	--Map Treasures
	[62803410] = { "31427", "Abandoned Crate of Goods", "Item with ~103g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ts", ""},
	[65808610] = { "31426", "Amber Encased Moth", "Grey item worth 105g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ts", ""},
	[34906310] = { "31423", "Fragment of Dread", "Grey item worth 90g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ts", ""},
	[53905840] = { "31424", "Hardened Sap of Kri'vess", "Grey item worth 110g.", "Counts toward the achievement [Riches of Pandaria]", "default", "treasures_ts", ""}
}

nodes["IsleoftheThunderKing"] = {
	--Mobs
}

local function GetItem(ID)
    if (ID == "824" or ID == "823") then
        local currency, _, _ = GetCurrencyInfo(ID)

        if (currency ~= nil) then
            return currency
        else
            return "Error loading CurrencyID"
        end
    else
        local _, item, _, _, _, _, _, _, _, _ = GetItemInfo(ID)

        if (item ~= nil) then
            return item
        else
            return "Error loading ItemID"
        end
    end
end 

local function GetIcon(ID)
    if (ID == "824" or ID == "823") then
        local _, _, icon = GetCurrencyInfo(ID)

        if (icon ~= nil) then
            return icon
        else
            return "Interface\\Icons\\inv_misc_questionmark"
        end
    else
        local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)

        if (icon ~= nil) then
            return icon
        else
            return "Interface\\Icons\\inv_misc_questionmark"
        end
    end
end

function PandariaTreasures:OnEnter(mapFile, coord)
    if (not nodes[mapFile][coord]) then return end
    
    local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

    if ( self:GetCenter() > UIParent:GetCenter() ) then
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end

    tooltip:SetText(nodes[mapFile][coord][2])
    if (nodes[mapFile][coord][3] ~= nil) and (PandariaTreasures.db.profile.show_loot == true) and (string.find(nodes[mapFile][coord][6], "quests") == nil) and (nodes[mapFile][coord][6] ~= "rare_ach") then
        if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
            tooltip:AddLine(("Loot: " .. GetItem(nodes[mapFile][coord][7])), nil, nil, nil, true)
			
			if (nodes[mapFile][coord][2] == "Zandalari Warbringer") then
				tooltip:AddLine((GetItem(nodes[mapFile][coord][8])), nil, nil, nil, true)
				tooltip:AddLine((GetItem(nodes[mapFile][coord][9])), nil, nil, nil, true)
			end
			
            if ((nodes[mapFile][coord][3] ~= nil) and (nodes[mapFile][coord][3] ~= "")) then
                tooltip:AddLine(("Lootinfo: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
            end
        else
            tooltip:AddLine(("Loot: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
        end
    end
	
	if (nodes[mapFile][coord][4] ~= "") and (PandariaTreasures.db.profile.show_notes == true) then
		tooltip:AddLine(("Notes: " .. nodes[mapFile][coord][4]), nil, nil, nil, true)
		if (nodes[mapFile][coord][2] == "Zandalari Warbringer") and (zul_again[2] > 0) then
			tooltip:AddLine(("\nKill " .. zul_again[2] .. " to complete one of the criteria of the [Zul'Again] Achievement!"), nil, nil, nil, true)
		end
    end
	
	if (nodes[mapFile][coord][6] == "rare_ach") then
		tooltip:AddLine((nodes[mapFile][coord][3]), nil, nil, nil, true)
	end

    tooltip:Show()
end

local isMoving = false
local info = {}
local clickedMapFile = nil
local clickedCoord = nil

local function generateMenu(button, level)
    if (not level) then return end
	
    for k in pairs(info) do info[k] = nil end

    if (level == 1) then
        info.isTitle = 1
        info.text = "PandariaTreasures"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        
        info.disabled = nil
        info.isTitle = nil
        info.notCheckable = nil
        info.text = "Remove this Object from the Map"
        info.func = DisableRare
        info.arg1 = clickedMapFile
        info.arg2 = clickedCoord
        UIDropDownMenu_AddButton(info, level)
        
        if isTomTomloaded == true then
            info.text = "Add this location to TomTom waypoints"
            info.func = addtoTomTom
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)
        end

        if isDBMloaded == true then
            info.text = "Add this treasure as DBM Arrow"
            info.func = AddDBMArrow
            info.arg1 = clickedMapFile
            info.arg2 = clickedCoord
            UIDropDownMenu_AddButton(info, level)
            
            info.text = "Hide DBM Arrow"
            info.func = HideDBMArrow
            UIDropDownMenu_AddButton(info, level)
        end

        info.text = CLOSE
        info.func = function() CloseDropDownMenus() end
        info.arg1 = nil
        info.arg2 = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        info.text = "Restore Removed Objects"
        info.func = ResetDB
        info.arg1 = nil
        info.arg2 = nil
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)
        
    end
end

local HandyNotes_PandariaTreasuresDropdownMenu = CreateFrame("Frame", "HandyNotes_PandariaTreasuresDropdownMenu")
HandyNotes_PandariaTreasuresDropdownMenu.displayMode = "MENU_Pandaria"
HandyNotes_PandariaTreasuresDropdownMenu.initialize = generateMenu

function PandariaTreasures:OnClick(button, down, mapFile, coord)
    if button == "RightButton" and down then
        clickedMapFile = mapFile
        clickedCoord = coord
        ToggleDropDownMenu(1, nil, HandyNotes_PandariaTreasuresDropdownMenu, self, 0, 0)
    end
end

function PandariaTreasures:OnLeave(mapFile, coord)
    if self:GetParent() == WorldMapButton then
        WorldMapTooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

local options = {
    type = "group",
    name = "PandariaTreasures",
    desc = "Locations of treasures in Pandaria.",
    get = function(info) return PandariaTreasures.db.profile[info.arg] end,
    set = function(info, v) PandariaTreasures.db.profile[info.arg] = v; PandariaTreasures:Refresh() end,
    args = {
        desc = {
            name = "General Settings",
            type = "description",
            order = 0,
        },
        icon_scale_treasures = {
            type = "range",
            name = "Icon Scale for Treasures",
            desc = "The scale of the icons",
            min = 0.25, max = 3, step = 0.01,
            arg = "icon_scale_treasures",
            order = 1,
        },
        icon_scale_rares = {
            type = "range",
            name = "Icon Scale for Rares",
            desc = "The scale of the icons",
            min = 0.25, max = 3, step = 0.01,
            arg = "icon_scale_rares",
            order = 2,
        },
        icon_alpha = {
            type = "range",
            name = "Icon Alpha",
            desc = "The alpha transparency of the icons",
            min = 0, max = 1, step = 0.01,
            arg = "icon_alpha",
            order = 20,
        },
        VisibilityOptions = {
            type = "group",
            name = "Visibility Settings",
            desc = "Visibility Settings",
            args = {
                VisibilityGroup = {
                    type = "group",
                    order = 0,
                    name = "Select what to show:",
                    inline = true,
                    args = {
                        groupTJF = {
                            type = "header",
                            name = "The Jade Forest",
                            desc = "The Jade Forest",
                            order = 0,
                        },
                        rareTJF = {
                            type = "toggle",
                            arg = "rare_tjf",
                            name = "Rares",
                            desc = "Rare spawns",
                            order = 1,
                            width = "half",
                        },
						treasuresTJF = {
							type = "toggle",
							arg = "treasures_tjf",
							name = "Treasures",
							desc = "Treasures from Jade Forest",
							order = 2,
							width = "half",
						},
                        groupKRA = {
                            type = "header",
                            name = "Krasarang Wilds",
                            desc = "Krasarang Wilds",
                            order = 10,
                        },  
                        rareKRA = {
                            type = "toggle",
                            arg = "rare_kra",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "half",
                            order = 11,
                        },
						treasuresKRA = {
							type = "toggle",
							arg = "treasures_kra",
							name = "Treasures",
							desc = "Treasures from Krasarang Wilds",
							order = 12,
							width = "half",
						},
                        groupFW = {
                            type = "header",
                            name = "Valley of The Four Winds",
                            desc = "Valley of The Four Winds",
                            order = 20,
                        },  
                        rareFW = {
                            type = "toggle",
                            arg = "rare_fw",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "half",
                            order = 21,
                        },
						treasuresFW = {
							type = "toggle",
							arg = "treasures_fw",
							name = "Treasures",
							desc = "Treasures from the Valley of The Four Winds",
							order = 22,
							width = "half",
						},
                        groupDW = {
                            type = "header",
                            name = "Dread Wastes",
                            desc = "Dread Wastes",
                            order = 30,
                        },  
                        rareDW = {
                            type = "toggle",
                            arg = "rare_dw",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "half",
                            order = 31,
                        },
                        groupKS = {
                            type = "header",
                            name = "Kun-Lai Summit",
                            desc = "Kun-Lai Summit",
                            order = 40,
                        },    
                        rareKS = {
                            type = "toggle",
                            arg = "rare_ks",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "half",
                            order = 41,
                        },
						treasuresKS = {
							type = "toggle",
							arg = "treasures_ks",
							name = "Treasures",
							desc = "Treasures from Kun-Lai Summit",
							order = 42,
							width = "half",
						},
                        groupTS = {
                            type = "header",
                            name = "Townlong Steppes",
                            desc = "Townlong Steppes",
                            order = 50,
                        },
                        rareTS = {
                            type = "toggle",
                            arg = "rare_ts",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "half",
                            order = 51,
                        },
						treasuresTS = {
							type = "toggle",
							arg = "treasures_ts",
							name = "Treasures",
							desc = "Treasures from Townlong Steppes",
							order = 52,
							width = "half",
						},
						groupEB = {
							type = "header",
							name = "Valley of Eternal Blossoms",
							desc = "Valley of Eternal Blossoms",
							order = 60,
						},
						rareEB = {
							type = "toggle",
                            arg = "rare_eb",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 61,
                        },
						groupTI = {
							type = "header",
							name = "Timeless Isle",
							desc = "Timeless Isle",
							order = 70,
						},
						rareTI = {
							type = "toggle",
                            arg = "rare_ti",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 71,
                        },
						groupIT = {
							type = "header",
							name = "Isle of Thunder",
							desc = "Isle of Thunder",
							order = 80,
						},
						rareIT = {
							type = "toggle",
                            arg = "rare_it",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "normal",
                            order = 81,
                        },
						groupTVS = {
							type = "header",
							name = "The Veiled Stair",
							desc = "The Veiled Stair",
							order = 90,
						},
						rareTVS = {
							type = "toggle",
                            arg = "rare_tvs",
                            name = "Rares",
                            desc = "Rare spawns",
                            width = "half",
                            order = 91,
                        },
						treasuresTVS = {
							type = "toggle",
							arg = "treasures_tvs",
							name = "Treasures",
							desc = "Treasures from the Veiled Stair",
							order = 92,
							width = "half",
						},
						groupWB = {
							type = "header",
							name = "World Bosses",
							desc = "Pandaria's World Bosses",
							order = 100,
						},
                    },
                },
                alwaysshowrares = {
                    type = "toggle",
                    arg = "alwaysshowrares",
                    name = "Show all rares with toys (requires /rl)",
                    desc = "Show every rare even if the toy is already known",
                    order = 110,
                    width = "full",
                },
				alwaysshowbosses = {
					type = "toggle",
					arg = "alwaysshowbosses",
					name = "Show looted World Bosses (Sha of Anger, Nalak, Galleon) (requires /rl)",
					desc = "Show World Bosses regardless of looted status",
					order = 112,
					width = "full",
				},
                show_loot = {
                    type = "toggle",
                    arg = "show_loot",
                    name = "Show Loot",
                    desc = "Shows the Loot for each Treasure/Rare",
                    order = 113,
                },
                show_notes = {
                    type = "toggle",
                    arg = "show_notes",
                    name = "Show Notes",
                    desc = "Shows the notes each Treasure/Rare if available",
                    order = 114,
                },
				low_impact = {
					type = "toggle",
					arg = "low_impact",
					name = "Low Impact (requires /rl)",
					desc = "Achievement and toy data is only gathered at login, avoiding periodic achievement/toys checks. Reduces the possible performance hits created by this addon to the minimum.",
					order = 115,
				},
            },
        },
    },
}

function PandariaTreasures:OnInitialize()
    local defaults = {
        profile = {
            icon_scale_treasures = 1.5,
            icon_scale_rares = 1.5,
            icon_alpha = 1.00,
            alwaysshowrares = false,
            alwaysshowtreasures = false,
			alwaysshowbosses = false,
			low_impact = false,
            save = true,
			rare_tjf = true,
			rare_dw = true,
			rare_kra = true,
			rare_ts = true,
			rare_fw = true,
			rare_eb = true,
			rare_ti = true,
			rare_it = true,
			rare_ks = true,
            treasures_tjf = true,
			treasures_kra = true,
			treasures_fw = true,
			treasures_tvs = true,
			treasures_ts = true,
			treasures_ks = true,
			boss_sha = true,
			boss_nalak = true,
			boss_galleon = true,
			boss_oondasta = true,
			show_loot = true,
			show_notes = true,
			rare_ach = true,
        },
    }

    self.db = LibStub("AceDB-3.0"):New("PandariaTreasuresDB", defaults, "Default")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "WorldEnter")
end

function PandariaTreasures:WorldEnter()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	if (self.db.profile.low_impact == false) then
		self:ScheduleRepeatingTimer("AchievementCheck", 8)
		self:ScheduleRepeatingTimer("QuestCheck", 6)
	else
		self:ScheduleTimer("AchievementCheck", 8)
		self:ScheduleTimer("QuestCheck", 6)
	end
	self:ScheduleTimer("RegisterWithHandyNotes", 8)
end

function PandariaTreasures:QuestCheck()
    do
        if (IsQuestFlaggedCompleted(32099) == false) or (self.db.profile.alwaysshowbosses) then
            nodes["KunLaiSummit"][67607460] = { "960009", "Sha of Anger", "Mount.", "Weekly cooldown.", "default", "boss_sha", "87771"}
        end
		
		if (IsQuestFlaggedCompleted(32098) == false) or (self.db.profile.alwaysshowbosses) then
			nodes["ValleyoftheFourWinds"][71606440] = { "960010", "Galleon", "Mount.", "Weekly cooldown.", "default", "boss_galleon", "89783"}
		end
		
		if (IsQuestFlaggedCompleted(32518) == false) or (self.db.profile.alwaysshowbosses) then
			nodes["IsleoftheThunderKing"][60503730] = { "960011", "Nalak", "Mount.", "Weekly cooldown.", "default", "boss_nalak", "95057"}
		end
		
		if (IsQuestFlaggedCompleted(32519) == false) then
			--nodes["IsleofGiants"][50605440] = { "960050", "Oondasta", "Mount.", "Weekly cooldown.", "default", "boss_oondasta", "94228"}
		end
		
		if (zul_again[1] > 0) then
			nodes["DreadWastes"][39604920] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["DreadWastes"][47806040] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["DreadWastes"][59806640] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["TheJadeForest"][44401760] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["TheJadeForest"][53002300] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["TheJadeForest"][53003120] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["KunLaiSummit"][65206460] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["KunLaiSummit"][74606780] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["KunLaiSummit"][67407960] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["TownlongWastes"][47408760] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["TownlongWastes"][39808900] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["TownlongWastes"][40407860] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["TownlongWastes"][48607420] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["Krasarang"][36205900] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["Krasarang"][39406340] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
			nodes["Krasarang"][43805700] = { "970002", "Zandalari Warscout", "", "Kill " .. zul_again[1] .. " to complete one of the criteria of the [Zul'Again] Achievement!", "skull_grey", "rare_ach", ""}
		end
    end
end

function PandariaTreasures:AchievementCheck()
	do
		local zones = {
		["rare_dw"] = "DreadWastes",
		["rare_ks"] = "KunLaiSummit",
		["rare_fw"] = "ValleyoftheFourWinds",
		["rare_eb"] = "ValeofEternalBlossoms",
		["rare_tjf"] = "TheJadeForest",
		["rare_kra"] = "Krasarang",
		["rare_ts"] = "TownlongWastes",
		["rare_ti"] = "TimelessIsle",
		["rare_it"] = "IsleoftheThunderKing",
		}
		zul_again = { -1, -1}
	
		-- Achievement "I'm in Your Base, Killing Your Dudes" #7932
		local faction = 0
		if (PlayerFaction == "Alliance") then
			faction = 1
		end
		
		local _, _, _, achievement_completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(7932)
		--this is due to assetID from this achievement is always 0 and each faction has its own NPCs
		--still missing the real NPC name, the achievement description states Champion of ...
		local base = {0, 0, 0, 0, 0, 0} --first 3 idx horde, second 3 ally, npcs in criteria order
		local npc  = {68318, 68317, 68319, 68321, 68320, 68322}
		local names = {}
		if (achievement_completed == false) then	
			for i=1,3 do
				local desc, _, completed, _, _, _, _, assetID, _, _ = GetAchievementCriteriaInfo(7932, i)
				names[i] = desc
				names[i+3] = desc
				if (completed == false) then
					if (faction == 0) then
						base[i] = 1
					else
						base[i+3] = 1
					end
				end
			end
						
			for i=1,#base do
				if (base[i] == 1) then
					local rare_data = rare_elites[npc[i]]
					local map_name = "Krasarang"
					nodes[map_name][rare_data[1][1]] = { rare_data[5], elite_names[npc[i]], "Needed for the [I'm in your Base, Killing your Dudes] Achievement!", rare_data[2], "skull_grey", "rare_ach", ""}
				end
			end
		end
		
		-- Achievement "Zul'Again" #8078
		local _, _, _, achievement_completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(8078)
		if (achievement_completed == false) then
			--zandalari warbringer already exists in nodes
			local _, _, completed, quantity, req_quantity, _, _, _, _, _ = GetAchievementCriteriaInfo(8078, 2)
			if (completed == false) then
				local mobs_left = req_quantity - quantity
				zul_again[2] = mobs_left
			end
			--zandalari warscout
			local _, _, completed, quantity, req_quantity, _, _, _, _, _ = GetAchievementCriteriaInfo(8078, 1)
			if (completed == false) then
				local mobs_left = req_quantity - quantity
				zul_again[1] = mobs_left
			end
		end
		
		-- Achievement Glorious #7439
		local _, _, _, achievement_completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(7439)
		if (achievement_completed == false) then
			for i=1,56 do
				local desc, _, completed, _, _, _, _, assetID, _, _ = GetAchievementCriteriaInfo(7439, i)
				if (completed == false) then
					local rare_data = rare_elites[assetID]
					local zone = zones[rare_data[4]]
					for j=1,#rare_data[1] do
						if (nodes[zone][rare_data[1][j]] == nil) then
							local note = "Needed for the [Glorious!] Achievement"
							nodes[zone][rare_data[1][j]] = { rare_data[5], desc, note, rare_data[2], "skull_grey", "rare_ach", ""}
						else
							if (nodes[zone][rare_data[1][j]][7] ~= "") then
								nodes[zone][rare_data[1][j]][3] = "Needed for the [Glorious!] Achievement"
							end
						end
					end
				end
			end
		end
		
		-- Achievement Timeless Champion #8714
		local _, _, _, achievement_completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(8714)
		if (achievement_completed == false) then
			for i=1,31 do
				local desc, _, completed, _, _, _, _, assetID, _, _ = GetAchievementCriteriaInfo(8714, i)
				if (completed == false) then
					--for some reason the archerus of flame is set with assetID = 0
					if (assetID == 0) then
						assetID = 73174
					end
					local rare_data = rare_elites[assetID]
					local zone = zones[rare_data[4]]
					for j=1,#rare_data[1] do
						if (nodes[zone][rare_data[1][j]] == nil) then
							local note = "Needed for the [Timeless Champion] Achievement"
							nodes[zone][rare_data[1][j]] = { rare_data[5], desc, note, rare_data[2], "skull_grey", "rare_ach", ""}
						else
							if (nodes[zone][rare_data[1][j]][7] ~= "") then
								nodes[zone][rare_data[1][j]][3] = "Needed for the [Timeless Champion] Achievement"
							end
						end
					end
				end
			end
		end
		
		-- Achievement Champions of Lei-Shen #8103
		local _, _, _, achievement_completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(8103)
		if (achievement_completed == false) then
			for i=1,10 do
				local desc, _, completed, _, _, _, _, assetID, _, _ = GetAchievementCriteriaInfo(8103, i)
				if (completed == false) then
					local rare_data = rare_elites[assetID]
					local zone = zones[rare_data[4]]
					for j=1,#rare_data[1] do
						if (nodes[zone][rare_data[1][j]] == nil) then
							local note = "Needed for the [Champions of Lei Shen] Achievement"
							nodes[zone][rare_data[1][j]] = { rare_data[5], desc, note, rare_data[2], "skull_grey", "rare_ach", ""}
						end
					end
				end
			end
		end
		
		-- Achievement It Was Worth Every Ritual Stone #8101
		local _, _, _, achievement_completed, _, _, _, _, _, _, _, _ = GetAchievementInfo(8101)
		local idx = 1
		if (achievement_completed == false) then
			for i=1,9 do
				local desc, _, completed, _, _, _, _, assetID, _, _ = GetAchievementCriteriaInfo(8101, i)
				if (completed == false) then
					--for some reason the spirit of warlord teng is set with wrong assetID = 139575
					-- the electromancer also set with wrong assetID = 139576
					-- the incomplete drakkari colossus also set with wrong assetID = 139577
					if (assetID == 139575) then
						assetID = 69471
					end
					if (assetID == 139576) then
						assetID = 69339
					end
					if (assetID == 139577) then
						assetID = 69347
					end
					local rare_data = rare_elites[assetID]
					local zone = zones[rare_data[4]]
					for j=1,#rare_data[1] do
						if (nodes[zone][rare_data[1][j]] == nil) then
							local note = "Needed for the [It Was Worth Every Ritual Stone"
							nodes[zone][rare_data[1][j]] = { rare_data[5], desc, note, rare_data[2], "ritual_stone", "rare_ach", ""}
						end
					end
				end
			end
		end
		
		for i=1,#pandaria_toys do
			local obtained = PlayerHasToy(pandaria_toys[i][1]) 
			if (obtained == false or self.db.profile.alwaysshowrares) then
				local npc = pandaria_toys[i][2]
				local rare_data = rare_elites[npc]
				local zone = zones[rare_data[4]]
				for j=1,#rare_data[1] do
					if (nodes[zone][rare_data[1][j]] == nil) then
						nodes[zone][rare_data[1][j]] = { rare_data[5], elite_names[npc], "Drops Toy.", rare_data[2], rare_data[3], rare_data[4], pandaria_toys[i][1]}
					else
						local note = nodes[zone][rare_data[1][j]][3]
						if (nodes[zone][rare_data[1][j]][3] ~= "Drops Toy.") then
							nodes[zone][rare_data[1][j]] = { rare_data[5], elite_names[npc], "Drops Toy. \n" .. note, rare_data[2], rare_data[3], rare_data[4], pandaria_toys[i][1]}
						end
					end
				end
			end
		end
	end
end

function PandariaTreasures:RegisterWithHandyNotes()
    do
        local function iter(t, prestate)
            if not t then return nil end

            local state, value = next(t, prestate)

            while state do
			
                -- QuestID[1], Name[2], Loot[3], Notes[4], Icon[5], Tag[6], ItemID[7]
                if (value[1] and self.db.profile[value[6]] and not PandariaTreasures:HasBeenLooted(value)) and (value[6] ~= "rare_h_tj") then
                    if ((value[7] ~= nil) and (value[7] ~= "")) then
                        GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
                    end

                    if ((value[5] == "default") or (value[5] == "unknown")) then
                        if ((value[7] ~= nil) and (value[7] ~= "")) then
                            return state, nil, GetIcon(value[7]), PandariaTreasures.db.profile.icon_scale_treasures, PandariaTreasures.db.profile.icon_alpha
                        else
                            return state, nil, iconDefaults[value[5]], PandariaTreasures.db.profile.icon_scale_treasures, PandariaTreasures.db.profile.icon_alpha
                        end
                    end

                    return state, nil, iconDefaults[value[5]], PandariaTreasures.db.profile.icon_scale_rares, PandariaTreasures.db.profile.icon_alpha
                end

                state, value = next(t, state)
            end
        end

        function PandariaTreasures:GetNodes(mapFile, isMinimapUpdate, dungeonLevel)
            return iter, nodes[mapFile], nil
        end
    end

    HandyNotes:RegisterPluginDB("PandariaTreasures", self, options)
    self:RegisterBucketEvent({ "LOOT_CLOSED" }, 2, "Refresh")
    self:Refresh()
end
 
function PandariaTreasures:Refresh()
    self:SendMessage("HandyNotes_NotifyUpdate", "PandariaTreasures")
end

function ResetDB()
    table.wipe(PandariaTreasures.db.char)
    PandariaTreasures:Refresh()
end

function PandariaTreasures:HasBeenLooted(value)
    if (self.db.profile.alwaysshowbosses and (string.find(value[6], "world_bosses") == nil)) then return false end
    if (PandariaTreasures.db.char[value[1]] and self.db.profile.save) then return true end
    if (IsQuestFlaggedCompleted(value[1])) then
        return true
    end

    return false
end

function DisableRare(button, mapFile, coord)
    if (nodes[mapFile][coord][1] ~= nil) then
        PandariaTreasures.db.char[nodes[mapFile][coord][1]] = true;
    end

    PandariaTreasures:Refresh()
end

function addtoTomTom(button, mapFile, coord)
    if isTomTomloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord][2];

        if (nodes[mapFile][coord][3] ~= nil) and (PandariaTreasures.db.profile.show_loot == true) then
            if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
                desc = desc.."\nLoot: " .. GetItem(nodes[mapFile][coord][7]);
                desc = desc.."\nLoot Info: " .. nodes[mapFile][coord][3];
            else
                desc = desc.."\nLoot: " .. nodes[mapFile][coord][3];
            end
        end

        if (nodes[mapFile][coord][4] ~= "") and (PandariaTreasures.db.profile.show_notes == true) then
            desc = desc.."\nNotes: " .. nodes[mapFile][coord][4]
        end

        TomTom:AddMFWaypoint(mapId, nil, x, y, {
            title = desc,
            persistent = nil,
            minimap = true,
            world = true
        })
    end
end

if isDBMloaded == true then
    local ArrowDesc = DBMArrow:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    ArrowDesc:SetWidth(400)
    ArrowDesc:SetHeight(100)
    ArrowDesc:SetPoint("CENTER", DBMArrow, "CENTER", 0, -35)
    ArrowDesc:SetTextColor(1, 1, 1, 1)
    ArrowDesc:SetJustifyH("CENTER")
    DBMArrow.Desc = ArrowDesc
end

function AddDBMArrow(button, mapFile, coord)
    if isDBMloaded == true then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        local desc = nodes[mapFile][coord][2];

        if (nodes[mapFile][coord][3] ~= nil) and (PandariaTreasures.db.profile.show_loot == true) then
            if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
                desc = desc.."\nLoot: " .. GetItem(nodes[mapFile][coord][7]);
                desc = desc.."\nLootinfo: " .. nodes[mapFile][coord][3];
            else
                desc = desc.."\nLoot: " .. nodes[mapFile][coord][3];
            end
			
        end

        if (nodes[mapFile][coord][4] ~= "") and (PandariaTreasures.db.profile.show_notes == true) then
            desc = desc.."\nNotes: " .. nodes[mapFile][coord][4]
        end

        if not DBMArrow.Desc:IsShown() then
            DBMArrow.Desc:Show()
        end

        x = x*100
        y = y*100
        DBMArrow.Desc:SetText(desc)
        DBM.Arrow:ShowRunTo(x, y, nil, nil, true)
    end
end

function HideDBMArrow()
    DBM.Arrow:Hide(true)
end