local widget = require "widget"
local composer = require "composer"
local PlayerData   = require "lib.dataControl.PlayerData"

local CustomizeShip = {}


-- Fonction pour copier table
-- !Important
function table.copy(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do res[table.copy(k)] = table.copy(v) end
  return res
end

--[[
Ici pour plus de clarté (c'est mon avis personnel)
J'ai préféré ne jamais utilisé "self"
La table params contient les paramètres du bouton:
parent        : parent du racapitulatif
]]--
function CustomizeShip:new(params)

  local ShipCustomizations_GUI = display.newGroup()
  local credits          = PLAYER_DATA.commander.credits

  -- Ici active part permet de savoir quelle partie on a chois
  -- Et active color permet de connaitre la couleur actuellement sélectionné
  local activePart       = 1
  local activeColor      = {0,0,0}

  if(params.parent) then
    params.parent:insert(ShipCustomizations_GUI)
  end

  -- Fonction pour mettre à jour les crédits
  function ShipCustomizations_GUI:updateCredits()
    credits                             = PLAYER_DATA.commander.credits
    ShipCustomizations_GUI.credits.text = credits
  end

  -- Fonction qui va sauvegarder les données de couleurs du vaisseau
  function shipPlayerDataColorSave()

    -- Je mets les données dans le player data
    PLAYER_DATA.sfx.laserColor            = table.copy(ShipCustomizations_GUI.laserShip.color)
    PLAYER_DATA.sfx.shipBackColor         = table.copy(ShipCustomizations_GUI.backShip.color)
    PLAYER_DATA.sfx.shipBaseColor         = table.copy(ShipCustomizations_GUI.baseShip.color)
    PLAYER_DATA.sfx.shipAileronsColor     = table.copy(ShipCustomizations_GUI.aileronsShip.color)
    PLAYER_DATA.sfx.shipMoteurColor       = table.copy(ShipCustomizations_GUI.moteurShip.color)
    PLAYER_DATA.sfx.shipCanonColor        = table.copy(ShipCustomizations_GUI.canonShip.color)

    -- Puis je suavegarde les données
    PlayerData:save()
  end


  -- Fonction qui change la couleur du vaisseau lorsque l'on valide
  function ShipCustomizations_GUI:shipUpdateColor()
    -- Je change la couleur des parties
    ShipCustomizations_GUI.laserShip:setFillColor(unpack(PLAYER_DATA.sfx.laserColor))
    ShipCustomizations_GUI.backShip:setFillColor(unpack(PLAYER_DATA.sfx.shipBackColor))
    ShipCustomizations_GUI.baseShip:setFillColor(unpack(PLAYER_DATA.sfx.shipBaseColor))
    ShipCustomizations_GUI.aileronsShip:setFillColor(unpack(PLAYER_DATA.sfx.shipAileronsColor))
    ShipCustomizations_GUI.moteurShip:setFillColor(unpack(PLAYER_DATA.sfx.shipMoteurColor))
    ShipCustomizations_GUI.canonShip:setFillColor(unpack(PLAYER_DATA.sfx.shipCanonColor))

    -- J'ajoute un attribut aux partie contenant leur couleur
    ShipCustomizations_GUI.laserShip.color         = table.copy(PLAYER_DATA.sfx.laserColor)
    ShipCustomizations_GUI.backShip.color          = table.copy(PLAYER_DATA.sfx.shipBackColor)
    ShipCustomizations_GUI.baseShip.color          = table.copy(PLAYER_DATA.sfx.shipBaseColor)
    ShipCustomizations_GUI.aileronsShip.color      = table.copy(PLAYER_DATA.sfx.shipAileronsColor)
    ShipCustomizations_GUI.moteurShip.color        = table.copy(PLAYER_DATA.sfx.shipMoteurColor)
    ShipCustomizations_GUI.canonShip.color         = table.copy(PLAYER_DATA.sfx.shipCanonColor)

  end

  -- Applique à la partie active la couleur du vaisseau
  function shipPartUpdateColor()
    if(activePart == 1) then
      ShipCustomizations_GUI.baseShip:setFillColor(unpack(activeColor))
      ShipCustomizations_GUI.baseShip.color = table.copy(activeColor)
    elseif(activePart == 2) then
      ShipCustomizations_GUI.backShip:setFillColor(unpack(activeColor))
      ShipCustomizations_GUI.backShip.color = table.copy(activeColor)
    elseif(activePart == 3) then
      ShipCustomizations_GUI.aileronsShip:setFillColor(unpack(activeColor))
      ShipCustomizations_GUI.aileronsShip.color = table.copy(activeColor)
    elseif(activePart == 4) then
      ShipCustomizations_GUI.moteurShip:setFillColor(unpack(activeColor))
      ShipCustomizations_GUI.moteurShip.color = table.copy(activeColor)
    elseif(activePart == 5) then
      ShipCustomizations_GUI.canonShip:setFillColor(unpack(activeColor))
      ShipCustomizations_GUI.canonShip.color = table.copy(activeColor)
    elseif(activePart == 6) then
      ShipCustomizations_GUI.laserShip:setFillColor(unpack(activeColor))
      ShipCustomizations_GUI.laserShip.color = table.copy(activeColor)
    end
  end
  -- BBAMCL

  -- Les fonctions liés directement aux boutons sont ici

  -- Fonction pour le bouton valider
  function validationButtonReleased()
    --print_r(PLAYER_DATA.sfx)
    if(PLAYER_DATA.commander.credits >= 50) then

      -- Première chose on met à jour les crédits du joueur
      PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits -50
      ShipCustomizations_GUI.credits.text = PLAYER_DATA.commander.credits

      -- Puis : on sauvegarde
      shipPlayerDataColorSave()


      -- Aficher un texte pour dire que c'est bon
      ShipCustomizations_GUI.achat_msg:setFillColor(0,0.8,0)
      ShipCustomizations_GUI.achat_msg.text = "Achat réussi !"

    else
      -- Aficher un texte pour dire que le joueur n'a pas assez de crédit
      ShipCustomizations_GUI.achat_msg:setFillColor(0.8,0,0)
      ShipCustomizations_GUI.achat_msg.text = "Vous n'avez pas assez de crédits !"

    end
    -- Affiche le message
    transition.to( ShipCustomizations_GUI.achat_msg, {alpha=1, onComplete=fadeToNone, time=1000 })
  end

  -- Fonction pour cacher le texte d'achat
  function fadeToNone()
    transition.to( ShipCustomizations_GUI.achat_msg, {alpha=0, time=1000})
  end

  -- Les fonctions qui selectionne la partie active
  -- Elle ne font que faire se déplacer le rectangle de sélection
  -- Puis elle change la variable activePart
  function baseButtonReleased(event)
    if(activePart ~= 1) then
      transition.to( ShipCustomizations_GUI.selection, {x=ShipCustomizations_GUI.base.x, time=200, transition=easing.inOutCirc} )
      activePart = 1
    end
  end

  function backButtonReleased(event)
    if(activePart ~= 2) then
      activePart = 2
      transition.to( ShipCustomizations_GUI.selection, {x=ShipCustomizations_GUI.back.x, time=200, transition=easing.inOutCirc} )
    end
  end

  function aileronsButtonReleased(event)
    if(activePart ~= 3) then
      activePart = 3
      transition.to( ShipCustomizations_GUI.selection, {x=ShipCustomizations_GUI.ailerons.x, time=200, transition=easing.inOutCirc} )
    end
  end

  function moteurButtonReleased(event)
    if(activePart ~= 4) then
      activePart = 4
      transition.to( ShipCustomizations_GUI.selection, {x=ShipCustomizations_GUI.moteur.x, time=200, transition=easing.inOutCirc} )
    end
  end

  function canonButtonReleased(event)
    if(activePart ~= 5) then
      activePart = 5
      transition.to( ShipCustomizations_GUI.selection, {x=ShipCustomizations_GUI.canon.x, time=200, transition=easing.inOutCirc} )
    end
  end

  function laserColorButtonReleased(event)
    if(activePart ~= 6) then
      activePart = 6
      transition.to( ShipCustomizations_GUI.selection, {x=ShipCustomizations_GUI.laserColor.x, time=200, transition=easing.inOutCirc} )
    end
  end

  -- Les evenements pour les sliders
  -- Les sliders vont modifier la couleur actuelle
  -- Et l'appliquer sur la partie du vaisseau active

  -- Fonction qui reset les sliders à 0
  function ShipCustomizations_GUI:resetSliders()
    ShipCustomizations_GUI.redSlider:setValue(0)
    ShipCustomizations_GUI.greenSlider:setValue(0)
    ShipCustomizations_GUI.blueSlider:setValue(0)
  end

  -- J'utilise la multiplication pour des raisons de performances (ref. coronaDoc)
  -- Rouge en premier
  function redSliderListener( event )
    activeColor[1] = event.value * 0.01
    shipPartUpdateColor()
  end

  -- Vert en deuxième
  function greenSliderListener( event )
    activeColor[2] = event.value * 0.01
    shipPartUpdateColor()
  end

  -- Bleue en deuxième
  function blueSliderListener( event )
    activeColor[3] = event.value * 0.01
    shipPartUpdateColor()
  end



  function init()


    -- Titre du menu
    ShipCustomizations_GUI.title_stroke = display.newText({
  		parent 			= ShipCustomizations_GUI,
  		text				= "Selectionnez la partie à personaliser,\n puis la couleur et cliquez sur valider\nPrix : 50 Credits la peinture",
  		x						= CCX,
  		y						=	VCH*.0825,
  		font				=	FONT_NORMAL,
  		fontSize 		= VCW*.0275,
      align       = "center"
  	})

  	ShipCustomizations_GUI.title = display.newText({
  		parent			= ShipCustomizations_GUI,
      text				=	"Selectionnez la partie à personaliser,\n puis la couleur et cliquez sur valider\nPrix : 50 Credits la peinture",
      x						=	CCX,
      y						=	VCH*.08,
      font				= FONT_NORMAL,
      fontSize 		= VCW*.0275,
      align       = "center"
    })

    ShipCustomizations_GUI.title:setFillColor(1,1,0)
    ShipCustomizations_GUI.title_stroke:setFillColor(1,0.5,0)

    -- Nombres de crédits
    ShipCustomizations_GUI.creditsBG = display.newRect(ShipCustomizations_GUI, VCW*.89, VCH*.94, VCW*.20, VCH*.09 )
    ShipCustomizations_GUI.creditsBG:setFillColor(0, 0, 0, .4)
    ShipCustomizations_GUI.creditsBG:setStrokeColor(.8, .8, .8, .4)
    ShipCustomizations_GUI.creditsBG.strokeWidth = 1
    ShipCustomizations_GUI.credits   = display.newEmbossedText({
        parent   = ShipCustomizations_GUI,
        text     = credits,
        x        = ShipCustomizations_GUI.creditsBG.x - VCW*.01,
        y        = ShipCustomizations_GUI.creditsBG.y + VCH * .025,
        font     = FONT_DIGITAL,
        fontSize = VCW * .025,
        align    = "right",
        width    = ShipCustomizations_GUI.creditsBG.width,
        height   = ShipCustomizations_GUI.creditsBG.height,
      })
    ShipCustomizations_GUI.credits:setFillColor(1, 1, 0)

    -- Texte a afficher si achat réussi ou non
    ShipCustomizations_GUI.achat_msg = display.newEmbossedText({
      parent			= ShipCustomizations_GUI,
      text				=	"XXXXXXXXX",
      x						=	CCX*.5,
      y						=	VCH*.4,
      font				= FONT_NORMAL,
      fontSize 		= VCW*.02,
      align       = "center"
    })

    ShipCustomizations_GUI.achat_msg.alpha = 0



    -- Ont met les choix de partie de vaisseau à personaliser
    -- Ont ajoute aussi un recctangle "sleection"
    ShipCustomizations_GUI.selection = display.newRect( ShipCustomizations_GUI, VCW * .11, VCH*.25, VCW*.15, VCH*.10 )
    ShipCustomizations_GUI.selection:setFillColor(0,0,0)
    ShipCustomizations_GUI.selection:setStrokeColor(1,1,1,0.4)
    ShipCustomizations_GUI.selection.strokeWidth = 1

    -- Ordre à partir de 1 par éléments du vaiseau
    -- On Commence par la base
    ShipCustomizations_GUI.base = widget.newButton({
  	        label 				= "Base",
  					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
  					font					= FONT_NORMAL_SECOND,
  					fontSize			= VCW*.015,
  	        onRelease 		= baseButtonReleased,
  	        shape 				= "rect",
  	        width 				= VCW*.15,
  	        height 				= VCH*.1,
  	        fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
  	        strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
  	        strokeWidth 	= 1,
  					emboss				= true,
  	    })

  	ShipCustomizations_GUI.base.x = VCW * .11
  	ShipCustomizations_GUI.base.y = VCH*.25
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.base)

    -- Puis l'arrière de vaisseau
    ShipCustomizations_GUI.back = widget.newButton({
            label 				= "Arriere",
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= VCW*.015,
            onRelease 		= backButtonReleased,
            shape 				= "rect",
            width 				= VCW*.15,
            height 				= VCH*.1,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipCustomizations_GUI.back.x = VCW * .265
    ShipCustomizations_GUI.back.y = VCH*.25
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.back)

    -- Puis les ailerons
    ShipCustomizations_GUI.ailerons = widget.newButton({
            label 				= "Ailerons",
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= VCW*.015,
            onRelease 		= aileronsButtonReleased,
            shape 				= "rect",
            width 				= VCW*.15,
            height 				= VCH*.1,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipCustomizations_GUI.ailerons.x = VCW * .42
    ShipCustomizations_GUI.ailerons.y = VCH*.25
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.ailerons)

    -- Puis le moteur
    ShipCustomizations_GUI.moteur = widget.newButton({
            label 				= "Moteur",
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= VCW*.015,
            onRelease 		= moteurButtonReleased,
            shape 				= "rect",
            width 				= VCW*.15,
            height 				= VCH*.1,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipCustomizations_GUI.moteur.x = VCW * .575
    ShipCustomizations_GUI.moteur.y = VCH*.25
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.moteur)

    -- Puis le canon
    ShipCustomizations_GUI.canon = widget.newButton({
            label 				= "Canon",
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= VCW*.015,
            onRelease 		= canonButtonReleased,
            shape 				= "rect",
            width 				= VCW*.15,
            height 				= VCH*.1,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipCustomizations_GUI.canon.x = VCW * .73
    ShipCustomizations_GUI.canon.y = VCH*.25
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.canon)

    -- Puis la couleur du laser
    ShipCustomizations_GUI.laserColor = widget.newButton({
            label 				= "Laser",
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= VCW*.015,
            onRelease 		= laserColorButtonReleased,
            shape 				= "rect",
            width 				= VCW*.15,
            height 				= VCH*.1,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipCustomizations_GUI.laserColor.x = VCW * .885
    ShipCustomizations_GUI.laserColor.y = VCH*.25
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.laserColor)

    -- Puis je mets en place les sliders de couleur pour la personalisation

    -- Slider pour la couleur rouge + Texte au dessus

    ShipCustomizations_GUI.redSlider = widget.newSlider({
      x = CCX*.25,
      y = VCH*.75,
      orientation = "vertical",
      height = VCH*.25,
      value = 0,
      listener = redSliderListener
    })
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.redSlider)

    ShipCustomizations_GUI.redSliderText = display.newEmbossedText({
        parent   = ShipCustomizations_GUI,
        text     = "R",
        x        = ShipCustomizations_GUI.redSlider.x,
        y        = ShipCustomizations_GUI.redSlider.y - VCH*.05,
        font     = FONT_NORMAL,
        fontSize = VCW * .025,
      })
    ShipCustomizations_GUI.redSliderText:setFillColor(1, 0, 0)

    -- Slider pour la couleur vert + Texte au dessus
    ShipCustomizations_GUI.greenSlider = widget.newSlider({
      x = CCX*.5,
      y = VCH*.75,
      orientation = "vertical",
      height = VCH*.25,
      value = 0,
      listener = greenSliderListener
    })
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.greenSlider)

    ShipCustomizations_GUI.greenSliderText = display.newEmbossedText({
        parent   = ShipCustomizations_GUI,
        text     = "V",
        x        = ShipCustomizations_GUI.greenSlider.x,
        y        = ShipCustomizations_GUI.greenSlider.y - VCH*.05,
        font     = FONT_NORMAL,
        fontSize = VCW * .025,
      })
    ShipCustomizations_GUI.greenSliderText:setFillColor(0, 1, 0)


    -- Slider pour la couleur bleu + Texte au dessus
    ShipCustomizations_GUI.blueSlider = widget.newSlider({
      x = CCX*.75,
      y = VCH*.75,
      orientation = "vertical",
      height = VCH*.25,
      value = 0,
      listener = blueSliderListener
    })
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.blueSlider)

    ShipCustomizations_GUI.blueSliderText = display.newEmbossedText({
        parent   = ShipCustomizations_GUI,
        text     = "B",
        x        = ShipCustomizations_GUI.blueSlider.x,
        y        = ShipCustomizations_GUI.blueSlider.y - VCH*.05,
        font     = FONT_NORMAL,
        fontSize = VCW * .025,
      })
    ShipCustomizations_GUI.blueSliderText:setFillColor(0, 0, 1)

    -- Je rajoute un apercu du vaisseau + Du laser
    ShipCustomizations_GUI.backShip     = display.newImageRect( ShipCustomizations_GUI, "ressources/images/shippart_back.png", VCW*0.3093, VCW*0.0789)
    ShipCustomizations_GUI.baseShip     = display.newImageRect( ShipCustomizations_GUI, "ressources/images/shippart_base.png", VCW*0.3093, VCW*0.0789)
    ShipCustomizations_GUI.aileronsShip = display.newImageRect( ShipCustomizations_GUI, "ressources/images/shippart_ailerons.png", VCW*0.3093, VCW*0.0789)
    ShipCustomizations_GUI.moteurShip   = display.newImageRect( ShipCustomizations_GUI, "ressources/images/shippart_moteur.png", VCW*0.3093, VCW*0.0789)
    ShipCustomizations_GUI.canonShip    = display.newImageRect( ShipCustomizations_GUI, "ressources/images/shippart_canon.png", VCW*0.3093, VCW*0.0789)
    ShipCustomizations_GUI.laserShip    = display.newRect(ShipCustomizations_GUI, CCX * 1.8, CCY * 1.35, VCW*0.04, VCH*.01 )

    -- Je fait le placement du vaisseau
    -- Le vaisseau étant plusieurs images de même taille
    -- j'ai simplement besoin de les superposer

    ShipCustomizations_GUI.backShip.x     = CCX * 1.6
    ShipCustomizations_GUI.baseShip.x     = CCX * 1.6
    ShipCustomizations_GUI.aileronsShip.x = CCX * 1.6
    ShipCustomizations_GUI.moteurShip.x   = CCX * 1.6
    ShipCustomizations_GUI.canonShip.x    = CCX * 1.6

    ShipCustomizations_GUI.backShip.y     = CCY * 1.2
    ShipCustomizations_GUI.baseShip.y     = CCY * 1.2
    ShipCustomizations_GUI.aileronsShip.y = CCY * 1.2
    ShipCustomizations_GUI.moteurShip.y   = CCY * 1.2
    ShipCustomizations_GUI.canonShip.y    = CCY * 1.2

    -- Je rajoute le bouton pour valider
    ShipCustomizations_GUI.validation = widget.newButton({
            label 				= "Valider",
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= VCW*.015,
            onRelease 		= validationButtonReleased,
            shape 				= "rect",
            width 				= VCW*.125,
            height 				= VCH*.089,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })
    ShipCustomizations_GUI.validation.x = VCW*.70
    ShipCustomizations_GUI.validation.y = VCH*.94
    ShipCustomizations_GUI:insert(ShipCustomizations_GUI.validation)

    ShipCustomizations_GUI:shipUpdateColor()
  end



  init()

  return ShipCustomizations_GUI

end

return CustomizeShip
