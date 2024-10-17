--!Type(Client)

-- Store the initial spawn location
spawnPosition = nil

-- Define parameters for wandering behavior
moveSpeed = 2.0       -- Movement speed of the object
rotateSpeed = 5.0     -- Rotation speed of the object
pauseDuration = 2.0   -- Duration to pause after reaching a target
targetPosition = nil  -- Current target position
timer = 0             -- Timer for pauses
moving = false         -- Is the object currently moving?

function SetSpawnPosition(position)
 spawnPosition = position
end

-- Randomly choose a new target position within a 5x5 area
function ChooseNewTarget()
    local randomX = math.random(-5, 5)
    local randomZ = math.random(-5, 5)
    targetPosition = spawnPosition + Vector3.new(randomX, 0, randomZ)
end

-- Rotate towards the target position
function RotateTowardsTarget()
    local direction = targetPosition - self.transform.position
    local targetRotation = Quaternion.LookRotation(direction)
    self.transform.rotation = Quaternion.Slerp(self.transform.rotation, targetRotation, rotateSpeed * Time.deltaTime)
end

-- Move towards the target position
function MoveTowardsTarget()
    if targetPosition then
        local direction = (targetPosition - self.transform.position).normalized
        local step = moveSpeed * Time.deltaTime
        self.transform.position = Vector3.MoveTowards(self.transform.position, targetPosition, step)
    end
end

-- Check if the object has reached the target position
function HasReachedTarget()
    if targetPosition then
        return Vector3.Distance(self.transform.position, targetPosition) < 0.1
    end
    return false
end

-- Function to handle wandering behavior inside Update
function self:Update()
    -- If currently moving towards the target
    if moving then
        -- Rotate towards and move to the target position
        RotateTowardsTarget()
        MoveTowardsTarget()

        -- If the target is reached, start the pause
        if HasReachedTarget() then
            moving = false
            timer = pauseDuration
        end
    else
        -- Handle pausing
        timer = timer - Time.deltaTime
        if timer <= 0 then
            -- Choose a new target and start moving again
            ChooseNewTarget()
            moving = true
        end
    end
end
