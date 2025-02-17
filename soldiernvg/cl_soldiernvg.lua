local wait = 0
local lightOn = lightOn or false
local dLight

function PLUGIN:Think()
	if LocalPlayer():Team() == TEAM_CITIZEN or LocalPlayer():Team() == TEAM_CWU or LocalPlayer():Team() == TEAM_CP or LocalPlayer():Team() == TEAM_VORT then
		lightOn = false
		return
	end

	if lightOn then
		dLight = DynamicLight(LocalPlayer():EntIndex())
		if dLight then
			dLight.pos = LocalPlayer():EyePos()
			dLight.r = 48
			dLight.g = 64
			dLight.b = 128
			dLight.brightness = 2
			local size = 2200
			dLight.Size = size
			dLight.Decay = size * 5
			dLight.DieTime = CurTime() + 0.8
		end
	end

	if vgui.CursorVisible() then
		return
	end

	if (wait > CurTime()) then return end

	if input.IsKeyDown(KEY_F) then
		wait = CurTime() + 0.3

		if lightOn then
			lightOn = false
			surface.PlaySound("buttons/combine_button3.wav")
			return
		end

		surface.PlaySound("buttons/combine_button3.wav")
		lightOn = true
	end
end