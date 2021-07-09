*! xtlsdvc_1 V1.0.5   06sep2005
*! Giovanni S.F. Bruno, Universita' Bocconi, Milan, Italy, 
*! giovanni.bruno@unibocconi.it
*! Subroutine called by xtlsdvc to obtain LSDVC estimates

*  Version history
*  1.0.5 Fixed a bug found by Carl-Oskar Lindgren causing the option -my- not
*        to work properly
*  1.0.4 Fixed a bug causing an over restricted estimation sample for the first-stage regression
*        in the presence of missing values in the regressors.
*  1.0.3 Added two post estimation results, e(predict) and e(ivar). These, together  
*        with the new routine -xtlsdvc_p-, enable -predict- after estimation   
*  1.0.2 The collinearity analysis for the LSDV regression is now carried out over the 
*        usable sample 
*  1.0.1 Fixed a bug causing xtlsdvc_1 to break down when the number of usable groups
*	 is different from that in the original panel. 
*	 Temp names given to T and matrices S`j'

program define xtlsdvc_1,  eclass
version 8.0

	syntax varlist [if], Initial(string) [ BIas(integer 1) Lsdv First] 




/* check that data is tsset */

	capture tsset
	

	capture local ivar "`r(panelvar)'"
	if "`ivar'"=="" {
		di as err "must tsset data and specify panelvar"
		exit 459
	}
	capture local tvar "`r(timevar)'"
	if "`tvar'" == "" {
		di as err "must tsset data and specify timevar"
		exit 459
	}

	if `bias'>3 {
		di as err "the maximum number of bias components allowed is 3"
		exit 198
	}	

set type double

quietly {		
			tempname touse
			mark `touse' `if'
			count if `touse'
			if r(N)<=1 {
				 error 2001
				 }
			}

preserve

tokenize `varlist'
local depn="`1'"

tempname   b bv e1 Ik uMu WMW WPMW WPP_trW Q QWPPW q11 PtPPM  est_gamma est_beta est_s2 est_s /*
		*/ bi bias1 bias2 bias3 b_in LSDVC
tempvar    bx Ly res   

qui gen double `Ly'=L.`1'

qui keep if `touse' 
 

 			/* one-step estimates from AH, AB, BB estimators or matrix my  */

/* consider the set of exogenous variables for initial estimates: 
this does not need coincide with that in the lsdv regression */  

 
local dim1=2
while "``dim1''"!="" {
		local x_1 "`x_1'  ``dim1''"
		local dim1=`dim1'+1
		}


if  "`initial'"!="my" {


	if "`first'"=="" { 
			qui {
			if  "`initial'"=="ab"  {
	noisily di as text "Note: Bias correction initialized by Arellano and Bond estimator" 

				xtabond `1' `x_1' ,  noconstant
				}

			if "`initial'"=="ah"  {
	noisily di as text "Bias correction initialized by Anderson and Hsiao estimator"  
				ivreg D.`1' D.(`x_1') (LD.`1'=L2.`1') ,  noconstant
				}
			if  "`initial'"=="bb"  {
	noisily di as text "Note: Bias correction initialized by Blundell and Bond estimator" _newline
	noisily di as text "Note: Blundell and Bond estimator is implemented through"
	noisily di as text "      the user-written Stata command -xtabond2- by David Roodman,"
	noisily di as text "      Center for Global Development, Washington, DC droodman@cgdev.org" 
				
		capture xtabond2 `1' L.`1' `x_1' , gmm(L.`1') iv(`x_1') noconstant
		if _rc==199 {
				di as error "Command xtabond2 not found as ado-file. " 
				exit 111
				}
			}
		}
	}

	else { 
			if  "`initial'"=="ab"  {
	noisily di as text "Note: Bias correction initialized by Arellano and Bond estimator" 

					xtabond `1' `x_1' ,  noconstant
				}

			if "`initial'"=="ah"  {
	noisily di as text "Note: Bias correction initialized by Anderson and Hsiao estimator" 
					ivreg D.`1' D.(`x_1') (LD.`1'=L2.`1') ,  noconstant
				}
			if  "`initial'"=="bb"  {
	noisily di as text "Note: Bias correction initialized by Blundell and Bond estimator" _newline
	noisily di as text "Note: Blundell and Bond estimator is implemented through"
	noisily di as text "      the user-written Stata command -xtabond2- by David Roodman,"
	noisily di as text "      Center for Global Development, Washington, DC droodman@cgdev.org" 
				
		capture which xtabond2
		if _rc==111 {
				di as error "Command xtabond2 not found as ado-file. " 
				exit 111
				}

		else xtabond2 `1' L.`1' `x_1' , gmm(L.`1') iv(`x_1') noconstant
	
			}
		}

	mat `b_in'=e(b)
	sca `est_gamma'=`b_in'[1,1]
	local vars: colnames `b_in'
	tokenize `vars'

	local dim1=2
	while "``dim1''"!="" {
			local noDvar: subinstr local `dim1' "D." ""
			tempname b`noDvar'
			sca `b`noDvar''=_b[``dim1'']
			local g "`g' + `b`noDvar''*`noDvar'"
			local dim1=`dim1'+1
			}
		}

else {
		di as text "Note: Bias correction initialized by matrix my" 
		mat `b_in'=my
		local colsofmy=`dim1'
		if colsof(my)!= `colsofmy' {
			di as err "the number of columns of my must be equal to the number of"
			di as err "right-hand variables plus one: mismatch possibly caused"
			di as err "by right-hand variables dropped due to collinearity"
			exit 198
			}	

		sca `est_gamma'=`b_in'[1,1]
		sca `est_s2'=`b_in'[1,`colsofmy']
		sca `est_s'=sqrt(`est_s2')
		tokenize `varlist'

		local dim1=2
		while "``dim1''"!="" {
				local g "`g' + my[1,`dim1']*``dim1''"
				local dim1=`dim1'+1
			}
	}

qui gen double `bx'=0 `g' 

