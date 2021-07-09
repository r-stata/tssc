*-------------------------------------------------------
*! 3.00 sean f. reardon, Joseph B. Townsend January 2018
*-------------------------------------------------------
* v3.0: added sample bias correction code options, only available for h and r
* POPcounts option -- indicates that the varlist contains expanded pop count estimates
* SAMPcounts option -- indicatest that the varlist contains sample counts
* RATE() option -- indicates variable containing sampling rate within a unit (must be >0 & <=1
* NSIZE() option -- indicates variable containing sample size within a unit (must be <= T)   
* TSIZE() option -- indicates variable containing pop size in a unit (must be >=N)
* ADJUST - indicates program should adjust estimates for sampling bias
* WREPLACEMENT -- specifies sampling with replacement is presumed for bias correction; default is off

program define seg
    version 13.1
    syntax varlist (min=2 max=999 num) ///
		[if] [in] ///
		[, Dseg Gseg Hseg Cseg Rseg Pseg Xseg Sseg Nseg ///
		BY(varlist) ///
		Unit(varname) ///
		BAse(numlist integer miss max=1 >1) ///
		noDISplay ///
		GENerate(string) ///
		File(string) ///
		REPLACE ///
		POPcounts ///
		SAMPcounts ///
		RATe(varname) ///
		NSIZe(varname) ///
		TSIZe(varname) ///
		WREPlacement ///
		ADJust ///
		ADJUSTVARS ///
		VARLISTPCTILES ///
		]
		
*------------------------------------------------------------
*NOTE1: options ADJUSTVARS and VARLISTPCTILES are not 
*		documented in the seg helpfile, and no effort is made 
*		to avoid potential name collisions. ADJUSTVARS, 
*		available only when adjust is specified, returns the 
*		following variables: tmean, nmean, hrate, t1harm, B, 
*		Bwo, Bwr. VARLISTPCTILES, available regardless of the 
*		adjust option, returns the proportion of each var in 
*		varlist, where the variable names are `var1'_pctile, 
*		`var2'_pctile, etc.
*NOTE2: weights are not allowed in this version of seg
*NOTE3: add population weight by multiplying each unit by pwt
*------------------------------------------------------------

local ind = "`dseg' `gseg' `hseg' `cseg' `rseg' `pseg' `xseg' `sseg' `nseg'"
local nind: word count `ind'

if `nind' == 0 {
	di in re "at least one of d g h c r p x s n options required"
	exit 198
}

if "`hseg'`rseg'" == "" & "`adjust'" ~= "" {
	di in re "adjust option only available with h or r index"
	exit 198
}
local nvars: word count `varlist'
if `nvars' ~= 2 & "`adjust'" ~= "" {
	di in re "adjust option only available with binary indices"
	exit 198
}

if "`unit'" ~= "" & "`adjust'" ~= "" {
	di in re "unit option cannot be used with adjust option"
	di in re "collapse data to unit-level (and compute unit-level population or sample sizes and sampling rates as needed)"
	di in re "before running rankseg"
	exit 198
}

if "`hseg'`rseg'" ~= "" & "`adjust'" ~= "" {

	*if neither popcounts nor sampcounts specified, assume popcounts
	if "`popcounts'`sampcounts'" == "" {
		di in ye "Note: Assuming `varlist' represent population counts"
		loc popcounts "popcounts"
	}

	if "`popcounts'" ~= "" {
		if "`sampcounts'" ~= "" {
			di in re "Popcounts and sampcounts options cannot be specified together"
			exit 198
		}
		else if "`tsize'" ~= "" {
			di in re "Popcounts and tsize options cannot be specified together"
			exit 198
		}
		else if "`nsize'" ~= "" & "`rate'" ~= "" {
			di in re "Rate and nsize options cannot be specified together"
			exit 198
		}
		else if "`nsize'`rate'`wreplacement'" == "" {
			loc wreplacement "wreplacement"
			di in re "Assuming self-weighting sampling with replacement"
			di in re "Specify rate variable or nsize variable for sampling without replacement correction"
		}
	}

	if "`sampcounts'" ~= "" {
		if "`nsize'" ~= "" {
			di in re "Sampcounts and nsize options cannot be specified together"
			exit 198
		}
		else if "`tsize'" ~= "" & "`rate'" ~= "" {
			di in re "Rate and tsize options cannot be specified together"
			exit 198
		}
		else if "`tsize'`rate'`wreplacement'" == "" {
			loc wreplacement "wreplacement"
			di in re "Assuming self-weighting sampling with replacement"
			di in re "Specify rate variable or tsize variable for sampling without replacement correction"
		}
	}
}

