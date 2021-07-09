*! Generalized Oaxaca-Blinder decomposition
*! Version 1.0.0  (01 September 2006 - prepared for London User Group Meeting)
*! Author: Tamás Bartus, Corvinus University, Budapest


program define gdecomp
	version 9

//  Checks whether latest version of margeff installed

	VerifyMargeff
	if `s(result)'==0  {
		di as error "gdecomp requires the latest version of -margeff-"
		di as error "Please install the latest version by typing:"
		di as input "     ssc install margeff, replace"
		exit
	}

	
	if `"`0'"'=="," | `"`0'"'=="" {
 		if "`e(cmd)'"!="gdecomp" {
			di as red "It is impossible to replay decomposition results"
			error 301
		}
		else {
			Replay `0'
			exit
		}
	}
	
	gettoken cmd 0 : 0 , parse(" ,")
	local l = length("`cmd'")
	if substr("graph",1,`l')==`"`cmd'"'  {
 		if "`e(cmd)'"!="gdecomp" {
			di as red "It is impossible to replay decomposition results"
			error 301
		}
		gdecomp_graph `0'
		exit
	}
	else {
		local 0 `cmd' `0'
		OnColonParse `0'
		Estimate `s(options)'
		exit
	}
end

	
program define Estimate , eclass
	version 9
	syntax varlist(max=1) ///
		[ , DXWeight(string) REVerse  ///
        eform OUTcome(string) at(string) ///
        Level(passthru) noHEADer noCOEF Dummies(string) ///
		CENter  *]

//	Estimation sample
	tempvar touse
	qui gen byte `touse' = 1 if `varlist'!=.
	GetMarkSample  `touse' `s(cmdargs)'
	qui replace `touse' = 0 if `s(touse)'==0
	qui replace `touse' = 0 if `touse'==0

//	Locals 
	local by       `varlist'
	local varlist  `s(varlist)'
	local weight   `s(weight)'
	local regopt   `s(options)'
	local cmd      `s(cmdname)'
	gettoken depvar : varlist

// SYNTAX CHECK, PROCESSING OPTIONS

	
	if "`cmd'"=="" {
		di as error "Invalid command specification: command name missing"
		error 198
	}
	
	local allow_seq  reg regr regre regres regress eform  /// 
        			 probit logit logistic cloglog  xtprobit poisson nbreg
//	local allow_meq  oprobit ologit gologit2  mlogit biprobit
//	Not supported yet because unexplained part of difference extremely high...
	local allow_meq `allow_meq' zip zinb
	foreach word in seq meq  {
		local temp : subinstr local allow_`word'  "`cmd'" "" , count(local c) word
		if `c'==1 {
			local cmdtype `word'
			continue , break
		}
	}
	if `c'==0 {
		di as error "gdecomp does not work after `cmd'"
		error 198
	}    
	if "`cmdtype'"=="meq" & "`outcome'"=="" {
		local outcome = 1
//        di as error "You should specify the outcome() option"
//        error 198
    }
	if "`cmdtype'"=="seq" & "`outcome'"!="" {
        di as input "You have specified the outcome() option, but it will be ignored"
    }
	if "`outcome'"!="" {
        local outcome outcome(`outcome')
    }
	if `"`dummmies'"'!=""	local dummies dummies(`dummies')

	tempname matrow
	capture tab `by' if `touse' , matrow(`matrow')
	if _rc==0 & r(r)!=2 {
            di as error "`by' should take exactly two values (in the estimation sample)"
            error 198
	}

	// Method - default is "high", meaning original Blinder method

	if `"`dxweight'"'=="" 			local dxweight high
	if `"`dxweight'"'=="high" 		local ref = 1
	else if `"`dxweight'"'=="low" 	local ref = 0
	else {
		di as error "`dxweight' not allowed in the dxweight() option"
		error 198
	}

//	Means, determining high-low order


	quietly forval row = 1/2 {
	// means
		local val =  `matrow'[`row',1]
		su `depvar' `s(weight)' if `touse'==1 & `by'==`val' , meanonly
		local m`row' = r(mean)
	}
	if (`m2'>=`m1' & "`reverse'"=="") | (`m2'<`m1' & "`reverse'"!="") {
		local val0 = `matrow'[1,1]
		local val1 = `matrow'[2,1]
		local y1   = `m2'
		local y0   = `m1'
	}
	else {
		local val0 = `matrow'[2,1]
		local val1 = `matrow'[1,1]
		local y1   = `m1'
		local y0   = `m2'
	}

	

