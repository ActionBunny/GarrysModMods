AddCSLuaFile()
resource.AddFile( "materials/markus/background1.png" )
resource.AddFile( "materials/markus/background2.png" )
resource.AddFile( "materials/markus/background3.png" )
resource.AddFile( "materials/markus/ttt_icon.png" )
resource.AddFile( "sound/weapons/rede.wav" )
resource.AddFile( "sound/weapons/cut.wav" )

sound.Add{
	name = "hitler_cut",
    channel=CHAN_STATIC,
	level=SNDLVL_70dB,
	sound = "weapons/cut.wav",
    volume=1,
    pitch=100
}

sound.Add{
	name = "hitlerrede",
    channel=CHAN_STATIC,
	level=SNDLVL_70dB,
	sound = "weapons/rede.wav",	
	volume=1,
    pitch=100
}
--[[
sound.Add{
	name = "null",
    channel=CHAN_STATIC,
    volume=1,
    level=120,
    pitch=100,
	sound = "common/null.wav"
}
]]
--[[ Weapon Info ]]--

SWEP.PrintName = "MarkusLauncher"
SWEP.Author = "ActionBunny"

--SWEP.AutoSwitchTo = false
--SWEP.AutoSwitchFrom = false

SWEP.Slot = 6
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.HoldType = "physgun"
SWEP.ViewModelFlip	= false
SWEP.ViewModelFOV	= 55
SWEP.Weight = 5

SWEP.ViewModel = "models/weapons/v_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1.5 
SWEP.Primary.Damage = 78
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.ClipMax = 1
SWEP.Primary.Delay = 1
SWEP.DeploySpeed = 0.5

SWEP.Secondary.Delay = 2

markustable = {}
table.insert( markustable, "models/props_c17/oildrum001.mdl" )
table.insert( markustable, "models/props_interiors/radiator01a.mdl" )
table.insert( markustable, "models/props_junk/bicycle01a.mdl" )
table.insert( markustable, "models/props_junk/trashbin01a.mdl" )
table.insert( markustable, "models/props_junk/cinderblock01a.mdl" )
table.insert( markustable, "models/props_junk/sawblade001a.mdl" )
table.insert( markustable, "models/props_c17/canister02a.mdl" )
table.insert( markustable, "models/props_c17/cashregister01a.mdl" )
table.insert( markustable, "models/props_wasteland/controlroom_filecabinet001a.mdl" )
table.insert( markustable, "models/props_wasteland/controlroom_filecabinet002a.mdl" )
table.insert( markustable, "models/props_borealis/bluebarrel001.mdl" )
table.insert( markustable, "models/props_c17/streetsign003b.mdl" )
table.insert( markustable, "models/props_junk/harpoon002a.mdl" )

local metaEnts = FindMetaTable( "Entity")
AccessorFunc( metaEnts, "markusthrower", "MarkusThrower" )
AccessorFunc( metaEnts, "markusswep", "MarkusSWEP" )
AccessorFunc( metaEnts, "markusply", "MarkusPly" )

--[[
local LoadedSounds
if CLIENT then
	LoadedSounds = {} -- this table caches existing CSoundPatches
end

local function ReadSound( FileName, ent )
	local sound
	local filter
	if SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
	end
	if SERVER or !LoadedSounds[FileName] then
		-- The sound is always re-created serverside because of the RecipientFilter.
		sound = CreateSound( ent, FileName, filter ) -- create the new sound, parented to the worldspawn ( which always exists )
		if sound then
			sound:SetSoundLevel( 0 ) -- play everywhere
			if CLIENT then
				LoadedSounds[FileName] = { sound, filter } -- cache the CSoundPatch
			end
		end
	else
		sound = LoadedSounds[FileName][1]
		filter = LoadedSounds[FileName][2]
	end
	if sound then
		if CLIENT then
			sound:Stop() -- it won't play again otherwise
		end
		sound:Play()
	end
	return sound -- useful if you want to stop the sound yourself
end
]]
-- When we are ready, we play the sound:


