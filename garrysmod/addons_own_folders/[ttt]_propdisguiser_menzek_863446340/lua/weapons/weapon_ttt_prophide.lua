---- TTT Prop Disguiser ----
-- By Exho - based off Jonascone's SWEP 
-- V: 12/28/15

if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "DisguiseDestroyed" )
	util.AddNetworkString( "PD_ChatPrint" ) 
	resource.AddFile("materials/vgui/ttt/exho_propdisguiser.png")
end
--[[]]
local cvarTimer = CreateConVar("pd_timerenabled", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "The timer which disables the prop disguise after a certain amount of time")
local cvarTime = CreateConVar("pd_timertime", "30", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "How long until the prop disguise deactivates")
local cvarTimeCool = CreateConVar("pd_timercool", "6", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "How long until the next disguise")
local cvarHealth = CreateConVar("pd_health", "40", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "How much damage can the prop disguise resist before it breaks")

--[[
4:22 PM - Alm: whenever you go out of a prop
4:22 PM - Alm: Do 5 traces
4:22 PM - Alm: do one trace straight down from the prop
4:22 PM - Alm: I mean
4:22 PM - Alm: straight up*
4:23 PM - Alm: if it detects a collision within like 100 pixels
4:23 PM - Alm: move the position the player spawns at down by X units
4:23 PM - Alm: same for right, left, forward, and back
4:23 PM - Alm: that way, if it detects walls around the prop, it moves the spawn position X amount in the opposite direction
]]


if CLIENT then
	SWEP.PrintName = "Prop Disguiser"
    SWEP.Slot = 7
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
	
	SWEP.Icon = "vgui/ttt/exho_propdisguiser.png"
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Allows you to disguise yourself as a Prop!\nReload key to select a new prop.\nPrimAtt: Disguise - SecAtt Undisguise\n1sec Cooldown"
   };
end

SWEP.HoldType			= "normal"
SWEP.Base				= "weapon_tttbase"
SWEP.Kind 				= WEAPON_EQUIP
SWEP.CanBuy 			= { ROLE_TRAITOR }
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.AutoSpawnable 		= false
SWEP.ViewModel          = "models/weapons/v_pistol.mdl"
SWEP.WorldModel         = "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		= false

------ CONFIGURATION ------
SWEP.Primary.Delay 		= 1 -- Time limit after undisguising until next disguise
SWEP.Secondary.Delay	= 1 -- The exact opposite of that ^

SWEP.DisguiseProp 		= Model("models/props_c17/oildrum001.mdl") -- Default disguise model

SWEP.MaxRadius			= 100 -- Max radius of a chosen prop. If its bigger than the player cannot use it
SWEP.MinRadius			= 5 -- Min radius of a chosen prop
------ //END CONFIGURATION//------

SWEP.Prop				= nil
SWEP.Disguised			= false
SWEP.AllowDrop			= true

-- Put the Model Names of props that pass the criteria but you dont want anyone to use. Seperate each string WITH a comma
-- Example of a model path would be "models/props_junk/wood_crate001a.mdl" 
SWEP.Blacklist = {

}

local function PD_Msg(txt, ply)
	if SERVER then
			net.Start("PD_ChatPrint")
				net.WriteString(txt)
			net.Send(ply)
	end
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	
	if not self:GetNWBool("PD_WepDisguised") then
		if IsValid(self.Prop) then self.Prop:Remove() end -- Just in case the prop already exists
		ply:SetNWBool("PD_Disguised", true)
		
		if ply:HasEquipmentItem(EQUIP_RADAR) then
			ply:SetNWBool("PD_HadRadar", true)
		else
			ply:SetNWBool("PD_HadRadar", false)
		end

		--self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
		self:PropDisguise() -- The main attraction, disguise
	else
		PD_Msg("You are already disguised.", ply)
		return
	end
end

function SWEP:SecondaryAttack()
	if self:GetNWBool("PD_WepDisguised") then 
		self.Owner:SetNWBool("PD_Disguised", false)
		self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
		--self:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
		self:PropUnDisguise() 
	end
end

