--if SERVER then
   AddCSLuaFile( "shared.lua" )
  -- resource.AddFile("materials/vgui/ttt/lykrast/icon_cloak.vmt")
   resource.AddFile("materials/vgui/ttt/lykrast/icon_cloaking.png")
  --resource.AddFile("vgui/ttt/lykrast/icon_cloaking.png")
--end

if( CLIENT ) then
    SWEP.PrintName = "Cloaking Device";
    SWEP.Slot = 7;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
    SWEP.Icon = "vgui/ttt/lykrast/icon_cloaking.png";
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Hold it to become nearly invisible.\n\nDoesn't hide your name or\nbloodstains on your body."
   };

end

SWEP.Author= "Lykrast"


SWEP.Base = "weapon_tttbase"
SWEP.Spawnable= false
SWEP.AdminSpawnable= true
SWEP.HoldType = "slam"
 
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
 
SWEP.ViewModelFOV= 60
SWEP.ViewModelFlip= false
SWEP.ViewModel      = "models/weapons/c_slam.mdl"
SWEP.WorldModel      = "models/weapons/w_slam.mdl"
SWEP.UseHands	= true
 
 --- PRIMARY FIRE ---
SWEP.Primary.Delay= 0.5
SWEP.Primary.Recoil= 0
SWEP.Primary.Damage= 0
SWEP.Primary.NumShots= 1
SWEP.Primary.Cone= 0
SWEP.Primary.ClipSize= -1
SWEP.Primary.DefaultClip= -1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo         = "none"
SWEP.NoSights = true
SWEP.AllowDrop = false

function SWEP:PrimaryAttack()
   return false
end

function SWEP:DrawWorldModel() -- Thanks v_hana :)
	-- if not IsValid(self.Owner) then -- Well let's test this way then
	-- 	self:DrawWorldModel()
	-- end
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Cloak()
    self.Owner:SetColor( Color(255, 255, 255, 3) ) 			
    self.Owner:SetMaterial( "sprites/heatwave" )
	self.Owner:DrawShadow(false)
    -- self.Weapon:SetMaterial("sprites/heatwave")
    self:EmitSound( "AlyxEMP.Charge" )
    -- self.Owner:DrawWorldModel( false ) -- Thanks v_hana :)
    self.conceal = true
end

function SWEP:UnCloak()
    self.Owner:SetMaterial("models/glass")
	self.Owner:DrawShadow(true)
    -- self.Weapon:SetMaterial("models/glass")
    self:EmitSound( "AlyxEMP.Discharge" )
    -- self.Owner:DrawWorldModel( true ) -- Thanks v_hana :)
    self.conceal = false
end

function SWEP:Deploy()
   self:Cloak()
end

function SWEP:Holster()

if ( self.conceal ) then
    self:UnCloak()
end
	
return true

end
 
function SWEP:PreDrop()

if ( self.conceal ) then
    self:UnCloak()
end
 
end

function SWEP:OnDrop() --Hopefully this'll work
   self:Remove()
end

hook.Add("TTTPrepareRound", "UnCloakAll",function()
    for k, v in pairs(player.GetAll()) do
        v:SetMaterial("models/glass")
    end
end
)