AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( "shared.lua" )
ENT.Base = "ent_jack_turret_base"

local HULL_TARGETING = {
    [HULL_TINY] = -5,
    [HULL_TINY_CENTERED] = 0,
    [HULL_SMALL_CENTERED] = -5,
    [HULL_HUMAN] = 10,
    [HULL_WIDE_SHORT] = 20,
    [HULL_WIDE_HUMAN] = 15,
    [HULL_MEDIUM] = 0,
    [HULL_MEDIUM_TALL] = 35,
    [HULL_LARGE] = 30,
    [HULL_LARGE_CENTERED] = 30
}

ENT.TargetDrones = true
ENT.TrackRate = .2
ENT.MaxTrackRange = 20000
ENT.FireRate = .1
ENT.ShotPower = 150
ENT.ScanRate = .75
ENT.ShotSpread = .005
ENT.RoundsOnBelt = 0
ENT.RoundInChamber = false
ENT.MaxCharge = 3000
ENT.ShellEffect = "RifleShellEject"
ENT.ProjectilesPerShot = 1
ENT.TurretSkin = "models/mat_jack_rocketturret"
ENT.ShotPitch = 100
ENT.NearShotNoise = "snd_jack_turretmissilelaunch_close.mp3"
ENT.FarShotNoise = "snd_jack_turretmissilelaunch_far.mp3"
ENT.AmmoType = "ATrocket"
ENT.MuzzEff = "muzzle_center_M82"
ENT.BarrelSizeMod = Vector( .01, .01, .01 )
ENT.Autoloading = false
ENT.CycleSound = "snd_jack_glcycle.mp3"
ENT.MechanicsSizeMod = 2.2

function ENT:SpawnFunction( ply, tr )
    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create( "ent_jack_turret_rocket" )
    ent:SetPos( SpawnPos )
    ent:SetNWEntity( "Owner", ply )

    ent:Spawn()
    ent:Activate()
    local effectdata = EffectData()
    effectdata:SetEntity( ent )
    util.Effect( "propspawn", effectdata )

    return ent
end

function ENT:GetCenterMassOf( ent )
    if not IsValid( ent ) then return Vector( 0, 0, 0 ) end
    local Pos = ent:LocalToWorld( ent:OBBCenter() )
    local Hull

    if not ent.GetHullType then
        Hull = HULL_HUMAN
    else
        Hull = ent:GetHullType()
    end

    local Add = Vector( 0, 0, HULL_TARGETING[Hull] )

    if string.find( ent:GetClass(), "vehicle", 1, false ) or string.find( ent:GetClass(), "car", 1, false ) or string.find( ent:GetClass(), "hoverball", 1, false ) or string.find( ent:GetClass(), "thruster", 1, false ) then
        Add = Vector( 0, 0, 0 )
    end

    local Vel = Vector( 0, 0, 0 )
    local Phys = ent:GetPhysicsObject()

    if IsValid( Phys ) then
        Vel = Phys:GetVelocity()
    else
        Vel = ent:GetVelocity()
    end

    local Dist = ( self:GetPos() - ent:GetPos() ):Length()
    Vel = Vel * Dist / 3500
    Pos = Pos + Add + Vel

    if ent:IsPlayer() and ent:Crouching() then
        Pos = Pos - Vector( 0, 0, 20 )
    end

    return Pos
end

