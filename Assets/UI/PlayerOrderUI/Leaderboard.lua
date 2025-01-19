--!Type(UI)


--!Bind
local Orders_Root : UIScrollView = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil
--!Bind
local _romanticTab : UIButton = nil
--!Bind
--local _roomTab : UIButton = nil
--!Bind
local _ShopContainer : VisualElement = nil

buttonState = 0

romanticBeeManager = require("RomanticBeeManager")
UIManager = require("UIManager")
playerManager = require("PlayerManager")

_romanticTab:RegisterPressCallback(function()
    local success = ButtonPressed("romantic")
  end, true, true, true)

  --_roomTab:RegisterPressCallback(function()
 --   local success = ButtonPressed("room")
  --end, true, true, true)
  

function AddItem(username, count, index)
    card = VisualElement.new()
    card:AddToClassList("order-item")
    
    if buttonState == 0 then
        card:AddToClassList("red")
    else
        card:AddToClassList("black")
    end

    groupElementName = VisualElement.new()
    groupElementName:AddToClassList("group-element")
    groupElementName:AddToClassList("fixed-width")

    if index ~= "" then
        indexLabel = UILabel.new()
        indexLabel:AddToClassList("title")    
        indexLabel:SetPrelocalizedText(index .. ".")
        groupElementName:Add(indexLabel)
    end

    name = UILabel.new()
    name:AddToClassList("title")
    name:SetPrelocalizedText(username)
    groupElementName:Add(name)

    card:Add(groupElementName)
    
    groupElement = VisualElement.new()
    groupElement:AddToClassList("group-element")
    

    if index ~= "" then
        prizeLabel = UILabel.new()
        prizeLabel:AddToClassList("title")  
        prizeLabel:AddToClassList("right-align-title")  
        prizeLabel:SetPrelocalizedText(GetPrizeAmount(index))
        groupElement:Add(prizeLabel)

        local _icon = UIImage.new()
        _icon:AddToClassList("icon_gold")
        prizeLabel:AddToClassList("right-align-title")  
        card:Add(_icon)
        groupElement:Add(_icon)

    end

    countLabel = UILabel.new()
    countLabel:AddToClassList("title")
    countLabel:AddToClassList("right-align-title")
    countLabel:SetPrelocalizedText(count)
    groupElementCount = VisualElement.new()
    groupElementCount:AddToClassList("group-element")
    groupElementCount:Add(countLabel)

    card:Add(groupElement)
    card:Add(groupElementCount)

    Orders_Root:Add(card)
end

function GetPrizeAmount(index)
    if index == 1 then
        return 10000
    elseif index == 2 then
        return 5000
    elseif index == 3 then
        return 2000
    elseif index == 4 then
        return 1000
    elseif index == 5 then
        return 500
    elseif index == 6 then
        return 100
    elseif index == 7 then
        return 100
    elseif index == 8 then
        return 100
    elseif index == 9 then
        return 100
    elseif index == 10 then
        return 100
    else
        return 0
    end
end

function Init()
    closeLabel:SetPrelocalizedText("Close", true)

    ButtonPressed("romantic")

    closeButton:RegisterPressCallback(function()
        UIManager.CloseLeaderboard()
    end, true, true, true)
end

function InitRomanticTab()
    Orders_Root:Clear()

    print("Initing")

    title = UILabel.new()
    title:AddToClassList("title-small")
    title:AddToClassList("right-align-title")
    title:SetPrelocalizedText("Romantic Bees caught:")
    Orders_Root:Add(title)

    romanticBeeManager.RequestRomanticLeaderboard()
end

function InitRoomTab()
    Orders_Root:Clear()

    title = UILabel.new()
    title:AddToClassList("title-small")
    title:AddToClassList("right-align-title")
    title:SetPrelocalizedText("Honey rate:")
    Orders_Root:Add(title)

    playerManager.RequestEarnRates()
end

function ButtonPressed(btn: string)
    if btn == "romantic" then
      if state == 0 then return end
      state = 0
      buttonState = 0
      _ShopContainer:AddToClassList("green")
      _romanticTab:AddToClassList("red")
     -- _roomTab:AddToClassList("red")

      _ShopContainer:RemoveFromClassList("black")
      _romanticTab:RemoveFromClassList("black")
      --_roomTab:RemoveFromClassList("black")

      _romanticTab:AddToClassList("nav-button--selected")
      _romanticTab:RemoveFromClassList("nav-button--deselected")
      --_roomTab:AddToClassList("nav-button--deselected")
      InitRomanticTab()
      return true
    elseif btn == "room" then
      if state == 1 then return end
      state = 1
      buttonState = 1
      _ShopContainer:RemoveFromClassList("green")
      _romanticTab:RemoveFromClassList("red")
     -- _roomTab:RemoveFromClassList("red")

      _ShopContainer:AddToClassList("black")
      _romanticTab:AddToClassList("black")
      --_roomTab:AddToClassList("black")

     -- _roomTab:AddToClassList("nav-button--selected")
     -- _roomTab:RemoveFromClassList("nav-button--deselected")
      _romanticTab:AddToClassList("nav-button--deselected")
      InitRoomTab()
      return true
    end
end
  

function self:ClientAwake()

    users = {}

    romanticBeeManager.receiveRomanticLeaderboard:Connect(function(romanticLeaderboard)
        for i, data in pairs(romanticLeaderboard) do
            AddItem(data.key, data.value, i)
            table.insert(users, data.key)
        end

        isInTopTen = false
        for user, _ in pairs(users) do
            if user == client.localPlayer.name then
                isInTopTen = true
                break
            end
        end

        if isInTopTen == false then
            spacer = VisualElement.new()
            spacer:AddToClassList("spacer")
            Orders_Root:Add(spacer)
            romanticBeeManager.requestPlayerScore:FireServer()
        end
    end)

    romanticBeeManager.receivePlayerScore:Connect(function(score)
        AddItem(client.localPlayer.name, score, "")
    end)

    playerManager.receiveEarnRates:Connect(function(rates)

        print("Earn rates received")
        table.sort(rates, function(a, b) return a < b end)

        i = 1
        for player, rate in pairs(rates) do
            if player ~= nil then
                AddItem(player.name, rate, i)
                i = i + 1
            end
        end
    end)
end