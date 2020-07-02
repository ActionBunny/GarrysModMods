local function CheckEveryone()
	local traitors = 0
	local innocents = 0
	local detectives = 0

	for k, v in pairs(player.GetAll()) do
		if not (v:Alive() and v:IsTerror()) then
			continue
		end

		if v:IsRole(ROLE_INNOCENT) then
			innocents = innocents + 1
		elseif v:IsRole(ROLE_TRAITOR) then
			traitors = traitors + 1
		else
			detectives = detectives + 1
		end
	end

	for k, v in pairs(player.GetAll()) do
		-- Chat part here
		local text = {Color(255, 0, 0), traitors .. " Traitor(s)", Color(255, 255, 255), detectives > 0 and ", " or " und ", Color(0, 255, 0), innocents .. " Innocent(s)"}
		if detectives > 0 then
			local detectivesStuff = {Color(255, 255, 255), " und ", Color(0, 0, 255), detectives .. " Detektiv(e)"}
			table.Add(text, detectivesStuff)
		end
		v:ColoredChatPrintTTTThing(unpack(text))
	end
end
hook.Add("TTTBeginRound", "TTTChatStats", CheckEveryone)


