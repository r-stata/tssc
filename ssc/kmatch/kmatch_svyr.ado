*! version 1.0.0.  11mar2020  Ben Jann

program kmatch_svyr, eclass prop(svyr)
    version 11
    local version : di "version " string(_caller()) ":"
    _parse comma lhs 0 : 0
    gettoken subcmd : lhs
    if `"`subcmd'"'=="predict" {
        gettoken subcmd lhs : lhs
        kmatch_svyr_p `lhs' `0'
        exit
    }
    syntax [, svy IFGENerate IFGENerate2(passthru) * ]
    if "`svy'"!="" {
        di as err "option svy not allowed"
        exit 198
    }
    if `"`ifgenerate'`ifgenerate2'"'=="" {
        di as err "ifgenerate() required"
        exit 198
    }
    `version' kmatch `lhs' `0'
    tempname b V
    mat `b' = e(b)
    mat `V' = I(`=colsof(`b')')
    mata: Kmatch_svylbl_b()
    ereturn repost b=`b' V=`V', resize
    eret local predict "kmatch_svyr predict"
end

program kmatch_svyr_p
    if `"`e(cmd)'"'!="kmatch" {
        di as err "last kmatch results not found"
        exit 301
    }
    syntax [anything] [if], SCores
    local IFs `"`e(ifgenerate)'"'
    if `:list sizeof IFs'==0 {
        di as err "IF variables not found"
        exit 498
    }
    _score_spec `anything', `scores'
    local tlist `s(typlist)'
    local vlist `s(varlist)'
    local over `"`e(over)'"'
    if `"`over'"'!="" {
        local levels `"`e(over_namelist)'"'
        local nover: list sizeof levels
        assert (`:list sizeof IFs'*`nover' == `:list sizeof vlist')
        foreach l of local levels {
            foreach IF of local IFs {
                gettoken var vlist : vlist
                gettoken typ tlist : tlist
                qui gen double `var' = cond(`IF'<. & `over'==`l', `IF', 0) `if'
            }
        }
    }
    else {
        assert (`:list sizeof IFs' == `:list sizeof vlist')
        foreach IF of local IFs {
            gettoken var vlist : vlist
            gettoken typ tlist : tlist
            qui gen double `var' = cond(`IF'<., `IF', 0) `if'
        }
    }
end

version 11
mata:
mata set matastrict on

void Kmatch_svylbl_b()
{
    string matrix cstripe
    
    cstripe = st_matrixcolstripe(st_local("b"))
    cstripe[,1] = cstripe[,1] :+ "@" :+ cstripe[,2]
    cstripe[,2] = J(rows(cstripe), 1, "_cons")
    st_matrixcolstripe(st_local("b"), cstripe)
}

end

exit

