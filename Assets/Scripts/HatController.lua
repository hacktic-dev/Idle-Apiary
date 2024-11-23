--!Type(Client)

--!SerializeField
local Hats : {GameObject} = nil

activeHat = nil

HatList = {
    ["yellow_wooly"] = Hats[1],
    ["pink_cap"] = Hats[2],
    ["yellow_bucket"] = Hats[3],
    ["traffic_cone"] = Hats[4],
    ["christmas_elf"] = Hats[5],
    ["pirate_hat"] = Hats[6],
    ["pixel_sunglasses"] = Hats[7],
    ["gold_crown"] = Hats[8],
}

function ApplyHat(hatId)
    if activeHat ~= nil then
        activeHat:SetActive(false)
        activeHat = nil
    end

    if hatId == nil then
        return
    end

    activeHat = HatList[hatId]
    activeHat:SetActive(true)
end
