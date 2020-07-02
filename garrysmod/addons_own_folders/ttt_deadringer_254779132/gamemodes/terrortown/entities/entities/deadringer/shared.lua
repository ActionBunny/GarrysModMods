-- First of all, this code from "Hat maker" addon by CapsAdmin. So credits to him for this code. 
--_____________________________________________________________________
-- This is new "worldmodel" for Dead Ringer, because the model doesn't have custom holdtype animations and etc...

-- Niandra's note; if you want the world model not to be invisible, comment or delete line 19, SetNoDraw, delete the /* and */ to
-- uncomment out the rigging stuff and then in the shared.lua of weapon_dead_ringer, go to line 162 and change 'normal' to
-- 'self.HoldType'

ENT.Type = "anim"
  
if SERVER then   
AddCSLuaFile("shared.lua")

function ENT:Initialize()   
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )
	self:DrawShadow(false)
	self:SetModel("models/ttt/c_models/c_pocket_watch.mdl")
	self:SetNoDraw( true )
end

	function ENT:Think()
		local player = self:GetOwner() 
		self:SetColor(player:GetColor())
		self:SetMaterial(player:GetMaterial())
end 
end  
  
 /* 
if CLIENT then  
    function ENT:Draw() 
-- some lines of code were modified, cause i dont need all bones, only right hand.	
        local p = self:GetOwner():GetRagdollEntity() or self:GetOwner()
        local hand = p:LookupBone("ValveBiped.Bip01_R_Hand")  
        if hand then  
            local position, angles = p:GetBonePosition(hand)
			
            local x = angles:Up() * (-0.25 )
            local y = angles:Right() * 1.40  
            local z = angles:Forward() * 3.42
  
            local pitch = 89.20
            local yaw = -1.31
            local roll = 105.27

            angles:RotateAroundAxis(angles:Forward(), pitch)  
            angles:RotateAroundAxis(angles:Right(), yaw)  
            angles:RotateAroundAxis(angles:Up(), roll)  
			
            self:SetPos(position + x + y + z)  
            self:SetAngles(angles)  
        end  
		local eyepos = EyePos()  
		local eyepos2 = LocalPlayer():EyePos()  
		if  eyepos:Distance(eyepos2) > 5 or LocalPlayer() != self:GetOwner() then
			self:DrawModel()
		end
    end  
end 

/*