include('shared.lua')

LANG.AddToLanguage("english", "mine_turtle_full", "You currently cannot carry more Menzelmine's")
LANG.AddToLanguage("english", "mine_turtle_disarmed", "A Menzelmine you've planted has been disarmed.")

ENT.PrintName = "Menzelmine"
ENT.Icon = "vgui/ttt/icon_mine_turtle"


if not TTT2 then
	net.Receive("TTT_MineTurtleWarning", function()
		local idx = net.ReadUInt(16)
		local armed = net.ReadBool()

		if armed then
			local pos = net.ReadVector()
			RADAR.bombs[idx] = {pos=pos, nick="Menzelmine"}
		else
			RADAR.bombs[idx] = nil
		end

		RADAR.bombs_count = table.Count(RADAR.bombs)
	end)
else
	net.Receive("TTT_MineTurtleWarning", function()
		local idx = net.ReadUInt(16)
		local armed = net.ReadBit() == 1

		if armed then
			local pos = net.ReadVector()
			--local etime = net.ReadFloat()
			local team = net.ReadString()

			--RADAR.bombs[idx] = {pos = pos, t = etime, team = team}
			RADAR.bombs[idx] = {pos = pos, nick = "Menzelmine", team = team}
		else
			RADAR.bombs[idx] = nil
		end
		RADAR.bombs_count = table.Count(RADAR.bombs)
	end)
end