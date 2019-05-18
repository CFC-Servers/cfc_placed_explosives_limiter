local limits = {
    m9k_proxy = 4
}

local function getExplosivesTable(ply, class)
    if limits[class] == nil then return end
    
    ply.placedExplosives = ply.placedExplosives or {}
    ply.placedExplosives[class] = ply.placedExplosives[class] or {}
    
    return ply.placedExplosives[class]
end

local function onExplosiveCreated( owner, ent )
    if not IsValid( owner ) then return end
    if not IsValid( ent ) then return end

    local class = ent:GetClass()
    local explosives = getExplosivesTable( owner, class )
    if explosives == nil then return end
    
    table.insert( explosives, 1, ent )
    
    if #explosives > limits[class] then
        explosives[#explosives]:Remove()
        explosives[#explosives] = nil
    end

end

local function onExplosiveRemoved( owner, ent )
    if not IsValid( owner ) then return end
    if not IsValid( ent ) then return end
    
    local explosives = getExplosivesTable(owner, ent:GetClass())
    if explosives == nil then return end
    table.RemoveByValue( explosives, ent ) 
end

hook.Remove("OnEntityCreated", "CFC_LimitExplosives")
hook.Add("OnEntityCreated", "CFC_LimitExplosives", function( ent )
    -- the entity has no owner until the next tick
    timer.Simple( 0, function() 
        onExplosiveCreated( ent.Owner, ent )
    end)
end)

hook.Remove("EntityRemoved", "CFC_LimitExplosives")
hook.Add("EntityRemoved", "CFC_LimitExplosives", function( ent )
     onExplosiveRemoved ( ent.Owner, ent )
end)