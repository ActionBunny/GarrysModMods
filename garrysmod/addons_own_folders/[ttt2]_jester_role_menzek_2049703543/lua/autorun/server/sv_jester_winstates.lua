-- local function JesterTakeNoDamage(ply, attacker)
	-- if not IsValid(ply) or ply:GetSubRole() ~= ROLE_JESTER then return end

	-- if IsValid(attacker) and attacker ~= ply then return end

	-- return true -- true to block damage event
-- end

-- local function JesterDealNoDamage(ply, attacker)
	-- if not IsValid(ply) or not IsValid(attacker) or not attacker:IsPlayer() or attacker:GetSubRole() ~= ROLE_JESTER then return end

	-- return true -- true to block damage event
-- end

local function SpawnJesterConfetti(ply)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_JESTER then return end

	if not IsValid(attacker) or attacker == ply then return end

	net.Start("NewConfetti")
	net.WriteEntity(ply)
	net.Broadcast()

	ply:EmitSound("ttt2/birthdayparty.mp3")
end

-- local function JesterRevive(ply, fn)
	-- ply:Revive(3, function(p)
		-- fn(p)
	-- end,
	-- function(p)
		-- return IsValid(p)
	-- end) -- revive after 3s
-- end

hook.Add("PlayerTakeDamage", "JesterDamage", function(ply, inflictor, killer, amount, dmginfo)
	--jester looses if he damages someone
	if IsValid(ply) and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and (dmginfo:GetAttacker():GetSubRole() == ROLE_JESTER) then
		--jester damaged someone
		print("jester damaged someone")
		dmginfo:GetAttacker().damagedSomeOne = true
		dmginfo:GetAttacker():Kill()
	end
end)

local winstates_death
winstates_death = {
	-- if the jester is killed, he has won
	[1] = function(ply, killer)
		if not killer:IsPlayer() or killer == ply or killer:GetTeam() == TEAM_TRAITOR then return end
		
		LANG.MsgAll("ttt2_role_jester_killed_by_player", {nick = killer:Nick()}, MSG_MSTACK_PLAIN)
		
		if JESTER.damagedSomeOne == false then
			if killer:GetBaseRole() == ROLE_DETECTIVE then
				print("jester killed by detective")
				JESTER.winBonus = GetConVar("ttt_jester_winBonusByDetective"):GetFloat()
			else
				JESTER.winBonus = GetConVar("ttt_jester_winBonus"):GetFloat()
			end
			
			JESTER.shouldWin = true
			return true
		else
			JESTER.shouldWin = false
			return false
		end
		
	end,

	-- Jester respawns after three seconds with a random opposite role of his killer
}

-- Jester deals no damage to other players
-- hook.Add("PlayerTakeDamage", "JesterNoDamage", function(ply, inflictor, killer, amount, dmginfo)
	-- if JesterTakeNoDamage(ply, killer) or JesterDealNoDamage(ply, killer) then
		-- dmginfo:ScaleDamage(0)
		-- dmginfo:SetDamage(0)

		-- return
	-- end
-- end)

hook.Add("TTT2PostPlayerDeath", "JesterPostDeath", function(ply, inflictor, killer)
	if not IsValid(ply) or ply:GetSubRole() ~= ROLE_JESTER or ply:GetForceSpec() or not IsValid(killer) then return end
	
	-- only handle jester winstates if round is active
	if GetRoundState() ~= ROUND_ACTIVE then return end

	if winstates_death[JESTER.winstate](ply, killer) then
		SpawnJesterConfetti(ply)
	end
end)

-- reset hooks at round end
hook.Add("TTTEndRound", "JesterEndRound", function()
	for _, v in ipairs(player.GetAll()) do
		hook.Remove("PostPlayerDeath", "JesterWaitForKillerDeath_" .. v:SteamID64())
	end

	JESTER.shouldWin = false
	JESTER.damagedSomeOne = false
end)
