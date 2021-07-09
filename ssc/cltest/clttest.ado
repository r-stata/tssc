*!********** Adjusted t-test Program ********
*! Estimates t-test statistic for continous outcomes
*! on clustered data. 15 October 2002. Jeph Herrin
*! see also clchi2.ado
* 
* Modified 
*	02 Feb 2012 - return scalars  
*
*       21 Apr 2004 - v8; fix strata problem
*
*       15 Oct 2002 - estimate ICC within groups, then pool
*
*       31 Jan 2002 - original release
*


capture program drop clttest
program define clttest, rclass
	version 8.0
	syntax varlist(min=1 max=1 default=none) [if] [in] , /*
*/		CLuster(varname) BY(varname) [STRata(varname) brief] 
	marksample touse

	tempname C C1 C2 diffw sd1 sd2 se1 se2 ses sew df df1 df2 rholb rhoub
	tempname summand M1 M2 x1 x2 CI1 CI2 CI1w CI2w CI t1 t2 t minby maxby
	tempname NC1 NC2 NC Pl Pt Pr ttest nstr s degf1 degf2 degf xall
	tempname xvar1 xvar2 Mvar1 Mvar2 Mvar diffs rhomean se 
	tempname sigw siga c

	tempvar myin Ks Ms
	tempvar MSC MSW Yi Yij M sd 
	tempvar summand df df1 df2 C1 C2 M1 M2 strvar group rho rhom rhomm
	tempvar x M C Vard W W_d dbar Sp W_Vard Var1 Var2 W_all
	tempvar W1 W2 W_Var1 W_Var2 W_x1 W_x2 diffw diffs xall Wall Sp
	tempvar m_ij m_Ai m2_ij m_0 M_i K MSCs  MSWs W_Varall Varall


	if "`cluster'"!="" { 
		unabbrev `cluster', max(1)
		local cluster "$S_1"
	}
	else {
		di in r "Must specify cluster"
		exit
	}
	if "`by'"!="" {
		unabbrev `by', max(1)
		local by "$S_1"
	}
	else {
		di in r "Must specify by variable"
		exit
	}
	if "`strata'"!="" { 
		unabbrev `strata', max(1)
		local strata "$S_1"
	}

	tokenize `varlist', parse(" ")
	local var1 "`1'"
	if "`cluster'"==""|"`var1'"==""|"`by'"==""  {
		di in gr "Syntax for " in wh "clttest" _c
		di in gr ", the clustered ttest is:"
		di in wh "clttest " in gr "v1" in wh ", by(" _c
		di in gr "v2" in wh ") cluster(" _c
		di in gr "v3" in wh ") strata(" _c
		di in gr "v4" in wh ")"
		di in gr "  where " in wh "v1 " in gr "is the test variable"
		di in wh "        v2 " in gr "is the required comparison variable"
		di in wh "        v3 " in gr "is a required cluster variable"
		di in wh "        v4 " in gr "is an optional strata variable"
		exit
	}

	quietly {

	gen byte `myin'= 1
	if ("`if'`in'"!="") {
		replace `myin'=0
		replace `myin'=1 `if' `in'
		}
	replace `myin'=`myin'&`var1'!=.&`by'!=.&`cluster'!=.


	** check the strata **

	if "`strata'"!="" {
		capture confirm string variable `strata'
		if _rc==0 {
			encode `strata', gen(`strvar')
		} 
		else {
			gen `strvar'=`strata'
		}
		tab `strvar'
		local `nstr'=r(r)
		if ``nstr''==. {
			di in r "`strata' must take 1-3000 values!"
			exit
		}
	}
	else {
		gen byte `strvar'=1
	}
	replace `myin'=`myin'&`strvar'!=.

** KEEP THE RIGHT ONES ***


	preserve
	keep if `myin'
	keep if `by'!=.

 	**** Basic stuff **********
	egen `group'=group(`strvar') 
	su `group', meanonly
	local `nstr'= r(max)
	count
	if r(N)<4  {
		di in r "Not enough observations"
		exit
	}
	inspect `by'
	if r(N_unique)!=2 {
		di in r "`by' : must have exactly two values"
		di in r "r(N_unique) = " r(N_unique)
		exit
	}
	su `by', meanonly
	scalar `minby'=r(min)
	scalar `maxby'=r(max)
	replace `by'=`by'!=`minby' 

	by `strvar' `by', sort: egen `sd'=sd(`var1')
	by `strvar' `by', sort: egen `M_i'=count(`var1')
	egen `M'=count(`var1')
	by `strvar',sort: egen `Ms'=count(`var1')
	by `strvar' `by', sort: egen `x'=mean(`var1')
	by `strvar' (`by'), sort: gen `diffw'=`x'[1]-`x'[_N]
	by `strvar' , sort: egen `xall'=mean(`var1')

