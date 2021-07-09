*! N. Orsini v.1.0.1 6aug19 fixed a missing parenthesis with 6 and 7 knots
*! N.Orsini v.1.0.0 2nov09   
 
capture program drop xbrcspline
program xbrcspline
version 10.0
syntax anything ,  MATKnots(string) Values(numlist) [ Reference(string)  Level(int $S_level) Format(string) ///
LSPlines eform  GENerate(namelist max=4)]

	local cilevel = `level'

	if "`format'" == "" 	local format = "%3.2fc"
	else local format = "`format'" 

	if `level' <10 | `level'>99 { 
			di in red "level() invalid"
			exit 198
	}   
	
		local xname `anything'
            local wc : word count `anything'

		local rowname : rownames `matknots'
		local colnames : colnames `matknots'

            local nk : word count `colnames' 
		local km1 = `nk' - 1

	 	qui su `rowname',d
		if "`reference'" == "" local refx `=r(min)'
		else local refx = `reference'
		local `rowname'min 
		
	if `wc' != 1 {
		di as error "write only the stub specified with mkspline (restricted cubic spline) command" 
		exit 198
	}

			
	      forvalues i=1/`nk' {
				local t`i' = `matknots'[1,`i']
			}			
	
		local r 1

	      forvalues i=1/`km1' {
				tempname v_`xname'`i'
				qui gen `v_`xname'`i'' = . 
			}	

	      forvalues i=1/`nk' {
				tempname _Xm`i'p
				qui gen `_Xm`i'p' = .
			}		

tempname xb lo hi rr lb ub 

foreach anyx of local values {
            
            qui replace `v_`xname'1' = `anyx' in `r'

		local j = 1

		while `j' <= `nk' {
			qui replace `_Xm`j'p' = max(0, `anyx' - `t`j'')
			local j = `j'+1
		}


		local j = 1

		while `j' <= `nk' -2 {
			
			local jp1 = `j' + 1
			qui replace `v_`xname'`jp1'' = (`_Xm`j'p'^3 - (`_Xm`km1'p'^3)* ///
				(`t`nk''   - `t`j'')/(`t`nk'' - `t`km1'') ///
				+ (`_Xm`nk'p'^3  )*(`t`km1'' - `t`j'')/ ///
				(`t`nk'' - `t`km1'')) / (`t`nk'' - `t1')^2 in `r'

			local j = `j' + 1
		}

		local r = `r' + 1

}

	      forvalues i=1/`km1' {
				qui su `xname'`i' if `rowname' == float(`refx'), meanonly
				if r(N) != 0 {
							local refx`i' = r(mean)
				}
				else {
					di _n as error "change the referent value to an existing value of `rowname'. The default is the minimum."
					exit 198
				}
			}


			if `nk' == 3 {
				  qui predictnl `xb' = _b[`xname'1]*(`v_`xname'1'-`refx1')+_b[`xname'2]*(`v_`xname'2'-`refx2'), ci(`lo' `hi') level(`cilevel')  
			}
			else if `nk'== 4 {
				  qui predictnl `xb' =  _b[`xname'1]*(`v_`xname'1'-`refx1')+_b[`xname'2]*(`v_`xname'2'-`refx2')+ _b[`xname'3]*(`v_`xname'3'-`refx3'), ci(`lo' `hi') level(`cilevel')  
			}
			else if `nk'== 5 {
				 qui predictnl `xb' =  _b[`xname'1]*(`v_`xname'1'-`refx1')+ _b[`xname'2]*(`v_`xname'2'-`refx2')+ _b[`xname'3]*(`v_`xname'3'-`refx3')+_b[`xname'4]*(`v_`xname'4'-`refx4'), ci(`lo' `hi') level(`cilevel')  
			}
			else if `nk'== 6 {
				 qui predictnl `xb' = _b[`xname'1]*(`v_`xname'1'-`refx1')+ _b[`xname'2]*(`v_`xname'2'-`refx2')+ _b[`xname'3]*(`v_`xname'3'-`refx3')+_b[`xname'4]*(`v_`xname'4'-`refx4') +_b[`xname'5]*(`v_`xname'5'-`refx5'), ci(`lo' `hi')  level(`cilevel')  
			}
			else if `nk'== 7 {
				 qui predictnl `xb' =  _b[`xname'1]*(`v_`xname'1'-`refx1')+ _b[`xname'2]*(`v_`xname'2'-`refx2')+ _b[`xname'3]*(`v_`xname'3'-`refx3')+_b[`xname'4]*(`v_`xname'4'-`refx4') +_b[`xname'5]*(`v_`xname'5'-`refx5')+_b[`xname'6]*(`v_`xname'6'-`refx6'), ci(`lo' `hi')  level(`cilevel')  
			}
			else 	{
				display as error ///
				"Restricted cubic splines with `nk' knots at default values not implemented."
				display as error ///
				"Number of knots specified in nknots() must be between 3 and 7."
				error 498
			}

