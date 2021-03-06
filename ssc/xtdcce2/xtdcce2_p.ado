/*
predict for xtdcce2
Requires xtdcce2 version 1.2
Changelog
16.10.2017 - fixed bug in stdp
08.11.2017 - added replace (option for Achim Ahrens)
		   - fixed bug in option xb
August 2018- added ardl and long run function
		   - added * to drop to all to overwrite cofficients etc.
Oct   2018 - changed xtdcce2133 to xtdcce2 in line 37
13.02.2019 - fixed bug if option xtpmgnames used and partilling out
*/
*capture program drop xtdcce2_p
program define xtdcce2_p
	syntax anything [in] [if] [, replace *]
	*local options `*'
	if "`replace'" != "" {
		local predvar = word("`anything'",`=wordcount("`anything'")') 
		capture drop `predvar'*
		if _rc == 0 {
			display "Variable `predvar' replaced"
		}
	}
	xtdcce2_p_int `anything' `if' `in', `options'
end

capture program drop xtdcce2_p_int
program define xtdcce2_p_int 
	syntax newvarname(max=1 generate) [in] [if] , [Residuals xb COEFFicient stdp se partial CFResiduals xb2 ]
	
	* marksample for in if of predict command; does not take e(sample) into account,
	* add additional variable smpl. will be used for calculation of cross-sectional averages and partialling out
	marksample touse, novarlist
	tempvar smpl
	gen byte `smpl' = 1
	
	if "`e(cmd)'" != "xtdcce2" {
		display as error "Only after xtdcce2, last command is `e(cmd)'"
		exit
	}
	
	local nopts : word count `residuals' `xb' `xb2' `coefficient' `stdp' `se' `partial' `cfresiduals'
    if `nopts' >1 {
        display "{err}only one statistic may be specified"
        exit 498
    }
	else if `nopts' == 0 {
		display in gr "(option xb assumed; fitted values; common factors partialled out)"
		local xb "xb"
	}

	
	if "`xb2'" == "xb2" {
		display in gr "(option xb2 assumed; fitted values; common factors included)"
	}
	
	
	**For residuals including common factors, first predict xb, then subtract them from Y
	if "`cfresiduals'" != "" {
		local xb2 "xb2"
	}
	
	** Which inverter
	local useqr = e(useqr)
	
	qui{
		tsset

		local newvar `varlist'
		
		tempvar tvar idvar  
		
			
		if "`e(p_if)'" != "" {
			*local p_if "& `e(p_if)'"
			replace `smpl' = `smpl' * (`e(p_if)')
		}
		if "`e(p_in)'" != "" {
			*local p_in "in `e(p_in)'"
			replace `smpl' = `smpl' * (`e(p_in)')
		}		
		tsset
		local d_idvar `r(panelvar)'
		local d_tvar `r(timevar)'
		sort `d_idvar' `d_tvar' 
		egen `idvar' = group(`d_idvar')
		egen `tvar' = group(`d_tvar')
		tsset `idvar' `tvar'
		
		local lhs `e(depvar)'
		local mg_vars  `e(p_mg_vars)'
		local mg_vars : list uniq mg_vars
		local pooled_vars `e(p_pooled_vars)'
		local cr_vars `e(p_cr_vars)' 
		local cr_options "`e(cr_options)'"		
		local lr_vars "`e(lr)'"	
		
		
		** check if constant in lr_vars
		local cons_lr = strmatch("`lr_vars'","*_cons*")
		
		** Remove constant from varlists
		if strmatch("`pooled_vars' `mg_vars' `cr_vars' `lr_vars'","*_cons*") == 1 {
			*tempvar trend
			*gen double `trend' = `tvar'
			local pooled_vars = subinword("`pooled_vars'","_cons","",.)
			local mg_vars = subinword("`mg_vars'","_cons","",.)
			local cr_vars = subinword("`cr_vars'","_cons","",.)
			local lr_vars = subinword("`lr_vars'","_cons","",.)
		}		
		
		** if xtpmgnames used, rename ec into first of LR. Check all varlists and change names in ebi and evi
		
		tempname ebi evi
		matrix `ebi' = e(bi)
		matrix `evi' = e(Vi)
		local xtpmgnames = 0
		local lr_options "`e(lr_options)'"
		
		if strmatch("`lr_options'","*xtpmgnames*") == 1 {
			local xtpmgnames = 1
			local lr1 "`e(p_lr_1)'"
			local pooled_vars = subinword("`pooled_vars'","ec","`lr1'",.)
			local mg_vars = subinword("`mg_vars'","ec","`lr1'",.)
			local cr_vars = subinword("`cr_vars'","ec","`lr1'",.)
			local lr_vars = subinword("`lr_vars'","ec","`lr1'",.)
			
			local coln : colnames `ebi'
			local coln = subinword("`coln'","ec","`lr1'",.)
			matrix colnames `ebi' = `coln'
			local coln : colnames `evi'
			local coln = subinword("`coln'","ec","`lr1'",.)
			matrix colnames `evi' = `coln'
			matrix rownames `evi' = `coln'
			
		}
		
		local o_lhs `lhs'
		local o_mg_vars `mg_vars'
		local o_pooled_vars `pooled_vars'
		local o_lr_vars "`lr_vars'"		
		
		
		** trend
		if strmatch("`pooled_vars' `mg_vars' `cr_vars' `lr_vars'","*trend*") == 1 {
			tempvar trend
			gen double `trend' = `tvar'
			local pooled_vars = subinword("`pooled_vars'","trend","`trend'",.)
			local mg_vars = subinword("`mg_vars'","trend","`trend'",.)
			local cr_vars = subinword("`cr_vars'","trend","`trend'",.)
			local lr_vars = subinword("`lr_vars'","trend","`trend'",.) 
		}
		
		
		local cr_lags = e(cr_lags)
		
		local constant_type = `e(constant_type)'
		
		**add long coefficients if ardl or ecm (then ec term) to mg or pooled
		** if pooled, then variable will be in pooled
		** if MG, then variable will not be in MG
		** for ecm: add only ec term
		** for ardl: add short run coeff of lr vars (not included in mg_vars)
		if "`lr_vars'" != "" {
			*local first "`e(p_lr_1)'"
			local mg_lr1_vars "`lr_vars'"
			local mg_lr1_vars : list mg_lr1_vars - pooled_vars	
			*gettoken first rest: mg_lr1_vars
			local o_mg_vars "`o_mg_vars' `mg_lr1_vars'"
			local mg_vars "`mg_vars' `mg_lr1_vars'"
			
			mata st_local("lr_label",invtokens(strtoname(tokens("`lr_vars'"))))

			if strmatch("`lr_options'","*ardl*") == 1 {
				tsrevar `lr_vars' , list
				local ardl_lr "`r(varlist)'"
				tsrevar `pooled' , list
				local ardl_pooled "`r(varlist)'"
				
				*local ardl_mg : list ardl_lr - ardl_pooled
				*local ardl_pooled : list ardl_lr & ardl_pooled
				
				local ardl_pooled "`e(lr_pooled)'"
				local ardl_mg "`e(lr_mg)'"
				
				*mata st_local("ardl_mg",invtokens("lr_":+strtoname(tokens("`ardl_mg'"))))
				*mata st_local("ardl_pooled",invtokens("lr_":+strtoname(tokens("`ardl_pooled'"))))
				local lr_label "`ardl_mg' `ardl_pooled'"
			}
		}		
		*** Markout here will all variables
		markout `smpl' `lhs' `mg_vars' `pooled_vars'
				
		**here add lr_vars
		local unique_vars `pooled_vars' `mg_vars' `cr_vars' `lhs' `lr_vars'
		local unique_vars : list uniq unique_vars
		
		***check for ts vars. tsrevar creates tempvars, then loop over remaining vars to create tempvars
	
		fvrevar `unique_vars' 
		local no_temp_vars `r(varlist)'
		local temp_vars : list unique_vars - no_temp_vars
		local no_temp_vars : list unique_vars & no_temp_vars
				
		*loop over ts vars and create temp var 
		* as over variables, subinword can be used
		foreach var in `temp_vars' {
			fvrevar `var'
			foreach liste in pooled_vars mg_vars cr_vars lhs lr_vars {
					local `liste' = subinword("``liste''","`var'","`r(varlist)'",.)
			}
		}
		
		*loop over non ts vars and create tempvar
		foreach var in `no_temp_vars' {
			tempvar `var'
			gen double ``var'' = `var' /*if `touse'*/
			foreach liste in pooled_vars mg_vars cr_vars lhs {
					local `liste' = subinword("``liste''","`var'","``var''",.)
			}
		}

		if "`e(bias_correction)'" == "recursive mean correction" {
			tempvar s_mean
			gen `s_mean' = 0
			local r_varlist `lhs' `mg_vars' `cr_vars' `pooled_vars' 
			local r_varlist: list uniq r_varlist
			local r_varlist: list r_varlist - `constant'

			foreach var in `r_varlist' {
				by `idvar' (`tvar'), sort: replace `s_mean' = sum(`var'[_n-1]) / (`tvar'-1) if `smpl' /*was touse*/
				replace `s_mean' = 0 if `s_mean' == . 
				replace `var' = `var' - `s_mean'  
			}
			replace `s_mean' = 0
			sort `idvar' `tvar'
		}
		sum `idvar' if `smpl' /* `touse'*/ , meanonly
		local N_g = r(max)
		*get country list
		forvalues i = 1(1)`N_g' {
			local ctry_list `ctry_list' `i'
		}
		
		**Constant types. If 0, 2, do nothing
		** if lists change, make sure to change o_ varlists to make sure order is correct.
		*if 1, then add to cr_list, but at a later stage. now only creation of constant
		if `constant_type' == 1 {
			tempvar constant
			gen double `constant' = 1
			*local cr_vars "`cr_vars' `constant'"
		}
		*if 3 then add to mg_vars
		else if `constant_type' == 3 {
			tempvar constant
			gen double `constant' = 1
			local mg_vars "`mg_vars' `constant'"
			local o_mg_vars = subinword("`o_mg_vars'","_cons","",.)
			local o_mg_vars "`o_mg_vars' _cons"
		}		
		** homogenous, 5 and 5
		else if `constant_type' == 5 | `constant_type' == 4 {
			tempvar constant
			gen double `constant' = 1
			local pooled_vars "`pooled_vars' `constant'"
			local o_pooled_vars = subinword("`o_pooled_vars'","_cons","",.)
			local o_pooled_vars "`o_pooled_vars' _cons"
			*local pooled_vars = subinword("`pooled_vars'","_cons","",.)
		}
		
		if `cons_lr' == 1  {
			local lr_vars "`lr_vars' `constant'"
			local o_lr_vars "`o_lr_vars' _cons"
		}

		** if IV, then partial out instruments
		if "`e(insts)'" != "" {
				foreach var in `e(insts)' {
					local varn = strtoname("`var'")
					tempvar `varn'
					gen double ``varn'' = `var' /*if `touse'*/
					local exo_cr "`exo_cr' ``varn'' 0"
				}
			}
		
		
		*create CR Lags
		if ("`cr_vars'" != "" & "`xb'" == "") | `constant_type' == 1 | "`e(insts)'" != ""  {
			tempvar cr_mean
			
			**check if cr_options include "(", if so, then ok, if not, build new with var#1 (#cr lags), var#2 (#cr lags)....
			if strmatch("`cr_options'","*(*") == 0 | strmatch("`cr_options'","*)*") == 0  {
				local cr_options 
				foreach var in `cr_vars' {
					local cr_options "`cr_options' `var' `cr_lags'"
				}
			}
			else {
				*remove any "(" or ")"
				local cr_options = subinstr("`cr_options'",")"," ",.)
				local cr_options = subinstr("`cr_options'","("," ",.)
			}
			if `constant_type' == 1 {
				local cr_options "`cr_options' `constant' 0"
				
			}
			
			local cr_options "`cr_options' `exo_cr'"
		
			sort `idvar' `tvar'
			
			tokenize "`cr_options'" 
			while "`1'" != "" {
				local var `1'
				local lags_i `2'
				macro shift
				macro shift
				** check if variable has ts operators
				tsrevar `var'
				local var `r(varlist)'
				
				by `tvar'  , sort: egen double `cr_mean' = mean(`var') if `smpl' /*was touse*/
				forvalues lag=0(1)`lags_i' {
					sort `idvar' `tvar'
					tempvar L`lag'_m_`var'
					gen double `L`lag'_m_`var'' = L`lag'.`cr_mean' if `smpl'   /*was touse*/
					local clist1  `clist1'  `L`lag'_m_`var'' 
				}
				drop `cr_mean' 
			}
			markout `smpl' `lhs' `pooled_vars' `mg_vars' `clist1'
			tempvar touse_ctry
			tempname mrk
			local mata_drop `mata_drop' `mrk'
			gen `touse_ctry' = 0
			sort `idvar' `tvar'	
			
			foreach ctry in `ctry_list' {
				qui replace `touse_ctry' =  1 if `smpl'  & `ctry' == `idvar' 
				mata xtdcce_m_partialout("`lhs' `pooled_vars' `mg_vars'","`clist1'","`touse_ctry'",`useqr',`mrk'=.)
				qui replace `touse_ctry' =  0				
			}
			
		}

		*Markout again to drop missings from partialout. put e(sample) in place (not needed for mean group)
		markout `touse' `lhs' `pooled_vars' `mg_vars'		
		*replace `touse' = `touse' * e(sample)
		**calculate coefficients
		tempname coeff xbc
		matrix `coeff' = `ebi'
		if "`se'" == "se" {
			matrix `coeff' = `evi'
			mata st_matrix("`coeff'",sqrt(diagonal(st_matrix("`coeff'")))')
			local coln : colnames `evi'
			matrix colnames `coeff' = `coln'
		}
		gen double `xbc' = 0 if `touse'
		local i = 1
		local lr_vars_adj "`lr_vars'"
		foreach var in `pooled_vars' `ardl_pooled' {
			tempvar c_`var'
			local o_var = word("`o_pooled_vars' `ardl_pooled'",`i')
			gen double `c_`var'' = `coeff'[1,colnumb(`coeff',"`o_var'")]
			local lr_vars_adj = subinword("`lr_vars_adj'","`o_var'","`var'",.)
			local i = `i' + 1	
		}
		local i = 1
		foreach var in `mg_vars' `ardl_mg' {
			tempvar c_`var'
			gen double `c_`var'' = .
			local o_var = word("`o_mg_vars' `ardl_mg'",`i')
			local lr_vars_adj = subinword("`lr_vars_adj'","`o_var'","`var'",.)
			foreach ctry in `ctry_list' {
				replace `c_`var'' = `coeff'[1,colnumb(`coeff',"`o_var'_`ctry'")] if `idvar' == `ctry' & `touse'
			}
			local i = `i' + 1
		}
		*** LR part
		*** for ECM: correct coefficients back to original one, only if option xb or residuals. Do nothing for ARDL
		if "`lr_vars'" != "" {
			if strmatch("`lr_options'","*ardl*") == 0 {
				if strmatch("`options'","*nodivide*") == 0 & "`residuals'`xb'" != ""  {
					gettoken first rest : lr_vars_adj					
					foreach var in `rest' {						
						replace `c_`var'' = -`c_`var'' * `c_`first'' if `touse'
					}
				}
				
			}
		}
		if "`xb2'" == "" {  
			foreach var in `mg_vars' `pooled_vars' {
				replace `xbc' = `xbc' + `c_`var'' * `var'  if `touse'
			}
		}
		else {
			local j = 1
			foreach var in `o_mg_vars' `o_pooled_vars' {			
				local ji = word("`mg_vars' `pooled_vars'",`j')
				replace `xbc' = `xbc' + `c_`ji'' * `var'  if `touse'
				local j = `j' + 1
			}
		}
		
		if "`xb'" == "xb" | "`xb2'" == "xb2" {
			replace `newvar' = `xbc'   if `touse'
			label var `newvar' "xb"
		}
		if "`stdp'" == "stdp" {
			replace `newvar' = `xbc'   if `touse'
			label var `newvar' "stdp"
		}
		if "`residuals'" == "residuals" {
			replace `newvar' = `lhs' - `xbc' if `touse'
			label var `newvar' "Residuals"
		}
		if "`coefficient'" == "coefficient" | "`se'" == "se" {
			drop `newvar'
			if "`coefficient'" == "coefficient" {
				local coeffse "Coeff" 
			}
			else {
				local coeffse "SE" 
			}
			local i = 1
			foreach var in `pooled_vars' `ardl_pooled' {
				local lrsr ""
				local o_var = word("`o_pooled_vars' `ardl_pooled'",`i')
				local o_var = strtoname("`o_var'")				
				gen double `newvar'_`o_var' = `c_`var'' if `touse'
				if "`lr_vars'" != "" {
					local lrsr " (Short Run)"
					if strmatch("`lr_label'","*`o_var'*") == 1 {
						local lrsr " (Long Run)"
					}
				}
				label var `newvar'_`o_var' "Est. `coeffse' for `o_var'`lrsr'"
				local i = `i' + 1
			}
			local i = 1
			foreach var in `mg_vars' `ardl_mg' {
				local lrsr ""
				local o_var = word("`o_mg_vars' `ardl_mg' ",`i')
				local o_var = strtoname("`o_var'")
				gen double `newvar'_`o_var' = `c_`var'' if `touse'
				if "`lr_vars'" != "" {
					local lrsr " (Short Run)"
					if strmatch("`lr_label'","*`o_var'*") == 1 {
						local lrsr " (Long Run)"
					}
				}
				label var `newvar'_`o_var' "Est. `coeffse' for `o_var'`lrsr'"
				local i = `i' + 1
			}
			foreach var in `ardl_lrlist_tmp' {
				gen double `newvar'_`o_var' = `c_`var'' if `touse'
			}
		}
		if "`stdp'" == "stdp" {
			local v_order: colnames `evi'
			foreach var in `o_mg_vars' {
				foreach i in `ctry_list' { 
					local o_mg_vars_id `o_mg_vars_id' `var'_`i'
				}			
			}
			local o_full_id `o_mg_vars_id' `o_pooled_vars'
			tempvar idt
			gen `idt' = _n
			preserve  
				foreach var in `mg_vars' {
					qui separate `var' if `touse' , by(`idvar')
					local mg_vars_id `mg_vars_id' `r(varlist)'
					recode `r(varlist)' (missing = 0) if `touse'
				}
				foreach var in `v_order' {
					local pos : list posof `"`var'"' in o_full_id
					local tmp = word("`mg_vars_id' `pooled_vars'",`pos')
					local v_order_n `v_order_n' `tmp'
				}			
				tempname m_V m_x m_h
				putmata `m_x' = (`v_order_n') `idt' if `touse' , replace
				mata `m_V' = st_matrix("`evi'")
				mata `newvar' = `m_x'*`m_V'*`m_x''
				mata `newvar'  = sqrt(diagonal(`newvar'))
			restore
			drop `newvar'
			getmata `newvar' , id(`idt'=`idt')
			mata mata drop `m_V' `m_x' `newvar' `idt'
			
		}
		if "`partial'" == "partial" {
			drop `newvar'
			local o_list  `o_lhs' `o_pooled_vars' `o_mg_vars' 
			local i = 1
			foreach var in `lhs' `pooled_vars' `mg_vars' {
				*Get current temp varname
				local tmp = word("`o_list'",`i')
				local tmp = subinstr("`tmp'",".","_",.)
				gen double `newvar'_`tmp' = `var'
				label var `newvar'_`tmp' "`tmp' partialled out"
				local i = `i' + 1
			}
		}
		if "`cfresiduals'" != "" {
			replace `newvar' = `o_lhs' - `newvar' if `touse'
			label var `newvar' "Residuals + cf"
		}
		
		if `xtpmgnames' == 1 {
			capture rename `newvar'_`=strtoname("`lr1'")' `newvar'_ec
		}	
		
		tsset `d_idvar' `d_tvar'
	} 