/*** get ICC *****/
	by `cluster', sort: egen `m_ij'=count(`var1')
	by `cluster', sort: replace `m_ij'=. if _n!=1
	egen `K'=count(`m_ij')
	by `strvar', sort: egen `Ks'=count(`m_ij')
	gen `m2_ij'=`m_ij'^2/`M_i'
	by `strvar' `by', sort: egen `m_Ai'=sum(`m2_ij')
	by `strvar' `by', sort: replace `m_Ai'=. if _n!=1
	by `strvar', sort: egen `m_0'=sum(`m_Ai')
	by `strvar', sort: replace `m_0'=(`Ms'-`m_0')/(`Ks'-2)

	by `cluster', sort: egen `Yij'=mean(`var1')
	by `strvar' `by', sort: egen `Yi'=mean(`var1')
	gen `MSCs'=`m_ij'*(`Yij'-`Yi')^2/(`Ks'-2)
	gen `MSWs'=(`var1'-`Yij')^2/(`Ms'-`Ks')
	by `strvar', sort: egen `MSC'=sum(`MSCs')
	by `strvar', sort: egen `MSW'=sum(`MSWs')
	gen `rho' = (`MSC'-`MSW')/(`MSC'+(`m_0'-1)*`MSW')
	replace `rho'=0 if `rho'<0

	gen `Sp'=(((`MSC'-`MSW')/`m_0')+`MSW')^0.5

	** rho is mean over all strata rhos **
	by `strvar', sort: gen `rhom'=`rho' if _n==1
	egen `rhomm'=mean(`rhom')
	replace `rhomm'=0 if `rhomm'<0
	scalar `rhomean'=`rhomm'[1]
*	replace `rho'=`rhomm'
	**
	by `cluster' , sort :gen `summand'=((_N-1)*`rho'+1)
	collapse (sum) `summand' `myin' (max) `Sp' `sd' `x' `M_i' `diffw' `xall' ,by(`cluster' `by' `strvar')
	collapse (sum) `summand' `myin' (max) `Sp' `sd' `x' `M_i' `diffw' `xall'   /*
*/ 			(count) `df'=`cluster',by(`by' `strvar')
	by `strvar' (`by'), sort: /*
*/ 			gen `Vard'=`Sp'*`Sp'*((`summand'[1]/`myin'[1]^2)+(`summand'[_N]/`myin'[_N]^2))
	by `strvar' (`by'), sort: gen `Var1'=`Sp'*`Sp'*(`summand'[1]/`myin'[1]^2)
	by `strvar' (`by'), sort: gen `Var2'=`Sp'*`Sp'*(`summand'[_N]/`myin'[_N]^2)
	by `strvar' (`by'), sort: gen `Varall'=`Sp'*`Sp'*((`summand'[_N]+`summand'[1])/(`myin'[_N]+`myin'[1])^2)
	by `strvar' (`by'), sort: gen `x1'=`x'[1]
	by `strvar' (`by'), sort: gen `x2'=`x'[_N]
	by `strvar' (`by'), sort: gen `df1'=`df'[1]
	by `strvar' (`by'), sort: gen `df2'=`df'[_N]
	by `strvar' (`by'), sort: gen `M1'=`M_i'[1]
	by `strvar' (`by'), sort: gen `M2'=`M_i'[_N]
	gen `W'=1/`Vard'
	gen `W1'=1/`Var1'
	gen `W2'=1/`Var2'
	gen `Wall'=1/`Varall'
	gen `W_d'=`W'*`diffw'
	gen `W_x1'=`W1'*`x1'
	gen `W_x2'=`W2'*`x2'
	gen `W_all'=`Wall'*`xall'
	gen `W_Vard'=`W'*`W'*`Vard'
	gen `W_Varall'=`Wall'*`Wall'*`Varall'
	gen `W_Var1'=`W1'*`W1'*`Var1'
	gen `W_Var2'=`W2'*`W2'*`Var2'
	drop if `by'==0
*	forvalues i=1(1)4 {
*		di in r `W'[`i']
*	} 
	collapse (sum) `W' `W1' `W2' `W_x1' `W_x2' `W_d' `W_Var1' `W_Var2' `W_Vard' /*
*/		  `df1' `df2'  `df' `M1' `M2' `Wall' `W_all' `W_Varall'

	gen `Vard'= `W_Vard'/(`W'*`W')
	gen `Var1'=`W_Var1'/(`W1'*`W1')
	gen `Var2'=`W_Var2'/(`W2'*`W2')
	gen `Varall'=`W_Varall'/(`Wall'*`Wall')
	gen `diffw'=`W_d'/`W'
	gen `x1'=`W_x1'/`W1'
	gen `x2'=`W_x2'/`W2'
	gen `xall'=`W_all'/`Wall'
	
	scalar `xvar1'=`x1'[1]
	scalar `xvar2'=`x2'[1]
	scalar `xall'=`xall'[1]
	scalar `Mvar1'= `M1'[1]
	scalar `Mvar2'= `M2'[1]
	scalar `Mvar'=`M1'+`M2'
	scalar `NC1' = `df1'[1]
	scalar `NC2' = `df2'[1]
	scalar `NC' = `NC1'+`NC2'
	scalar `se1'=`Var1'[1]^0.5
	scalar `se2'=`Var2'[1]^0.5
	scalar `se' = `Varall'[1]^0.5
	scalar `sd1'=`se1'*(`Mvar1'^0.5)
	scalar `sd2'=`se2'*(`Mvar2'^0.5)
	scalar `sd'=`se'*(`Mvar'^0.5)
	scalar `ses'=(`se1'*`se1'+`se2'*`se2')^0.5
	scalar `sew'= `Vard'[1]^0.5
	scalar `degf1'=`NC1'-``nstr''
	scalar `degf2'=`NC2'-``nstr''
	scalar `degf'=`degf1'+`degf2'
	scalar `t1' = invttail(`degf1',(1-$S_level/100)/2)
