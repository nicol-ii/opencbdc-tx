function gen_rc()
    function trylock(k)
        return coroutine.yield(k)
    end
    function hook()
        error("too many instructions")
    end
    function R(C,payload) -- condense
        debug.sethook(hook, "", 1000) -- instruction limit, can only have 1000 instructions
        update_map = {}
        
        function subroutine(C,payload) -- update the map
            function new_trylock(k)
                -- make it so it updates from update map
                if update_map[C] and update_map[C][k] then -- if value already in map
                    return update_map[C][k]
                end
                return trylock("storage_" .. C .. "_" .. k) -- if not already in map
            end

            local update;
            -- sandbox
            do
                local f = assert(load(trylock("contract_" .. C)))
                local _ENV = { trylock=new_trylock, subroutine=subroutine,
                                debug=debug,
                                table=table, print=print, error=error, pairs=pairs }
                debug.setupvalue(f, 1, _ENV)
                f()
                _ENV.debug = nil
                update = contract(payload)
            end
            -- update final map
            for k, v in pairs(update) do
                update_map["storage_" .. C .. "_" .. k] = v
            end
        end
        subroutine(C, payload)
        debug.sethook()
        return update_map
    end
    c = string.dump(R, true)
    t = {}
    for i = 1, #c do
        t[#t + 1] = string.format("%02x", string.byte(c, i))
    end
    
    return table.concat(t)
end