if "`eform'" != "" {
			quietly {
			gen `rr' = exp(`xb')
			gen `lb' = exp(`lo')
			gen `ub' = exp(`hi')
			char `rr'[varname] "exp(XB)"
			}
		}
	else {
		    qui gen `rr' = `xb'
			qui gen `lb' = `lo'
			qui gen `ub' = `hi'
			char `rr'[varname] "XB"
		}

			char `lb'[varname] "LB"
			char `ub'[varname] "UB"

	      forvalues i=1/`km1' {
				char `v_`xname'`i'' [varname] "`xname'`i'" 
			}	


format   `rr' `lb' `ub'  `format'
di _n as text "Reference value for `rowname' = " as res `refx'

if "`lsplines'" == "" {
				char `v_`xname'1'[varname] "`rowname'"
				list `v_`xname'1' `rr' `lb' `ub' in 1/`=`r'-1', clean noobs  subvarname
} 
else {

			if `nk' == 3 {
				format `v_`xname'1' `v_`xname'2' `format'
				list `v_`xname'1' `v_`xname'2' `rr' `lb' `ub' in 1/`=`r'-1', clean noobs  subvarname 
			}
			else if `nk'== 4 {
				format `v_`xname'1' `v_`xname'2' `v_`xname'3'  `format'
				list `v_`xname'1' `v_`xname'2' `v_`xname'3'  `rr' `lb' `ub' in 1/`=`r'-1', clean noobs  subvarname 
			}
			else if `nk'== 5 {
				format `v_`xname'1' `v_`xname'2' `v_`xname'3' `v_`xname'4' `format'
				list `v_`xname'1' `v_`xname'2' `v_`xname'3' `v_`xname'4'  `rr' `lb' `ub' in 1/`=`r'-1', clean noobs  subvarname 
			}
			else if `nk'== 6 {
				format `v_`xname'1' `v_`xname'2' `v_`xname'3' `v_`xname'4' `v_`xname'5' `format'
				list `v_`xname'1' `v_`xname'2' `v_`xname'3' `v_`xname'4'  `v_`xname'5' `rr' `lb' `ub' in 1/`=`r'-1', clean noobs  subvarname 
			}
			else if `nk'== 7 {
				format `v_`xname'1' `v_`xname'2' `v_`xname'3' `v_`xname'4' `v_`xname'5' `v_`xname'6'  `format'
				list `v_`xname'1' `v_`xname'2' `v_`xname'3' `v_`xname'4'  `v_`xname'5' `v_`xname'6'  `rr' `lb' `ub' in 1/`=`r'-1', clean noobs  subvarname 
			}

}

// Save new variables containing the displayed results

	if "`generate'" != "" {

		local listvarnames "`v_`xname'1' `rr' `lb' `ub'" 
		local nnv : word count `generate' 
		tokenize `generate'

		forv i = 1/`nnv' {	
				qui gen ``i'' = `: word `i' of `listvarnames''
		}
	}
end
