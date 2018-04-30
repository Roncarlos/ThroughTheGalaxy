-- Ce module implémente la représentation d'un ciel étoilé sous la forme
-- d'un calque recouvrant une surface équivalente à 2 écrans juxtaposés
-- horizontalement : une partie "gauche" et une partie "droite".
--
-- Les étoiles sont réparties à l'identique sur chaque partie du calque.
-- On fait alors défiler ce calque à l'écran vers la gauche. De cette façon,
-- lorsque la partie gauche du calque disparaît progressivement de l'écran,
-- celle de droite apparaît progressivement dans le même temps.
--
--                +---------+ - - - - +    A et A' sont visuellement
--                |    A    |    A'   |
--                +---------+ - - - - +           identiques
--                   <---
--      + - - - - +---------+
--      |    A    |    A'   |
--      + - - - - +---------+
--
-- Les parties gauche et droite étant identiques, lorsqu'on atteint la position
-- limite (qui correspond à l'étape ou la partie droite occupe entièrement
-- l'écran, alors que la partie gauche en est totalement sortie), on est revenu
-- à la scène initiale.
--
-- Il suffit donc de replacer instantanément le calque dans sa position initiale
-- (l'observateur ne s'en rend pas compte puisque les parties gauche et droite
-- du calque sont identiques) avant de poursuivre le processus de défilement.
--
-- De cette manière, on donne l'impression à l'observateur qu'un décor défile
-- indéfiniment sous ses yeux de manière continue.
--
local StellarLayer = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent: le groupe d'affichage parent
--   stars:  le nombre d'étoiles figurant sur chaque partie du calque
--   speed:  la vitesse de défilement du calque
--   floor:  l'altitude minimum des étoiles
function StellarLayer:new(params)

  -- création du calque
  local layer = display.newGroup()
  -- on détermine le groupe d'affichage dans lequel est inséré le calque
  local parent = params.parent or display.currentStage
  parent:insert(layer)

  -- réglages des paramètres du calque (avec des valeurs par défaut)
  local numberOfStars = params.stars or 20
  local speed         = params.speed or 1
  local floor         = params.floor or VCH
  layer.night         = params.night or false
  layer.stars         = display.newGroup()

  -- fonction d'initialisation du calque
  function init()
    local star,copy,x,y,color,alpha
    -- pour chaque étoile à insérer dans le "ciel"
    for i=1,numberOfStars do
      -- on détermine ses coordonnées (sur la partie gauche du calque)
      x = SOX + math.random()*VCW
      y = SOY + math.random()*floor
      -- sa couleur
      color = {.5, .5+math.random(1,3)/6, .5+math.random(1,2)/4}
      -- et son opacité (qui dépend ici de son altitude)
      -- J'ai décidé d'activé malgré tous le stellar layer, même si c'est le jour
      -- La perte en temps CPU est acceptable, et cela permet de pas rendre le code
      -- Plus complexe pour rien
      alpha = 1 - (y - SOY)/floor
      -- on crée alors l'étoile sur la partie gauche du calque
      star = display.newCircle(layer, x, y, 1)
      star.alphaSave = alpha
      -- et sa jumelle sur la partie droite du calque
      copy = display.newCircle(layer, x+VCW, y, 1)
      copy.alphaSave = alpha
      -- il ne reste plus qu'à appliquer la même apparence à chacune
      star:setFillColor(unpack(color))
      copy:setFillColor(unpack(color))
      if(layer.night == true) then
        star.alpha = alpha
        copy.alpha = alpha
      else
        star.alpha = 0
        copy.alpha = 0
      end
    end
  end

  -- boucle de défilement du calque :
  -- elle est synchronisée sur les cycles de rafraîchissement graphique
  function layer:enterFrame(event)
    self.x = self.x - speed
    -- lorsque le calque s'est déplacé d'au moins une largeur d'écran,
    -- on le recadre instantanément :
    if (self.x < - VCW) then self.x = self.x + VCW end
  end

  -- démarrage du défilement
  function layer:start()
    Runtime:addEventListener('enterFrame', self)
  end

  -- arrêt du défilement
  function layer:stop()
    Runtime:removeEventListener('enterFrame', self)
  end

  function layer:changeOpacity()
    if(layer.night) then
      for i=layer.numChildren,1,-1 do
        layer[i].alpha = layer[i].alphaSave
      end
    else
      for i=layer.numChildren,1,-1 do
        layer[i].alpha = 0
      end
    end
  end
  -- on procède à l'initialisation du calque
  init()

  return layer

end

return StellarLayer
