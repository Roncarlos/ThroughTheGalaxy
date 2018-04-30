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

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local scenery = display.newGroup()
-- Main menu
local playButton,hangarButton,settingsButton

-- Settings menu
local soundButton, musicButton, backButton


local function playButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	composer.gotoScene( "lib.scenes.main_game", "fade", 500)
	return true
end

local function hangarButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	composer.gotoScene( "lib.scenes.hangar_menu", "fade", 500)
	return true
end

local function soundButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
		SETTINGS.sounds = false
		event.target:setLabel("Sons : Désactivés")
	else
		SETTINGS.sounds = true
		event.target:setLabel("Sons : Activés")
	end

	Settings:save()

	return true
end

local function musicButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end

	if(SETTINGS.music) then
		SETTINGS.music = false
		event.target:setLabel("Musique : Désactivée")
	else
		SETTINGS.music = true
		event.target:setLabel("Musique : Activée")
	end

	Settings:save()

	return true
end


-- Menu déplacement
-- Vers le menu des options
local function settingsButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	-- Déplacement du menu hors de l'écran
	transition.to( playButton, {time=1000, x = -CCX})
	transition.to( hangarButton, {time=1000, x = -CCX})
	transition.to( settingsButton, {time=1000, x = -CCX})

	-- Déplacement du menu des options dans l'écran
	transition.to( soundButton, {time=1000, x = CCX})
	transition.to( musicButton, {time=1000, x = CCX})
	transition.to( backButton, {time=1000, x = CCX})

	return true
end

-- Vers le menu principal
local function backButtonReleased( event )
	if(SETTINGS.sounds) then
		audio.play(MENU_CLICK)
	end
	-- Déplacement du menu hors de l'écran
	transition.to( playButton, {time=1000, x = CCX})
	transition.to( hangarButton, {time=1000, x = CCX})
	transition.to( settingsButton, {time=1000, x = CCX})

	-- Déplacement du menu des options dans l'écran
	transition.to( soundButton, {time=1000, x = VCW*1.5})
	transition.to( musicButton, {time=1000, x = VCW*1.5})
	transition.to( backButton, {time=1000, x = VCW*1.5})
	return true
end


