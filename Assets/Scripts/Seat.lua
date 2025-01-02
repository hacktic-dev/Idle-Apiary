--!Type(Client)

function self:ClientAwake()
	self:GetComponent(TapHandler).Tapped:Connect(function()
		self:GetComponentInParent(Furniture).RequestSitPlayerOnSeat()
	end)
end

function SitPlayerOnSeat(player)
		player.character:TeleportToAnchor(self:GetComponent(Anchor), function() end)
end