function SWEP:Reload()
	if self:GetNWBool("PD_WepDisguised") then -- If you are a prop, the trace 'hits' your entity. 
		PD_Msg("You can't choose a new model while disguised, silly", ply)
		return
	else
		self:ModelHandler()
	end
end

function SWEP:OnDrop()
	if self:GetNWBool("PD_WepDisguised", false) then
		self:SetNWBool("PD_WepDisguised", false)
	end
end

function SWEP:PropDisguise()
	local ply = self.Owner
	if self:GetNWBool("PD_WepDisguised") then print("HOW DID YOU GET THIS FAR??") return end -- Cant be too careful!
	--self.Disguised = true
	--self:SetNWBool("PD_TimeOut", false)
	if not IsValid(ply) or not ply:Alive() then print("Player aint valid, yo") return end
	
	if SERVER then
		-- Undisguise after the time limit
		--if cvarTimer:GetBool() then
		--	timer.Create(ply:SteamID().."_DisguiseTime", cvarTime:GetInt(), 1, function() 
		--		self:SetNWBool("PD_TimeOut", true)
		--		self:SetNextPrimaryFire(CurTime()+self.Primary.Delay + 5) -- Small delay after timer going out
		--		self:PropUnDisguise() 
		--	end)
		--end
		self.AllowDrop = false
		--ply:SetNWFloat("PD_TimeLeft", CurTime() + cvarTime:GetInt()) -- Clientside timer
		ply:SetNWBool("PD_Disguised", true) -- Shared - player disguised
		self:SetNWBool("PD_WepDisguised", true)
		
			self.Prop = ents.Create("prop_physics") -- Create our disguise
			local prop = self.Prop
		prop:SetModel(self.DisguiseProp)
		prop:SetNWEntity("spec_owner", ply)
		
		local ang = ply:GetAngles()
		ang.x = 0 -- The Angles should always be horizontal
		prop:SetAngles(ang)
		prop:SetPos(ply:GetPos() + Vector(0,0,20))
		prop.fakehp = cvarHealth:GetInt() -- Using our own health value
		prop.plyhp = ply:Health()
		prop.plycredits = ply:GetCredits() --fix for missing credits, but cant shop while propped
		ply:SetCredits( 0 )
		prop.hp_constant = cvarHealth:GetInt()
		ply:SetHealth(50) -- This is the prop's health but displayed as their own
		prop.IsADisguise = true -- Identifier for our prop
		prop.TiedPly = ply -- The Master
		prop:SetName(ply:Nick().."'s Disguised Prop") -- Prevent spectator possessing if TTT
		ply.DisguisedProp = prop
		
		prop:Spawn()
		
		local phys = prop:GetPhysicsObject()
		if not IsValid(phys) then return end
		phys:SetVelocity(ply:GetVelocity())
		ply.boughtItems = ply.bought
		
		ply.model = ply:GetModel()
		ply.color = ply:GetPlayerColor()
		
		-- Spectate it
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(self.Prop)
		ply:SelectWeapon(self:GetClass())
		ply:SetRenderMode(RENDERMODE_NONE) -- Fixes the player showing above the object
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)
		
		PD_Msg("Enabled Prop Disguise!", ply)
	end
end

function SWEP:PropUnDisguise()
	local ply = self.Owner
	local prop = self.Prop
	
	if IsValid(self.Prop) and IsValid(self.Owner) and self:GetNWBool("PD_WepDisguised") then
		prop.IsADisguise = false
		self.AllowDrop = true
		--ply:SetNWFloat("PD_TimeLeft", 0)
		ply:SetNWBool("PD_Disguised", false)
		self:SetNWBool("PD_WepDisguised", false)
		
		--timer.Destroy(ply:SteamID().."_DisguiseTime")
		
		ply:UnSpectate()
		ply:Spawn() -- We have to spawn before editing anything
		
		--for _, v in pairs( ply.boughtItems ) do
		--	ply:AddBought(v)
		--end
		
		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:SetAngles(prop:GetAngles())
		ply:SetPos(prop:GetPos())
		--if UnStuck( ply ) == 
		ply:SetHealth( prop.plyhp ) -- Clamp health, explanation below
		ply:SetCredits( prop.plycredits ) --fix for missing credits
		ply:SetVelocity(prop:GetVelocity())
		ply:DrawViewModel(true)
		ply:DrawWorldModel(true)
		ply:SelectWeapon(self:GetClass())
		prop:Remove() -- Banish our prop
		prop = nil
		
		ply:SetModel( ply.model )
		ply:SetPlayerColor( ply.color )
		
		--local tout = self:GetNWBool("PD_TimeOut", true)
		--if tout then
		--	PD_Msg("Timer ran out and you were undisguised! This weapon will cooldown for additional 5 seconds", ply)
		--else
			PD_Msg("Disabled Prop Disguise!", ply)
		--end
		if ply:GetNWBool("PD_HadRadar") then 
			ply:GiveEquipmentItem(EQUIP_RADAR)
		end
	end