end

*** Partial Out Program
** quadcross automatically removes missing values and therefore only uses (and updates) entries without missing values
*** Partial Out Program
** quadcross automatically removes missing values and therefore only uses (and updates) entries without missing values
** X1 variable which is partialled out
capture mata mata drop xtdcce_m_partialout()
mata:
	function xtdcce_m_partialout (  string scalar X2_n,
									string scalar X1_n, 
									string scalar touse,
									real scalar useold,
									| real scalar rk)
	{
		"start partial out"
		real matrix X1
		real matrix X2
		
		st_view(X2,.,tokens(X2_n),touse)
		st_view(X1,.,tokens(X1_n),touse)
		X1X1 = quadcross(X1,X1)
		X1X2 = quadcross(X1,X2)
		"x1x1 and x1x2 calculated"
		//Get rank
		X2[.,.] = (X2 - X1*m_xtdcce_solver(X1X1,X1X2,useold,rk))
		"partial out done"
		"rank condition:"
		rk
	}
end

// Mata utility for sequential use of solvers
// Default is cholesky;
// if that fails, use QR;
// if overridden, use QR.
// By Mark Schaffer 2015
capture mata mata drop cholqrsolve()
mata:
	function cholqrsolve (  numeric matrix A,
							numeric matrix B,
						  | real scalar useqr)
	{
			
			if (args()==2) useqr = 0
			
			real matrix C

			if (!useqr) {
					C = cholsolve(A, B)
					if (C[1,1]==.) {
							C = qrsolve(A, B)
					}
			}
			else {
					C = qrsolve(A, B)
			}
			return(C)

	};
