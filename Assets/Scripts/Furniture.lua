--!Type(Client)

ownerId = nil

local placedId = nil

placedObjectsManager = require("PlacedObjectsController")

function SetOwner(id)
	ownerId = id
end

function SetPlacedId(_id)
    placedId = _id
end

function RequestSitPlayerOnSeat()
	placedObjectsManager.requestSitPlayerOnSeat:FireServer(placedId)
end

function ClientSitPlayerOnSeat(player)
	self:GetComponentInChildren(Seat).SitPlayerOnSeat(player)
end