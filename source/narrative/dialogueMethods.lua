dialogueMethods = {}

function dialogueMethods.bestoKnowsExtra()
  return true
end

function dialogueMethods.extraIsHungry(foodItemsEaten)
  return foodItemsEaten < 5
end

function dialogueMethods.protaIsTired()
  return false
end

function dialogueMethods.sayCoolSimilie(thing1, thing2)
  return {
    actor = "Prota",
    line = "A " .. thing1 .. " is just a " .. thing2 .. ".",
    expression = "happy"
  }
end

function dialogueMethods.getConcertConvoFinishingText()
  return "That was a great concert!"
end
