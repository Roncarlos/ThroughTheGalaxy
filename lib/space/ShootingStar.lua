-- Ce module va nous permettre de modéliser des étoiles filantes
-- qui vont parcourir toute la largeur de l'écran, horizontalement,
-- à une vitesse donnée
local ShootingStar = {}

-- la table `params` permet de spécifier les paramètres suivants :
--   parent: le groupe d'affichage parent
--   floor:  l'altitude minimum de l'étoile
--   speed:  la vitesse de l'étoile
--   alpha:  l'opacité de l'étoile (qui traduit son intensité lumineuse)
function ShootingStar:new(params)

  -- on détermine le groupe d'affichage parent de l'étoile
  local parent = params.parent or display.currentStage
  -- on crée une étoile avec sa traînée pour lui donner l'apparence
  -- d'une étoile filante : un rectangle de hauteur 1, qu'on va pouvoir remplir
  -- avec un dégradé du blanc vers le transparent
  local star = display.newRect(parent, SOX + VCW, SOY + params.floor*math.random(), params.length, 1)
  star:setFillColor{type='gradient', color1={1, 1, 1}, color2={1, 1, 1, 0}, direction='right'}
  -- le "centre" de l'étoile (son point d'ancrage) est situé au point le plus
  -- étincelant, c'est à dire à l'extrémité gauche (naissance de la traînée)
  star.anchorX = -1
  -- on applique l'intensité lumineuse spécifiée
  star.alpha = params.alpha

  -- boucle de calcul du déplacement de l'étoile
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function star:enterFrame(event)
    -- lorsque l'étoile est entièrement sortie de l'écran,
    -- elle devient inutile...
    if (self.x < -params.length or GAME_STATE == "ENDED") then
      -- donc on arrête la boucle chargée d'effectuer son déplacement
      self:stop()
      -- et on supprime l'objet graphique
      -- en le retirant de son groupe d'affichage
      self:removeSelf()
    end
    self.x = self.x - params.speed
  end

  -- activation du déplacement
  function star:start()
    Runtime:addEventListener('enterFrame', self)
  end

  -- arrêt du déplacement
  function star:stop()
    Runtime:removeEventListener('enterFrame', self)
  end

  -- on lance le calcul du déplacement de l'étoile
  star:start()

  return star

end

return ShootingStar
