local BiDirectionalController = {}

function BiDirectionalController:new(params)

  local parent = params.parent or display.currentStage

  local controller = display.newGroup()
  parent:insert(controller)

  -- positionnement du contrôleur à l'écran
  controller.x = params.x
  controller.y = params.y

  -- écart maximum de la crosse du joystick par-rapport à sa position d'équilibre
  local stickBound  = .5*params.height - .15*params.width
  -- rayon de la crosse du joystick
  local stickRadius = .35*params.width

  -- initialisation du contrôleur
  function init()
    initShapes()
    initListener()
  end

  -- initialisation des éléments graphiques du contrôleur
  function initShapes()
    -- un rectangle arrondi qui délimite la course maximale de la crosse
    local edge = display.newRoundedRect(controller, 0, 0, params.width, params.height, params.width/2)
    edge:setFillColor(0, 0, 0, 0)
    edge:setStrokeColor(1, 1, 1, params.alpha)
    edge.strokeWidth = .1*params.width

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
      self:move('pushed', dy)
    -- si le témoin de saisie de la crosse est activé
    -- alors les autres phases de l'événement sont examinées
    elseif (self.pushed) then
      -- lorsque la crosse est déplacée...
      if (event.phase == 'moved') then
        -- notification de l'action sur la crosse
        self:move('moved', dy)
      -- lorsque la crosse est relâchée
      elseif (event.phase == 'ended' or event.phase == 'cancelled') then
        -- la crosse retrouve sa teinte d'origine lorsqu'elle est relâchée
        self.stick.alpha = params.alpha
        -- le témoin de saisie est aussitôt désactivé
        self.pushed = false
        -- on annule l'extension de la portée de l'écouteur
        display.currentStage:setFocus(nil)
        -- notification de l'action sur la crosse
        self:move('released', dy)
        -- et on ramène la crosse du contrôleur à sa position d'équilibre
        -- avec un petit effet "mécanique" qui simule un retour d'effort
        transition.to(self.stick, {time=150, y=0, transition=easing.outElastic})
      end
    end
  end

  function controller:move(phase, dy)
    -- calcul de la course maximale de la crosse
    local range = stickBound - stickRadius
    -- calcul de l'intensité de la force appliquée dans [-1,1]
    local strength = math.max(math.min(dy, range), -range) / range
    -- actualisation graphique de la crosse
    self.stick.y = strength * range
    -- diffusion d'un événement décrivant l'action appliquée par le joueur
    Runtime:dispatchEvent{name="joystick", phase=phase, strength=strength}
  end

  -- déclenche l'initialisation du contrôleur
  init()

  return controller

end

return BiDirectionalController
