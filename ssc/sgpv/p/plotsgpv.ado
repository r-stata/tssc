*!Plot interval estimates according to Second-Generation p-value rankings
*!Author: Sven-Kristjan Bormann
*Based on the R-code for plotsgpv.R from the sgpv-package from https://github.com/weltybiostat/sgpv
*!Version 1.01 29.03.2020 : Added code for the cornercase that the ordering is set "sgpv", no variables as inputs are used and the matrix size exceeds c(matsize) -> uses Ben Jann's mm_cond() function (necessary code is included to avoid having the moremata-package installed ) -> not tested the code yet due to lack of test cases 
*Version 1.00 : Initial SSC release, no changes compared to the last Github version.
*Version 0.98a: The option xshow() has now the same effect as in the R-code -> it sets correctly the limit of the x-axis.
*				 Changed the default behaviour of the nullpt-option to be the same as in the R-code. 
*				 Now a line is only drawn if set, before it was to 0 as a default and always drawn.	
*				 Changed the default behaviour of xtitle() option -> now a default title is shown if not set
*				 Added do-file to make running the example in the help-file easier.
*Version 0.98 : Fixed nolegend-option -> disables now the legend as expected; minor updates to the help file and additional abbreviations for options
*				 Fixed nullcol-option -> now parses correctly color names and sets the color correctly, previous only the default color was used.
*				 Fixed intcol-option -> now parses correctly color names and  RGB-values
*				 Changed behaviour of intcol-option -> now three separate color options for easier providing custom colors,
*				 the change is necessary to make it possible (easier) to set the colors in the dialog box 
*Version 0.91 : Changed the handling of additional plotting options to avoid hard to understand error messages of the twoway-command.
*				Corrected minor errors in the documentation
*Version 0.90 : Initial Github release


program define plotsgpv, sortpreserve
version 12.0
syntax [if] [in] ,  estlo(string) esthi(string) nulllo(string) nullhi(string)  /// 
[SETOrder(string) Xshow(string) NULLCol(string asis) intcol1(string asis) intcol2(string asis) intcol3(string asis)	 ///
	 noPLOTY_axis noPLOTX_axis	nullpt(string) noOUTlinezone Title(string) /// 
	XTitle(string) YTitle(string) noLEGend nomata noshow replace TWOway_opt(string asis) ] 


***Some default values : Color settings -> translated R-colors into RGB for Stata -> Not sure how to install the colours in Stata for easier referencing.
local firebrick3 205 38 38
local cornflowerblue 100 149 237
local darkslateblue 72 61 139


*local intcoldefault firebrick3 cornflowerblue  darkslateblue 
local nullcoldefault 208 216 232
***Input parsing
*Need additional checks and conversions of matrix names  to work with the example in the R-code
if `:word count `nullhi'' != `: word count `nulllo''{
	disp as error `" Options "nullhi" and "nulllo" are of different length. "'
	exit 198
}

if `:word count `esthi'' != `: word count `estlo''{
	disp as error `" Options "esthi"' and "estlo" are of different length. "'
	exit 198
}

if `:word count `nullhi'' !=  1 |`: word count `nulllo'' !=1{
	disp as error `" Options "nulllo" and "nullhi" must be only one number or expression. "'
	exit 198
}
***Further input parsing
*Not sure how to parse matrices as input for esthi and estlo

if `:word count `esthi''==1{
	capture confirm numeric variable `esthi' `estlo'
	if !_rc{
		local varsfound 1
	}
	else{
		local varsfound 0
	}

}
*Set order of results -> Default behaviour: No ordering if nothing set
if "`setorder'"!="" & "`setorder'"!="sgpv"{
	capture confirm variable `setorder'
	if _rc{
		disp as error `"No variables found in option 'setorder'. Only variable names or "sgpv" are allowed values. "'
		exit 198
	}
	else local setorder_var `setorder' // Indicate that variable for sorting got found -> currently needed due to somewhat confusing handling of the setorder option
}

*How much to show
if "`xshow'"!=""{ 
	local xshow = real("`xshow'")
}
else local xshow = _N

