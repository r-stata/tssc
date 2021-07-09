*! version 1.0.2  September 2011	M. Daigl  AO Clinical Investigation and Documentation
*! Domain : Data analysis		Description : Scoring algorithm for SF36 version 2

*************************************************************************************************
* Terms and Conditions for Using the 36-Item Short Form Health Survey apply
* In order to use the SF-36 Health Survey and scoring algorithms you must register at:
* http://www.qualitymetric.com/DefaultPermissions/RequestInformation/tabid/233/Default.aspx
* Every effort is made to test code as thoroughly as possible but user must accept
* responsibility for use
*************************************************************************************************

version 10
capture program drop sf36v2
program define sf36v2
syntax [if] [in] [, ACute REF(string asis) FSC(integer 1990) SUFfix(string asis) Details]
marksample touse
set varabbrev off

/*Display which version of SF36 forms is used */
if "`acute'"== "" {
	display in yellow "SF36 version 2 is beeing calculated using data from a 4 week recall form"
	}
else if "`acute'" ~= "" {
	display in yellow "SF36 version 2 is beeing calculated using data from a 1 week recall form"
	}

*************************************************************************************************
*	1. Define Reference Population means and sd
*************************************************************************************************
if "`ref'" ~="" {
	tokenize `ref' 
	local ref_pop = "`1'"
	local ref_y = "`2'"
	}

if "`ref_pop'"=="" {
		local ref_pop="US"
		}
else if "`ref_pop'"~="" & "`ref_pop'"~="JP" & "`ref_pop'"~="US" {
		display in red "Reference population must be one of the following: US, JP"
		exit 198
		}

if "`ref_y'"=="" { /*use defaults if not defined*/
	if "`ref_pop'"=="US" {
		local ref_y="1998"
		}
	else if "`ref_pop'"=="JP" {
		local ref_y="2002"
		}
	}
else if "`ref_y'"~="" {
	if "`ref_pop'"=="US" & `ref_y'~=1998 {
		display in red "Currently supported US norms: 1998"
		exit 198
		}
	else if "`ref_pop'"=="JP" & `ref_y'~=2002 {
		display in red "Currently supported JP norms: 2002"
		exit 198
		}
	}
	
if "`acute'"=="" {
	if "`ref_pop'"=="US" & "`ref_y'"=="1998" {
			local ref_m="83.29094 82.50964 71.32527 70.84570 58.31411 84.30250 87.39733 74.98685"
			local ref_sd="23.75883 25.52028 23.66224 20.97821 20.01923 22.91921 21.43778 17.75604"
			}
	else if "`ref_pop'"=="JP" & "`ref_y'"=="2002" {
			local ref_m="87.70901 88.55583 74.18785 64.04815 62.00366 86.51170 87.13488 71.66899"
			local ref_sd="14.19995 18.32648 22.59283 18.49784 20.31911 19.00734 19.60730 18.81024"
			}
		}

else if "`acute'"~="" {
	if "`ref_pop'"=="US" & "`ref_y'"=="1998" {
			local ref_m="82.62455 82.65109 73.86999 70.78372 58.41968 85.11568 87.50009 75.76034"
			local ref_sd="24.43176 26.19282 24.00884 21.28902 20.87823 23.24464 22.01216 18.04746"
			}
	else if "`ref'"=="JP" & "`ref_y'"="2002" {
			display in red "Acute Form not supported for JP population"
			exit 198
			}
		}

	
*************************************************************************************************
*	2. Define reference Factor Score Coefficients
*************************************************************************************************
if ("`ref_pop'"=="US" | "`ref_pop'"=="JP") & "`fsc'"=="1990" {
	local fsc_PCS="0.42402 0.35119 0.31754 0.24954 0.02877 -0.00753 -0.19206 -0.22069"
	local fsc_MCS="-0.22999 -0.12329 -0.09731 -0.01571 0.23534 0.26876 0.43407 0.48581"
	}
else if "`ref_pop'"=="JP" & "`fsc'"=="1995" {
	local fsc_PCS="0.42796 0.49529 0.13995 -0.00866 -0.19126 0.06965 0.33214 -0.24931"
	local fsc_MCS="-0.18362 -0.21633 0.10532 0.24000 0.42270 0.17259 -0.07121 0.45970"
	}