function ENT:FireShot()
    self:StandBy()

    self.BatteryCharge = self.BatteryCharge - .1

    if self.WillWarn then
        if not ( self.NextWarnTime < CurTime() ) then
            if self.NextWarnTime < CurTime() then
                self:HostileAlert()
                self.NextWarnTime = CurTime() + 1
            end

            return
        end
    end

    if self.RoundInChamber then
        local SelfPos = self:GetPos() + self:GetUp() * 55
        local TargPos

        TargPos = self:GetCenterMassOf( self.CurrentTarget )

        local Dist = ( self:GetPos() - TargPos ):Length()

        if Dist <= 500 then
            self:HostileAlert()
            self.MissileLocked = false

            return
        end

        self:EmitSound( self.NearShotNoise )
        self:EmitSound( self.FarShotNoise )
        local Vec = TargPos - SelfPos
        local Dir = Vec:GetNormalized()
        Dir = ( Dir + VectorRand() * self.ShotSpread ):GetNormalized()
        local Spred = self.ShotSpread
        --fire round
        local Miss = ents.Create( "ent_jack_turretrocket" )
        Miss.ParentLauncher = self
        Miss:SetNWEntity( "Owner", self )
        Miss:SetPos( SelfPos - self:GetRight() * 5 + Dir * 40 + Vector( 0, 0, 5 ) )
        local Ang = Dir:Angle()
        Ang:RotateAroundAxis( Ang:Up(), 90 )
        Miss:SetAngles( Ang )
        constraint.NoCollide( self, Miss )
        Miss.InitialVel = self:GetPhysicsObject():GetVelocity() + Dir * 1000
        Miss:Spawn()
        Miss:Activate()
        Miss:GetPhysicsObject():SetVelocity( Miss.InitialVel )
        local PosAng = self:GetAttachment( 1 )
        local ThePos = PosAng.Pos + PosAng.Ang:Forward() * 25
        ParticleEffect( self.MuzzEff, ThePos, PosAng.Ang, self )
        local effectd = EffectData()
        effectd:SetStart( ThePos )
        effectd:SetNormal( PosAng.Ang:Forward() )
        effectd:SetScale( 1 )
        util.Effect( "eff_jack_turretmuzzlelight", effectd, true, true )
        PosAng.Ang:RotateAroundAxis( PosAng.Ang:Right(), 180 )
        ThePos = PosAng.Pos + PosAng.Ang:Forward() * 40
        ParticleEffect( self.MuzzEff, ThePos, PosAng.Ang, self )
        local effectd = EffectData()
        effectd:SetStart( ThePos )
        effectd:SetNormal( PosAng.Ang:Forward() )
        effectd:SetScale( 1 )
        util.Effect( "eff_jack_turretmuzzlelight", effectd, true, true )
        self.FiredAtCurrentTarget = true
        self.RoundInChamber = false
        self.RoundsOnBelt = 0
        self.NextNoMovementCheckTime = CurTime() + 5
        self:SetDTBool( 2, self.RoundInChamber )
        self.RoundsOnBelt = 0
        util.BlastDamage( self, self:GetCreator(), SelfPos - Dir * 75, 50, 50 )
        self:GetPhysicsObject():ApplyForceOffset( -Dir * self.ShotPower * 6 * self.ProjectilesPerShot, SelfPos + self:GetUp() * 20 )
    else
        if self.NextWhineTime < CurTime() then
            self:Whine()
            self.NextWhineTime = CurTime() + 2.25
        end
    end
end

function ENT:DetachAmmoBox()
    self.RoundsOnBelt = 0
    self.HasAmmoBox = false
    self:SetDTBool( 0, self.HasAmmoBox )
    local Box = ents.Create( "ent_jack_turretrocketpod" )
    Box.AmmoType = self.AmmoType
    Box.Empty = true
    Box:SetPos( self:GetPos() - self:GetRight() * 10 + self:GetUp() * 30 - self:GetForward() * 10 )
    Box:SetAngles( self:GetUp():Angle() )
    Box:Spawn()
    Box:Activate()
    Box:GetPhysicsObject():SetVelocity( self:GetPhysicsObject():GetVelocity() - self:GetForward() * 20 - self:GetRight() * 20 )
    self:EmitSound( "snd_jack_missileunload.mp3" )
    SafeRemoveEntityDelayed( Box, 30 )
end

function ENT:RefillAmmo( box )
    self.HasAmmoBox = true
    self:SetDTBool( 0, self.HasAmmoBox )
    self.RoundInChamber = true
    self:SetDTBool( 2, self.RoundInChamber )
    self.RoundsOnBelt = 1
    self:EmitSound( "snd_jack_missileload.mp3" )
    SafeRemoveEntity( box )
end
