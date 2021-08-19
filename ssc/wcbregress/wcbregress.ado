*! v 1.0.0
*! Estimating a Linear Regression Model and Computing the Wild Cluster Boostrap Standard Errors and T-test Confidence Intervals
*! Distribution-Date: 20201101 (Nov 1, 2020)

program define wcbregress, eclass
syntax varlist(min=2 numeric fv) [if] [in] [iweight aweight pweight fweight] [, * ///
	group(varname) Details rep(integer 200) seed(integer 100) ///
	level(integer 95) /// 
	]
version 13

/* [> Initialisations <] */ 
qui marksample touse 
tempvar touse2
qui g byte `touse2'=.
qui replace `touse2'=1 `if' `in'
qui replace `touse2'=0 if `touse'!=1
if "`details'" == "" { 
	local de "qui "  
	local olstable "notab"
}

/* [> Seed <] */ 
set seed `seed'
mata: rseed(`seed')

/* [> Weights <] */ 
if "`weight'" != ""  { 
	local wexp "  [`weight'`exp']  "  
}   

/* [> Factor variables <] */ 
local fvops = "`s(fvops)'" == "true" | _caller() >= 11 
if `fvops' { 
	local vv: di "version " ///
	string(max(11,_caller())) ", missing: " 
	gettoken lhs rhs : varlist
	_fv_check_depvar `lhs'
} 

/* [> CI level <] */ 
if "`level'"!="" {
	local level_exp " level(`level')"
} 

/* [> Index the group <] */ 
tempvar gid
capture confirm numeric variable `group'
if !_rc { 
	qui tempvar clstr
	qui tostring `group', force gen(`clstr')
	qui encode `clstr' if `touse2'==1, gen(`gid')
}
capture confirm string variable `group'
if !_rc { 
	qui encode `group' if `touse2'==1, gen(`gid')
}
qui sum `gid'  if `touse2'==1
local G = r(max)



/* [> 1. OLSE  <] */ 
`de'di in ye  "OLS Estimating..."
tempvar u xb
`de'regress `lhs' `rhs'`wexp' if `touse2'==1 , cluster(`gid')  `options'   `level_exp'  
local olsn         =   e(N)  
local olsr2        =   e(r2)  
local olsr2_a      =   e(r2_a)  
local olsrmse      =   e(rmse)   

tempname beta bmat  variance
mat `beta' = e(b) 
local colname: colnames `beta'
local K   `=colsof(`beta')' 
mat `variance' = e(V)  
mata: `bmat'=st_matrix("`beta'")'
qui predict  double `u' if `touse2'==1, resid 
qui predict  double `xb' if `touse2'==1 ,xb  



/* [> 2. B reps <] */ 
nois di in ye _newline(1) "Wild Cluster Boostrap in progress (`rep' replications)"
nois _dots 0, title(   (each dot "." indicates one replication) ) 

tempname wald  wcbb
`de'forvalues b = 1 (1) `rep' { 

	di in ye _newline(1)  "Repetition `b': detailed intermediate results"

	tempname prob
	mata: st_matrix("`prob'",runiform(1,`G'))

	/* [> 2.1 <] */ 
	qui {
		/* [> clear memory <] */ 
		tempvar ustar 
		tempvar ystar 
		gen double `ustar' =  `u'  if `touse2'==1
		gen double `ystar' =  .

		/* [> compute <] */  
		forvalues g = 1 (1) `G' {
			local p= `prob'[1,`g']
			if `p'>=0.5 {
				replace   `ustar' = -`u'  if `touse2'==1 & `gid'==`g'   
			}
			replace `ystar'  = `xb' + `ustar' if `touse2'==1 & `gid'==`g' 
		}  // end of forvalues g = 1 (1) `G' 
	}


	/* [> 2.2 <] */ 
	regress `ystar' `rhs'`wexp' if `touse2'==1 , cluster(`gid')   `options'  `level_exp'
	tempname eb ev  wald`b' wcbb`b'
	mat `eb' = e(b)
	mat `ev' = e(V)
	mata: `wcbb`b''=wcbbf("`eb'") 
	mata: `wald`b''=waldstat(`bmat',"`eb'","`ev'") 

	/* [> Empirical distribution <] */ 
	if `b'==1 {
		mata: `wald'=`wald`b''
		mata: `wcbb'=`wcbb`b''
	}
	if `b'>1 {
		mata: `wald'=(`wald',`wald`b'')
		mata: `wcbb'=(`wcbb',`wcbb`b'')
	}

	nois _dots `b' 0
	mata: mata drop `wald`b'' `wcbb`b''


}  // end of forvalues b = 1 (1) `rep'

