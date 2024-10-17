function gen_rc()

    function R(param)
        function trylock(k)
            return coroutine.yield(k)
        end
        
        function hook()
            error("too many instructions")
        end

        C, payload = string.unpack("c11 c144", param) -- what format is payload in???
        
        -- let each individual contract handle signature and sequences (?)
        -- q: should I do check_sig in root contract or allow user-deployed contracts to enforce that...
    
        --debug.sethook(hook, "", 1000) -- instruction limit, should figure out how much set for root contract
        pre_update_map = {}
        
        function subroutine(C,payload) -- update the map
            function new_trylock(k)
                if pre_update_map[C] and pre_update_map[C][k] then -- if value already in map
                    return pre_update_map[C][k]
                end
                return trylock(k)
                return trylock("storage_" .. C .. "_" .. k) -- if not already in map
            end
    
            local update;
            -- sandbox
            do
                local f = assert(load(trylock("contract_" .. C)))
                -- local f = assert(load(trylock(C)))
                local _ENV = { trylock=new_trylock, subroutine=subroutine,
                                debug=debug,
                                table=table, print=print, error=error, pairs=pairs, 
                                coroutine=coroutine } -- needs to be gotten rid of before deployment
                debug.setupvalue(f, 1, _ENV)
                f()
                _ENV.debug = nil
                update = contract(payload)
            end
            -- update final map
            for k, v in pairs(update) do
                if not pre_update_map[C] then
                    pre_update_map[C] = {}
                end
                pre_update_map[C][k] = v
            end
        end
        subroutine(C, payload)
        --debug.sethook()
        update_map  = {}
        for C, tab in pairs(pre_update_map) do
            for k, v in pairs(tab) do
                update_map["storage_" .. C .. "_" .. k] = v
            end
        end
        return update_map
    end

    c = string.dump(R, true)
    t = {}
    for i = 1, #c do
        t[#t + 1] = string.format("%02x", string.byte(c, i))
    end
    return table.concat(t)
    
end









-- TESTING -- 

function R1(C,payload) -- original version
    function trylock(k)
        return test_db[k]
    end
    
    function hook()
        error("too many instructions")
    end

    debug.sethook(hook, "", 1000) -- instruction limit, can only have 1000 instructions
    pre_update_map = {}
    
    function subroutine(C,payload) -- update the map
        function new_trylock(k)
            if pre_update_map[C] and pre_update_map[C][k] then -- if value already in map
                return pre_update_map[C][k]
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
            if not pre_update_map[C] then
                pre_update_map[C] = {}
            end
            pre_update_map[C][k] = v
        end
    end
    subroutine(C, payload)
    debug.sethook()
    update_map  = {}
    for C, tab in pairs(pre_update_map) do
        for k, v in pairs(tab) do
            update_map["storage_" .. C .. "_" .. k] = v
        end
    end
    return update_map
end

contract_USD = io.open("./contracts/contract_USD.lua","rb"):read "*a"
contract_CAD = io.open("./contracts/contract_CAD.lua","rb"):read "*a"
contract_swap = io.open("./contracts/contract_swap.lua","rb"):read "*a"

test_db = {["storage_USD_Alice"]=1000, ["storage_CAD_Alice"]=0,
             ["storage_USD_Bob"]=0, ["storage_CAD_Bob"]=1000,
             ["contract_USD"]=contract_USD,
             ["contract_CAD"]=contract_CAD,
             ["contract_swap"]=contract_swap,
}
update = R1("swap", {"Alice", "Bob", 10, 11, "USD", "CAD"})
for k,tab in pairs(update) do 
    print(k .. " " .. tab)
end






