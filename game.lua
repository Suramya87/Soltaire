local Deck = require("deck")
local Pile = require("pile")

local Game = {}
Game.__index = Game

function Game:load()
    self.deck = Deck:new()
    self.deck:shuffle()

    self.piles = {}
    for i = 1, 7 do
        local pile = Pile:new(100 + (i - 1) * 100, 150)
        for j = 1, i do
            local card = self.deck:drawCard()
            card.faceUp = (j == i)
            pile:addCard(card)
        end
        table.insert(self.piles, pile)
    end
end

function Game:update(dt)
end

function Game:draw()
    for _, pile in ipairs(self.piles) do
        pile:draw()
    end
end

function Game:mousepressed(x, y, button)
    -- Placeholder for interaction logic
end

return Game
