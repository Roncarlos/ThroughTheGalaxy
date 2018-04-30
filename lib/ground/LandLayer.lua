local Tile        = require 'lib.ground.LandTile'
local FuelTank    = require 'lib.environment.FuelTank'
local Rocket      = require 'lib.environment.Rocket'
local AmmoBox     = require 'lib.environment.AmmoBox'

local LandLayer = {}

--[[

Ce script à été modifié pour pouvoir répondre aux besoin du projet

--]]

-- la table `params` doit comporter les indexes suivants :
--   baseLine:    altitude de l'axe du faisceau de tirage aléatoire
--   amplitude:   amplitude du faisceau de tirage aléatoire
--   roughness:   indice de rugosité du terrain ∈ [0,1]
--   iterations:  nombre d'itérations dichotomiques à appliquer
--   orientation: orientation des pics rocheux (up|down)
--   ridgeColor:  couleur de la ligne de crête
--   landColor:   couleur de remplissage des pics rocheux
--   parent:      groupe d'affichage parent
--   physics:     bool permetant de savoir si la colision est activé
function LandLayer:new(params)

  local layer = display.newGroup()
  local parent = params.parent or display.currentStage
  parent:insert(layer)

  if(params.activated) then layer.activated = true else layer.activated = false end


  -- définition des paramètres de réglages des tuiles qui seront générées
  local settings = {
    parent            = layer,
    yLeft             = params.baseLine,
    yRight            = params.baseLine,
    amplitude         = params.amplitude,
    roughness         = params.roughness,
    orientation       = params.orientation,
    iterations        = params.iterations,
    ridgeColor        = params.ridgeColor,
    -- Ici on évite le fait de ne pas avoir de polygone
    landColor         = params.landColor or {1,1,1},
    physics           = params.physics,
    spawnableObjects  = params.spawnableObjects,
  }

  -- Nom du layer : Informations de Base pour debug
  layer.name = "Generic Layer"

  -- définition de la vitesse de défilement du calque
  local speed = math.floor(params.speed) or 1

  -- Si le layer est avec alors la valeur done est false.
  -- Cette varible sert lors de la desactivation du layer.
  layer.done  = not layer.activated

  -- initialisation du calque avec la création de deux premières tuiles
  function init()
    -- on place une tuile à l'intérieur de l'écran
    -- True pour dire a la fonction que c'est la première tuile
    layer:addNewTile(true)
    -- puis une autre tuile hors écran, à l'extrémité droite de celui-ci
    layer:addNewTile()

    -- Si le layer n'est pas activé on place les tuilles en dehors de l'écran
    -- Celles-ci vont ainsi, une fois qu'elles seront actives, venir du dehors
    -- de l'écran
    if(layer.activated == false) then
      if(settings.ridgeColor) then
        layer[1].line.x = VCW
        layer[2].line.x = VCW * 2
      end
      layer[1].fill.x = VCW * 1.5
      layer[2].fill.x = VCW * 2.5
    end

    layer:changeSettings(_params)

  end

  -- Fonction qui permet de changer à volonté les settings de creation des
  -- tuilles
  function layer:changeSettings(_params)
    if(_params == nil) then return end
    if(_params.yLeft) then settings.yLeft = _params.yLeft end
    if(_params.yRight) then settings.yRight = _params.yRight end
    if(_params.amplitude) then settings.amplitude = _params.amplitude end
    if(_params.roughness) then settings.roughness = _params.roughness end
    if(_params.orientation) then settings.orientation = _params.orientation end
    if(_params.iterations) then settings.iterations = _params.iterations end
    if(_params.ridgeColor) then settings.ridgeColor = _params.ridgeColor end
    if(_params.landColor) then settings.landColor = _params.landColor end
    if(_params.physics) then settings.physics = _params.physics end

    if(DEBUG) then print("Layer: " .. layer.name .. "\nSettings changed.") end
  end

  -- fonction qui permet d'activer de manière claire le layer
  function layer:activate()
    self.activated = true
    self.done = false
  end

  -- fonction qui permet de désactiver de manière claire le layer
  function layer:desactivate()
    self.activated = false
  end

  -- ajoute une nouvelle tuile hors écran, à l'extrémité droite de celui-ci
  function layer:addNewTile(_first)
    local tile = Tile:new(settings)
    local decal = 0

    if(not _first) then
      tile.fill.x = VCW*1.5
      decal = VCW
      if(settings.ridgeColor) then tile.line.x = VCW end
    end

    if(params.amplitudeRandom) then
      layer:changeSettings({amplitude=math.random(VCH*.05, VCH*.2), })
    end
    --layer:changeSettings({landColor = {math.random(),math.random(),math.random(), 1}, amplitude=math.random(0,100), })

    -- Creation des objets de la carte
    if(#tile.ObjectsSpawnPoints > 0 and not(_first)) then
      tile.Objects = display.newGroup()
      for i=1,#tile.ObjectsSpawnPoints do
        -- On choisi au hasard quel objet faire spawn
        -- 1 => Fuel tank
        -- 2 => Missile
        choice = math.random(1,2)
        if(choice == 1) then
          local newObject = FuelTank:new{
            x           = tile.ObjectsSpawnPoints[i][1] + decal,
            y           = tile.ObjectsSpawnPoints[i][2],
            fuel        = math.random(4,10),
            speed       = speed,
            parent      = tile.Objects
          }
        else
          local newObject = Rocket:new{
            x           = tile.ObjectsSpawnPoints[i][1] + decal,
            y           = tile.ObjectsSpawnPoints[i][2],
            damage      = math.floor(1 * (1 + DIFFICULTY/2)),
            speed       = speed,
            parent      = tile.Objects
          }
        end
      end

      -- Je fais aussi apparaître une caisse de munition si la chance le veut bien
      if(math.random() > .9) then
        AmmoBox:new{
          x           = tile.fill.x,
          y           = math.random(VCH*.3, VCH*.7),
          speed       = speed,
          parent      = tile
        }
      end

    end
  end

  -- renouvellement des tuiles par :
  --   * destruction de la première tuile
  --   * permutation de la tuile restante
  --   * création d'une nouvelle tuile
  function layer:swapTiles()
    -- Ceci est un fix (FIX_2_TILE), quand la vitesse est trop grande (par rapport à la taille de l'écran)
    -- ou quand il y a des chutes de fps, un décalage se créé
    --[[if(self[2].fill.x < VCW * .5) then
      self[2].fill.x = VCW * .5
      self[2].line.x = 0
    end--]]

    -- la première tuile est supprimée du calque
    -- Ainsi que son contour s'il existe
    self:remove(1)
    -- on replace le calque à l'intérieur de l'écran
    -- on décale la tuile restante pour qu'elle demeure à l'intérieur de l'écran
    -- et on crée une nouvelle tuile hors écran
    self:addNewTile()

  end

  -- boucle de défilement du calque :
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function layer:enterFrame(event)
    -- lorsque la première tuile est sortie de l'écran
    -- on déclenche le renouvellement des tuiles
    -- Ici aussi il y a un gros changement, chacune des tuiles sont déplacées
    -- Ainsi que la crête

    if(self.activated) then
      if (self[1].fill.x <= - VCW * .5 + speed*0.25) then self:swapTiles() end
      self[1].fill.x = self[1].fill.x - speed
      self[2].fill.x = self[2].fill.x - speed
      -- Contour Ici
      -- Ont fait exactement la même chose
      if(settings.ridgeColor) then
        self[1].line.x = self[1].line.x - speed
        self[2].line.x = self[2].line.x - speed
      end
    elseif(self.activated == false) then
      -- Ici c'est la partie si le layer est sésactivé.

      -- Si le layer est désactivé mais qu'il na pas fini son déplacement
      -- Alors on continue le déplacement comme si de rien n'était
      -- Sauf qu'on arrête le déplacement si les montagnes sont toutes les deux
      -- en dehors de l'écran
      if(self.done == false) then
        if(self[1].fill.x < VCW * 1.5) then
          if(self[1].fill.x <= -VCW * 0.5) then
            self[1].fill.x = VCW * 1.5
            self[1].line.x = VCW
          else
            self[1].fill.x = self[1].fill.x - speed
            self[1].line.x = self[1].line.x - speed
          end
        end

        if(self[2].fill.x < VCW * 2.5) then
          if(self[2].fill.x <= -VCW * 0.5) then
            self[2].fill.x = VCW * 2.5
            self[2].line.x = VCW*2
          else
            self[2].fill.x = self[2].fill.x - speed
            self[2].line.x = self[2].line.x - speed
          end
        end


        -- Ici on vérifie que les deux montagnes sont bien en dehors de l'écran,
        -- et si c'est le cas on met à jour la variable done
        if(self[1].fill.x == VCW * 1.5 and self[2].fill.x == VCW * 2.5) then
          self.done = true
        end
      end
    end

  end


  -- démarrage du défilement
  function layer:start()
    Runtime:addEventListener('enterFrame', self)
  end

  -- arrêt du défilement
  function layer:stop()
    Runtime:removeEventListener('enterFrame', self)
  end

  -- on procède à l'initialisation du calque
  init()

  return layer

end

return LandLayer
