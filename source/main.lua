--
-- Ekans main game loop
--

import "Corelibs/object"
import "Corelibs/graphics"
import "Corelibs/sprites"
import "Corelibs/timer"

import "icon" -- Icon library and access method https://github.com/Pictogrammers/Memory
              -- Copyright 2021 Pictogrammers Icon Group. All company logos are copyrighted by their respective owners.

local gfx <const> = playdate.graphics   -- constant for playdate.graphics function library


local gameversion = "0.1-alpha"         -- Version number of the game
local snake  = {}
local snakeSprites = {}
local playerBodySprites = {}
local playerSprite = nil     -- empty player sprite
local backgroundSprite = nil -- empty background sprite
local playTimer = nil        -- empty timer
local playTime = 30 * 1000   -- 30 secs.
local snakeLength = 0

local playerSpeed = 4        -- Speed that the player initially travels at
local playerStartX = 200     -- X     coordinates of initial player start
local playerStartY = 120     -- and Y
local playerHeadX = -1
local playerHeadY = -1

local gameState = "Title"          -- state machine initialisation
local playTimer = nil

local snakeHeadUpImage = gfx.image.new("images/SnakeHeadUp")
local snakeHeadDownImage = gfx.image.new("images/SnakeHeadDown")
local snakeHeadLeftImage = gfx.image.new("images/SnakeHeadLeft")
local snakeHeadRightImage = gfx.image.new("images/SnakeHeadRight")

local snakeBodyUpImage = gfx.image.new("images/SnakeBodyUp")
local snakeBodyDownImage = gfx.image.new("images/SnakeBodyDown")
local snakeBodyLeftImage = gfx.image.new("images/SnakeBodyLeft")
local snakeBodyRightImage = gfx.image.new("images/SnakeBodyRight")

local snakeTailUpImage = gfx.image.new("images/SnakeTailUp")
local snakeTailDownImage = gfx.image.new("images/SnakeTailDown")
local snakeTailLeftImage = gfx.image.new("images/SnakeTailLeft")
local snakeTailRightImage = gfx.image.new("images/SnakeTailRight")

local function resetTimer()
--[[
Reset the game timer to the default value

Parameters
----------
N/A

Returns
-------
N/A

Raises
------
N/A

Notes
-----
N/A

--]]
    playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end


local function print_snake(snakeLength, snake, snakeSprites, prevx, prevy)

    for i = 1, snakeLength do 
        dir = string.sub(snake[i],9,9)
        part = string.sub(snake[i],11,14)
        print(dir)

        
        if i ~=1 then
            prev_dir = string.sub(snake[i-1],9,9)
        else
            prev_dir = string.sub(snake[1],9,9)
            tx = 0
            ty = 0
            transform = string.format("%3d",prevx) .. '/' .. string.format("%3d",prevy)
        end
        -- change direction
        if prev_dir == 'U' then
            if part == 'BODY' then
                snakeSprites[i]:setImage(snakeBodyUpImage)
            end
            if part == 'TAIL' then
                snakeSprites[i]:setImage(snakeTailUpImage)
            end                
            transform = '  0/ 16'
            tx = 0
            ty = 16
        end
        if prev_dir == 'D' then
            if part == 'BODY' then
                snakeSprites[i]:setImage(snakeBodyDownImage)
            end
            if part == 'TAIL' then
                snakeSprites[i]:setImage(snakeTailDownImage)
            end   
            transform = '  0/-16'
            tx = 0
            ty = -16
        end
        if prev_dir == 'L' then
            if part == 'BODY' then
                snakeSprites[i]:setImage(snakeBodyLeftImage)
            end
            if part == 'TAIL' then
                snakeSprites[i]:setImage(snakeTailLeftImage)
            end   
            transform = ' 16/  0'
            tx = 16
            ty = 0
        end
        if prev_dir == 'R' then
            if part == 'BODY' then
                snakeSprites[i]:setImage(snakeBodyRightImage)
            end
            if part == 'TAIL' then
                snakeSprites[i]:setImage(snakeTailRightImage)
            end   
            transform = '-16/  0'
            tx = -16
            ty = 0
        end
        

        snake[i] = transform .. '/' .. prev_dir ..'/' .. part
        x = tx + prevx
        y = ty + prevy
        
        prevx = x 
        prevy = y 
        snakeSprites[i]:moveTo(x, y) 
        snakeSprites[i]:add()
    end
    gfx.sprite.update()             -- Update all sprites

end

