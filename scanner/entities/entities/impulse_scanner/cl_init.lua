local include = include
local Vector = Vector
local math_min = math.min
local FrameTime = FrameTime
local math_BSplinePoint = math.BSplinePoint
local Lerp = Lerp
local IsValid = IsValid
local math_AngleDifference = math.AngleDifference
local LocalPlayer = LocalPlayer
local CurTime = CurTime
local net_Start = net.Start
local net_SendToServer = net.SendToServer
local CreateSound = CreateSound
local net_Receive = net.Receive
local net_ReadEntity = net.ReadEntity
local DynamicLight = DynamicLight

include("shared.lua")

local knots = {
    Vector(-20, 0, 0),
    Vector(-30, 0, 0),
    Vector(120, 0, 0),
    Vector(90, 0, 0),
}

function ENT:Think()
    local velocity = self:GetVelocity()
    local lengthSqr = velocity:LengthSqr()
    self.wheel = self.wheel or 360
    self.wheel = self.wheel - math_min((lengthSqr / 80) + 250, 900)
        * FrameTime()
    if (self.wheel < 0) then
        self.wheel = 360
    end

    self:SetPoseParameter("dynamo_wheel", self.wheel)

    local t = velocity.z / self.maxSpeed
    self.tail = math_BSplinePoint(t, knots, 1)
    self.realTail = Lerp(FrameTime() * 5, self.realTail or 0, self.tail.x)
    self:SetPoseParameter("tail_control", self.realTail)

    local pilot = self:GetPilot()
    local angles = self:GetAngles()
    local goalAngles = IsValid(pilot) and pilot:EyeAngles() or angles

    local hDiff = math_AngleDifference(goalAngles.y, angles.y) / 45
    local vDiff = math_AngleDifference(goalAngles.p, angles.p) / 45
    self:SetPoseParameter("flex_horz", hDiff * 20)
    self:SetPoseParameter("flex_vert", vDiff * 20)

    self:playFlySound()

    if (self.sound) then
        self.sound:ChangePitch(math_min(80 + (lengthSqr / 10000)*20, 255), 0.5)
    end
    
    if not pilot then return end
    if not IsValid(pilot) then return end
    if pilot != LocalPlayer() then return end

    if(pilot:KeyDown(IN_RELOAD)) then
        if (self.NextQuitAttempt or 0) > CurTime() then return end
        self.NextQuitAttempt = CurTime() + 5
        
        net_Start("impulseHL2RP.ScannerExitScanner")
        net_SendToServer()
    end
end

function ENT:playFlySound()
    if (not self.sound) then
        local source = "npc/scanner/cbot_fly_loop.wav"
        if (self:GetModel():find("shield_scanner")) then
            source = "npc/scanner/combat_scan_loop6.wav"
        end
        self.sound = CreateSound(self, source)
        self.sound:PlayEx(0.5, 100)
    elseif (not self.sound:IsPlaying()) then
        self.sound:Play()
    end
end

function ENT:OnRemove()
    if (self.sound) then
        self.sound:Stop()
        self.sound = nil
    end
end

net_Receive("impulseScannerFlash", function()
    local entity = net_ReadEntity()
    if (IsValid(entity)) then
        local light = DynamicLight(entity:EntIndex())
        if (not light) then return end

        light.pos = entity:GetPos() + entity:GetForward() * 24
        light.r = 255
        light.g = 255
        light.b = 255
        light.brightness = 5
        light.Decay = 5000
        light.Size = 360
        light.DieTime = CurTime() + 1
    end
end)
