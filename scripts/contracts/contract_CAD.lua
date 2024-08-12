function contract(param)
    mode = param[1]
    if mode == "pay" then
        error("not implemented yet")
    elseif mode == "earmark" then
        _, name, amount = table.unpack(param)
        value = trylock(name)
        if value >= amount then
            return {[name]=trylock(name)-amount}
        else
            error("insufficient funds")
        end
    elseif mode == "release" then
        _, name, amount = table.unpack(param)
        return {[name]=trylock(name) + amount}
    end
end