end
--[[
function UnStuck ( ply )
     local pos = ply:GetPos()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos
	tracedata.filter = ply
	tracedata.mins = ply:OBBMins()
	tracedata.maxs = ply:OBBMaxs()
	local trace = util.TraceHull( tracedata )
	
	if trace.Entity and (trace.Entity:IsWorld() or trace.Entity:IsValid()) then
		return true--They're stuck.
	end
end
]]
local seen 
function SWEP:ModelHandler()
	local ply = self.Owner -- Ply is a lot easier to type
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	
	if seen then return end -- To prevent chat spamming of messages
	seen = true
	timer.Simple(1, function() seen = false end)
	
	if ent:IsPlayer() or ent:IsNPC() or ent:GetClass() == "prop_ragdoll" or tr.HitWorld or ent:IsWeapon() then
		PD_Msg("That entity is not a prop.", ply)
		return
	elseif IsValid(ent) then -- The PROP is valid
		if string.sub( ent:GetClass(), 1, 5 ) ~= "prop_" then -- The last check
			PD_Msg("That entity is not a valid prop", ply)
			return
		end
		-- This entity IS a prop without a shadow of a doubt.
		for CANT, EVEN in pairs(self.Blacklist) do
			if ent:GetModel() == EVEN then
				print("I LITERALLY CANT EVEN")
				PD_Msg("That model is blacklisted, sorry.", ply)
				return
			end
		end
		
		local mdl = ent:GetModel()
		local rad = ent:BoundingRadius() 
		if rad < self.MinRadius then -- All self explanatory
			PD_Msg("That model is too small!", ply)
			return
		elseif rad > self.MaxRadius then
			PD_Msg("That model is too big!", ply)
			return
		else -- If its not a bad prop, choose it.
			self.DisguiseProp = mdl
			PD_Msg("Set Disguise Model to ("..mdl..")!", ply)
		end
	end
end
function SWEP:DrawHUD()
	local ply = self.Owner
	local propped = ply:GetNWBool("PD_Disguised")
	local disguised = self:GetNWBool("PD_WepDisguised")
	
	if disguised and propped then
		local w = ScrW()
		local h = ScrH()
		draw.RoundedBox(2, w/2 -350, 0,700, 60, Color(0, 0, 0,200))
		draw.SimpleText("NICHT ALS PROP SHOPPEN! Es kann sein, dass man nichts bekommt.", "Trebuchet24", w/2, 27, Color(255,0,0,255), 1, 1)
	end
