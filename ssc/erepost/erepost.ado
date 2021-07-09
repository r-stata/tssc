*! version 1.0.2, Ben Jann, 15jun2015

prog erepost, eclass
    version 8.2
    syntax [anything(equalok)] [, cmd(str) noEsample Esample2(varname) REName ///
        Obs(passthru) Dof(passthru) PROPerties(passthru) * ]
    if "`esample'"!="" & "`esample2'"!="" {
        di as err "only one allowed of noesample and esample()"
        exit 198
    }
// parse [b = b] [V = V]
    if `"`anything'"'!="" {
        tokenize `"`anything'"', parse(" =")
        if `"`7'"'!="" error 198
        if `"`1'"'=="b" {
            if `"`2'"'=="=" & `"`3'"'!="" {
                local b `"`3'"'
                confirm matrix `b'
            }
            else error 198
            if `"`4'"'=="V" {
                if `"`5'"'=="=" & `"`6'"'!="" {
                    local v `"`6'"'
                    confirm matrix `b'
                }
                else error 198
            }
            else if `"`4'"'!="" error 198
        }
        else if `"`1'"'=="V" {
            if `"`4'"'!="" error 198
            if `"`2'"'=="=" & `"`3'"'!="" {
                local v `"`3'"'
                confirm matrix `v'
            }
            else error 198
        }
        else error 198
    }
//backup existing e()'s
    if "`esample2'"!="" {
        local sample "`esample2'"
    }
    else if "`esample'"=="" {
        tempvar sample
        gen byte `sample' = e(sample)
    }
    local emacros: e(macros)
    local emacros: subinstr local emacros "_estimates_name" "", word
    if `"`properties'"'!="" {
        local emacros: subinstr local emacros "properties" "", word
    }
    foreach emacro of local emacros {
        local e_`emacro' `"`e(`emacro')'"'
    }
    local escalars: e(scalars)
    if `"`obs'"'!="" {
        local escalars: subinstr local escalars "N" "", word
    }
    if `"`dof'"'!="" {
        local escalars: subinstr local escalars "df_r" "", word
    }
    foreach escalar of local escalars {
        tempname e_`escalar'
        scalar `e_`escalar'' = e(`escalar')
    }
    local ematrices: e(matrices)
    if "`b'"=="" & `:list posof "b" in ematrices' {
        tempname b
        mat `b' = e(b)
    }
    if "`v'"=="" & `:list posof "V" in ematrices' {
        tempname v
        mat `v' = e(V)
    }
    local bV "b V"
    local ematrices: list ematrices - bV
    foreach ematrix of local ematrices {
        tempname e_`ematrix'
        matrix `e_`ematrix'' = e(`ematrix')
    }
// rename
    if "`b'"!="" & "`v'"!="" & "`rename'"!="" { // copy colnames from b
        mat `v' = `b' \ `v'
        mat `v' = `v'[2..., 1...]
        mat `v' = `b'', `v'
        mat `v' = `v'[1..., 2...]
    }
// post results
    if "`esample'"=="" {
        eret post `b' `v', esample(`sample') `obs' `dof' `properties' `options'
    }
    else {
        eret post `b' `v', `obs' `dof' `properties' `options'
    }
    foreach emacro of local emacros {
        eret local `emacro' `"`e_`emacro''"'
    }
    if `"`cmd'"'!="" {
        eret local cmd `"`cmd'"'
    }
    foreach escalar of local escalars {
        eret scalar `escalar' = scalar(`e_`escalar'')
    }
    foreach ematrix of local ematrices {
        eret matrix `ematrix' = `e_`ematrix''
    }
end
