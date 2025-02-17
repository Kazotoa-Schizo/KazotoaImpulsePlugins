local util_AddNetworkString = util.AddNetworkString
local net_Receive = net.Receive
local IsValid = IsValid
local CurTime = CurTime
local net_ReadUInt = net.ReadUInt
local net_ReadData = net.ReadData
local ipairs = ipairs
local player_GetAll = player.GetAll
local hook_Run = hook.Run
local net_Start = net.Start
local net_WriteUInt = net.WriteUInt
local net_WriteData = net.WriteData
local net_Send = net.Send

util_AddNetworkString("impulseScannerData")
util_AddNetworkString("impulseScannerPicture")
util_AddNetworkString("impulseScannerClearPicture")

net_Receive("impulseScannerData", function(length, client)
    if (IsValid(client.impulseScn) and client:GetViewEntity() == client.impulseScn and (client.impulseNextPic or 0) < CurTime()) then
        local delay = 15
        client.impulseNextPic = CurTime() + delay - 1

        local length = net_ReadUInt(16)
        local data = net_ReadData(length)

        if (length != #data) then
            return
        end

        local receivers = {}

        for k, v in ipairs(player_GetAll()) do
            if (hook_Run("CanPlayerReceiveScan", v, client)) then
                receivers[#receivers + 1] = v
                v:EmitSound("npc/overwatch/radiovoice/preparevisualdownload.wav")
            end
        end

        if (#receivers > 0) then
            net_Start("impulseScannerData")
                net_WriteUInt(#data, 16)
                net_WriteData(data, #data)
            net_Send(receivers)
        end
    end
end)

net_Receive("impulseScannerPicture", function(length, client)
    if (not IsValid(client.impulseScn)) then return end
    if (client:GetViewEntity() ~= client.impulseScn) then return end
    if ((client.impulseNextFlash or 0) >= CurTime()) then return end

    client.impulseNextFlash = CurTime() + 1
    client.impulseScn:flash()

    for k, v in pairs(ents.FindInSphere(client.impulseScn:GetPos(), 128)) do
		if not ( v:IsPlayer() ) then
            continue
        end

        if ( client == v ) then
            continue
        end

        if ( v:IsCP() ) then
            continue
        end

        v:ScreenFade(SCREENFADE.IN, color_white, 1, 0.5)
    end

    if ( client:GetViewEntity() and IsValid(client:GetViewEntity()) ) then
        local scanner = client:GetViewEntity()
        
        if ( scanner:GetClass() == "impulse_scanner" ) then
            impulse.Combine.Waypoints.Add({
                text = "Airwatch Visual Download.",
                pos = ( client:GetEyeTrace().HitPos - Vector(0, 0, 30) ),
                time = 120,
                sent = "Airwatch Asset",
                color = Color(255, 125, 0)

            })
        end
    end
end)