require "utxo"

shard = {} -- placeholder


function check_sig (inp, out, sig)
    -- error("signature not valid")
    return true
end

function hash_tx (inp, out)
    -- placeholder
    return 2
end

function serialize (tx_hash, idx)
    return string.pack("c32 I8", tx_hash, idx)
end

function is_valid (inp, out, sig)
    -- check input existence in shards
    --[[ for _, token in pairs(inp) do
        if not shard[token] then
            error("inputs invalid")
        end
    end ]]
    -- check input balanced to output
    local inUSD, inRCV = 0, 0
    local in_amounts = {}
    for _, bill in pairs(inp) do
        local val, unit, owner = bill:getValue(), bill:getUnit(), bill:getSC()
        if unit == "RCV" then
            inRCV = inRCV + val
        elseif unit == "USD" then
            inUSD = inUSD + val
        end
        local acc = owner .. "_" .. unit
        if not in_amounts[acc] then
            in_amounts[acc] = 0
        end
        in_amounts[acc] = in_amounts[acc] + val
    end
    local outUSD, outRCV = 0, 0
    local out_amounts = {}
    for _, bill in pairs(out) do
        local val, unit, owner = bill:getValue(), bill:getUnit(), bill:getSC()
        if unit == "RCV" then
            outRCV = outRCV + val
        elseif unit == "USD" then
            outUSD = outUSD + val
        end
        local acc = owner .. "_" .. unit
        if not out_amounts[acc] then
            out_amounts[acc] = 0
        end
        out_amounts[acc] = out_amounts[acc] + val
    end

    if inUSD ~= outUSD or inRCV ~= outRCV or inUSD ~= inRCV or outUSD ~= outRCV then
        error("inputs and outputs are not balanced")
    end
    -- check rcv tokens swapped correctly (difficult)

    -- check signature (NEED TO DESIGN THIS FUNCTION???)
    check_sig(inp, out, sig)

    
end

function process_tx (tx)
    local inp, out, sig = table.unpack(tx)
    -- make sure tx is valid
    is_valid(inp, out, sig)

    -- compute tx hash
    local tx_hash = hash_tx(inp, out)

    -- compute serial nms for output and assign serials
    for idx, bill in pairs(out) do
        bill:setSerialNum(serialize(tx_hash, idx))
    end
    
    local del, add = {}, {}
    -- compute hashes of utxos
    for _, bill in pairs(inp) do
        table.insert(del, bill:hash())
    end
    for _, bill in pairs(out) do
        table.insert(add, bill:hash())
    end

    return table.pack(del, add)
end

u1 = UTXO:new{value = 10, unit = "USD", spendingCondition = "A", serial = 0}
u2 = UTXO:new{value = 10, unit = "RCV", spendingCondition = "B", serial = 1}
u3 = UTXO:new{value = 7, unit = "USD", spendingCondition = "B", serial = 2}
u4 = UTXO:new{value = 3, unit = "USD", spendingCondition = "A", serial = 3}
u5 = UTXO:new{value = 7, unit = "RCV", spendingCondition = "B", serial = 4}
u6 = UTXO:new{value = 3, unit = "RCV", spendingCondition = "A", serial = 5}

inp = {u1, u2}
out = {u3, u4, u5, u6}
sig = "sig"
tx = {inp, out, sig}

process_tx(tx)