end


capture mata mata drop cholqrinv()
mata:
	function cholqrinv (  numeric matrix A,
						  | real scalar useqr)
	{
			if (args()==2) useqr = 0

			real matrix C

			if (!useqr) {
					C = cholinv(A)
					if (C[1,1]==.) {
							C = qrinv(A)
					}
			}
			else {
					C = qrinv(A)
			}
			return(C)

	};
end

///Program for matrix inversion.
///Default is cholesky
///if not full rank use invsym (Stata standard) 
///and obtain columns to use
///options: 
///1. if columns are specified, force use invsym
///2. allow for old method (cholinv, if fails qrinv)
///output
///return: inverse
///indicator for rank (1x2, rank and rows), which method used and variables used

capture mata mata drop m_xtdcce_inverter()
mata:
	function m_xtdcce_inverter(	numeric matrix A,
								| real scalar useold,
								real matrix rank,
								real matrix coln,
								string scalar method)
								
	{
		real matrix C
		
		if (args() == 1) {
			useold = 0
			coln = 0
		}
		if (args() == 2){
			coln = 0
		}
		if (useold == 1) {			
			C = cholqrinv(A)
			qrinv(A,rank)
			method = "cholqr"		
		}
		else {
			if (coln[1,1] == 0) {
				/// calculate rank seperate. if A is not full rank, cholinv still produces results
				C = invsym(A)
				rank = rows(C)-diag0cnt(C)
				
				if (rank < rows(A)) {	
					/// not full rank, use invsym
					method = "invsym"
					coln = selectindex(colsum(A1:==0):==rows(A1):==0)			
				}
				else {
					/// full rank use cholsolve
					C = cholinv(A,B)
					method = "chol"
				}				
			}
			else {
				C = invsym(A,coln)
				rank = rows(C)-diag0cnt(C)
				method = "invsym"
			}			
		}
		rank = (rank, rows(C))
		return(C)
	}

