*!Version 4.1.0 20Jan10, by Jonah B. Gelbach 
*Original version 4.0.0 was 10Nov08.  
*Key difference is that newer version fully supports 2sls.  
*
*NO WARRANTIES: TO THE EXTENT PERMITTED BY APPLICABLE LAW,
*NEITHER JONAH B. GELBACH, NOR ANY OTHER PERSON, EITHER EXPRESSLY OR IMPLICITLY,
*WARRANTS ANY ASPECT OF THIS SOFTWARE OR PROGRAM, INCLUDING ANY OUTPUT
*OR RESULTS OF THIS SOFTWARE OR PROGRAM. THIS SOFTWARE AND PROGRAM IS BEING PROVIDED "AS IS", WITHOUT
*ANY WARRANTY OF ANY TYPE OR NATURE, EITHER EXPRESS OR IMPLIED,
*INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
*MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, AND ANY
*WARRANTY THAT THIS SOFTWARE OR PROGRAM IS FREE FROM DEFECTS.
*

*CHANGELOG SINCE VERSION 4.0.0
*
* Version 4.1.0: fixed problem with aweights that led to absurd covariance estimates
*
 

program define b1x2, eclass sortpreserve

	version 10.0
	syntax varname [if] [in] [aweight fweight iweight /], x1all(varlist) x2all(varlist) [ x1only(varname) x1endog(varlist) iv(varlist) Robust Cluster(passthru) x2delta(string) noBase noFull gamma0 cov0 ]

	*note: x1only should allow a varlist in principle, but that would involve more parsing/matrix manipulation/etc

	*making sure that cov0 option is on if gamma=0 is specified
	if "`gamma0'"=="gamma0" local cov0 "cov0"

	*get unique varlists: subroutine uniqify returns unique list in global macro $uniqified
	unab x1all : `x1all'
	local x1all : list uniq x1all

	*initializing
	local numiv	=0
	local N_clust	=0
	local numx1endog=0

	if "`iv'"~="" { /* we have instruments, so recreate x1all to have x1exog first, followed by x1endog */
		unab iv : `iv'	       
		local iv : list uniq iv
	
		unab x1endog : `x1endog'
		local x1endog : list uniq x1endog
	
		*extract x1exog from x1all, given x1endog
		local x1exog : list x1all - x1endog
	
		*recreate x1all: have to do endog first for mat accum extraction code below
		local x1all "`x1endog' `x1exog'"
	}

	local groupnames
	if "`x2delta'"=="" {
		local x2delta "ALL = `x2all'"
	}

	local depvar "`varlist'"

	/* mark sample */
	tempvar touse
	qui marksample touse
	qui markout `touse' `x1all' `x2all' `exp' `iv'

	qui count if `touse'==1
	local numobs = _result(1)

	*now we don't need to worry about if and in the rest of the way

	/* deal with options */
	local comma ""
	if ("`robust'"=="robust" | "`cluster'"~="") {
		local comma ","
	} /* end if for options and comma */

	/* giving weight var a mnemonic name */
	tempvar weightval
	qui gen `weightval'=1
	if "`weight'" ~= "" { 
		local weight "[`weight'=`exp']"
		qui replace `weightval' = `exp'
	}


	*get unique varlist: subroutine uniqify returns unique list in global macro $uniqified
	unab x2all : `x2all'
	local x2all : list uniq x2all

	****************************************
	* check that all x2delta vars in x2all *
	****************************************
	*don't use local list approach, b/c x2delta is funky (with "=" and ":")
	check 2 , delta(`x2delta') all(`x2all')

        ***************************************************
	**** BEGIN DOING STUFF RELATED TO DROPPED VARS ****
        ***************************************************

	qui _rmdcoll `depvar' `x1all' `x2all' `iv' `weight' if `touse'
	local notdropped "`r(varlist)'"
	local first_nondropped : word 1 of `notdropped'
	local last_nondropped  : word count `notdropped'

	*getting list of dropped vars
	local all "`x1all' `x2all'"
	local dropped : list all - notdropped

	*get intersection of original `x2all' and `notdropped'
	local x2all : list x2all & notdropped

	*get intersection of original `x1all' and `notdropped'
	local x1all : list x1all & notdropped

	*make sure no vars appear in both x1all and x2all
	local inboth : list x1all & x2all
	if "`inboth'"~="" {
		di
		di "b1x2: Both x1all() and x2all() contain variable(s) `inboth'"
		di "      Pick only one list and try again."
		error jbg
	}
        *************************************************
	**** END DOING STUFF RELATED TO DROPPED VARS ****
        *************************************************


	***********************************
	**** BEGIN PARSING GROUP LISTS ****
	***********************************
	*initialize for decomp
	local x2deltalist
	local numgroups=0
	local maxlength=0
	local Deltaroweq

	*now we parse `x2delta' on colons
	tokenize "`x2delta'", parse(":")

	local g 0
	while "`1'"~="" { /* looping over colon-delimited elements of `x2delta' */

		if "`1'"==":" {
			mac shift
			continue
		}

		local g = `g' + 1
		local grouplist "`1'"

		*creating lmac groupname`g' with name of group (first token of `grouplist') and leaving rest of `grouplist' the same
		localparse , input( `grouplist' ) parse("=")
		local groupname`g' "$groupname__"
		local grouplist`g' "$grouplist__"
		unab  grouplist`g' : `grouplist`g''

		*now we remove dropped vars from the groups
		*first get intersection of `grouplist`g'' plus `dropped'
		local dropped`g' : list grouplist`g' & dropped

		*now remove these vars
		local grouplist`g' : list grouplist`g' - dropped`g'
		*di "...grouplist`g' now '`grouplist`g'''"

		*now make grouplist`g' unique
		local grouplist`g' : list uniq grouplist`g'
		*di "...grouplist`g' now '`grouplist`g'''"

		local groupnames "`groupnames' `groupname`g''"	/* add to list of groupnames */

		local maxlength = max(`maxlength',length("`groupname`g''"))

		/* can't use -wordcount- string function b/c it truncates. unbelievable. */
		local ngrouplist`g' : word count `grouplist`g''
		local Deltaroweq "`Deltaroweq' `x1all' _cons"

		*we will use `x2deltalist' below to get v2ulocal and Gammalocal matrices in right order
		local x2deltalist "`x2deltalist' `grouplist`g''"

		mac shift
	} /* end looping over tokens in `x2delta' */

	local numgroups = `g'	/* total number of groups for x2delta part, plus 1 for __TC */

	*checking to make sure no element of any grouplist is repeated in another one 
	local duplicates : list dups x2deltalist
	if "`duplicates'"~="" {
		di 
		di "b1x2 ERROR: The following variable(s) --`duplicates'-- appear(s) in multiple groups in your -x2delta- list."
		di "r(jbg)"
		di
	        exit
	} /* done checking for duplicates in x2deltalist */

	*checking for any x2vars left out of x2deltalist but not dropped from the unrestricted regression
	local residual_x2vars : list x2all - x2deltalist
	if "`residual_x2vars'"~="" { /* there are some residual x2vars, so we add a new group to x2deltalist */

		local numgroups=`numgroups'+1

		local groupname`numgroups' "__RESIDUAL"
		local groupnames "`groupnames' __RESIDUAL"

		local grouplist`numgroups' "`residual_x2vars'"
		local ngrouplist`numgroups' : word count `grouplist`numgroups''

		local x2deltalist "`x2deltalist' `residual_x2vars'"

	} /* end dealing with residual x2vars */


	*replace x2all with x2deltalist: do this so we can use `x2all' below without having to re-order
	*note that we can't do this step until we get here, because we need x2all to make residual_x2vars lmac above
	local x2all "`x2deltalist'"
	*********************************
	**** END PARSING GROUP LISTS ****
	*********************************


	*******************************************************
	**** BEGIN DOING CROSS-PRODUCT STUFF FOR ESTIMATES ****
	*******************************************************

	*now get first and last x1 variables, as well as k1
	local x1allfirst : word 1 of `x1all'
	local numx1all : word count `x1all'
	local k1 = `numx1all'+1 			/* need the plus one for the constant */
	local x1alllast : word `numx1all' of `x1all'

	*now get first and last x2 variables, as well as k2
	local x2allfirst : word 1 of `x2all'
	local k2 : word count `x2all'
	local x2alllast : word `k2' of `x2all'

	tempname xyxy xx xxinv x1x1 x1x1inv xy x1y x1x2

	if "`iv'"=="" { /* no instruments */
	
		qui mat accum `xyxy' = `depvar' `x1all' `x2all' `weight' if `touse'
		local n = r(N)

		*total sum of squares
		local sst = `xyxy'[1,1]
	
		*stuff for unrestricted regression
		mat `xx'    = `xyxy'["`x1allfirst'".."_cons","`x1allfirst'".."_cons"]
		mat `xxinv' = syminv(`xx')
		mat `xy'    = `xyxy'["`x1allfirst'".."_cons","`depvar'"]
	
		*stuff for restricted regression
		mat `x1x1'    =    (`xyxy'["`x1allfirst'".."`x1alllast'","`x1allfirst'".."`x1alllast'"] , /*
			*/		 `xyxy'["`x1allfirst'".."`x1alllast'","_cons"] ) \ /*
			*/ 	   (`xyxy'["_cons","`x1allfirst'".."`x1alllast'"] , `xyxy'["_cons","_cons"] ) 
	
		mat `x1x1inv' = syminv(`x1x1')
		mat `x1y'    = `xyxy'["`x1allfirst'".."`x1alllast'","`depvar'"] \ `xyxy'["_cons","`depvar'"] 
	
		*stuff for Gamma: has to be inside the no-instruments block: we use x1x2=x1pzx2 in iv case
		mat `x1x2'	= `xyxy'["`x1allfirst'".."`x1alllast'","`x2allfirst'".."`x2alllast'"] \ /*
			*/		`xx'[ "_cons" , "`x2allfirst'" .. "`x2alllast'"]
	
	} 
	else { /* we have instruments for x1 (this code won't handle instruments for x2) */
	
		*now get first and last x1endog variables, as well as numiv
		local x1endogfirst : word 1 of `x1endog'
		local numx1endog   : word count `x1endog'
		local x1endoglast  : word `numx1endog' of `x1endog'
	
		*now get first and last x1exog variables, as well as numiv
		if "`x1exog'"~="" {
			local x1exogfirst : word 1 of `x1exog'
			local numx1exog   : word count `x1exog'
			local x1exoglast  : word `numx1exog' of `x1exog'
		}
		else local numx1exog=0
		
		*now get first and last iv variables, as well as numiv for restricted case
		local ivfirst : word 1 of `iv'
		local numiv   : word count `iv'
		local ivlast  : word `numiv' of `iv'
	
		if `numiv'<`numx1endog' { /* check the order condition */
			di _new "The model appears to be under-identified: "
			di "there are only `numiv' linearly independent exogenous x1 variables and IVs,"
			di      "and there are " `numx1' " non-constant variables in x1".
			exit
		} 
	
		tempname xzyxzy
		qui mat accum `xzyxzy' = `depvar' `x1endog' `x1exog' `iv' `x2all' `weight' if `touse'
		local n = r(N)       

		*total sum of squares
		local sst = `xzyxzy'[1,1]
	
		*stuff for restricted regression: we actually want x1Pzx1
		tempname x1endogx1endog
		mat `x1endogx1endog' = `xzyxzy'["`x1endogfirst'".."`x1endoglast'","`x1endogfirst'".."`x1endoglast'"]
	
		tempname x1endogiv ivx1endog
		mat `x1endogiv' = `xzyxzy'["`x1endogfirst'".."`x1endoglast'","`ivfirst'".."`ivlast'"] 
		mat `ivx1endog' = `x1endogiv''
	
		tempname conscons
		mat `conscons'	 	= `xzyxzy'["_cons","_cons"]
	
		tempname consx1endog x1endogcons
		mat `consx1endog'	= `xzyxzy'["_cons","`x1endogfirst'".."`x1endoglast'"]
		mat `x1endogcons'	= `consx1endog''
	
		tempname consiv ivcons
		mat `consiv'	 	= `xzyxzy'["_cons","`ivfirst'".."`ivlast'"]
		mat `ivcons'		= `consiv''
	
		tempname x1endogx1exog x1exogx1endog x1exogx1exog ivx1exog x1exogiv consx1exog x1exogcons
		if "`x1exogfirst'"~="" { /* no exogenous covariates in base specification */
			mat `consx1exog'	= `xzyxzy'["_cons","`x1exogfirst'".."`x1exoglast'"]
			mat `x1exogcons'	= `consx1exog''
	
			mat `x1endogx1exog' = `xzyxzy'["`x1endogfirst'".."`x1endoglast'","`x1exogfirst'".."`x1exoglast'"]
			mat `x1exogx1endog' = `x1endogx1exog''
		
			mat `x1exogx1exog' = `xzyxzy'["`x1exogfirst'".."`x1exoglast'","`x1exogfirst'".."`x1exoglast'"]
			mat `ivx1exog' 	= `xzyxzy'["`ivfirst'".."`ivlast'","`x1exogfirst'".."`x1exoglast'"]
			mat `x1exogiv' 	= `ivx1exog''
		} /* done dealing with x1exog stuff */
	
		tempname iviv
		mat `iviv'     	= `xzyxzy'["`ivfirst'".."`ivlast'","`ivfirst'".."`ivlast'"]
	
		*base specification stuff
		tempname x1z zx1 zz zzinv
		
		if "`x1exogfirst'"=="" { /* base spec has no exog covariates */
			mat `x1z' 	= /*
				*/		( `x1endogiv' 	, `x1endogcons'	) \ /*
				*/		( `consiv'  	, `conscons'	) 
		
		
			mat `zz'	= /*
				*/		( `iviv'     	, `ivcons'   	) \ /*
				*/		( `consiv' 	, `conscons'	) 
		}
		else {  /* base spec has at least one exog covariate */
			mat `x1z' 	= /*
				*/		( `x1endogiv' 	, `x1endogx1exog' , `x1endogcons'	) \ /*
				*/		( `x1exogiv'  	, `x1exogx1exog'  , `x1exogcons' 	) \ /*
				*/		( `consiv'  	, `consx1exog'    , `conscons' 		) 
		
		
			mat `zz'	= /*
				*/		( `iviv'     	, `ivx1exog'	, `ivcons'	   	) \ /*
				*/		( `x1exogiv' 	, `x1exogx1exog', `x1exogcons'		) \ /*
				*/		( `consiv' 	, `consx1exog'	, `conscons'		) 
		} /* done making x1z and zz */
	
		mat `zx1' 	= `x1z''
		mat `zzinv' 	= syminv(`zz')
	
	
		*x2 stuff from mataccum results
		tempname ivx2 x2iv x1endogx2 x2x1endog x2x2 x2cons consx2
		mat `ivx2'		= `xzyxzy'["`ivfirst'".."`ivlast'","`x2allfirst'".."`x2alllast'"]
		mat `x2iv'		= `ivx2''
	
		mat `x1endogx2' 	= `xzyxzy'["`x1endogfirst'".."`x1endoglast'","`x2allfirst'".."`x2alllast'"]
		mat `x2x1endog'		= `x1endogx2''
	
		mat `x2x2'		= `xzyxzy'["`x2allfirst'".."`x2alllast'","`x2allfirst'".."`x2alllast'"]
		mat `x2cons'		= `xzyxzy'["`x2allfirst'".."`x2alllast'","_cons"]
		mat `consx2'		= `x2cons''
	
		tempname x1exogx2 x2x1exog zx2
		if "`x1exogfirst'"=="" { /* at no exogenous covariates in base specification */
			mat `zx2' 	= `ivx2' \ `consx2'
		}
		else { /* at least one exogenous covariate in base specification */
			mat `x1exogx2' 	= `xzyxzy'["`x1exogfirst'".."`x1exoglast'","`x2allfirst'".."`x2alllast'"]
			mat `x2x1exog'	= `x1exogx2''
	
			mat `zx2' 	= `ivx2' \ `x1exogx2' \ `consx2'
		} /* done with exog covariate stuff */
	
	
		tempname XZ ZX ZZ ZZinv
		if "`x1exogfirst'"=="" { /* base spec has no exog covariates */
			mat `XZ' 	= /*
				*/		( `x1endogiv'	,  `x1endogx2'	, `x1endogcons'	) \ /*
				*/		( `x2iv'	,  `x2x2' 	, `x2cons' 	) \ /*
				*/		( `consiv'	,  `consx2' 	, `conscons' 	)
		
			mat `ZZ' 	= /*
				*/		( `iviv'     	, `ivx2'	, `ivcons'	) \ /*
				*/	 	( `x2iv' 	, `x2x2'	, `x2cons'	) \ /*
				*/	 	( `consiv' 	, `consx2'	, `conscons'	) 
		}
		else { /* base specification has at least one exog covariate */
			mat `XZ' 	= /*
				*/	( `x1endogiv'	, `x1endogx1exog', `x1endogx2'	, `x1endogcons'	) \ /*
				*/	( `x1exogiv' 	, `x1exogx1exog' , `x1exogx2' 	, `x1exogcons' 	) \ /*
				*/	( `x2iv'	, `x2x1exog'     , `x2x2' 	, `x2cons' 	) \ /*
				*/	( `consiv'	, `consx1exog'   , `consx2' 	, `conscons' 	)
		
			mat `ZZ' 	= /*
				*/	( `iviv'     	, `ivx1exog'    , `ivx2'	, `ivcons'	) \ /*
				*/	( `x1exogiv' 	, `x1exogx1exog', `x1exogx2'	, `x1exogcons'	) \ /*
				*/	( `x2iv' 	, `x2x1exog' 	, `x2x2'	, `x2cons'	) \ /*
				*/	( `consiv' 	, `consx1exog' 	, `consx2'	, `conscons'	) 
		}
		mat `ZX' 	= `XZ''
		mat `ZZinv' 	= syminv(`ZZ')
	
	
		*depvar stuff from mataccum results
		tempname ivy x2y consy x1exogy
		mat `ivy' 	= `xzyxzy'["`ivfirst'".."`ivlast'","`depvar'"]
		mat `x2y' 	= `xzyxzy'["`x2allfirst'".."`x2alllast'","`depvar'"]
		mat `consy' 	= `xzyxzy'["_cons","`depvar'"]
	
		tempname zy Zy
		if "`x1exogfirst'"=="" { /* no exogenous covariates in base specification */
			mat `zy' 	= `ivy' 	\ `consy'
			mat `Zy' 	= `ivy' \ `x2y' \ `consy'
		}
		else {
			mat `x1exogy' 	=  `xzyxzy'["`x1exogfirst'".."`x1exoglast'" , "`depvar'"] 
			mat `zy' 	= `ivy' \ `x1exogy' 		\ `consy'
			mat `Zy' 	= `ivy' \ `x1exogy' \ `x2y'   	\ `consy'
		} /* done with exog covariate stuff */
	
	
	
	
		*key matrices: base specification
		tempname x1pzx1 x1pzx1inv x1pzy 
		mat `x1pzx1'	= `x1z'*`zzinv'*`zx1'
		mat `x1pzx1inv'	= syminv(`x1pzx1')
		mat `x1pzy'	= `x1z'*`zzinv'*`zy'
	
		*renaming so that we can recycle code below for the no-instruments case
		mat `x1x1'	= `x1pzx1'
		mat `x1x1inv'	= `x1pzx1inv'
		mat `x1y'	= `x1pzy'
	
		*key matrices: full specification
		tempname XPZX XPZXinv XPZy
		mat `XPZX'	= `XZ'*`ZZinv'*`ZX'
		mat `XPZXinv'	= syminv(`XPZX')
		mat `XPZy'	= `XZ'*`ZZinv'*`Zy'
	
		*renaming so that we can recycle code below for the no-instruments case
		mat `xx'	= `XPZX'
		mat `xxinv'	= `XPZXinv'
		mat `xy'	= `XPZy'
	
	
		*create x1pzx2 and then rename to x1x2
		tempname x1pzx2 
		mat `x1pzx2' 	= `x1z'*`zzinv'*`zx2'
		mat `x1x2'	= `x1pzx2'
	
	
	} /* end iv conditional */
	
	local rowsofxx=rowsof(`xx')
	local df = `n'-`rowsofxx'

	local rowsofx1x1=rowsof(`x1x1')
	local dfr = `n'-`rowsofx1x1'

	*actual coef estimates
	tempname bu b1u b2u b1r Gamma delta 
	mat `bu'    = (`xxinv'*`xy')'					/* this has to be a row vector */

	if "`iv'"=="" 	mat `b1u'   = `bu'[1,"`x1allfirst'".."`x1alllast'"] , `bu'[1,"_cons"]
	else    	mat `b1u'   = /*
		*/ `bu'[1,"`x1endogfirst'".."`x1endoglast'"] ,  `bu'[1,"_cons"]

	mat `b2u'   = `bu'[1,"`x2allfirst'".."`x2alllast'"]
	mat `b1r'   = (`x1x1inv'*`x1y')'				/* this has to be a row vector */
	mat `Gamma' = (`x1x1inv'*`x1x2')
	mat `delta' = `b2u'*`Gamma''					/* this has to be a row vector */

	tempvar yhat ehat yhatr ehatr
	qui mat score double `yhat' = `bu' if `touse'
	qui gen       double `ehat' = `depvar' - `yhat' if `touse'

	qui mat score double `yhatr' = `b1r' if `touse'
	qui gen       double `ehatr' = `depvar' - `yhatr' if `touse'
	*****************************************************
	**** END DOING CROSS-PRODUCT STUFF FOR ESTIMATES ****
	*****************************************************

	*****************************
	***BEGIN VARIANCE MATRICES***
	*****************************
	tempname bxy bx1y vu v1r v1u v2u
	if "`robust'`cluster'"=="" { /* do sum of sqs and we're there */

		*unrestricted
		tempvar ehat2
		qui gen double `ehat2' = `ehat'^2 if `touse'
                qui sum `ehat2' `weight' if `touse'
		*local weightsum = _result(2)**need to use result(1) instead to get things right with weights
		local weightsum = _result(1)
		local ehat2mean = _result(3)
                local sse	= `ehat2mean'*`weightsum'

		tempname s2u 
	    	scalar `s2u' = `sse'/(`n'-`rowsofxx')
		mat `vu' = `s2u'*`xxinv'	       

		*restricted
		tempvar ehatr2
		qui gen double `ehatr2' = `ehatr'^2 if `touse'
		qui sum `ehatr2' `weight' if `touse'
		*local weightsumr = _result(2)**need to use result(1) instead to get things right with weights
		local weightsumr = _result(1)
		local ehatr2mean = _result(3)
		local sser	= `ehatr2mean'*`weightsum'

		tempname s2r 
	    	scalar `s2r' = `sser'/(`n'-`rowsofx1x1')
		mat `v1r' = `s2r'*`x1x1inv'	       
	}
	else { /* need to do robust */

		if "`iv'"==""{ /* no instruments */

			*unrestricted
			mat `vu' = `xxinv'
	                _robust `ehat' `weight' if `touse' , v(`vu') minus(`rowsofxx') `cluster'
			local N_clust = r(N_clust)
	
			*restricted
			mat `v1r' = `x1x1inv'
        	        _robust `ehatr' `weight' if `touse' , v(`v1r') minus(`rowsofx1x1') `cluster'
		}
		else { /* instruments */
		
			*unrestricted
			tempname ZehatehatZ
			mat `ZehatehatZ' = `ZZinv'
			local rowsofZZ = rowsof(`ZZ')
			_robust `ehat' `weight' if `touse' , v(`ZehatehatZ') minus(`rowsofZZ') `cluster'
			mat `vu' = `XPZXinv'*`XZ'*`ZehatehatZ'*`ZX'*`XPZXinv'
			local N_clust = r(N_clust)

			*restricted
			tempname zehatehatz
			mat `zehatehatz' = `zzinv'
			local rowsofzz = rowsof(`zz')
			_robust `ehatr' `weight' if `touse' , v(`zehatehatz') minus(`rowsofzz') `cluster'
			mat `v1r' = `x1pzx1inv'*`x1z'*`zehatehatz'*`zx1'*`x1pzx1inv'
		} /* done with instruments case for robust variance estimation */
	} /* done with variance of unrestricted and restricted regressions */

	*get part of `vu' that has to do with x1
	mat `v1u' =  (`vu'["`x1allfirst'".."`x1alllast'" , "`x1allfirst'".."`x1alllast'"] , /*
		  */   `vu'["`x1allfirst'".."`x1alllast'" , "_cons"]) \ /* 
		  */ (`vu'["_cons"                , "`x1allfirst'".."`x1alllast'"] , `vu'["_cons","_cons"])

	*get part of `vu' that has to do with x2
        mat `v2u' = `vu'["`x2allfirst'".."`x2alllast'" , "`x2allfirst'".."`x2alllast'"]
	***************************
	***END VARIANCE MATRICES***
	***************************


	******************************************
	**** BEGIN SETTING UP AUX REGRESSIONS ****
	******************************************
	local g=0
	local x1=0
	local x2=0

	local colnamesmvregdelta ""

	foreach groupname in `groupnames' { /* setting up aux regressions by group */

		local g = `g'+1

		foreach x1 in `x1all' _cons { /* loop to make colnames for `mvregdelta' */
			local colnamesmvregdelta "`colnamesmvregdelta' `groupname':`x1'"
		} /* end loop to make colnames for `mvregdelta' */

		tempvar Hhat`g'
		qui gen double `Hhat`g'' = 0 if `touse'==1
		local cout = 0  	

		foreach element in `grouplist`g'' { /* loop over elements of this group to calculate Hhat^g */

			local cout = `cout'+1
			* counter for total number of x2 vars, over all groups. need this for `Gamma' indexing
			local x2 = `x2'+1     

			tempname dumbmat
			mat `dumbmat' = `b2u'[1,"`element'"]
			local belement = `dumbmat'[1,1]
                        qui replace `Hhat`g'' = `Hhat`g'' + `element'*`belement' if `touse'==1

		} /* end loop over elements of this group */


	} /* end setting up aux regressions */

	*initializing `Bigmat'
	tempname Bigmat zeros1 zeros2
        mat `Bigmat' = J(`k1',max(1,`k2'-`ngrouplist1'),0)
	local sofar 0

	*initializing
	local start 1
	local end   0
	forvalues g=1/`numgroups' { /* loop over g to pull out gamma`g' and create Bigmat */

		*now pulling out Gamma`g' 
		local end = `start' + `ngrouplist`g'' - 1
		tempname gamma`g'
		mat `gamma`g'' = `Gamma'[1...,`start'..`end']
		mat roweq `gamma`g'' = `groupname`g''	
		mat rownames `gamma`g'' = `x1all' _cons

		/* now we create that big matrix involving group-specific cols of Gamma.....
			      
													      
			Bigmat = (Gamma1, Zeros) \ (Zeros, Gamma2, Zeros) \ ... \ (Zeros, Gamma`numgroups'), 
													      
				 where "Zeros" indicates a matrix of zeros with `k1' rows 
													      
			Number of leading columns of zeros is						
													
				* For group `g'=1: 		none					
				* For group `g'=`numgroups' : 	`k2'-`ngrouplist`numgroups''		
				* For other cases :  		sum_h<`g' `ngrouplist`g''		
													
													
			Number of trailing columns of zeros is						
													
				* For group `g'=1: 		`k2'-`ngrouplist1'			
				* For group `g'=`numgroups' : 	none					
				* For other cases :  		sum_h>`g' `ngrouplist`g''		
													
		        Then we create Vnew = Bigmat*`v2u'*Bigmat', and that is the addition to the cov matrix
		*/                                                                                            

		if (`g'==1 & `numgroups'==1) { /* user specified only 1 group, so set Bigmat equal to Gamma */
			mat `Bigmat' = `Gamma'
		}
		else if (`g'==1) {
			mat `Bigmat' = `gamma`g'' , `Bigmat'
		}
		else if (`g'<`numgroups') {
                        mat `zeros1' = J(`k1',`sofar',0)
                        mat `zeros2' = J(`k1',`k2'-(`sofar'+`ngrouplist`g''),0)
			mat rownames `zeros1' = `x1all'
			mat roweq `zeros1' = `groupname`g''	
			mat `Bigmat' = `Bigmat' \ (`zeros1' , `gamma`g'' , `zeros2' ) 
		}
		else {
			mat `zeros1' = J(`k1',`sofar',0)
			mat roweq `zeros1'   = `groupname`g''	
			mat rownames `zeros1' = `x1all'
			mat `Bigmat' = `Bigmat' \ (`zeros1' , `gamma`g'')
		}

		*setting for next group
		local sofar = `sofar' + `ngrouplist`g''
		local start = `end'+1
	} /* end loop over g to pull out gamma`g' and create Bigmat */
	****************************************
	**** END SETTING UP AUX REGRESSIONS ****
	****************************************


	****************************************************************************************
	**** BEGIN HAND-CALCULATING AUX REGRESSION COEFS/COV MATRIX IN JOINT MODEL WITH b2u ****
	****************************************************************************************
	local residstring ""
	tempname mvregdelta
	mat `mvregdelta'=J(1,`k1'*`numgroups',0)
	forvalues g=1/`numgroups' { /* looping over groups to construct decomp coefs (mvregdelta) */
	
		tempname hhataccum`g' coefrowvec

		if "`iv'"=="" { /* no instruments */
			qui mat vecaccum `hhataccum`g'' = `Hhat`g'' `x1all' `weight' if `touse'==1
			mat `coefrowvec' = `hhataccum`g''*`x1x1inv'
		}
		else { /* instruments */
			qui mat vecaccum `hhataccum`g'' = `Hhat`g'' `iv' `x1exog' `weight' if `touse'==1
			mat `coefrowvec' = `hhataccum`g''*`zzinv'*`zx1'*`x1x1inv'
		}

		*calculate fitted residuals
		tempvar fitted`g' residual`g'
		qui mat score double `fitted`g'' = `coefrowvec'
		qui gen double `residual`g'' = `Hhat`g''-`fitted`g''
		qui drop `fitted`g''
	
		local residstring "`residstring' `residual`g''"
	
		local firstcol=1+(`g'-1)*`k1'
		mat `mvregdelta'[1,`firstcol'] = `coefrowvec'
		mat drop `coefrowvec' `hhataccum`g''
	
		foreach x1 in `x1all' _cons { /* looping over x1 vars to construct mvregdelta_names */
			local name = rtrim("`groupname`g''")
			local mvregdelta_names "`mvregdelta_names' `name':`x1'"
		} /* end looping over x1 vars to construct mvregdelta_names */
	} /* end looping over groups to construct decomp coefs (mvregdelta) */
	
	mat colnames `mvregdelta' = `mvregdelta_names'
	
	*making long row vector with all unrestricted reg coefs followed by decomp coefs
	tempname budummy mvregdeltalong
	mat `budummy'=`bu'
	mat colnames `budummy' = __UN__:
	mat `mvregdeltalong' = `budummy',`mvregdelta'
	mat drop `budummy'
	
	tempname xxbig xxbiginv
	mat `xxbig' = 	    (`xx'                            , J(`k1'+`k2',`k1'*`numgroups',0) ) \ /*
			*/  (J(`k1'*`numgroups',`k1'+`k2',0) , I(`numgroups')#`x1x1'           )
	local mvregdeltalong_names : colfullnames `mvregdeltalong'
	mat rownames `xxbig' = `mvregdeltalong_names'
	mat colnames `xxbig' = `mvregdeltalong_names'
	mat `xxbiginv' = syminv(`xxbig')
	
	*calculate cov matrix
	tempname auxregV Cbigaux 
	if "`robust'`cluster'"=="" {
		
		*construct covariance of residuals as a (G+1)x(G+1) matrix 
		*and then form appropriate matrix to pre-multiply by xxbiginv
		tempname residaccum 
		qui mat accum `residaccum' = `ehat' `residstring' `weight' if `touse', deviations nocons

		*don't really need df correction, but use it for consistency with Stata's reported results
		mat `residaccum'=`residaccum'/(r(N)-`k1'-`k2')	
	
		tempname Sigma_vbeta
		mat `Sigma_vbeta' = `residaccum'[2...,1]
	
		mat `Cbigaux' = J(`k1'+`k2'+`numgroups'*`k1',`k1'+`k2'+`numgroups'*`k1',0)

		*upper left  block of cov matrix for big aux regression 
		mat `Cbigaux'[1,1] = `residaccum'[1,1]*`xxinv' 

		* lower left  block of cov matrix for big aux regression 
		mat `Cbigaux'[1+`k1'+`k2',1          ] = `Sigma_vbeta' # ( ( I(`k1') , `Gamma' ) * `xxinv' )

		*upper right block of cov matrix for big aux regression (note trailing transpose symbol)
		mat `Cbigaux'[1          ,1+`k1'+`k2'] = `Sigma_vbeta'' # ( ( I(`k1') , `Gamma' ) * `xxinv' )'

		*lower right block of cov matrix for big aux regression 
		mat `Cbigaux'[1+`k1'+`k2',1+`k1'+`k2'] = `residaccum'[2...,2...]#`x1x1inv'		      
	
		mat rownames `Cbigaux' = `mvregdeltalong_names'
		mat colnames `Cbigaux' = `mvregdeltalong_names'
	
		mat `auxregV' = `Cbigaux'[1+`k1'+`k2'...,1+`k1'+`k2'...]
	
	}
	else { /* robust/cluster calculation */
		
		if "`iv'"=="" { /* no instruments */

			*doing robust calculation....`xxbiginv' will contain resulting robust cov matrix
		        _robust `ehat' `residstring' `weight' if `touse' , v(`xxbiginv') `cluster'
			mat `Cbigaux' = `xxbiginv' 	/* just renaming for mnemonic ease */
			mat drop `xxbiginv' 
	
			mat `auxregV' = `Cbigaux'[1+`k1'+`k2'...,1+`k1'+`k2'...]
		}
		else { /* instruments */

			/* Here's how to think of this. Define D as

				D = 	( Z  ,  0  ) 
					( 0  , I#z),

			   where Z is the full matrix of all exog variables in the full specification,
			   and   z is the matrix of all exog variables in the base specification (no x2).

			   Define W =   ( X  ,  0  )
					( 0  , I#x1),

			   where X is the full matrix of all endogenous and exogenous explanatory variables, 
			   while x1 is the matrix of only the base-specification explanatory variables.

			   Finally, define Y = (y', hhat1', ... , hhatG')', which is the stacked vector
			   of the depvar and all auxiliary heterogeneity terms.

			   The vector of all coefficient estimates can be written as

				Thetahat = (W'PdW)^{-1}W'PdY,

			   so that the cluster-robust covariance estimator is

				(W'PdW)^{-1}W'D(D'D)^{-1}D'UhatUhat'D(D'D)^{-1}D'W(W'PdW)^{-1}.

			   We can use _robust to get (D'D)^{-1}D'UhatUhat'D(D'D)^{-1}. 
                           This is done using the matrix DD below.

			   To get the other matrices, we just have to compute D'D and W'D, since
                           W'PdW = W'D(D'D)^{-1}D'W, and 

				W'D = 	( X'Z	,  0 	)
					(  0 	, I#x1'z)

				D'D = 	( Z'Z	,  0	)
					(  0	, I#z'z	)

			*/

			local colsofZ   = `numiv'+`numx1exog'+`k2'+1
			local colsofz   = `numiv'+`numx1exog'+1
			local colsofX  = `k1'+`k2'
			local colsofx1 = `k1'

			tempname WD DW DDinv
			mat `WD' = 	( `XZ'		   	 , J(`colsofX',`colsofz'*`numgroups',0)) \ /*
				*/	( J(`colsofx1'*`numgroups',`colsofZ',0) , I(`numgroups')#`x1z' )
			mat `DW' = `WD''

			mat `DDinv' = 	( `ZZinv'	      , J(`colsofZ',`numgroups'*`colsofz',0)) \ /*
				*/	( J(`colsofz'*`numgroups',`colsofZ',0)  , I(`numgroups')#`zzinv' )

			tempname WPdWinv
			mat `WPdWinv' 	= syminv(`WD'*`DDinv'*`DW')

			tempname XZdummy ZZdummy /* these are just to mess around with matrix stripes */
			mat `XZdummy' = `XZ'

			*set the equation names
			mat roweq `XZdummy' = __UN__:
			mat coleq `XZdummy' = __UN__:

			*get names of x1z
			local rownamesx1z : rownames `x1z'
			local colnamesx1z : colnames `x1z'

			*initialize namesWD 
			local rownamesWD : rowfullnames `XZdummy'
			local colnamesWD : colfullnames `XZdummy'

			forvalues g=1/`numgroups' {

				*WD
				local thisrowstripe
				foreach rowvar in `rownamesx1z' {
					local eqname  = trim("`groupname`g''")
					local varname = trim("`rowvar'")
					local thisrowstripe "`thisrowstripe' `eqname':`rowvar' "
				}

				local thiscolstripe
				foreach colvar in `colnamesx1z' {
					local eqname  = trim("`groupname`g''")
					local varname = trim("`colvar'")
					local thiscolstripe "`thiscolstripe' `eqname':`colvar' "
				}

				local rownamesWD "`rownamesWD' `thisrowstripe' "
				local colnamesWD "`colnamesWD' `thiscolstripe' "

				*DD
				local thisrowstripe
				foreach rowvar in `rownameszz' {
					local eqname  = trim("`groupname`g''")
					local varname = trim("`rowvar'")
					local thisrowstripe "`thisrowstripe' `eqname':`rowvar' "
				}

				local thiscolstripe
				foreach colvar in `colnameszz' {
					local eqname  = trim("`groupname`g''")
					local varname = trim("`colvar'")
					local thiscolstripe "`thiscolstripe' `eqname':`colvar' "
				}

				local rownamesWD "`rownamesWD' `thisrowstripe' "
				local colnamesWD "`colnamesWD' `thiscolstripe' "
			}

			mat rownames `WD' = `rownamesWD'
			mat colnames `WD' = `colnamesWD'

			mat rownames `DDinv'   = `colnamesWD'	/* this isn't a typo: need the *col*names */
			mat colnames `DDinv'   = `colnamesWD'

			mat rownames `WPdWinv' = `rownamesWD'
			mat colnames `WPdWinv' = `rownamesWD'	/* this isn't a typo: need the *row*names */

			*doing robust calculation....`DDbiginv' will contain resulting robust cov matrix
		        _robust `ehat' `residstring' `weight' if `touse' , v(`DDinv') `cluster'
			mat `Cbigaux' = `WPdWinv'*`WD'*`DDinv'*`DW'*`WPdWinv'
			mat drop `DDinv' `WD' `DW'
	
			mat `auxregV' = `Cbigaux'[1+`k1'+`k2'...,1+`k1'+`k2'...]

		} /* end instruments */
	
	} /* end robust/cluster calculation */
	**************************************************************************************
	**** END HAND-CALCULATING AUX REGRESSION COEFS/COV MATRIX IN JOINT MODEL WITH b2u ****
	**************************************************************************************
	

	*******************************************
	**** BEGIN FINAL VARIANCE CALCULATION *****
	*******************************************
	*name `Bigmat'
	mat rownames `Bigmat' = `colnamesmvregdelta'
	mat colnames `Bigmat' = `x2deltalist'


	*calculate part of the cov matrix that has to do with variance in b2u
	tempname v2upart
	mat `v2upart' = `Bigmat'*`v2u'*`Bigmat''

	tempname fullcov
	*calculate full cov matrix: sum of two variance parts, 
	*unless user specified to set Gamma=0, in which case `v2upart'=0

	*no  v2upart, no cov between b2hat and dhat
	if "`gamma0'"=="gamma0"    	mat `fullcov' = `auxregV'
	else if "`cov0'"=="cov0"	mat `fullcov' = `auxregV' + `v2upart' /*yes v2upart, nocov(b2,d) */
	else if "`specialvar'"=="specialvar" mat `fullcov' = `v2upart'
	else { /* dealing with case where user wants to include all four matrices in variance definition */

		*have to get the relevant sub-blocks out of lower left and upper right blocks of `Cbigaux'
		tempname covterms
		mat `covterms' = J(`k1'*`numgroups',`k1'*`numgroups',0)
		mat rownames `covterms' = `mvregdelta_names'
		mat colnames `covterms' = `mvregdelta_names'
		local g=0
		foreach group_g in `groupnames' { /* outer loop over groups to populate cov-terms matrix */

			local g=`g'+1
			local group_g_first : word 1 		   of `grouplist`g''
			local group_g_last  : word `ngrouplist`g'' of `grouplist`g''

			local h=0
			foreach group_h in `groupnames' { /* outer loop over groups to pop cov-terms matrix */

				local h=`h'+1
				mat `covterms'[1+(`g'-1)*`k1',1+(`h'-1)*`k1'] = /*
						*/ `gamma`g''* /*
						*/ `Cbigaux'["__UN__:`group_g_first'".."__UN__:`group_g_last'","`group_h':"]

			} /* end inner loop over groups to populate covariance-terms matrix */
		} /* end outer loop over groups to populate covariance-terms matrix */

		mat `fullcov' = `auxregV' + `v2upart' + `covterms' + `covterms''

	} /* end dealing with case where user wants to include all four matrices in variance definition */
	*****************************************
	**** END FINAL VARIANCE CALCULATION *****
	*****************************************


	*********************************************************************************************
	**** BEGIN GETTING RESULTS AND COV FOR TOTAL CHANGE                                      ****
	**** (THIS IS NEC B/C A USER MIGHT HAVE REQUESTED DECOMP FOR A STRICT SUBSET OF X2 VARS) ****
	*********************************************************************************************
	tempvar _tc						  
        qui mat score double `_tc' = `b2u' if `touse' 
        qui reg `_tc' `x1all' `weight' if `touse' `comma' `robust' `cluster'
								  
	tempname _tcregpart __TCcov __TCb

	*get the delta vector for total-change case
	mat `__TCb' = e(b)				  
	mat coleq `__TCb' = __TC

	*get part of var of total-change delta vector that's due to variance in gamma, holding b2u constant
	mat `_tcregpart' = e(V)					  

	*add the part of the variance that's due to variance in b2u, holding gamma constant
	if "`gamma0'"==""	      mat `__TCcov' =  `_tcregpart' + `Gamma'*`v2u'*`Gamma''
	else if "`gamma0'"=="gamma0"  mat `__TCcov' =  `_tcregpart'

	*give __TCcov matrix correct eqnames (row/colnames are created properly when the matrix is created)
	mat coleq `__TCcov' = __TC
	mat roweq `__TCcov' = __TC
	*********************************************************************************************
	**** END GETTING RESULTS AND COV FOR TOTAL CHANGE                                        ****
	**** (THIS IS NEC B/C A USER MIGHT HAVE REQUESTED DECOMP FOR A STRICT SUBSET OF X2 VARS) ****
	*********************************************************************************************


	**************************************************
	**** BEGIN SWITCHING EQNAMES AND COL/ROWNAMES ****
	**************************************************
	*Note: need `mvregdelta' and `fullcov' as separate from `Delta' and `Covdelta' b/c of order switching 
	*need Delta and Covdelta to deal with reordering of elements of mvregdelta and fullcov, 
	*which is part of interchanging eqnames and row/colnames
	tempname Delta Covdelta zeros
	mat `Delta'    = `mvregdelta' 
	mat `Covdelta' = `fullcov'

	*initializing
	local colcount    = 0
	local Deltanames 

	foreach x1col in `x1all' _cons { /* col loop over x1 varnames */
		foreach groupcol in `groupnames' { /* col loop over groupnames */

			local colcount = `colcount'+1

                        mat `Delta'[1,`colcount'] = `mvregdelta'[1,colnumb(`mvregdelta',"`groupcol':`x1col'")]
			local Deltanames "`Deltanames' `x1col':`groupcol'"

			local rowcount=0
			foreach x1row in `x1all' _cons { /* row loop over x1 varnames */
				foreach grouprow in `groupnames' { /* row loop over groupnames */

					local rowcount = `rowcount'+1
                                        mat `Covdelta'[`rowcount',`colcount'] = `fullcov'[rownumb(`fullcov',"`grouprow':`x1row'"),colnumb(`fullcov',"`groupcol':`x1col'")]

				} /* end row loop over groupnames */
			} /* end row loop over x1 varnames */
		} /* end looping over groupnames */
	} /* end looping over x1 varnames */

*	mat `Delta' = -1*`Delta' /* correcting the sign so that we get b1u-b1r instead of opposite */

	mat colnames `Delta'    = `Deltanames'
	mat colnames `Covdelta' = `Deltanames'
        mat rownames `Covdelta' = `Deltanames'

	*now adding on total-change part (__TC)
	tempname Rg R
	mat `Rg' = I(`numgroups') \ J(1,`numgroups',1)
	mat `R'  = I(`k1')#`Rg'

	local Rnamesrows
	local Rnamescols
	foreach x1 in `x1all' _cons { /* looping over x1 names */
		foreach group in `groupnames' { /* looping over groupnames to make eqnames for `R' */

			local Rnamescols "`Rnamescols' `x1':`group'"
			local Rnamesrows "`Rnamesrows' `x1':`group'"
		} /* end looping over x1 names */

		local Rnamesrows "`Rnamesrows' `x1':__TC"
	} /* end looping over groupnames to make eqnames for `R' */

	mat rownames `R' = `Rnamesrows'
	mat colnames `R' = `Rnamescols'

	mat `Delta'    = `Delta'*`R''
	mat `Covdelta' = `R'*`Covdelta'*`R''
	************************************************
	**** END SWITCHING EQNAMES AND COL/ROWNAMES ****
	************************************************


	************************************************
	** EXTRACTING PART RELATED TO X1ONLY, IF USED **
	************************************************

	if "`x1only'"~="" {
		mat `Delta' = `Delta'[1,"`x1only':"]
		mat `Covdelta' = `Covdelta'["`x1only':","`x1only':"]
	}

	*****************************
	**** FINAL DISPLAY STUFF ****
	*****************************

	di
	if "`dropped'"~="" {
		di "Dropped variables: `dropped'"
		di
	}
	di _column(55) "Number of obs = " `numobs'
	di 
	if "`iv'"~="" {
		di "X1 variables treated as exogenous in both specifications:"
		di
		di _skip(4) "`x1exog'" 
		di
		di "X1 variables treated as endogenous in both specifications:"
		di
		di _skip(4) "`x1endog'" 
		di
		di "Instruments used in both specifications:"
		di
		di _skip(4) "`iv'" 
		di
	}
	di 
	di "Restricted regression:"
	di
	if "`iv'"=="" {
		di ". b1x2: reg `depvar' `x1all' `if' `in' `weight' `comma' `robust' `cluster'"
	}
	else {
	       di ". b1x2: reg `depvar' `x1all' (`iv' `x1exog') `if' `in' `weight' `comma' `robust' `cluster'"
	}
	di

	*post short results
	if "`base'"=="" { /* user did not specify nobase option */

		tempname b1rpost v1rpost short
		mat `b1rpost' = `b1r'
		mat `v1rpost' = `v1r'

		tempvar tousepost 
		qui gen `tousepost' = `touse'

		ereturn post `b1rpost' `v1rpost', obs(`numobs') depname(`depvar') esample(`tousepost')
		ereturn display
	} 
	else {
		di
		di "You requested that the restricted regression results not be displayed."
		di "They will be available in e(b1r) and e(V1r)."
		di
		
	} /* end nobase option */

	
	di
	if "`dropped'"~="" {
		di "Dropped variables: `dropped'"
		di
	}
	di "Unrestricted regression:"
	di
	if "`iv'"=="" {
		di ". b1x2: reg `depvar' `x1all' `x2all' `if' `in' `weight' `comma' `robust' `cluster'"
	}
	else {
		di ". b1x2: reg `depvar' `x1all' `x2all' (`iv' `x1exog' `x2all') " _cont
		di "`if' `in' `weight' `comma' `robust' `cluster'"
	}

	if "`full'"=="" { /* user did not specify nofull option */

		tempname bupost vupost long

		tempvar tousepost 
		qui gen `tousepost' = `touse'

		if "`longb2'"=="" { /* user did not say to display only b1 estimates from long regression */
			mat `bupost' = `bu'
			mat `vupost' = `vu'
			ereturn post `bupost' `vupost', obs(`numobs') depname(`depvar') esample(`tousepost')
		} 
		else { /* user wants only b1 results */
			mat `bupost' = `b1u'
			mat `vupost' = `v1u'
			ereturn post `bupost' `vupost', obs(`numobs') depname(`depvar') esample(`tousepost')

			di "Displaying only b1 estimates, as you requested..."
			di
		} /* end returning long results */

		ereturn display

	} 
	else {
		di
		di "You requested that the unrestricted regression results not be displayed."
		di "They will be available in e(bu), e(bu) and e(Vufull)."
		di
	} /* end nofull option */


	di
	di "Decomposition of changes in coefficients on x1 vars:"
	di
	di _column(8) trim("`x1all'")
	di
	di "into parts due to these groups:"
	di

	forvalues g=1/`numgroups' { /* displaying groupnames and varlists */
		di "`groupname`g'' = `grouplist`g''" _new
	} /* end displaying groupnames and varlists */

	if "`dropped'"~="" {
		di
		di "Dropped variables: `dropped'"
		di
	}

	tempname Deltacopy Covdeltacopy
	mat `Deltacopy' = `Delta'
	mat `Covdeltacopy' = `Covdelta'

	*returning results
	ereturn post `Delta' `Covdelta', obs(`numobs') depname(`depvar') esample(`touse')

	eret local      groupnames      "`groupnames'"
	eret local 	cmd	  	"b1x2" 
	eret local 	depvar  	"`depvar'"
	eret local 	weight  	"`weight'"
	eret local 	if	  	"`if'"
	eret local 	in	  	"`in'"
	eret local 	cluster		"`cluster'"

        eret scalar 	N_clust	   = 	`N_clust'
	eret scalar 	N      	   =	`numobs'
	eret scalar 	k1	   =	`k1'
	eret scalar 	k2	   =	`k2'
	eret scalar 	numiv	   =    `numiv'
	eret scalar 	numx1endog =    `numx1endog'

	eret mat    	Delta	  	`Deltacopy'
	eret mat    	Covdelta	`Covdeltacopy'

	eret mat    	b1base		`b1r'
	eret mat 	V1base		`v1r'
	eret mat 	b1full		`b1u'
	eret mat 	V1full		`v1u'
	eret mat 	b2full		`b2u'
	eret mat 	V2full		`v2u'
	eret mat 	bfull		`bu'
	eret mat 	Vfull		`vu'

	ereturn display

	di
	di "Note: The __TC...  line is the sum of all x2 variables' impacts on each x1."
	di "      The reported covariance between this coef and all others is zero."
	di "      This is NOT correct!!"
	di
	di "Done with -b1x2-."
	di

end


*code to get unique list of vars from raw varlist that may have some vars repeated 
program define uniqify

	*`macname' is where we will put uniqified string
	syntax varlist

	unab string : `varlist'
	local n 0			/* counter for newstring macros */
	foreach token of local string {

	*di "token=`token'"

		if length("`newstring`n''") >= 57 { /* need to start a new string b/c of irritating stata limits on string length */
			local n = `n' + 1
		} /* end of need to start a new string b/c of irritating stata limits on string length */

		local match = 0
		foreach m of numlist 0/`n' { /* looping over newstring macros */
                        *di " -> m=`m', newstring`m'=`newstring`m''"
                        local match = `match' + match(" `newstring`m'' ", "* `token' *" )
		} /* end of looping over newstring macros */
		
		*di "token is `token' and match=`match'"

		if `match'==0 { /*not already there */
			local newstring`n' "`newstring`n'' `token'"
		} /* done with not already there */
	}

	*di "n counter is now `n'. newstring macros are...."
	foreach m of numlist 0/`n' { /* looping over newstring macros */
		local newstring "`newstring' `newstring`m''"
	} /* end of looping over newstring macros */
	
	*di "done and newstring is " _new "`newstring'"

	global uniqified "`newstring'"
