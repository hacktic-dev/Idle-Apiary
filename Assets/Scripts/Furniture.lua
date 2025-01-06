--!Type(ClientAndServer)

ownerId = nil

local placedId = nil

function SetOwner(id)
	ownerId = id
end

function SetPlacedId(_id)
    placedId = _id
end