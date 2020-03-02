dialogueMethods = {}

function dialogueMethods.lastExitWas(exitId)
  return scene.storyline.exitsTaken[#scene.storyline.exitsTaken].id == exitId
end

function dialogueMethods.isSandwichQuality(quality)
  local score = 0
  for _, exit in ipairs(scene.storyline.exitsTaken) do
    score += exit.sandwichScore
  end
  if quality == "Fail" then
    return score <= 9
  elseif quality == "Normal" then
    return 10 <= score and score <= 20
  else
    return 21 <= score
  end
end

function dialogueMethods.getSandwichNameLine()
  if #scene.storyline.exitsTaken >= 5 then
    return
      scene.storyline.exitsTaken[3].sandwichText .. " " .. -- cheese, e.g. "An extra horny"
      scene.storyline.exitsTaken[4].sandwichText .. " " .. -- veggies, e.g. "green"
      scene.storyline.exitsTaken[2].sandwichText .. " " .. -- protien, e.g. "muscle-builder"
      scene.storyline.exitsTaken[1].sandwichText .. " " .. -- bread, e.g. "wrap"
      scene.storyline.exitsTaken[5].sandwichText .. "!" -- condiments, e.g. "with mayo!"
  else
    return "A sandwich!"
  end
end
