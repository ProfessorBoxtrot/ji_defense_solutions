AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
ENT.Base = "ent_jack_turret_base"
ENT.TargetDrones = true
ENT.TrackRate = 1.25
ENT.MaxTrackRange = 1500
ENT.FireRate = 14
ENT.ShotPower = 40
ENT.ScanRate = 2
ENT.ShotSpread = .034
ENT.RoundsOnBelt = 0
ENT.RoundInChamber = false
ENT.MaxCharge = 3000
ENT.ShellEffect = "ShellEject"
ENT.ProjectilesPerShot = 1
ENT.TurretSkin = "models/mat_jack_pistolturret"
ENT.ShotPitch = 110
ENT.NearShotNoise = "snd_jack_turretshootshort_close.mp3"
ENT.FarShotNoise = "snd_jack_turretshootshort_far.mp3"
ENT.AmmoType = "9x19mm"
ENT.MuzzEff = "muzzleflash_pistol"
ENT.Automatic = true
ENT.BarrelSizeMod = Vector( 1, 1, 1 )
ENT.Autoloading = true
ENT.MechanicsSizeMod = 1.5

function ENT:SpawnFunction( ply, tr )
    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create( "ent_jack_turret_smg" )
    ent:SetPos( SpawnPos )
    ent:SetNWEntity( "Owner", ply )

    ent:Spawn()
    ent:Activate()
    local effectdata = EffectData()
    effectdata:SetEntity( ent )
    util.Effect( "propspawn", effectdata )

    return ent
end
