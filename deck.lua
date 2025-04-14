local Card = require("card")
local Deck = {}
Deck.__index = Deck

local suits = {"card_hearts_", "card_diamonds_", "card_clubs_", "card_spades_"}
local ranks = {"A", "02", "03", "04", "05", "06", "07", "08", "09", "10", "J", "Q", "K"}

function Deck:new()
    local self = setmetatable({cards = {}}, Deck)
    for _, suit in ipairs(suits) do
        for _, rank in ipairs(ranks) do
            table.insert(self.cards, Card:new(suit, rank))
        end
    end
    return self
end

function Deck:shuffle()
    for i = #self.cards, 2, -1 do
        local j = love.math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

function Deck:draw()
    for _, card in ipairs(self.cards) do
        card:draw()
    end
end

function Deck:drawCard()
    return table.remove(self.cards)
end

return Deck
