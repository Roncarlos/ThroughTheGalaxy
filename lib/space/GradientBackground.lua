-- ce module permet simplement de tracer un rectangle recouvrant la totalité
-- de l'écran, avec un remplissage en dégradé de couleurs (2 couleurs)
local GradientBackground = {}

function GradientBackground:new(
  parent,    -- groupe d'affichage parent
  direction, -- orientation du dégradé (up|down|left|right)
  color1,    -- teinte initiale du dégradé
  color2     -- teinte finale du dégradé
)

  local background = display.newRect(parent, CCX, CCY, VCW, VCH)
  background:setFillColor{ type='gradient', color1=color1, color2=color2, direction=direction }

  return background

end

return GradientBackground
