-- Ce module implémente la gestion des missiles qui sont lancés
-- par la navette lorsque le joueur appuie sur le contrôleur de tir
local Missile = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent: groupe d'affichage parent
--   x:      abscisse initiale du missile
--   y:      ordonnée initiale du missile
--   length: longueur du missile
--   speed:  vitesse du missile
--   color:  couleur du missile
function Missile:new(params)

  -- on détermine le groupe d'affichage parent
  local parent = params.parent or display.currentStage
  local color = params.color or {0,1,0}

  -- le missile est représenté par un simple trait de couleur
  local missile = display.newRect(parent, params.x, params.y, params.length, 1 )
  missile:setFillColor(unpack(params.color))

  physics.addBody( missile, "dynamic", {isSensor=true})
  missile.gravityScale = 0

  -- On determine le nom du missile (Pour plus de possibilité, comme tir ami etc)
  -- ainsi que ses degats et la direction dans laquelle il va
  if(params.name) then missile.name = params.name else missile.name = "genericMissile" end
  if(params.damage) then missile.damage = params.damage else missile.damage = 1 end
  if(params.direction) then missile.direction = params.direction else missile.direction = "right" end

  -- boucle de calcul du déplacement du missile
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function missile:enterFrame(event)
    -- le missile se déplace horizontalement à la vitesse spécifiée dans le sens spécifié
    if(self.direction == "right") then
      -- Direction droite
      self.x = self.x + params.speed
      -- dès que le missile sort de l'écran
      if (self.x > SOX + VCW + .5*params.length) then
        self:selfDestroy()
      end

    else
      -- Drection gauche
      self.x = self.x - params.speed
      if (self.x < SOX - VCW - .5*params.length) then
        self:selfDestroy()
      end
    end
    if(GAME_STATE == "ENDED") then self:selfDestroy() end

  end

  function missile:selfDestroy()
    -- on n'oublie SURTOUT PAS de désactiver la prise en compte
    -- des événéments `enterFrame` pour stopper la "boucle" induite
    -- par les cycles de rafraîchissement graphique
    Runtime:removeEventListener('enterFrame', self)
    missile:removeEventListener('collision')
    -- et on supprime le missile
    -- (il suffit ici de l'ôter de la pile d'affichage du groupe parent)
    parent:remove(self)
  end

  local function onLocalCollision( self, event )
    if ( event.phase == "began" ) then
        if(event.other.name ~= "playerShuttle" and self.name == "playerMissile") then
          self:selfDestroy()
        end
    end
  end

  -- Active la détection de la colision pour la bombe
  if(missile.collision == nil) then missile.collision = onLocalCollision end

  -- aussitôt généré, le missile est mis en mouvement
  Runtime:addEventListener('enterFrame', missile)
  missile:addEventListener('collision')

  return missile

end

return Missile