// ESTIMATION IN DIFFERENT SAMPLES

	tempname b0 b1 		// parameters
	tempname vb0 vb1 	// vce of parameters
	tempname x0 x1		// means
*	tempname c0 c1
//	tempname vx0 vx1 	// variance of means

	quietly forval i = 0/1 {
	// labels for output
		local lab`i' : label (`by') `val`i''
		if `"`lab`i''"'=="" {
			local lab`i' "`by'==`val`i''"
		}
	// coefficient vector and vce matrix
		`cmd' `varlist' `weight' if `touse'==1 & `by'==`val`i''  , `regopt'
		if substr("`cmd'",1,3)=="reg" {
			GetCoef
			local title expected value of `e(depvar)'
		}
		else {
			di "Caller is> " _caller()

			GetMargeff , at(mean) `eform' `outcome' `dummies' constant
			local title = e(margeff_title)
		}
		local N`i' = e(N)
		local df`i' = e(df_m)
		mat `b`i'' = r(b)
		mat `vb`i'' = r(v)
		mat `x`i'' = r(x)
 	}

	if `df0'!=`df1' {
		di as error "Number of regressors differs between the groups"
		di as error "Perhaps a variable was dropped in one of the groups defined by `by'"
		exit
	}
	local names : colnames `b1'  // needed for labeling at the end
	local names : subinstr local names "_cons" "" , all word 
//	local ncol  = colsof(`b1')
	
	// Variable-level decompositon

	tempname be bc bu	// coef matrices for E, C and U parts
	tempname ve vc vu	// vce  matrices for E, C and U parts
	tempname fullbe fullbc    // temp matrices
	
	mat `fullbe' = `b`ref'''*(`x1'-`x0')
	mat `be' = vecdiag(`fullbe')
	mat `ve' = (`x1'-`x0')'*(`x1'-`x0')
//	mat `ve' = diag(vecdiag((`x1'-`x0')'*(`x1'-`x0')))
	mat `ve' = `ve' * `vb`ref''	// assumes x is fixed
//	mat `ve' = (`x1'-`x0')'*(`x1'-`x0') * `vb`ref''	// assumes x is fixed
	mat `fullbc' = `x0''*(`b1'-`b0')
	mat `bc' = vecdiag(`fullbc')
	mat `vc' = diag(vecdiag(`x0''*`x0')) * (`vb1'+`vb0')			// assumes x is fixed
//	mat `vc' = `x0''*`x0' * (`vb1'+`vb0')			// assumes x is fixed

	local dim = colsof(`bc')
	mat `bu' = `bc'[1,`dim']
	mat `vu' = `vc'[`dim',`dim']
	local dim = `dim'-1
	mat `bc' = `bc'[1,1..`dim']
	mat `vc' = `vc'[1..`dim',1..`dim']
	mat `be' = `be'[1,1..`dim']
	mat `ve' = `ve'[1..`dim',1..`dim']

	
//	Matrices for model-level results
//	Model-level results as scalars

	tempname dy dyc dye dyu D res	
	tempname ob ov	// matrices for overall coef and vce results
	tempname tvc tve tvu	// temp matrices for overall E, C components
	scalar `dyu' = `bu'[1,1]
	scalar `dye' = trace(`fullbe')
	scalar `dyc' = trace(`fullbc')-`dyu'
	scalar `tve' = trace(`ve')
	scalar `tvc' = trace(`vc')

	mat `ob' = (`dye' , `dyc' )
	mat `ov' = (`tve' , 0 \ 0 , `tvc' )

	scalar `dy'  = `y1'-`y0'
	scalar `res' = `dy'-`dyc'-`dye'-`dyu'
//	scalar `D'   = (`dy'-`dye')/`dye'
	
// Combination of matrices
//	Manipulation of vce matrices ; right now there are asymmetric and possibly negative definite

	tempname b v 
	mat `b' = `ob' , `be' , `bc' , `bu'
//	mat `b' =  `be' , `bc' , `bu'
	mat `v' = J(2*`dim'+3, 2*`dim'+3 ,0)
//	mat `v' = J(2*`dim'+1, 2*`dim'+1 ,0)
	mat `v'[1,1] = `ov'
	mat `v'[3,3] = `ve'
//	mat `v'[1,1] = `ve'
	mat `v'[`dim'+3,`dim'+3] = `vc'
//	mat `v'[`dim'+1,`dim'+1] = `vc'
	mat `v'[2*`dim'+3,2*`dim'+3] = `vu'
//	mat `v'[2*`dim'+1,2*`dim'+1] = `vu'

	mat `v' = diag(vecdiag(`v'))			 // otherwise matrix asymmetric	and not positive definite
