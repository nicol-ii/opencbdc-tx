-- contract_a is going to subroutine contract_b
function contract(param)
    return subroutine("b", {"all"})
    -- would like this to return test_db["storage_b_all"]
end