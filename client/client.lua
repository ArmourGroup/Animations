------------------------------------------------------------------------------------------------------------------------
--  REQUIRE
------------------------------------------------------------------------------------------------------------------------
local Config = require('config.client')
local Shared = require('config.shared')
------------------------------------------------------------------------------------------------------------------------
--  VARIABLE
------------------------------------------------------------------------------------------------------------------------
local animVars = { nil, nil, false, 49 }
------------------------------------------------------------------------------------------------------------------------
--  FUNCTION
------------------------------------------------------------------------------------------------------------------------
lib.addKeybind({
    name = 'left',
    description = 'Interação da seta esquerda.',
    defaultKey = 'left',
    onPressed = function()
        if not QBX.PlayerData.metadata.inlaststand and not IsPedInAnyVehicle(cache.ped, false) and not IsPedArmed(cache.ped, 7) and not IsPedSwimming(cache.ped) then
            exports.Animations:PlayAnim(true, { 'anim@mp_player_intupperthumbs_up', 'enter' }, false)
        end
    end
})

lib.addKeybind({
    name = 'right',
    description = 'Interação da seta direita.',
    defaultKey = 'right',
    onPressed = function()
        if not QBX.PlayerData.metadata.inlaststand and not IsPedInAnyVehicle(cache.ped, false) and not IsPedArmed(cache.ped, 7) and not IsPedSwimming(cache.ped) then
            exports.Animations:PlayAnim(true, { 'anim@mp_player_intcelebrationmale@face_palm', 'face_palm' },
                false)
        end
    end
})

lib.addKeybind({
    name = 'up',
    description = 'Interação da seta pra cima.',
    defaultKey = 'up',
    onPressed = function()
        if not QBX.PlayerData.metadata.inlaststand and not IsPedInAnyVehicle(cache.ped, false) and not IsPedArmed(cache.ped, 7) and not IsPedSwimming(cache.ped) then
            exports.Animations:PlayAnim(true, { 'anim@mp_player_intcelebrationmale@salute', 'salute' }, false)
        end
    end
})

lib.addKeybind({
    name = 'down',
    description = 'Interação da seta pra baixo.',
    defaultKey = 'down',
    onPressed = function()
        if not QBX.PlayerData.metadata.inlaststand and not IsPedInAnyVehicle(cache.ped, false) and not IsPedArmed(cache.ped, 7) and not IsPedSwimming(cache.ped) then
            exports.Animations:PlayAnim(true, { 'rcmnigel1c', 'hailing_whistle_waive_a' }, false)
        end
    end
})

lib.addKeybind({
    name = 'cancel',
    description = 'Cancelar todas as ações.',
    defaultKey = 'f6',
    onPressed = function()
        if not not QBX.PlayerData.metadata.inlaststand then
            exports.Animations:Destroy()
        end
    end
})

local function LoadNetwork(Network)
    Wait(100)

    if NetworkDoesNetworkIdExist(Network) then
        local Object = NetToEnt(Network)

        if DoesEntityExist(Object) then
            NetworkRequestControlOfEntity(Object)
            while not NetworkHasControlOfEntity(Object) do
                Wait(1)
            end

            SetEntityAsMissionEntity(Object, true, true)
            while not IsEntityAMissionEntity(Object) do
                Wait(1)
            end

            return Object
        end
    end

    return false
end

local function StopAnim(Upper)
    Active = false

    if Upper then
        ClearPedSecondaryTask(cache.ped)
    else
        ClearPedTasks(cache.ped)
    end
end

local function Destroy(Mode)
    if IsPedUsingScenario(cache.ped, 'PROP_HUMAN_SEAT_CHAIR_UPRIGHT') then
        TriggerEvent('target:UpChair')
    elseif IsEntityPlayingAnim(cache.ped, 'amb@world_human_sunbathe@female@back@idle_a', 'idle_a', 3) then
        TriggerEvent('target:UpBed')
    end

    if Mode == 'one' then
        StopAnim(true)
    elseif Mode == 'two' then
        StopAnim(false)
    else
        StopAnim(true)
        StopAnim(false)
    end

    animVars[3] = false

    if DoesEntityExist(Object) then
        TriggerServerEvent('ArmourAnimations:server:deleteObject', ObjToNet(Object))
        Object = nil
    end
end

local function CreateObjects(Dict, Anim, Prop, Flag, Hands, Height, Pos1, Pos2, Pos3, Pos4, Pos5)
    if DoesEntityExist(Object) then
        TriggerServerEvent('ArmourAnimations:server:deleteObject', ObjToNet(Object))
        Object = nil
    end

    if Anim ~= '' then
        if lib.requestAnimDict(Dict) then
            TaskPlayAnim(cache.ped, Dict, Anim, 8.0, 8.0, -1, Flag, 1, 0, 0, 0)
        end

        animVars[4] = Flag
        animVars[3] = true
        animVars[1] = Dict
        animVars[2] = Anim
    end

    if not IsPedInAnyVehicle(cache.ped, false) then
        local Coords = GetEntityCoords(cache.ped)
        local Progression, Network = lib.callback.await('ArmourAnimations:server:createObject', false, Prop, Coords
            ['x'], Coords['y'], Coords['z'])
        if Progression then
            Object = LoadNetwork(Network)
            if Object then
                if Height then
                    AttachEntityToEntity(Object, cache.ped, GetPedBoneIndex(cache.ped, Hands), Height, Pos1, Pos2, Pos3,
                        Pos4, Pos5,
                        true, true, false, true, 1, true)
                else
                    AttachEntityToEntity(Object, cache.ped, GetPedBoneIndex(cache.ped, Hands), 0.0, 0.0, 0.0, 0.0, 0.0,
                        0.0, true,
                        true, false, true, 2, true)
                end
            else
                Object = nil
            end

            SetModelAsNoLongerNeeded(Prop)
        end
    end
