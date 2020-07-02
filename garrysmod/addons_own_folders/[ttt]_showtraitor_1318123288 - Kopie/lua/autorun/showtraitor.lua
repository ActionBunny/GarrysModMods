if SERVER then
	util.AddNetworkString( "ShowTraitor" )
	util.AddNetworkString( "ShowTraitorStart" )
	util.AddNetworkString( "ShowTraitorFail" )
end

	-- local text = net.ReadString()
	-- local roleData = sender:GetSubRoleData() -- use cached role

	-- chat.AddText(
		-- sender:GetRoleColor(),
		-- Format("(%s) ", string.upper(GetTranslation(roleData.name))),
		-- color_4,
		-- sender:Nick(),
		-- color_5,
		-- ": " .. text

-- client:ChatPrint("Your current role is: '" .. client:GetSubRoleData().name .. "'")
	


if CLIENT then
	white = Color(255,255,255,255)
	red = Color(255,0,0,255)
	green = Color(0,255,0,255)
	net.Receive( "ShowTraitorStart", function()
		chat.AddText( green, "Traitor werden dir in 10s angezeigt.")
	end)	
	
	net.Receive( "ShowTraitorFail", function()
		chat.AddText( red, "Fehler. ", white, "Du lebst noch.")
	end)
	
	net.Receive( "ShowTraitor", function()
		
		chat.AddText( white, "Traitor sind: ")
		chat.AddText( red, net.ReadString() )
	
	end)
end		
		
		
function chatCommandTraitor( ply, text, public )
    if  (string.sub( string.lower(text), 1) == "!t") then
		if ply:Alive() then 
			net.Start( "ShowTraitorFail")
				net.WriteString("Fail")
			net.Send( ply )
		end
		if IsValid(ply) and not ply:Alive() then
			net.Start( "ShowTraitorStart")
				net.WriteString("Start")
			net.Send( ply )
		end
		
		timer.Simple( 10, function()
			if IsValid(ply) and not ply:Alive() then
				net.Start( "ShowTraitor")	
				
					local traitor = ""
					
					for _,v in pairs( player.GetAll() ) do
						if  v:GetRole() == ROLE_TRAITOR then
							traitor = traitor .. v:Nick() .. "\n"
						end
					end		
					net.WriteString(traitor)
				net.Send( ply )
			end
		end)
	end
end
hook.Add( "PlayerSay", "showtraitorchat", chatCommandTraitor )