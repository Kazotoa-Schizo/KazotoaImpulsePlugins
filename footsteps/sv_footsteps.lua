local PLUGIN = PLUGIN

local footstepSounds = {
    [TEAM_CP] = {
        [CLASS_UNION] = "npc/metropolice/gear", 
        [CLASS_HELIX] = "npc/metropolice/gear", 
        [CLASS_GRID] = "npc/metropolice/gear", 
        [CLASS_JURY] = "npc/metropolice/gear", 
        [CLASS_VICE] = "npc/metropolice/gear"
    },
    [TEAM_OTA] = {
        [CLASS_ECHO] = "npc/combine_soldier/gear",
        [CLASS_MACE] = "npc/combine_soldier/gear",
        [CLASS_SENTINEL] = "npc/combine_soldier/gear",
        [CLASS_RANGER] = "npc/combine_soldier/gear"
    },
    [TEAM_VORT] = "npc/vort/vort_foot"
}

function PLUGIN:PlayerFootstep(ply, pos, foot, soundName, vol)
    if ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_FORWARD) and not ply:KeyDown(IN_DUCK) then
        if footstepSounds[ply:Team()] then
            local teamClass = ply:GetTeamClass()
            local soundData = footstepSounds[ply:Team()][teamClass]
            
            if type(soundData) == "table" then
                local footstepSound = soundData.sound
                ply:EmitSound(footstepSound .. math.random(2, 3) .. ".wav", 80, math.random(115, 125), math.random(0.5, 1))
            elseif type(soundData) == "string" then
                ply:EmitSound(soundData .. math.random(1, 6) .. ".wav", 100, 100, 1)
            end

            return true
        end
    end

    return false
end