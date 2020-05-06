import "CoreLibs/utilities/printer"

dialogueMethods = {}

function dialogueMethods.getStorylineName()
  return game.playthroughData.storylines[game.playthrough.storyline.name].label
end

function dialogueMethods.lastExitWas(exitId)
  return game.playthrough.storyline.exits[#game.playthrough.storyline.exits].id == exitId
end

function dialogueMethods.failExit()
  printT(game.playthrough)
  local exitScore = game.playthrough.storyline.exits[#game.playthrough.storyline.exits].score
  return exitScore < 3
end

function dialogueMethods.normalExit()
  printT(game.playthrough)
  local exitScore = game.playthrough.storyline.exits[#game.playthrough.storyline.exits].score
  return exitScore == 3
end

function dialogueMethods.specialExit()
  local exitScore = game.playthrough.storyline.exits[#game.playthrough.storyline.exits].score
  return exitScore > 3
end

function dialogueMethods.failPlaythrough()
  return game:getPlaythroughResult() == "fail"
end

function dialogueMethods.normalPlaythrough()
  return game:getPlaythroughResult() == "normal"
end

function dialogueMethods.specialPlaythrough()
  return game:getPlaythroughResult() == "special"
end

function dialogueMethods.finishedStoryline(storylineName)
  return game:finishedStoryline(storylineName)
end

function dialogueMethods.finishedStorylineWithResult(storylineName, result)
  return game:finishedStorylineWithResult(storylineName, result)
end

function dialogueMethods.failResult()
  return game:getStorylineResult() == "fail"
end

function dialogueMethods.normalResult()
  return game:getStorylineResult() == "normal"
end

function dialogueMethods.specialResult()
  return game:getStorylineResult() == "special"
end

function dialogueMethods.failResultInPreviousStoryline(storylineName)
  for _, storyline in ipairs(game.playthrough.finishedStorylines) do
    if storyline.name == storylineName then
      return storyline.result == "fail"
    end
  end
  print("Could not find data for previous storyline " .. storyline)
  return false
end

function dialogueMethods.normalResultInPreviousStoryline(storylineName)
  for _, storyline in ipairs(game.playthrough.finishedStorylines) do
    if storyline.name == storylineName then
      return storyline.result == "normal"
    end
  end
  print("Could not find data for previous storyline " .. storyline)
  return false
end

function dialogueMethods.specialResultInPreviousStoryline(storylineName)
  for _, storyline in ipairs(game.playthrough.finishedStorylines) do
    if storyline.name == storylineName then
      return storyline.result == "special"
    end
  end
  print("Could not find data for previous storyline " .. storyline)
  return false
end

function dialogueMethods.getFinalSandwichLine()
  return
    game.playthrough.storyline.exits[2].finalText .. " " .. -- topping, e.g. "A CRUNCHY"
    game.playthrough.storyline.exits[1].finalText .. " " .. -- protein, e.g. "HAM SANDWICH"
    game.playthrough.storyline.exits[3].finalText .. "!" -- condiment, e.g. "ON ISLAND TIME!"
end

function dialogueMethods.getFinalRobotLine()
  return
    game.playthrough.storyline.exits[1].robotText .. " " .. -- head, e.g. "SMART"
    game.playthrough.storyline.exits[2].robotText .. " " .. -- torso, e.g. "FRIDGE"
    game.playthrough.storyline.exits[3].robotText .. " BOT!" -- legs, e.g. "GOLF CART BOT!"
end

function dialogueMethods.getFinalTarotLine()
  return
    game.playthrough.storyline.exits[2].tarotText .. " " .. -- death, e.g. "DEATH-DEALING"
    game.playthrough.storyline.exits[3].tarotText .. " " .. -- tower, e.g. "HUNGRY"
    game.playthrough.storyline.exits[1].tarotText .. "!" -- star, e.g. "STARFISH!"
end

function dialogueMethods.getFinalLibraryPosterLine()
  return
    "A " ..
    game.playthrough.storyline.exits[2].posterText .. " " .. -- words, e.g. "SIMPLE"
    game.playthrough.storyline.exits[1].posterText .. " POSTER OF " .. -- paper, e.g. "GREASY POSTER OF"
    game.playthrough.storyline.exits[3].posterText .. "!" -- picture, e.g. "SOME DOG'S BUTT!"
end

function dialogueMethods.getFinalSkateParkEmojiLine()
  return
    game.playthrough.storyline.exits[1].finalText .. " / " .. -- e.g. "THUMBS UP EMOJI /"
    game.playthrough.storyline.exits[2].finalText .. " / " .. -- e.g. "BABY EMOJI /"
    game.playthrough.storyline.exits[3].finalText -- e.g. "MINTY EMOJI"
end

function dialogueMethods.getFinalBallMuseumLine()
  return
    "COME AND SEE " ..
    game.playthrough.storyline.exits[1].finalText .. ", " .. -- e.g. "AN 8-BALL,"
    game.playthrough.storyline.exits[2].finalText .. ", AND " .. -- e.g. "A POMEGRANATE, AND"
    game.playthrough.storyline.exits[3].finalText .. "!" -- e.g. "THE MOON!"
end

function dialogueMethods.getFinalSecurityCityLine()
  return
    game.playthrough.storyline.exits[1].finalText .. " " .. -- e.g. "HAZARDOUS,"
    game.playthrough.storyline.exits[2].finalText .. " " .. -- e.g. "SAFETY"
    game.playthrough.storyline.exits[3].finalText .. "!" -- e.g. "LEGEND!"
end

function dialogueMethods.getFinalDaycareRiddleLine1()
  return "WHEN " .. game.playthrough.storyline.exits[1].finalText .. "..." -- e.g. "WHEN THE THREADS OF FATE..."
end

function dialogueMethods.getFinalDaycareRiddleLine2()
  return "... MEETS " .. game.playthrough.storyline.exits[2].finalText .. "..." -- e.g. "...MEETS THE COLORS OF THE ANCIENT RAINBOM..."
end

function dialogueMethods.getFinalDaycareRiddleLine3()
  return "... " .. game.playthrough.storyline.exits[3].finalText .. " SHALL COME TO PASS!" -- e.g. "... NEW LIFE SHALL COME TO PASS!"
end