end
--[[
function SWEP:DrawHUD()
	local ply = self.Owner
	local propped = ply:GetNWBool("PD_Disguised")
	local disguised = self:GetNWBool("PD_WepDisguised")
	
	--print(disguised, propped)
	if disguised and propped then
		local w = ScrW()
		local h = ScrH()
		local x_axis, y_axis, width, height = 800, 98, 300, 54
		draw.RoundedBox(2, x_axis, y_axis, width, height, Color(10,10,10,200))
	
		local timeleft = ply:GetNWFloat("PD_TimeLeft") - CurTime() -- Subtract (float + Cur) from Cur
		timeleft = math.Round(timeleft or 0, 1) -- Round for simplicity
		timeleft = math.Clamp(timeleft, 0, cvarTime:GetInt()) -- Clamp to prevent negatives
		
		local Segments = width / cvarTime:GetInt() -- Divide the width into the timer 
		local CountdownBar = timeleft * Segments -- Bar length 
		CountdownBar = math.Clamp(CountdownBar, 3, 300)

		draw.RoundedBox(2, x_axis, y_axis, CountdownBar, height, Color(52, 152, 219,200))
		draw.SimpleText("Disguise: " .. timeleft, "Trebuchet24", x_axis + 160, y_axis + 27, Color(255,255,255,255), 1, 1)
	--cooldown
	elseif not disguised and not propped and CurTime() < self:GetNextPrimaryFire() then
		local w = ScrW()
		local h = ScrH()
		local x_axis, y_axis, width, height = 800, 98, 300, 54
		draw.RoundedBox(2, x_axis, y_axis, width, height, Color(10,10,10,200))
	
		local coolleft = self:GetNextPrimaryFire() - CurTime() -- Subtract (float + Cur) from Cur
		coolleft = math.Round(coolleft or 0, 1) -- Round for simplicity
		coolleft = math.Clamp(coolleft, 0, cvarTimeCool:GetInt()) -- Clamp to prevent negatives
		
		local Segments = width / cvarTimeCool:GetInt() -- Divide the width into the timer 
		local CountdownBar = coolleft * Segments -- Bar length 
		CountdownBar = math.Clamp(CountdownBar, 3, 300)

		draw.RoundedBox(2, x_axis, y_axis, CountdownBar, height, Color(214, 56, 56,200))
		draw.SimpleText("Cooldown: " .. coolleft, "Trebuchet24", x_axis + 160, y_axis + 27, Color(255,255,255,255), 1, 1)
	end
end
]]
local function DeathHandler(ply, inflictor, att)
	if ply:GetNWBool("PD_Disguised") then
		if IsValid(ply.DisguisedProp) then
			ply.DisguisedProp:Remove() -- If the player is disguised, remove their disguise.
		end
	end
end

local function DamageHandler( ent, dmginfo ) -- Entity Take Damage
	-- Damage method copied from my Destructible Doors and Door Locker addons
	if ent.IsADisguise and SERVER and IsValid(ent.TiedPly) then
		local ply = ent.TiedPly
		
		local dbug_mdl = ent:GetModel()
		local h = ent.fakehp 
		local dmg = dmginfo:GetDamage()
		ent.fakehp = h - (dmg) -- Artificially take damage for the prop
		ent.hp_constant = ent:Health() -- Make sure this stays updated
		if ent.fakehp <= 0 then 
			net.Start("DisguiseDestroyed")
			net.Send(ply) -- Tell the client to draw our fancy messages
			
			ply:SetRenderMode(RENDERMODE_NORMAL)
			ply:Kill() -- Kill the player
			
				local effectdata = EffectData() -- EFFECTS!
			effectdata:SetOrigin( ent:GetPos() + ent:OBBCenter() )
			effectdata:SetMagnitude( 5 )
			effectdata:SetScale( 2 )
			effectdata:SetRadius( 5 )
			util.Effect( "Sparks", effectdata )
			ent:Remove() -- Remove the disguise
		else
			-- Sometimes the Prop's defined Health is lower than what it should be, so it gets destroyed early. 
			-- This is a fix for it
			timer.Simple(0.5, function() -- Wait a little bit
				if not IsValid(ent) and ply:GetNWBool("PD_Disguised") then 
					-- Player is disguised but the disguise doesnt exist anymore
					print("[Prop Disguise Debug]")
					print(ply:Nick().." used wonky prop ("..dbug_mdl..") and was automatically killed!")
					print("Recommended you add this prop to the blacklist")
					ply:Kill() -- Kill the player
					net.Start("DisguiseDestroyed")
					net.Send(ply)
				end
			end)
		end
	end
end

