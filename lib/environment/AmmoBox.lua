-- Boite de munitions permettant d'en récupérer
local AmmoBox = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent: groupe d'affichage parent
--   x:      abscisse initiale de l'ammo Box
--   ammo:   LE NOMBRE DE MUNITIONS
--   speed:  vitesse de défillement
--   y:      ordonnée
function AmmoBox:new(params)

  -- on détermine le groupe d'affichage parent
  local parent = params.parent or display.currentStage

  -- Le fuel tank est représenté par une image
  local ammoBox = display.newRect( parent, params.x, params.y, VCW*.05,  VCW*.05 )
  ammoBox.fill = {type="image", filename="ressources/images/ammobox.png"}
  physics.addBody( ammoBox, "static", {isSensor=true})

  ammoBox.limitMove = "up"
  ammoBox.limit     = ammoBox.y

  -- On determine le nom du missile (Pour plus de possibilité, comme tir ami etc)
  -- ainsi que ses degats et la direction dans laquelle il va
  ammoBox.name  = "ammo_box"
  ammoBox.ammo  = params.ammo or math.random(1,5) * 10
  ammoBox.speed = params.speed or 8


  -- boucle de calcul du déplacement du ammoBox qui suit le terrain de droite à gauche
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function ammoBox:enterFrame(event)

    if(GAME_STATE ~= "INITIALISATION") then
      if(self.limitMove == "up") then
        self.y = self.y - 0.4
        if(self.y <= self.limit - 10) then
          self.limitMove = "down"
        end
      else
        self.y = self.y + 0.4
        if(self.y >= self.limit + 10) then
          self.limitMove = "up"
        end
      end

      self.x = self.x - self.speed
      if(self.x < 0 - self.width) then
        self:selfDestroy()
      end
      if(GAME_STATE == "ENDED") then self:selfDestroy() end
    end
  end

  function ammoBox:selfDestroy()
    -- on n'oublie SURTOUT PAS de désactiver la prise en compte
    -- des événéments `enterFrame` pour stopper la "boucle" induite
    -- par les cycles de rafraîchissement graphique
    Runtime:removeEventListener('enterFrame', ammoBox)
    ammoBox:removeEventListener('collision')
    -- et on supprime le missile
    -- (il suffit ici de l'ôter de la pile d'affichage du groupe parent)
    parent:remove(self)
  end

  local function onLocalCollision( self, event )
    if(event.other.name == "playerShuttle") then
      Runtime:dispatchEvent{name='gameManager', phase="ammo_add", ammo=self.ammo}
    end
    if(event.other.name ~= "playerMissile" and
    event.other.name ~= "playerBomb") then
      self:selfDestroy()
    end
  end

  -- Active la détection de la colision pour le ammoBox
  if(ammoBox.collision == nil) then ammoBox.collision = onLocalCollision end

  -- aussitôt généré, le missile est mis en mouvement
  Runtime:addEventListener('enterFrame', ammoBox)
  ammoBox:addEventListener('collision')


  return ammoBox

end

return AmmoBox
