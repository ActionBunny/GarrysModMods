function nightvision( player, command, arguments )
    player:ConCommand("r_screenoverlay effects/NIGHTVISION_overlay.vmt")
	player:ConCommand("play snapon.wav")
	end

function normalvision( player, command, arguments )
	player:ConCommand("r_screenoverlay 0")
	player:ConCommand("play snapoff.wav")
end

concommand.Add( "Nightvisionon", nightvision )
concommand.Add( "Nightvisionoff", normalvision )
