if SERVER then
	AddCSLuaFile("")

	util.AddNetworkString("ColoredChatMessage")
	local ply = FindMetaTable("Player")

	function ply:ColoredChatPrintTTTThing( ... )
		local args = { ... }

		net.Start("ColoredChatMessage")
		net.WriteTable( args )
		net.Send( self )
	end
    else
	net.Receive("ColoredChatMessage", function( len )
		local args = net.ReadTable()
		chat.AddText( Color(0, 255, 255), "In dieser Runde gibt es ", Color(255, 255, 255), unpack(args) )
	end)
end