tokenize `generate'
local i = 1
while "``i''" ~= "" {
	local j=`i'+1
	if "``i''" == "d" {
		local dout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "g" {
		local gout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "h" {
		local hout ``j''
		if "`file'" == "" confirm new var ``j''
		if "`adjust'" == "adjust" {
			loc hout_adj ``j''_adj
			if "`file'" == "" confirm new var ``j''_adj
		}
		else loc hout_adj ""
		}
	if "``i''" == "c" {
		local cout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "r" {
		local rout ``j''
		if "`file'" == "" confirm new var ``j''
		if "`adjust'" == "adjust" {
			loc rout_adj ``j''_adj
			if "`file'" == "" confirm new var ``j''_adj
		}
		else loc rout_adj ""
		}
	if "``i''" == "p" {
		local pout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "x" {
		local xout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "s" {
		local sout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "n" {
		local nout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "i" {
		local iout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "e" {
		local eout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "t" {
		local tout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	if "``i''" == "u" {
		local uout ``j''
		if "`file'" == "" confirm new var ``j''
		}
	local i = `i' + 2
}

if "`file'" ~= "" & "`replace'" == "" confirm new file `file'

local sorted: sortedby
local nby: word count `by'
if "`base'"=="" {
	local base = `nvars'
}

if "`generate'" == "" & "`file'" ~= "" {
	tokenize `by'
	local i = 1
	while `i' <= `nby' {
		if "``i''" == "Total" {
			di in re "Name collision with Total: use generate option to name t"
			exit 110 
		}
		if "``i''" == "nunits" {
			di in re "Name collision with nunits: use generate option to name u"
			exit 110 
		}
		if "`dseg'" ~= "" & "``i''" == "Dseg" {
			di in re "Name collision with Dseg: use generate option to name d"
			exit 110 
		}
		if "`gseg'" ~= "" & "``i''" == "Gseg" {
			di in re "Name collision with Gseg: use generate option to name g"
			exit 110 
		}
		if "`hseg'" ~= "" & "``i''" == "Hseg" {
			di in re "Name collision with Hseg: use generate option to name h"
			exit 110 
		}
		if "`cseg'" ~= "" & "``i''" == "Cseg" {
			di in re "Name collision with Cseg: use generate option to name c"
			exit 110 
		}
		if "`rseg'" ~= "" & "``i''" == "Rseg" {
			di in re "Name collision with Rseg: use generate option to name r"
			exit 110 
		}
		if "`pseg'" ~= "" & "``i''" == "Pseg" {
			di in re "Name collision with Pseg: use generate option to name p"
			exit 110 
		}
		if "`xseg'" ~= "" & "``i''" == "Xseg" {
			di in re "Name collision with Xseg: use generate option to name x"
			exit 110 
		}
		if "`sseg'" ~= "" & "``i''" == "Sseg" {
			di in re "Name collision with Sseg: use generate option to name s"
			exit 110 
		}
		if "`nseg'" ~= "" & "``i''" == "Nseg" {
			di in re "Name collision with Nseg: use generate option to name n"
			exit 110 
		}
		if "`dseg'`gseg'`rseg'" ~= "" & "``i''" == "Idiv" {
			di in re "Name collision with Idiv: use generate option to name i"
			exit 110 
		}
		if "`hseg'" ~= "" & "``i''" == "Ediv" {
			di in re "Name collision with Ediv: use generate option to name e"
			exit 110 
		}
		
		if "`adjust'" == "adjust" { 
			if "`hseg'" ~= "" & "``i''" == "Hseg_adj" {
				di in re "Name collision with Hseg_adj: use generate option to name h"
				exit 110 
			}
			if "`rseg'" ~= "" & "``i''" == "Rseg_adj" {
				di in re "Name collision with Rseg_adj: use generate option to name r"
				exit 110 
			}
		}
		
		local i = `i' + 1
	}
}

tokenize `varlist'

if "`display'" == "" & `nby' > 1 {
	di _n in re "Note: " in bl "Results too complex for display" 
	if "`file'" == "" & "`generate'" == "" {
      	di in re "Results not stored"
		di in re "Use Generate or File option to store results"
		exit 198
	}
}

if "`display'" ~= "" & "`file'" == "" & "`generate'" == "" {
	di in re "Results will not be stored or displayed"
	di in re "Use Generate or File option to store results"
	exit 198
}

marksample touse
qui count if `touse'
if r(N)==0 {
	di in re "no observations"
	exit 2000
	}

*check for no negative values
local i = 1
while `i' <= `nvars' {
	capture assert ``i'' >= 0 if `touse' 
	if _rc {
		di in r "``i'' has negative values"
		exit 411
      }
	local i = `i'+1
}

*define unit (default=individual record)
tempvar u d
qui {
if "`unit'" == ""  gen long `u' = _n if `touse' 
else  gen double `u' = `unit' if `touse' 

*define BY variable (default=all)
if "`by'" == "" {
	gen str8 `d' = "Total" if `touse'
	label var `d' "--------"
	local by "`d'"
	local noby = 1
	}
else local noby = 0

preserve

* end of housekeeping; begin calculation of indices

*make unit-level data set of group counts
sort `by' `u'
collapse (sum) `varlist' `rate' `nsize' `tsize' if `touse', by(`by' `u') cw fast 
tempvar ttl
egen `ttl' = rsum(`varlist')
*check for small unit counts (only check if using multiracial indices)
tempvar nunits
egen `nunits' = count(`ttl'), by(`by')
tempvar minun
egen `minun' = min(`nunits')
local min = `minun'[1]
if `min' < `nvars' & "`dseg'`gseg'`hseg'`cseg'`rseg'`pseg'" ~= "" {
	if `noby' == 1 {
		di in re "Note: Data have fewer units than groups."
		di in re "Multigroup indices should be interpreted with caution."
	}
	else {
		di in re "Note: Some by-groups have fewer units than groups."
		di in re "Multigroup indices for these by-groups should be interpreted with caution."
	}
}

tempvar touse
g `touse' = 1
	
foreach v of varlist `varlist' {
	tempvar `v'
		qui g ``v'' = `v' if `touse'		
	loc tempvarlist "`tempvarlist' ``v''"
}

if "`adjust'" == "adjust" {

	tempvar tot n rt nmean tmean hrate invrate invt1 t1harm
	if "`popcounts'" ~= "" { 
		qui egen `tot' = rsum(`varlist') if `touse'
		if "`rate'`nsize'" == "" {
			qui g `rt' = 1 if `touse'
			qui g `n' =  `rt'*`tot' if `touse'
		}
		else if "`rate'" ~= "" {
			qui g `rt' = `rate' if `touse'
			qui g `n' =  `rt'*`tot' if `touse'
		}		
		else if "`nsize'" ~= "" {
			qui g `n' = `nsize' if `touse'
			qui g `rt' = `n'/`tot'
		}
		qui egen `nmean' = mean(`n') if `touse', by(`by')
		qui egen `tmean' = mean(`tot') if `touse', by(`by')
		qui g `invrate' =  1/`rt' if `touse'
		qui egen `hrate' = mean(`invrate') if `touse', by(`by')
		qui replace `hrate' = 1/`hrate' if `touse'
		qui drop `invrate'
		qui g `invt1' =  1/(`tot'-1) if `touse'
		qui egen `t1harm' = mean(`invt1') if `touse', by(`by')
		qui replace `t1harm' = 1/`t1harm' if `touse'
		qui drop `tot'
		qui drop `invt1'
	}		
	else if "`sampcounts'" ~= "" { 	
		qui egen `n' = rsum(`varlist') if `touse'
		
		if "`rate'`tsize'" == "" {
			qui g `rt' = 1 if `touse'
			qui g `tot' =  `n' if `touse'
		}
		else if "`tsize'" ~= "" {
			qui g `tot' = `tsize' if `touse'
			qui g `rt' = `n'/`tot'
			
			tempvar temptot
			gen `temptot' = 0
			foreach v of varlist `varlist' {
				qui replace `temptot' = `temptot' + ``v''
			}
			
			qui replace `rt' = 1 if `temptot'>=`tot' & `temptot'<(`tot'+1)
			qui replace `tot' = `temptot' if `temptot'>`tot' & `temptot'<(`tot'+1)
			
			foreach v of varlist `varlist' {
				qui replace ``v'' = ``v''/`rt'
			}
		}
		else if "`rate'" ~= "" {
			qui g `rt' = `rate' if `touse'
			foreach v of varlist `varlist' {			
				qui replace ``v'' = ``v''/`rt'
			
			}
			qui egen `tot' =  rsum(`tempvarlist') if `touse'
			
		}
		qui egen `nmean' = mean(`n') if `touse', by(`by')
		qui egen `tmean' = mean(`tot') if `touse', by(`by')
		qui g `invrate' =  1/`rt' if `touse'
		qui egen `hrate' = mean(`invrate') if `touse', by(`by')
		qui replace `hrate' = 1/`hrate' if `touse'
		qui drop `invrate'
		qui g `invt1' =  1/(`tot'-1) if `touse'
		qui egen `t1harm' = mean(`invt1') if `touse', by(`by')
		qui replace `t1harm' = 1/`t1harm' if `touse'
		qui drop `tot'
		qui drop `invt1'
	}
	
	qui su `rt' if `touse'	
	if r(max) > 1 | r(min) <= 0 {	
		di in red "uh??"
		di in re "Sample sizes or sampling rates outside allowable range: sampling rate must be >0 and <= 1"
		exit 198
	}

	tempfile hold
	save `hold', replace
		
		keep `by' `hrate' `tmean' `nmean' `t1harm'
		qui duplicates drop
		/*
		qui g tmean = `tmean'
		qui g nmean = `nmean'
		qui g hrate = `hrate'
		qui g t1harm = `t1harm'
		drop `hrate' `tmean' `nmean' `t1harm'	
		*/
		
		tempvar z Bwr Bwo
		qui g `z' = 1 + (((`tmean' - 1)/(`t1harm'))-1)/`tmean'
		qui g `Bwr' = `z'/((`tmean'-1)*`hrate')
		qui g `Bwo' = `z'*(1-`hrate')/((`tmean'-1)*`hrate')
		drop `z'
	
		sort `by'
		tempfile bias
		save `bias', replace		
			
	use `hold', clear		
}

* make a tempfile of `by' and varlist pctile vars, `by' level
tempfile holdData
save `holdData', replace
	
	collapse (sum) `tempvarlist', by(`by')
	tempvar totd
	egen double `totd' = rsum(`tempvarlist') 
	loc keepMe "`totd'"
	loc r = 1
	foreach v in `tempvarlist' {
		tempvar pctd`r'
		gen double `pctd`r'' = `v'/`totd'
		loc keepMe "`keepMe' `pctd`r''"
		loc ++r
	}
	
	keep `by' `keepMe'
	tempfile totWPctile
	save `totWPctile', replace
	
	
use `holdData', clear

tempvar totu /*totd*/
egen double `totu' = rsum(`tempvarlist') 
merge m:1 `by' using `totWPctile'
drop _merge
local r = 1
foreach v of varlist `varlist' {
	tempvar pctu`r' /*totd`r' pctd`r'*/
	gen double `pctu`r'' = ``v'' / `totu'	
	
	local r = `r' + 1
}

*calculate segregation indices

if "`gseg'" ~= "" {
*calculate gini index numerator
	tempvar gnum
	gen double `gnum' = 0
	local r = 1
	while `r' <= `nvars' {
		tempvar gur gsumur
		sort `by' `pctu`r''
		by `by': ///
			gen double `gur' = ( `totu' * `pctu`r'' * sum(`totu') - `totu' * /// 
			sum( `totu' * `pctu`r'' ) ) / `totd'^2
		by `by': gen double `gsumur' = sum(`gur')
		by `by': replace `gnum' = `gnum' + `gsumur'[_N]
		drop `gur' `gsumur'
		local r = `r' + 1
	}
}

if "`dseg'" ~= "" {
*calculate dissimilarity index numerator
	tempvar dnum
	gen double `dnum' = 0
	local r = 1
	while `r' <= `nvars' {
		tempvar dur dsumur 
		gen double `dur' = `totu' * abs(`pctu`r''-`pctd`r'') / (2*`totd')
		sort `by'
		by `by': gen double `dsumur' = sum(`dur')
		by `by': replace `dnum' = `dnum' + `dsumur'[_N]
		drop `dur' `dsumur'
		local r = `r' + 1
	}
}

if "`hseg'" ~= "" {
*calculate entropy index numerator
	tempvar hnum
	gen double `hnum' = 0
	local r = 1
	while `r' <= `nvars' {
		tempvar hur hsumur 	
		gen double `hur' = `totu' * `pctu`r'' * log(1 / `pctu`r'') / (`totd' * log(`base'))
		replace `hur' = 0 if `pctu`r'' == 0
		sort `by'
		by `by': gen double `hsumur' = sum(`hur')
		by `by': replace `hnum' = `hnum' + `hsumur'[_N]		
		drop `hur' `hsumur'
		local r = `r' + 1
	}
}

if "`cseg'`rseg'`pseg'" ~= "" {
*calculate c, r, p 
	tempvar rnum ctemp ptemp
	gen double `ctemp' = 0
	gen double `ptemp' = 0
	gen double `rnum' = 0
	local r = 1
	while `r' <= `nvars' {
		tempvar crpur
		gen double `crpur' = `totu' * (`pctd`r'' - `pctu`r'')^2 / `totd'	
		if "`cseg'" ~= "" {
			tempvar cur csumr
			gen double `cur' = `crpur' / ((`nvars' - 1) * `pctd`r'')
			replace `cur' = 0 if `pctd`r'' == 0
			sort `by'
			by `by': gen `csumr' = sum(`cur')
			by `by': replace `ctemp' = `ctemp' + `csumr'[_N]
			drop `cur' `csumr'
		}
		if "`rseg'" ~= "" {
			tempvar rsumr
			sort `by'
			by `by': gen double `rsumr' = sum(`crpur')
			by `by': replace `rnum' = `rnum' + `rsumr'[_N]
			drop `rsumr'			
		}
		if "`pseg'" ~= "" {
			tempvar pur psumr
			gen double `pur' = `crpur' / (1 - `pctd`r'')
			replace `pur' = 0 if `pctd`r'' == 1
			sort `by'
			by `by': gen `psumr' = sum(`pur')
			by `by': replace `ptemp' = `ptemp' + `psumr'[_N]
			drop `pur' `psumr'
		}
		drop `crpur'
		local r = `r' + 1
	}
}

if "`xseg'`nseg'" ~= "" {
*calculate exposure indices
	tempvar xu xtemp 
	gen double `xu' = `pctu1' * `pctu2' * `totu' / (`pctd1' * `totd')
	sort `by'
	by `by': gen double `xtemp' = sum(`xu')
	by `by': replace `xtemp' = `xtemp'[_N]
	if "`nseg'" ~= "" {
		tempvar ntemp
		gen double `ntemp' = 1 - (`xtemp' / `pctd2') if `pctd2'~=0
		replace `ntemp' = 0 if `pctd2'==0 
	}
	drop `xu'
}

if "`sseg'" ~= "" {
*calculate isolation index
	tempvar su stemp
	gen double `su' = `totu' * `pctu1'^2 / (`pctd1' * `totd')
	sort `by'
	by `by': gen double `stemp' = sum(`su')
	by `by': replace `stemp' = `stemp'[_N]
	drop `su'
}	

*make BY-level data set of group counts
sort `by'

collapse (mean) `dnum' `gnum' `hnum' `rnum' `ctemp' `ptemp' ///
	`xtemp' `stemp' `ntemp' `nunits', by(`by') cw fast
	
merge 1:1 `by' using `totWPctile'
drop _merge	
	
label var `totd' "Total Count"
label var `nunits' "Total Units"

* calculate `by'-level pctiles
loc pctiles ""
loc r = 1
foreach v in `tempvarlist' {
	tempvar pct_d_`r'
	gen `pct_d_`r'' = `pctd`r''
	loc pctiles "`pctiles' `pct_d_`r''"
	loc ++r
}

if "`varlistpctiles'"=="" loc pctiles ""

if "`dseg'`gseg'`cseg'`rseg'`pseg'" ~= "" {
	local r = 1
	tempvar I NI
	gen double `I' = 0
	foreach v in `tempvarlist' {	
		tempvar /* pctd`r' */ ir		
		gen double `ir' = `pctd`r'' * (1 - `pctd`r'')
		
		replace `I' = `I' + `ir'
		drop /* `pctd`r'' */ `ir'
		local r = `r' + 1
	}

	gen `NI' = `nvars' * `I' / (`nvars' - 1)
	lab var `I'  "Interaction"
	lab var `NI' "Norm. Int. "
	format `I' `NI' %6.4f
}

if "`hseg'" ~= "" {
	local r = 1
	tempvar E
	gen `E' = 0
	foreach v in `tempvarlist' {
		tempvar /* pctd`r' */ er		
		gen double `er' = `pctd`r'' * log(1 / `pctd`r'') / log(`base')
		replace `er' = 0 if `pctd`r'' == 0
		replace `E' = `E'+`er'
		drop `pctd`r'' `er'
		local r = `r' + 1

	}
	lab var `E' "Entropy    "
	format `E' %6.4f
}

if "`dseg'" ~= "" {
	tempvar D
	gen `D' = `dnum' / `I'
	replace `D' = 0 if `I' == 0
	format `D' %6.4f
	label var `D' "Dissim.    "
}

if "`gseg'" ~= "" {
	tempvar G
	gen `G' = `gnum' / `I'
	replace `G' = 0 if `I' == 0
	format `G' %6.4f
	label var `G' "Gini       "
}

if "`hseg'" ~= "" {
	tempvar H
	gen `H' = 1 - `hnum' / `E'
	replace `H' = 0 if `E' == 0
	format `H' %6.4f
	label var `H' "Inf. Theory "
}

if "`cseg'" ~= "" {
	tempvar C
	gen `C' = `ctemp'
	replace `C' = . if `totd' == 0
	replace `C' = 0 if `I' == 0
	format `C' %6.4f
	label var `C' "Squared. CV"
}

if "`rseg'" ~= "" {
	tempvar R
	gen `R' = `rnum' / `I'
	replace `R' = 0 if `I' == 0
	format `R' %6.4f
	label var `R' "Rel. Diver."
}

if "`pseg'" ~= "" {
	tempvar P
	gen `P' = `ptemp'
	replace `P' = . if `totd' == 0
	replace `P' = 0 if `I' == 0
	format `P' %6.4f
	label var `P' "Norm. Exp. "
}

if "`xseg'" ~= "" {
	tempvar X
	gen `X' = `xtemp'
	format `X' %6.4f
	label var `X' "Exposure   "
}

if "`sseg'" ~= "" {
	tempvar S
	gen `S' = `stemp'
	format `S' %6.4f
	label var `S' "Isolation  "
}

if "`nseg'" ~= "" {
	tempvar N
	gen `N' = `ntemp'
	format `N' %8.4f
	label var `N' "2G Norm Exp"
}

if "`adjust'" == "adjust" { 
	merge 1:1 `by' using `bias'	
	tab _merge
	drop _merge
	
	tempvar B
	
	if "`wreplacement'" == "" {
		g `B' = `Bwo'
	}
	else if "`wreplacement'" == "wreplacement" {
		g `B' = `Bwr'
	}	
	
	loc adjSegs ""
	
	if "`hseg'" ~= "" {
		tempvar H_adj
		gen `H_adj' = `H' - `B'/(2*`E'*log(`base'))
		lab var `H_adj' "Hseg, bias corrected"
		replace `H_adj' = 0 if `E'==0
		replace `H_adj' = 0 if `H_adj'<0
		replace `H_adj' = 1 if `H_adj'>1
		loc adjSegs "`adjSegs' `H_adj'"
	}
	if "`rseg'" ~= "" {
		tempvar R_adj
		gen `R_adj' = (`R' - `B')/(1 - `B')
		lab var `R_adj' "Rseg, bias corrected"
		replace `R_adj' = 0 if `R'==0
		replace `R_adj' = 0 if `R_adj'<0
		replace `R_adj' = 1 if `R_adj'>1
		loc adjSegs "`adjSegs' `R_adj'"
	}
	
		
	if "`adjustvars'"=="adjustvars" {
		rename `tmean' _tmean
			lab var _tmean "mean of unit tot w/i by-group"
		rename `nmean' _nmean
			lab var _nmean "mean of unit samp size w/i by-group"
		rename `hrate' _hrate
			lab var _hrate "harmonic mean of unit samp rate w/i by-group"
		rename `t1harm' _t1harm
			lab var _t1harm "harmonic mean of unit tot w/i by-group"
		rename `B' _B
			lab var _B "bias factor"
		rename `Bwo' _Bwo
			lab var _Bwo "bias factor, sampling w/o replacement"
		rename `Bwr' _Bwr
			lab var _Bwr "bias factor, sampling w/ replacement"
		loc adjVars "_tmean _nmean _hrate _t1harm _B _Bwo _Bwr"
	}
	else loc adjVars ""
	
}
else loc adjOptions ""

*---------------
noi {
	if "`display'" == "" & `nby' < 2 {
		di _n in gr "Group Variables:" _col(20) in ye "`varlist'"
		di _n in ye "Total Counts and Diversity Measures"
		tabdisp `by', c(`nunits' `totd' `I' `NI' `E') center
		di _n in ye "Segregation Measures"
		if `nind' > 5 {
			tabdisp `by', c(`D' `G' `H' `C' `R') center
			tabdisp `by', c(`P' `X' `S' `N') center
		}
		else {
			tabdisp `by', c(`D' `G' `H' `C' `R' `P' `X' `S' `N') center
		}
	}
}

keep `by' `totd' `nunits' `I' `NI' `E' `G' `D' `H' `C' `R' `P' `X' `S' `N' `pctiles' `adjSegs' `adjVars'

*-------------------------------------------------
*output code
*-------------------------------------------------

* adding pctile values here
if "`varlistpctiles'"!="" {
	loc r = 1
	foreach v in `varlist' {
		rename `pct_d_`r'' pctile_`v'
		loc ++r
	}
}

if "`generate'" ~= "" {
	if "`D'" ~= "" { 
		if "`dout'" ~= "" rename `D' `dout'
		else drop `D'
	}
	if "`G'" ~= "" { 
		if "`gout'" ~= "" rename `G' `gout'
		else drop `G'
	}
	if "`H'" ~= "" { 
		if "`hout'" ~= "" rename `H' `hout'
		else drop `H'
		if "`hout_adj'" ~= "" rename `H_adj' `hout_adj'
	}
	if "`C'" ~= "" { 
		if "`cout'" ~= "" rename `C' `cout'
		else drop `C'
	}
	if "`R'" ~= "" { 
		if "`rout'" ~= "" rename `R' `rout'
		else drop `R'
		if "`rout_adj'" ~= "" rename `R_adj' `rout_adj'
	}
	if "`P'" ~= "" { 
		if "`pout'" ~= "" rename `P' `pout'
		else drop `P'
	}
	if "`X'" ~= "" { 
		if "`xout'" ~= "" rename `X' `xout'
		else drop `X'
	}
	if "`S'" ~= "" { 
		if "`sout'" ~= "" rename `S' `sout'
		else drop `S'
	}
	if "`N'" ~= "" { 
		if "`nout'" ~= "" rename `N' `nout'
		else drop `N'
	}
	if "`I'" ~= "" { 
		if "`iout'" ~= "" {
			rename `NI' `iout'
			drop `I'
		}
		else drop `I' `NI'
	}
	if "`E'" ~= "" { 
		if "`eout'" ~= "" rename `E' `eout'
		else drop `E'
	}
	if "`tout'" ~= "" rename `totd' `tout'
	else drop `totd'
      if "`uout'" ~= "" rename `nunits' `uout'
	else drop `nunits'
	
	noi if "`file'" ~= "" {
		save `file', `replace'
		di _n in bl "Index Values Written to Output File:"
		di in ye "`file'"
		di
	}
	else {
		tempfile byfile
		sort `by'
		save `byfile'
		noi di _n in bl "Index Values Written to Current File"
	}
} 
/* end of the `generate' ~= "" condition */

else {
	if "`file'" ~= "" {
		noi di _n in bl "Index Values Written to Output File:"
		noi di in ye "`file'"
		rename `totd' Total
		rename `nunits' nunits
		if "`I'" ~= "" { 
			rename `NI' Idiv
			drop `I' 
		}
		if "`E'" ~= ""  rename `E' Ediv
		if "`D'" ~= ""  rename `D' Dseg
		if "`G'" ~= ""  rename `G' Gseg
		if "`H'" ~= ""  rename `H' Hseg
		if "`C'" ~= ""  rename `C' Cseg
		if "`R'" ~= ""  rename `R' Rseg
		if "`P'" ~= ""  rename `P' Pseg
		if "`X'" ~= ""  rename `X' Xseg
		if "`S'" ~= ""  rename `S' Sseg
		if "`N'" ~= ""  rename `N' Nseg
		
		if "`adjust'" == "adjust" { 
			if "`H'" ~= "" rename `H_adj' Hseg_adj
			if "`R'" ~= "" rename `R_adj' Rseg_adj
		}
		
		save `file', `replace'
	}
}

}

if "`generate'" ~= "" & "`file'" == "" {
	restore, preserve
	sort `by'
	tempvar merge
	merge m:1 `by' using "`byfile'", gen(`merge')
	drop `merge'
	if "`sorted'" ~= "" sort `sorted'
	restore, not
}
else restore


end
