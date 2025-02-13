AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
ENT.Base = "ent_jack_turret_base"
ENT.TargetDrones = true
ENT.TrackRate = .2
ENT.MaxTrackRange = 12000
ENT.FireRate = .25
ENT.ShotPower = 120
ENT.ScanRate = .75
ENT.ShotSpread = .002
ENT.RoundsOnBelt = 0
ENT.RoundInChamber = false
ENT.MaxCharge = 3000
ENT.ShellEffect = "RifleShellEject"
ENT.ProjectilesPerShot = 1
ENT.TurretSkin = "models/mat_jack_sniperturret"
ENT.ShotPitch = 80
ENT.NearShotNoise = "snd_jack_turretshoot_close.mp3"
ENT.FarShotNoise = "snd_jack_turretshoot_far.mp3"
ENT.AmmoType = "7.62x51mm"
ENT.MuzzEff = "muzzleflash_sr25"
ENT.BarrelSizeMod = Vector( 1, 1, 3 )
ENT.Autoloading = false
ENT.CycleSound = "snd_jack_sniperturretcycle.mp3"
ENT.MechanicsSizeMod = 1

function ENT:SpawnFunction( ply, tr )
    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create( "ent_jack_turret_sniper" )
    ent:SetPos( SpawnPos )
    ent:SetNWEntity( "Owner", ply )

    ent:Spawn()
    ent:Activate()
    local effectdata = EffectData()
    effectdata:SetEntity( ent )
    util.Effect( "propspawn", effectdata )

    return ent
end
