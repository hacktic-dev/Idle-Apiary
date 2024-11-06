--!Type(UI)

--!Bind
local _statusLabel : UILabel = nil

function SetStatus(status)
    _statusLabel:SetPrelocalizedText(status)
end