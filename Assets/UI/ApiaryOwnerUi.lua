--!Type(UI)

--!Bind
-- Binding the UILabel for displaying the first title
local titleLabel1 : UILabel = nil


-- Function called when the script starts
function self:Start()
    --titleLabel1:SetPrelocalizedText("Hello")
end

function SetLabel(player, count)
    if count < 8 then
        badge = "Novice Apiarist"
        titleLabel1:AddToClassList("novice")
        titleLabel1:RemoveFromClassList("amateur")
        titleLabel1:RemoveFromClassList("professional")
        titleLabel1:RemoveFromClassList("legendary")
    elseif count < 16 then
        badge = "Amateur Apiarist"
        titleLabel1:RemoveFromClassList("novice")
        titleLabel1:AddToClassList("amateur")
        titleLabel1:RemoveFromClassList("professional")
        titleLabel1:RemoveFromClassList("legendary")
    elseif count < 24 then
        badge = "Professional Apiarist"
        titleLabel1:RemoveFromClassList("novice")
        titleLabel1:RemoveFromClassList("amateur")
        titleLabel1:AddToClassList("professional")
        titleLabel1:RemoveFromClassList("legendary")
    else
        badge = "Legendary Apiarist"
        titleLabel1:RemoveFromClassList("novice")
        titleLabel1:RemoveFromClassList("amateur")
        titleLabel1:RemoveFromClassList("professional")
        titleLabel1:AddToClassList("legendary")
    end

    titleLabel1:SetPrelocalizedText(player .. "\n" .. badge)
end