function trylock(k) -- original trylock
    return test_db[k]
end
            
function R(C,p)
    original_trylock = trylock

    function subroutine(C,p)
        function new_trylock(k)
            return original_trylock("storage_" .. C .. "_" .. k)
        end
        local f = assert(load(original_trylock("contract_" .. C)))
        local _ENV = { trylock=new_trylock, debug=debug, table=table, subroutine=subroutine, print=print, error=error, pairs=pairs, string=string }
        debug.setupvalue(f, 1, _ENV)
        f()
        _ENV.debug = nil
        update = contract(p)
        if update == true or update == false then return update end -- if update is not a table
        sanitized_update = {}
        for k, v in pairs(update) do
            if string.sub(k, 1, 7) == "storage" then
                sanitized_update[k] = v
            else
                sanitized_update["storage_" .. C .. "_" .. k] = v
            end
        end
        return sanitized_update
    end
    
    update = subroutine(C, p)
    return update
end