end

local function PlayAnim(Upper, Sequency, Loop)
    if Sequency['task'] then
        StopAnim(true)

        if Sequency['task'] == 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER' then
            local Coords = GetEntityCoords(cache.ped)
            local Heading = GetEntityHeading(cache.ped)
            TaskStartScenarioAtPosition(cache.ped, Sequency['task'], Coords['x'], Coords['y'], Coords['z'] - 1, Heading,
                0, false, false)
        else
            TaskStartScenarioInPlace(cache.ped, Sequency['task'], 0, false)
        end
    else
        Flags = 0
        StopAnim(Upper)

        if lib.requestAnimDict(Sequency[1]) then
            if Upper then
                Flags = Flags + 48
            end

            if Loop then
                Flags = Flags + 1
            end

            Dict = Sequency[1]
            Name = Sequency[2]

            if Flags == 49 then
                Active = true
            end

            TaskPlayAnim(cache.ped, Sequency[1], Sequency[2], 8.0, 8.0, -1, Flags, 0, false, false, false)
        end
    end
end
------------------------------------------------------------------------------------------------------------------------
--  STATE BAG
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--  EXPORTS
------------------------------------------------------------------------------------------------------------------------
exports('CreateObjects', CreateObjects)
exports('PlayAnim', PlayAnim)
exports('Destroy', Destroy)
------------------------------------------------------------------------------------------------------------------------
--  CALLBACK
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--  EVENTS
------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('ArmourAnimations:client:init')
AddEventHandler('ArmourAnimations:client:init', function(Name)
    if Config.Anim[Name] and not IsPedArmed(cache.ped, 7) and not IsPedSwimming(cache.ped) then
        Destroy('one')

        if not IsPedInAnyVehicle(cache.ped, false) and not Config.Anim[Name]['cars'] then
            if Config.Anim[Name]['height'] and not Config.Anim[Name]['anim'] then
                CreateObjects('', '', Config.Anim[Name]['prop'], Config.Anim[Name]['flag'], Config.Anim[Name]
                    ['hand'],
                    Config.Anim[Name]['height'], Config.Anim[Name]['pos1'], Config.Anim[Name]['pos2'],
                    Config.Anim[Name]['pos3'],
                    Config.Anim[Name]['pos4'], Config.Anim[Name]['pos5'])
            elseif Config.Anim[Name]['height'] and Config.Anim[Name]['anim'] then
                CreateObjects(Config.Anim[Name]['dict'], Config.Anim[Name]['anim'], Config.Anim[Name]['prop'],
                    Config.Anim[Name]['flag'],
                    Config.Anim[Name]['hand'], Config.Anim[Name]['height'], Config.Anim[Name]['pos1'],
                    Config.Anim[Name]['pos2'],
                    Config.Anim[Name]['pos3'], Config.Anim[Name]['pos4'], Config.Anim[Name]['pos5'])
            elseif Config.Anim[Name]['prop'] then
                CreateObjects(Config.Anim[Name]['dict'], Config.Anim[Name]['anim'], Config.Anim[Name]['prop'],
                    Config.Anim[Name]['flag'],
                    Config.Anim[Name]['hand'])
            elseif Config.Anim[Name]['dict'] then
                PlayAnim(Config.Anim[Name]['walk'], { Config.Anim[Name]['dict'], Config.Anim[Name]['anim'] },
                    Config.Anim[Name]['loop'])
            else
                PlayAnim(false, { task = Config.Anim[Name]['anim'] }, false)
            end
        else
            if IsPedInAnyVehicle(cache.ped, false) and Config.Anim[Name]['cars'] then
                local Vehicle = GetVehiclePedIsUsing(cache.ped)

                if (GetPedInVehicleSeat(Vehicle, -1) == cache.ped or GetPedInVehicleSeat(Vehicle, 1) == cache.ped) and Name == 'sexo4' then
                    PlayAnim(Config.Anim[Name]['walk'], { Config.Anim[Name]['dict'], Config.Anim[Name]['anim'] },
                        Config.Anim[Name]['loop'])
                elseif (GetPedInVehicleSeat(Vehicle, 0) == cache.ped or GetPedInVehicleSeat(Vehicle, 2) == cache.ped) and (Name == 'sexo5' or Name == 'sexo6') then
                    PlayAnim(Config.Anim[Name]['walk'], { Config.Anim[Name]['dict'], Config.Anim[Name]['anim'] },
                        Config.Anim[Name]['loop'])
                elseif Name == 'hotwired' then
                    PlayAnim(Config.Anim[Name]['walk'], { Config.Anim[Name]['dict'], Config.Anim[Name]['anim'] },
                        Config.Anim[Name]['loop'])
                end
            end
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------
--  NUI
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
--  COMMANDS
------------------------------------------------------------------------------------------------------------------------
RegisterCommand('e', function(_, args)
    if args[1] then
        TriggerEvent('ArmourAnimations:client:init', args[1])
    end
end)
------------------------------------------------------------------------------------------------------------------------
--  THREAD
------------------------------------------------------------------------------------------------------------------------
