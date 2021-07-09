*! version 1.0.3  Ben Jann  13dec2007

prog mgofi
    version 9.2
    syntax anything [, vce(passthru) CLuster(passthru) svy SVY2(passthru) * ]
    local svy `"`svy'`svy2'"'
    foreach opt in vce cluster svy {
        if `"``opt''"'!="" {
            di as err "`opt' not allowed"
            exit 198
        }
    }
    gettoken obs exp : anything, parse("/")
    gettoken exp exp : exp, parse("/")
    local rdel ""
    foreach o of local obs {
        gettoken e exp : exp
        local mat `"`macval(mat)'`rdel'"'
        local mat `"`macval(mat)'`o'"'
        if `"`e'"'!="" {
            local mat `"`macval(mat)',`e'"'
        }
        local rdel "\"
    }
    tempname C
    mat input `C' = (`macval(mat)')
    mgof, mat(`C') `options'
end
