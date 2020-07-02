
local killmsg = {}
killmsg.chatcolor = Color(255,255,255,255)
killmsg.namecolor = Color(255,255,0,255)
killmsg.detective = Color(0,171,255,200)
killmsg.traitor = Color(206,0,0,0)
killmsg.innocent = Color(0,183,27,129)

net.Receive("killmessages", function()
	local atk = net.ReadEntity()
	local role = net.ReadString()

	if role == "world" then
		chat.AddText(killmsg.chatcolor, "Durch Welt ausgeschaltet.")
	elseif atk:IsValid() && atk:Nick() == LocalPlayer():Nick() then 
		chat.AddText(killmsg.chatcolor, "Du hast es geschafft dich selbst zu erledigen.")
	elseif role == "traitor" then
		chat.AddText(killmsg.chatcolor, "Du wurdest von ", killmsg.namecolor, atk:Nick(), killmsg.chatcolor," erledigt. Rolle: ", killmsg.traitor, role..".")
	elseif role == "detective" then
		chat.AddText(killmsg.chatcolor, "Du wurdest von ", killmsg.namecolor, atk:Nick(), killmsg.chatcolor," erledigt. Rolle: ", killmsg.detective, role..".")
	elseif role == "innocent" then
		chat.AddText(killmsg.chatcolor, "Du wurdest von ", killmsg.namecolor, atk:Nick(), killmsg.chatcolor, " erledigt. Rolle: ", killmsg.innocent, role..".")
	else
		chat.AddText(killmsg.chatcolor, "Das hier sollte nicht angezeigt werden. Bitte kontaktiere den Ersteller um das Problem zu beseitigen.")
	end
end)
