--copy /b love.exe+game.love smr.exe

if love.filesystem.isFused() then
    local dir = love.filesystem.getSourceBaseDirectory()
    local success = love.filesystem.mount(dir, "", true)
end

require 'scripts/base/engine/main'