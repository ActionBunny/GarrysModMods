--CONFIGURATION
--local TraitorGlow = true --To draw the effect for traitors.
--local DetectiveGlow = true --To draw the effect for detectives.

local TraitorGlowColor = Color(255, 0, 0) --The color for the traitor glow effect.
local DetectiveGlowColor = Color(0, 0, 255) --The color for the detective glow effect.
local InnocentGlowColor = Color(0, 255, 0)

local TraitorGlowIntensity = 3 --How big the effect is for traitors.
local DetectiveGlowIntensity = 3 --How big the effect is for detectives.

local TraitorWall = true --Can traitors see other traitors through walls?
local DetectiveWall = false --Can detectives see other detectives through walls?
--END OF CONFIGURATION

CreateClientConVar("ttt_traitor_glow", "1", true, false)
CreateClientConVar("ttt_detective_glow", "1", true, false)

local function GlowingTTT()
	local traitors = {}
	local detectives = {}
	
	for k, v in pairs(player.GetAll()) do
		if v:IsActiveTraitor() and v != LocalPlayer() then
			table.insert(traitors, v)
		elseif v:IsActiveDetective() and v != LocalPlayer() then
			table.insert(detectives, v)
		end
	end

	if LocalPlayer():IsActiveTraitor() and TraitorGlow then
		if GetConVar("ttt_traitor_glow"):GetInt() == 1 then
			halo.Add(traitors, TraitorGlowColor, 0, 0, TraitorGlowIntensity, true, TraitorWall)
		end
	elseif LocalPlayer():IsActiveDetective() and DetectiveGlow then
		if GetConVar("ttt_detective_glow"):GetInt() == 1 then
			halo.Add(detectives, DetectiveGlowColor, 0, 0, DetectiveGlowIntensity, true, DetectiveWall)
		end
	end
end

local function GamemodeLoadGlowingTTT()
	if ( engine.ActiveGamemode() == "terrortown" ) then
		hook.Add("PreDrawHalos", "AddHalos", GlowingTTT)
	end
end
hook.Add( "PostGamemodeLoaded", "GamemodeLoadGlowingTTT", GamemodeLoadGlowingTTT )