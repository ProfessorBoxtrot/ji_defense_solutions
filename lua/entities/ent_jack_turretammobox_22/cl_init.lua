include( "shared.lua" )
ENT.Base="ent_jack_turretammobox_base"
function ENT:Draw()
	self:DrawModel()
end

language.Add("ent_jack_ammobox_22",".22LR AmmoBox")