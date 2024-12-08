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
    
    Orders_Root:Clear()

    print("Initing")

    title = UILabel.new()
    title:AddToClassList("title-small")
    title:AddToClassList("right-align-title")
    title:SetPrelocalizedText("Festive Bees caught:")
    Orders_Root:Add(title)

    festiveBeeManager.RequestFestiveLeaderboard()

    closeButton:RegisterPressCallback(function()
        UIManager.CloseLeaderboard()
    end, true, true, true)
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
end