if SERVER then
	function ulx.roundbalance( calling_ply, steamid )
	    --local nick = calling_ply:GetName()
	    name = ULib.bans[ steamid ] and ULib.bans[ steamid ].name
		ULib.unban( steamid, calling_ply )
		calling_ply:RemovePData("slaynr_slays")
    end
    local roundbalance = ulx.command( CATEGORY_NAME, "ulx roundbalance", ulx.roundbalance )
    roundbalance:addParam{ type=ULib.cmds.StringArg, hint="steamid" }
    roundbalance:defaultAccess( ULib.ACCESS_ALL )
end
