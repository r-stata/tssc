*! version 1.1.0 PR 27apr2012
program define xpredict
version 11.0
syntax newvarname [if] [in], WITH(varlist fv) ///
 [ A(numlist) at(string) CONStant DOUble EQ(string) MEANzero mi Stdp xb ]
// Option xb is default so is redundant, included for backwards compatibility
if "`xb'" != "" {
	local xb
}
if "`mi'"!="" {
	confirm var _mj
}
fvexpand `with'
local with `r(varlist)'
if "`meanzero'" != "" & "`stdp'" != "" {
	// Mark complete cases among `with' for later use
	tempvar touse
	mark `touse'
	markout `touse' `with'
	local origwith `with'
}
tempname tmp b V b2 V2
matrix `b'=e(b)
matrix `V'=e(V)
if "`constant'"!="" {
	local with `with' _cons
}
if missing(`"`eq'"') {
	local eq : coleq `b'
	local eq : word 1 of `eq'
	if (`"`eq'"' == "-") local eq
}
if !missing(`"`eq'"') {
	* include equation name with variable(s)
	tokenize `with'
	local with
	while "`1'"!="" {
		local with `with' `eq':`1'
		mac shift
	}
}
matselrc `b' `b2', row(1) col(`with')
matselrc `V' `V2', row(`with') col(`with')
local nc = colsof(`b2')
if "`a'"!="" {
	local na: word count `a'
	if `na'!=`nc' {
		di in red "wrong number of elements in a(), should be `nc'"
		exit 198
	}
	* construct matrix from `a' by hand
	tempname A
	matrix `A'=J(1,`nc',0)
	tokenize `a'
	local i 1
	while `i'<=`nc' {
		matrix `A'[1,`i']=``i''
		local i=`i'+1
	}
	local cn: colnames `b2'
	* Linear combination of elements in b2 with a.
	* Multiply A by b2 elementwise and overwrite b2.
	qui matewm `A' `b2' `b2'
	matrix colnames `b2'=`cn'
	* Form outer product of A with itself then multiply by V2 elementwise,
	* overwriting V2.
	matrix `A'=`A''*`A'
	qui matewm `A' `V2' `V2'
	matrix colnames `V2'=`cn'
	matrix rownames `V2'=`cn'
}
_estimates hold `tmp'
capture ereturn post `b2' `V2'
local rc=c(rc)
if `rc' {
	_estimates unhold `tmp'
	error `rc'
}
// Out of sample predictions using at()
if "`at'" != "" {
	preserve
	tokenize `at'
	while "`1'" != "" {
		fvunab tmpfv: `1'
		local 1 `tmpfv'
		cap _ms_parse_parts `1'
		if c(rc) {
			di as err "invalid term " as res "`1'" as err " in at(... `1' `2' ...)"
			di as err "`1' may refer to an entire factor variable"
			exit 198
		}
		if "`r(type)'" != "variable" {
			di as err "level indicators of factor" /*
				*/ " variables may not be individually set" _n /*
				*/ "with the at() option; set one value" /*
				*/ " for the entire factor variable"
			exit 198
		}
		cap confirm var `2'
		if c(rc) {
			cap confirm num `2'
			if c(rc) {
				di as err "invalid at(... `1' `2' ...)"
				exit 198
			}
		}
		qui replace `1' = `2' `if' `in'
		mac shift 2
	}
}
qui if "`mi'"!="" {
	* Partial prediction for all obs, then average over imputations
	sum _mj, meanonly
	local m=r(max)
	tempvar f
	if `"`if'"'=="" {
		local If if _mj>0
	}
	else local If `if' & _mj>0
	capture predict `double' `f' `If' `in', xb
	local rc=_rc
	_estimates unhold `tmp'
	if `rc' {
		error `rc'
	}
	sort _mi _mj
	by _mi: gen `double' `varlist'=sum(`f')/`m' if _mj>0
	by _mi: replace `varlist'=`varlist'[_N] if _n<_N & _mj>0
}
else {
	tempvar newvar
	predict `double' `newvar' `if' `in', `stdp' `options'
	if "`meanzero'" != "" {
		if "`stdp'" == "" {
			qui sum `newvar' `if' `in'
			qui gen `double' `varlist' = `newvar' - r(mean)
		}
		else {
			matrix `V' = e(V)
			mata: zcalc("`varlist'", "`V'", "`origwith'", "`touse'")
		}
	}
	else rename `newvar' `varlist'
	_estimates unhold `tmp'
}
if "`at'" != "" {
	// restore original data and merge in new variables
	keep `varlist'
	tempfile newvars
	qui save `"`newvars'"'
	restore
	merge 1:1 _n using `"`newvars'"', nogenerate noreport
}
end