*************************************************************************************************
*	3. Prepare variables for calculation
*************************************************************************************************
qui {
tempvar aggPHYS aggMENT
foreach x in PF RP BP GH VT SF RE MH HT {
	tempvar m`x' c`x' r`x' 
	}

foreach x in PF01 PF02 PF03 PF04 PF05 PF06 PF07 PF08 PF09 PF10 RP01 RP02 RP03 RP04 ///
	BP01 BP02 GH01 GH02 GH03 GH04 GH05 VT01 VT02 VT03 VT04 SF01 SF02 ///
	RE01 RE02 RE03 MH01 MH02 MH03 MH04 MH05 HT {
	tempvar p`x' x`x'
	gen `p`x''=`x'`suffix' if `touse'
	gen `x`x''=1 if `x'`suffix'~=. 
	}
}
local dimensions="PF RP BP GH VT SF RE MH"


*************************************************************************************************
* 	4. Verify occurence of out-of-range item values
*************************************************************************************************
tempvar alarm1 alarm2 alarm3
qui gen `alarm1'= . 
foreach item in PF01 PF02 PF03 PF04 PF05 PF06 PF07 PF08 PF09 PF10 {
	qui replace `alarm1' = 1 if `p`item'' ~=. & ( `p`item'' <1 | `p`item'' >3) 
	list `item'`suffix' if `p`item'' ~=. & ( `p`item'' <1 | `p`item'' >3) 
	}

qui gen `alarm2'=.
foreach item in RP01 RP02 RP03 RP04 BP02 ///
	GH01 GH02 GH03 GH04 GH05 VT01 VT02 ///
	VT03 VT04 SF01 SF02 RE01 RE02 RE03 ///
	MH01 MH02 MH03 MH04 MH05 HT {
	qui replace `alarm2'=1 if `p`item'' ~=. & ( `p`item'' <1 | `p`item'' >5)
	list `item'`suffix' if `p`item'' ~=. & ( `p`item'' <1 | `p`item'' >5) 
	}

qui gen `alarm3'=. 
qui replace `alarm3'=1 if `pBP01'~=. & (`pBP01' < 1 | `pBP01' >6 )
list BP01`suffix' if `pBP01'~=. & (`pBP01' < 1 | `pBP01' >6 )

qui summ `alarm1'
local r1=`r(N)'
qui summ `alarm2'
local r2=`r(N)'
qui summ `alarm3'
local r3=`r(N)'
if `r1'~=0 | `r2'~=0 | `r3'~=0 {
	display in red "Out of range values found as described above"
	exit
	}


*************************************************************************************************
*	5. Reverse score and/or recalibrate scores for 10 items (Precoded item value to final item value)
*************************************************************************************************
qui {
foreach x in PF01 PF02 PF03 PF04 PF05 PF06 PF07 PF08 PF09 PF10 RP01 RP02 RP03 RP04 {
	tempvar f`x'
	gen `f`x''=`p`x'' /* PF and RP scale do not require recoding of items*/
	}

tempvar fBP01
recode `pBP01' (1=6) (2=5.4) (3=4.2) (4=3.1) (5=2.2) (6=1.0), gen(`fBP01')

tempvar fBP02
gen `fBP02' = 6     if (`xBP01'~=. & `xBP02'~=. & `pBP02'==1 & `pBP01'==1) 
replace `fBP02' = 5 if (`xBP01'~=. & `xBP02'~=. & `pBP02'==1 & `pBP01'>=2 & `pBP01'<=6)
replace `fBP02' = 4 if (`xBP01'~=. & `xBP02'~=. & `pBP02'==2 & `pBP01'>=1 & `pBP01'<=6)
replace `fBP02' = 3 if (`xBP01'~=. & `xBP02'~=. & `pBP02'==3 & `pBP01'>=1 & `pBP01'<=6)
replace `fBP02' = 2 if (`xBP01'~=. & `xBP02'~=. & `pBP02'==4 & `pBP01'>=1 & `pBP01'<=6)
replace `fBP02' = 1 if (`xBP01'~=. & `xBP02'~=. & `pBP02'==5 & `pBP01'>=1 & `pBP01'<=6)

replace `fBP02'=`pBP02' if `xBP01'==.
recode `fBP02' (1=6.0) (2=4.75) (3=3.5) (4=2.25) (5=1.0) if `xBP01'==.

tempvar fGH01
recode `pGH01' (1=5.0) (2=4.4) (3=3.4) (4=2.0) (5=1.0), gen(`fGH01')

