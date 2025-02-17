local PLUGIN = PLUGIN

function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
    if not ( impulse.NPCDrops ) then
        return
    end

    if not ( impulse.NPCDrops[npc:GetClass()] ) then
        return
    end
    
    for i = 1, math.random(1, impulse.NPCDrops[npc:GetClass()].max) do
        local randomitem = impulse.NPCDrops[npc:GetClass()].items[math.random(1, #impulse.NPCDrops[npc:GetClass()].items)]
        
        impulse.Inventory.SpawnItem(randomitem, npc:GetPos() + Vector(0, 0, 40))
    end
end