local Pile = {}
Pile.__index = Pile

function Pile:new(x, y)
    local self = setmetatable({
        x = x, y = y,
        cards = {}
    }, Pile)
    return self
end

function Pile:addCard(card)
    card.x = self.x
    card.y = self.y + (#self.cards * 20)  -- stacked visual
    table.insert(self.cards, card)
end

function Pile:draw()
    for _, card in ipairs(self.cards) do
        card:draw()
    end
end

return Pile