function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.markusActive = "false"
end

--[[ TTT Information ]]--

SWEP.EquipMenuData = {
	type = "item_weapon",
	desc = [[
		Smash a high-velocity prop in innocent faces.
		Markus + Menzel + HL2 = 4evarIn<3
	]]
}

SWEP.Icon = "markus/ttt_icon.png"
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

if ( GAMEMODE.Name == "Trouble in Terrorist Town" ) then
	SWEP.Slot = 7
end

net.Receive( "MarkusSecondaryStart", function()
	timeSend = tonumber( net.ReadFloat() )
	--curTime = tonumber( CurTime() )
	--chat.AddText( "XXX" .. timeSend  )
	--chat.AddText( "XXX" .. curTime  )
	local function perkIconHUD()
		if ( timeSend + 7 ) > tonumber( CurTime() ) then
			surface.SetMaterial(Material("markus/background1.png"))
			surface.SetDrawColor( 255, 255, 255, 100 )
			surface.DrawTexturedRect( 0,0,ScrW(),ScrH() )
		elseif (timeSend + 15 ) > tonumber( CurTime() ) then
			surface.SetMaterial(Material("markus/background2.png"))
			surface.SetDrawColor( 255, 255, 255, 100 )
			surface.DrawTexturedRect( 0,0,ScrW(),ScrH() )
		else
			surface.SetMaterial(Material("markus/background3.png"))
			surface.SetDrawColor( 255, 255, 255, 100 )
			surface.DrawTexturedRect( 0,0,ScrW(),ScrH() )		
		end
	end
	hook.Add( "HUDPaint", "perkHUDPaintIconMarkus", perkIconHUD )
end )

net.Receive( "MarkusSecondaryStop", function()
	hook.Remove( "HUDPaint", "perkHUDPaintIconMarkus" )
end )
	
function SWEP:IsEquipment() return true end

