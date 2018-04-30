local loadsave = require "lib.extLib.loadsave"
local PlayerData = {}
local crypto = require( "crypto" )

function PlayerData:TableToString(playerData)
  local str = ""
  --[[for key,value in pairs(playerData) do --pseudocode
    if(type(playerData[key]) == "table") then
      str = str .. PlayerData:TableToString(playerData[key])
    else
      if(key ~= "key") then
        str = str .. tostring( value )
      end
    end
  end--]]

  -- J'ai du au final faire comme ça, puisque l'odre
  -- N'était pas le même avec la fonction précédente
  -- Et ainsi ça ne marchait pas comme je le voulais
  -- On commence par le commandant
  str = str .. playerData.commander.name .. tostring(playerData.commander.nameSelected) ..
  tostring(playerData.commander.tutorialDone) .. playerData.commander.credits ..
  playerData.commander.creditsMultiplier

  -- Puis les informations du vaisseau
  str = str .. playerData.ship.armorLevel .. playerData.ship.laserLevel ..
  playerData.ship.laserSpeedLevel .. playerData.ship.bombLevel ..
  playerData.ship.bombSpeedLevel .. playerData.ship.fuelTankLevel ..
  playerData.ship.driveLevel .. playerData.ship.ammoMaxLevel

  -- Puis les informations sur le sfx (couleurs armes + vaisseau)
  str = str .. table.concat(playerData.sfx.laserColor) .. table.concat(playerData.sfx.shipBackColor) ..
  table.concat(playerData.sfx.shipAileronsColor) .. table.concat(playerData.sfx.shipBaseColor) ..
  table.concat(playerData.sfx.shipCanonColor) .. table.concat(playerData.sfx.shipMoteurColor)

  return str
end


function PlayerData:load()
  local playerData = loadsave.loadTable("_playerData.json", system.DocumentsDirectory)

  if(playerData == nil) then
    PlayerData:new()
    PlayerData:load()
  else
    if(PlayerData:verify(playerData)) then
      -- Si les données sont bonnes ont les enregistrent dans une variable globale
      PLAYER_DATA = playerData
    else
      PlayerData:new()
      PlayerData:load()
    end
  end

end

function PlayerData:save()
  local key = PlayerData:TableToString(PLAYER_DATA)
  key = "MoN" .. key .. "daY"
  local hash = crypto.digest( crypto.md5, key )
  PLAYER_DATA.commander.key = hash
  loadsave.saveTable(PLAYER_DATA, "_playerData.json", system.DocumentsDirectory)
end

function PlayerData:new(params)
  local playerData = {
    commander = {
      name               = "",
      nameSelected       = false,
      tutorialDone       = false,
      credits            = 0,
      creditsMultiplier  = 0,
      key                = ""
    },


    -- Chaque niveau augmente de 10% l'efficacité de base de chacun des attributs
    -- Vitesse d'attaque est en fait la vitesse entre chaque tirs
    -- armorLevel       -> HP du vaisseau
    -- laserLevel       -> dégats des lasers NOT IMPLEMENTED YET
    -- laserSpeedLevel  -> vitesse d'attaque des lasers
    -- bombLevel        -> dégats des bombes NOT IMPLEMENTED YET
    -- bombSpeedLevel   -> vitesse d'attaque des bombes
    -- fuelTankLevel    -> maximum de fuel
    -- driveLevel-      -> maniabilité du vaisseau
    -- ammoMaxLevel     -> munitions maximum
    ship = {
      armorLevel      = 0,
      laserLevel      = 0,
      laserSpeedLevel = 0,
      bombLevel       = 0,
      bombSpeedLevel  = 0,
      fuelTankLevel   = 0,
      driveLevel      = 0,
      ammoMaxLevel    = 0,
    },

    sfx = {
      laserColor           = {0,1,0},
      shipBackColor        = {1,1,1},
      shipBaseColor        = {1,1,1},
      shipAileronsColor    = {1,1,1},
      shipMoteurColor      = {1,1,1},
      shipCanonColor       = {1,1,1},
    },

    highScores = {},

    version = "1.0.0",


  }

  -- On créer une clé pour les données de base
  local key = PlayerData:TableToString(playerData)
  key = "MoN" .. key .. "daY"
  local hash = crypto.digest( crypto.md5, key )
  playerData.commander.key = hash

  loadsave.saveTable(playerData, "_playerData.json", system.DocumentsDirectory)
end

function PlayerData:verify(playerData)

  -- Vérifcation des données, pour voir s'il n'y a pas eu de mofications...
  -- Dans un premier lieu les informations du commandant
  if(type(playerData.commander.name) ~= "string") then return false end
  if(type(playerData.commander.nameSelected) ~= "boolean") then return false end
  if(type(playerData.commander.tutorialDone) ~= "boolean") then return false end
  if(type(playerData.commander.credits) ~= "number") then return false end
  if(type(playerData.commander.creditsMultiplier) ~= "number") then return false end


  -- Puis les informations du vaisseau
  if(type(playerData.ship.armorLevel) ~= "number") then return false end
  if(type(playerData.ship.laserLevel) ~= "number") then return false end
  if(type(playerData.ship.laserSpeedLevel) ~= "number") then return false end
  if(type(playerData.ship.bombLevel) ~= "number") then return false end
  if(type(playerData.ship.bombSpeedLevel) ~= "number") then return false end
  if(type(playerData.ship.fuelTankLevel) ~= "number") then return false end
  if(type(playerData.ship.driveLevel) ~= "number") then return false end
  if(type(playerData.ship.ammoMaxLevel) ~= "number") then return false end

  -- Puis les informations sur le sfx (couleurs armes + vaisseau)
  if(type(playerData.sfx.laserColor) ~= "table") then return false end
  if(type(playerData.sfx.shipBackColor) ~= "table") then return false end
  if(type(playerData.sfx.shipAileronsColor) ~= "table") then return false end
  if(type(playerData.sfx.shipBaseColor) ~= "table") then return false end
  if(type(playerData.sfx.shipCanonColor) ~= "table") then return false end
  if(type(playerData.sfx.shipMoteurColor) ~= "table") then return false end

  -- Puis pour les scores
  if(type(playerData.highScores) ~= "table") then return false end

  -- Puis on vérifie la clé
  local key = PlayerData:TableToString(playerData)
  key = "MoN" .. key .. "daY"
  local hash = crypto.digest( crypto.md5, key )
  if(playerData.commander.key ~= hash) then return false end

  return true
end

return PlayerData
