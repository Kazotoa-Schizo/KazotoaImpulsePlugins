function FacingWall(ply)
	local data = {}
	data.start = ply:EyePos()
	data.endpos = data.start + ply:GetForward() * 30
	data.filter = ply

	if (!util.TraceLine(data).Hit) then
		return false
	else
        return true
    end
end

function FacingWallBack(ply)
	local data = {}
	data.start = ply:LocalToWorld(ply:OBBCenter())
	data.endpos = data.start - ply:GetForward() * 30
	data.filter = ply

	if (!util.TraceLine(data).Hit) then
		return false
    else
        return true
    end
end

local actexit = {
    description = "Leave the current act.",
    requiresAlive = true,
    onRun = function(ply)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end

        ply:leaveSequence()
        ply:Freeze(false)
    end
}
impulse.RegisterChatCommand("/actexit", actexit)

local actidle = {
    description = "Act for standing idle.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("d1_t02_playground_cit1_arms_crossed", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actidle", actidle)

local actlean = {
    description = "Act for leaning against a wall.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("plazaidle2", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actlean", actlean)

local actsit = {
    description = "Act for sitting on something.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("sit", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actsit", actsit)

local actsitground = {
    description = "Act for sitting on ground.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("sit_ground", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actsitground", actsitground)

local actsitwall = {
    description = "Act for sitting on the wall.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("silo_sit", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actsitwall", actsitwall)

local actinjured = {
    description = "Act for sitting being injured.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("injured3", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actinjured", actinjured)


local actarrest = {
    description = "Act for being arrested.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("spreadwallidle", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actarrest", actarrest)

local actlay = {
    description = "Act to lying down.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("lying_down", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actlay", actlay)

local actcheck = {
    description = "Act to check something on the ground.",
    requiresAlive = true,
    onRun = function(ply, arg)
        if ply:IsArrested() then return ply:Notify("You cannot do act commands while arrested.") end
        if ply:IsCP() then return ply:Notify("You must be a citizen to use this command.") end        
        
        ply:ForceSequence("d1_town05_daniels_kneel_idle", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actcheck", actcheck)

local actcpidle = {
    description = "Act for standing idle.",
    requiresAlive = true,
    onRun = function(ply, arg)        
        if ply:Team() ~= TEAM_CP then
			return ply:Notify("You must be an Civil Protection Officer to use this command.")
		end
        
        ply:ForceSequence("idlebaton", nil, 9999)
        ply:Freeze(true)
    end
}
impulse.RegisterChatCommand("/actcpidle", actcpidle)

local actcpmotion = {
    description = "Act for motioning.",
    requiresAlive = true,
    onRun = function(ply, arg)        
        if ply:Team() ~= TEAM_CP then
			return ply:Notify("You must be an Civil Protection Officer to use this command.")
		end
        
        ply:Freeze(true)
        ply:ForceSequence("motionright", function()
            if IsValid(ply) then
                ply:Freeze(false)
            end
        end, 2)
    end
}
impulse.RegisterChatCommand("/actcpmotion", actcpmotion)

local actcpthreat = {
    description = "Act for threatening a citizen.",
    requiresAlive = true,
    onRun = function(ply, arg)        
        if ply:Team() ~= TEAM_CP then
			return ply:Notify("You must be an Civil Protection Officer to use this command.")
		end
        
        ply:Freeze(true)
        ply:ForceSequence("plazathreat1", function()
            if IsValid(ply) then
                ply:Freeze(false)
            end
        end, 2)
    end
}
impulse.RegisterChatCommand("/actcpthreat", actcpthreat)