foreach x in GH02 GH04 VT03 VT04 SF02 RE01 RE02 RE03 MH01 MH02 MH04 HT {
	tempvar f`x'
	gen `f`x''=`p`x''
	}

foreach x in GH03 GH05 SF01 VT01 VT02 MH03 MH05 {
	tempvar f`x'
	recode `p`x'' (1=5) (2=4) (4=2) (5=1), gen(`f`x'')
	}
}


*************************************************************************************************
*	6. Recode missing item responses with mean substitution
************************************************************************************************
qui {
* create means 
egen `mPF'=rowmean(`fPF01' `fPF02' `fPF03' `fPF04' `fPF05' `fPF06' `fPF07' `fPF08' `fPF09' `fPF10')
egen `cPF'=rownonmiss(`fPF01' `fPF02' `fPF03' `fPF04' `fPF05' `fPF06' `fPF07' `fPF08' `fPF09' `fPF10') 
egen `mRP'=rowmean(`fRP01' `fRP02' `fRP03' `fRP04')
egen `cRP'=rownonmiss(`fRP01' `fRP02' `fRP03' `fRP04')
egen `mBP'=rowmean(`fBP01' `fBP02')
egen `cBP'=rownonmiss(`fBP01' `fBP02')
egen `mGH'=rowmean(`fGH01' `fGH02' `fGH03' `fGH04' `fGH05')
egen `cGH'=rownonmiss(`fGH01' `fGH02' `fGH03' `fGH04' `fGH05')
egen `mVT'=rowmean(`fVT01' `fVT02' `fVT03' `fVT04')
egen `cVT'=rownonmiss(`fVT01' `fVT02' `fVT03' `fVT04')
egen `mSF'=rowmean(`fSF01' `fSF02')
egen `cSF'=rownonmiss(`fSF01' `fSF02')
egen `mRE'=rowmean(`fRE01' `fRE02' `fRE03')
egen `cRE'=rownonmiss(`fRE01' `fRE02' `fRE03')
egen `mMH'=rowmean(`fMH01' `fMH02' `fMH03' `fMH04' `fMH05')
egen `cMH'=rownonmiss(`fMH01' `fMH02' `fMH03' `fMH04' `fMH05')

* mean imputation
foreach x in fPF01 fPF02 fPF03 fPF04 fPF05 fPF06 fPF07 fPF08 fPF09 fPF10 {
	replace ``x''=`mPF' if ``x''==. & `cPF'>=5
	}
foreach x in fRP01 fRP02 fRP03 fRP04 {
	replace ``x''=`mRP' if ``x''==. & `cRP'>=2
	}
foreach x in fBP01 fBP02 {
	replace ``x''=`mBP' if ``x''==. & `cBP'>=1
	}
foreach x in fGH01 fGH02 fGH03 fGH04 fGH05 {
	replace ``x''=`mGH' if ``x''==. & `cGH'>=3
	}
foreach x in fVT01 fVT02 fVT03 fVT04 {
	replace ``x''=`mVT' if ``x''==. & `cVT'>=2
	}
foreach x in fSF01 fSF02 {
	replace ``x''=`mSF' if ``x''==. & `cSF'>=1
	}
foreach x in fRE01 fRE02 fRE03 {
	replace ``x''=`mRE' if ``x''==. & `cRE'>=2
	}
foreach x in fMH01 fMH02 fMH03 fMH04 fMH05 {
	replace ``x''=`mMH' if ``x''==. & `cMH'>=3
	}
}

	
*************************************************************************************************
*	7. Compute Raw Scale Scores
*************************************************************************************************
qui {
gen `rPF' = `fPF01' + `fPF02' + `fPF03' + `fPF04' + `fPF05' + `fPF06' + `fPF07' + `fPF08' + `fPF09' + `fPF10'
gen `rRP' = `fRP01' + `fRP02' + `fRP03' + `fRP04' 
gen `rBP' = `fBP01' + `fBP02' 
gen `rGH' = `fGH01' + `fGH02' + `fGH03' + `fGH04' + `fGH05'
gen `rVT' = `fVT01' + `fVT02' + `fVT03' + `fVT04'
gen `rSF' = `fSF01' + `fSF02'  
gen `rRE' = `fRE01' + `fRE02' + `fRE03'
gen `rMH' = `fMH01' + `fMH02' + `fMH03' + `fMH04' + `fMH05' 
}


*************************************************************************************************
*	8. Tranform raw scale scores to 0-100 scale
*************************************************************************************************
qui {
gen PF`suffix' = ((`rPF'-10)/20)*100
gen RP`suffix' = ((`rRP'-4)/16)*100
gen BP`suffix' = ((`rBP'-2)/10)*100
gen GH`suffix' = ((`rGH'-5)/20)*100
gen VT`suffix' = ((`rVT'-4)/16)*100
gen SF`suffix' = ((`rSF'-2)/8)*100
gen RE`suffix' = ((`rRE'-3)/12)*100
gen MH`suffix' = ((`rMH'-5)/20)*100