local function initialize()
    resetTimer()
    local backgroundImage = gfx.image.new( "images/title" )
    backgroundSprite = gfx.sprite.new(backgroundImage)
    --backgroundSprite:setScale(0.44)
    backgroundSprite:moveTo(200, 120)
    backgroundSprite:setZIndex(-1)
    backgroundSprite:add()
end

-- -------------------------- --

initialize()

function playdate.update()
    if gameState == "Title" then
        if playdate.buttonJustPressed(playdate.kButtonA) then
            backgroundSprite:remove()
            playerSprite = gfx.sprite.new(snakeHeadUpImage)
            playerSprite:moveTo(playerStartX, playerStartY) -- Start in the middle of the playing field
            playerSprite:add()
            playerHeadX = playerStartX
            playerHeadY = playerStartY

            snakeLength = 1
            table.insert(snakeSprites,playerSprite)
            table.insert(snake, string.format("%3d",playerStartX) ..'/'.. string.format("%3d",playerStartY) .. '/U/HEAD')
            playerBodySprite = gfx.sprite.new(snakeBodyUpImage)
            for i =2,4 do
                snakeLength=snakeLength + 1
                table.insert(snake, '  0/ 16/U/BODY')
                table.insert(snakeSprites,gfx.sprite.new(snakeBodyUpImage))
                snakeSprites[i]:add()
            end
            snakeLength=snakeLength + 1
            playerTailSprite = gfx.sprite.new(snakeTailUpImage)
            --playerTailSprite:moveTo(playerStartX, playerStartY) -- Start in the middle of the playing field
            playerTailSprite:add()
            table.insert(snake, '  0/ 16/U/TAIL')
            table.insert(snakeSprites,playerTailSprite)
            
            gameState = "Play"

            resetTimer()
            prevx=playerStartX
            prevy=playerStartY
            print_snake(snakeLength, snake, snakeSprites, prevx, prevy)

        end    
    end
    gfx.sprite.update()                -- Update all sprites

    if playTimer.value <= 0 then
        gameState = "Done"
        if playdate.buttonJustPressed(playdate.kButtonA) then
            resetTimer()
            
            gameState = "Play"
        end
        gfx.sprite.update()         -- Update all sprites
    end

    if gameState == "Play" then
        local direction = 'UP'
        -- Ensure player moves in the correct direction within constraints
        if playdate.buttonIsPressed(playdate.kButtonUp) then
            playerSprite:moveBy(0, -playerSpeed)
            playerHeadY = playerHeadY - playerSpeed
            playerSprite:setImage(snakeHeadUpImage)
            local direction = 'U'
            snake[1] = string.format("%3d",playerHeadX) ..'/'.. string.format("%3d",playerHeadY) .. '/' .. direction ..'/' .. 'HEAD'
        end

        if playdate.buttonIsPressed(playdate.kButtonDown) then
            playerSprite:moveBy(0, playerSpeed)
            playerHeadY = playerHeadY + playerSpeed
            playerSprite:setImage(snakeHeadDownImage)
            local direction = 'D'
            snake[1] = string.format("%3d",playerHeadX) ..'/'.. string.format("%3d",playerHeadY) .. '/' .. direction ..'/' .. 'HEAD'
       end
        if playdate.buttonIsPressed(playdate.kButtonLeft) then
            playerSprite:moveBy(-playerSpeed, 0)
            playerHeadX = playerHeadX - playerSpeed
            playerSprite:setImage(snakeHeadLeftImage)
            local direction = 'L'
            snake[1] = string.format("%3d",playerHeadX) ..'/'.. string.format("%3d",playerHeadY) .. '/' .. direction ..'/' .. 'HEAD'
        end
        if playdate.buttonIsPressed(playdate.kButtonRight) then
            playerSprite:moveBy(playerSpeed, 0)
            playerHeadX = playerHeadX + playerSpeed
            playerSprite:setImage(snakeHeadRightImage)
            local direction = 'R'
            snake[1] = string.format("%3d",playerHeadX) ..'/'.. string.format("%3d",playerHeadY) .. '/' .. direction ..'/' .. 'HEAD'
        end
        
        local prevx = playerHeadX
        local prevy = playerHeadY
        local snakeImage = nil

        print_snake(snakeLength, snake, snakeSprites, prevx, prevy)


        -- Update screen
        playdate.timer.updateTimers()   -- Update all timers
        gfx.sprite.update()             -- Update all sprites
        gfx.drawText("Time : " .. math.ceil(playTimer.value/1000), 5, 5) -- Draw time left on the screen
    end
end

