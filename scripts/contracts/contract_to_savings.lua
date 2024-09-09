function contract(param) 
    value = table.unpack(param)
    savings = trylock("savings")
    checking = trylock("checking")
    return {["savings"]=savings + value, ["checking"]=checking - value}
end