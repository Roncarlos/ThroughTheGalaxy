local FireController = {}

--[[
  Paramètres:
  parent      = parent de l'objet
  x           = emplacmeent voullu pour le controlleur
  y           = pareil mais en x
  eventName   = nom de l'event lié au joystick à executer quand il est appuyé
                c'est la partie "phase" de l'evenement lié au joystick
]]--
function FireController:new(params)

  local parent = params.parent or display.currentStage

  local controller = display.newGroup()
  parent:insert(controller)


  if(params.eventName) then
    controller.eventName = params.eventName
  else
    controller.eventName = "genericEvent"
  end

  -- positionnement du contrôleur à l'écran
  controller.x = params.x
  controller.y = params.y

  -- initialisation du contrôleur
  function init()
    initShapes()
    initListener()
  end

  -- initialisation des composantes graphiques du contrôleur
  function initShapes()
    -- un anneau (uniquement pour l'esthétique)
    local ring = display.newCircle(controller, 0, 0, params.radius)
    ring:setFillColor(0, 0, 0, 0)
    ring:setStrokeColor(1, 1, 1, params.alpha)
    ring.strokeWidth = .2*params.radius

    -- le bouton de tir
    local fire = display.newCircle(controller, 0, 0, .8*params.radius)
    fire:setFillColor(1, 1, 1)
    fire.alpha = params.alpha
    controller.fire = fire
  end

  -- initialisation du gestionnaire d'événements tactiles
  function initListener()
    controller.fire:addEventListener('touch', controller)
  end

  -- gestionnaire des événements tactiles
  function controller:touch(event)
    if (event.phase == 'began') then
      -- le bouton de tir est "illuminé" dès qu'il est sollicité par le joueur
      self.fire.alpha = 1
      -- diffusion d'un événement notifiant que le joueur a tiré
      if(DEBUG) then
        print("Joystick cast: " .. self.eventName)
      end
      Runtime:dispatchEvent{name='joystick', phase=self.eventName}
    elseif (event.phase == 'ended') then
      -- le bouton de tir retrouve sa teinte d'origine lorsqu'il est relâché
      self.fire.alpha = params.alpha
      Runtime:dispatchEvent{name='joystick', phase=self.eventName .. "_stopped"}
      if(DEBUG) then
        print("Joystick cast: " .. self.eventName .. "_stopped")
      end
    end
  end

  -- déclenche l'initialisation du contrôleur
  init()

  return controller

end

return FireController
