-- Ce module implémente un contrôleur de mouvement tactile
-- à la manière d'un joystick multidirectionnel
local MultiDirectionalController = {}

-- le constructeur prend un unique argument `params`, qui est une table
-- indexée par les paramètres suivants :
--   parent: groupe d'afffichage parent
--   x:      abscisse du contrôleur
--   y:      ordonnée du contrôleur
--   radius: rayon externe du contrôleur
--   alpha:  indice d'opacité du contrôleur
function MultiDirectionalController:new(params)

  local parent = params.parent or display.currentStage

  local controller = display.newGroup()
  parent:insert(controller)

  -- positionnement du contrôleur à l'écran
  controller.x = params.x
  controller.y = params.y

  -- écart maximum de la crosse du joystick par-rapport à son axe central
  local stickBound  = .8*params.radius
  -- rayon de la crosse du joystick
  local stickRadius = .4*params.radius

  -- initialisation du contrôleur
  function init()
    initShapes()
    initListener()
  end

  -- initialisation des éléments graphiques du contrôleur
  function initShapes()
    -- un anneau qui délimite la course maximale de la crosse
    local ring = display.newCircle(controller, 0, 0, params.radius)
    ring:setFillColor(0, 0, 0, 0)
    ring:setStrokeColor(1, 1, 1, params.alpha)
    ring.strokeWidth = .2*params.radius

    -- la crosse qui peut être écartée de son axe central par le joueur
    local stick = display.newCircle(controller, 0, 0, stickRadius)
    stick:setFillColor(1, 1, 1)
    stick.alpha = params.alpha
    controller.stick = stick
  end

  -- initialisation du gestionnaire d'événements tactiles
  function initListener()
    controller.stick:addEventListener('touch', controller)
  end

  -- gestionnaire des événements tactiles
  function controller:touch(event)
    local dx = event.x - event.xStart
    local dy = event.y - event.yStart
    -- lorsque la crosse est saisie...
    if (event.phase == 'began') then
      -- la crosse est "illuminée" dès qu'elle est saisie par le joueur
      self.stick.alpha = 1
      -- on étend la portée de l'écouteur à la scène globale
      -- car le doigt du joueur peut glisser hors de la surface "sensorielle"
      -- on lui associe du même coup l'identifiant de l'événement pour
      -- ne pas le confondre (au cours des autres phases) avec des événements
      -- tactiles qui pourraient survenir sur un autre récepteur tactile
      display.currentStage:setFocus(self.stick, event.id)
      -- on active un témoin qui assure que la crosse a bien été saisie
      -- de façon à autoriser la gestion des autres phases de l'événement
      self.pushed = true
      -- notification de l'action sur la crosse
      self:move('pushed', dx, dy)
    -- si le témoin de saisie de la crosse est activé
    -- alors les autres phases de l'événement sont examinées
    elseif (self.pushed) then
      -- lorsque la crosse est déplacée...
      if (event.phase == 'moved') then
        -- notification de l'action sur la crosse
        self:move('moved', dx, dy)
      -- lorsque la crosse est relâchée
      elseif (event.phase == 'ended' or event.phase == 'cancelled') then
        -- la crosse retrouve sa teinte d'origine lorsqu'elle est relâchée
        self.stick.alpha = params.alpha
        -- le témoin de saisie est aussitôt désactivé
        self.pushed = false
        -- on annule l'extension de la portée de l'écouteur
        display.currentStage:setFocus(nil)
        -- notification de l'action sur la crosse
        self:move('released', dx, dy)
        -- et on ramène la crosse du contrôleur à sa position d'équilibre
        -- avec un petit effet "mécanique" qui simule un retour d'effort
        transition.to(self.stick, {time=150, x=0, y=0, transition=easing.outElastic})
      end
    end
  end

  -- cette fonction déplace graphiquement la crosse du contrôleur sous l'action
  -- du joueur, et calcule un couple (strength, angle) décrivant l'intensité
  -- et l'angle du vecteur de force appliquée :
  --   `strength` est un coefficient compris dans l'intervalle [0, 1]
  --   `angle` est initialement calculé en radians
  -- l'action du joueur sur la crosse est alors diffusée via un événement
  -- porteur des informations suivantes :
  --   phase:    indique la nature de l'action (pushed, moved, released)
  --   strength: indique l'intensité de la force appliquée par le joueur
  --   angle:    indique l'angle de la force appliquée par le joueur
  function controller:move(phase, dx, dy)
    -- calcul de la course maximale de la crosse
    local range = stickBound - stickRadius
    -- calcul de la course réelle (mais bornée) de la crosse
    local dr = math.min(math.sqrt(dx*dx + dy*dy), range)
    -- calcul de l'intensité de la force appliquée dans [0,1]
    local strength = dr / range
    -- calcul de l'angle de la force appliquée en radians
    local angle = math.atan2(dy, dx)
    -- actualisation graphique de la crosse
    self.stick.x = dr * math.cos(angle)
    self.stick.y = dr * math.sin(angle)
    -- diffusion d'un événement décrivant l'action appliquée par le joueur
    Runtime:dispatchEvent{name="joystick", phase=phase, strength=strength, angle=math.deg(angle)}
  end

  -- déclenche l'initialisation du contrôleur
  init()

  return controller

end

return MultiDirectionalController
