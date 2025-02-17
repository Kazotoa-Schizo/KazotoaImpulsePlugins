net.Receive("impulseRankOpen", function()
    if not ( LocalPlayer():IsCP() ) then
        return
    end
    
    vgui.Create("impulseRankMenu")
end)