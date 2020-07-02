local function GlowingTTT()
	local mates = {}

	if LocalPlayer().IsActiveEvil then
		for k, v in pairs(player.GetAll()) do
			if v != LocalPlayer() and v:IsActive() and LocalPlayer():IsSpecial() and ( ( v:GetTeam() == LocalPlayer():GetTeam() and not LocalPlayer():GetDetective() ) or ( v:GetRole() == LocalPlayer():GetRole() ) ) and not LocalPlayer():IsShinigami() then
				table.insert(mates, v)
			end
		end
	else
		for k, v in pairs(player.GetAll()) do
			if v:IsActiveTraitor() and v != LocalPlayer() then
				table.insert(mates, v)
			elseif v:IsActiveDetective() and v != LocalPlayer() then
				table.insert(mates, v)
			end
		end
	end

	if #mates == 0 then return end
	
	for _, v in pairs(mates) do
		local clr = Color(255, 0, 0)
		if v:GetRoleTable().DefaultColor then
			clr = v:GetRoleTable().DefaultColor
		elseif v:IsTraitor() then
			clr = Color(255, 0, 0)
		elseif v:IsDetective() then
			clr = Color(0, 0, 255)
		end
		halo.Add({ v }, clr, 0, 0, 3, true, true)
	end

end

local function CheckTTTGlow()
    if gamemode.Get("terrortown") then
        hook.Add("PreDrawHalos", "AddTTTTeamGlow", GlowingTTT)
    end
end
hook.Add("PostGamemodeLoaded", "LoadTTTTeamGlow", CheckTTTGlow)
