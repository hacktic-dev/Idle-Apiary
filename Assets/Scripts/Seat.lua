--!Type(Client)

function self:ClientAwake()
	self:GetComponent(TapHandler).Tapped:Connect(function()
		client.localPlayer.character:TeleportToAnchor(self:GetComponent(Anchor), function() end)
		--TODO send to all clients
	end)
end