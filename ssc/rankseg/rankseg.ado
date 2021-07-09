*-------------------------------------------------------
*! 3.00 sean f. reardon, Joseph B. Townsend January 2018
*-------------------------------------------------------
* v3.0: added sample bias correction code options, available for h and r
* POPcounts option -- indicates that the varlist contains expanded pop count estimates
* SAMPcounts option -- indicatest that the varlist contains sample counts
* RATE() option -- indicates variable containing sampling rate within a unit (must be >0 & <=1
* NSIZE() option -- indicates variable containing sample size within a unit (must be <= T)   
* TSIZE() option -- indicates variable containing pop size in a unit (must be >=N)
* ADJUST - indicates program should adjust estimates for sampling bias
* WREPLACEMENT -- specifies sampling with replacement is presumed for bias correction; default is off

* NOTE: generate option is not activated
* note sure if the unit option works with all bias correction options
* the sampling rate and sample size will be at the observation level, 
* but need to be at the unit-level for calculations to work.
* adjust is not available with the unit option.
*---------------------

program define rankseg
	version 13.1
	syntax varlist(min=2 max=999 num) ///
		[if] [in] ///
		, ORDers(numlist integer min=1 >=0) ///
		[Hseg Rseg Oseg ///
		BY(varlist) ///
		Unit(varname) ///
		GENerate(string) ///
		FILe(string) ///
		TFile(string) ///
		noDISplay ///
		REPLACE ///
		POPcounts ///
		SAMPcounts ///
		RATe(varname) ///
		NSIZe(varname) ///
		TSIZe(varname) ///
		WREPlacement ///
		ADJust ///
		]		
		
local ind = "`hseg' `rseg' `oseg'"
local nbyvars: word count `by'

if "`hseg'`rseg'`oseg'" == "" {
	di in re "at least one index (h r or o) must be specified"
	exit 198
}

if "`hseg'`rseg'"=="" & "`adjust'" == "adjust" {
	di in red "Adjust option not available with index o"
	exit 198
}

if "`display'" == "" & `nbyvars' > 1 {
	di _n in re "Note: " in bl "Results too complex for display" 
	if ("`file'" == "" & "`tfile'" == "") & "`generat'" == "" {
      	di in re "Results not stored"
		di in re "Use Generate or File option to store results"
		exit 198
	}
}

if "`display'" ~= "" & "`file'" == "" & "`tfile'" == "" & "`generat'" == "" {
	di in re "Results will not be stored or displayed"
	di in re "Use Generate or File option to store results"
	exit 198
}

if "`file'" ~= "" & "`replace'" == "" {
	confirm new file "`file'"
}
if "`tfile'" ~= "" & "`replace'" == "" {
	confirm new file "`tfile'"
}
loc K: word count `varlist'
loc O: word count `orders'
tokenize `orders'
loc ordlist "`1'"
loc 1 ""
forv o = 2/`O' {
	loc ordlist "`ordlist', ``o''"
	loc `o' ""
}	
if `O' >= 2 {
	loc maxord = max(`ordlist')
	loc minord = min(`ordlist')
}
else {
	loc maxord = `ordlist'
	loc minord = `ordlist'
}
if `minord' > `K'-2 {
	noi di in re "Polynomial orders must be < `=`K'-1'"
	exit 198
}
else if `maxord' > `K'-2 {
	noi di in re "Cannot fit order-`maxord' polynomial to `=`K'-1' threshold points"
	noi di in re "Only lower-order polynomials will be used"
	loc ords ""
	foreach o in `orders' {
		if `o' <= `K'-2 {
			loc ords "`ords' `o'"
		}
	}
	loc orders "`ords'"
}

* save adjust options
loc options ///
		`popcounts' ///
		`sampcounts' ///
		`wreplacement' ///
		`adjust'

	if "`rate'"~="" loc options "`options' rate("`rate'")"
	if "`nsize'"~="" loc options "`options' nsize("`nsize'")"
	if "`tsize'"~="" loc options "`options' tsize("`tsize'")"
	
tokenize `varlist'
	
marksample touse
qui count if `touse'
if r(N)==0 {
	di in re "no observations"
	exit 2000
}
	
if "`by'" == "" {
	tempvar byvar
	qui g `byvar' = 1 if `touse'
	loc by "`byvar'"
}	

tempvar temptot
qui egen `temptot' = rsum(`varlist') if `touse'

forv k = 1/`K' {
	loc count`k' "``k''"
}

loc pctvars ""
forv k = 1/`=`K'-1' {
	tempvar cnum`k' rnum`k' /*p`k' i`k' ibar`k'*/ // these now come from seg
	qui g `cnum`k'' = 0 if `touse'		
	forv j = 1/`k' {
		qui replace `cnum`k'' = `cnum`k'' + `count`j'' if `touse'
	}	
	qui g `rnum`k'' = `temptot' - `cnum`k'' if `touse'
	loc pctvars `"`pctvars' `cnum`k'' "'
}

loc ucmd ""
if "`unit'" ~= "" {
	loc ucmd "unit(`unit')"
}