function SWEP:PrimaryAttack()
	
	if not self:CanPrimaryAttack() then return false end
	
	wep = self.Weapon
	--wep:EmitSound( "weapons/hitler_cut.wav" )
	wep:EmitSound( "hitler_cut" )
	
	ply = self.Owner
	
	markusmodel = markustable[ math.random( #markustable ) ]

	self:TakePrimaryAmmo( 1 )

	if (CLIENT) then return end
	
	local ang = self.Owner:EyeAngles() 
	prop = ents.Create( "prop_physics" )
	prop.Shooter = self.Owner
	prop:SetModel( markusmodel )	
	prop:SetPos( self.Owner:GetShootPos() + ang:Forward() * 50 + ang:Right() * 1 - ang:Up() * 1 )
	prop:SetAngles( ang )
	
	prop:SetMarkusThrower( self.Owner )
	prop:SetMarkusSWEP( self )
	
	prop:Spawn()

	
	local phys = prop:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:SetMass( 250 )
		local velocity = self.Owner:GetAimVector()
		velocity = velocity * 500000
		velocity = velocity + ( VectorRand() * 1 ) 
		phys:ApplyForceCenter( velocity )
	end

end

hook.Add( "EntityTakeDamage", "MarkusPropDamage", function( ent, dmginfo )
	if ent:IsPlayer() and IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "prop_physics" and IsValid( dmginfo:GetInflictor():GetMarkusThrower() )and IsValid( dmginfo:GetInflictor():GetMarkusSWEP() ) then

		dmginfo:SetAttacker( dmginfo:GetInflictor():GetMarkusThrower() )
		dmginfo:SetInflictor( dmginfo:GetInflictor():GetMarkusSWEP() )
		dmginfo:ScaleDamage( 2 )
		dmginfo:SetDamageType( DMG_GENERIC )

	end
end
)

function SWEP:Holster()
	ply = self.Owner
	
	if SERVER then
		net.Start( "MarkusSecondaryStop" )
			--net.WriteFloat( CurTime() )
			net.Broadcast()
		--net.Send( ply )
	end
	
	ply:SetNWString("MarkusIsActive","false")
	
	--local sound = ReadSound( "weapons/hitlerrede.wav", self.Weapon )
	--sound:Stop()
	
	return true
end

function SWEP:OnDrop()
	if IsValid( self:GetMarkusPly( ply ) ) then
		ply = self:GetMarkusPly( ply )

		if SERVER then
			net.Start( "MarkusSecondaryStop" )
				--net.WriteFloat( CurTime() )
				net.Broadcast()
			--net.Send( ply )
		end
		ply:SetNWString("MarkusIsActive","false")
		--local sound = ReadSound( "weapons/hitlerrede.wav", self.Weapon )
		--sound:Stop()
		--hook.Remove( "HUDPaint", "perkHUDPaintIconMarkus" )
	end
end

if SERVER then
	util.AddNetworkString( "MarkusSecondaryStart" )
	util.AddNetworkString( "MarkusSecondaryStop" )
end

function SWEP:SecondaryAttack()
	ply = self.Owner
	self:SetMarkusPly( ply )
	
	markusActive = ply:GetNWString("MarkusIsActive","false")
	
	--local sound = ReadSound( "weapons/hitlerrede.wav", self.Weapon )
	
	if SERVER then

		if markusActive == "true" then
			if SERVER then
				net.Start( "MarkusSecondaryStop" )
					--net.WriteFloat( CurTime() )
					net.Broadcast()
				--net.Send( ply )
			end
			ply:SetNWString("MarkusIsActive","false")
		else
			if SERVER then
			net.Start( "MarkusSecondaryStart" )
				net.WriteFloat( CurTime() )
				net.Broadcast()
			--net.Send( ply )
			end
			ply:SetNWString("MarkusIsActive","true")

		end
	end	
	
	if markusActive == "false" then
		--sound:Play()
		self:EmitSound( "hitlerrede" )
	else
		--sound:Stop()
		self:StopSound( "hitlerrede" )
	end
end

if CLIENT then
	function SWEP:DrawHUD()
		print ( "draw" )
		local x = math.floor(ScrW() / 2.0)
		local y = math.floor(ScrH() / 2.0)
		
		l = 10
		k = l/2
		r = 14
		if self.Owner:IsTraitor() then
			surface.SetDrawColor(255, 50, 50, 255)
		else
			surface.SetDrawColor(0, 255, 0, 255)
		end
		
		surface.DrawLine( x - k , y + k, x + k, y - k)
		surface.DrawLine( x - k , y - k, x + k, y + k)
		surface.DrawLine( x - l , y, x - k, y + k)
		surface.DrawLine( x - k , y - k, x, y - l)
		surface.DrawLine( x + k , y - k, x + l, y)
		surface.DrawLine( x + k , y + k, x, y + l)
		
		if self.Owner:IsTraitor() then
			surface.DrawCircle( x, y, r, 255, 50, 50, 255 )
		else
			surface.DrawCircle( x, y, r, 0, 255, 0, 255 )
		end
	end
end

local function Resetting()
	for _,ply in pairs(player.GetAll()) do
		--timer.Simple(1,function() hook.Remove( "HUDPaint", "perkHUDPaintIconMarkus" ) end)
		if SERVER then
			net.Start( "MarkusSecondaryStop" )
				--net.WriteFloat( CurTime() )
				net.Broadcast()
			--net.Send( ply )
		end
		ply:SetNWString("MarkusIsActive","false")
	end
	
	--local sound = ReadSound( "weapons/hitlerrede.wav", self.Weapon )
	--sound:Stop()
	--LoadedSounds = {}
end

hook.Add( "TTTPrepareRound", "TTTMarkusLauncherPrepareRound", Resetting )