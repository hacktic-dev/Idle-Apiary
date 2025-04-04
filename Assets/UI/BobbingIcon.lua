--!Type(UI)

--!Bind
local text : UILabel = nil
--!SerializeField
local textString : string = ""
--!SerializeField
local isSmall : boolean = false

function self:ClientAwake()
    text:SetPrelocalizedText(textString)

    if isSmall then
        text:AddToClassList("text-small")
        text:RemoveFromClassList("text")
    end
end