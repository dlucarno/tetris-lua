scene = "menu"
local game = require('game')

fonts = {}
fonts.path = 'assets/fonts/content.ttf'
fonts.secondPath = 'assets/fonts/menuContent.ttf'
fonts.thirdPath = 'assets/fonts/gui.ttf'
fonts.fourPath = 'assets/fonts/normal.ttf'
sndMenu = love.audio.newSource("assets/musics/tetris-gameboy-01.mp3", "static")
sndGame = love.audio.newSource("assets/musics/tetris-gameboy-02.mp3", "stream")
local soundLineComplete

function love.load()
    backgroundMenu = love.graphics.newImage("assets/img/bg3.jpg")
    love.window.setTitle("TETRIS - Développé par Lucarno")
    screen_width = love.graphics.getWidth()
    screen_height =  love.graphics.getHeight()
    game.load()
end

function love.update(dt)
  dt = math.min(dt, 1/60)
  game.update()

end



function love.draw()
  if scene == "menu" then
      love.graphics.draw(backgroundMenu, 0, 0, 0, screen_width / backgroundMenu:getWidth(), screen_height / backgroundMenu:getHeight())
      
      -- Vérifie si la musique est déjà en cours de lecture
      if not sndMenu:isPlaying() then
          sndMenu:setLooping(true)
          sndMenu:play()
      end
      
      drawMenu()
  elseif scene == "game" then
      -- Arrêter la musique lorsque vous changez de scène
      love.audio.stop()
      game.draw()
  
  end
end

function love.keypressed(key)
    if scene == 'menu' and key == 'return' then
        scene = 'game'
    end
    game.keypressed(key)
end