function scene:create( event )
	local sceneGroup = self.view

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


	scenery.distantStars 					= Stars:new{parent=scenery, stars=300, floor=VCH, speed=.025, night=true}
	scenery.planet			 					= display.newImageRect( scenery, "ressources/images/planet.png", VCW*1.5, VCH)
	scenery.planet.x 							= VCW * .5
	scenery.planet.y 							= VCH
	scenery.halo					 				= display.newImageRect(	scenery, "ressources/images/halo.png", VCW, VCW)
	scenery.halo.x 								= VCW * .5
	scenery.halo.y 								= VCH * 0.62
	scenery.halo.basicWidth 			= scenery.halo.width
	scenery.halo.basicHeight 			= scenery.halo.height


	function scenery.halo:blink()
    if(scenery.halo.alpha < 1) then
        transition.to( scenery.halo, {time=5000, alpha=1, width=scenery.halo.basicWidth, height=scenery.halo.basicHeight })
    else
        transition.to( scenery.halo, {time=5000, alpha=0.8, width=scenery.halo.basicWidth*.75, height=scenery.halo.basicWidth*.75})
    end
	end

	scenery.halo.timer = timer.performWithDelay( 5000, scenery.halo.blink, -1 )
	timer.pause(scenery.halo.timer)

	-- Contour du texte

	scenery.title_stroke = display.newText({
		parent 			= scenery,
		text				= "Through The Galaxy",
		x						= CCX,
		y						=	VCH*.125,
		font				=	FONT_NORMAL,
		fontSize 		= VCW*.05,
	})

	scenery.title = display.newText({
		parent			= scenery,
    text				=	"Through The Galaxy",
    x						=	CCX,
    y						=	VCH*.12,
    font				= FONT_NORMAL,
    fontSize 		= VCW*.05,
  })

	scenery.title:setFillColor(1,1,0)
	scenery.title_stroke:setFillColor(1,0.5,0)

	-- MAIN MENU

	-- Bouton pour lancer le jeu ici


	playButton = widget.newButton({
	        label 				= "Commencer",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.030,
	        onRelease 		= playButtonReleased,
	        shape 				= "rect",
	        width 				= VCW*.30,
	        height 				= VCH*.2,
	        fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
	        strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
	        strokeWidth 	= 1,
					emboss				= true,
	    })

	playButton.x = CCX
	playButton.y = VCH*.4

	-- Bouton pour aller acheter des items ici
	hangarButton = widget.newButton({
	        label 				= "Hangar",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
	        onRelease 		= hangarButtonReleased,
	        shape 				= "rect",
	        width 				= VCW*.3,
	        height 				= VCH*.2,
	        fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
	        strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
	        strokeWidth 	= 1,
					emboss				= true,
	    })
	hangarButton.x = CCX
	hangarButton.y = VCH*.6

	-- Bouton des options

	settingsButton = widget.newButton({
					label 				= "Options",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
					onRelease 		= settingsButtonReleased,
					shape 				= "rect",
					width 				= VCW*.3,
					height 				= VCH*.2,
					fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
					strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
					strokeWidth 	= 1,
					emboss				= true,
			})
	settingsButton.x = CCX
	settingsButton.y = VCH*.8

	-- SETTINGS MENU

	soundButton = widget.newButton({
	        label 				= "",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
	        onRelease 		= soundButtonReleased,
	        shape 				= "rect",
	        width 				= CCX,
	        height 				= VCH*.25,
	        fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
	        strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
	        strokeWidth 	= 1,
					emboss				= true,
	    })

	soundButton.x = VCW*1.5
	soundButton.y = VCH*.45
	if(SETTINGS.sounds) then
		soundButton:setLabel("Sons : Activés")
	else
		soundButton:setLabel("Sons : Désactivés")
	end

	musicButton = widget.newButton({
					label 				= "",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
					onRelease 		= musicButtonReleased,
					shape 				= "rect",
					width 				= CCX,
					height 				= VCH*.25,
					fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
					strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
					strokeWidth 	= 1,
					emboss				= true,
			})

	musicButton.x = VCW*1.5
	musicButton.y = VCH*.70

	if(SETTINGS.music) then
		musicButton:setLabel("Musique : Activée")
	else
		musicButton:setLabel("Musique : Désactivée")
	end

	backButton = widget.newButton({
					label 				= "Retour",
					labelColor		= { default={1, 1, 0, 1}, over={0,0,0,.8} },
					font					= FONT_NORMAL,
					fontSize			= VCW*.03,
					onRelease 		= backButtonReleased,
					shape 				= "rect",
					width 				= VCW*.15,
					height 				= VCH*.08,
					fillColor 		= { default={0, 0, 0, .4}, over={0,0,0,.8} },
					strokeColor 	= { default={.8,.8,.8, .4}, over={0.8,0.8,1,1} },
					strokeWidth 	= 1,
					emboss				= true,
			})

	backButton.x = VCW*1.5
	backButton.y = VCH*.25

	scenery:insert(settingsButton)
	scenery:insert(playButton)
	scenery:insert(hangarButton)
	sceneGroup:insert( scenery )
	--sceneGroup:insert( titleLogo )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		timer.resume(scenery.halo.timer)
		scenery.distantStars:start()

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
		timer.pause(scenery.halo.timer)
		scenery.distantStars:stop()
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
	timer.cancel(scenery.halo.timer)
	playButton:removeSelf()
	hangarButton:removeSelf()
	settingsButton:removeSelf()

	playButton 			= nil
	hangarButton 		= nil
	settingsButton 	= nil

	soundButton:removeSelf()
	musicButton:removeSelf()
	backButton:removeSelf()

	soundButton 	= nil
	musicButton 	= nil
	backButton 		= nil

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
