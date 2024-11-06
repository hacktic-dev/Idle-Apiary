--!Type(Module)

--!SerializeField
local PurchaseSound : AudioShader = nil
--!SerializeField
local CaptureSound : AudioShader = nil
--!SerializeField
local PlaceSound : AudioShader = nil

audioMap = {
    purchaseSound = PurchaseSound,
    captureSound = CaptureSound,
    placeSound = PlaceSound
}

function PlaySound(sound, pitch)
    Audio:PlaySound((audioMap[sound]), self.gameObject, 1, pitch, false, false)
end

function self:ClientAwake()
    --Audio:PlayMusic(BGMusic, 1)
end