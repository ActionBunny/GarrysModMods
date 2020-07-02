include('shared.lua')

function ENT:Initialize()
	self:SetMaterial("c4_green/w/c4_green")
end

if not TTT2 then
	net.Receive("TTT_DoorBusterWarning", function()
		local idx = net.ReadUInt(16)
		local armed = net.ReadBool()
		--print("doorbusterrevived")
		if armed then
			local pos = net.ReadVector()
			RADAR.bombs[idx] = {pos=pos, nick="DoorBuster"}
		else
			RADAR.bombs[idx] = nil
		end

		RADAR.bombs_count = table.Count(RADAR.bombs)
	end)
else
	net.Receive("TTT_DoorBusterWarning", function()
		local idx = net.ReadUInt(16)
		local armed = net.ReadBit() == 1

		if armed then
			local pos = net.ReadVector()
			--local etime = net.ReadFloat()
			local team = net.ReadString()

			--RADAR.bombs[idx] = {pos = pos, t = etime, team = team}
			RADAR.bombs[idx] = {pos = pos, nick = "DoorBuster", team = team}
		else
			RADAR.bombs[idx] = nil
		end
		RADAR.bombs_count = table.Count(RADAR.bombs)
	end)
end