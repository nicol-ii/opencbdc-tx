function contract(param)
    mode, p1, p2, p3, amount = table.unpack(param)
    if mode == "1" then
        subroutine("comet", amount)
        return {[p1]={trylock(name) - amount}, [p2]=trylock(name) + amount}
    elseif mode == "2" then
        subroutine("tiggy", {trylock(p1), amount})
        return {[p1]=trylock(name) - 2*amount, [p3]=trylock(name) + 2*amount}
    else
        return true
    end
end