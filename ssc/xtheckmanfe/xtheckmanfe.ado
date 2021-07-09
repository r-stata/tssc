*Original code by Anastasia Semykina
*This version Modified by Fernando Rios-Avila
*adding instruments
* Tried to do asymptotic moments but was too difficult. Perhaps at some other time.

*capture program define  drop parseselection 
*capture program define  drop _xthck 
*capture program define  drop _xthckiv 
*capture program define  drop xtheckmanfe
*capture program define  drop myparse_endog

program define  myparse_endog, rclass
syntax anything, 
	local rest `anything'
	while "`rest'"!="" {
	   gettoken eqt rest: rest, match(nvu) parse("(")
	   if "`eqt'"!="" {
		  local cnt=`cnt'+1
		  local r`cnt' `eqt'
	   }
	}
	forvalues j=1/`cnt' {
		return local m`j' `r`j''
	}
return scalar cnt =`cnt'
end

program define  parseselection, rclass
	syntax anything(equalok)
	
	local equal=strrpos("`anything'","=")
	if `equal'==0  {
		local z2 `anything'
		}
	else if `equal'!=0  {
	    local sel2=subinstr("`anything'","="," ",.)
		tokenize `sel2'
		local y2 `1'
		macro shift
		local z2 `*'
	}	
	return local selvar  ="`y2'"
	return local xselvar ="`z2'"
end