tokenize `varlist'
qui gen double `res'=`1'-`est_gamma'*`Ly'-`bx'  

/*  selection rule for each individual i, S_i and
    LSDV regression */

quietly {		
			tsfill,full
			markout `touse'  `res'   
			count if `touse'
			if r(N)<=1 {
				 error 2001
					 }

					/* collinearity analysis for LSDV */

			_rmcoll   `x_1' if `touse'
			local xvar_ct: word count  `x_1'
			local xvar1_ct: word count  `r(varlist)'

			if `xvar_ct' >`xvar1_ct' {
				noisily di, _newline
				noisily _rmcoll `x_1' if `touse'
				noisily di as text "      in the LSDV regression" 
				}	
			local xvar_fe `Ly' `r(varlist)'

					/* LSDV regression */


			xtreg `1'  `xvar_fe' , fe

			mat `b'=e(b)
			mat `bv'=e(V)
			local dim=colsof(`b')
			local dim=`dim'-1

			mat `Ik'=I(`dim')
			mat `e1'=J(`dim',1,0)	
			mat `e1'[1,1]=1
			mat `b'=`b'[1,1..`dim']
			local vars: colnames `b'

			tokenize `vars'
			local dim1=2
			while "``dim1''"!="" {
			local x "`x'  ``dim1''"
			local dim1=`dim1'+1
				}	 
			tokenize `varlist'
			matrix colnames `b'=L.`1' `x' 
			mat `bv'=`bv'[1..`dim',1..`dim']
			matrix colnames `bv'=L.`1' `x' 
			matrix rownames `bv'=L.`1' `x' 

			by `ivar': drop if _n==1 

						
			mvencode  `res' `Ly' `x',mv(0) o
			tempvar touse_sum
			by `ivar': egen `touse_sum'=sum(`touse')
			drop if `touse_sum'==0
			xtdes 
			local T=r(max)
			local nid=r(N)	
			}

local upper=0

		forvalues j=1/`nid' { 
				local i=`upper'+ 1
				local upper=`upper' +`T'
				tempname S`j'
				qui mkmat `touse' in `i'/`upper', mat(`S`j'')
				mat `S`j''=diag(`S`j'')
				}



				/* Generate matrices W_i for the AR model with and without x's */
	
local upper=0

	/* AR model with x's variables */

if "`x'"!="" {
		forvalues j=1/`nid' { 
				local i=`upper'+ 1
				local upper=`upper' +`T'
				qui mkmat `x'    in `i'/`upper', mat(x`j')
				qui mkmat `Ly'   in `i'/`upper', mat(Ly`j')
				qui mkmat `res' in `i'/`upper', mat(epsy`j')
				}

		/* gen. matrices of dimension T */

	tempname I_T I L GA C
	mat `I_T'=J(`T',1,1) 
	mat `I'=I(`T')
	mat `L'=J(`T',`T',0)
	local i=2
		while `i'<`T'+1 {
				mat `L'[`i',`i'-1]=1
				local i=`i'+1					
				}
	mat `GA'=inv(`I'-`est_gamma'*`L')
	mat `C'=`L'*`GA'
	 
	local summ=0

	local j=1
		forvalues j=1/`nid' {
				tempname  M`j' C`j' P`j' PP`j' PtP`j' MPtPM`j' /*
				*/ PP`j' PM`j' K`j' D`j' H`j' PtPP`j' PPPP`j' Lybar`j' trP`j' /*
				*/ trPP`j' trPtP`j' trPtPP`j' trPPPP`j'
				local T`j'=trace(`S`j'')
				local summ=`summ'+ `T`j''-1
				mat `M`j''=`S`j''*(`I'-(1/(`T`j''))*`I_T'*`I_T'')*`S`j''
				mat `Lybar`j''=Ly`j'-`C'*`M`j''*epsy`j'
				mat W`j'=`Lybar`j'',x`j'
				mat drop x`j' Ly`j'
				mat `P`j''=`M`j''*`C'
				sca `trP`j''=trace(`P`j'')
				mat `PP`j''=`P`j''*`P`j''
				sca `trPP`j''=trace(`PP`j'')
				mat `PtP`j''=`P`j'''*`P`j''
				sca `trPtP`j''=trace(`PtP`j'')
				mat `PtPP`j''=`PtP`j''*`P`j''
				sca `trPtPP`j''=trace(`PtPP`j'')
				mat `PPPP`j''=`PtP`j''*`PtP`j''
				sca `trPPPP`j''=trace(`PPPP`j'')
				mat `MPtPM`j''=`M`j''*`PtP`j''*`M`j''
				mat `PP`j''=`P`j''*`P`j''
				mat `PM`j''=`P`j''*`M`j''
				mat drop  `PtP`j'' `PPPP`j'' `PtPP`j'' `PP`j'' 
				}
			}

	/* AR model without x's */

else {
		forvalues j=1/`nid' { 
				local i=`upper'+ 1
				local upper=`upper' +`T'
				qui mkmat `Ly'   in `i'/`upper', mat(Ly`j')
				qui mkmat `res' in `i'/`upper', mat(epsy`j')
				}

	qui keep `varlist' `ivar' `tvar' 				

		/* gen. matrices of dimension T */

	tempname I_T I L GA C
	mat `I_T'=J(`T',1,1) 
	mat `I'=I(`T')
	mat `L'=J(`T',`T',0)
	local i=2
		while `i'<`T'+1 {
				mat `L'[`i',`i'-1]=1
				local i=`i'+1					
				}
	mat `GA'=inv(`I'-`est_gamma'*`L')
	mat `C'=`L'*`GA'			
	
	local summ=0

	local j=1
		forvalues j=1/`nid' {
				tempname  M`j' C`j' P`j' PP`j' PtP`j' MPtPM`j' /*
				*/ PP`j' PM`j' K`j' D`j' H`j' PtPP`j' PPPP`j' Lybar`j' trP`j' /*
				*/ trPP`j' trPtP`j' trPtPP`j' trPPPP`j'
				local T`j'=trace(`S`j'')
				local summ=`summ'+ `T`j''-1
				mat `M`j''=`S`j''*(`I'-(1/(`T`j''))*`I_T'*`I_T'')*`S`j''
				mat `Lybar`j''=Ly`j'-`C'*`M`j''*epsy`j'
				mat W`j'=`Lybar`j''
				mat drop  Ly`j'
				mat `P`j''=`M`j''*`C'
				sca `trP`j''=trace(`P`j'')
				mat `PP`j''=`P`j''*`P`j''
				sca `trPP`j''=trace(`PP`j'')
				mat `PtP`j''=`P`j'''*`P`j''
				sca `trPtP`j''=trace(`PtP`j'')
				mat `PtPP`j''=`PtP`j''*`P`j''
				sca `trPtPP`j''=trace(`PtPP`j'')
				mat `PPPP`j''=`PtP`j''*`PtP`j''
				sca `trPPPP`j''=trace(`PPPP`j'')
				mat `MPtPM`j''=`M`j''*`PtP`j''*`M`j''
				mat `PP`j''=`P`j''*`P`j''
				mat `PM`j''=`P`j''*`M`j''
				mat drop  `PtP`j'' `PPPP`j'' `PtPP`j'' `PP`j'' 
				}
			}


				/* Construct approximations */

mat `WMW'=J(`dim',`dim',0)
mat `WPMW'=J(`dim',`dim',0)
mat `uMu'=J(1,1,0)
mat `WPP_trW'=J(`dim',`dim',0)


