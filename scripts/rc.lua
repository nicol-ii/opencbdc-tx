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

test_db = {["storage_USD_Alice"]=1000, ["storage_CAD_Alice"]=0,
             ["storage_USD_Bob"]=0, ["storage_CAD_Bob"]=1000,
             ["storage_a_all"]="aaa",
             ["storage_b_all"]="bbb",
             ["contract_USD"]=contract_USD,
             ["contract_CAD"]=contract_CAD,
             ["contract_swap"]=contract_swap,
             ["contract_a"]=contract_a,
             ["contract_b"]=contract_b,
             ["contract_swap_users"]={["Alice"]=true, ["Bob"]=true},
             ["contract_USD_users"]={["Alice"]=true, ["Bob"]=true},
             ["contract_CAD_users"]={["Alice"]=true, ["Bob"]=true}
}

function trylock(k)
    return test_db[k]
end

function check_sig(from, sig, payload) -- for unit testing sake... do smth simple
end

function pack_account(updates, name, balance, seq)
    updates[name] = string.pack("I8 I8", balance, seq)
end

function update_accounts(from_acc, from_bal, from_seq, to_acc, to_bal, to_seq)
    ret = {}
    pack_account(ret, from_acc, from_bal, from_seq)
    if to_acc ~= nil then
        pack_account(ret, to_acc, to_bal, to_seq)
    end
    return ret
end

function hook()
    error("too many instructions")
end 

function R(C,payload)
    debug.sethook(hook, "", 1000) -- instruction limit, can only have 1000 instructions

    function subroutine(C,payload)
        function new_trylock(k)
            return trylock("storage_" .. C .. "_" .. k)
        end
        local f = assert(load(trylock("contract_" .. C)))
        local _ENV = { trylock=new_trylock, pack_account=pack_account, update_accounts=update_accounts, subroutine=subroutine,
                        debug=debug,
                        table=table, print=print, error=error, pairs=pairs, string=string, type=type }
        debug.setupvalue(f, 1, _ENV)
        f()
        _ENV.debug = nil
        update = contract(payload)


        
        sanitized_update = {}
        -- ayo.
        for k, v in pairs(update) do
            if k:sub(1,8) == "storage_" then 
                sanitized_update[k] = v
            else
                sanitized_update["storage_" .. C .. "_" .. k] = v
            end
        end
        return sanitized_update
    end

    update = subroutine(C, payload)
    debug.sethook()
    return update
end

function call(usr,C,payload)
    -- check if user has permission to execute contract through whitelist/blacklist
    if not trylock("contract_" .. C .. "_users")[usr] then
        error("no permission to use contract")
    end
    return R(C,payload)
end

update = call("Alice", "swap", {"Alice", "Bob", 10, 11, "USD", "CAD"})
for k,v in pairs(update) do print(k .. " " .. v) end









