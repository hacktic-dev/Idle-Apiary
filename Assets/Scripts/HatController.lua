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
    ["leather_cap"] = Hats[9],
    ["miner_helmet"] = Hats[10],
    ["red_beret"] = Hats[11],
    ["sailor_hat"] = Hats[12],
    ["santa_hat"] = Hats[13],
    ["top_hat"] = Hats[14],
    ["fishermans_cap"] = Hats[15],
    ["cat_ears"] = Hats[16],
    ["sleeping_cap"] = Hats[17],
    ["mustache"] = Hats[18],
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
