--100% not based on MrDoubleA's code!! i promise............

local blockManager = {}


function blockManager.setBlockSettings(settings)
    assert(settings.id ~= nil,"Block settings must contain 'id' field.",2)

    local config = Block.config[settings.id]

    for key,value in pairs(settings) do
        if key ~= "id" then
            config[key] = value
        end
    end

    return config
end

function blockManager.getNpcSettings(id)
    return Block.config[id]
end


blockManager.eventListeners = {[true] = {},[false] = {}}
blockManager.registeredEvents = {[true] = {},[false] = {}}


local function tryCalledEvent(npc,isEarly,eventName,...)
    local objs = blockManager.eventListeners[isEarly][eventName]
    if objs == nil then
        return
    end

    objs = objs[npc.id]
    if objs == nil then
        return
    end
    
    for _,obj in ipairs(objs) do
        local library = obj[1]
        local functionName = obj[2] or eventName

        local func = library[functionName]

        if func ~= nil then
            func(npc,...)
        end
    end
end

function blockManager.registerEvent(id, library, eventName, functionName, isEarly)
    if isEarly == nil then
        isEarly = true
    end

    if blockManager.eventListeners[isEarly][eventName] == nil then
        local normalEventName = eventName:match("^(.+)NPC$")


        blockManager.eventListeners[isEarly][eventName] = {}

        blockManager.registeredEvents[isEarly][eventName] = (function(...)
            -- Call events
            for _,npc in ipairs(Block) do
                tryCalledEvent(npc,isEarly,eventName,...)
            end
        end)

        registerEvent(blockManager.registeredEvents[isEarly],normalEventName,eventName,isEarly)
    end


    blockManager.eventListeners[isEarly][eventName]     = blockManager.eventListeners[isEarly][eventName]     or {}
    blockManager.eventListeners[isEarly][eventName][id] = blockManager.eventListeners[isEarly][eventName][id] or {}

    table.insert(blockManager.eventListeners[isEarly][eventName][id], {library,functionName})
end


blockManager.specialListeners = {}

function blockManager.registerSpecialEvent(id,library,eventName,functionName)
    blockManager.specialListeners[eventName]     = blockManager.specialListeners[eventName]     or {}
    blockManager.specialListeners[eventName][id] = blockManager.specialListeners[eventName][id] or {}

    table.insert(blockManager.specialListeners[eventName][id], {library,functionName})
end

function blockManager.callSpecialEvent(npc,eventName,...)
    local objs = blockManager.specialListeners[eventName]
    if objs == nil then
        return
    end

    objs = objs[npc.id]
    if objs == nil then
        return
    end

    for _,obj in ipairs(objs) do
        local library = obj[1]
        local functionName = obj[2] or eventName

        local func = library[functionName]

        if func ~= nil then
            func(npc,...)
        end
    end
end

return blockManager