*	di in r "DegF " `degf1'
*	di in r "T1   " `t1'
	scalar `t2' = invttail(`degf2',(1-$S_level/100)/2)
	scalar `t' = invttail(`degf',(1-$S_level/100)/2)
	scalar `diffs'=`xvar1'-`xvar2'
	scalar `diffw'=`diffw'[1]
	scalar `ttest'=`diffw'/`sew'
	scalar `Pt' = 2*ttail(`degf',abs(`ttest'))
	if `ttest' < 0 {
		scalar `Pl' = ttail(`degf',abs(`ttest'))
		scalar `Pr' = 1 - `Pl'
	}
	else {
		scalar `Pr' = ttail(`degf',`ttest')
		scalar `Pl' = 1 - `Pr'
	}
	scalar `CI1'=`diffs'-`ses'*`t'
	scalar `CI2'=`diffs'+`ses'*`t'
	scalar `CI1w'=`diffw'-`sew'*`t'
	scalar `CI2w'=`diffw'+`sew'*`t'

	*****************************************
	restore
	}  /* end quietly */

	if "`brief'"=="" {
	di
	di in g " t-test adjusted for clustering"
	display in y " `var1'" in g " by " in y "`by'" in g /*
*/                     ", clustered by " in y "`cluster'"
	if ``nstr''!=1 {
	display in g "              stratified on " in y "`strata'"
	}
	di in g  " " _dup(72) "-"
	display in gr "  Intra-cluster correlation" _col(37) "= " /*
*/                     in y %16.4f `rhomean'
/*
	#delimit ;
	di in smcl in gr %8s abbrev(`"`by'"',8) " {c |}" in ye
		 _col(12) %7.0f `Mvar1'
		 _col(22) %9.0g `xvar1'
		 _col(34) %9.0g `se1'
		 _col(46) %9.0g `sd1'
		 _col(58) %9.0g (`xvar1')-`t1'*(`se1')
		 _col(70) %9.0g (`xvar1')+`t1'*(`se1') ;
	#delimit cr
*/

	di in g  " " _dup(72) "-"
	di in gr _col(15) "N    Clusts    Mean           SE" _col(60) "$S_level % CI"
	di in gr %2.0f " `by'=" `minby' _co   
	di in y  %6.0f _col(11) `Mvar1'   _col(22)  `NC1' _co
	di in y  %8.4f _col(28) `xvar1'   _co
	di in y  %8.4f _col(40) `se1'   _co
	di in gr %8.4f _col(55) "[" in y %8.4f `xvar1'-`se1'*`t1' _co
	di in gr %8.4f       "," in y %8.4f `xvar1'+`se1'*`t1' in g "]" 
	di in gr %2.0f " `by'=" `maxby' _co   
	di in y  %6.0f _col(11) `Mvar2'   _col(22)  `NC2' _co
	di in y  %8.4f _col(28) `xvar2'   _co
	di in y  %8.4f _col(40) `se2'   _co
	di in gr %8.4f _col(55) "[" in y %8.4f `xvar2'-`se2'*`t2' _co
	di in gr %8.4f       "," in y %8.4f `xvar2'+`se2'*`t2' in g "]" 
	di in g  " " _dup(72) "-"
	di in gr %2.0f " Combined "  _co   
	di in y  %6.0f _col(11) `Mvar'   _col(22)  `NC2' _co
	di in y  %8.4f _col(28) `xall'   _co
	di in y  %8.4f _col(40) `se'   _co
	di in gr %8.4f _col(55) "[" in y %8.4f `xall'-`se'*`t' _co
	di in gr %8.4f       "," in y %8.4f `xall'+`se'*`t' in g "]" 
	di in g  " " _dup(72) "-"
	di in gr " Diff("  `minby' "-" `maxby' ")"  _co
	di in y  %6.0f  _col(11) `Mvar'   _col(22)  `NC' _co
	di %8.4f in gr  _col(28)  in y `diffs' _co
	di %8.4f in gr  _col(40)  in y `ses' _co
	di %8.4f in gr  _col(55) "[" in y %8.4f `CI1' _co
	di %8.4f in gr       "," in y %8.4f `CI2' in g "]"
	if ``nstr''>1 {
	di in gr " Weighted across strata" _co
	di %8.4f in gr  _col(28)  in y `diffw' _co
	di %8.4f in gr  _col(40)  in y `sew' _co
	di %8.4f in gr  _col(55) "[" in y %8.4f `CI1w' _co
	di %8.4f in gr       "," in y %8.4f `CI2w' in g "]"
	}

	di 
	di in g  " Degrees freedom:    " in y `degf'
	if ``nstr''>1 {
	di in g  " Number of strata:    " in y ``nstr''
	}
/* Display Ho. */
	di
	di in g _dup(20) " " "Ho: mean(" `min' "-" `max' ") = mean(diff) = 0"

/* Display Ha. */

        local tt : di %8.4f `ttest'
        local p1 : di %8.4f `Pl'
        local p2 : di %8.4f `Pt'
        local p3 : di %8.4f `Pr'

        di
        _ttest center "Ha: mean(diff) < 0"  /*
	*/            "Ha: mean(diff) ~= 0" /*
	*/            "Ha: mean(diff) > 0"

        _ttest center "    t = @`tt'@"    /*
        */            "      t = @`tt'@"  /*
        */            "    t = @`tt'@"
        _ttest center "P < t = @`p1'@"   /*
        */            "P > |t| = @`p2'@" /*
        */            "P > t = @`p3'@"

	} 
	else {
	di  " BRIEF      N           Mean          SE    [95% CI              ]"
	di  %2.0f " `by'=" `minby' %6.0f `Mvar1' _col(10) %8.4f _col(25) `xvar1' _col(35) `se1' _co
	di  %8.4f _col(45) `xvar1'-`se1'*`t1' _col(55) `xvar1'+`se1'*`t1'
	di  %2.0f " `by'=" `maxby' %6.0f `Mvar2' _col(10) %8.4f _col(25) `xvar2' _col(35) `se2' _co
	di  %8.4f _col(45) `xvar2'-`se2'*`t2' _col(55) `xvar2'+`se2'*`t1'
	di  " COMBINED " %6.0f `Mvar' _col(10) %8.4f _col(25) `xall' _col(35) `se' _co
	di  %8.4f _col(45) `xall'-`se'*`t' _col(55) `xall'+`se'*`t'
	di  " DIFF(S)  " `Mvar' _col(10) %8.4f _col(25) `diffs' _col(35) `ses' _co
	di  %8.4f _col(45) `CI1' _col(55) `CI2'
	di  " DIFF(W)  " `Mvar' _col(10) %8.4f _col(25) `diffw' _col(35) `sew' _co
	di  %8.4f _col(45) `CI1w' _col(55) `CI2w'
	di  " PVALUE   " _col(25) %8.4f `Pt'
	}
	return scalar p= `Pt'
	return scalar p_u= `Pr'
	return scalar p_l= `Pl'
	return scalar mu_1=`xvar1'
	return scalar mu_2=`xvar2'
	return scalar se_1=`se1'
	return scalar se_2=`se2'
	return scalar m_diff=`diffs'
	return scalar se=`ses'
	return scalar sd_1=`sd1'
	return scalar sd_2=`sd2'
	return scalar t=`tt'
	return scalar df_t=`degf'
	return scalar N_1=`Mvar1'
	return scalar N_2=`Mvar2'

end 
**************end program clttest ********
