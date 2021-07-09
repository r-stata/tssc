*JBA 30Oct2006
*For a numeric variable list converts all variables to largest data type
program define decompress
    version 8
    syntax [varlist]

    local typelist ""
    foreach x in `varlist' {
        local type : type `x'
        local typelist "`typelist' `type'"
    }

    // test that all variables are of the same type
    tokenize `varlist'
    cap confirm numeric variable `1'
    if !_rc {
        confirm numeric variable `varlist'

        local double : list posof "double" in typelist
        local float : list posof "float" in typelist
        local long : list posof "long" in typelist
        local int : list posof "int" in typelist

        if (`double') local type "double"
        else if (`float') local type "float"
        else if (`long') local type "long"
        else if (`int') local type "int"
        else local type "byte"
    }
    else {
        confirm string variable `varlist'
        local maxlen = 0
        foreach x in `varlist' {
            local len = real(substr("`:type `x''",4,.))
            if (`len' > `maxlen') {
                local maxlen = `len' 
            }
        }
        local type "str`maxlen'"
    }
    recast `type' `varlist'
    forvalues i = 1/`:word count `varlist'' {
        local type : word `i' of `typelist'
        local var : word `i' of `varlist'
        local newtype : type `var'
	  if "`newtype'" != "`type'" {
             di "{txt}`var' was {res}`type' {txt}now {res}`newtype'"
        }
    }

end
