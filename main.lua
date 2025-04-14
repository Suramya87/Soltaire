local Game = require("game")
--require "game"
function love.load()
    love.window.setTitle("Klondike Solitaire")
    love.window.setMode(1024, 768)
    love.graphics.setBackgroundColor(0,0.7,0.2,1)
    Game:load()
end

function love.update(dt)
    Game:update(dt)
end

function love.draw()
    Game:draw()
end

function love.mousepressed(x, y, button)
    Game:mousepressed(x, y, button)
end
