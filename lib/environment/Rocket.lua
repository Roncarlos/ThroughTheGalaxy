-- Ce module implémente la gestion des missiles qui sont lancés
-- par la navette lorsque le joueur appuie sur le contrôleur de tir
local Rocket = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent: groupe d'affichage parent
--   x:      abscisse initiale de la Rocket
--   y:      ordonnée initiale de la Rocket
--   damage: les dégats que fait subir l'objet
--   yspeed: Vitesse de déplacement verticale
--   ammo:   Les rockets donnerons des munitions au joueur s'il est détruit
function Rocket:new(params)

  -- on détermine le groupe d'affichage parent
  local parent = params.parent or display.currentStage

  -- La rocket est représenté par une image
  local rocket = display.newRect( parent, params.x, params.y, VCW*.03,  VCW*.05 )
  rocket.fill = {type="image", filename="ressources/images/rocket.png"}
  rocket.anchorX = 0
  rocket.anchorY = 1
  physics.addBody( rocket, "static")
  rocket.isActive = false
  rocket.ySpeed = math.floor(math.random(VCW*0.002,VCW*0.006))
  rocket.type = math.random(1,4)
  rocket.score = math.random(2,4) * rocket.type * (1+DIFFICULTY/5)

  if(rocket.type == 1) then rocket:setFillColor(1,0,0) end
  if(rocket.type == 2) then rocket:setFillColor(1,0,1) end
  if(rocket.type == 3) then rocket:setFillColor(0,1,1) end
  if(rocket.type == 4) then rocket:setFillColor(0,1,0) end


  -- On determine le nom de la rocket
  -- Les dégats et son activation
  rocket.name             = "rocket"
  rocket.ammo             = params.ammo or math.random(1,3)
  rocket.damage           = params.damage or 1
  rocket.activationRange  = params.activationRange or math.random(VCW*.05, rocket.x-VCW*.02)



  -- boucle de calcul du déplacement du rocket qui suit le terrain de droite à gauche
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function rocket:enterFrame(event)
    if(GAME_STATE ~= "INITIALISATION") then
      if(self.isActive) then
        self.y = self.y - self.ySpeed
      else
        if(self.x - X_DETECTION <= self.activationRange) then
          self.isActive = true
        end
      end

      self.x = self.x - params.speed

      if(self.x < 0 - self.width or self.y < 0 - self.height) then
        self:selfDestroy()
      end
    end
    if(GAME_STATE == "ENDED") then self:selfDestroy() end
  end

  function rocket:selfDestroy()
    -- on n'oublie SURTOUT PAS de désactiver la prise en compte
    -- des événéments `enterFrame` pour stopper la "boucle" induite
    -- par les cycles de rafraîchissement graphique
    Runtime:removeEventListener('enterFrame', rocket)
    rocket:removeEventListener('collision')
    -- et on supprime le missile
    -- (il suffit ici de l'ôter de la pile d'affichage du groupe parent)
    parent:remove(self)

  end

  -- Gestion collision + application des dégats
  local function onLocalCollision( self, event )
    self:selfDestroy()
    if(event.other.name == "playerShuttle") then
      event.other:addLife(-self.damage)
    end

    if(event.other.name == "playerMissile"
    or event.other.name == "playerBomb") then
      Runtime:dispatchEvent{name='gameManager', phase="score_add", score=self.score}

      -- Pour des raisons d'équilibrage les "rocket" ne donnent plus de munitions
      -- NEW - > Type de missile pour gain ammo
      Runtime:dispatchEvent{name='gameManager', phase="ammo_add", ammo=self.type}
      if(SETTINGS.sounds) then
        audio.play(SOUND_EXPLOSION)
      end
    end
  end

  -- Active la détection de la colision pour la rockete
  if(rocket.collision == nil) then rocket.collision = onLocalCollision end

  -- aussitôt généré, le missile est mis en mouvement
  Runtime:addEventListener('enterFrame', rocket)
  rocket:addEventListener('collision')


  return rocket

end

return Rocket
