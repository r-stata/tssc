*! version 1.2  08may2012, 25may2012, 19july2012, 26jan2013
*moehring@wiso.uni-koeln.de

version 11.0, missing
capture program drop mlt2stage
program define mlt2stage, rclass

*Syntax: 1.dependent var, 2.indep vars, 3.optional:if-condition, 4.optional:weights, 5.optional:notab
syntax varlist (min=2 max=101 numeric) [if] [aweight fweight iweight] , l2id(varname) [logit] [taboff] [drop]


*Erase old L2ID-variables
capture drop L2ID_mlt	
capture drop n_mlt
capture drop mltl2idstr


* which command specified?
capture confirm existence  `logit'
if !_rc {
	local l=1
	}
else {
	local l=0
	}

	
* if specified?
capture confirm existence  `if'
if !_rc {
 local i=1
 gettoken rest ifr : if , parse("i")
 gettoken rest ifr : ifr , parse("f")
 local ifr="& "+"`ifr'"
	}
else {
	local i=0
	}
	
	
* weights specified?
capture confirm existence  `weight'
if !_rc {
	local w=1
	}
else {
	local w=0
	}


*notab specified?
capture confirm existence `taboff'
if !_rc {
	local t=0
	}
else {
	local t=1
	}


*drop specified?
capture confirm existence  `drop'
if !_rc {
	local d=1
	}
else {
	local d=0
	}
	
	
** Convert string L2ID into nummeric L2ID
local l2id_name = "`l2id'"
capture confirm numeric v `l2id'
if _rc {
 encode `l2id', gen(mltl2idstr)
 local l2id = "mltl2idstr"
}


* get dependent and independent variables
*local varlist ="gr_incdiff age sex respincperc rgdppc"
local ivn=1
gettoken yvar xvars : varlist , parse(" ")
gettoken xvar1 rest : xvars , parse(" ")
forval x = 2/101 {
 if "`rest'" != "" {
  gettoken xvar`x' rest : rest , parse(" ")
  local ivn=`x'  
 }
}
  

dis " "
dis as text "Two-stage values calculated for the dependent variable" as result " `yvar' "
dis as text "and the independent variables" as result " `xvars' "
if `w'==1 { 
 dis as text "and the weight:" as result " `weight'"
}
dis " "


*Erase L2ID-variable
capture drop L2ID_mlt


* Get values and levels of level two ID
dis as text "Level 2 variable is" as result " `l2id_name' "
dis " "
qui levelsof `l2id' `if', local(l2idvalues) clean


* generate new Level2ID Variable
local i=0
qui gen L2ID_mlt = .

qui label variable L2ID_mlt "Level-2 ID"
foreach x of local l2idvalues {
 local i=`i'+1
 qui replace L2ID = `x' in `i' 
}
* get labels of original level-2 two ID and use them for the new variable L2ID
local vl :value label `l2id'		
label values L2ID `vl'

* Save number of macro units as local cn
char L2ID[varname] "`l2id'"
qui tab L2ID
local cn=r(r)


