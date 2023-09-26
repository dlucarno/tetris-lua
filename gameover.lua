local gameOver = {}


function gameOver.load()
    
end

function gameOver.update(dt)

end

function gameOver.draw()
    love.graphics.print('game')
end

function gameOver.keypressed(key)
    if key == 'escape' then
        scene = 'menu'
    end
end




return gameOver