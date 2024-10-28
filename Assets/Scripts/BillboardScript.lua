--!Type(Client)

--!SerializeField
local mainCam : GameObject = nil

function self:Update()
    if mainCam == nil then mainCam = GameObject.FindGameObjectWithTag("MainCamera") end
     local directionToCam = mainCam.transform.position - self.transform.position;
     local oppositeDirection = -directionToCam;
     self.transform:LookAt(self.transform.position + oppositeDirection);
end