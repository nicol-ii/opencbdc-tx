function contract(param)
    p1, p2, amount1, amount2, currency1, currency2, sig1, sig2, seq = table.unpack(param) -- p1 would like to swap amount1 of currency1 with p2 for amount2 of currency2
    -- verification for person 1
    --[[ payload1 = sig_payload(p2, amount1, seq)
    check_sig(p1, sig1, payload1) ]]
    -- verification for person 2
    --[[ payload2 = sig_payload(p1, amount2, seq)
    check_sig(p2, sig2, payload2) ]]
    subroutine(currency1,{"earmark", p1, amount1})
    subroutine(currency2,{"earmark", p2, amount2})
    subroutine(currency1,{"release", p2, amount1})
    subroutine(currency2,{"release", p1, amount2})
    return {}
end

-- try and override another function 
-- doesn't work!
function print(arg)
    error("byebye")
end