--!Type(Client)

--!SerializeField
local RegularBox : GameObject = nil

--!SerializeField
local GoldBox : GameObject = nil

--!SerializeField
local OwnerUI : GameObject = nil

function GetGoldBox()
    return GoldBox
end

function GetRegularBox()
    return RegularBox
end

function GetOwnerUi()
    return OwnerUI
end