local Background = require 'lib.space.GradientBackground'

-- ce module implémente la partie "fixe" du décor (celle qui n'est pas animée)
-- il est constitué :
--   * d'un ciel dégradé
--   * d'un ensemble de trois planètes (de tailles différentes)
local FixedBackground = {}

function FixedBackground:new(parent, color1, color2)

  -- mise en place du fond dégradé (du bleu vers le turquoise)
  BackgroundFixed = display.newGroup()
  parent:insert(BackgroundFixed)

  local c1 = color1 or {0, .2, .3}
  local c2 = color2 or {.3, .8, .8}
  BackgroundFixed.color = Background:new(BackgroundFixed, 'down', c1, c2)
  BackgroundFixed.next  = nil
  colorChanged = false

  -- mise en place de la planète de grande taille
  local bigplanet = display.newCircle(BackgroundFixed,
    CCX + .25*VCW,
    CCY - .25*VCH,
    .07*VCW)
  bigplanet:setFillColor(1, 1, 1, .05)

  -- mise en place de la planète de taille moyenne
  -- elle est placée "en orbite" autour de la plus grande
  local middleplanet = display.newCircle(BackgroundFixed,
    bigplanet.x + .12*VCW * math.cos(-math.pi/10),
    bigplanet.y + .12*VCW * math.sin(-math.pi/10),
    .02*VCW)
  middleplanet:setFillColor(1, 1, 1, .1)

  -- mise en place de la planète de petite taille
  -- elle est également placée "en orbite" autour de la plus grande
  local littleplanet = display.newCircle(BackgroundFixed,
    bigplanet.x + .1*VCW * math.cos(-math.pi/4),
    bigplanet.y + .1*VCW * math.sin(-math.pi/4),
    .01*VCW)
  littleplanet:setFillColor(1, 1, 1, .05)

  function BackgroundFixed:changeColor(color1, color2)
    self.next = Background:new(BackgroundFixed, 'down', color1, color2)
    self.next.alpha = 0
    transition.to( self.color, {time=250, onComplete=BackgroundFixed:onComplete(), alpha=0} )
  end

  function BackgroundFixed:onComplete()
    self.color = nil
    self.color = self.next
    self.next  = nil
    transition.to(self.color, {time=500, transition=easing.inOutCirc, alpha=1})
    bigplanet:toFront()
    middleplanet:toFront()
    littleplanet:toFront()
  end


  return BackgroundFixed


end

return FixedBackground
