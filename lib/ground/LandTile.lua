local Map = require 'lib.ground.HeightMap'
local MapHandCrafted = require 'lib.ground.HandCraftedHeightMap'

local LandTile = {}

-- Pour pouvoir correspondre aux besoins du projet
-- Cette algorithme à été modifié

-- la table `params` doit comporter les indexes suivants :
--   yLeft:       altitude de l'extrémité gauche de la carte
--   yRight:      altitude de l'extrémité droite de la carte
--   amplitude:   amplitude du faisceau de tirage aléatoire
--   roughness:   indice de rugosité du terrain ∈ [0,1]
--   iterations:  nombre d'itérations dichotomiques à appliquer
--   orientation: orientation des pics rocheux (up|down)
--   ridgeColor:  couleur de la ligne de crête
--   landColor:   couleur de remplissage des pics rocheux
--   parent:      groupe d'affichage parent
--   physics:     permet de savoir si la boite de colision est active
function LandTile:new(params)

  local tile = display.newGroup()
  tile.ObjectsSpawnPoints = {}
  if params.parent then params.parent:insert(tile) end

  -- génération de la carte de terrain
  local map = {}

  if(not params.spawnableObjects) then
    map = Map:new{
      yLeft      = params.yLeft,
      yRight     = params.yRight,
      amplitude  = params.amplitude,
      roughness  = params.roughness,
      bounded    = true,
      iterations = params.iterations or math.floor(math.log(VCW) / math.log(2)),
    }
  else
    map = MapHandCrafted:new{
      yLeft      = params.yLeft,
      yRight     = params.yRight,
      amplitude  = params.amplitude,
      roughness  = params.roughness,
      bounded    = true,
      iterations = params.iterations or math.floor(math.log(VCW) / math.log(2)),
    }
  end

  -- construction de la "ligne de crête" à partir de la carte de terrain

  local ridge = {}
  -- en fonction du nombre de points que comporte la carte
  -- on est capable de déterminer le nombre de subdivisions de l'écran
  -- qu'ils impliquent, et donc la largeur de chacune de ces subdivisions
  local w = VCW / (#map-1)
  local x,y
  for i=1,#map do          -- pour chaque niveau d'altitude de la carte,
    x = SOX + (i-1) * w    -- on calcule les coordonnées du point (x,y)
    y = SOY + map[i]       -- auquel il correspond sur l'écran
    table.insert(ridge, x) -- on insère alors ces coordonnées dans une liste
    table.insert(ridge, y) -- qui va constituer notre ligne de crête
    if(map.ObjectsSpawnPoints and table.contains(map.ObjectsSpawnPoints, i)) then
      table.insert(tile.ObjectsSpawnPoints, {x,y})
    end
  end

  -- si une couleur de remplissage a été paramétrée
  if (params.landColor) then
    -- on construit le polygone de remplissage à partir de la ligne de crête
    local land = { unpack(ridge) }
    -- il faut fermer la ligne de crête avec le haut ou le bas de l'écran
    -- selon l'orientation des pics rocheux que l'on souhaite
    -- une précaution s'impose : sortir légèrement de l'écran (+1/-1) pour que
    -- les arêtes du polygone ne se chevauchent pas !
    local yOutOfScreen = ((params.orientation == 'up') and SOY + VCH*2) or SOY - 1 - VCH * 2
    table.insert(land, SOX+VCW)
    table.insert(land, yOutOfScreen)
    table.insert(land, SOX)
    table.insert(land, yOutOfScreen)
    -- il ne reste plus qu'à dessiner la forme à l'écran
    tile.fill = display.newPolygon(tile, CCX, yOutOfScreen, land)
    tile.fill:setFillColor(unpack(params.landColor))
    tile.fill.anchorY = ((params.orientation == 'up') and 1) or 0

    -- Ajoute de la physique sur le polygone
    if(params.physics) then
      physics.addBody( tile.fill, "static", {shape = vertices})
      tile.fill.name = "terrain"
    end
  end

  -- si une couleur de crête a été paramétrée
  -- Ici petite modification pour permettre le bord
  -- De suivre le polygone
  if (params.ridgeColor) then
    -- on dessine la ligne de crête
    tile.line = display.newLine(tile, unpack(ridge))
    tile.line:setStrokeColor(unpack(params.ridgeColor))
  end

  return tile

end

return LandTile
