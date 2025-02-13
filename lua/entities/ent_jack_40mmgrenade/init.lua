include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/Items/AR2_Grenade.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_NONE )
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
        phys:SetMass( 7 )
    end

    self:Fire( "enableshadow", "", 0 )
    self.Exploded = false
    self.ExplosiveMul = 0.5
end

function ENT:PhysicsCollide( data )
    if data.Speed > 80 and data.DeltaTime > 0.2 then
        self:Detonate()
    end
end

function ENT:OnTakeDamage( dmginfo )
    self:TakePhysicsDamage( dmginfo )
end

function ENT:Detonate()
    if self.Exploding then return end
    self.Exploding = true
    local pos = self:GetPos()

    util.ScreenShake( pos, 99999, 99999, 1, 750 )
    local attacker = self:GetNWEntity( "Owner" )
    if IsValid( attacker ) then
        attacker = attacker:GetCreator()
    end
    util.BlastDamage( self, attacker, pos, 190, 190 )

    for _ = 0, 30 do
        local effectTrace = util.QuickTrace( pos, VectorRand() * 200, { self } )

        if effectTrace.Hit then
            util.Decal( "FadingScorch", effectTrace.HitPos + effectTrace.HitNormal, effectTrace.HitPos - effectTrace.HitNormal )
        end
    end

    self:Remove()
end