end
/// same as inverter, rank is for matrix A (which is inverted) 
capture mata mata drop m_xtdcce_solver()
mata:
	function m_xtdcce_solver(	numeric matrix A,
								numeric matrix B,
								| real scalar useold,
								real matrix rank,
								real matrix coln,
								string scalar method)
								
	{
		real matrix C
		
		if (args() == 2) {
			useold = 0
			coln = 0
		}
		if (args() < 5){
			coln = 0
		}		

		if (useold == 1) {			
			C = cholqrsolve(A,B)
			qrinv(A,rank)
			method = "cholqr"
		}
		else {
			if (coln[1,1] == 0) {
				
				/// calculate rank seperate. if A is not full rank, cholsolve still produces results
				A1 = invsym(A)
				rank = rows(A1)-diag0cnt(A1)
				
				if (rank < rows(A)) {	
					/// not full rank, solve by hand
					C = A1 * B
					method = "invsym"
					coln = selectindex(colsum(A1:==0):==rows(A1):==0)			
				}
				else {
					/// full rank use cholsolve
					C = cholsolve(A,B)
					method = "chol"
					coln = 0
				}
			}
			else {
				/// coln is defined, use invsym on specified columns
				A1 = invsym(A,coln)
				C = A1 * B
				method = "invsym"
				rank = rows(A1)-diag0cnt(A1)
			}			
		}
		rank = (rank, rows(A1))
		return(C)		
	}

end
