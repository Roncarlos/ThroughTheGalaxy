local widget = require "widget"
local composer = require "composer"
local PlayerData   = require "lib.dataControl.PlayerData"

local BuyShipUpgrades = {}

--[[
La table params contient les paramètres du bouton:
parent        : parent du racapitulatif
]]--
function BuyShipUpgrades:new(params)

  local ShipUpgrades_GUI = display.newGroup()
  local credits          = PLAYER_DATA.commander.credits
  local upgradeFontSize  = VCW * .016

  if(params.parent) then
    params.parent:insert(ShipUpgrades_GUI)
  end

  local laserPrice    = math.floor(200 * (1 + PLAYER_DATA.ship.laserSpeedLevel/2))
  local bombPrice     = math.floor(200 * (1 + PLAYER_DATA.ship.bombSpeedLevel/2))
  local ammoMaxPrice  = math.floor(25 * (1 + PLAYER_DATA.ship.ammoMaxLevel/4))
  local armorPrice    = math.floor(25 * (1 + PLAYER_DATA.ship.armorLevel/4))
  local drivePrice    = math.floor(100 * (1 + PLAYER_DATA.ship.driveLevel/2))
  local fuelTankPrice = math.floor(50 * (1 + PLAYER_DATA.ship.fuelTankLevel/2))

  -- Fonction pour update credits
  function ShipUpgrades_GUI:updateCredits()
    credits                       = PLAYER_DATA.commander.credits
    ShipUpgrades_GUI.credits.text = credits
  end

  function init()
    -- Titre du menu
    ShipUpgrades_GUI.title_stroke = display.newText({
  		parent 			= ShipUpgrades_GUI,
  		text				= "Touchez une partie pour l'améliorer",
  		x						= CCX,
  		y						=	VCH*.105,
  		font				=	FONT_NORMAL,
  		fontSize 		= VCW*.04,
  	})

  	ShipUpgrades_GUI.title = display.newText({
  		parent			= ShipUpgrades_GUI,
      text				=	"Touchez une partie pour l'améliorer",
      x						=	CCX,
      y						=	VCH*.1,
      font				= FONT_NORMAL,
      fontSize 		= VCW*.04,
    })

    ShipUpgrades_GUI.title:setFillColor(1,1,0)
    ShipUpgrades_GUI.title_stroke:setFillColor(1,0.5,0)

    -- Nombres de crédits
    ShipUpgrades_GUI.creditsBG = display.newRect(ShipUpgrades_GUI, ShipUpgrades_GUI.title.x, VCH*.25, VCW*.4, VCH*.09 )
    ShipUpgrades_GUI.creditsBG:setFillColor(0, 0, 0, .4)
    ShipUpgrades_GUI.creditsBG:setStrokeColor(.8, .8, .8, .4)
    ShipUpgrades_GUI.creditsBG.strokeWidth = 1
    ShipUpgrades_GUI.credits   = display.newEmbossedText({
        parent   = ShipUpgrades_GUI,
        text     = credits,
        x        = CCX,
        y        = VCH*.25,
        font     = FONT_DIGITAL,
        fontSize = VCW * .05,
        align    = "right",
        width    = VCW*.35,
        height   = VCH*.09,
      })
    ShipUpgrades_GUI.credits:setFillColor(1, 1, 0)

    --Toutes les parties améliorables
    -- Partie Gauche
    -- Lasers
    ShipUpgrades_GUI.laserAS = widget.newButton({
  	        label 				= "Lasers\n\nPrix : " .. laserPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.laserSpeedLevel,
  					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
  					font					= FONT_NORMAL_SECOND,
  					fontSize			= upgradeFontSize,
  	        onRelease 		= laserASButtonReleased,
  	        shape 				= "rect",
  	        width 				= VCW*.2,
  	        height 				= VCH*.2,
  	        fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
  	        strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
  	        strokeWidth 	= 1,
  					emboss				= true,
  	    })

  	ShipUpgrades_GUI.laserAS.x = CCX * .25
  	ShipUpgrades_GUI.laserAS.y = VCH*.4
    ShipUpgrades_GUI:insert(ShipUpgrades_GUI.laserAS)

    -- Bombes
    ShipUpgrades_GUI.bombAS = widget.newButton({
            label 				= "Bombes\n\nPrix : " .. bombPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.bombSpeedLevel,
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= upgradeFontSize,
            onRelease 		= bombASButtonReleased,
            shape 				= "rect",
            width 				= VCW*.2,
            height 				= VCH*.2,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipUpgrades_GUI.bombAS.x = CCX * .25
    ShipUpgrades_GUI.bombAS.y = VCH*.6
    ShipUpgrades_GUI:insert(ShipUpgrades_GUI.bombAS)

    -- Ammo Max
    ShipUpgrades_GUI.ammoMax = widget.newButton({
            label 				= "Munitions\n\nPrix : " .. ammoMaxPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.ammoMaxLevel,
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= upgradeFontSize,
            onRelease 		= ammoMaxButtonReleased,
            shape 				= "rect",
            width 				= VCW*.2,
            height 				= VCH*.2,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipUpgrades_GUI.ammoMax.x = CCX * .25
    ShipUpgrades_GUI.ammoMax.y = VCH*.8
    ShipUpgrades_GUI:insert(ShipUpgrades_GUI.ammoMax)

    -- Partie Droite
    -- Armure
    ShipUpgrades_GUI.armor = widget.newButton({
            label 				= "Armure\n\nPrix : " .. armorPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.armorLevel,
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= upgradeFontSize,
            onRelease 		= armorButtonReleased,
            shape 				= "rect",
            width 				= VCW*.2,
            height 				= VCH*.2,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipUpgrades_GUI.armor.x = CCX * 1.75
    ShipUpgrades_GUI.armor.y = VCH*.4
    ShipUpgrades_GUI:insert(ShipUpgrades_GUI.armor)

    -- Drive
    ShipUpgrades_GUI.drive = widget.newButton({
            label 				= "Moteur\n\nPrix : " .. drivePrice .. "\n\nLevel : " .. PLAYER_DATA.ship.driveLevel,
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= upgradeFontSize,
            onRelease 		= driveButtonReleased,
            shape 				= "rect",
            width 				= VCW*.2,
            height 				= VCH*.2,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipUpgrades_GUI.drive.x = CCX * 1.75
    ShipUpgrades_GUI.drive.y = VCH*.6
    ShipUpgrades_GUI:insert(ShipUpgrades_GUI.drive)

    -- Fuel Tank
    ShipUpgrades_GUI.fuelTank = widget.newButton({
            label 				= "Essence\n\nPrix : " .. fuelTankPrice .."\n\nLevel : " .. PLAYER_DATA.ship.fuelTankLevel,
            labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
            font					= FONT_NORMAL_SECOND,
            fontSize			= upgradeFontSize,
            onRelease 		= fuelTankButtonReleased,
            shape 				= "rect",
            width 				= VCW*.2,
            height 				= VCH*.2,
            fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
            strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
            strokeWidth 	= 1,
            emboss				= true,
        })

    ShipUpgrades_GUI.fuelTank.x = CCX * 1.75
    ShipUpgrades_GUI.fuelTank.y = VCH*.8
    ShipUpgrades_GUI:insert(ShipUpgrades_GUI.fuelTank)



  end

  -- Les événements pour chacuns des boutons

  -- Bouton pour les lasers
  function laserASButtonReleased()
    if(SETTINGS.sounds) then
      audio.play(MENU_CLICK)
    end
    if(PLAYER_DATA.commander.credits >= laserPrice) then
      PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits - laserPrice
      PLAYER_DATA.ship.laserSpeedLevel = PLAYER_DATA.ship.laserSpeedLevel + 1
      ShipUpgrades_GUI.credits.text = PLAYER_DATA.commander.credits
    end
    PlayerData:save()
    laserPrice    = math.floor(200 * (1 + PLAYER_DATA.ship.laserSpeedLevel/2))
    ShipUpgrades_GUI.laserAS:setLabel("Lasers\n\nPrix : " .. laserPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.laserSpeedLevel)
  end

  -- Bouton pour les bombes
  function bombASButtonReleased()
    if(SETTINGS.sounds) then
      audio.play(MENU_CLICK)
    end
    if(PLAYER_DATA.commander.credits >= bombPrice) then
      PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits - bombPrice
      PLAYER_DATA.ship.bombSpeedLevel = PLAYER_DATA.ship.bombSpeedLevel + 1
      ShipUpgrades_GUI.credits.text = PLAYER_DATA.commander.credits
    end
    PlayerData:save()
    bombPrice     = math.floor(200 * (1 + PLAYER_DATA.ship.bombSpeedLevel/2))
    ShipUpgrades_GUI.bombAS:setLabel("Bombes\n\nPrix : " .. bombPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.bombSpeedLevel)
  end

  -- Bouton pour les munitions
  function ammoMaxButtonReleased()
    if(SETTINGS.sounds) then
      audio.play(MENU_CLICK)
    end
    if(PLAYER_DATA.commander.credits >= ammoMaxPrice) then
      PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits - ammoMaxPrice
      PLAYER_DATA.ship.ammoMaxLevel = PLAYER_DATA.ship.ammoMaxLevel + 1
      ShipUpgrades_GUI.credits.text = PLAYER_DATA.commander.credits
    end
    PlayerData:save()
    ammoMaxPrice  = math.floor(25 * (1 + PLAYER_DATA.ship.ammoMaxLevel/4))
    ShipUpgrades_GUI.ammoMax:setLabel("Munitions\n\nPrix : " .. ammoMaxPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.ammoMaxLevel)
  end

  -- Bouton pour l'armure
  function armorButtonReleased()
    if(SETTINGS.sounds) then
      audio.play(MENU_CLICK)
    end
    if(PLAYER_DATA.commander.credits >= armorPrice) then
      PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits - armorPrice
      PLAYER_DATA.ship.armorLevel = PLAYER_DATA.ship.armorLevel + 1
      ShipUpgrades_GUI.credits.text = PLAYER_DATA.commander.credits
    end
    PlayerData:save()
    armorPrice = math.floor(25 * (1 + PLAYER_DATA.ship.armorLevel/2))
    ShipUpgrades_GUI.armor:setLabel("Armure\n\nPrix : " .. armorPrice .. "\n\nLevel : " .. PLAYER_DATA.ship.armorLevel)
  end

  -- Bouton pour le moteur
  function driveButtonReleased()
    if(SETTINGS.sounds) then
      audio.play(MENU_CLICK)
    end
    if(PLAYER_DATA.commander.credits >= drivePrice) then
      PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits - drivePrice
      PLAYER_DATA.ship.driveLevel = PLAYER_DATA.ship.driveLevel + 1
      ShipUpgrades_GUI.credits.text = PLAYER_DATA.commander.credits
    end
    PlayerData:save()
    drivePrice = math.floor(100 * (1 + PLAYER_DATA.ship.driveLevel/2))
    ShipUpgrades_GUI.drive:setLabel("Moteur\n\nPrix : " .. drivePrice .. "\n\nLevel : " .. PLAYER_DATA.ship.driveLevel)
  end


  -- Bouton pour le fuel tank
  function fuelTankButtonReleased()
    if(SETTINGS.sounds) then
      audio.play(MENU_CLICK)
    end
    if(PLAYER_DATA.commander.credits >= fuelTankPrice) then
      PLAYER_DATA.commander.credits = PLAYER_DATA.commander.credits - fuelTankPrice
      PLAYER_DATA.ship.fuelTankLevel = PLAYER_DATA.ship.fuelTankLevel + 1
      ShipUpgrades_GUI.credits.text = PLAYER_DATA.commander.credits
    end
    PlayerData:save()
    fuelTankPrice = math.floor(50 * (1 + PLAYER_DATA.ship.fuelTankLevel/2))
    ShipUpgrades_GUI.fuelTank:setLabel("Essence\n\nPrix : " .. fuelTankPrice .."\n\nLevel : " .. PLAYER_DATA.ship.fuelTankLevel)
  end







  init()
  return ShipUpgrades_GUI

end

return BuyShipUpgrades
