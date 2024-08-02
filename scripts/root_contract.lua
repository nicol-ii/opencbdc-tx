function trylock(k) -- original trylock
    return test_db[k]
end
            
function R(C,p)
    original_trylock = trylock
    function new_trylock(k)
        return original_trylock("storage_" .. C .. "_" .. k)
    end

    function subroutine(C,p)
        function new_trylock(k)
            return original_trylock("storage_" .. C .. "_" .. k)
        end
        local f = assert(load(original_trylock("contract_" .. C)))
        local _ENV = { trylock=new_trylock, debug=debug, table=table, subroutine=subroutine, print=print, error=error, pairs=pairs }
        debug.setupvalue(f, 1, _ENV)
        f()
        _ENV.debug = nil
        return contract(p)
    end

    -- sandbox
    update = subroutine(C, p)
    sanitized_update = {}
    for k, v in pairs(update) do
        sanitized_update["storage_" .. C .. "_" .. k] = v
    end
    return sanitized_update
end
