CreateConVar( "ttt_flashbang_amount", "2", FCVAR_NOTIFY + FCVAR_ARCHIVE , "Adjust the amount of flashbangs." )

if (SERVER) then --the init.lua stuff goes in here
   AddCSLuaFile ("shared.lua")
end

if (CLIENT) then --the init.lua stuff goes in here


	SWEP.PrintName = "Flashbang"
	SWEP.SlotPos = 2
	SWEP.IconLetter			= "g"
	SWEP.NameOfSWEP			= "weapon_ttt_flashbang" --always make this the name of the folder the SWEP is in.
	
	SWEP.EquipMenuData = {
	   type = "item_weapon",
	   desc = "Best Flash you've/ll ever see/n - NOT FOR ISA!"
   };

end

SWEP.Primary.NumNades = GetConVar("ttt_flashbang_amount"):GetFloat() --number of throwable grenades at your disposal
SWEP.Grenade = "ttt_thrownflashbang" --self explanitory

local here = true
SWEP.Author = "Converted by Porter"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.Base = "weapon_tttbasegrenade"

SWEP.ViewModel			= "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel			= "models/weapons/w_eq_flashbang.mdl"
SWEP.ViewModelFlip		= true
SWEP.AutoSwitchFrom		= true

SWEP.DrawCrosshair		= false

SWEP.IsGrenade = true
SWEP.NoSights = true

SWEP.was_thrown = false

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.LimitedStock = false
SWEP.Icon = "icons/icon_flashbang.png"

SWEP.Primary.ClipSize = GetConVar("ttt_flashbang_amount"):GetFloat()
SWEP.Primary.DefaultClip = GetConVar("ttt_flashbang_amount"):GetFloat()
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "slam"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "slam"

function SWEP:Throw()
   if CLIENT then
      self:SetThrowTime(0)
   elseif SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end
		self.was_thrown = false
      if self.was_thrown then return end
	
      self.was_thrown = true

      local ang = ply:EyeAngles()
      local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())+ (ang:Forward() * 8) + (ang:Right() * 10)
      local target = ply:GetEyeTraceNoCursor().HitPos
      local tang = (target-src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards
      -- Makes the grenade go upgwards
      if tang.p < 90 then
         tang.p = -10 + tang.p * ((90 + 10) / 90)
      else
         tang.p = 360 - tang.p
         tang.p = -10 + tang.p * -((90 + 10) / 90)
      end
      tang.p=math.Clamp(tang.p,-90,90) -- Makes the grenade not go backwards :/
      local vel = math.min(800, (90 - tang.p) * 6)
      local thr = tang:Forward() * vel + ply:GetVelocity()
      self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)

      self:SetThrowTime(0)
      self:TakePrimaryAmmo( 1 )
	  if self.Weapon:Clip1() == 0 then 
		self.Owner:StripWeapon("weapon_ttt_flashbang")
	end
		 
   end
end

function SWEP:GetGrenadeName()
   return "ttt_thrownflashbang"
end