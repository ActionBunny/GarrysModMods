if SERVER then 
	util.AddNetworkString("killmessages")
	
	hook.Add("PlayerDeath", "KillMessage", function(vic, inf, atk)
		timer.Simple( 1.1, function ()
			net.Start("killmessages")
			net.WriteEntity(atk)
			--print(atk)
			if IsValid(atk) && atk:IsPlayer() then
				if vic:GetNWBool("ASCCanRespawn") then
					--print("yesASC")
				else
					net.WriteString(atk:GetRoleString())
					net.Send(vic)
					--print("noASC")
				end
			else 
				net.WriteString("world")
				net.Send(vic)
			end	
		end)	
	end)
end 