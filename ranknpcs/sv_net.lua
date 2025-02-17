util.AddNetworkString("impulseRankOpen")
util.AddNetworkString("impulseRankBecome")

net.Receive("impulseRankBecome", function(len, ply)
    local divisionid = net.ReadUInt(8)
    local rankid = net.ReadUInt(8)
    local div = impulse.Teams.Data[ply:Team()].classes[divisionid]
    local rank = impulse.Teams.Data[ply:Team()].ranks[rankid]
    
    if not ( ply:CanBecomeTeamClass(divisionid, true) ) then
        return
    end 
    
    if not ( ply:CanBecomeTeamRank(rankid, true) ) then
        return
    end

    if rank.xp then
        if ply:GetXP() < rank.xp then
            ply:Notify("You don't have the XP required to play as this rank.")
            return
        end
    end

    local name = (impulse.Config.CityCode or "C17").."-"..div.name.."-"..rank.name.."-"..impulse.ZeroNumber(math.random(1, 9999), 4)

    if ply:Team() == TEAM_CP then
        name = ("CP-" .. (impulse.Config.CityCode or "C17")) .. "-" .. rank.name .. "-" .. div.name .. "-" .. impulse.ZeroNumber(math.random(1, 9999), 4)
    elseif ply:Team() == TEAM_OTA then
        name = ("OTA-" .. (impulse.Config.OverwatchCode or "S17")) .. "-" .. rank.name .. "-" .. div.name .. "-" .. impulse.ZeroNumber(math.random(1, 9999), 4)
    end
    
    ply:SetRPName(name, false)
    ply:SetTeamClass(divisionid)
    ply:SetTeamRank(rankid)

    ply:Notify("Unit is now designated as "..rank.name.." "..div.name.."!")
end)