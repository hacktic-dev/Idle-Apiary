--!Type(UI)

--!Bind
local text : UILabel = nil
--!SerializeField
local textString : string = ""
--!SerializeField
local isSmall : boolean = false
--!SerializeField
local shouldBob : boolean = false

local time = 0
local originalY = 0

local BOB_SPEED = 2 -- Speed of bobbing
local BOB_HEIGHT = .4 -- Height of bobbing

function self:ClientAwake()
    text:SetPrelocalizedText(textString)

    if isSmall then
        text:AddToClassList("text-small")
        text:RemoveFromClassList("text")
    end

    originalY = self:GetComponent(Transform).localPosition.y
end

function SetText(_text)
    textString = _text
    text:SetPrelocalizedText(textString)
end

function self:Update()
    if shouldBob then
        time = time + Time.deltaTime * BOB_SPEED -- Adjust speed of bobbing here
        local bobOffset = math.abs(math.sin(time)) * BOB_HEIGHT -- Adjust multiplier for desired bobbing height
        self:GetComponent(Transform).localPosition = Vector3.new(0, originalY + bobOffset, 0)
    end
end