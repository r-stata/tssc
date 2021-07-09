*! denton7 1.0.7 cfb 20110812
*  modified from tscollap.ado v1.0.3
*  1.0.1: suppress check for gaps, novarlist on marksample
*  1.0.2: move quarterly variable to mandatory indicator option
*  1.0.3: check for annual obs defined
*  1.0.4: check that sample begins in Q1
*  1.0.5: allow operation on onepanel
*  1.0.6: correct error with indicator adjustment
*  1.0.7: renamed to denton7 with release of new denton

program define denton7
	version 7.0
	syntax varlist(max=1 numeric) [if] [in] ,Indicator(string) Generate(string)
	di " "
	qui tsset /* error if not set as time series */ 
	local curfreq `r(unit1)'  /* current frequency of dataset must be q */
	if "`curfreq'" ~= "q" {
		di in r "Error: denton7 currently requires quarterly data"
		error 198
		}
	marksample touse, novarlist
*	_ts timevar, sort
	_ts timevar panelvar `if' `in', sort onepanel
	markout `touse' `timevar'
	tempvar fm tfm
* ensure that sample starts in first quarter of year
    qui gen `fm' = 0 
	qui replace `fm' = mod(quarter(dofq(`timevar')),4)==1 if `touse'
	qui gen `tfm' = sum(`fm')
	qui replace `fm' = . if `tfm' == 0
	markout `touse' `fm'
*
	capture confirm new variable `generate' 
        if _rc { 
                di in r "`generate' already exists: " _c  
                di in r "specify new variable with generate( ) option"
                exit 110 
        } 
	qui sum `touse',meanonly
	local en = r(sum)
	capture confirm numeric variable `indicator'
    if _rc { 
                di in r "`indicator' must be an existing numeric variable" 
                exit 110 
        } 	
	qui sum `indicator',meanonly
	local eni = r(N)
	local imin = r(min)
	if `en' > `eni' {
	di "`en' `eni'"
		di in r "Error: quarterly variable must be available for entire sample"
		error 198
		}
* deal with negative values in indicator 
	local iadj 0
	if `imin' <= 0 {
		local iadj = abs(`imin')+1
		}
* create x variable as 4th quarter readings on annual series
	tempvar av iv ptr tsum tf
	tempname mav mey A X I res
	qui gen double `av' = `varlist' if  `touse' & quarter(dofq(`timevar'))==4
	qui sum `av', meanonly
	if r(N) == 0 {
		di in r "Error: annual series must be defined in quarter 4."
		error 2000
		}
	qui replace `av' = 1e+300 if `av' ==.
	di _n "Interpolating annual " in ye "`varlist'" in gr " from quarterly indicator series " in ye "`i'" in gr 
	mkmat `av' if `touse', mat(`mav')
* get first obs marked in touse
    qui gen `tsum' = sum(`touse')
    qui gen `tf' = _n if `tsum'==1
    qui summ `tf',meanonly
    local tf = r(mean)-1
* dimensions of problem
	local eny = int(`en'/4)
	local dim = 5*`eny'
	mat `A' = J(`dim',1,0)
	mat `X' = J(`dim',1,0)
	mat `I' = J(`dim',`dim',0)
* create i variable from specified sample; ensure positive 
	qui gen double `iv' =`indicator'+`iadj' if `touse'
// cfb 0128: use iv. not indicator!
	mkmat `iv' if `touse', mat(`mey')

// mat li `mey'

* constraint borders, elements of A
	local fnp1 = `en'+1
	local j 0
	forv i = `fnp1'/`dim' {
		forv k=1/4 {
			mat `I'[`i',`k'+`j'] = 1
			mat `I'[`k'+`j',`i'] = 1
			}
		local j = `j'+4
		mat `A'[`i',1] = `mav'[`j',1]
		}
* first row, last row
	mat `I'[1,1] = 1/`mey'[1,1]^2
	mat `I'[1,2] = -1/(`mey'[1,1]*`mey'[2,1])
	mat `I'[`en',`en'-1] = -1/(`mey'[`en'-1,1]*`mey'[`en',1])
	mat `I'[`en',`en'] = 1/`mey'[`en',1]^2
* intermediate rows
	local enm1 = `en'-1
	forv i = 2/`enm1' {
		mat `I'[`i',`i'-1] = -1/(`mey'[`i'-1,1]*`mey'[`i',1])
		mat `I'[`i',`i'] = 2/`mey'[`i',1]^2
		mat `I'[`i',`i'+1] = -1/(`mey'[`i',1]*`mey'[`i'+1,1])
		}

// mat li `I'

mat `X' = inv(`I')*`A'
mat `res' = `X'[1..`en',1]
local lo = `tf'+1
local hi = `tf'+`en'
qui gen double `generate'= matrix(`res'[_n-`tf',1]) in `lo'/`hi'
di in gr "Interpolated series is " in ye "`generate'" in gr 
di _n in gr "To verify: tscollap (last)`a' (sum)`generate', to(y)" _n
end


