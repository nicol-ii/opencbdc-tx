-- contract b is called by contract a
function contract(param)
    return trylock(param[1])
end