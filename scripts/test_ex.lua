function check_subroutines(bytecode) -- extracts all arguments to subroutine calls in a given bytecode
    results = {}
    i = 1
    while i < #bytecode do
        s_pos, e_pos = bytecode:find("subroutine", i)
        if not s_pos then break end
        stk = {}
        cur_start = e_pos + 1
        cur_end = nil
        for j = cur_start, #bytecode do
            ch = bytecode:sub(j, j)
            if ch == "(" then 
                table.insert(stk, "(")
            elseif ch == ")" then 
                table.remove(stk)
                if #stk == 0 then
                    cur_end = j
                    break
                end
            end
        end
        if cur_end then 
            arg = bytecode:sub(cur_start, cur_end-1)
            table.insert(results, arg:sub(2))
            i = cur_end + 1
        end
    end
    return results
end

function sig_payload(acc, new_val, seq) -- you sign off each account's new value
    return string.pack("c32 I8 I8", acc, new_val, seq)
end

function verify_sig(update, sigs, seq) -- goal: verifies that there is a signature for each account touched in update uh
    for acc, v in pairs(update) do
        payload = sig_payload(acc, v, seq)
        verified = false
        for sig in sigs do -- if one signature works, then validate that
            if pcall(check_sig(sig, payload)) then 
                verified = true 
                break
            end
        end
        if not verified then
            error("invalid signature")
        end
    end
end

test = io.open("./contracts/contract_swap.lua","rb"):read "*a"
subs_called = check_subroutines(test)
print(table.concat(subs_called, "\n"))

