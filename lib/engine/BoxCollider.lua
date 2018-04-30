local BoxCollider = {}

-- la table `params` permet de spécifier les réglages suivants :
--   parent:    groupe d'affichage parent
--   x:         abscisse initiale de la navette
--   y:         ordonnée initiale de la navette
--   size:      Taille de la box
function BoxCollider:new(params)
  local _BoxCollider = display.newRect(params.parent, 0, 0, params.size, params.size )
  _BoxCollider:setFillColor(0,0,0,0)
  if(DEBUG) then
    _BoxCollider:setStrokeColor(1,0,0)
    _BoxCollider.strokeWidth = 1
  end

  if(params.name) then _BoxCollider.nameReference = params.name else _BoxCollider.nameReference = "Undefined" end


  return _BoxCollider;

end

return BoxCollider
