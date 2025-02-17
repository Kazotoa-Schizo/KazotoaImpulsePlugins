local rebelNPCs = {
	["npc_citizen"] = true,
	["npc_vortigaunt"] = true,
}

local combineNPCs = {
	["npc_cscanner"] = true,
	["npc_stalker"] = true,
	["npc_clawscanner"] = true,
	["npc_turret_floor"] = true,
	["npc_combine_camera"] = true,
	["npc_metropolice"] = true,
	["npc_csniper"] = true,
	["npc_combine_s"] = true,
	["npc_manhack"] = true,
	["npc_rollermine"] = true,
	["npc_strider"] = true,
	["npc_hunter"] = true,
	["npc_combinegunship"] = true,
	["npc_combinedropship"] = true,
	["npc_helicopter"] = true,
	["npc_turret_floor"] = true,
}

function UpdateRelationShip(ent)
    for k, v in pairs(player.GetAll()) do
		if ( v:IsCP() ) then
			if ( combineNPCs[ent:GetClass()] ) then
				ent:AddEntityRelationship(v, D_LI, 99)
			elseif ( rebelNPCs[ent:GetClass()] ) then
				ent:AddEntityRelationship(v, D_HT, 99)
			end
		else
			if ( combineNPCs[ent:GetClass()] ) then
				ent:AddEntityRelationship(v, D_HT, 99)
			elseif ( rebelNPCs[ent:GetClass()] ) then
				ent:AddEntityRelationship(v, D_LI, 99)
			end
		end
    end
end

function PLUGIN:PlayerSpawnedNPC( ply, ent )
    UpdateRelationShip(ent)
end

if ( SERVER ) then
    local chance = math.random(1, 4)
    function PLUGIN:Think()
        for k, v in ipairs(ents.FindByClass("npc_*")) do       
            v:SetKeyValue("spawnflags", "16384")
            v:SetKeyValue("spawnflags", "2097152")
            v:SetKeyValue("spawnflags", "8192") -- dont drop weapons

            if ( v.SetCurrentWeaponProficiency ) then
                
                local weaponProficiency

                if ( chance == 0 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_POOR
                elseif ( chance == 1 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_AVERAGE
                elseif ( chance == 2 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_GOOD
                elseif ( chance == 3 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_VERY_GOOD
                elseif ( chance == 4 ) then
                    weaponProficiency = WEAPON_PROFICIENCY_PERFECT
                end

                v:SetCurrentWeaponProficiency(weaponProficiency)
            end
            
			UpdateRelationShip(v)
        end
    end
end