include( "shared.lua" )

function ENT:Initialize()
    self.Prettiness = ClientsideModel( "models/props_explosive/explosive_butane_can.mdl" )
    self.Prettiness:SetPos( self:GetPos() )
    self.Prettiness:SetParent( self )
    self.Prettiness:SetNoDraw( true )
    local Matricks = Matrix()
    Matricks:Scale( Vector( .85, .85, .625 ) )
    self.Prettiness:EnableMatrix( "RenderMultiply", Matricks )
    self.Prettiness:SetMaterial( "models/mat_jack_aidfuel_naturalgas" )
end

function ENT:Draw()
    self.Prettiness:SetRenderOrigin( self:GetPos() - self:GetUp() * 6.25 )
    local Ang = self:GetAngles()
    self.Prettiness:SetRenderAngles( Ang )
    self.Prettiness:DrawModel()
end

language.Add( "ent_jack_aidfuel_naturalgas", "Natural Gas Canister" )