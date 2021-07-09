*! version 1.0.1  28oct2009  Ben Jann

program define dview
    version 9.0
    local caller : di _caller()
    syntax [anything(everything)] [, name(name) noCmd * ]
    if (`"`options'"'!="") {
        local options `", `options'"'
    }
    if "`name'" == "" {
        local name describe
    }
    version `caller': viewresults, name(`name') `cmd':describe `anything'`options'
end
