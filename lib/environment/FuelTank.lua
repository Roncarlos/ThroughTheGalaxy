-- Ce module implémente la gestion des missiles qui sont lancés
-- par la navette lorsque le joueur appuie sur le contrôleur de tir
local FuelTank = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent: groupe d'affichage parent
--   x:      abscisse initiale du fuel tank
--   y:      ordonnée initiale du fuel tank
--   fuel:   le nombre de fuel en tonne
function FuelTank:new(params)

  -- on détermine le groupe d'affichage parent
  local parent = params.parent or display.currentStage

  -- Le fuel tank est représenté par une image
  local fuelTank = display.newRect( parent, params.x, params.y, VCW*.05,  VCW*.05 )
  fuelTank.fill = {type="image", filename="ressources/images/fueltank.png"}
  fuelTank.anchorX = 0
  fuelTank.anchorY = 1
  physics.addBody( fuelTank, "static")


  -- On determine le nom du missile (Pour plus de possibilité, comme tir ami etc)
  -- ainsi que ses degats et la direction dans laquelle il va
  fuelTank.name = "fuel_tank"
  if(params.fuel) then fuelTank.fuel = params.fuel else fuelTank.fuel = math.random(1,4) end


  -- boucle de calcul du déplacement du fuelTank qui suit le terrain de droite à gauche
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function fuelTank:enterFrame(event)
    if(GAME_STATE ~= "INITIALISATION") then
      self.x = self.x - params.speed
      if(self.x < 0 - self.width) then
        self:selfDestroy()
      end
    end

    if(GAME_STATE == "ENDED") then self:selfDestroy() end
  end

  function fuelTank:selfDestroy()
    -- on n'oublie SURTOUT PAS de désactiver la prise en compte
    -- des événéments `enterFrame` pour stopper la "boucle" induite
    -- par les cycles de rafraîchissement graphique
    Runtime:removeEventListener('enterFrame', fuelTank)
    fuelTank:removeEventListener('collision')
    -- et on supprime le missile
    -- (il suffit ici de l'ôter de la pile d'affichage du groupe parent)
    self:removeSelf()
    self = nil
  end

  local function onLocalCollision( self, event )
    if(event.other.name == "playerShuttle") then
      event.other:addLife(-math.random(1,5))
    elseif(event.other.name ~= "meteorite") then
      if(SETTINGS.sounds) then
        audio.play(SOUND_EXPLOSION)
      end
      Runtime:dispatchEvent{name='gameManager', phase="fuel_add", fuel=self.fuel}
    end
    self:selfDestroy()
  end

  -- Active la détection de la colision pour le fuelTank
  if(fuelTank.collision == nil) then fuelTank.collision = onLocalCollision end

  -- aussitôt généré, le missile est mis en mouvement
  Runtime:addEventListener('enterFrame', fuelTank)
  fuelTank:addEventListener('collision')


  return fuelTank

end

return FuelTank
