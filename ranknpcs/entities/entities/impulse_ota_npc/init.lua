AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Soldier.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()

	local phys = self:GetPhysicsObject()

	if ( IsValid(phys) ) then
		phys:Wake()
	end	
end

function ENT:OnTakeDamage()
	return false
end 

function ENT:Use(act, ply)
	if ( ply:Team() == TEAM_OTA ) then
		self:EmitSound("npc/combine_soldier/vo/fullactive.wav")
		
		net.Start("impulseRankOpen")
		net.Send(ply)
	else
		ply:Notify("You are not part of the "..impulse.Teams.Data[TEAM_OTA].name.."!")
	end
end