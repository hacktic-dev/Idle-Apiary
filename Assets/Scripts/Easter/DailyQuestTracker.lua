--!Type(Module)

eggInventoryHandler = require("EggInventoryHandler")
playerManager = require("PlayerManager")

dailyQuestData = {}

function GetData(player)
    Storage.GetPlayerValue(player, "DailyQuestData", function(data, errorCode)
        if errorCode == 0 then
            if data == nil then
                data = 
                {
                    date = math.floor(os.time() / 86400),
                    lastCompletedQuestDate = 0,
                    redEggsCollected = 0,
                    orangeEggsCollected = 0,
                    yellowEggsCollected = 0,
                    greenEggsCollected = 0,
                    purpleEggsCollected = 0,
                    beeEggsCrafted = 0,
                    beesHatched = 0,
                    redBeesHatched = 0,
                    orangeBeesHatched = 0,
                    yellowBeesHatched = 0,
                    greenBeesHatched = 0,
                    purpleBeesHatched = 0
                }
            end

            -- Check if the date has changed
            local currentDate = math.floor(os.time() / 86400)
            if data.date ~= currentDate then
                -- Reset the daily quest data for the new day
                data = 
                {
                    date = currentDate,
                    redEggsCollected = 0,
                    orangeEggsCollected = 0,
                    yellowEggsCollected = 0,
                    greenEggsCollected = 0,
                    purpleEggsCollected = 0,
                    beeEggsCrafted = 0,
                    beesHatched = 0,
                    redBeesHatched = 0,
                    orangeBeesHatched = 0,
                    yellowBeesHatched = 0,
                    greenBeesHatched = 0,
                    purpleBeesHatched = 0
                }
            end

            dailyQuestData[player] = data
        else
            print("Error retrieving DailyQuestData: " .. errorCode)
        end
    end)
end

function SaveData(player)
    if dailyQuestData[player] then
        Storage.SetPlayerValue(player, "DailyQuestData", dailyQuestData[player], function(errorCode)
            if errorCode ~= 0 then
                print("Error saving DailyQuestData: " .. errorCode)
            end
        end)
    end
end

function self:ServerAwake()
    eggInventoryHandler.GiveEggEvent:Connect(function(player, eggId)
        if dailyQuestData[player] then
            if eggId == "egg_red" then
                dailyQuestData[player].redEggsCollected = dailyQuestData[player].redEggsCollected + 1
            elseif eggId == "egg_orange" then
                dailyQuestData[player].orangeEggsCollected = dailyQuestData[player].orangeEggsCollected + 1
            elseif eggId == "egg_yellow" then
                dailyQuestData[player].yellowEggsCollected = dailyQuestData[player].yellowEggsCollected + 1
            elseif eggId == "egg_green" then
                dailyQuestData[player].greenEggsCollected = dailyQuestData[player].greenEggsCollected + 1
            elseif eggId == "egg_purple" then
                dailyQuestData[player].purpleEggsCollected = dailyQuestData[player].purpleEggsCollected + 1
            end
            print("DailyQuestTracker: Player " .. player.name .. " collected an egg: " .. eggId)
        end
    end)

    eggInventoryHandler.RequestCraftEggEvent:Connect(function(player, item)
        if dailyQuestData[player] then
            dailyQuestData[player].beeEggsCrafted = dailyQuestData[player].beeEggsCrafted + 1
            print("DailyQuestTracker: Player " .. player.name .. " crafted an egg: " .. item.id)
        end
    end)

    playerManager.EasterBeeHatched:Connect(function(player, bee)
        if dailyQuestData[player] then
            dailyQuestData[player].beesHatched = dailyQuestData[player].beesHatched + 1

            if bee == "Red Easter Bee" then
            dailyQuestData[player].redBeesHatched = dailyQuestData[player].redBeesHatched + 1
            elseif bee == "Orange Easter Bee" then
            dailyQuestData[player].orangeBeesHatched = dailyQuestData[player].orangeBeesHatched + 1
            elseif bee == "Yellow Easter Bee" then
            dailyQuestData[player].yellowBeesHatched = dailyQuestData[player].yellowBeesHatched + 1
            elseif bee == "Green Easter Bee" then
            dailyQuestData[player].greenBeesHatched = dailyQuestData[player].greenBeesHatched + 1
            elseif bee == "Purple Easter Bee" then
            dailyQuestData[player].purpleBeesHatched = dailyQuestData[player].purpleBeesHatched + 1
            end

            print("DailyQuestTracker: Player " .. player.name .. " hatched a bee: " .. bee)
        end
    end)
end
