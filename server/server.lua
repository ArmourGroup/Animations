------------------------------------------------------------------------------------------------------------------------
--  REQUIRE
------------------------------------------------------------------------------------------------------------------------
local Config = require('config.server')
local Shared = require('config.shared')
------------------------------------------------------------------------------------------------------------------------
--  VARIABLE
------------------------------------------------------------------------------------------------------------------------
Objects = {}
------------------------------------------------------------------------------------------------------------------------
--  FUNCTION
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--  STATE BAG
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--  EXPORTS
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--  CALLBACK
------------------------------------------------------------------------------------------------------------------------
lib.callback.register('ArmourAnimations:server:createObject', function(source, Model, x, y, z, Weapon)
    local SpawnObjects = 0
    local Hash = GetHashKey(Model)
    local Object = CreateObject(Hash, x, y, z, true, true, false)

    while not DoesEntityExist(Object) and SpawnObjects <= 1000 do
        SpawnObjects = SpawnObjects + 1
        Wait(1)
    end

    local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity(Object)
    if DoesEntityExist(Object) then
        if Weapon then
            if not Objects[source] then
                Objects[source] = {}
            end

            Objects[source][Weapon] = NetworkGetNetworkIdFromEntity
        else
            if not Objects[source] then
                Objects[source] = {}
            end

            Objects[source][NetworkGetNetworkIdFromEntity] = true
        end

        return true, NetworkGetNetworkIdFromEntity
    end

    return false
end)
------------------------------------------------------------------------------------------------------------------------
--  EVENTS
------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('ArmourAnimations:server:deleteObject')
AddEventHandler('ArmourAnimations:server:deleteObject', function(Index, Value)
    local source = source

    if Value and Objects[source] and Objects[source][Value] then
        Index = Objects[source][Value]
        Objects[source][Value] = nil
    end

    TriggerEvent('ArmourAnimations:server:deleteObjectServer', Index)
end)

AddEventHandler('ArmourAnimations:server:deleteObjectServer', function(entIndex)
    local idNetwork = NetworkGetEntityFromNetworkId(entIndex)
    if DoesEntityExist(idNetwork) and not IsPedAPlayer(idNetwork) and GetEntityType(idNetwork) == 3 then
        DeleteEntity(idNetwork)
    end
end)
------------------------------------------------------------------------------------------------------------------------
--  COMMANDS
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--  THREAD
------------------------------------------------------------------------------------------------------------------------
