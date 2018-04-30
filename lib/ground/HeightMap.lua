-- ------------------------------------------------------------------------
-- Génération aléatoire de terrain fractal
-- Technique de déplacement du point médian
-- ------------------------------------------------------------------------
-- https://bitesofcode.wordpress.com/2016/12/23/landscape-generation-using-midpoint-displacement/
-- ------------------------------------------------------------------------
-- L'idée consiste ici à générer une carte de terrain représentée par une
-- liste de niveaux d'altitude calculés aléatoirement dans un faisceau
-- défini par :
--   l'altitude de l'extrémité gauche de la carte
--   l'altitude de l'extrémité droite de la carte
--   une amplitude de tirage aléatoire
--
-- L'algorithme de déplacement du point médian est récursif et procède
-- par découpage dichotomique de l'intervalle situé entre les extrémités
-- gauche et droite de la carte.
--
-- Le nombre de valeurs (d'altitude) que comporte la carte dépend du nombre
-- d'itérations de l'algorithme de calcul. En effet :
--   1 itération  --> 3 valeurs
--   2 itérations --> 5 valeurs
--   3 itérations --> 9 valeurs
--   n itérations --> (2^n + 1) valeurs
-- ------------------------------------------------------------------------
-- Exemple de carte à (2^4 + 1) = 17 valeurs (obtenue après 4 itérations)
--
--    - - - - - ------------------------•------------------------   - amplitude
--    |                           •  •    •
--    |                        •                 •
--    |               •                       •
--    |            •        •                       •
--  y |  yLeft  o  -  -  •  -  -  -  -  -  -  -  -  -  -  -  -  o   yRight
--    |                                                •     •
--    |                                                   •
--    |
--    v
--    - - - - - |--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|   + amplitude
--              1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17
-- ------------------------------------------------------------------------

local HeightMap = {}

-- la table `params` doit comporter les indexes suivants :
--   yLeft:      altitude de l'extrémité gauche de la carte
--   yRight:     altitude de l'extrémité droite de la carte
--   amplitude:  amplitude du faisceau de tirage aléatoire
--   bounded:    flag indiquant si l'amplitude est une borne stricte
--   roughness:  indice de rugosité du terrain ∈ [0,1]
--   iterations: nombre d'itérations à appliquer
function HeightMap:new(params)

  -- on calcule la ligne de base définie par l'altitude moyenne des extrémités,
  -- de façon à borner les valeurs calculées autour de cette ligne de référence
  -- par l'amplitude si celle-ci est stricte
  local baseLine = (params.yLeft + params.yRight) / 2

  -- on s'assure que l'indice de rugosité est bien compris dans [0,1]
  -- et s'il n'est pas spécifié, il est fixé à 0.5 par défaut
  local roughness = math.min(1, math.max(0, params.roughness or .5))

  -- on calcule le nombre de points de la carte en fonction du nombre
  -- d'itérations de l'algorithme que l'on souhaite appliquer
  local n = math.pow(2, params.iterations) + 1

  -- la carte que l'on va calculer est un simple tableau
  local map = {}
  -- que l'on va pré-remplir de la manière suivante :
  map[1] = params.yLeft  -- on fixe l'altitude de l'extrémité gauche de la carte
  for i=2,n-1 do         -- puis des valeurs arbitraires pour tous les "points"
    map[i] = 0           -- situés entre les extrémités de la carte
  end
  map[n] = params.yRight -- on fixe l'altitude de l'extrémité droite de la carte

  -- la fonction de calcul des niveaux d'altitude de la carte est récursive
  -- par nature et nécessite, à chaque étape, la connaissance de :
  --   step:  numéro de l'étape en cours
  --   first: indice de l'extrémité gauche de l'intervalle examiné à cette étape
  --   last:  indice de l'extrémité droite de l'intervalle examiné à cette étape
  function buildMap(step, first, last)

    -- on calcule l'indice du point médian de l'intervalle
    local middle = (first + last) / 2
    -- on récupère les niveaux d'altitude des extrémités de l'intervalle
    local y1 = map[first]
    local y2 = map[last]

    local displacement,y
    repeat
      -- on calcule le déplacement aléatoire à appliquer au point médian
      -- ce déplacement est encadré par un faisceau dont l'amplitude a été
      -- fournie comme paramètre de la fonction "new"
      displacement = params.amplitude * (2*math.random() - 1)
      -- il faut ensuite appliquer une réduction à ce déplacement pour éviter
      -- de trop grandes variations d'altitude entre les étapes successives de
      -- l'algorithme.
      -- c'est là qu'intervient l'indice de rugosité (0 ≤ roughness ≤ 1) :
      -- multiplier le déplacement par ce facteur à chaque itération permettra
      -- de l'affaiblir de manière exponentielle :
      --   étape 1 : on ne touche à rien (le déplacement reste inchangé)
      --   etape n : on multiple le déplacement par roughness^(n-1)
      displacement = math.pow(roughness, step-1) * displacement
      -- il ne reste plus qu'à appliquer ce déplacement au point médian
      y = (y1 + y2) / 2 + displacement
      -- et vérifier si l'altitude résultante est bien située à l'intérieur du
      -- domaine de valeurs acceptables, dans le cas où l'amplitude doit être
      -- considérée comme une borne stricte
    until not params.bounded or (math.abs(y - baseLine) <= params.amplitude)

    -- et on stocke, dans la carte, le niveau d'altitude obtenu
    map[middle] = y

    -- tant qu'on n'a pas appliqué toutes les itérations, on continue en
    -- passant à l'étape suivante (step+1), de part et d'autre du point médian
    if (step < params.iterations) then
      buildMap(step+1, first, middle)
      buildMap(step+1, middle, last)
    end

  end

  -- on initialise le calcul de la carte en démarrant le processus par l'étape
  -- numéro 1, entre le premier et le dernier "point" de la carte
  buildMap(1, 1, #map)
  return map

end

return HeightMap