tempname trP trPP trPtP trPtPP trPPPP trPM trQWPPW

sca  `trP'=0
sca  `trPP'=0
sca  `trPtP'=0
sca `trPtPP'=0
sca `trPPPP'=0
 
	forvalues j=1/`nid' {
				sca `trP'=`trP'+ `trP`j''
				sca `trPP'=`trPP'+ `trPP`j''
				sca `trPtP'=`trPtP'+`trPtP`j'' 
				sca `trPtPP'=`trPtPP'+`trPtPP`j''
				sca `trPPPP'=`trPPPP'+`trPPPP`j''
				mat `WMW' =`WMW' + W`j''*`M`j''*W`j'
				mat `WPMW' =`WPMW' + W`j''*`PM`j''*W`j'
				mat `uMu' = `uMu'+ epsy`j''*`M`j''*epsy`j'
				mat `WPP_trW' =`WPP_trW' + W`j''*`P`j''*`P`j'''*W`j'
				mat drop W`j' epsy`j'  `P`j'' `PM`j'' `M`j''
				}

if  "`initial'"!="my" { 
		sca `est_s2'=trace(`uMu')
		sca `est_s2'=`est_s2'/(`summ'-`dim')
		sca `est_s'=sqrt(`est_s2')
		}

mat `Q'=`WMW'+`est_s2'*`trPtP'*`e1'*`e1''