*Pre-check whether dependent variable varies in every country
foreach cnum in `l2idvalues' { 
 qui sum `yvar' if `l2id'==`cnum'
 if r(sd)==0 {
  dis as error "`yvar' is constant in `l2id_name'=`cnum'"
  exit 2000
 }
}


*Estimate regression models country seperated
capture drop cons_`yvar' /*$km 23-01-13: save constant*/
qui gen cons_`yvar'=. 
char cons_`yvar'[varname] "Constant"
format cons_`yvar' %9.3f
 
*if no weights specified
if `w'==0 {
 *for all IVs
 forval x=1/`ivn' {
  set more off
  capture drop coef_`yvar'_`xvar`x''
  qui gen coef_`yvar'_`xvar`x''=.
  char coef_`yvar'_`xvar`x''[varname] "`xvar`x''"
  format coef_`yvar'_`xvar`x'' %9.3f
  local coefvars="`coefvars'" + " coef_`yvar'_`xvar`x''"
 }
 
 foreach cnum in `l2idvalues' { 
  if `l'==0 {
   capture regress `yvar' `xvars' if `l2id'==`cnum' `ifr'
   if _rc!=0 {
    dis as error "Model estimation failed in `l2id_name'=`cnum' due to Stata-error " _rc
	exit 2000
   }
   matrix c=e(b)
   qui: replace cons_`yvar'=c[1,`ivn'+1]  if `l2id'==`cnum' /*$km 23-01-13: save constant*/
   forval x=1/`ivn' {
    qui: replace coef_`yvar'_`xvar`x''=c[1,`x']  if `l2id'==`cnum'
   }
   matrix drop c
  }
 else {
   capture logit `yvar' `xvars' if `l2id'==`cnum' `ifr'
   if _rc!=0 {
    dis as error "Model estimation failed in `l2id_name'=`cnum' due to Stata-error " _rc
	exit 2000
   }
   matrix c=e(b)
   qui: replace cons_`yvar'=c[1,`ivn'+1]  if `l2id'==`cnum' /*$km 23-01-13: save constant*/
   forval x=1/`ivn' {
    qui: replace coef_`yvar'_`xvar`x''=c[1,`x']  if `l2id'==`cnum'
   }
   matrix drop c
  }
 }
}



*if weights specified
if `w'==1 {
*for all IVs

 forval x=1/`ivn' {
  set more off
  capture drop coef_`yvar'_`xvar`x''
  qui: gen coef_`yvar'_`xvar`x''=.
  char coef_`yvar'_`xvar`x''[varname] "`xvar`x''"
  format coef_`yvar'_`xvar`x'' %9.3f
  local coefvars="`coefvars'" + " coef_`yvar'_`xvar`x''"
 }
 
 foreach cnum in `l2idvalues' { 
  if `l'==0 {
   qui: regress `yvar' `xvars' [`weight'`exp'] if `l2id'==`cnum' `ifr'
   if _rc!=0 {
    dis as error "Model estimation failed in `l2id_name'=`cnum' due to Stata-error " _rc
	exit 2000
   }
   matrix c=e(b)
   qui: replace cons_`yvar'=c[1,`ivn'+1]  if `l2id'==`cnum' /*$km 23-01-13: save constant*/
   forval x=1/`ivn' {
    capture replace coef_`yvar'_`xvar`x''=c[1,`x']  if `l2id'==`cnum'
   }
   matrix drop c
  }
 else {
   capture logit `yvar' `xvars' [`weight'`exp'] if `l2id'==`cnum' `ifr'
   if _rc!=0 {
    dis as error "Model estimation failed in `l2id_name'=`cnum' due to Stata-error " _rc
	exit 2000
   }
   matrix c=e(b)
   qui: replace cons_`yvar'=c[1,`ivn'+1]  if `l2id'==`cnum' /*$km 23-01-13: save constant*/
   forval x=1/`ivn' {
    qui: replace coef_`yvar'_`xvar`x''=c[1,`x']  if `l2id'==`cnum'
   }
   matrix drop c
  }
 }
}



*Output table
if `t'==1 {
 dis " "
 dis as text "Coefficients of the `l2id_name'-seperated regressions for " as result "`xvars'" as text " on" as result " `yvar'" as text ":" 
 preserve
 bysort `l2id': gen n_mlt=_n
 sort n_mlt `l2id'
 list `l2id' cons_`yvar' coef_`yvar'_`xvar1'-coef_`yvar'_`xvar`ivn''  in 1/`cn', divider sep(`cn') noobs subvarname
 restore
}

*Erase Coef-variables if drop specified
if `d'==1 {
 drop cons_`yvar'
 forval x=1/`ivn' {
  drop coef_`yvar'_`xvar`x''
 }
}


	
*Erase L2ID-variable
capture drop L2ID_mlt	
capture drop n_mlt
capture drop mltl2idstr



end