/* [> 3.1 Bootstrap SE <] */ 
tempname  wcbse  wcbsemat
mata: `wcbse'=sqrt(rowsum((`wcbb':-mean(`wcbb'')'):^2):/(`rep'-1))
qui mata: st_matrix("`wcbsemat'", `wcbse'') 
 
/* [> 3.2 Bootstrap 95% CI <] */ 
tempvar waldvar
tempname waldmat
qui mata: st_matrix("`waldmat'", `wald'') 
mata: mata drop `wald' `bmat' `wcbse' `wcbb'

preserve 
	qui svmat `waldmat', name(`waldvar')   
	`de'forvalues k = 1 (1) `K' { 

		qui _pctile(`waldvar'`k'), nq(1000)
		local  l99`k' = r(r5)
		local  u99`k' = r(r995) 
		local  l95`k' = r(r25)
		local  u95`k' = r(r975) 
		local  l90`k' = r(r50)
		local  u90`k' = r(r950)

		local buse`k' = `beta'[1,`k']
		local seuse`k' = sqrt(`variance'[`k',`k'])

		/* [> WC Bootstrap SE <] */ 
		local sse`k' = `wcbsemat'[1,`k']

		/* [> WC Bootstrap Normalized CI <] */ 
		local nl`k' =  `buse`k'' -  `sse`k''*1.96
		local nu`k' =  `buse`k'' +  `sse`k''*1.96  
		if `nu`k''<`nl`k'' {
			local temps = nu`k'
			local nu`k' =  nl`k'
			local nl`k' =  `temps'
		}
		/* [> WC Bootstrap Normalized z & p value <] */ 
		local nz`k' = `buse`k''/`seuse`k''
		local np`k' = tprob(9999999,`nz`k'')

		/* [> WC Bootstrap-t: Symmetric and Asymmetric `level'% CI <] */  
		local sl`k' =  `buse`k'' -  `seuse`k''*`u`level'`k''
		local su`k' =  `buse`k'' +  `seuse`k''*`u`level'`k''  
		local asl`k' = `buse`k'' +  `seuse`k''*`l`level'`k''

		/* [> WC Bootstrap-t:  p value = 2* min{ (number of rejection / B<t), (number of rejection / B>t) } <] */ 
		local tstat =  `buse`k''/`seuse`k'' 
		qui count if  `waldvar'`k' < `tstat' & `waldvar'`k'!=. 
 		local nrejl = r(N)
		qui count if  `waldvar'`k' > `tstat' & `waldvar'`k'!=.
 		local nreju = r(N)
 		local nrej = min(`nrejl',`nreju')
 		local p`k' = 2*`nrej'/`rep'  

		local vv`k': word `k' of `colname' 
		di "`k'th variable (`vv`k''): t=b/se=`buse`k''/`seuse`k''=`tstat'"
		di "     		no of rej=2*min{`nrejl', `nreju'} "    
		di "     		p-value=no of rej/Brep=`nrej'/`rep'=`p`k'' "    

		/* [> Omitted <] */ 
		if "`sl`k''"=="." {
			local p`k'  ""
		}

	}  // end of forvalues k = 1 (1) `K'
restore 

/* [> Return <] */ 
di in gr _newline as text "Wild Cluster Bootstrap Linear regression"
di in gr  _column(60) "Number of obs     = " as result  %4.3f `olsn'
di in gr  _column(60) "Replications      = " as result  %4.3f `rep'
di in gr  _column(60) "R-squared         = " as result  %4.3f `olsr2'
di in gr  _column(60) "Adj R-squared     = " as result  %4.3f `olsr2_a'
di in gr  _column(60) "Root MSE          = " as result  %4.3f `olsrmse'
tempname Bv Bp 

	/* [> WC Bootstrap SE <] */ 
	di in ye  ""
	dhe1 `lhs' `level'
	forvalues k = 1 (1) `K' {
		dxe1 "`vv`k''" `buse`k''  `seuse`k'' `nz`k'' `np`k'' `nl`k''  `nu`k''    
	}  // end of forvalues k = 1 (1) `K'
	dbe 

	/* [> WC Bootstrap t <] */ 
	dhe2 `lhs' `level'
	forvalues k = 1 (1) `K' {
		dxe2 "`vv`k''"  `sse`k''  `p`k'' `sl`k''  `su`k''   `asl`k''  `su`k''  
	}  // end of forvalues k = 1 (1) `K'
	dbe 

mat `Bv' = `beta'
mat `Bp' = `beta'
forvalues k = 1 (1) `K' { 
	if "`p`k''"!="" {
		mat  `Bv'[1,`k']  =  `sse`k''*`sse`k''
		mat  `Bp'[1,`k']  =  `p`k''
	}
	if "`p`k''"=="" {
		mat  `Bv'[1,`k']  =  .
		mat  `Bp'[1,`k']  =  .
	}
}  // end of forvalues k = 1 (1) `K'
ereturn post `beta' `variance', esample(`touse2')
ereturn local Brep = `rep'
ereturn matrix WCB_V     = `Bv'
ereturn matrix WCB_pvalue = `Bp'
ereturn local title "Wild cluster bootstrap SE and T-tests for the linear regression"
ereturn local cmd "wcbregress"
ereturn local vcetype "Wild Cluster Bootstrap SE"
di in ye "* Disclaimer: This is a Beta version of the command. helloyzz@gmail.com"
ereturn scalar N = `olsn'         
ereturn scalar r2 =  `olsr2'      
ereturn scalar r2_a =  `olsr2_a'  
ereturn scalar rmse =  `olsrmse'  
end  
 
/* [> Subroutines and MATA function <] */ 
program define .dhe1
	args lhs level
	di in gr  as text "{hline 88}"
	di in ye    " Panel A: Point Estimates and Wild Cluster Bootstrap Std. Err.   " 
	di in gr  as text "{hline 20}{c TT}{hline 67}"
	di as text                                          _column(20) " {c |} "         _col(35) " Bootstrap "  _col(65)    "      Normalized" 
	di in gr "   " as text  %16s abbrev("`lhs'",16) ""  _column(20) " {c |}   Coef."  _col(35)    " Std. Err." _col(48)    "  z"  _col(55) "P>|z|"  _col(65)  "[  `level'% Conf. Interval  ]"
	di as text "{hline 20}{c +}{hline 67}"