foreach x in PF RP BP GH VT SF RE MH {
	if "`suffix'" == "" { 
		label var `x' "Transformed `x' Score"
		}
	else if "`suffix'" ~= "" { 
		label var `x'`suffix' "Transformed `x' Score (`suffix')"
		}
	}
}
display in gr "0-100 scores generated (PF`suffix'-MH`suffix')"


*************************************************************************************************
*	9. Transform  0-100 score to norm-based scores
*************************************************************************************************
noi {
foreach i of numlist 1/8 {
		local mean: word `i' of `ref_m'
		local sd: word `i' of `ref_sd'
		local dim: word `i' of `dimensions'
		tempvar z`dim'
		qui gen `z`dim''=(`dim'`suffix'-`mean')/`sd' /*z-score standardization of SF-36v2 Scales*/
		qui gen `dim'_NBS`suffix'=50+(`z`dim''*10) /*Norm-based tranformation of SF-26v2 z-scores*/
		}

foreach x in PF RP BP GH VT SF RE MH {
	if "`suffix'" == "" { 
		label var `x'_NBS "Norm-Based `x' Score"
		}
	else if "`suffix'" ~= "" { 
		label var `x'_NBS`suffix' "Norm-Based `x' Score (`suffix')"
		}
	}
}
display in gr "Norm-based scores generated (PF_NBS`suffix'-MH_NBS`suffix')"


*************************************************************************************************
*	10. Scoring SF-36v2 Physical and Mental Summary Measures
*************************************************************************************************

qui {
foreach i of numlist 1/8 {
	local dim: word `i' of `dimensions'
	local pfsc`dim': word `i' of `fsc_PCS'
	local mfsc`dim': word `i' of `fsc_MCS'
	}
#delimit ;
gen `aggPHYS'=(`zPF'*`pfscPF') + (`zRP'*`pfscRP') + (`zBP'*`pfscBP') + 
		(`zGH'*`pfscGH') + (`zVT'*`pfscVT') + (`zSF'*`pfscSF') + (`zRE'*`pfscRE') + (`zMH'*`pfscMH') ;
gen `aggMENT'=(`zPF'*`mfscPF') + (`zRP'*`mfscRP') + (`zBP'*`mfscBP') + 
		(`zGH'*`mfscGH') + (`zVT'*`mfscVT') + (`zSF'*`mfscSF') + (`zRE'*`mfscRE') + (`zMH'*`mfscMH') ;
#delimit cr
gen PCS`suffix' = 50 + (`aggPHYS' * 10)
gen MCS`suffix' = 50 + (`aggMENT' * 10)
if "`suffix'"=="" {
	label var PCS`suffix' "Physical Component Score"
	label var MCS`suffix' "Mental Component Score"
	}
else if "`suffix'"~="" {
	label var PCS`suffix' "Physical Component Score (`suffix')"
	label var MCS`suffix' "Mental Component Score (`suffix')"
	}
}

display in gr "Physical and Mental Component Summary generated (PCS`suffix',MCS`suffix')"

if "`details'"~="" {
	display "Norms and Coefficients used for the calculation:"
	display " +----------------------------------------------------+"
	display " |             ---Norms---        -Factor Score Coef- |"
	display " |              (`ref_pop' `ref_y')                (`fsc')       |"      
	display " | Dimension	mean	sd             PCS      MCS    |"
	foreach i of numlist 1/8 {
		local dim: word `i' of `dimensions'
		local mean: word `i' of `ref_m'
		local sd: word `i' of `ref_sd'
		local pfsc: word `i' of `fsc_PCS'
		local mfsc: word `i' of `fsc_MCS'
		display " | `dim'	`mean'	`sd'    " %8s "`pfsc'" "   "%8s "`mfsc'" " |"
		}
	display " +----------------------------------------------------+"
	}
	
set varabbrev on

end
