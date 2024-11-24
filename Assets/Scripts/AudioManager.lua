--!Type(Module)

--!SerializeField
local PurchaseSound : AudioShader = nil
--!SerializeField
local CaptureSound : AudioShader = nil
--!SerializeField
local PlaceSound : AudioShader = nil
--!SerializeField
local CutSound : AudioShader = nil
--!SerializeField
local FailSound : AudioShader = nil

audioMap = {
    purchaseSound = PurchaseSound,
    captureSound = CaptureSound,
    placeSound = PlaceSound,
    cutSound = CutSound,
    failSound = FailSound;
}

function PlaySound(sound, pitch)
    Audio:PlaySound((audioMap[sound]), self.gameObject, 1, pitch, false, false)
end

function self:ClientAwake()
    --Audio:PlayMusic(BGMusic, 1)
end