*end 'uniqify' subroutine
end



*this program does scoring with column vectors, whereas stata demands row vectors
program define colscore
	syntax [if] , newvar(string) matrix(string) 

	tempname prime
	mat `prime' = `matrix''
	mat score double `newvar' = `prime' `if'

*end 'colscore' subroutine
end


program define check

	syntax anything ,  all(varlist) delta(string)

	if ~("`anything'"=="1" | "`anything'"=="2") {
		di "Programming error on -check- call"
		error jbg
	}
	else { /* correct call to -check- */
		foreach x`anything'd in `x`anything'delta' {
			foreach x`anything'a in `x`anything'all' {
	
				if "`x`anything'a'"=="`x`anything'd'" {
					continue
				}
			} /* end x`anything'all loop */
	
	
			di "Error: Variable '`x`anything'd'' is not in the 'x`anything'all' list"
			error 111

		} /* end x2delta loop */
	} /* end check */

	*we are ok

*end 'check' subroutine
end



*parse on argument of parse(), where that argument appears no more than once
program define localparse

	syntax , input(string)  parse(string)

	tokenize "`input'", parse("`parse'")
	global groupname__  "`1'"

*di "g: $groupname__"
	mac shift
	mac shift
	global grouplist__ "`*'"
*di "e: $grouplist__"

end


*shift off first token and return rest of string in gmac $grouplist__
program define localshift

	syntax varlist

	tokenize "`varlist'"
	mac shift
	global grouplist__ "`*'"

end
