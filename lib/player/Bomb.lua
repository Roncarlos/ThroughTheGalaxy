-- Ce module implémente la gestion des missiles qui sont lancés
-- par la navette lorsque le joueur appuie sur le contrôleur de tir
local Bomb = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent: groupe d'affichage parent
--   x:      abscisse initiale du missile
--   y:      ordonnée initiale du missile
--   name:   nom de la bombe
--   damage: les dégâts de la bombe
function Bomb:new(params)

  -- on détermine le groupe d'affichage parent
  local parent = params.parent or display.currentStage

  -- La bombe est représenté par une image
  local bomb = display.newCircle( parent, params.x, params.y, 5 )
  bomb:setStrokeColor(1,0,1)
  bomb.strokeWidth = 2
  physics.addBody( bomb, "dynamic")


  -- On determine le nom du missile (Pour plus de possibilité, comme tir ami etc)
  -- ainsi que ses degats et la direction dans laquelle il va
  if(params.name) then bomb.name = params.name else bomb.name = "genericBomb" end
  if(params.damage) then bomb.damage = params.damage else bomb.damage = 1 end



  -- boucle de calcul du déplacement du bomb
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function bomb:enterFrame(event)
    -- le missile se déplace horizontalement à la vitesse spécifiée dans le sens spécifié
    if(GAME_STATE == "ENDED") then self:selfDestroy() end


  end

  function bomb:selfDestroy()
    -- on n'oublie SURTOUT PAS de désactiver la prise en compte
    -- des événéments `enterFrame` pour stopper la "boucle" induite
    -- par les cycles de rafraîchissement graphique
    Runtime:removeEventListener('enterFrame', self)
    bomb:removeEventListener('collision')
    -- et on supprime le missile
    -- (il suffit ici de l'ôter de la pile d'affichage du groupe parent)
    parent:remove(self)
  end

  local function onLocalCollision( self, event )
    if ( event.phase == "began" ) then
        if(event.other.name == "genericMissile"
        or event.other.name == "terrain"
        or event.other.name == "fuel_tank"
        or event.other.name == "rocket"
        ) then
          self:selfDestroy()
        end
    end
  end

  -- Active la détection de la colision pour la bombe
  if(bomb.collision == nil) then bomb.collision = onLocalCollision end

  -- aussitôt généré, le missile est mis en mouvement
  Runtime:addEventListener('enterFrame', bomb)
  bomb:addEventListener('collision')

  bomb:applyForce(0.2)

  return bomb

end

return Bomb
