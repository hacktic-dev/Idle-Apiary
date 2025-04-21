--!Type(UI)

--!Bind
local _closeButton : UIButton = nil
--!Bind
local _closeButtonLabel : UILabel = nil
--!Bind
local _wheel : VisualElement = nil
--!Bind
local _spinButton : UIButton = nil
--!Bind
local _spinButtonLabel : UILabel = nil

local TweenModule = require("TweenModule")
local Tween = TweenModule.Tween
local Easing = TweenModule.Easing
local UIManager = require("UIManager")


--!SerializeField
local ItemIcons : {Texture} = nil
--!SerializeField
local SpinEasing : AnimationCurve = nil

prizes = 
{
    "egg_red",
    "egg_orange",
    "egg_yellow",
    "egg_green",
    "egg_purple",
    "egg_pink",
    "egg_white",
    "egg_golden",
}

function self:ClientAwake()
    _closeButton:RegisterPressCallback(function()
        UIManager.CloseDailyRewardsWheel()
    end)

    _spinButton:RegisterPressCallback(function()
        Spin(math.random(1, #ItemIcons))
    end)

    _closeButtonLabel:SetPrelocalizedText("Close")
    _spinButtonLabel:SetPrelocalizedText("Spin")
end

function AddItems(prizeId : number)
    _wheel:Clear()
    _wheel.style.translate = StyleTranslate.new(Translate.new(Length.new(0), Length.new(-1410)))
    for i=1, 20 do 
        if i == 2 then
            -- Add the prize item at position 2
            local new_final_item = CreateItem(prizeId, _wheel)
            Timer.After(1.25, function()
                -- Highlight the final item
                new_final_item:AddToClassList("Slot__Item--Main")
            end)
        else
            -- Add random items
            CreateItem(math.random(1, #ItemIcons), _wheel)
        end
    end
end

-- Creates a slot item with the specified ID
function CreateItem(itemID: number, wheel: VisualElement)
    local _item = Image.new()
    _item:AddToClassList("Slot__Item")
    -- Set item icon
    _item.image = ItemIcons[itemID]
    -- Add item to the wheel
    wheel:Add(_item)
    return _item
end

function SpinWheelAnimations(wheel : VisualElement)
    local SpinTween = Tween:new(
        -1400, -- Start position (pixels)
        -10, -- End position
        .75, -- Duration in seconds
        false, -- Loop flag
        false, -- Yoyo flag
        function(t)
            -- Use custom easing curve
            return SpinEasing:Evaluate(t)
        end,
        function(value, t)
            -- Update wheel vertical position
            wheel.style.translate = StyleTranslate.new(Translate.new(Length.new(0), Length.new(value)))
        end,
        function()
            -- Reset wheel position
            wheel.style.translate = StyleTranslate.new(Translate.new(Length.new(0), Length.new(-10)))
        end
    )
    SpinTween:start()
end

function Spin(prizeId : number)
    AddItems(prizeId)
    SpinWheelAnimations(_wheel)
    _spinButton.visible = false
end

function Init()
    _spinButton.visible = true
    AddItems(math.random(1, #ItemIcons))
end