mat `Q' =syminv(`Q')



mat `PtPPM'=`Q'*`WPMW'
mat drop `WPMW'
sca `trPM' =trace(`PtPPM')
mat `QWPPW'=`Q'*`WPP_trW'
sca `trQWPPW'=trace(`QWPPW')


mat `q11'=`e1''*`Q'*`e1'
sca `q11'=`q11'[1,1]

mat `bias1'=`est_s2'*`trP'*`Q'*`e1'
mat `bias2'=-`est_s2'*(`PtPPM'+`trPM'*`Ik' + /*
 */ 2*`est_s2'*`e1''*`Q'*`e1'*`trPtPP'*`Ik')*`Q'*`e1'
mat `bias3'= (`est_s2'^2)*`trP'*(2*`e1''*`Q'*`e1'*`QWPPW'*`Q'*`e1' + /*
 */ (`e1''*`Q''*`WPP_trW'*`Q'*`e1'+`e1''*`Q'*`e1'*`trQWPPW' + 2*`trPPPP'*`q11'^2)*`Q'*`e1')

if `bias'==1 	mat `bi'=`bias1'
	

if `bias'==2 	mat `bi'=`bias1'+`bias2'
	

if `bias'==3 	mat `bi'=`bias1'+`bias2'+`bias3'
	


mat  `LSDVC'=`b''-`bi'
mat rownames `LSDVC'=L.`1' `x' 
mat colnames `LSDVC'="LSDVC Estimates"
ereturn post `b' `bv',depname(`depn')

if "`lsdv'"!="" {
	di as text "LSDV dynamic regression" 
	ereturn display
	di,_newline
	}

				/* matrices of LSDV estimates to post */

if `bias'==1 {
		di as text "note: Bias correction up to order O(1/T)" _newline
		
	}

if `bias'==2 {
		di as text "note: Bias correction up to order O(1/NT)" _newline
		
	}

if `bias'==3 {
		di as text "note: Bias correction up to order O(1/NT^2)" _newline
		
	}

restore
 
local depn="`1'"
markout `touse' L.`1' `x'
mat `b'=e(b)
mat `bv'=e(V)
	
tempname bc bcv
mat `bc'=`LSDVC''
mat `bcv'=J(`dim',`dim',0)
mat rownames `bcv'=L.`1' `x' 
mat colnames `bcv'=L.`1' `x'
local nobs=`summ'+`nid'
local T_bar=`nobs'/`nid'
ereturn post `bc' `bcv', depname(`depn') esample(`touse') obs(`nobs')

ereturn local depvar "`depn'"
ereturn scalar sigma=`est_s'
ereturn scalar Tbar=`T_bar'
ereturn scalar N_g=`nid'
ereturn matrix b_lsdv=`b'
ereturn matrix V_lsdv=`bv'
ereturn local cmd "xtlsdvc_1"
ereturn local predict "xtlsdvc_p"
ereturn local ivar "`ivar'"


end

