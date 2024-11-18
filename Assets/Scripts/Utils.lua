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
    ["Locked"] = beeTextures[19]
}

HatImage = {
    ["Test 1"] = hatTextures[1],
    ["Test 2"] = hatTextures[2],
    ["Test 3"] = hatTextures[3],
    ["Test 4"] = hatTextures[4],
    ["Test 5"] = hatTextures[5],
    ["Test 6"] = hatTextures[6],
    ["Test 7"] = hatTextures[7],
    ["Test 8"] = hatTextures[8],
}

local hatData = 
{
    {name = "Test 1", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 1000, goldCost = 100},
    {name = "Test 2", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1, isLimited = false, cost = 2000, goldCost = 200},
    {name = "Test 3", rarity = "Common", selectFactorRegular = 10, selectFactorGold = 1,isLimited = false, cost = 5000, goldCost = 500},
    {name = "Test 4", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = false, cost = 8000, goldCost = 800},
    {name = "Test 5", rarity = "Uncommon", selectFactorRegular = 5, selectFactorGold = 2, isLimited = false, cost = 10000, goldCost = 1000},
    {name = "Test 6", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 12000, goldCost = 1200},
    {name = "Test 7", rarity = "Rare", selectFactorRegular = 3, selectFactorGold = 8, isLimited = false, cost = 15000, goldCost = 1500},
    {name = "Test 8", rarity = "Legendary", selectFactorRegular = 0, selectFactorGold = 10, isLimited = false, cost = -1, goldCost = 2000},
}

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