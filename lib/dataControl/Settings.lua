local loadsave = require "lib.extLib.loadsave"
local Settings = {}


function Settings:load()
  local settings = loadsave.loadTable("_playerSettings.json", system.DocumentsDirectory)

  if(settings == nil) then
    Settings:new()
    Settings:load()
  else
    if(Settings:verify(settings)) then
      -- Si les données sont bonnes ont les enregistrent dans une variable globale
      SETTINGS = settings
    else
      -- Créer puis load peut être dangereux si j'ai mal codé l'application
      -- Mais je code "bien"... :p
      Settings:new()
      Settings:load()
    end
  end

end

function Settings:new()
  local settings = {
    sounds   = true,
    music    = true,
    language = "english"
  }
  loadsave.saveTable(settings, "_playerSettings.json", system.DocumentsDirectory)
end

function Settings:save()
  loadsave.saveTable(SETTINGS, "_playerSettings.json", system.DocumentsDirectory)
end

function Settings:verify(settings)

  -- Vérifcation des données, pour voir s'il n'y a pas eu de mofications...
  if(type(settings.sounds) ~= "boolean") then return false end
  if(type(settings.music) ~= "boolean") then return false end
  if(type(settings.language) ~= "string") then return false end


  return true
end

return Settings
