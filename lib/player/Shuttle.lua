local Missile = require 'lib.player.Missile'
local Bomb = require 'lib.player.Bomb'

-- Ce module va nous permettre de simuler une navette volant à basse altitude
-- au-dessus du décor défilant, animée d'un mouvement oscillatoire vertical
local Shuttle = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent:    groupe d'affichage parent
--   x:         abscisse initiale de la navette
--   y:         ordonnée initiale de la navette
--   altimax:   altitude maximum
--   altimin:   altitude mminimum
--   name:      nom de l'objet
--   life:      points de vie du vaisseau
--   ammo:      nombre de munition du vaisseau
--   fuel:      carburant du vaisseau
function Shuttle:new(params)

  local shuttle = display.newGroup()
  local parent = params.parent or display.currentStage
  parent:insert(shuttle)

  shuttle.laserColor        = params.laserColor     or {0,1,0}
  shuttle.backColor         = params.backColor      or {1,1,1}
  shuttle.baseColor         = params.baseColor      or {1,1,1}
  shuttle.aileronsColor     = params.aileronsColor  or {1,1,1}
  shuttle.moteurColor       = params.moteurColor    or {1,1,1}
  shuttle.canonColor        = params.canonColor     or {1,1,1}


  -- définition des propriétés cinématiques (en coordonnées polaires)
  shuttle.v = {r = 0, theta = 0} -- vitesse du défilement
  shuttle.a = {r = 0, theta = 0} -- accélération du défilement



  shuttle.name               = params.name        or "genericShuttle"
  shuttle.life               = params.life        or 20
  shuttle.ammo               = params.ammo        or 50
  shuttle.ammoMax            = shuttle.ammo
  shuttle.fuel               = params.fuel        or 100
  shuttle.fuelMax            = shuttle.fuel
  shuttle.missileAS          = params.missileAS   or 100
  shuttle.bombAS             = params.bombAS      or 1000



  shuttle.isFiringMissile   = false
  shuttle.isFiringBomb      = false

  -- Get / Set
  -- Même si ces fonctions ne sont pas utiles ici, je trouve ça plus clair
  -- Surtout quand on accède à ces variables en dehors de "l'objet"
  function shuttle:getAmmo()
    return shuttle.ammo
  end

  function shuttle:getLife()
    return shuttle.life
  end

  function shuttle:addLife(life)
    self.life = self.life + life
  end



  -- initialisation des composantes graphiques de la navette

  function init()


    -- On créer le vaisseau
    shuttle.back      = display.newImageRect( shuttle, "ressources/images/shippart_back.png", VCW*0.1031, VCW*0.0263)
    shuttle.base      = display.newImageRect( shuttle, "ressources/images/shippart_base.png", VCW*0.1031, VCW*0.0263)
    shuttle.ailerons  = display.newImageRect( shuttle, "ressources/images/shippart_ailerons.png", VCW*0.1031, VCW*0.0263)
    shuttle.moteur    = display.newImageRect( shuttle, "ressources/images/shippart_moteur.png", VCW*0.1031, VCW*0.0263)
    shuttle.canon     = display.newImageRect( shuttle, "ressources/images/shippart_canon.png", VCW*0.1031, VCW*0.0263)


    -- On assigne des couleurs aux parties
    shuttle.back:setFillColor(unpack(shuttle.backColor))
    shuttle.base:setFillColor(unpack(shuttle.baseColor))
    shuttle.ailerons:setFillColor(unpack(shuttle.aileronsColor))
    shuttle.moteur:setFillColor(unpack(shuttle.moteurColor))
    shuttle.canon:setFillColor(unpack(shuttle.canonColor))






    -- tracé de la flamme du réacteur
    shuttle.flame = display.newPolygon(shuttle, 0, 0, {
      0,  0.5,
      16, -5,
      16,  5
    })
    shuttle.flame:setFillColor(1, 1, 1)
    shuttle.flame.anchorX = 1
    shuttle.flame.x = shuttle.back.x - VCW * .05
    shuttle.flame.y = 2

    shuttle.x, shuttle.y = params.x, params.y
    --shuttle.collider = BoxCollider:new{parent=shuttle, x=shuttle.x, y=shuttle.y, size=50}
    physics.addBody( shuttle, "dynamic", {isSensor = true})
    -- Permet de garder la physique pour la collision
    shuttle.gravityScale = 0
    shuttle.isSleepingAllowed = false

  end

  -- boucle de calcul du déplacement de la navette
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function shuttle:enterFrame(event)

    -- Bi Directional Controller here
    --[[ on calcule la vitesse résultante de l'accélération induite
    -- par la force appliquée par le joueur sur le joystick
    -- la vitesse est, en outre, bornée par une vitesse maximale
    self.vy = math.max(-params.speed, math.min(params.speed, self.vy + self.ay))

    -- la nouvelle position de la navette est ensuite calculée en tenant
    -- compte de la vitesse calculée précédemment
    -- l'altitude est, en outre, bornée
    self.y = math.max(params.altimin, math.min(params.altimax, self.y + self.vy))

    -- enfin, pour simuler une perte d'énergie mécanique due au frottement
    -- de la navette dans l'atmosphère, on applique un coefficient réducteur
    -- à la vitesse pour l'affaiblir (ici de 10% de sa valeur initiale)
    self.vy = self.vy * .9--]]


    -- Multi Directional Controller here

    self.v.r = math.min(params.speed, self.v.r + self.a.r)
    self.v.theta = self.a.theta

    -- la nouvelle position du pavage est ensuite calculée en tenant
    -- compte de la vitesse calculée précédemment
    self.x = math.max(VCW*0.05, math.min(VCW*.9, self.x - self.v.r * math.cos(self.v.theta)))
    self.y = math.max(params.altimin, math.min(params.altimax, self.y - self.v.r * math.sin(self.v.theta)))

    -- enfin, pour simuler une perte d'énergie mécanique due au frottement
    -- de la bille sur le pavage, on applique un coefficient réducteur à la
    -- vitesse pour l'affaiblir (ici de 10% de sa valeur initiale)
    self.v.r = self.v.r * .9




    -- on peut également appliquer un indice de transparence à la flamme
    -- du réacteur de manière aléatoire pour simuler un visuel "perturbé"
    -- de l'effet de la combustion
    self.flame.alpha = .5*math.random()
  end

  function shuttle:joystick(event)
    if (event.phase == 'moved') then
      -- dès que le joueur applique une force sur le joystick,
      -- elle est transformée en une force motrice
      -- qui engendre, à son tour, une accélération
      --[[self.ay = .5*event.strength--]]

      self.a.r     = .5*event.strength
      self.a.theta = math.rad(event.angle) + math.pi
    elseif (event.phase == 'released') then
      -- lorsque le joystick est relâché, la force est annulée,
      -- et l'accélération du même coup
      --self.ay = 0

      self.a.r     = 0
    elseif (event.phase == 'fired') then

      -- Ceci est un fix d'un bug pouvant se produire.
      -- En effet sur le simulateur, nous venions à quitter l'écran alors que
      -- l'on clique sur le bouton, il s'avère que le timer ne se cancel pas puisque
      -- l'event xxx_fired_stopped ne se déclenche pas
      -- du coup grace à cette petite partie, si un timer est déjà actif on le
      -- supprime. Même si ce bug peut ne pas arriver sur mobile, la prudence
      -- est de rigueur.
      if(self.firingMissile) then timer.cancel(self.firingMissile); self.firingMissile = nil end

      -- Je créer une fonction en "closure" pour pouvoir faire passer un argument
      -- Lors de l'appel avec performWithDelay
      -- Ici cela permet de continuer de tirer tant que le doigt est sur le bouton
      -- de tir
      local missileFunc = function() return self:fire(0) end
      self.firingMissile = timer.performWithDelay(self.missileAS,missileFunc,-1)

      -- Ici c'est pour que le premier tir soit instantané bien sur je prends en
      -- compte le fait que si le joueur veut "flood" le bouton celui ci ne peut
      -- pas tirer plus vite que son "attack speed"
      if(self.isFiringMissile == false) then
        self:fire(0)
      end


    elseif (event.phase == "bomb_fired") then
      if(self.firingBomb) then timer.cancel(self.firingBomb); self.firingBomb = nil end


      -- Ici je fais la même chose qu'en haut mais pour les bombes
      local bombFunc = function() return self:fire(1) end
      self.firingBomb = timer.performWithDelay(self.bombAS,bombFunc,-1)

      -- Ici même chose qu'en haut
      if(self.isFiringBomb == false) then
        self:fire(1)
      end

    -- Partie de suppression des tirs
    -- Ajout de vérification si le timer existe (HOTFIX)
    elseif (event.phase == "fired_stopped" and self.firingMissile) then
      timer.cancel(self.firingMissile)
    elseif (event.phase == "bomb_fired_stopped" and self.firingBomb) then
      timer.cancel(self.firingBomb)
    end

  end

  function shuttle:fire(fireNum)
    -- 1 -> Tir de laser
    -- 2 -> Tir de bomb
    -- On verifie si on ne tire pas pour tirer (avec un délai qui est l'attack speed)
    -- Puis on vérifie si on a les munitions
    -- Puis on tire et on décrémente les munitions
    if(fireNum == 0) then
      self.isFiringMissile = true
      local isFiringMissile = function() self.isFiringMissile = false end
      timer.performWithDelay( self.missileAS, isFiringMissile, 1)
      if(self.ammo > 0) then
        Missile:new{
          parent = parent,
          x      = self.x + 10,
          y      = self.y + 6.5,
          length = 10,
          speed  = 10,
          color  = shuttle.laserColor,
          name   = "playerMissile",
        }
        self.ammo = self.ammo - 1
      end

      -- SOUND
      if(SETTINGS.sounds) then
        audio.play(SOUND_LASER)
      end


    elseif(fireNum == 1) then

      self.isFiringBomb = true
      local isFiringBomb = function() self.isFiringBomb = false end
      timer.performWithDelay( self.bombAS, isFiringBomb, 1)

      if(self.ammo >= 10) then
        Bomb:new{
          parent = parent,
          x      = self.x + 20,
          y      = self.y + 2,
          name   = "playerBomb",
        }
        self.ammo = self.ammo - 10
      end

    end
  end

  -- activation du déplacement
  function shuttle:start()
    if(shuttle.collision == nil) then shuttle.collision = onLocalCollision end

    Runtime:addEventListener('enterFrame', self)
    Runtime:addEventListener('joystick', self)
    shuttle:addEventListener("collision")
  end

  -- arrêt du déplacement
  function shuttle:stop()
    shuttle.collision = nil
    Runtime:removeEventListener('enterFrame', self)
    Runtime:removeEventListener('joystick', self)
    physics.removeBody( self )

    -- Permet de désactiver les tirs automatiques si le joueur meurt avant
    -- d'avoir enlever son doigt du bouton de tir
    -- HOTFIX pouvait causer une erreur si on ne le faisait pas
    if(self.firingMissile) then timer.cancel( self.firingMissile ); self.firingMissile = nil end
    if(self.firingBomb) then timer.cancel(self.firingBomb); self.firingBomb = nil end
    parent:remove(self)
    self = nil
  end

  function onLocalCollision( self, event )

    if ( event.phase == "began" ) then
        if(event.other.name == "genericMissile" or event.other.name == "enemyMissile") then
          self.life = self.life - event.other.damage
        elseif(event.other.name == "terrain") then
          self.life = 0
        end

    elseif ( event.phase == "ended" ) then

    end
  end

  -- on procède à l'initialisation de la navette
  init()

  return shuttle

end

return Shuttle
