--!Type(Module)

--!SerializeField
local beeTextures : {Texture} = nil
--!SerializeField
local hatTextures : {Texture} = nil

BeeImage = {
    ["Common Bee"] = beeTextures[1],
    ["Stone Bee"] = beeTextures[2],
    ["Forest Bee"] = beeTextures[3],
    ["Aquatic Bee"] = beeTextures[4],
    ["Giant Bee"] = beeTextures[5],
    ["Silver Bee"] = beeTextures[6],
    ["Muddy Bee"] = beeTextures[7],
    ["Frigid Bee"] = beeTextures[8],
    ["Steel Bee"] = beeTextures[9],
    ["Magma Bee"] = beeTextures[10],
    ["Ghostly Bee"] = beeTextures[11],
    ["Iridescent Bee"] = beeTextures[12],
    ["Sandy Bee"] = beeTextures[13],
    ["Autumnal Bee"] = beeTextures[14],
    ["Petal Bee"] = beeTextures[15],
    ["Galactic Bee"] = beeTextures[16],
    ["Radiant Bee"] = beeTextures[17],
    ["Rainbow Bee"] = beeTextures[18],
    ["Astral Bee"] = beeTextures[19],
    ["Industrial Bee"] = beeTextures[20],
    ["Pearlescent Bee"] = beeTextures[21],
    ["Prismatic Bee"] = beeTextures[22],
    ["Shadow Bee"] = beeTextures[23],
    ["Hypnotic Bee"] = beeTextures[24],
    ["Locked"] = beeTextures[25]
}

HatImage = {
    ["Yellow Wooly Hat"] = hatTextures[1],
    ["Pink Cap"] = hatTextures[2],
    ["Yellow Bucket Hat"] = hatTextures[3],
    ["Traffic Cone"] = hatTextures[4],
    ["Christmas Elf Hat"] = hatTextures[5],
    ["Pirate Hat"] = hatTextures[6],
    ["Pixel Sunglasses"] = hatTextures[7],
    ["Gold Crown"] = hatTextures[8],

    ["Leather Cap"] = hatTextures[9],
    ["Miner's Helmet"] = hatTextures[10],
    ["Red Beret"] = hatTextures[11],
    ["Sailor's Hat"] = hatTextures[12],
    ["Santa Hat"] = hatTextures[13],
    ["Top Hat"] = hatTextures[14],
    ["Fisherman's Cap"] = hatTextures[15],
}

local hatData = 
{
    {name = "Yellow Wooly Hat", id = "yellow_wooly", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 2000, goldCost = 250},
    {name = "Pink Cap", id = "pink_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 3000, goldCost = 400},
    {name = "Yellow Bucket Hat", id = "yellow_bucket", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2,isLimited = false, cost = 10000, goldCost = 500},
    {name = "Traffic Cone", id = "traffic_cone", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = false, cost = 15000, goldCost = 750},
    {name = "Christmas Elf Hat", id = "christmas_elf", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = true, cost = 20000, goldCost = 1500},
    {name = "Pirate Hat", id = "pirate_hat", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 30000, goldCost = 2500},
    {name = "Pixel Sunglasses", id = "pixel_sunglasses", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 3000},
    {name = "Gold Crown", id = "gold_crown", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 4000},

    {name = "Leather Cap", id = "leather_cap", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 3000, goldCost = 400},
    {name = "Miner's Helmet", id = "miner_helmet", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8,isLimited = false, cost = 20000, goldCost = 1500},
    {name = "Red Beret", id = "red_beret", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 25000, goldCost = 1800},
    {name = "Sailor's Hat", id = "sailor_hat", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = true, cost = 8000, goldCost = 750},
    {name = "Santa Hat", id = "santa_hat", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 20000, goldCost = 1500},
    {name = "Top Hat", id = "top_hat", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 3000},
    {name = "Fisherman's Cap", id = "fishermans_cap", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = false, cost = 8000, goldCost = 750},
}

function LookupHatName(id)
    for _, hat in ipairs(hatData) do
        if hat.id == id then
            return hat.name
        end
    end
    return nil -- Return nil if no matching id is found
end

-- Function to calculate total spawn factor
local function GetTotalSelectionFactor(isGold)
    local totalFactor = 0

    for _, hat in ipairs(hatData) do
        if isGold == true then
            factor = hat.selectFactorGold
        else
            factor = hat.selectFactorRegular
        end
        totalFactor = totalFactor + factor
    end
    return totalFactor
end

-- Function to choose a bee species based on spawn factors
function ChooseHat(isGold)
    print(isGold)
    local totalSpawnFactor = GetTotalSelectionFactor(isGold)
    local rand = math.random() * totalSpawnFactor
    local cumulativeFactor = 0

    for _, hat in ipairs(hatData) do

        if isGold == true then
            factor = hat.selectFactorGold
        else 
            factor = hat.selectFactorRegular
        end

        cumulativeFactor = cumulativeFactor + factor
        if rand <= cumulativeFactor then
            return hat
        end
    end

    -- Fallback in case no species is selected (this shouldn't happen)
    return hat[0]
end