hook.Add( "KeyPress", "KeyPressProp", function( ply, key )
	if ply:GetNWBool("PD_Disguised") then
		
		local force = 60
		local jumppower = 300
		if ply.nextboost == nil then -- boost for first time
			ply.nextboost = CurTime()
		end
		
			ply.prop = ply:GetObserverTarget()
			if not IsValid(ply.prop) then return end
			ply.phys = ply.prop:GetPhysicsObject()
			if not IsValid(ply.phys) then return end
			
			tr = ply:GetEyeTrace()			
			
			if ( key == IN_FORWARD ) then
				--ply.phys:SetVelocity( ply.phys:GetVelocity() + Vector( force, 0, 0 ) )
				ply.phys:SetVelocity( ply.phys:GetVelocity() + tr.Normal * force )
			

			elseif ( key == IN_BACK ) then
			--ply.phys:SetVelocity( ply.phys:GetVelocity() + Vector( (-1) * (force), 0, 0 ) )
			--ply.phys:GetAngles():RotateAroundAxis( Vector( 0, 1, 0 ), 5 )

			elseif  ( key == IN_MOVELEFT ) then
			--ply.phys:GetAngles():RotateAroundAxis( Vector( 1, 0, 0 ), 5 )

			
			--[[
			ply.phys:SetVelocity( ply.phys:GetVelocity() + Vector( 0, force, 0 ) )
			]]
			elseif ( key == IN_MOVERIGHT ) then
			--ply.phys:GetAngles():RotateAroundAxis( Vector( 1, 0, 0 ), -5 )
			--[[
			ply.phys:SetVelocity( ply.phys:GetVelocity() + Vector( 0, (-1) * (force), 0 ) )
			]]
			elseif ( key == IN_JUMP ) and CurTime() >= ply.nextboost then
			ply.phys:SetVelocity( ply.phys:GetVelocity() + Vector( 0, 0, jumppower ) )
			ply.nextboost = CurTime() + 3
			
			elseif ( key == IN_DUCK ) then
			ply.phys:SetVelocity( (-1) * (ply.phys:GetVelocity()) )
			
			end
			

	end
end )

--prop beschleunigen

--[[
local function Reset()
	if not GetRoundState() == ROUND_PREP then return end
	plyprep = {}
	
	timer.Simple( 0.2, function()
		for k, plytbl in pairs(player.GetHumans()) do
			if not plytbl:IsSpec() and plytbl:Alive() and plytbl:IsValid() and not plytbl:IsRagdoll() then
			if not plytbl == nil then
			table.insert( plyprep, plytbl )
			end
			end
		end	
		
		for l, p in pairs(plyprep) do
			print( p:Nick() )
			local mdl = p:GetModel()
			
			p:SetNWFloat("PD_TimeLeft", 0)
			p:SetNWBool("PD_Disguised", false)
			timer.Destroy(p:SteamID().."_DisguiseTime")
			
			if not p:IsSpec() and p:Alive() and p:IsValid() and not p:IsRagdoll() then
				p:KillSilent()
				timer.Simple( 0.2, function() 
				p:SpawnForRound(true)
				end)
			end

			p:SetRenderMode( RENDERMODE_NORMAL )
			p:SetModel( mdl )
		end	
	end )
end
]]

local function Reset()
	for k, ply in pairs(player.GetAll()) do
		print ( "PropHideReset: " .. ply:Nick() )
		local mdl = ply:GetModel()
		
		--ply:SetNWFloat("PD_TimeLeft", 0)
		ply:SetNWBool("PD_Disguised", false)
		--timer.Destroy(ply:SteamID().."_DisguiseTime")
		
		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:Spawn()
		ply:SetModel( mdl )
	end
end

