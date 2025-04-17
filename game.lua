local Deck = require("deck")
local Pile = require("pile")

local Game = {}
Game.__index = Game

function Game:load()

    self.deck = Deck:new()
    self.deck:shuffle()

    self.heldCard = nil
    self.heldCards = {}
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    self.heldFromPile = nil

    -- Setup restart button
    self.restartButton = {x = 10, y = 10, w = 100, h = 30}
    
    -- Setup foundation slots (ensure they are Pile objects)
    self.foundations = {}
    for i = 1, 4 do
        local foundation = Pile:new(400 + (i - 1) * 100, 50) -- Use Pile constructor for foundations
        foundation.isFoundation = true -- Mark them as foundation piles
        table.insert(self.foundations, foundation)
    end

    -- Setup piles
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

    -- Setup stock and waste
    self.stock = {}
    self.waste = {}
    self:updateStockFromDeck()
end


function Game:updateStockFromDeck()
    while #self.deck.cards > 0 do
        table.insert(self.stock, self.deck:drawCard())
    end
end

function Game:update(dt)
    if self.heldCard then
        local mx, my = love.mouse.getPosition()
        for i, card in ipairs(self.heldCards) do
            card.x = mx - self.dragOffsetX
            card.y = my - self.dragOffsetY + (i - 1) * 20
        end
    end
end

function Game:draw()
  
      -- Draw foundations
  for _, foundation in ipairs(self.foundations) do
      foundation:draw()
  end
    -- Draw restart button
    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", self.restartButton.x, self.restartButton.y, self.restartButton.w, self.restartButton.h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Restart", self.restartButton.x + 10, self.restartButton.y + 8)

    -- Draw piles
    for _, pile in ipairs(self.piles) do
        pile:draw()
    end

    -- Draw stock and waste
    if #self.stock > 0 then
        local backImage = love.graphics.newImage("cards/card_back.png")
        love.graphics.draw(backImage, 100, 50)
    end

    for i = 1, math.min(3, #self.waste) do
        local card = self.waste[#self.waste - 3 + i]
        if card then
            card.x = 200 + (i - 1) * 20
            card.y = 50
            card:draw()
        end
    end

    -- Draw dragged cards on top
    if self.heldCard then
        for _, card in ipairs(self.heldCards) do
            card:draw()
        end
    end
    
    -- Draw foundation slots
    for _, foundation in ipairs(self.foundations) do
        love.graphics.setColor(0.2, 0.6, 0.2) -- green outline
        love.graphics.rectangle("line", foundation.x, foundation.y, 71, 96)
        love.graphics.setColor(1, 1, 1)

        local top = foundation.cards[#foundation.cards]
        if top then
            top.x = foundation.x
            top.y = foundation.y
            top:draw()
        end
    end
end

function Game:mousepressed(x, y, button)
    if button == 1 then
        -- Restart
        if x >= self.restartButton.x and x <= self.restartButton.x + self.restartButton.w and
           y >= self.restartButton.y and y <= self.restartButton.y + self.restartButton.h then
            self:load()
            return
        end

        -- Click stock
        if x >= 100 and x <= 171 and y >= 50 and y <= 146 then
            if #self.stock > 0 then
                for i = 1, 3 do
                    local card = table.remove(self.stock)
                    if card then
                        card.faceUp = true
                        table.insert(self.waste, card)
                    end
                end
            elseif #self.waste > 0 then
                -- Refill the stock from waste
                for i = #self.waste, 1, -1 do
                    local card = table.remove(self.waste, i)
                    card.faceUp = false
                    table.insert(self.stock, card)
                end
            end
            return
        end


        -- Click top waste card
        local topWaste = self.waste[#self.waste]
        if topWaste and topWaste:contains(x, y) then
            self.heldCard = topWaste
            self.heldCards = {topWaste}
            self.dragOffsetX = x - topWaste.x
            self.dragOffsetY = y - topWaste.y
            self.heldFromPile = "waste"
            table.remove(self.waste)
            return
        end

        -- Click piles
        for _, pile in ipairs(self.piles) do
            local cards = pile:getFaceUpCardsAt(x, y)
            if #cards > 0 then
                self.heldCard = cards[1]
                self.heldCards = cards
                self.dragOffsetX = x - self.heldCard.x
                self.dragOffsetY = y - self.heldCard.y
                pile:removeCards(cards)
                self.heldFromPile = pile
                return
            end
        end
    end
end

function Game:mousereleased(x, y, button)
    if button == 1 and self.heldCard then
        local placed = false
        
        -- Check if the held card can be placed in any of the piles
        for _, pile in ipairs(self.piles) do
            if pile:isPointInside(x, y) and pile:canAcceptCard(self.heldCard) then
                for _, card in ipairs(self.heldCards) do
                    pile:addCard(card)
                end
                placed = true
                break
            end
        end

        -- Check foundations (added for Ace placement and stacking)
        if not placed then
            for _, foundation in ipairs(self.foundations) do
                if foundation:isPointInside(x, y) and foundation:canAcceptToFoundation(self.heldCard) then
                    for _, card in ipairs(self.heldCards) do
                        table.insert(foundation.cards, card)
                    end
                    placed = true
                    break
                end
            end
        end

        -- If not placed in any pile or foundation, return to original location
        if not placed then
            -- Return to waste
            if self.heldFromPile == "waste" then
                for _, card in ipairs(self.heldCards) do
                    table.insert(self.waste, card)
                end
            elseif self.heldFromPile then
                -- Return to original pile
                for _, card in ipairs(self.heldCards) do
                    self.heldFromPile:addCard(card)
                end
            end
        end

        -- Flip new top card if any in original pile
        if self.heldFromPile and type(self.heldFromPile) ~= "string" then
            local top = self.heldFromPile.cards[#self.heldFromPile.cards]
            if top and not top.faceUp then
                top.faceUp = true
            end
        end

        -- Reset held card and other variables
        self.heldCard = nil
        self.heldCards = {}
        self.heldFromPile = nil
    end
for i, foundation in ipairs(self.foundations) do
    print("Foundation " .. i .. " type:", tostring(getmetatable(foundation)))
end


end




return Game
