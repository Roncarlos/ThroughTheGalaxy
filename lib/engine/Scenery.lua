local Background   = require 'lib.space.FixedBackground'
local ShootingStar = require 'lib.space.ShootingStar'
local Stars        = require 'lib.space.StellarLayer'
local Land         = require 'lib.ground.LandLayer'

-- Ce module implémente la gestion complète du décor :
--   * mise en place des différents plans
--   * défilement parallaxe de chaque plan
--   * projection aléatoire d'étoiles filantes
--   * différents biomes avec un biome pour le jour et un pour la nuit
local Scenery = {}

function Scenery:new(parent)

  local scenery = display.newGroup()
  parent:insert(scenery)

  -- Une table contenant l'ensemble des types de biomes + une avec les index
  local biomeListIndex = {"earth_desert_day", "earth_desert_night", "earth_forest_day", "earth_forest_night"}
  local selected_Biome     = biomeListIndex[math.random(#biomeListIndex)]
  scenery.biomeList = {
    earth_forest_day = {
      backgroundColor1                = {0.53, 0.80, 1},
      backgroundColor2                = {0.61, 0.86, 0.98},

      backgroundMountainColor         = {.3, .3, .25},
      backgroundMountainRidgeColor    = {.28, .28, .22},

      terrainColor                    = {.05, .3, .05},
      terrainRidgeColor               = {.035, .25, .035},

      night                           = false,
    },

    earth_forest_night = {
      backgroundColor1                = {.0, .1, .2},
      backgroundColor2                = {.0, .2, .4},

      backgroundMountainColor         = {.1, .1, .1},
      backgroundMountainRidgeColor    = {.08, .08, .08},

      terrainColor                    = {.02, .05, .02},
      terrainRidgeColor               = {.016, .036, .016},

      night                           = true,
    },

    exoplanet_desert_day = {
      backgroundColor1                = {0.91, 0.61, 0.345},
      backgroundColor2                = {1, .95, 0.82},

      backgroundMountainColor         = {.74, .53, .45},
      backgroundMountainRidgeColor    = {0, 0, 0},

      terrainColor                    = {.94, .73, 0.098},
      terrainRidgeColor               = {.05, .3, .05},

      night                           = false,
    },

    earth_desert_day = {
      backgroundColor1                = {0.941, 0.502, 0.173},
      backgroundColor2                = {1, .914, 0.843},

      backgroundMountainColor         = {.741, .416, 0.439},
      backgroundMountainRidgeColor    = {.898, 0.608, 0.31},

      terrainColor                    = {.941, .58, 0.114},
      terrainRidgeColor               = {.91, .659, .212},

      night                           = false,
    },

    earth_desert_night = {
      backgroundColor1                = {0.129, 0.263, 0.51},
      backgroundColor2                = {0.702, .42, 0.80},

      backgroundMountainColor         = {.176, .176, 0.455},
      backgroundMountainRidgeColor    = {.11, 0.298, 0.51},

      terrainColor                    = {.459, .235, 0.529},
      terrainRidgeColor               = {.49, .169, .404},

      night                           = true,
    },
  }


  -- l'arrière-plan est fixe et constitué d'un ciel dégradé dans lequel
  -- apparaissent 3 planètes immobiles
  -- On change la couleur du ciel en fonction du biome choisi

  scenery.background   = Background:new(scenery,
    scenery.biomeList[selected_Biome].backgroundColor1,
    scenery.biomeList[selected_Biome].backgroundColor2)
  -- 2 calques étoilés sont ensuite apposés par-dessus
  -- chaque calque défilera a une vitesse différente donnant ainsi une
  -- impression de profondeur du milieu interstellaire
  scenery.distantStars = Stars:new{parent=scenery, stars=100, floor=.75*VCH, speed=.1, night=scenery.biomeList[selected_Biome].night}
  scenery.closeStars   = Stars:new{parent=scenery, stars=50, floor=.75*VCH, speed=.5, night=scenery.biomeList[selected_Biome].night}

  -- un plan médian montagneux est ensuite ajouté
  -- celui défilera avec une vitesse "modérée", supérieure à celle des plans
  -- situés à l'arrière (les étoiles)
  scenery.mountains = Land:new{
    parent      = parent,
    baseLine    = 3*VCH/4,
    amplitude   = VCH/4,
    roughness   = .6,
    orientation = 'up',
    landColor   = scenery.biomeList[selected_Biome].backgroundMountainColor,
    ridgeColor  = scenery.biomeList[selected_Biome].backgroundMountainRidgeColor,
    speed       = math.floor(VCW*0.004),
    activated   = true,
  }

  -- enfin, un premier plan assimilé au sol est ajouté
  -- celui-ci défilera à grande vitesse pour donner l'impression d'un mouvement
  -- horizontal rapide de la navette
  scenery.ground = Land:new{
    parent           = parent,
    baseLine         = 11*VCH/12,
    amplitude        = VCH/12,
    roughness        = 1,
    iterations       = 4,
    orientation      = 'up',
    landColor        = scenery.biomeList[selected_Biome].terrainColor,
    ridgeColor       = scenery.biomeList[selected_Biome].terrainRidgeColor,
    speed            = math.floor(VCW*0.008),
    physics          = true,
    activated        = true,
    spawnableObjects = true,
    aplitudeRandom   = true,
  }

  scenery.topCave = Land:new{
    parent      = parent,
    baseLine    = 0,
    amplitude   = VCH/4,
    roughness   = 1.2,
    iterations  = 3,
    orientation = 'down',
    landColor   = scenery.biomeList[selected_Biome].terrainColor,
    ridgeColor  = scenery.biomeList[selected_Biome].terrainRidgeColor,
    speed       = math.floor(VCW*0.008),
    physics     = true,
    activated   = false,
    aplitudeRandom   = true,
  }



  -- boucle de projection aléatoire des étoiles filantes :
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function scenery:enterFrame(event)
    if (math.random() < .05) then
      -- chaque étoile filante est animée d'un mouvement horizontal rapide
      -- pour augmenter davantage l'impression de vitesse de la navette
      ShootingStar:new{
        parent = self,
        floor  = .6*VCH,
        length = .1*VCW * math.random(1,2),
        speed  = 10 + math.random(3,5),
        alpha  = .25 + .5*math.random()
      }
    end


  end

  -- active la boucle de projection alétoire des étoiles filantes
  function scenery:startLoop()
    Runtime:addEventListener('enterFrame', self)

  end

  -- arrête la boucle de projection alétoire des étoiles filantes
  function scenery:stopLoop()
    Runtime:removeEventListener('enterFrame', self)
  end

  -- active le défilement de l'ensemble des plans
  function scenery:start()
    self.distantStars:start()
    self.closeStars:start()
    self.mountains:start()
    self.ground:start()
    self.topCave:start()
    self:startLoop()
  end

  -- interrompt le défilement de l'ensemble des plans
  function scenery:stop()
    self.distantStars:stop()
    self.closeStars:stop()
    self.mountains:stop()
    self.ground:stop()
    self.topCave:stop()
    self:stopLoop()
  end

  function scenery:randomBiome()
    local choiceIndex = math.random(#biomeListIndex)
    local tempChoice = biomeListIndex[choiceIndex]
    if(tempChoice == selected_Biome) then
      tempChoice = next(biomeListIndex, choiceIndex)
    end
    selected_Biome = tempChoice
    self:changeBiome(selected_Biome)
  end

  function scenery:changeBiome(_biomeName)

    if(scenery.biomeList[_biomeName]) then

      -- On s'occuppe du background
      scenery.background:changeColor(
        scenery.biomeList[_biomeName].backgroundColor1,
        scenery.biomeList[_biomeName].backgroundColor1
      )

      -- Puis du terrain
      scenery.ground:changeSettings({
        landColor  = scenery.biomeList[_biomeName].terrainColor,
        ridgeColor = scenery.biomeList[_biomeName].terrainRidgeColor
      })
      scenery.ground[1].fill:setFillColor(unpack(scenery.biomeList[_biomeName].terrainColor))
      scenery.ground[1].line:setStrokeColor(unpack(scenery.biomeList[_biomeName].terrainRidgeColor))

      scenery.ground[2].fill:setFillColor(unpack(scenery.biomeList[_biomeName].terrainColor))
      scenery.ground[2].line:setStrokeColor(unpack(scenery.biomeList[_biomeName].terrainRidgeColor))

      -- Puis du haut de la cave
      scenery.topCave:changeSettings({
        landColor  = scenery.biomeList[_biomeName].terrainColor,
        ridgeColor = scenery.biomeList[_biomeName].terrainRidgeColor
      })
      scenery.topCave[1].fill:setFillColor(unpack(scenery.biomeList[_biomeName].terrainColor))
      scenery.topCave[1].line:setStrokeColor(unpack(scenery.biomeList[_biomeName].terrainRidgeColor))

      scenery.topCave[2].fill:setFillColor(unpack(scenery.biomeList[_biomeName].terrainColor))
      scenery.topCave[2].line:setStrokeColor(unpack(scenery.biomeList[_biomeName].terrainRidgeColor))


      -- Puis enfin des montagnes en arrière plan
      scenery.mountains:changeSettings({
        landColor  = scenery.biomeList[_biomeName].backgroundMountainColor,
        ridgeColor = scenery.biomeList[_biomeName].backgroundMountainRidgeColor
      })
      scenery.mountains[1].fill:setFillColor(unpack(scenery.biomeList[_biomeName].backgroundMountainColor))
      scenery.mountains[1].line:setStrokeColor(unpack(scenery.biomeList[_biomeName].backgroundMountainRidgeColor))

      scenery.mountains[2].fill:setFillColor(unpack(scenery.biomeList[_biomeName].backgroundMountainColor))
      scenery.mountains[2].line:setStrokeColor(unpack(scenery.biomeList[_biomeName].backgroundMountainRidgeColor))

      -- Puis on regarde si c'est la nuit, et si c'est le cas, on active les étoiles
      if(scenery.biomeList[_biomeName].night) then
        scenery.distantStars.night = true
        scenery.closeStars.night   = true

        scenery.distantStars:changeOpacity()
        scenery.closeStars:changeOpacity()

      else
        scenery.distantStars.night = false
        scenery.closeStars.night   = false

        scenery.distantStars:changeOpacity()
        scenery.closeStars:changeOpacity()
      end
    end


  end

  return scenery

end

return Scenery