//	matrix can be made symmetric using:	mat `v' = (`v'+`v'')/2				
//	matrix can be made + definite if covariance between E and C effects would be not zero but estimated

//	Setting col and row eqnames
	local eqname Model Model
//	local eqname 
	forval i = 1/`dim' {
		local eqname `eqname' E
	}
	forval i = 1/`dim' {
		local eqname `eqname' C
	}
	local eqname `eqname' U
	mat coleq `b' = `eqname'
	mat coleq `v' = `eqname'
	mat roweq `v' = `eqname'
	local model E C	
//	local model 
	mat colnames `b' = `model' `names' `names' _cons
	mat colnames `v' = `model' `names' `names' _cons
	mat rownames `v' = `model' `names' `names' _cons


//	Posting results

	eret clear
	eret post `b' `v' , depn(`depvar')	esample(`touse')
	
	eret local cmd    gdecomp
	eret local cmd2   `cmd'
	eret local depvar `depvar'
	eret local group   `by'
	eret local title  `title'
	eret local ref    `ref'
	eret local cat0   `val0'
	eret local cat1   `val1'
	eret local label0 `lab0'
	eret local label1 `lab1'
	
	ereturn mat b0 = `b0'
	ereturn mat b1 = `b1'
	ereturn mat x0 = `x0'
	ereturn mat x1 = `x1'

	ereturn scalar y0  = `y0'
	ereturn scalar y1  = `y1'
	ereturn scalar dy  = `dy'
	ereturn scalar dyc = `dyc'
	ereturn scalar dye = `dye'
	ereturn scalar dyu = `dyu'
	ereturn scalar res = `res'
//	ereturn scalar D   = `D'
    ereturn scalar N0  = `N0'
	ereturn scalar N1  = `N1'

	if "`eform'"!="" local eform "eform(exp(b))"
	local dxw dxw(`dxweight')
	Replay , `level' `header' `coef'  `dxw'

end



program define Replay, eclass
	version 9
	syntax  [, Level(passthru) noheader nocoef dxw(string) ]

// Header
	local format	
	if "`header'"=="" {
		di
		di as text "Decomposition of differences in " as res "`e(title)'" as text " after `e(cmd2)'"
		di as text "High outcome group: " as result "`e(label1)'" as text " -  Low outcome group: " as result "`e(label0)'" 
//		di as text "Weights in the endowment (E) effect are coefficients in the `dxw' outcome group"
		di
        di as text "Observed difference "					_col(42) as result `format' `e(dy)'
        di as text "Residual difference"					_col(42) as result `format' `e(res)'

    }
// Variables
    if "`coef'"=="" {
        di
        tempname ehold 
        _est hold `ehold' , copy
        if "`eform'"!="" local eform "eform(exp(b))"
        ereturn display,  `level'
        _est unhold `ehold'
    }
	else {
	        di as text "Explained difference due to"			
        di as text " - differences in endowments   (E)"		_col(42) as result `format' `e(dye)'
        di as text " - differences in coefficients (C)"		_col(42) as result `format' `e(dyc)'
        di as text " - differences in constants    (U)"		_col(42) as result `format' `e(dyu)'
//        di as text "Discrimination coefficient"	    		_col(42) as result `format' `e(D)'
	}
end



program define gdecomp_graph
	version 9
	syntax varname [ , legend(string) xtitle(string) ytitle(string) * ]
	
//	syntax check
	if `"`legend'"'==""	local legend legend(" " off)
	if "`xtitle'"=="" {
		local xvarlab : var lab `varlist'
		if `"`xvarlab'"'=="" local xvarlab `varlist'
		local xtitle xtitle("`xvarlab'")
	}
	if "`ytitle'"=="" {
		local yvarlab : var lab `e(depvar)'
		if `"`yvarlab'"'=="" local yvarlab `e(depvar)'
		local ytitle ytitle("`yvarlab'")
	}
//	Execution
	foreach var in `varlist' {
		capt di _b[C:`var']
		if _rc!=0 {
			di as red "Variable `var' not found"
			error 198
		}
		DrawGraph `var' , `legend' `xtitle' `ytitle' `option' `options'
	//	tempname G`var'
	//	DrawGraph `var' , saving(`G`var'')
	// local graphlist `graphlist' `G`var''
	}
	// graph combine `graphlist' , `saving'	`label'
end


program define DrawGraph
	version 9
	syntax varlist [ , legend(string) ytitle(string) xtitle(string) * ]
	local ref = e(ref)
	local nor = `ref'==0
// Obtaining matrices + making vector of ones needed to obtain intercept
	tempname x1 x0 b1 b0 one 
	mat `x0' = e(x0)
	mat `x1' = e(x1)
	mat `b0' = e(b0)
	mat `b1' = e(b1)
	local dim = colsof(`b1')
	local pos = colnumb(`b1',"`varlist'")
	mat `one' = J(`dim',1,1)
// Observed means
	local m0 = `x0'[1,`pos']
	local m1 = `x1'[1,`pos']
	local y0 = e(y0)
	local y1 = e(y1)
// Extracting parameters = slopes
	local s0 = 	`b0'[1,`pos']
	local s1 = 	`b1'[1,`pos']
// Intercept
	mat `x0' = `x0'*`b0''
	mat `x1' = `x1'*`b1''
	local a0 = `x0'[1,1]
	local a0 = `a0' - `s0'*`m0'
	local a1 = `x1'[1,1]
	local a1 = `a1' - `s1'*`m1'
//	Important y values
	local O = `a0'+`s0'*`m0'	// Origin or Observed
	local D = `a1'+`s1'*`m1'	// Destination
	local C = `a1'+`s1'*`m0'	// Coefficients effect 
	local E = `a`ref''+`s`ref''*`m1'	// Endowment effect
	
//	Clokpos option
*	if abs(`O'-`C')>abs(`U0'-`C')	local cpos0 6
*	else local cpos0 12
*	if abs(`L'-`E0')>abs(`E0'-`D')	local cpos1 6
*	else local cpos1 12
	
//	Labels
	local gvarlab : var lab `e(group)'
	if `"`yvarlab'"'=="" local yvarlab `e(depvar)'

//	Range and height
	local rmin = floor(`m0')
	local rmax = ceil(`m1')
	local range range(`rmin' `rmax')
	if `e(dy)'>1 {
		local ymin = floor(`a0'+`s0'*`rmin')
		local ymax = ceil(`a1'+`s1'*`rmax')
		local step = int((`ymax'-`ymin')/10)+1
	}
	else {
		local ndec = 10^( length(string(`e(dy)'-int(`e(dy)')))-2)
		local ndec = 10
		local ymin = floor(`ndec'*(`a0'+`s0'*`rmin'))/`ndec'
		local ymax = ceil(`ndec'*(`a1'+`s1'*`rmax'))/`ndec'
		local step = 1/`ndec'
	}
	local range range(`rmin' `rmax')
	
//	Determining which points to be displayed and which lines to be highlighted
	local yli1 = `a1'+`s1'*`rmax'
	local yli0 = `a0'+`s0'*`rmax'
	local text1 text(`yli1' `m1' "`e(label1)'", place(3)) 
	local text0 text(`yli0' `m0' "`e(label0)'", place(3)) 
	local Yticks `O'   0  (3) "O"  `C'   0   (3) "C"  `E'  0  (3)
//	Arrow coordinates. Position of Letters E and C	
	if `ref'==1	{
		local arrow `C' `m0' `D' `m0'
		local yE = (`C'+`D')/2
		local xE = `m0'
	}
	else {
		local arrow `O' `m1' `E' `m1'
		local yE = (`O'+`E')/2
		local xE = `m1'
	}
	local yC = 	 (`O'+`C')/2

//	Options for function graphs
	local fncopt n(1000) lstyle(p1) xtitle("`xtitle'") ytitle("`ytitle'")  ///
		xlabel( , nogrid) ylabel(`ymin' (`step') `ymax' , nogrid)  

//	Drawing the graph		
	#delimit ;
	local opt2 legend(off) lstyle(none)	;
	graph twoway
	// Functions
		(function  y = `a0'+`s0'*x ,  `fncopt'  range(`rmin' `rmax')  lpat(solid) lw(thin)  )
		(function  y = `a1'+`s1'*x ,  `fncopt'  range(`rmin' `rmax')  lpat(solid) lw(thin)  )
		(scatteri  `yli0' `rmax' (10) "`e(label0)' " `yli1' `rmax' (10) "`e(label1)' " , xtick(`m0' `m1')  msymbol(i)  )
	// Dashed horizontal lines
		(function  y = `y0'        ,  `fncopt'  range(`rmin' `m`nor'')    lpat("-")   lw(thin) )
		(function  y = `E'         ,  `fncopt'  range(`rmin' `m1')    lpat("-")   lw(thin) )
		(function  y = `C'         ,  `fncopt'  range(`rmin' `m0')    lpat("-")   lw(thin) )
	// X-Axis and Ticks
		(scatteri  `ymin' `m0' (11) "`e(label0)' " `ymin' `m1' (2) "`e(label1)' " , xline(`m0' `m1' , lp("-")) msymbol(i)  )
	// Arrows showing Coeffients and Endowment effects
		(pcarrowi `O' `m0' `C' `m0'  , lpat(solid) lw(thin))
		(pcarrowi `arrow'            , lpat(solid) lw(thin))
		(scatteri  `yE' `xE' (9) "E" `yC' `m0' (9) "C"  ,  msymbol(i)  )
	, legend(off)  `option' `options'
	;
	#delimit cr

end


program define ParseSaving	, sclass
	version 9
	gettoken fname 0 : 0 , , parse(" , ")
	if "`fname'"=="" | "`fname'"=="," | "`fname'"=="," | "`fname'"=="," {
		di as error "Graph name is not specified in the saving() option"
		error 198
	}
	
	tokenize `"`0'"' , parse(" , ")
	
end


program define OnColonParse, sclass
* This is the official _on_colon_parse
	version 9

	sreturn local before ""
	sreturn local after ""

	// put ": <command>" in `after'
	gettoken before after : 0, parse(":") bind match(par) quotes
	if "`par'" != "" {
		local before `"(`before')"'
	}

	// handle special case when nothing is before ":"
	if `"`before'"' == ":" {
		sreturn local after `"`after'"'
		exit
	}

	while `"`COLON'"' != ":" & `"`after'"' != "" {
		// check for syntax errors
		gettoken COLON after : after, parse(":") bind match(par) quotes
		if "`par'" != "" {
			local before `before' (`COLON')
			local COLON
		}
		else if `"`COLON'"' != ":" {
			local before `"`before' `COLON'"'
			local COLON
		}
	}
	if `"`COLON'"' != ":" {
		di as err "'' found were ':' expected"
		exit 198
	}
	local do = 1
	while `do'==1 {
		gettoken w after : after
		capture confirm var `w'
		if _rc!=0 {
			local cmdname `cmdname' `w'
		}
		else {
			local do = 0
			local cmdargs `w' `after'
		}
	}
	
	sret clear
	sreturn local options `"`before'"'
	sreturn local cmdname `"`cmdname'"'
	sreturn local cmdargs `"`cmdargs'"'
end


program define GetMarkSample  , sclass
	version 9
	syntax [varlist] [if] [in] [pweight fweight aweight iweight]  [ , * ]
	marksample temp
	gettoken touse varlist : varlist
	qui replace `touse' = . if `temp'==0
	qui replace `touse' = 0 if `touse'==.
	if "`weight'"!="" {
		local weight [`weight'`exp']
	}
	sret local varlist `varlist'
	sret local touse   `touse'
	sret local weight  `weight'
	sret local options `options'
end


*********  SUBROUTINES USED BY Estimate **********************

program GetCoef , rclass
	version 9
	tempname b v x
	mat `b' = e(b)
	mat `v' = e(V)
	_at mean
	mat `x' = r(at)
	return mat b = `b'
	return mat v = `v'
	return mat x = `x'
end


program GetMargeff , rclass
	version 9
	syntax [ , eform outcome(integer -1) constant * ]
	if `outcome'!=-1	 local outcome outcome(`outcome')
	else local outcome
	di "Caller is> " _caller()
	margeff , at(mean)	`eform' `outcome'  constant 
	tempname b v x
	mat `b' = e(margeff_b)
	mat `v' = e(margeff_V)
	mat `x' = e(margeff_at)
	if colsof(`b')>colsof(`x') {
		tempname cons
		mat `cons' = J(1,1,1)
		mat colnames `cons' = _cons
		mat `x' = `x' , `cons'
	}
	return mat b = `b'
	return mat v = `v'
	return mat x = `x'
end


************** verifying the existence and current version of margeff ********

program define VerifyMargeff , sclass
	capture which margeff
	if _rc!=0 {
		sret local result = 0
		exit
	}
	margeff ?
	if "`s(margeff_version)'"=="" | `s(margeff_version)'<201 {
		sret local result = 0
		exit
	}
	sret local result = 1
end