loc genvars ""
foreach index in h r o {
	if "``index'seg'" == "hseg" {
		loc genvars "`genvars' h h e e"
	}
	else if "``index'seg'" == "rseg" {
		loc genvars "`genvars' r r i i"	
	}
	else if "``index'seg'" == "oseg" {
		loc genvars "`genvars' o o v v"
	}
}

forv k = 1/`=`K'-1' {
	tempfile seg`k'
	if "`oseg'" == "" {
		qui seg `cnum`k'' `rnum`k'' if `touse', `ind' by(`by') `ucmd' nodisp `options' ///
			gen(`genvars') file(`seg`k'') varlistpctiles
	}
	else if "`oseg'" ~= "" {
		qui seg2 `cnum`k'' `rnum`k'' if `touse', `ind' by(`by') `ucmd' nodisp ///
			gen(`genvars') file(`seg`k'')
	}

	preserve
		use `seg`k'', clear
		qui g thold = `k'
		rename pctile_`cnum`k'' pctile
		drop pctile_`rnum`k''
		sort `by'
		order `by' thold pctile 
		qui save `seg`k'', replace
	restore
}

preserve
	use `seg1', clear
	forv k = 2/`=`K'-1' {
		append using `seg`k''
	}	

	if "`hseg'" == "hseg" {
		replace e = e*ln(2)
	}
	
	if "`rseg'" == "rseg" {
		replace i = i/4
	}

	tempfile tholdseg
	sort `by' thold
	qui save `tholdseg', replace	
	
restore

