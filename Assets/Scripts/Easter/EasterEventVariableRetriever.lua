--!Type(Module)

-- Networked values for Easter event data
pinkEggSpawnRate = 0
whiteEggSpawnRate = 0
goldEggSpawnRate = 0

-- Function to retrieve Easter event data from storage
local function RetrieveEasterEventData()
    Storage.GetValue("EasterEventData", function(data, errorCode)
        if errorCode ~= 0 then
            print("Error: couldn't retrieve Easter event data")
            return
        end

        -- Initialize default values if data is nil
        data = data or { pinkEggSpawnRate = 0.1, whiteEggSpawnRate = 0.05, goldEggSpawnRate = 0.01 }

        pinkEggSpawnRate.value = data.pinkEggSpawnRate
        whiteEggSpawnRate.value = data.whiteEggSpawnRate
        goldEggSpawnRate.value = data.goldEggSpawnRate

        -- Save the updated data back to storage
        Storage.SetValue("EasterEventData", data, function(saveErrorCode)
            if saveErrorCode ~= 0 then
                print("Error: failed to save Easter event data")
            end
        end)
    end)
end

-- Server-side initialization
function self:ServerAwake()

    pinkEggSpawnRate = NumberValue.new("PinkEggSpawnRate", 0)
    whiteEggSpawnRate = NumberValue.new("WhiteEggSpawnRate", 0)
    goldEggSpawnRate = NumberValue.new("GoldEggSpawnRate", 0)

    RetrieveEasterEventData()
    Timer.new(30, function() RetrieveEasterEventData() end, true)
end

-- Client-side initialization
function self:ClientAwake()
   pinkEggSpawnRate = NumberValue.new("PinkEggSpawnRate", 0)
   whiteEggSpawnRate = NumberValue.new("WhiteEggSpawnRate", 0)
   goldEggSpawnRate = NumberValue.new("GoldEggSpawnRate", 0)
end

function GetPinkEggSpawnRate()
    return pinkEggSpawnRate.value
end

function GetWhiteEggSpawnRate()
    return whiteEggSpawnRate.value
end

function GetGoldEggSpawnRate()
    return goldEggSpawnRate.value
end