--[[
local function Reset()
	if not GetRoundState() == ROUND_PREP then return end
	--plyprep = {}
	
	timer.Simple( 0.5, function()
		for _, ply in pairs( player.GetAll() ) do
			--if not ply:Nick() == nil then
				ragdollPlayer( ply )
				
				timer.Simple( 0.2, function()
				--	unragdollPlayer( ply )
				end)
				
				local mdl = ply:GetModel()
					
				ply:SetNWFloat("PD_TimeLeft", 0)
				ply:SetNWBool("PD_Disguised", false)
				timer.Destroy(p:SteamID().."_DisguiseTime")
				
				--ply:SpawnForRound(true)

				ply:SetRenderMode( RENDERMODE_NORMAL )
				ply:SetModel( mdl )
			--else
			
			--print( "ply nil" )
			print( ply:Nick() )
			--end
		end	

	end)
end

local function ragdollPlayer( v )
	if v:InVehicle() then
		local vehicle = v:GetParent()
		v:ExitVehicle()
	end

	ULib.getSpawnInfo( v ) -- Collect information so we can respawn them in the same state.

	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll.ragdolledPly = v

	ragdoll:SetPos( v:GetPos() )
	local velocity = v:GetVelocity()
	ragdoll:SetAngles( v:GetAngles() )
	ragdoll:SetModel( v:GetModel() )
	ragdoll:Spawn()
	ragdoll:Activate()
	v:SetParent( ragdoll ) -- So their player ent will match up (position-wise) with where their ragdoll is.
	-- Set velocity for each peice of the ragdoll
	local j = 1
	while true do -- Break inside
		local phys_obj = ragdoll:GetPhysicsObjectNum( j )
		if phys_obj then
			phys_obj:SetVelocity( velocity )
			j = j + 1
		else
			break
		end
	end

	v:Spectate( OBS_MODE_CHASE )
	v:SpectateEntity( ragdoll )
	v:StripWeapons() -- Otherwise they can still use the weapons.

	ragdoll:DisallowDeleting( true, function( old, new )
		if v:IsValid() then v.ragdoll = new end
	end )
	v:DisallowSpawning( true )

	v.ragdoll = ragdoll
	--ulx.setExclusive( v, "ragdolled" )
	print( "PropHide ragdolled:" .. v:Nick() )
end

local function unragdollPlayer( v )
	v:DisallowSpawning( false )
	v:SetParent()

	v:UnSpectate() -- Need this for DarkRP for some reason, works fine without it in sbox

	local ragdoll = v.ragdoll
	v.ragdoll = nil -- Gotta do this before spawn or our hook catches it

	if not ragdoll:IsValid() then -- Something must have removed it, just spawn
		ULib.spawn( v, true )

	else
		local pos = ragdoll:GetPos()
		pos.z = pos.z + 10 -- So they don't end up in the ground

		ULib.spawn( v, true )
		v:SetPos( pos )
		v:SetVelocity( ragdoll:GetVelocity() )
		local yaw = ragdoll:GetAngles().yaw
		v:SetAngles( Angle( 0, yaw, 0 ) )
		ragdoll:DisallowDeleting( false )
		ragdoll:Remove()
	end
	print( "PropHide unragdolled:" .. v:Nick() )
	--ulx.clearExclusive( v )
end
]]

hook.Add("EntityTakeDamage","CauseGodModeIsOP", DamageHandler)
hook.Add("PlayerDeath","EntDestroyeronDeath", DeathHandler)
hook.Add("PlayerSilentDeath","EntDestroyeronSilentDeath", DeathHandler)
hook.Add("TTTPrepareRound","ResetItAll", Reset)

if CLIENT then
	local white = Color( 255, 255, 255 )
	local PropDisguiseCol = Color(52, 152, 219)
	
	net.Receive( "DisguiseDestroyed", function( len, ply ) -- Recieve the message
		chat.AddText( PropDisguiseCol, "Prop Disguiser: ", white, 
		"Your disguise was destroyed and you were ",  Color( 170, 0, 0 ), "KILLED",white,"!!")
	end)
	
	net.Receive( "PD_ChatPrint", function( len, ply ) -- Recieve the message
		local txt = net.ReadString()
		chat.AddText( PropDisguiseCol, "Prop Disguiser: ", white, txt)
	end)
end

--hook.Add("TTTOrderedEquipment", "TTTPDOrderEquipment", function(ply, equipment, is_item) -- Called when a player orders something
--	if equipment == EQUIP_RADAR and ply:GetNWBool("PD_Disguised") then -- if the player ordered our item
--		ply:SetNWBool("PD_HadRadar", true) -- your code here
--	end
--end)