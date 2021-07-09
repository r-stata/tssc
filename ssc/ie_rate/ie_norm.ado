
program define ie_norm, eclass
// adapted/cloned from Ben Jann's devcon.ado
// normalize reference category coefficients after ANOVA fit 

	syntax, Groups(string) [ eq(int 1) ]
//retrieve names of regressors
	tempname b V btmp
	mat `b' = e(b)'
	mat `V' = e(V)
	if `"`e(eqnames)'"'=="" {
		local eqs: roweq `b', quoted
		local eqs: list uniq eqs
	}
	else local eqs `"`e(eqnames)'"'
	local eq: word `eq' of `eqs'
	if `"`eq'"'=="" {
		di as err "equation not found"
		exit 111
	}
	if `:list sizeof eqs'>1 {
		tempname btmp
		mat `btmp' = `b'[`"`eq':"',1]
		local vars: rownames `btmp'
		mat drop `btmp'
	}
	else local vars: rownames `b'
	local rest `vars'
	if `"`eq'"'=="_" local eq
	else local eq `"`eq':"'

//Parse groups

	tokenize `"`groups'"', parse(",")
	while `"`1'"'!="" {
		gettoken 1 cons : 1, parse("(")
		if "`cons'"!="" {
			unab cons: `cons'
		}
		if "`cons'"=="" local cons _cons
		if !`:list cons in vars' {
			di as error `"coefficient "`cons'" not found"'
			exit 111
		}
		unab 1: `1'
		local keep `1'
		local ref: list 1 - vars
		if `:list sizeof ref'>1 {
			di as txt "note: several possible reference indicators: `ref'"
			di as txt "      using first indicator; this may cause problems"
		}
		local ref: word 1 of `ref'
		if "`ref'"=="" {
			di as error "no reference indicator found"
			exit 111
		}
		local 1: list vars & 1
		if "`1'"=="" {
			di as error "invalid groups()"
			exit 198
		}
		if !`:list 1 in rest' {
			di as error "groups must be mutually exclusive"
			exit 198
		}
		local rest: list rest - 1
		local 1: list 1 | ref
		local 1: list keep & 1
		local gvars `"`gvars'"`1'" "'
		if `:list ref in refs' {
			di as error "duplicate reference indicators"
			exit 198
		}
		else local refs "`refs'`ref' "
		local conss "`conss'`cons' "
		mac shift
		mac shift
	}

//Determine order of coefficients
	local var: word 1 of `vars'
	while "`var'"!="" {
		if `:list var in rest' {
			local master `"`master'`"`eq'`var'"' "'
			local vars: list vars - var
		}
		else {
			foreach gvar of local gvars {
				if `:list var in gvar' {
					foreach temp of local gvar {
						local master `"`master'`"`eq'`temp'"' "'
					}
					local vars: list vars - gvar
					continue, break
				}
			}
		}
		local var: word 1 of `vars'
	}

//Normalize coefficients and compute (co-)variances
	tempname I Icons btmp Vtmp Z
	local g 0
	foreach vars of local gvars {
		local ref: word `++g' of `refs'
		local cons: word `g' of `conss'
		local k: word count `vars'
//-prepare indicator vectors
		mat `I' = `b' * 0
		foreach var of local vars {
			if "`var'"!="`ref'" {
				mat `I'[rownumb(`I',`"`eq'`var'"'),1] = -1
			}
		}
		mat `Icons' = `I'

//-transform coefficients vector
//-minus the sum of relevant coefficient vector 
 		mat `btmp' = `I'' * `b' 
		mat rown `btmp' = `"`eq'`ref'"'
        mat `b' =  `b' \ `btmp'

//-add ref cat to V(b)

        mat `Vtmp' = ( `I'' * `V' )
		mat rown `Vtmp' = `"`eq'`ref'"'
        mat `V' = ( `V' \ -`Vtmp' ) , ( ( -`Vtmp'' \ `Vtmp' * `I'))
//-update indicator vectors and transform V(b)
		mat `I' = `I' \ `btmp'*0
		mat `Icons' = `Icons' \ `btmp'*0
		mat `Vtmp' = ( `I'' * `V')
	}
	mat drop `btmp' `Vtmp'

//Reorder b and v(b)
	if `"`eq'"'""=="" local eq "_:"
	foreach eqi of local eqs {
		if `"`eqi':"'==`"`eq'"' {
			foreach var of local master {
				mat `btmp' = nullmat(`btmp') \ `b'[`"`var'"',1]
				mat `Vtmp' = nullmat(`Vtmp') \ `V'[`"`var'"',1...]
			}
		}
		else {
			mat `btmp' = nullmat(`btmp') \ `b'[`"`eqi':"',1]
			mat `Vtmp' = nullmat(`Vtmp') \ `V'[`"`eqi':"',1...]
		}
	}
	mat `b' = `btmp''
	mat drop `btmp'
	mat `V' = `Vtmp'
	mat drop `Vtmp'
	foreach eqi of local eqs {
		if `"`eqi':"'==`"`eq'"' {
			foreach var of local master {
				mat `Vtmp' = nullmat(`Vtmp') , `V'[1...,`"`var'"']
			}
		}
		else {
			mat `Vtmp' = nullmat(`Vtmp') , `V'[1...,`"`eqi':"']
		}
	}
	mat `V' = `Vtmp'
	mat drop `Vtmp'

//Post results
	local temp: e(macros)
	local i: list sizeof temp
	while `i'>0 {
		local e_local: word `i--' of `temp'
		if `"`e_local'"'!="_estimates_name" {
			local e_locals: list e_locals | e_local
		}
	}
	foreach e_local of local e_locals {
		local e_`e_local' `"`e(`e_local')'"'
	}
	local e_scalars: e(scalars)
	local e_scalars: subinstr local e_scalars "N" "", word
	local e_scalars: subinstr local e_scalars "df_r" "", word
	foreach e_scalar of local e_scalars {
		tempname `e_scalar'
		scalar ``e_scalar'' = e(`e_scalar')
	}
	tempname touse
	gen `touse' = e(sample)
	eret post `b' `V', esample(`touse') ///
	 `=cond(`:list sizeof e_depvar'==1,"depname(`e_depvar')","")'  ///
	 obs(`e(N)') `=cond("`e(df_r)'"!="","dof(`e(df_r)')","")'
	ereturn local devcon transformed
	foreach e_local of local e_locals {
		ereturn local `e_local' `"`e_`e_local''"'
	}
	foreach e_scalar of local e_scalars {
		ereturn scalar `e_scalar' = ``e_scalar''
	}
//Display results
	di as txt _n "Transformed " as res "`e(cmd)'" as txt " coefficients" _c
		di as txt _col(51) "Number of obs    =" as res %10.0g e(N)
		eret di, `level'
end






