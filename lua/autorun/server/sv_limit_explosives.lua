local isValid = IsValid
local limits = {
    m9k_proxy = 4,
    npc_satchel = 15
}

local function getExplosivesTable( ply, class )
    if limits[class] == nil then return end

    ply.placedExplosives = ply.placedExplosives or {}
    ply.placedExplosives[class] = ply.placedExplosives[class] or {}

    return ply.placedExplosives[class]
end

local function getOwner( ent )
    local owner = ent:GetInternalVariable( "m_hThrower" )
    if isValid( owner ) then return owner end

    owner = ent.Owner
    if isValid( owner ) then return owner end

    owner = ent.ProxyBombOwner
    if isValid( owner ) then return owner end
end

local function onExplosiveCreated( ent )
    if not isValid( ent ) then return end

    local class = ent:GetClass()
    if not limits[class] then return end

    local owner = getOwner( ent )
    if not owner then return end

    local explosives = getExplosivesTable( owner, class )
    if explosives == nil then return end

    table.insert( explosives, 1, ent )

    if #explosives > limits[class] then
        SafeRemoveEntity( explosives[#explosives] )
        explosives[#explosives] = nil
    end
end

local function onExplosiveRemoved( ent )
    if not isValid( ent ) then return end

    local class = ent:GetClass()

    if not limits[class] then return end

    local owner = getOwner( ent )
    if not owner then return end

    local explosives = getExplosivesTable( owner, class )
    if explosives == nil then return end

    table.RemoveByValue( explosives, ent )
end

hook.Remove( "OnEntityCreated", "CFC_LimitExplosives" )
hook.Add( "OnEntityCreated", "CFC_LimitExplosives", function( ent )
    timer.Simple( 0, function()
        onExplosiveCreated( ent )
    end )
end )

hook.Remove( "EntityRemoved", "CFC_LimitExplosives" )
hook.Add( "EntityRemoved", "CFC_LimitExplosives", onExplosiveRemoved )
