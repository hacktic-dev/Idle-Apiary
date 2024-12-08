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
local _roomTab : UIButton = nil

festiveBeeManager = require("FestiveBeeManager")
UIManager = require("UIManager")
playerManager = require("PlayerManager")

_festiveTab:RegisterPressCallback(function()
    local success = ButtonPressed("festive")
  end, true, true, true)

  _roomTab:RegisterPressCallback(function()
    local success = ButtonPressed("room")
  end, true, true, true)
  

function AddItem(username, count, index)
    card = VisualElement.new()
    card:AddToClassList("order-item")
    

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

    InitFestiveTab()

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

    playerManager.RequestEarnRates()
end

function ButtonPressed(btn: string)
    if btn == "festive" then
      if state == 0 then return end
      state = 0
      _festiveTab:AddToClassList("nav-button--selected")
      _festiveTab:RemoveFromClassList("nav-button--deselected")
      _roomTab:AddToClassList("nav-button--deselected")
      InitFestiveTab()
      return true
    elseif btn == "room" then
      if state == 1 then return end
      state = 1
      _roomTab:AddToClassList("nav-button--selected")
      _roomTab:RemoveFromClassList("nav-button--deselected")
      _festiveTab:AddToClassList("nav-button--deselected")
      InitRoomTab()
      return true
    end
end
  

function self:ClientAwake()

    users = {}

    festiveBeeManager.recieveFestiveLeaderboard:Connect(function(festiveLeaderboard)
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

    festiveBeeManager.recievePlayerScore:Connect(function(score)
        AddItem(client.localPlayer.name, score, "")
    end)

    playerManager.recieveEarnRates:Connect(function(rates)

        print("Earn rates recieved")
        table.sort(rates)

        i = 1
        for player, rate in pairs(rates) do
            if player ~= nil then
                AddItem(player.name, rate, i)
                i = i + 1
            end
        end
    end)
end