if SERVER then
	util.AddNetworkString( "ShowTraitor" )
	util.AddNetworkString( "ShowTraitorStart" )
	util.AddNetworkString( "ShowTraitorFail" )
	module("roles", package.seeall)
end

if CLIENT then
	white = Color(255,255,255,255)
	red = Color(255,0,0,255)
	green = Color(0,255,0,255)
	net.Receive( "ShowTraitorStart", function()
		chat.AddText( green, "Traitor werden dir in 9s angezeigt.")
	end)	
	
	net.Receive( "ShowTraitorFail", function()
		chat.AddText( red, "Fehler. ", white, "Du lebst noch.")
	end)
	
	net.Receive( "ShowTraitor", function()
		num = net.ReadInt(4)
		for i = 1, num do

			r = net.ReadInt(16)
			g = net.ReadInt(16)
			b = net.ReadInt(16)
			a = net.ReadInt(16)
					

			role = net.ReadString()
			ply = net.ReadString()
			
			chat.AddText(  Color(r,g,b,a), role )
			chat.AddText(  white, ply )
		end	
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
				
				local plys = player.GetAll()
				
				local roles = {}
				
				for i = 1, #plys do
				  local x = plys[i]
					

					if roles[x:GetSubRoleData().ClassName] == nil then
						roles[x:GetSubRoleData().ClassName] = {["color"] = x:GetSubRoleData().color, ["players"] = {}}
					end
					table.insert(roles[x:GetSubRoleData().ClassName]["players"], x:Nick())
				end
				
				local num = 0
			
				
				for k,v in pairs(roles) do
					num = num + 1
				end
				
				PrintTable(roles)
				
				print(num)
				
				net.WriteInt(num, 4)
								
				for k,v in pairs(roles) do
					-- net.WriteColor(roles[k]["color"])
					
					net.WriteInt(tonumber(roles[k]["color"]["r"]),16)
					net.WriteInt(tonumber(roles[k]["color"]["g"]),16)
					net.WriteInt(tonumber(roles[k]["color"]["b"]),16)
					net.WriteInt(tonumber(roles[k]["color"]["a"]),16)
					
					net.WriteString(k)

					tmp_role = roles[k]

					local plystring = ''
					
					for m,n in pairs(tmp_role["players"]) do
						plystring = plystring .. n .. "  "
					end
					net.WriteString(plystring)
				end
	
				net.Send( ply )
			end
		end)
	end
end
hook.Add( "PlayerSay", "showtraitorchat", chatCommandTraitor )