preserve
	use `tholdseg', clear
	
	qui egen bys = group(`by')
	qui su bys
	loc nby = r(max)
	
	loc hvars ""
	loc rvars ""
	loc ovars ""
	
	foreach ord in `orders' {
		loc pvars ""
		forv o = 1/`ord' {
			qui g double p`o' = pctile^`o'
			loc pvars "`pvars' p`o'"
		}
		if "`hseg'" == "hseg" {
			qui g double h`ord' = .
			qui g double seh`ord' = .
			lab var h`ord' "Rank-order H (unadjusted)"
			lab var seh`ord' "se of Rank-order H (unadjusted)"
			loc hvars "`hvars' h`ord' seh`ord'"
			forv i = 1/`nby' {
			
				capture reg h `pvars' [aw=e^2] if bys==`i' & pctile>0 & pctile<1
				if _rc==0 {
					loc hdelta0 = 1
					loc hdeltas ""
					forv m=1/`ord' {
						loc bsum=0
						forv n=0/`m' {
							loc bsum=`bsum'+((-1)^(`m'-`n'))*comb(`m',`n')/((`m'-`n'+2)^2)
						}
						loc hdelta`m'=2/((`m'+2)^2)+2*`bsum'
						loc hdeltas "`hdeltas' `hdelta`m'',"
					}
					loc hdeltas "`hdeltas' `hdelta0'"
					matrix hD`ord' = (`hdeltas')
					matrix hB`ord' = e(b)
					matrix hV`ord' = e(V)
					matrix h`ord' = hD`ord'*hB`ord''
					qui replace h`ord' = h`ord'[1,1] if bys==`i'
					matrix hse`ord' = hD`ord'*hV`ord'*hD`ord''
					qui replace seh`ord' = sqrt(hse`ord'[1,1]) if bys==`i'
				}
				else {
					* do nothing, the vars h`ord' & seh`ord' are set to missing
				}
			}			
		}	

		if "`hseg'" == "hseg" & "`adjust'" == "adjust" {
			qui g double h`ord'_adj = .
			qui g double seh`ord'_adj = .
			lab var h`ord'_adj "Rank-order H (based on adjusted binary H)"
			lab var seh`ord'_adj "se of Rank-order H (based on adjusted binary H)"
			loc hvars "`hvars' h`ord'_adj seh`ord'_adj"
			forv i = 1/`nby' {
				capture reg h_adj `pvars' [aw=e^2] if bys==`i' & pctile>0 & pctile<1
				
				if _rc==0 {
					loc hadjdelta0 = 1
					loc hadjdeltas ""
					forv m=1/`ord' {
						loc bsum=0
						forv n=0/`m' {
							loc bsum=`bsum'+((-1)^(`m'-`n'))*comb(`m',`n')/((`m'-`n'+2)^2)
						}
						loc hadjdelta`m'=2/((`m'+2)^2)+2*`bsum'
						loc hadjdeltas "`hadjdeltas' `hadjdelta`m'',"
					}
					loc hadjdeltas "`hadjdeltas' `hadjdelta0'"
					matrix hadjD`ord' = (`hadjdeltas')
					matrix hadjB`ord' = e(b)
					matrix hadjV`ord' = e(V)
					matrix hadj`ord' = hadjD`ord'*hadjB`ord''
					qui replace h`ord'_adj = hadj`ord'[1,1] if bys==`i'
					matrix hadjse`ord' = hadjD`ord'*hadjV`ord'*hadjD`ord''
					qui replace seh`ord'_adj = sqrt(hadjse`ord'[1,1]) if bys==`i'
				}
				else {
					* do nothing, the vars h`ord'_adj & seh`ord'_adj are set to missing
				}
			}
		}	

		if "`rseg'" == "rseg" {
			qui g double r`ord' = .
			qui g double ser`ord' = .
			lab var r`ord' "Rank-order R (unadjusted)"
			lab var ser`ord' "se of Rank-order R (unadjusted)"
			loc rvars "`rvars' r`ord' ser`ord'"
			forv i = 1/`nby' {		
				capture reg r `pvars' [aw=i^2] if bys==`i' & pctile>0 & pctile<1
				if _rc==0 {
					loc rdelta0 = 1
					loc rdeltas ""
					forv m=1/`ord' {
						loc rdelta`m' = 6/((`m'+2)*(`m'+3))
						loc rdeltas "`rdeltas' `rdelta`m'',"
					}
					loc rdeltas "`rdeltas' `rdelta0'"
					matrix rD`ord' = (`rdeltas')
					matrix rB`ord' = e(b)
					matrix rV`ord' = e(V)
					matrix r`ord' = rD`ord'*rB`ord''
					qui replace r`ord' = r`ord'[1,1] if bys==`i'
					matrix rse`ord' = rD`ord'*rV`ord'*rD`ord''
					qui replace ser`ord' = sqrt(rse`ord'[1,1]) if bys==`i'
				}
				else {
					* do nothing, the vars r`ord' & ser`ord' are set to missing
				}
			}
		}	

		if "`rseg'" == "rseg" & "`adjust'" == "adjust" {
			qui g double r`ord'_adj = .
			qui g double ser`ord'_adj = .
			lab var r`ord'_adj "Rank-order R (based on adjusted binary R)"
			lab var ser`ord'_adj "se of Rank-order H (based on adjusted binary R)"
			loc rvars "`rvars' r`ord'_adj ser`ord'_adj"
			forv i = 1/`nby' {
				capture reg r_adj `pvars' [aw=i^2] if bys==`i' & pctile>0 & pctile<1
				
				if _rc==0 {
					loc radjdelta0 = 1
					loc radjdeltas ""
					forv m=1/`ord' {
						loc radjdelta`m' = 6/((`m'+2)*(`m'+3))
						loc radjdeltas "`radjdeltas' `radjdelta`m'',"
					}
					loc radjdeltas "`radjdeltas' `radjdelta0'"
					matrix radjD`ord' = (`radjdeltas')
					matrix radjB`ord' = e(b)
					matrix radjV`ord' = e(V)
					matrix radj`ord' = radjD`ord'*radjB`ord''
					qui replace r`ord'_adj = radj`ord'[1,1] if bys==`i'
					matrix radjse`ord' = radjD`ord'*radjV`ord'*radjD`ord''
					qui replace ser`ord'_adj = sqrt(radjse`ord'[1,1]) if bys==`i'
				}
				else {
					* do nothing, the vars r`ord'_adj & ser`ord'_adj are set to missing
				}
			}
		}	

		if "`oseg'" == "oseg" {
			qui g double o`ord' = .
			qui g double seo`ord' = .
			loc ovars "`ovars' o`ord' seo`ord'"
			forv i = 1/`nby' {
				capture reg o `pvars' [aw=v^2] if bys==`i' & pctile>0 & pctile<1
				if _rc==0 { 
					loc odelta0 = 1
					loc odeltas ""
					forv m=1/`ord' {
						loc odelta`m'=4
						forv n=0/`m' {
							loc odelta`m'=`odelta`m''*(2*`n'+1)/(2*`n'+4)
						}
						loc odeltas "`odeltas' `odelta`m'',"
					}
					loc odeltas "`odeltas' `odelta0'"
					matrix oD`ord' = (`odeltas')
					matrix oB`ord' = e(b)
					matrix oV`ord' = e(V)
					matrix o`ord' = oD`ord'*oB`ord''
					qui replace o`ord' = o`ord'[1,1] if bys==`i'
					matrix ose`ord' = oD`ord'*oV`ord'*oD`ord''
					qui replace seo`ord' = sqrt(ose`ord'[1,1]) if bys==`i'
				}
				else {
					* do nothing, the vars r`ord'_adj & ser`ord'_adj are set to missing
				}
			}
		}	
		forv o = 1/`ord' {
			drop p`o'
		}
	}

	qui keep if thold==1
	keep `by' `hvars' `rvars' `ovars'
	order `by' `hvars' `rvars' `ovars'
	sort `by'

	noi if "`file'" ~= "" {
		qui save "`file'", `replace'
		di _n in bl "Rank-Order Index Values Written to Output File:"
		di in ye "`file'"
		di
	}
	
	else {
		tempfile results
		qui save `results'
		noi di _n in bl "Rank-Order Index Values Written to Current File"
	}

	if "`tfile'" ~= "" {
		qui merge 1:m `by' using `tholdseg' 
		drop _merge 
		sort `by' thold
		qui save "`tfile'", `replace'
		di _n in bl "Threshold Index Values Written to Output File:"
		di in ye "`tfile'"
		di
	}
	
restore

if "`file'" == "" {
	sort `by'
	qui merge m:1 `by' using `results'
	drop _merge
}

end