end // end of program   

program define .dxe1
	args x b s z p l u
	display in gr "   " as text %16s abbrev("`x'",16) " {c |}"  as result   _column(20) %9.4f  `b' "" _col(35) %9.4f `s' "" _col(48) %3.2f `z' "" _col(55) %4.3f `p' "" _col(65) %10.3f `l' "    " %10.3f `u'
end // end of program   

program define .dhe2
	args lhs level
	di in ye   " Panel B: Wild Cluster Bootstrap t-tests and Confidence Intervals  " 
	di in gr  as text "{hline 20}{c TT}{hline 67}"
	di as text   _column(20) " {c |}  Bootstrap" _col(50)   "[  `level'% Conf. Interval  ]" 
	di in gr "   " as text  %16s abbrev("`lhs'",16) "" _column(20) " {c |}   P>|t*|" _col(40)   "[    Symmetric CI    ]"  _col(65)   "[    Asymmetric CI   ]"
	di as text "{hline 20}{c +}{hline 67}"
end // end of program   
 
program define .dxe2
	args x s p l u al au
	display in gr "   " as text %16s abbrev("`x'",16) " {c |}"  as result  _column(25) %4.3f  `p' ""  _col(40) %10.3f `l' "  " %10.3f `u' _col(65) %10.3f `al' "  " %10.3f `au'
end // end of program   



program define .dbe
	di as text "{hline 20}{c BT}{hline 67}" 
end // end of program  
  



mata

real vector waldstat(b,string scalar bs,string scalar vs)
{
	bstar=st_matrix(bs)'
	vstar=st_matrix(vs)
	sestar=sqrt(diagonal(vstar))  
	return((bstar:-b):/(sestar))
}

real vector wcbbf(string scalar bs)
{
	bstar=st_matrix(bs)'
	return(bstar)
}

end









*oOo