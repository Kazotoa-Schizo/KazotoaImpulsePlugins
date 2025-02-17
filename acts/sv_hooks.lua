function ResetGesture(ply)
    ply:Freeze(false)
    ply:leaveSequence()
end

hook.Add("PlayerDeath", "ResetGestureOnDeath", function(ply)
    timer.Simple(0.1, function()
        ResetGesture(ply)
    end)
end)