local EventManager = {}

EventManager.eventsList = {
    "onTick","onTickEnd",
    "onDraw","onDrawEnd",
	"onCameraUpdate",
	"onCameraDraw",
	
    "onNPCHarm","onPostNPCHarm",
    "onNPCKill","onPostNPCKill",
	
	"onBlockHit", "onPostBlockHit",
	"onBlockDestroyed", "onPostBlockDestroyed",
	
	"onPause", "onUnpause",
}


EventManager.listeners = {[true] = {},[false] = {}}


function EventManager.callListeners(eventName,isEarly,...)
    local objs = EventManager.listeners[isEarly][eventName]

    if objs ~= nil then
        for _,obj in ipairs(objs) do
            local library = obj[1]
            local functionName = obj[2] or eventName

            local func = library[functionName]

            if func ~= nil then
                func(...)
            end
        end
    end
end


function EventManager.callEvent(eventName,...)
    EventManager.callListeners(eventName, true, ...)
    EventManager.callListeners(eventName, false, ...)
end

function registerEvent(library,eventName,functionName,isEarly)
    if isEarly == nil then
        isEarly = true
    end

    EventManager.listeners[isEarly][eventName] = EventManager.listeners[isEarly][eventName] or {}

    table.insert(EventManager.listeners[isEarly][eventName], {library,functionName})
end

_G.EventManager = EventManager