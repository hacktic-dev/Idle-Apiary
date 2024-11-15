--!Type(UI)

--!Bind
local label : UILabel = nil -- Reference to the button for closing the UI.

function GetLabel()
    return label
end

function self:ClientAwake()
    label:SetPrelocalizedText("test")
end