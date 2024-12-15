--!Type(UI)


--!Bind
local Orders_Root : UIScrollView = nil
--!Bind
local closeButton : UIButton = nil
--!Bind
local closeLabel : UILabel = nil
--!Bind
local _festiveTab : UIButton = nil
--!Bind
--local _roomTab : UIButton = nil
--!Bind
local _ShopContainer : VisualElement = nil

buttonState = 0

festiveBeeManager = require("FestiveBeeManager")
UIManager = require("UIManager")
playerManager = require("PlayerManager")

_festiveTab:RegisterPressCallback(function()
    local success = ButtonPressed("festive")
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

    if index ~= "" then
        indexLabel = UILabel.new()
        indexLabel:AddToClassList("title")    
        indexLabel:SetPrelocalizedText(index .. ".")
        card:Add(indexLabel)
    end

    name = UILabel.new()
    name:AddToClassList("title")
    name:SetPrelocalizedText(username)
    card:Add(name)

    countLabel = UILabel.new()
    countLabel:AddToClassList("title")
    countLabel:AddToClassList("right-align-title")
    countLabel:SetPrelocalizedText(count)
    card:Add(countLabel)

    Orders_Root:Add(card)
end

function Init()
    closeLabel:SetPrelocalizedText("Close", true)

    ButtonPressed("festive")

    closeButton:RegisterPressCallback(function()
        UIManager.CloseLeaderboard()
    end, true, true, true)
end

function InitFestiveTab()
    Orders_Root:Clear()

    print("Initing")

    title = UILabel.new()
    title:AddToClassList("title-small")
    title:AddToClassList("right-align-title")
    title:SetPrelocalizedText("Festive Bees caught:")
    Orders_Root:Add(title)

    festiveBeeManager.RequestFestiveLeaderboard()
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
    if btn == "festive" then
      if state == 0 then return end
      state = 0
      buttonState = 0
      _ShopContainer:AddToClassList("green")
      _festiveTab:AddToClassList("red")
     -- _roomTab:AddToClassList("red")

      _ShopContainer:RemoveFromClassList("black")
      _festiveTab:RemoveFromClassList("black")
      --_roomTab:RemoveFromClassList("black")

      _festiveTab:AddToClassList("nav-button--selected")
      _festiveTab:RemoveFromClassList("nav-button--deselected")
      --_roomTab:AddToClassList("nav-button--deselected")
      InitFestiveTab()
      return true
    elseif btn == "room" then
      if state == 1 then return end
      state = 1
      buttonState = 1
      _ShopContainer:RemoveFromClassList("green")
      _festiveTab:RemoveFromClassList("red")
     -- _roomTab:RemoveFromClassList("red")

      _ShopContainer:AddToClassList("black")
      _festiveTab:AddToClassList("black")
      --_roomTab:AddToClassList("black")

     -- _roomTab:AddToClassList("nav-button--selected")
     -- _roomTab:RemoveFromClassList("nav-button--deselected")
      _festiveTab:AddToClassList("nav-button--deselected")
      InitRoomTab()
      return true
    end
end
  

function self:ClientAwake()

    users = {}

    festiveBeeManager.receiveFestiveLeaderboard:Connect(function(festiveLeaderboard)
        for i, data in pairs(festiveLeaderboard) do
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
            festiveBeeManager.requestPlayerScore:FireServer()
        end
    end)

    festiveBeeManager.receivePlayerScore:Connect(function(score)
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