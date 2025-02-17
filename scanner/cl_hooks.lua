local hook_Add = hook.Add
local IsValid = IsValid
local math_abs = math.abs
local RealTime = RealTime
local math_Clamp = math.Clamp
local Lerp = Lerp
local FrameTime = FrameTime
local LocalPlayer = LocalPlayer
local ScrW = ScrW
local CurTime = CurTime
local math_Round = math.Round
local math_TimeFraction = math.TimeFraction
local math_sin = math.sin
local draw_SimpleText = draw.SimpleText
local Color = Color
local math_floor = math.floor
local util_TraceLine = util.TraceLine
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawLine = surface.DrawLine
local DrawColorModify = DrawColorModify
local PICTURE_WIDTH = 580
local PICTURE_HEIGHT = 370
local PICTURE_WIDTH2 = PICTURE_WIDTH * 0.5
local PICTURE_HEIGHT2 = PICTURE_HEIGHT * 0.5

local view = {}
local zoom = 0
local deltaZoom = zoom
local nextClick = 0
local hidden = false
local data = {}

local CLICK = "buttons/button18.wav"

local blackAndWhite = {
    ["$pp_colour_addr"] = 0, 
    ["$pp_colour_addg"] = 0, 
    ["$pp_colour_addb"] = 0, 
    ["$pp_colour_brightness"] = 0, 
    ["$pp_colour_contrast"] = 1.5, 
    ["$pp_colour_colour"] = 0, 
    ["$pp_colour_mulr"] = 0, 
    ["$pp_colour_mulg"] = 0, 
    ["$pp_colour_mulb"] = 0
}

hook_Add("CalcView", "scannerCalcView", function(client, origin, angles, fov)
    local entity = client:GetViewEntity()

    if (IsValid(entity) and entity:GetClass():find("scanner")) then
        view.angles = client:GetAimVector():Angle()
        view.fov = fov - deltaZoom

        if (math_abs(deltaZoom - zoom) > 5 and nextClick < RealTime()) then
            nextClick = RealTime() + 0.05
            client:EmitSound("common/talk.wav", 50, 180)
        end

        return view
    end
end)

hook_Add("InputMouseApply", "scannerInputMouseApply", function(command, x, y, angle)
    zoom = math_Clamp(zoom + command:GetMouseWheel()*1.5, 0, 40)
    deltaZoom = Lerp(FrameTime() * 2, deltaZoom, zoom)
end)

hook_Add("PreDrawOpaqueRenderables", "scannerPreDrawOpaqueRenderables", function()
    local viewEntity = LocalPlayer():GetViewEntity()

    if (IsValid(lastViewEntity) and lastViewEntity != viewEntity) then
        lastViewEntity:SetNoDraw(false)
        lastViewEntity = nil
        LocalPlayer():EmitSound(CLICK, 50, 120)
    end

    if (IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
        viewEntity:SetNoDraw(true)

        if (lastViewEntity ~= viewEntity) then
            viewEntity:EmitSound(CLICK, 50, 140)
        end

        lastViewEntity = viewEntity

        hidden = true
    elseif (hidden) then
        hidden = false
    end
end)

hook_Add("AdjustMouseSensitivity", "scannerAdjustMouseSensitivity", function()
    if (hidden) then
        return 0.8
    end
end)

hook_Add("HUDPaint", "scannerHUDPaint", function()
    if (not hidden) then return end

    local scrW, scrH = ScrW() * 0.5, ScrH() * 0.5
    local x, y = scrW - PICTURE_WIDTH2, scrH - PICTURE_HEIGHT2

    if (lastPic and lastPic >= CurTime()) then
        local delay = 15
        local percent = math_Round(math_TimeFraction(lastPic - delay, lastPic, CurTime()), 2) * 100
        local glow = math_sin(RealTime() * 15)*25

        draw_SimpleText("RE-CHARGING: "..percent.."%", "CombineTerminalFont", x, y - 24, Color(255 + glow, 100 + glow, 25, 250))
    end

    local position = LocalPlayer():GetPos()
    local angle = LocalPlayer():GetAimVector():Angle()

    draw_SimpleText("POS ("..math_floor(position[1])..", "..math_floor(position[2])..", "..math_floor(position[3])..")", "CombineTerminalFont", x + 8, y + 8, color_white)
    draw_SimpleText("ANG ("..math_floor(angle[1])..", "..math_floor(angle[2])..", "..math_floor(angle[3])..")", "CombineTerminalFont", x + 8, y + 24, color_white)
    draw_SimpleText("ID  ("..LocalPlayer():Name()..")", "CombineTerminalFont", x + 8, y + 40, color_white)
    draw_SimpleText("ZM  ("..(math_Round(zoom / 40, 2) * 100).."%)", "CombineTerminalFont", x + 8, y + 56, color_white)

    if (IsValid(lastViewEntity)) then
        data.start = lastViewEntity:GetPos()
        data.endpos = data.start + LocalPlayer():GetAimVector() * 500
        data.filter = lastViewEntity

        local entity = util_TraceLine(data).Entity

        if (IsValid(entity) and entity:IsPlayer()) then
            entity = entity:Name()
        else
            entity = "NULL"
        end

        draw_SimpleText("TRG ("..entity..")", "CombineTerminalFont", x + 8, y + 72, color_white)
    end

    surface_SetDrawColor(235, 235, 235, 230)

    surface_DrawLine(0, scrH, x - 128, scrH)
    surface_DrawLine(scrW + PICTURE_WIDTH2 + 128, scrH, ScrW(), scrH)
    surface_DrawLine(scrW, 0, scrW, y - 128)
    surface_DrawLine(scrW, scrH + PICTURE_HEIGHT2 + 128, scrW, scrH)

    surface_DrawLine(x, y, x + 128, y)
    surface_DrawLine(x, y, x, y + 128)

    x = scrW + PICTURE_WIDTH2

    surface_DrawLine(x, y, x - 128, y)
    surface_DrawLine(x, y, x, y + 128)

    x = scrW - PICTURE_WIDTH2
    y = scrH + PICTURE_HEIGHT2

    surface_DrawLine(x, y, x + 128, y)
    surface_DrawLine(x, y, x, y - 128)

    x = scrW + PICTURE_WIDTH2

    surface_DrawLine(x, y, x - 128, y)
    surface_DrawLine(x, y, x, y - 128)

    surface_DrawLine(scrW - 48, scrH, scrW - 8, scrH)
    surface_DrawLine(scrW + 48, scrH, scrW + 8, scrH)
    surface_DrawLine(scrW, scrH - 48, scrW, scrH - 8)
    surface_DrawLine(scrW, scrH + 48, scrW, scrH + 8)
end)

hook_Add("PlayerBindPress", "scannerPlayerBindPress", function(client, bind, pressed)
    bind = bind:lower()
    if (
        bind:find("attack") and
        pressed and
        hidden and
        IsValid(lastViewEntity)
    ) then
        takePicture()
        return true
    end
end)