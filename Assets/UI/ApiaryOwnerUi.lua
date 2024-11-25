--!Type(UI)

--!Bind
-- Binding the UILabel for displaying the first title
local titleLabel1 : UILabel = nil


-- Function called when the script starts
function self:Start()
    --titleLabel1:SetPrelocalizedText("Hello")
end

function SetLabel(player)
    print("owner is " .. player)
    titleLabel1:SetPrelocalizedText(player)
end