--
-- Point d'entrée de l'application
--

-- définition des variables métriques globales

VCW = display.viewableContentWidth
VCH = display.viewableContentHeight
CCX = display.contentCenterX
CCY = display.contentCenterY
SOX = display.screenOriginX
SOY = display.screenOriginY
CW = display.contentWidth
CH = display.contentHeight
ACW = display.actualContentWidth
ACH = display.actualContentHeight

local SETTINGS    = {}
local PLAYER_DATA = {}
MENU_CLICK        = audio.loadSound('ressources/sounds/click_2.wav')

FONT_DIGITAL        = "digital-7.ttf"
FONT_NORMAL         = "distant_galaxy_2.ttf"
FONT_NORMAL_SECOND  = "SM.ttf"

DEBUG = false

-- fait disparaître la barre de statut
display.setStatusBar(display.HiddenStatusBar)
local fps          = require "lib.extLib.fps"
local Settings     = require "lib.dataControl.Settings"
local PlayerData   = require "lib.dataControl.PlayerData"
local composer     = require "composer"
require 'lib.extLib.extFunc'





local physics = require "physics"
physics.start()
if(DEBUG) then
  physics.setDrawMode( "hybrid" )
  fps:show()
end


Settings:load()
PlayerData:load()


-- load menu screen
composer.gotoScene( "lib.scenes.main_menu", "fade", 1000)
--composer.gotoScene( "lib.scenes.main_game" )
--composer.gotoScene( "lib.scenes.hangar_menu" )
