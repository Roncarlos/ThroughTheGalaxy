-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
composer.recycleOnSceneChange = true
local Stars    = require 'lib.space.StellarLayer'
local scene = composer.newScene()
local Settings = require 'lib.dataControl.Settings'
local BuyShipUpdates = require "lib.gui_displays.BuyShipUpgrades"
local CustomizeShip = require "lib.gui_displays.CustomizeShip"

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
-- Variable pour mouvement des menus pour empecher le déplacement
-- Si le mouvement n'est pas fini
local isMoving = false

-- Main menu
local scenery = display.newGroup()
local buyUpdatesButton, customizeButton, backToMainMenuButton
local backHangarMenu
-- Upgrades for ship
local buyShipUpgrades_GUI
local customizeShip_GUI

local function movingFinished()
	isMoving = false
end


local function customizeButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	if(isMoving == false) then
		customizeShip_GUI:resetSliders()
		customizeShip_GUI:shipUpdateColor()
		customizeShip_GUI:updateCredits()
		isMoving = true
		transition.to( scenery, 						{time=500, x = VCW, onComplete=movingFinished})
		transition.to( customizeShip_GUI,   {time=500, x = 0})
	end
	return true
end



local function buyUpdatesButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	if(isMoving == false) then
		isMoving = true
		buyShipUpgrades_GUI:updateCredits()
		transition.to( scenery, 						{time=500, x = -VCW, onComplete=movingFinished})
		transition.to( buyShipUpgrades_GUI, {time=500, x = 0})
	end
	return true
end

local function backMenuUpgradesButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	if(isMoving == false) then
		isMoving = true
		transition.to( scenery, 						{time=500, x = 0, onComplete=movingFinished})
		transition.to( buyShipUpgrades_GUI, {time=500, x = VCW})
	end
	return true
end

local function backMenuCustomizeButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	if(isMoving == false) then
		isMoving = true
		transition.to( scenery, 					{time=500, x = 0, onComplete=movingFinished})
		transition.to( customizeShip_GUI, {time=500, x = -VCW})
	end
	return true
end

local function backToMainMenuButtonReleased()
	if(isMoving == false) then
		composer.gotoScene( "lib.scenes.main_menu", "fade", 500 )
	end
end


function scene:create( event )
	local sceneGroup = self.view
	-- Ajout d'un background gris pale
	scenery.background = display.newRect(sceneGroup, CCX, CCY, VCW*3, VCH )
	scenery.background:setFillColor(1,1,1, 0.2)

	-- Ajout du menu de droite avec les améliorations du vaisseau


	buyShipUpgrades_GUI = BuyShipUpdates:new({parent = sceneGroup})
	buyShipUpgrades_GUI.x = VCW
	-- Ajout du bouton de retour pour le menu de l'upgrade de vaisseau
	buyShipUpgrades_GUI.backMenu = widget.newButton({
					label 				= "Retour",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL_SECOND,
					fontSize			= VCW*.015,
					onRelease 		= backMenuUpgradesButtonReleased,
					shape 				= "rect",
					width 				= VCW*.2,
					height 				= VCH*.1,
					fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
					strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
					strokeWidth 	= 1,
					emboss				= true,
			})

	buyShipUpgrades_GUI.backMenu.x = CCX
	buyShipUpgrades_GUI.backMenu.y = VCH*.9
	buyShipUpgrades_GUI:insert(buyShipUpgrades_GUI.backMenu)


	-- Ajout du menu à gauche avec la personalisation du vaisseau
	customizeShip_GUI = CustomizeShip:new({parent=sceneGroup})
	customizeShip_GUI.x = -VCW

	-- Ajoute du bouton pour le retour vers le menu a partir de la Partie
	-- personalisation
	customizeShip_GUI.backMenuCustomize = widget.newButton({
					label 				= "Retour",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL_SECOND,
					fontSize			= VCW*.015,
					onRelease 		= backMenuCustomizeButtonReleased,
					shape 				= "rect",
					width 				= VCW*.125,
					height 				= VCH*.089,
					fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
					strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
					strokeWidth 	= 1,
					emboss				= true,
			})

	customizeShip_GUI.backMenuCustomize.x = VCW*.55
	customizeShip_GUI.backMenuCustomize.y = VCH*.94
	customizeShip_GUI:insert(customizeShip_GUI.backMenuCustomize)



	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	--[[local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY--]]

	-- Contour du texte

	scenery.title_stroke = display.newText({
		parent 			= scenery,
		text				= "Bienvenue au hangar",
		x						= CCX,
		y						=	VCH*.125,
		font				=	FONT_NORMAL,
		fontSize 		= VCW*.05,
	})

	scenery.title = display.newText({
		parent			= scenery,
    text				=	"Bienvenue au hangar",
    x						=	CCX,
    y						=	VCH*.12,
    font				= FONT_NORMAL,
    fontSize 		= VCW*.05,
  })

	scenery.title:setFillColor(1,1,0)
	scenery.title_stroke:setFillColor(1,0.5,0)

	-- MAIN MENU

	-- Bouton pour lancer le jeu ici


	buyUpdatesButton = widget.newButton({
	        label 				= "Acheter des améliorations",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
	        onRelease 		= buyUpdatesButtonReleased,
	        shape 				= "rect",
	        width 				= VCW*.6,
	        height 				= VCH*.2,
	        fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
	        strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
	        strokeWidth 	= 1,
					emboss				= true,
	    })

	buyUpdatesButton.x = CCX
	buyUpdatesButton.y = VCH*.4

	customizeButton = widget.newButton({
					label 				= "Personaliser le vaisseau",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
					onRelease 		= customizeButtonReleased,
					shape 				= "rect",
					width 				= VCW*.6,
					height 				= VCH*.2,
					fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
					strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
					strokeWidth 	= 1,
					emboss				= true,
			})

	customizeButton.x = CCX
	customizeButton.y = VCH*.6

	backToMainMenuButton = widget.newButton({
					label 				= "Retourner au menu principal",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
					onRelease 		= backToMainMenuButtonReleased,
					shape 				= "rect",
					width 				= VCW*.6,
					height 				= VCH*.2,
					fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
					strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
					strokeWidth 	= 1,
					emboss				= true,
			})

	backToMainMenuButton.x = CCX
	backToMainMenuButton.y = VCH*.8

	scenery:insert( buyUpdatesButton )
	scenery:insert( customizeButton )
	scenery:insert( backToMainMenuButton )

	sceneGroup:insert( scenery )
	--sceneGroup:insert( titleLogo )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen

	elseif phase == "did" then
		--composer.gotoScene( "lib.scenes.main_game")
		--composer.gotoScene( "lib.scenes.main_game")
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--composer.removeScene("lib.scenes.main_menu")
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	-- Called prior to the removal of scene's "view" (sceneGroup)
	--[[timer.cancel(scenery.halo.timer)
	buyUpdatesButton:removeSelf()
	marketButton:removeSelf()
	settingsButton:removeSelf()

	buyUpdatesButton 			= nil
	marketButton 		= nil
	settingsButton 	= nil

	soundButton:removeSelf()
	musicButton:removeSelf()
	backButton:removeSelf()

	soundButton 	= nil
	musicButton 	= nil
	backButton 		= nil--]]

	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
