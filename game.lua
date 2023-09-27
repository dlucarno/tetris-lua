
local game = {}
local blockSize = 30
local areaWidth = 10
local areaHeight = 20
local font
local menuSin = 0

local shapes = {
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
  {255, 255, 255}  -- blanc
}
  
local shape
local shapePosX
local shapePosY
local shapeFall
local nextShape

local blocks

local score
local lines
local level
local gameOver

local timer
local interval = 0.05
local controlTimer
local controlInterval = 0.07
local collectTimer
local collectInterval = 0.15

function game.load()
    soundLineComplete = love.audio.newSource("assets/sounds/lineComplete.mp3", "static")
    sndLoose = love.audio.newSource("assets/musics/tetris-gameboy-04.mp3", "static")
    font = love.graphics.newFont('assets/fonts/gui.ttf', 50)
    love.graphics.setFont(font)
    
  restart()
end

function resetShape()
  local shapeType
  local shapeRot

  if nextShape ~= nil then
    -- Copy next shape
    shapeType = nextShape.type
    shapeRot = nextShape.rot
  else
    -- Generate new
    shapeType = love.math.random(1, #shapes)
    shapeRot = love.math.random(1, 4)
  end

  shape = createShape(shapeType, shapeRot)
  shapePosX = math.floor(areaWidth / 2 - (shape.maxX - shape.minX) / 2 - shape.minX + 0.5)
  shapePosY = -shape.minY + 1
  shapeFall = 0
  
  -- Randomize next shape
  local nextShapeType = love.math.random(1, #shapes)
  local nextShapeRot = love.math.random(1, 4)
  nextShape = createShape(nextShapeType, nextShapeRot)
  
  -- Check if there is no room left
  if isShapeColliding(shapePosX, shapePosY) then
    gameOver = true
  end
end

function restart()
  gameOver = false
  clearBlocks()
  nextShape = nil
  resetShape()
  score = 0
  lines = 0
  level = 0
  timer = 0
  controlTimer = 0
  collectTimer = 0
end

function clearBlocks()
  blocks = {}
  
  for j = 1, areaHeight do
    blocks[j] = {}
    
    for i = 1, areaWidth do
      blocks[j][i] = 0
    end
  end
end

function saveShape()
  for j = 1, shape.length do
    for i = 1, shape.length do
      if shape.data[j][i] == 1 then
        local x = shapePosX + i
        local y = shapePosY + j
        
        -- Copy shape into blocks if inside the area
        if x >= 1 and x <= areaWidth and y >= 1 and y <= areaHeight then
          blocks[y][x] = shape.type
        end
      end
    end
  end
end

function markBlocks()
  -- Create temporary blocks
  local temp = {}
  
  for j = 1, areaHeight do
    temp[j] = {}
    
    for i = 1, areaWidth do temp[j][i] = 0 end
  end
  
  -- Mark blocks for collecting
  local marked = false
  
  for j = areaHeight, 1, -1 do
    local mark = true
    
    for i = 1, areaWidth do
      if blocks[j][i] == 0 then mark = false; break end
    end
    
    if mark then
      for i = 1, areaWidth do temp[j][i] = 8 end
      lines = lines + 1
      score = score + areaWidth * 10
      marked = true
    else
      for i = 1, areaWidth do temp[j][i] = blocks[j][i] end
    end
  end
  
  -- Level up
  if marked then
    score = score + (level + 1) * areaWidth * 10
    level = level + 1
    collectTimer = 0
  end
  
  -- Copy temporary blocks
  for j = 1, areaHeight do
    for i = 1, areaWidth do blocks[j][i] = temp[j][i] end
  end
end

function collectBlocks()
  -- Create temporary blocks
  local temp = {}
  
  for j = 1, areaHeight do
    temp[j] = {}
    
    for i = 1, areaWidth do temp[j][i] = 0 end
  end
  
  -- Collect blocks
  local row = areaHeight
  
  for j = areaHeight, 1, -1 do
    local copy = false
    
    for i = 1, areaWidth do
      if blocks[j][i] < 8 then copy = true; break end
    end
    
    if copy then
      for i = 1, areaWidth do temp[row][i] = blocks[j][i] end
      row = row - 1
    end
  end
  
  -- Copy temporary blocks
  for j = 1, areaHeight do
    for i = 1, areaWidth do blocks[j][i] = temp[j][i] end
  end
  
end

function createShape(t, r)
  local shape = {
    type = t,
    rot = r,
    length = #shapes[t][1],
    minX = 100,
    maxX = -100,
    minY = 100,
    maxY = -100,
    data = {}
  }

  for y = 1, shape.length do
    shape.data[y] = {}
    
    for x = 1, shape.length do
      local u = x
      local v = y
      
      -- Rotated shape coordinates
      if r == 2 then
        u = y
        v = shape.length - x + 1
      elseif r == 3 then
        u = shape.length - x + 1
        v = shape.length - y + 1
      elseif r == 4 then
        u = shape.length - y + 1
        v = x
      end
      
      -- Copy rotated shape
      shape.data[y][x] = shapes[t][v][u]
      
      -- Check shape min and max values
      if shape.data[y][x] == 1 then
        if x < shape.minX then shape.minX = x end
        if x > shape.maxX then shape.maxX = x end
        if y < shape.minY then shape.minY = y end
        if y > shape.maxY then shape.maxY = y end
      end
    end
  end
    
  return shape
end

function isShapeColliding(x, y)
  -- Check the boundaries
  local minX = -shape.minX + 1
  local minY = -shape.minY + 1
  local maxX = areaWidth - shape.maxX
  local maxY = areaHeight - shape.maxY
  if x < minX then return true end
  if y < minY then return true end
  if x > maxX then return true end
  if y > maxY then return true end
  
  -- Check if any of its blocks are colliding
  for j = 1, shape.length do
    for i = 1, shape.length do
      if shape.data[j][i] == 1 then
        local px = x + i
        local py = y + j
        
        if px >= 1 and px <= areaWidth and py >= 1 and py <= areaHeight and blocks[py][px] > 0 then
          return true
        end
      end
    end
  end
  
  return false
end

function game.keypressed(key)
  if key == "escape" then love.event.quit() end
  if key == "return" and gameOver then restart() end
  if key == "r" then restart() end
  
  -- Rotate the shape
  if key == "up" then
    -- Save current stats
    local oldShapePosX = shapePosX
    local oldShapePosY = shapePosY
    local oldShapeType = shape.type
    local oldShapeRot = shape.rot
    
    -- Try to rotate shape
    shape.rot = shape.rot + 1
    if shape.rot > 4 then shape.rot = 1 end
    shape = createShape(shape.type, shape.rot)
  
    -- Check the boundaries
    local minX = -shape.minX + 1
    local minY = -shape.minY + 1
    local maxX = areaWidth - shape.maxX
    local maxY = areaHeight - shape.maxY
    if shapePosX < minX then shapePosX = minX end
    if shapePosY < minY then shapePosY = minY end
    if shapePosX > maxX then shapePosX = maxX end
    if shapePosY > maxY then shapePosY = maxY end
  
    -- Reset shape if collided
    if isShapeColliding(shapePosX, shapePosY) then
      shape = createShape(oldShapeType, oldShapeRot)
      shapePosX = oldShapePosX
      shapePosY = oldShapePosY
    end
  end

  -- Drop the shape
  if key == "space" then
    shapeFall = 0
    
    while not isShapeColliding(shapePosX, shapePosY + 1) do
      shapePosY = shapePosY + 1
      score = score + 10
    end
    
    saveShape()
    markBlocks()
    resetShape()
  end
end

function game.update(dt)
    dt =  1/100
    menuSin = menuSin + 5*60*dt
  if gameOver then return end
  
  controlTimer = controlTimer + dt
  if controlTimer >= controlInterval then
    controlTimer = 0
    
    -- Move shape
    if love.keyboard.isDown("left") and not isShapeColliding(shapePosX - 1, shapePosY) then
      shapePosX = shapePosX - 1
    end
    
    if love.keyboard.isDown("right") and not isShapeColliding(shapePosX + 1, shapePosY) then
      shapePosX = shapePosX + 1
    end

    if love.keyboard.isDown("down") and not isShapeColliding(shapePosX, shapePosY + 1) then
      shapePosY = shapePosY + 1
      score = score + 10
    end
  end

  collectTimer = collectTimer + dt
  if collectTimer >= collectInterval then
    collectTimer = 0
    collectBlocks()
  end
  
  timer = timer + dt
  while timer >= interval do
    timer = timer - interval
    
    -- Check if shape is falling
    shapeFall = shapeFall + 1
    if shapeFall >= 20 - level then
      shapeFall = 0
      
      if isShapeColliding(shapePosX, shapePosY + 1) then
        saveShape()
        markBlocks()
        resetShape()
      else
        shapePosY = shapePosY + 1
        score = score + 10
      end
    end
  end
end

function drawBlock(t, x, y)
    local r, g, b = colors[t][1], colors[t][2], colors[t][3]
  
    love.graphics.setColor(r * 120, g * 120, b * 120)
    love.graphics.rectangle("fill", blockSize * x, blockSize * y, blockSize, blockSize)
    love.graphics.setColor(255, 255, 255)
    -- Dessiner la bordure en bas
    love.graphics.setColor(r * 255, g * 255, b * 255)
    love.graphics.rectangle("fill", blockSize * x, blockSize * y + blockSize - 2, blockSize, 2)
    love.graphics.setColor(255, 255, 255)
    -- Dessiner la bordure à droite
    love.graphics.setColor(r * 255, g * 255, b * 255)
    love.graphics.rectangle("fill", blockSize * x + blockSize - 2, blockSize * y, 2, blockSize)
    love.graphics.setColor(255, 255, 255)
    -- Dessiner un coin en bas à droite
    love.graphics.setColor(r * 255, g * 255, b * 255)
    love.graphics.rectangle("fill", blockSize * x + blockSize - 4, blockSize * y + blockSize - 4, 4, 4)
    love.graphics.setColor(255, 255, 255)
  end
  
  function drawShape(s, x, y)  
    for j = 1, s.length do
      for i = 1, s.length do
        if s.data[j][i] == 1 then drawBlock(s.type, x + i - 1, y + j - 1) end
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
  

function drawArea()
    
  for j = 1, areaHeight do
    for i = 1, areaWidth do
      if blocks[j][i] == 0 then
        -- Draw empty block
        love.graphics.setColor(20, 20, 20)
        love.graphics.rectangle("fill", blockSize * (i - 1) + 2, blockSize * (j - 1) + 2, blockSize - 4, blockSize - 4)
      else
        -- Draw filled block
        drawBlock(blocks[j][i], i - 1, j - 1)
      end
    end
  end
end

function drawGUI()
  local sw = love.graphics.getWidth()
  local aw = blockSize * areaWidth
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf("NEXT", aw, blockSize * 0.5, sw - aw, "center")
  love.graphics.printf("SCORE", aw, blockSize * 7.5, sw - aw, "center")
  love.graphics.printf("LINES", aw, blockSize * 11.5, sw - aw, "center")
  love.graphics.printf("LEVEL", aw, blockSize * 15.5, sw - aw, "center")

  love.graphics.setColor(180, 180, 180)
  love.graphics.printf(score, aw, blockSize * 9, sw - aw, "center")
  love.graphics.printf(lines, aw, blockSize * 13, sw - aw, "center")
  love.graphics.printf(level, aw, blockSize * 17, sw - aw, "center")
  
  local px = areaWidth + 3.5 - (nextShape.maxX - nextShape.minX) / 2 - nextShape.minX
  drawShape(nextShape, px, 3.5 - nextShape.minY)
end

function game.draw()

  backgroundGame = love.graphics.newImage("assets/img/bg2.jpg")
  if gameOver then
    love.graphics.draw(backgroundGame, 0, 0, 0, screen_width / backgroundGame:getWidth(), screen_height / backgroundGame:getHeight())
    local sw, sh = love.graphics.getDimensions()
    local sw2, sh2 = sw / 2, sh / 2
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf("GAME OVER!", 0, sh2 - blockSize * 3.5, sw, "center")
    love.graphics.printf("Press ENTER to restart!", 0, sh2 + blockSize * 2.5, sw, "center")
  
    love.graphics.setColor(180, 180, 180)
    love.graphics.printf("Score: " .. score, 0, sh2 - blockSize * 1.5, sw, "center")
   
    love.graphics.printf("Level: " .. level, 0, sh2 + blockSize * 0.5, sw, "center")
    
  else
    
    love.graphics.draw(backgroundGame, 0, 0, 0, screen_width / backgroundGame:getWidth(), screen_height / backgroundGame:getHeight())
    drawArea()
    drawShape(shape, shapePosX, shapePosY)
    drawGUI()
  end
end


return game
