scene = "menu"

local game = require('game')
local menuSin = 0
local font
local Tetros = {
  {
    { 0,1,0 },
    { 1,1,0 },
    { 0,1,0 }
  },
  {
    { 0,0,1,0 },
    { 0,0,1,0 },
    { 0,0,1,0 },
    { 0,0,1,0 }
  },
  {
    { 1,1 },
    { 1,1 }
  },
  {
    { 1,0,0 },
    { 1,1,0 },
    { 0,1,0 }
  },
  {
    { 0,1,0 },
    { 1,1,0 },
    { 1,0,0 }
  },
  {
    { 1,1,0 },
    { 0,1,0 },
    { 0,1,0 }
  },
  {
    { 0,1,0 },
    { 0,1,0 },
    { 1,1,0 }
  }
}

local colors = {
  {255, 0, 0},   -- Rouge
  {0, 255, 0},   -- Vert
  {0, 0, 255},   -- Bleu
  {255, 165, 0}, -- Orange
  {0, 191, 255}, -- Bleu clair
  {255, 105, 180}, -- Rose
  {148, 0, 211}, -- Violet
  {255, 255, 255}  -- Blanc
}

fonts = {}
fonts.path = 'assets/fonts/content.ttf'
fonts.secondPath = 'assets/fonts/menuContent.ttf'
fonts.thirdPath = 'assets/fonts/gui.ttf'
fonts.fourPath = 'assets/fonts/normal.ttf'


fonts.score = love.graphics.newFont(fonts.path, 80)
fonts.option = love.graphics.newFont(fonts.thirdPath, 30)
fonts.title = love.graphics.newFont(fonts.fourPath, 50)
fonts.author = love.graphics.newFont(fonts.fourPath, 10)
fonts.rules = love.graphics.newFont(fonts.path, 30)
menu = {}
menu.title = {}
menu.title.text = 'TETRIS'
menu.title.y = 80
menu.color = {}
menu.initialColor = {.5, .5, 1}
menu.hoverColor = {.1, .2, 2}

menu.option = {}


menu.option = {}

menu.option[1] = {}
menu.option[1].y = 180
menu.option[1].text = "Joueur vs Joueur"
menu.option[1].underlineColor = {.5, .5, 1}


menu.option[2] = {}
menu.option[2].y = 250
menu.option[2].text = "Bot vs Joueur"
menu.option[2].underlineColor = menu.initialColor


menu.option[3] = {}
menu.option[3].y = 320
menu.option[3].text = "Regles du jeu"
menu.option[3].underlineColor = menu.initialColor


menu.option[4] = {}
menu.option[4].y = 390
menu.option[4].text = "Quitter"
menu.option[4].underlineColor = menu.initialColor
menu.option.underlineWidth = 50

local isInRulesPage = false
rulesContent = "Règles du jeu Pong :\n\n" ..
               "Deux modes de jeu sont disponibles :\n\n" ..
               "1. Joueur contre Joueur : Utilisez les touches Z (monter) et S (descendre) pour le joueur de gauche, et les touches fléchées Haut et Bas pour le joueur de droite.\n\n" ..
               "2. Bot contre Joueur : Vous jouez contre un bot. Utilisez les touches fléchées Haut et Bas pour le joueur de droite. Le bot est à gauche.\n\n" ..
                "3. Le but du jeu est de faire passer la balle dans le camp adverse. Le score s'affiche en haut. Bon jeu !!\n\n"


function love.load()
font = love.graphics.newFont('assets/fonts/normal.ttf', 50)
    love.graphics.setFont(font)
    love.window.setTitle("TETRIS - Développé par Lucarno")
    screen_width = love.graphics.getWidth()
    screen_height =  love.graphics.getHeight()
    cursor = {}
    cursor.hand = love.mouse.getSystemCursor('hand')
    cursor.arrow = love.mouse.getSystemCursor('arrow')

    game.load()
end

function love.update(dt)
dt = math.min(dt, 1/60)
game.update()
menuSin = menuSin + 5*60*dt
end



function love.draw()
    if scene == "menu" then
        drawMenu()
    elseif scene == "game" then
        game.draw()
    end

end

function love.keypressed(key)
    if scene == 'menu' and key == 'return' then
        scene = 'game'
    end
    game.keypressed(key)
end

function love.mousepressed(mouseX, mouseY, button)
    if scene == 'menu' and button == 1 then
        if mouseY >= menu.option[1].y and mouseY <= menu.option[1].y + 30 and mouseX > screen_width/2 - 150 and mouseX < screen_width/2 + 150 then
            game.gamemode = 1
            reset()
            scene = 'game'
            love.mouse.setCursor(cursor.arrow)
        elseif mouseY >= menu.option[2].y and mouseY <= menu.option[2].y + 30 and mouseX > screen_width/2 - 150 and mouseX < screen_width/2 + 150 then
           game.gamemode = 2
           reset()
            scene = 'game'
            love.mouse.setCursor(cursor.arrow)
        elseif mouseY >= menu.option[3].y and mouseY <= menu.option[3].y + 30 and mouseX > screen_width/2 - 150 and mouseX < screen_width/2 + 150 then
            scene = 'rules'
            isInRulesPage = true
            love.mouse.setCursor(cursor.arrow)
        elseif mouseY >= menu.option[4].y and mouseY <= menu.option[4].y + 30 and mouseX > screen_width/2 - 150 and mouseX < screen_width/2 + 150 then
            love.event.quit()
        end
    end
end

function drawMenu()
  local sMessage = "LUCARNO TETRIS"
  local w = font:getWidth(sMessage)
  local h = font:getHeight(sMessage)
  local x = (screen_width - w)/2
  local y = 0

  for c=1,sMessage:len() do
    local char = string.sub(sMessage,c,c)
    y = math.sin((x+menuSin)/50)*30
    local color = colors[c % #colors + 1] -- Utilisez une couleur du tableau 'colors'
    love.graphics.setColor(color[1] * 255, color[2] * 255, color[3] * 255)
    love.graphics.print(char, x, y + (screen_height - h)/2.5)
    x = x + font:getWidth(char)
  end

  sMessage = "PRESS ENTER"
  local w = font:getWidth(sMessage)
  local h = font:getHeight(sMessage)
  local color = colors[8] -- Utilisez la dernière couleur du tableau 'colors'
  love.graphics.setColor(color[1] * 255, color[2] * 255, color[3] * 255)
  love.graphics.print(sMessage, (screen_width - w)/2, (screen_height - h)/1.5)
end

