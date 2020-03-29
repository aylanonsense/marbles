dialogueMethods = {}

function dialogueMethods.lastExitWas(exitId)
  return game and game.playthrough.storyline.exits[#game.playthrough.storyline.exits].id == exitId
end

function dialogueMethods.isSandwichQuality(quality)
  if game then
    local score = 0
    for _, exit in ipairs(game.playthrough.storyline.exits) do
      score += (exit.sandwichScore or 0)
    end
    if quality == "Fail" then
      return score < 10
    elseif quality == "Normal" then
      return 10 <= score and score < 21
    else
      return 21 <= score
    end
  end
end

function dialogueMethods.getSandwichNameLine()
  if game and #game.playthrough.storyline.exits >= 5 then
    return
      game.playthrough.storyline.exits[3].sandwichText .. " " .. -- cheese, e.g. "An extra horny"
      game.playthrough.storyline.exits[4].sandwichText .. " " .. -- veggies, e.g. "green"
      game.playthrough.storyline.exits[2].sandwichText .. " " .. -- protien, e.g. "muscle-builder"
      game.playthrough.storyline.exits[1].sandwichText .. " " .. -- bread, e.g. "wrap"
      game.playthrough.storyline.exits[5].sandwichText .. "!" -- condiments, e.g. "with mayo!"
  else
    return "A sandwich!"
  end
end

function dialogueMethods.getStorylineName()
  return game.playthroughData.storylines[game.playthrough.storyline.name].label
end
