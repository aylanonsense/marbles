dialogueMethods = {}

function dialogueMethods.lastExitWas(exitId)
  return game.playthrough.storyline.exits[#game.playthrough.storyline.exits].id == exitId
end

function dialogueMethods.lastStorylineWas(storylineName)
  return game.playthrough.finishedStorylines[#game.playthrough.finishedStorylines].name == storylineName
end

function dialogueMethods.failResult()
  local averageScore = 0
  for _, exit in ipairs(game.playthrough.storyline.exits) do
    averageScore += (exit.score or 3) / #game.playthrough.storyline.exits
  end
  return averageScore < 1.9
end

function dialogueMethods.normalResult()
  local averageScore = 0
  for _, exit in ipairs(game.playthrough.storyline.exits) do
    averageScore += (exit.score or 3) / #game.playthrough.storyline.exits
  end
  return 1.9 <= averageScore and averageScore < 3.9
end

function dialogueMethods.specialResult()
  local averageScore = 0
  for _, exit in ipairs(game.playthrough.storyline.exits) do
    averageScore += (exit.score or 3) / #game.playthrough.storyline.exits
  end
  return 3.9 <= averageScore
end

function dialogueMethods.getSandwichNameLine()
  return
    game.playthrough.storyline.exits[3].sandwichText .. " " .. -- cheese, e.g. "An extra horny"
    game.playthrough.storyline.exits[4].sandwichText .. " " .. -- veggies, e.g. "green"
    game.playthrough.storyline.exits[2].sandwichText .. " " .. -- protien, e.g. "muscle-builder"
    game.playthrough.storyline.exits[1].sandwichText .. " " .. -- bread, e.g. "wrap"
    game.playthrough.storyline.exits[5].sandwichText .. "!" -- condiments, e.g. "with mayo!"
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

function dialogueMethods.getStorylineName()
  return game.playthroughData.storylines[game.playthrough.storyline.name].label
end
