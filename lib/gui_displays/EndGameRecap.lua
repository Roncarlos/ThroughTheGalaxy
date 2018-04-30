local widget = require "widget"
local composer = require "composer"
local PlayerData   = require "lib.dataControl.PlayerData"

local EndGameRecap = {}

--[[
La table params contient les paramètres du bouton:
score         : Score obtenu
difficulte    : palier de difficulté atteint
parent        : parent du racapitulatif
]]--
function EndGameRecap:new(params)

  local finalEndGameRecap = display.newGroup()
  local credits           = math.floor(params.score * (1+params.difficulte/2) * (1 + PLAYER_DATA.commander.creditsMultiplier/10)/10)
  local fontSize_normal   = VCW * .03

  if(params.parent) then
    params.parent:insert(finalEndGameRecap)
  end
  local textColor = params.color or {1,1,1}
  -- On défini le conteneur des informations
  finalEndGameRecap.buttonDisplay = display.newRect(finalEndGameRecap, CCX, CCY, VCW*.4, VCH*.6 )
  finalEndGameRecap.buttonDisplay:setFillColor(0, 0, 0, .4)
  finalEndGameRecap.buttonDisplay:setStrokeColor(.8, .8, .8, .8)
  finalEndGameRecap.buttonDisplay.strokeWidth = 1


  -- Titre de la fenêtre
  finalEndGameRecap.title = display.newEmbossedText({
    parent   = finalEndGameRecap,
    text     = "Résumé",
    x        = CCX,
    y        = VCH*.25,
    font     = FONT_NORMAL,
    fontSize = VCW * .032
  })
  finalEndGameRecap.title:setFillColor(1,1,0)


  -- -2 = Stroke du background
  finalEndGameRecap.lineTitle = display.newRect(finalEndGameRecap, CCX, VCH*.3, finalEndGameRecap.buttonDisplay.width-2, 1 )
  finalEndGameRecap.lineTitle:setFillColor(.8, .8, .8, .8)


  -- Crédits texte
  finalEndGameRecap.creditsText = display.newEmbossedText({
    parent   = finalEndGameRecap,
    text     = " Crédits :",
    x        = finalEndGameRecap.buttonDisplay.x*.75,
    y        = VCH*.35,
    font     = FONT_NORMAL,
    fontSize = fontSize_normal
  })
  finalEndGameRecap.creditsText:setFillColor(1,1,0)

  -- Crédits nombre
  finalEndGameRecap.credits = display.newEmbossedText({
    parent   = finalEndGameRecap,
    text     = credits .. " C",
    x        = finalEndGameRecap.creditsText.x * 1.70,
    y        = finalEndGameRecap.creditsText.y,
    font     = FONT_NORMAL,
    fontSize = fontSize_normal,
    align    = "right"
  })
  finalEndGameRecap.credits:setFillColor(1,1,0)

  finalEndGameRecap.lineCredits = display.newRect(finalEndGameRecap, CCX, finalEndGameRecap.credits.y*1.15, finalEndGameRecap.lineTitle.width, 1 )
  finalEndGameRecap.lineCredits:setFillColor(.8, .8, .8, .8)

  -- Palier de difficulté
  finalEndGameRecap.difficulteText = display.newEmbossedText({
    parent   = finalEndGameRecap,
    text     = " Palier :",
    x        = finalEndGameRecap.buttonDisplay.x*.75,
    y        = VCH*.45,
    font     = FONT_NORMAL,
    fontSize = fontSize_normal,
  })
  finalEndGameRecap.difficulteText:setFillColor(1,1,0)

  -- Palier
  finalEndGameRecap.difficulte = display.newEmbossedText({
    parent   = finalEndGameRecap,
    text     = params.difficulte + 1,
    x        = finalEndGameRecap.difficulteText.x * 1.70,
    y        = finalEndGameRecap.difficulteText.y,
    font     = FONT_NORMAL,
    fontSize = fontSize_normal,
    align    = "right"
  })
  finalEndGameRecap.difficulte:setFillColor(1,1,0)

  finalEndGameRecap.lineDifficulte = display.newRect(finalEndGameRecap, CCX, finalEndGameRecap.difficulte.y*1.10, finalEndGameRecap.lineTitle.width, 1 )
  finalEndGameRecap.lineDifficulte:setFillColor(.8, .8, .8, .8)


  -- Listener du bouton pour retourner au menu principal
  local function goBackButtonReleased( event )
  	if(SETTINGS.sounds) then
  		audio.play(audio.loadSound('ressources/sounds/click_2.wav'))
  	end
  	composer.gotoScene( "lib.scenes.main_menu")
  	return true
  end
  -- Bouton pour retourner au menu principal
  finalEndGameRecap.goBackButton = widget.newButton({
    label 				= "Retour au menu",
    labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
    font					= FONT_NORMAL,
    fontSize			= VCW*.03,
    onRelease 		= goBackButtonReleased,
    shape 				= "rect",
    width 				= VCW*.4,
    height 				= VCH*.15,
    fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
    strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
    strokeWidth 	= 1,
    emboss				= true,
  })

  finalEndGameRecap.goBackButton.x = finalEndGameRecap.lineDifficulte.x
  finalEndGameRecap.goBackButton.y = finalEndGameRecap.buttonDisplay.y * 1.45
  PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits + credits
  PlayerData:save()






  return finalEndGameRecap

end

return EndGameRecap
