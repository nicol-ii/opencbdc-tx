-------------------- PATCH METHOD --------------------
-- test 1: original
--[[ n = 25
print(math.sqrt(n))

-- test 2: overridden
local orig_sqrt = math.sqrt -- preserves original sqrt function
math.sqrt = function ()
    print("Hello World")
    return orig_sqrt(n)
end
print(math.sqrt(n)) ]]

-------------------- COROUTINE --------------------
--[[ function foo()
    for i=1,10 do
        print("co", i)
        coroutine.yield()
    end
end
co = coroutine.create(foo)
coroutine.resume(co)
coroutine.resume(co)
coroutine.resume(co)
coroutine.resume(co) ]]

-------------------- SET ENV --------------------
--[[ local foo;
bar = 5

do -- close to setfenv
    -- can sandbox specific functions like this ?
    local _ENV = { print = print}
    function foo()
        print(bar)
    end
end

foo() ]]

-------------------- ROOT CONTRACT: CAN ONLY TOUCH OWN STORAGE --------------------
--[[ self_transfer = io.open("./contracts/contract_to_savings.lua","rb"):read "*a"

-- contract prefix, contract address, payload
test_db = {["savings"]=5, ["checking"]=12, ["storage_nicole_savings"]=200, ["storage_nicole_checking"]=100, ["contract_nicole"]=self_transfer}

function trylock(k) -- original trylock
    return test_db[k]
end

function R(C,p)
    original_trylock = trylock
    function new_trylock(k)
        return original_trylock("storage_" .. C .. "_" .. k)
    end

    -- sandbox
    local update;
    do
        local f = load(original_trylock("contract_" .. C))
        local _ENV = { trylock=new_trylock, debug=debug, table=table }
        debug.setupvalue(f, 1, _ENV)
        f()
        _ENV.debug = nil
        update = contract(p)
    end

    sanitized_update = {}
    for k, v in pairs(update) do
        sanitized_update["storage_" .. C .. "_" .. k] = v
    end
    return sanitized_update
end

update = R("nicole", {10})
for k, v in pairs(update) do
    print(k .. "   " .. v)
end ]]

-------------------- SWAP CONTRACT --------------------
contract_USD = io.open("./contracts/contract_USD.lua","rb"):read "*a"
contract_CAD = io.open("./contracts/contract_CAD.lua","rb"):read "*a"
contract_swap = io.open("./contracts/contract_swap.lua","rb"):read "*a"
contract_a = io.open("./contracts/contract_a.lua","rb"):read "*a"
contract_b = io.open("./contracts/contract_b.lua","rb"):read "*a"

test_db = {["storage_USD_Alice"]=10, ["storage_CAD_Alice"]=0,
             ["storage_USD_Bob"]=0, ["storage_CAD_Bob"]=11,
             ["storage_a_all"]="a",
             ["storage_b_all"]="b",
             ["contract_USD"]=contract_USD,
             ["contract_CAD"]=contract_CAD,
             ["contract_swap"]=contract_swap,
             ["contract_a"]=contract_a,
             ["contract_b"]=contract_b
}
        

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

update = R("swap", {"Alice", "Bob", 10, 11, "USD", "CAD"})
for k,v in pairs(update) do print(k .. " " .. v) end

    









