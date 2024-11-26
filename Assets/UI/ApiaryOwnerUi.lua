--!Type(UI)

--!Bind
-- Binding the UILabel for displaying the first title
local titleLabel1 : UILabel = nil

local labelText

local playerManager = require("PlayerManager")

-- Function called when the script starts
function self:Start()
    --titleLabel1:SetPrelocalizedText("Hello")

    playerManager.showBadgesChanged:Connect(function(show)
        
        if show then
            titleLabel1:SetPrelocalizedText(labelText)
        else
            titleLabel1:SetPrelocalizedText("")
        end
    end)
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

    labelText = player .. "\n" .. badge

    if playerManager.ShouldShowBadges() then
        titleLabel1:SetPrelocalizedText(labelText)
    else
        titleLabel1:SetPrelocalizedText("")
    end
end