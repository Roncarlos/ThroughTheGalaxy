-----------------------------------------------------------------------------------------
--
-- Main Game
--
-----------------------------------------------------------------------------------------



local composer = require( "composer" )
composer.recycleOnSceneChange = true
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"

local GameManager = require "lib.engine.GameManager"


local gameManager
--------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()
	gameManager = GameManager:run()
	sceneGroup:insert(gameManager)




end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen

	elseif phase == "did" then
		physics.start()
		gameManager:start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view

	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	gameManager.endGameRecap.goBackButton:removeSelf()
	gameManager.endGameRecap.goBackButton = nil

	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
