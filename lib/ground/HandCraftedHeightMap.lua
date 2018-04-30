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

  local maxToPlace = math.random(n*.3,n*.5)
  local placed = 0

  -- la carte que l'on va calculer est un simple tableau
  local map = {}
  map.ObjectsSpawnPoints = {}
  -- que l'on va pré-remplir de la manière suivante :
  map[1] = params.yLeft  -- on fixe l'altitude de l'extrémité gauche de la carte
  map[n] = params.yRight -- on fixe l'altitude de l'extrémité droite de la carte
  for i=2,n-1 do         -- puis des valeurs arbitraires pour tous les "points"
    displacement = params.amplitude * (2*math.random() - 1)
    if(placed < maxToPlace and math.random() > 0.5) then
      map[i] = map[i-1]
      placed = placed + 1
      table.insert( map.ObjectsSpawnPoints, i-1 )
    else
      displacement = math.pow(roughness, map[i-1]) * displacement
      map[i] = (params.yLeft + params.yRight) * .5 + displacement
    end
  end

  return map

end

return HeightMap
