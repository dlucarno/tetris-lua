local Tetros = {}

Tetros[1] = { {
  {0,0,0,0},
  {0,0,0,0},
  {1,1,1,1},
  {0,0,0,0}
  },
  {
  {0,0,1,0},
  {0,0,1,0},
  {0,0,1,0},
  {0,0,1,0}
  } }

Tetros[2] = { {
  {0,0,0,0},
  {0,1,1,0},
  {0,1,1,0},
  {0,0,0,0}
  } }

Tetros[3] = { {
  {0,0,0},
  {1,1,1},
  {0,0,1},
  },
  {
  {0,1,0},
  {0,1,0},
  {1,1,0},
  },
  {
  {1,0,0},
  {1,1,1},
  {0,0,0},
  },
  {
  {0,1,1},
  {0,1,0},
  {0,1,0},
  } }

Tetros[4] = { {
  {0,0,0},
  {0,1,1},
  {1,1,0},
  },
  {
  {0,1,0},
  {0,1,1},
  {0,0,1},
  },
  {
  {0,0,0},
  {0,1,1},
  {1,1,0},
  },
  {
  {0,1,0},
  {0,1,1},
  {0,0,1},
  } }

  local currentTetros = {}
  currentTetros.position = { x = 0, y = 0 }
  local currentRotation = 1
local dropSpeed = 1
local timerDrop = 0

local Grid = {}
Grid.width = 10
Grid.height = 20
Grid.cellSize = 0
Grid.cells = {}

function love.load()
    spawnTetros()
end

function love.keypressed(key)
    if key == "right" then
        currentTetros.position.x = currentTetros.position.x + 1
      end
      if key == "left" then
        currentTetros.position.x = currentTetros.position.x - 1
      end

      if key == "up" then
        currentTetros.rotation = currentTetros.rotation + 1
        if currentTetros.rotation > #Tetros[currentTetros.shapeid] then
          currentTetros.rotation = 1
        end
      end
end

function love.update(dt)

    timerDrop = timerDrop - dt
  if timerDrop <= 0 then
    currentTetros.position.y = currentTetros.position.y + 1
    timerDrop = dropSpeed
  end
    updateMenu(dt)
    updatePlay(dt)
    updateGameover(dt)
end

function love.draw()
    currentTetros.shapeid = 1
    local Shape = Tetros[currentTetros.shapeid][currentRotation]
    currentRotation = currentRotation + 1
    if currentRotation > #Tetros[currentTetros.shapeid] then
        currentRotation = 1
    end
    screen_height = love.graphics.getHeight()
    screen_width = love.graphics.getWidth()
    initGrid()
    drawGrid()
    drawShape(Shape, 1, 1)


   
    currentTetros.shapeid = 1
    currentTetros.rotation = 1
    currentTetros.position = { x=0, y=0 }

end

function inputMenu(dt)
  
end

function inputPlay(dt)
   
end

function inputGameover(dt)
  
end

function updateMenu(dt)
   
end

function updatePlay(dt)
    
end

function updateGameover(dt)
    
end

function drawMenu(dt)
    
end

function drawPlay(dt)
   
end

function drawGameover(dt)
   
end


function initGrid()
    local h = screen_height / Grid.height
    Grid.cellSize = h
    Grid.offsetX = (screen_width / 2) - (h*Grid.width) / 2
    Grid.offsetY = 0
  
    Grid.cells = {}
    for l=1,Grid.height do
      Grid.cells[l] = {}
      for c=1,Grid.width do
        Grid.cells[l][c] = 0
      end
    end
  end

  function drawGrid()
    local h = Grid.cellSize
    local w = h
    local x,y
    love.graphics.setColor(1,1,1,0.2)
    for l=1,Grid.height do
      for c=1,Grid.width do
        x = (c-1)*w
        y = (l-1)*h
        x = x + Grid.offsetX
        y = y + Grid.offsetY
        love.graphics.rectangle("fill", x, y, w-1, h-1)
      end
    end
  end

  function drawShape(pShape, pColumn, pLine)
    love.graphics.setColor(1,0,0)
    for l=1,#pShape do
    for c=1,#pShape[l] do
      -- Calcule la position initiale de la case
      local x = (c-1) * Grid.cellSize
      local y = (l-1) * Grid.cellSize
      -- Ajoute la position de la pièce
      x = x + (pColumn-1) * Grid.cellSize
      y = y + (pLine-1) * Grid.cellSize
      -- Ajoute l'offset de la grille
      x = x + Grid.offsetX
      y = y + Grid.offsetY
      if pShape[l][c] == 1 then
        love.graphics.rectangle("fill", x, y, Grid.cellSize - 1, Grid.cellSize - 1)
      end
    end
end
  end

  function spawnTetros()
    local new = math.random(1, #Tetros)
    currentTetros.shapeid = 1
    currentTetros.rotation = 1
    local tetrosWidth = 
  #Tetros[currentTetros.shapeid][currentTetros.rotation][1]
    currentTetros.position.x =
  (math.floor((Grid.width - tetrosWidth) / 2)) + 1
    currentTetros.position.y = 1
    timerDrop = dropSpeed
  end