*if `touse', y1(`y1') y2(`y2') z1(i.time#c.(`z1' `mn_var_z1')) x1(`x1' `mn_var_x1') time(`time')

program define  xtheckmanfe, eclass
	if replay() {
		if "`e(cmd)'"=="xtheckmanfe" {
			ereturn display
			exit
		}
		else {
			display in red "last extimates not found"
			exit 301
		}
	}
version 13
syntax varlist(fv) [if], SELECtion(str) [ ENDogenous(str) id(varname) time(varname) reps(integ 50) seed(str)]
 
** This version will be based on Semykina, but standard errors will be done using Bootstrap
** Step 1. Gather all variables of interest
	qui:capture which ftools
	if _rc==111 {
		display in red "The command requires " as result "ftools"
		display as text "You can install it using {stata ssc install ftools}"
		exit 111
	}
		
	capture:qui:drop _mn_*
	capture:qui:drop _sel_imr
*** This get main model and explanatory variables
    tokenize `varlist'
	local y1 `1'
	macro shift
	local x1 `*'

*** Need to parse Selection
	parseselection `selection'
	local y2 `r(selvar)'
	local z1 `r(xselvar)'
	
*** Need to parse Endogenous
	if "`endogenous'"!="" {
		parseselection `endogenous'
		local y3 `1'
		macro shift
		local z2 `*'
	}
*** sample def
	marksample touse , novarlist
	markout `touse' `x1' `y2' `z1' `y3' `z2' `id' `time', strok
	
 *** redefine smp
	if "`y2'"=="" {
		tempvar ss 
		qui:gen byte `ss'=`y1'!=.
		local y2 `ss'
	}
	
*** define id and time
	if ("`id'"!="" & "`time'"=="") | ("`id'"=="" & "`time'"!="") {
		display in red "Need to define id and time. Otherwise leave blank to use information from xtset"
		exit 1
	}
	else if ("`id'"=="" & "`time'"=="") {
		qui:xtset
		local id   `r(panelvar)'
		local time `r(timevar)'
		local isxtset = 1 
	}
 *** Generate variables for Probit. The Mundalk version
	** may consider doing this using myhdfe 
	* the model is defined as
	* y1 = xb+y3*g+e if y2==1
	* selection
	* y2 = xb+z1 +z2 
	* endogeneity
	* y3 = xb+z2 
	* main variables all Exogenous
	myhdfe `x1' if `touse', abs(`id')
		 local mn_var_x1  `r(mn_varlist)'
	* selection variables. can be empty? should not	
	myhdfe `z1' if `touse', abs(`id')
		 local mn_var_z1  `r(mn_varlist)'		
	if "`endogenous'"!="" {
		* endogenous variables	
		*myhdfe `y3' if `touse', abs(`id')
		*** Here is the question. What happens if a variable is endogenous. would mean_y be instrumented with mean_z? mean_y not for now
		*local mn_var_y3  `r(mn_varlist)'
		* instruments for endogenous variables 
		myhdfe `z2' if `touse', abs(`id')
			 local mn_var_z2  `r(mn_varlist)'
	}

	//	Initial model estimation quietly
	qui:probit `y2' i.`time'#c.(`x1' `x1m' `z1' `z1m' `z2' `z2m') i.`time' if `touse'
	tempname bpi
	qui:matrix `bpi'=e(b)
	
	if "`endogenous'"==""  {
		qui:xtset, clear
 	 
		bootstrap, cluster(`id') reps(`reps') seed(`seed'):		_xthck if `touse', ///
		       y1(`y1') x1(`x1') x1m(`mn_var_x1') /// outcome equation
	           y2(`y2') z1(`z1') z1m(`mn_var_z1') /// selection equation
			   time(`time') bpi(`bpi') 
		if "`isxtset'"=="1" qui:xtset `id' `time'
	}
	if "`endogenous'"!=""  {
		qui:xtset, clear
		capture qui _xthckiv 
		bootstrap, cluster(`id') reps(`reps') seed(`seed'):_xthckiv if `touse', ///
				y1(`y1') x1(`x1') x1m(`mn_var_x1') 				 /// outcome equation
				y3(`y3') z1(`z1') z1m(`mn_var_z1')  		     /// Endogeneity equation also adds x1
				y2(`y2') z2(`z2') z2m(`mn_var_z2') time(`time')  /// selection equation need to add z1 and x1
				bpi(`bpi') 
		if "`isxtset'"=="1" qui:xtset `id' `time'
	}
	ereturn local cmd      "xtheckmanfe"
	ereturn local cmdline  "xtheckmanfe `0'"
end 
**	
 program define  myhdfe, rclass
syntax varlist(fv) [if] , abs(varname)
	marksample touse
	
	ms_fvstrip `varlist' if `touse', expand dropomit
	local 1:word count `r(nobase)'
	local nb `r(nobase)'
	local fvl `r(fullvarlist)'
	forvalues i=1/`1' {
		local i1:word `i' of `nb'
		local i2:word `i' of `fvl'
		local vnm = subinstr("`i2'",".","_",.)
		local vnm = subinstr("`vnm'","#","_x_",.)
		if "`i1'"=="0" {
			capture:qui:gen byte _mn_`vnm'=0
		}
		else if "`i1'"=="1" {
			capture:qui:egen double _mn_`vnm' = mean(`i2') if `touse', by(`abs')
		}
		local mn_varlist `mn_varlist' _mn_`vnm'
	}
 	return local mn_varlist  `mn_varlist'
end 
/*
notes for me and asymptotic
W=x y2 mill     K
Z=x z1 mill     J
h=x z1 z2       H
e=y1-W*b 

ZEEZ=Z(ee)Z' J x J 
EE=residuals original model
ZEQ JxH 
ZEQ Z*e * mills * h   by ID
where: 
   ZEQ=Z*ehat by panel... X QxVar   JxH 
   qui gen eh`var'=`var'*ehat;
   qui egen t`var' = sum(eh`var'), by(`id');
   Q is mills from Probit     (score0

   H = VCOV probit 
   
ZG = H x J
Z*(-lambda*(lambda+xb)*gamma`i')*h 
** see how they "are"

mat TERM2=ZEQ*H*ZG'; 13x28 28x28 28x13

QQ = h x q x q x h
mat TERM4=ZG*H*QQ*H*ZG';

WZ*invsym(ZZ)*WZ'

mat VB=WZ*invsym(ZZ)*(TERM1-TERM2-TERM2'+TERM4)*invsym(ZZ)*WZ';

mat V2=invsym(A)*B*invsym(A)*(e(N)-1)*g/((g-1)*(e(N)-K-L2-2*tmax));
*/
