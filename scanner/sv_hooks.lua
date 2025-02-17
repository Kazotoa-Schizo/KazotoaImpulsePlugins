local IsValid = IsValid
local ents_Create = ents.Create
local ipairs = ipairs
local ents_FindByClass = ents.FindByClass
local hook_Add = hook.Add
local CurTime = CurTime
local table_Random = table.Random
local math_random = math.random

local SCANNER_SOUNDS = {
    "npc/scanner/scanner_blip1.wav",
    "npc/scanner/scanner_scan1.wav",
    "npc/scanner/scanner_scan2.wav",
    "npc/scanner/scanner_scan4.wav",
    "npc/scanner/scanner_scan5.wav",
    "npc/scanner/combat_scan1.wav",
    "npc/scanner/combat_scan2.wav",
    "npc/scanner/combat_scan3.wav",
    "npc/scanner/combat_scan4.wav",
    "npc/scanner/combat_scan5.wav",
    "npc/scanner/cbot_servoscared.wav",
    "npc/scanner/cbot_servochatter.wav"
}

function createScanner(client, isClawScanner)
    if (IsValid(client.impulseScn)) then
        return
    end

    local entity = ents_Create("impulse_scanner")
    if (not IsValid(entity)) then
        return
    end

    for _, scanner in ipairs(ents_FindByClass("impulse_scanner")) do
        if (scanner:GetPilot() == client) then
            scanner:SetPilot(NULL)
        end
    end
    
    client.lastScannerPos = client:GetPos()
    
    entity:SetPos(client:GetPos())
    entity:SetAngles(client:GetAngles())
    entity:SetColor(client:GetColor())
    entity:Spawn()
    entity:Activate()
    entity:setPilot(client)

    if (isClawScanner) then
        entity:setClawScanner()
    end

    entity:SetNWEntity("player", client)
    client.impulseScn = entity

    return entity
end

hook_Add("PlayerSpawn", "scannerPlayerSpawn", function(client)
    if (IsValid(client.impulseScn)) then
        client.impulseScn.noRespawn = true
        client.impulseScn.spawn = client:GetPos()
        client.impulseScn:Remove()
        client.impulseScn = nil
        client:SetViewEntity(NULL)
    end
end)

hook_Add("DoPlayerDeath", "scannerDoPlayerDeath", function(client, attacker, dmg)
    if (IsValid(client.impulseScn)) then
        client:AddDeaths(1)
        return false -- Suppress ragdoll creation.
    end
end)

hook_Add("PlayerDeath", "scannerPlayerDeath", function(client)
    if (IsValid(client.impulseScn) and client.impulseScn.health > 0) then
        client.impulseScn:die()
        client.impulseScn = nil
    end
end)

hook_Add("KeyPress", "scannerKeyPress", function(client, key)
    if (IsValid(client.impulseScn) and (client.impulseScnDelay or 0) < CurTime()) then
        local source

        if (key == IN_USE) then
            source = table_Random(SCANNER_SOUNDS)
            client.impulseScnDelay = CurTime() + 1.75
        elseif (key == IN_RELOAD) then
            source = "npc/scanner/scanner_talk"..math_random(1, 2)..".wav"
            client.impulseScnDelay = CurTime() + 10
        elseif (key == IN_DUCK) then
            if (client:GetViewEntity() == client.impulseScn) then
                client:SetViewEntity(NULL)
            else
                client:SetViewEntity(client.impulseScn)
            end
        end

        if (source) then
            client.impulseScn:EmitSound(source)
        end
    end
end)

hook_Add("PlayerNoClip", "scannerPlayerNoClip", function(client)
    if (IsValid(client.impulseScn)) then
        return false
    end
end)

hook_Add("PlayerUse", "scannerPlayerUse", function(client, entity)
    if (IsValid(client.impulseScn)) then
        return false
    end
end)

hook_Add("CanPlayerReceiveScan", "scannerCanPlayerReceiveScan", function(client, photographer)
    return client.IsCP and client:IsCP()
end)

hook_Add("PlayerSwitchFlashlight", "scannerPlayerSwitchFlashlight", function(client, enabled)
    local scanner = client.impulseScn
    if (not IsValid(scanner)) then return end

    if ((scanner.nextLightToggle or 0) >= CurTime()) then return false end
    scanner.nextLightToggle = CurTime() + 0.5

    local pitch
    if (scanner:isSpotlightOn()) then
        scanner:disableSpotlight()
        pitch = 240
    else
        scanner:enableSpotlight()
        pitch = 250
    end

    scanner:EmitSound("npc/turret_floor/click1.wav", 50, pitch)
    return false
end)

hook_Add("CanUseInventory", "scannerCanUseInventory", function(client, item)
    if (IsValid(client.impulseScn)) then
        return false
    end
end)

hook_Add("PlayerFootstep", "scannerPlayerFootstep", function(client)
    if (IsValid(client.impulseScn)) then
        return true
    end
end)