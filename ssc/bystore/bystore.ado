*! version 1.0.0 DH 23Dec2004.
program bystore
    version 8
    tokenize `"`0'"', p(":")
    cap assert "`2'"==":"
    if _rc {
        di as error ": required"
        exit 100
    }
	local bssyntax `1'
	mac shift 2
    local ecmd `*'
    local 0 `bssyntax'
    syntax varlist [, noLabel PREfix(string) *]
	tempvar grp
    if `"`prefix'"'=="" {
        local prefix "_E"
    }
    _stripchars `prefix'
    local prefix=r(name)
    confirm name `prefix'
    qui {
        cap est drop `prefix'*
        if "`label'"=="" {
		    tempname glab
		    egen `grp'=group(`varlist'), lname(`glab')
        }
        else {
            egen `grp'=group(`varlist')
        }
    	su `grp', meanonly
        local ng=r(max)
        preserve
        forvalues g=1/`ng' {
            if "`label'"=="" {
				local gl : label `glab' `g'
    	        _stripchars `gl'
        	    local gl=r(name)
                confirm name `gl'
            }
            else {
                local gl `g'
            }
            keep if `grp'==`g'
            `ecmd' if `grp'==`g'
            est store `prefix'`gl'
            restore, preserve
        }
        restore
    }
    est table `prefix'*, `options'
end

program _stripchars, rclass
    foreach c of numlist 30/31 33/47 58/64 91/94 123/137 139 141 143/153 155 157 160/191 215 216 247 248 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "", all
    }
    local 0 : subinstr local 0 `"`=char(138)'"' "S", all
    foreach c of numlist 140 208 210/214 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "O", all
    }
    local 0 : subinstr local 0 `"`=char(142)'"' "Z", all
    foreach c of numlist 154 223 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "s", all
    }
    foreach c of numlist 156 240 242/246 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "o", all
    }
    local 0 : subinstr local 0 `"`=char(158)'"' "z", all
    foreach c of numlist 159 221 222 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "Y", all
    }
    foreach c of numlist 192/198 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "A", all
    }
    local 0 : subinstr local 0 `"`=char(199)'"' "c", all
    foreach c of numlist 200/203 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "E", all
    }
    foreach c of numlist 204/207 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "I", all
    }
    local 0 : subinstr local 0 `"`=char(209)'"' "N", all
    foreach c of numlist 217/220 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "U", all
    }
    foreach c of numlist 224/230 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "a", all
    }
    local 0 : subinstr local 0 `"`=char(231)'"' "c", all
    foreach c of numlist 232/235 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "e", all
    }
    foreach c of numlist 236/239 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "i", all
    }
    local 0 : subinstr local 0 `"`=char(241)'"' "n", all
    foreach c of numlist 249/252 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "u", all
    }
    foreach c of numlist 253/255 {
        local 0 : subinstr local 0 `"`=char(`c')'"' "y", all
    }
    local 0 : subinstr local 0 "`" "", all
    local 0 : subinstr local 0 " " "_", all
    return local name `"`0'"'
end
