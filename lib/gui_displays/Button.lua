local widget = require "widget"

local Button = {}

--[[
La table params contient les paramètres du bouton:
height          = hauteur du bouton
width           = largeur du bouton
x               = position x du bouton
y               = position y du bouton
color           = couleur du texte
strokeColor     = couleur d'arrière plan du texte
fontSize        = taille de la police
font            = police utilisé
text            = texte à afficher

]]--
function Button:new(params)
  local finalButton = display.newGroup()


  function init()
    if(params.parent) then
      params.parent:insert(finalButton)
    end
    local textColor = params.color or {1,1,1}
    -- On défini le bouton en lui même (aka le conteneur du texte)
    finalButton.buttonDisplay = display.newRect(finalButton, params.x, params.y, params.width, params.height )
    finalButton.buttonDisplay:setFillColor(0,0,0)
    finalButton.buttonDisplay.alpha = 0.4
    finalButton.buttonDisplay:setStrokeColor(.8,.8,.8)
    finalButton.buttonDisplay.strokeWidth = 1


    if(params.strokeColor) then
       finalButton.button_stroke = display.newText({
           parent   = finalButton,
           text     = params.text,
           font     = params.font or "distant_galaxy_2.ttf",
           fontSize = params.fontSize + 0.3 or VCW*.025 + 0.3,
       })
       finalButton.button_stroke:setFillColor(unpack(params.strokeColor))
       finalButton.button_stroke.x = finalButton.buttonDisplay.x
       finalButton.button_stroke.y = finalButton.buttonDisplay.y
     end


    if(params.nextScene) then
      finalButton.button_text = widget.newButton(
        {
          label = "button",
          onEvent = handleButtonEvent
        }
      )
    else
      finalButton.button_text = display.newText({
        parent   = finalButton,
        text     = params.text,
        font     = params.font or "distant_galaxy_2.ttf",
      })
      finalButton.button_text:setFillColor(unpack(textColor))
    end
    finalButton.button_text.x = finalButton.buttonDisplay.x
    finalButton.button_text.y = finalButton.buttonDisplay.y
  end

  -- Son si défini
  function finalButton:sound()
    if (params.sound) then
      audio.play(params.sound)
    end
  end



  init()


  return finalButton

end

return Button
