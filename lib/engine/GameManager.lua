local Scenery      = require 'lib.engine.Scenery'
local Shuttle      = require 'lib.player.Shuttle'
local Joystick     = require 'lib.control.MultiDirectionalController'
local Fire         = require 'lib.control.FireController'
local EndGameRecap = require 'lib.gui_displays.EndGameRecap'

-- J'utilise souvent objectGameManager et pas "self" pour plus de clarté
local GameManager = {}

function GameManager:run()

  -- sounds
  SOUND_LASER             = audio.loadSound('ressources/sounds/laser.wav')
  SOUND_EXPLOSION         = audio.loadSound('ressources/sounds/explosion.wav')
  SOUND_EXPLOSION_PLAYER  = audio.loadSound('ressources/sounds/explosion_player.wav')

  -- Global Variables

  GAME_STATE              = "INITIALISATION"
  DIFFICULTY              = 0 -- (Augmente en pourcentage la difficulté)
  FUEL_LOOSING_RATE       = 1 -- Per seconds
  X_DETECTION             = 0 -- Position du joueur

  objectGameManager = display.newGroup()


  --local stage = display.currentStage
  -- mise en place du décor global
  objectGameManager.landscape = Scenery:new(objectGameManager)

  -- mise en place de la navette du joueur
  -- Ainsi que des statistiques
  objectGameManager.player = Shuttle:new{
    parent          = objectGameManager,
    x               = VCW*0.10,
    y               = VCH * .5,
    speed           = 1 * (1 + PLAYER_DATA.ship.driveLevel/10),
    altimin         = VCH/12,
    altimax         = VCH,
    name            = "playerShuttle",
    laserColor      = PLAYER_DATA.sfx.laserColor,
    backColor       = PLAYER_DATA.sfx.shipBackColor,
    baseColor       = PLAYER_DATA.sfx.shipBaseColor,
    aileronsColor   = PLAYER_DATA.sfx.shipAileronsColor,
    moteurColor     = PLAYER_DATA.sfx.shipMoteurColor,
    canonColor      = PLAYER_DATA.sfx.shipCanonColor,
    missileAS       = 1000 / (1 + PLAYER_DATA.ship.laserSpeedLevel/10),
    bombAS          = 2000 / (1 + PLAYER_DATA.ship.bombSpeedLevel/10),
    fuel            = 80 * (1 + PLAYER_DATA.ship.fuelTankLevel/4),
    life            = math.floor(4 * (1 + PLAYER_DATA.ship.armorLevel/7)),
    --life = 99999,
    ammo            = math.floor(25 * (1+PLAYER_DATA.ship.ammoMaxLevel/10))
  }


  -- Loosing fuel for player every seconds
  local fuelLoosing = function()
    objectGameManager.player.fuel = objectGameManager.player.fuel - FUEL_LOOSING_RATE
    if(objectGameManager.player.fuel < 0) then objectGameManager.player.fuel = 0 end
  end


  -- Mise en place des textes
  objectGameManager.backgroundDisplays  = display.newRect(objectGameManager, VCW*.95, VCH*.15, VCW*.25,  VCH*.30 )
  objectGameManager.backgroundDisplays:setFillColor(0,0,0)
  objectGameManager.backgroundDisplays.alpha = 0.4
  objectGameManager.backgroundDisplays:setStrokeColor(.8,.8,.8)
  objectGameManager.backgroundDisplays.strokeWidth = 1

  objectGameManager.lifeDisplay         = display.newText({
    text      = 0,
    x         = VCW*.90,
    y         = VCH*.05,
    align     = "left",
    width     = VCW*.10,
    font      = FONT_DIGITAL,
    fontSize  = VCW*.03,
    parent    = objectGameManager
  })
  objectGameManager.lifeDisplay.image   = display.newImageRect(objectGameManager, "ressources/images/armor.png", VCW*.033, VCW*.033)
  objectGameManager.lifeDisplay.image.x = objectGameManager.lifeDisplay.x + VCW * .06
  objectGameManager.lifeDisplay.image.y = objectGameManager.lifeDisplay.y

  objectGameManager.ammoDisplay         = display.newText({
    parent      = objectGameManager,
    text        = 0,
    x           = VCW*.90,
    y           = VCH*.15,
    align       = "left",
    width       = VCW*.10,
    font        = FONT_DIGITAL,
    fontSize    = VCW*.03,
  })
  objectGameManager.ammoDisplay.image   = display.newImageRect(objectGameManager, "ressources/images/ammo.png", VCW*.033, VCW*.033)
  objectGameManager.ammoDisplay.image.x = objectGameManager.ammoDisplay.x + VCW * .06
  objectGameManager.ammoDisplay.image.y = objectGameManager.ammoDisplay.y


  objectGameManager.fuelDisplay         = display.newText({
    parent    = objectGameManager,
    text      = 0,
    x         = VCW*.90,
    y         = VCH*.25,
    align     = "left",
    width     = VCW*.10,
    font      = FONT_DIGITAL,
    fontSize  = VCW*.03,
  })
  objectGameManager.fuelDisplay.image   = display.newImageRect(objectGameManager, "ressources/images/fuel.png", VCW*.033, VCW*.033)
  objectGameManager.fuelDisplay.image.x = objectGameManager.fuelDisplay.x + VCW * .06
  objectGameManager.fuelDisplay.image.y = objectGameManager.fuelDisplay.y
  --display.newText(0, VCW*.5, VCH*.05)
  objectGameManager.scoreDisplay        = display.newText({
    text      = 0,
    x         = VCW*.5,
    y         = VCH*.05,
    fontSize  = VCW*.05,
    font      = FONT_DIGITAL,
    parent    = objectGameManager,
  })
  objectGameManager.score               = 0
  X_DETECTION                           = objectGameManager.player.x

  objectGameManager.difficultyDisplay   = display.newText({
    text      = "DIFFICULTE : 1",
    x         = VCW*.1,
    y         = VCH*.05,
    fontSize  = VCW*.03,
    font      = FONT_DIGITAL,
    parent    = objectGameManager,
  })



  objectGameManager.nextCave            = 50
  objectGameManager.endCave             = 200
  objectGameManager.nextDifficulty      = 100

  --objectGameManager.score % math.floor((100 + (1 + (DIFFICULTY/20)))

  local updateScore = function()
    objectGameManager.score = objectGameManager.score + 1 math.floor((1 * (1 + DIFFICULTY/4)))

    -- Si on a atteint un palier on augmente la difficulté
    if(objectGameManager.score >= objectGameManager.nextDifficulty) then
      DIFFICULTY = DIFFICULTY + 1
      FUEL_LOOSING_RATE       = math.floor(1 + (1*DIFFICULTY/2))
      objectGameManager.nextDifficulty = objectGameManager.score + math.floor((100 * (1 + DIFFICULTY/2)))
      objectGameManager.landscape:randomBiome()
      objectGameManager.difficultyDisplay.text = "DIFFICULTE : " .. DIFFICULTY+1
    end
  end

  objectGameManager.scoreTimer  = timer.performWithDelay(100,updateScore,-1)

  function objectGameManager:endGame()
    if(SETTINGS.sounds) then
      audio.play(SOUND_EXPLOSION_PLAYER)
    end
    objectGameManager.endGameRecap = EndGameRecap:new({
      parent      = objectGameManager,
      score       = objectGameManager.score,
      difficulte  = DIFFICULTY
    })
  end

  function objectGameManager:gameManager(event)
    if(event.phase == "score_add") then
      objectGameManager.score = objectGameManager.score + math.floor(event.score)
    elseif(event.phase == "fuel_add") then
      objectGameManager.player.fuel = objectGameManager.player.fuel + math.floor(event.fuel)
      -- Si ça dépasse la limtie maximal on bloque à la limite maximale
      if(objectGameManager.player.fuel > objectGameManager.player.fuelMax) then objectGameManager.player.fuel = objectGameManager.player.fuelMax end
    elseif(event.phase == "ammo_add") then
      objectGameManager.player.ammo = objectGameManager.player.ammo + event.ammo
      -- Si ça dépasse la limtie maximal on bloque à la limite maximale
      if(objectGameManager.player.ammo > objectGameManager.player.ammoMax) then objectGameManager.player.ammo = objectGameManager.player.ammoMax end
    end
  end

  function objectGameManager:enterFrame(event)

    -- Optimisation sauvegarde dans une variable au lieu de rappel la fonction
    -- Optimisation dérisoire mais quand même
    local playerLife = objectGameManager.player:getLife();

    objectGameManager.ammoDisplay.text     = objectGameManager.player:getAmmo() .. " / " .. objectGameManager.player.ammoMax
    objectGameManager.lifeDisplay.text     = playerLife
    objectGameManager.fuelDisplay.text     = objectGameManager.player.fuel
    objectGameManager.scoreDisplay.text    = objectGameManager.score
    X_DETECTION                            = objectGameManager.player.x

    if(playerLife <= 0 or objectGameManager.player.fuel <= 0) then
      objectGameManager:finish()
      Runtime:removeEventListener('enterFrame', self)
      self:endGame()
      timer.cancel(objectGameManager.scoreTimer)
      objectGameManager.lifeDisplay.text = 0
    end
    -- On vérifie qu'on a atteint la fin de la cave
    if(objectGameManager.landscape.topCave.activated and objectGameManager.score >= objectGameManager.endCave) then
      objectGameManager.landscape.topCave:desactivate()
      objectGameManager.nextCave = math.random(100, 200) + objectGameManager.score
    elseif(objectGameManager.landscape.topCave.activated == false and objectGameManager.score >= objectGameManager.nextCave) then
      objectGameManager.endCave  = objectGameManager.nextCave + math.random(100, 200)
      objectGameManager.landscape.topCave:activate()
    end


  end


  --[[ TODO : VISUAL TO KNOW TIME BETWEEN NEXT POSSIBLE ATTACK
  objectGameManager.fireTime = display.newText("5", SOX + VCW - VCH/6, SOY + 5*VCH/6)
  objectGameManager.bombTime = display.newText("5", SOX + VCW - VCH/2, SOY + 5*VCH/6)
  --]]
  Joystick:new{
    parent    = objectGameManager,
    x         = VCW/8,
    y         = VCH*0.8,
    radius    = VCH/6,
    alpha     = .3,
  }

  -- mise en place du contrôleur de tir
  Fire:new{
    parent    = objectGameManager,
    x         = SOX + VCW - VCH/6,
    y         = SOY + 5*VCH/6,
    radius    = VCH/12,
    alpha     = .3,
    eventName = "fired"
  }

  -- mise en place du contrôleur des bombes
  Fire:new{
    parent    = objectGameManager,
    x         = SOX + VCW - VCH/2.5,
    y         = SOY + 5*VCH/6,
    radius    = VCH/12,
    alpha     = .3,
    eventName = "bomb_fired"
  }


  -- activation du "multitouch"
  system.activate('multitouch')

  -- lancement des animations
  function objectGameManager:start()
    objectGameManager.landscape:start()
    objectGameManager.player:start()
    objectGameManager.fuelLoosingTimer = timer.performWithDelay( 1000, fuelLoosing, -1 )
    GAME_STATE = "STARTED"
    Runtime:addEventListener('enterFrame', objectGameManager)
    Runtime:addEventListener('gameManager', objectGameManager)
  end

  function objectGameManager:finish()
    objectGameManager.landscape:stop()
    objectGameManager.player:stop()
    timer.cancel(objectGameManager.fuelLoosingTimer)
    GAME_STATE = "ENDED"
    Runtime:removeEventListener('enterFrame', objectGameManager)
    Runtime:removeEventListener('gameManager', objectGameManager)
  end


  return objectGameManager

end

return GameManager
