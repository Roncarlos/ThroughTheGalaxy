local Fps = {}

function Fps:show()
  local prevTime = 0
  local curTime = 0
  local dt = 0
  local fps = 50
  local mem = 0

  local displayInfo = display.newText("FPS: " .. fps .. " - Memory: ".. mem .. "mb", 120, 20, native.systemFontBold, 16)

  local function updateText()
    curTime = system.getTimer()
    dt = curTime - prevTime
    prevTime = curTime
    fps = math.floor(1000 / dt)
    mem = system.getInfo("textureMemoryUsed") / 1000000

    --Limit fps range to avoid the "fake" reports
    if fps > display.fps then
      fps = display.fps
    end

    displayInfo.text = "FPS: " .. fps .. " - Memory: ".. string.sub(mem, 1, string.len(mem) - 4) .. "mb"
    displayInfo:toFront()
  end

  Runtime:addEventListener("enterFrame", updateText)
end



return Fps