if "`if'"!=""{
	local if  `if' & \`x'<=`xshow'   //Don't expand x because the variable will be defined only later -> maybe place this macro somewhere else
}
else local if if \`x'<=`xshow'

**Other graphing options

*Color settings

*Change of the color logic compared to R-code
if `"`intcol1'"'==""{ // firebrick3 for SGPV = 0
	local intcol1 `firebrick3' 
}
if `"`intcol2'"'==""{ // cornflowerblue for 0 < SGPV < 1
	local intcol2 `cornflowerblue' 
}

if `"`intcol3'"'==""{ // darkslateblue for SGPV = 1
	local intcol3 `darkslateblue'
}


if `"`nullcol'"'==""{
	local nullcol `nullcoldefault'
}
	
	**** Compute SGPVs for plotting
	tempname sgpvs sgpvcombo
	tempvar sgpvcomb x nlo nhi
	if `varsfound'==1{
		sgpvalue, estlo(`estlo') esthi(`esthi') nulllo(`nulllo') nullhi(`nullhi') nomata `replace' `noshow'
		if ("`setorder'"=="sgpv") gen `sgpvcomb' = cond(pdelta==0,-dg,pdelta )
	}
	else if `varsfound'==0{ // Not correct yet
			sgpvalue, estlo(`estlo') esthi(`esthi') nulllo(`nulllo') nullhi(`nullhi') `nomata' `replace' //Nomata option may not be useful, will fail if nomata and c(matsize) < rows of esthi or estlo -> how test these cases?
			mat `sgpvs' = r(results)
			if ("`sortorder'"=="sgpv"){
				if `=rowsof(`sgpvs')'<=c(matsize){				
					mat `sgpvcombo' = J(`=rowsof(`sgpvs')',1,.) 
					mat colnames `sgpvcombo' = "sgpvcombo"
					forvalues i=1/`=rowsof(`sgpvs')'{ // Only needed if sorting is set to sgpv
						if `sgpvs'[`i',1]==0{
							mat `sgpvcombo'[`i',1]=-`=`sgpvs'[`i',2]'
						}
						else{
							mat `sgpvcombo'[`i',1]=`=`sgpvs'[`i',1]'
						}
					
					}
				}
				else if `=rowsof(`sgpvs')'>c(matsize){ //Not tested yet -> need test case
					*capture findfile lmoremata.mlib
					*if _rc qui ssc install moremata, replace
					mata: sgpv = st_matrix("`sgpvs'") //Transfer matrix to mata
					mata: sgpvcombo = J(rows(sgpv),1.)
					mata: sgpvcombo = mm_cond(sgpv:==0,-sgpv[.,2],sgpv[.,1]) // Use Ben Jann's mm_cond as a shortcut
					mata: st_matrix("`sgpvcombo'",sgpvcombo)
					mat colnames `sgpvcombo' = "sgpvcombo"
				}
			}
	}

	*Convert matrix to variables -> directly plotting of matrices not possible
	preserve
	*Prepare matrix for conversion
	if (`varsfound'==0 & "`setorder'"=="sgpv") svmat `sgpvcombo' ,names(col)
	
	*Sort dataset
	if "`setorder'"=="sgpv"{ 
		if `varsfound'==0 local order sgpvcombo
		if `varsfound'==1 local order \`sgpvcomb'
	
	}
	if "`order'"!="" sort `order'
	else if "`setorder_var'"!="" sort `setorder_var'
	gen `x'=_n
	*Define default title of x-axis
	if "`setorder'"!="" local xtitlevar `"`setorder'"'
	else if "`setorder_var'"!="" local xtitlevar `"`setorder_var'"'
	else if	("`setorder'"=="" & "`setorder_var'"=="") local xtitlevar original ordering
	
	label variable `x' "Ranking according to `xtitlevar'"
	gen `nhi' = `nullhi'
	gen `nlo' = `nulllo'
	***Set up graphs

	*Null interval
	local nullint (rarea `nlo' `nhi' `x', sort lcolor("`nullcol'") fcolor("`nullcol'"))
	
	* Intervals where SGPV==0
	local sgpv0  (rbar `estlo' `esthi' `x' if pdelta==0 & dg!=., sort lcolor("`intcol1'") fcolor("`intcol1'"))
	
	
	* Intervals where 0<SGPV<1
	local sgpv01 (rbar `estlo' `esthi' `x' if pdelta<1 & dg==., sort lcolor("`intcol2'") fcolor("`intcol2'"))

	
	* Intervals where SGPV==1
	local sgpv1 (rbar `estlo' `esthi' `x' if pdelta==1 & dg==., sort lcolor("`intcol3'") fcolor("`intcol3'"))

	*Detail indifference zone
	if "`nullpt'"!=""{
		local ynullpt yline(`=real("`nullpt'")', lpattern(dash))
	}
	

	if "`outlinezone'"!="nooutlinezone"{
		local ynulllo yline(`nulllo', lcolor(white))
		local ynullhi yline(`nullhi', lcolor(white))
	}
	*Turning off axis	
	if "`ploty_axis'"=="noploty_axis" local yaxis yscale(off)
	if "`plotx_axis'"=="noplotx_axis" local xaxis xscale(off)
	
	*Legend
	if "`legend'"!="nolegend"{
	 local sgpvlegend	legend(on order(1 "Interval Null" 2 "0 < p <1"  3 "p = 1"  4 "p = 0")  position(1) ring(0) cols(1) symy(*0.25) region(lpattern(blank))) // Not all settings in R-code are possible in Stata
	}
	else if "`legend'"=="nolegend"{
		local sgpvlegend legend(off)
	}	

	*Setting xlabel limit according to xshow -> the ticks are multiples of 10, assuming a large number of inputs
	local xlabel xlabel(0(`=10^(floor(log10(`xshow')))')`xshow')
	
	***Plot: Set up the twoway plot
	twoway `nullint' `sgpv01' `sgpv1' `sgpv0' `if'  `in'  , title(`title') xtitle(`xtitle') ytitle(`ytitle') `ynullhi' `ynulllo' `ynullpt' `sgpvlegend' `xaxis' `yaxis' `xlabel'  `twoway_opt'
	
	restore
end

* Included this code to remove the requirement for having the moremata package installed
*! mm_cond.mata
*! version 1.0.0  29feb2008  Ben Jann
version 9.2
mata:

transmorphic matrix mm_cond(real matrix x, transmorphic matrix y, transmorphic matrix z)
{
        transmorphic matrix res
        real scalar r, R, c, C
        transmorphic scalar rx, cx, ry, cy, rz, cz

        if (eltype(y) != eltype(z)) _error(3250)
        R = max((rows(x),rows(y),rows(z)))
        C = max((cols(x),cols(y),cols(z)))
        rx = (rows(x)==1 ? &1 : (rows(x)<R ? _error(3200) : &r))
        cx = (cols(x)==1 ? &1 : (cols(x)<C ? _error(3200) : &c))
        ry = (rows(y)==1 ? &1 : (rows(y)<R ? _error(3200) : &r))
        cy = (cols(y)==1 ? &1 : (cols(y)<C ? _error(3200) : &c))
        rz = (rows(z)==1 ? &1 : (rows(z)<R ? _error(3200) : &r))
        cz = (cols(z)==1 ? &1 : (cols(z)<C ? _error(3200) : &c))
        res = J(R,C, missingof(y))
        for (r=1;r<=R;r++) {
                for (c=1;c<=C;c++) {
                        res[r,c] = (x[*rx,*cx] ? y[*ry,*cy] : z[*rz,*cz])
                }
        }
        return(res)
}

end

