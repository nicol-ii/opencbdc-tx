function contract(param)
    p1, p2, amount1, amount2, currency1, currency2, sig1, sig2, seq = table.unpack(param) -- p1 would like to swap amount1 of currency1 with p2 for amount2 of currency2
    -- verification for person 1
    --[[ payload1 = sig_payload(p2, amount1, seq)
    check_sig(p1, sig1, payload1) ]]
    -- verification for person 2
    --[[ payload2 = sig_payload(p1, amount2, seq)
    check_sig(p2, sig2, payload2) ]]
    -- if signatures verified, continue
    earmark1 = subroutine(currency1,{"earmark", p1, amount1})
    earmark2 = subroutine(currency2,{"earmark", p2, amount2})
    if not earmark1 or not earmark2 then
        error("insufficient funds")
    end
    p2_update = subroutine(currency1,{"release", p2, amount1})
    p1_update = subroutine(currency2,{"release", p1, amount2})
    result = {}
    for k,v in pairs(earmark1) do result[k] = v end
    for k,v in pairs(p1_update) do result[k] = v end
    for k,v in pairs(earmark2) do result[k] = v end
    for k,v in pairs(p2_update) do result[k] = v end
    return result
end

-- try and override another function