*! NJC 1.1.0 20 Apr 2000  (STB-56: dm79)
program def matselrc
* NJC 1.0.0 14 Oct 1999 
        version 6.0
        gettoken m1 0 : 0, parse(" ,")
        gettoken m2 0 : 0, parse(" ,") 
	
	if "`m1'" == "," | "`m2'" == "," | "`m1'" == "" | "`m2'" == "" { 
		di in r "must name two matrices" 
		exit 198
	} 
	
        syntax , [ Row(str) Col(str) Names ]
        if "`row'`col'" == "" {
                di in r "nothing to do"
                exit 198
        }

        tempname A B 
        mat `A' = `m1' /* this will fail if `matname' not a matrix */
	local cols = colsof(`A') 
	local rows = rowsof(`A') 

        if "`col'" != "" {
		if "`names'" != "" { local colnum 1 } 
		else { 
	                capture numlist "`col'", int r(>0 <=`cols')
			if _rc == 0 { local col "`r(numlist)'" } 
                	else if _rc != 121 { 
				local rc = _rc 
				error `rc' 
			} 	
			local colnum = _rc == 0 
		}	
		/* colnum = 1 for numbers, 0 for names */ 

		tokenize `col' 
		local ncols : word count `col' 
		if `colnum' { 
			mat `B' = `A'[1..., `1'] 
			local j = 2 
			while `j' <= `ncols' { 
                		mat `B' = `B' , `A'[1..., ``j'']
				local j = `j' + 1 
			} 	
		} 
		else {
			mat `B' = `A'[1..., "`1'"] 
			local j = 2 
			while `j' <= `ncols' { 
                		mat `B' = `B' , `A'[1..., "``j''"]
				local j = `j' + 1 
			} 	
		} 
		mat `A' = `B' 	
		local cols = colsof(`A')  		
        }
	
	if "`row'" != "" {
		if "`names'" != "" { local rownum 0 } 
		else { 
	                capture numlist "`row'", int r(>0 <=`rows')
			if _rc == 0 { local row "`r(numlist)'" } 
                	else if _rc != 121 { 
				local rc = _rc 
				error `rc' 
			} 	
			local rownum = _rc == 0   
		} 	
		/* rownum = 1 for numbers, 0 for names */ 

		tokenize `row' 
		local nrows : word count `row' 
		if `rownum' { 
			mat `B' = `A'[`1', 1...] 
			local j = 2 
			while `j' <= `nrows' { 
                		mat `B' = `B' \ `A'[``j'', 1...]
				local j = `j' + 1 
			} 	
		} 
		else {
			mat `B' = `A'["`1'", 1...] 
			local j = 2 
			while `j' <= `nrows'  { 
                		mat `B' = `B' \ `A'["``j''", 1...]
				local j = `j' + 1 
			} 	
		} 
		mat `A' = `B' 	
        }
	
        mat `m2' = `A'
end
program define matewm
*! 1.0.1 NJC 15 June 1999 STB-50 dm59
* 1.0.0  NJC 21 July 1998
    version 5.0
    parse "`*'", parse(" ,")
    if "`3'" == "" | "`3'" == "," {
        di in r "invalid syntax"
        exit 198
    }

    matchk `1'
    local A "`1'"
    matchk `2'
    local B "`2'"
    matcfa `A' `B'
    local nr = rowsof(matrix(`A'))
    local nc = colsof(matrix(`A'))
    local C "`3'"
    mac shift 3
    local options "Format(str)"
    parse "`*'"

    tempname D
    mat `D' = J(`nr',`nc',1)
    local i 1
    while `i' <= `nr' {
        local j 1
        while `j' <= `nc' {
            mat `D'[`i',`j'] = `A'[`i',`j'] * `B'[`i',`j']
            local j = `j' + 1
        }
        local i = `i' + 1
    }

    if "`format'" == "" { local format "%9.3f" }
    mat `C' = `D' /* allows overwriting of either `A' or `B' */
    mat li `C', format(`format')
end
*! 1.0.0 NJC 19 July 1998    STB-50 dm69
program def matcfa
* matrices conformable for addition?
* matcfa `1' `2'
    version 5.0
    if "`1'" == "" | "`2'" == "" | "`3'" != "" {
        di in r "invalid syntax"
        exit 198
    }
    tempname C
    mat `C' = `1' + `2'
end
*! 1.0.0 NJC 5 July 1998    STB-50 dm69
program def matchk
* matrix?
* matchk `1'
    version 5.0
    if "`1'" == "" | "`2'" != "" {
        di in r "invalid syntax"
        exit 198
    }
    tempname C
    mat `C' = `1'
end

mata:
void zcalc(string scalar newvarname, string scalar cov_beta, string scalar xvarlist,
	string scalar tousevar)
{
	real colvector xbar
	// Form views of data in Mata
	V = st_matrix(cov_beta)
	xvars = tokens(xvarlist)
	st_view(X=., ., xvars, tousevar)
	n = rows(X)
	k = cols(X)
	xbar = J(k, 1, 0)
	for(j=1; j<=k; j++) {
		xbar[j, 1] = sum(X[., j])
	}
	xbar = xbar :/ n
	st_view(result=., ., st_addvar("float", newvarname), tousevar)
	for(i=1; i<=n; i++) {
		x1 = X[i, .]' - xbar
		result[i]  = sqrt(x1' * V * x1)
	}
}
end
