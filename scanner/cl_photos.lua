local CurTime = CurTime
local net_Start = net.Start
local net_SendToServer = net.SendToServer
local timer_Simple = timer.Simple
local hook_Add = hook.Add
local util_Compress = util.Compress
local render_Capture = render.Capture
local ScrW = ScrW
local net_WriteUInt = net.WriteUInt
local net_WriteData = net.WriteData
local net_Receive = net.Receive
local net_ReadData = net.ReadData
local net_ReadUInt = net.ReadUInt
local util_Base64Encode = util.Base64Encode
local util_Decompress = util.Decompress
local IsValid = IsValid
local Format = Format
local vgui_Create = vgui.Create
local os_time = os.time
local concommand_Add = concommand.Add
local ipairs = ipairs
local os_date = os.date

local PICTURE_WIDTH = 580
local PICTURE_HEIGHT = 370
local PICTURE_WIDTH2 = PICTURE_WIDTH * 0.5
local PICTURE_HEIGHT2 = PICTURE_HEIGHT * 0.5

PHOTO_CACHE = PHOTO_CACHE or {}

local startPicture = false

function takePicture()
    if ((lastPic or 0) < CurTime()) then
        lastPic = CurTime() + 15

        net_Start("impulseScannerPicture")
        net_SendToServer()

        timer_Simple(0.1, function()
            startPicture = true
        end)
    end
end


hook_Add("PostRender", "scannerPostRender", function()
    if (startPicture) then
        local data = util_Compress(render_Capture({
            format = "jpeg",
            h = PICTURE_HEIGHT,
            w = PICTURE_WIDTH,
            quality = 35,
            x = ScrW()*0.5 - PICTURE_WIDTH2,
            y = ScrH()*0.5 - PICTURE_HEIGHT2
        }))

        net_Start("impulseScannerData")
            net_WriteUInt(#data, 16)
            net_WriteData(data, #data)
        net_SendToServer()
        
        startPicture = false
    end
end)


net_Receive("impulseScannerData", function()
    local data = net_ReadData(net_ReadUInt(16))
    data = util_Base64Encode(util_Decompress(data))

    if (not data) then return end

    if (IsValid(CURRENT_PHOTO)) then
        local panel = CURRENT_PHOTO

        CURRENT_PHOTO:AlphaTo(0, 0.25, 0, function()
            if (IsValid(panel)) then
                panel:Remove()
            end
        end)
    end

    local html = Format([[
        <html>
            <body style="background: black; overflow: hidden; margin: 0; padding: 0;">
                <img src="data:image/jpeg;base64,%s" width="%s" height="%s" />
            </body>
        </html>
    ]], data, PICTURE_WIDTH, PICTURE_HEIGHT)

    local panel = vgui_Create("DPanel")
    panel:SetSize(PICTURE_WIDTH + 8, PICTURE_HEIGHT + 8)
    panel:SetPos(ScrW(), 8)
    panel:SetDrawBackground(true)
    panel:SetAlpha(150)

    panel.body = panel:Add("DHTML")
    panel.body:Dock(FILL)
    panel.body:DockMargin(4, 4, 4, 4)
    panel.body:SetHTML(html)

    panel:MoveTo(ScrW() - (panel:GetWide() + 8), 8, 0.5)

    timer_Simple(15, function()
        if (IsValid(panel)) then
            panel:MoveTo(ScrW(), 8, 0.5, 0, -1, function()
                panel:Remove()
            end)
        end
    end)

    PHOTO_CACHE[#PHOTO_CACHE + 1] = {data = html, time = os_time()}
    CURRENT_PHOTO = panel
end)

net_Receive("impulseScannerClearPicture", function()
    if (IsValid(CURRENT_PHOTO)) then
        CURRENT_PHOTO:Remove()
    end
end)

concommand_Add("impulse_photocache", function()
    local frame = vgui_Create("DFrame")
    frame:SetTitle("Photo Cache")
    frame:SetSize(480, 360)
    frame:MakePopup()
    frame:Center()

    frame.list = frame:Add("DScrollPanel")
    frame.list:Dock(FILL)
    frame.list:SetDrawBackground(false)

    for k, v in ipairs(PHOTO_CACHE) do
        local button = frame.list:Add("DButton")
        button:SetTall(28)
        button:Dock(TOP)
        button:DockMargin(4, 4, 4, 0)
        button:SetText(os_date("%X - %d/%m/%Y", v.time))
        button.DoClick = function()
            local frame2 = vgui_Create("DFrame")
            frame2:SetSize(PICTURE_WIDTH + 8, PICTURE_HEIGHT + 8)
            frame2:SetTitle(button:GetText())
            frame2:MakePopup()
            frame2:Center()

            frame2.body = frame2:Add("DHTML")
            frame2.body:SetHTML(v.data)
            frame2.body:Dock(FILL)
            frame2.body:DockMargin(4, 4, 4, 4)
        end
    end
end)