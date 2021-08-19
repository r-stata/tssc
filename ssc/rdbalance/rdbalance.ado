*! version: 1.03
*! update: 20210608
* Yongli Chen, yongli_chan@163.com
* Yujun Lian, arlionn@163.com
 
*cap program drop rdbalance
program define rdbalance, rclass byable(recall) sort
    version 14.1
    /* obtain settings */
    syntax varlist(min=2 numeric) [if] [in] [,  ///
		Statistics(str)							///
		Wt(varlist min=1 max=1)                 /// weight e.g. IPTW, MMMS   
		ABsolute                                /// report absolute std diff
		Format(string)                          /// formatting numeric values
		CASEwise								/// perform casewise deletion of observationsd
		LEFTControl								/// list control group on the left
		Saving(string asis)		                /// save output
		EXCEL 									/// save as excel
		Vline 									/// vertical border
		NOTitle									/// title of the excel table
		NOTEs(string) * ]						//  notes of the excel table

	local vars `varlist'
	if "`casewise'" == "" {
		local varlist: word 1 of `vars'
	}
	marksample touse
	gettoken treat vars: vars
	
	qui count if `touse'
	if r(N) <= 1 {
		error 2000
	}
	qui tabulate `treat' if `touse'
	if r(r) ~=2 {
		dis in red "cannot find two groups"
		exit 198
	}
	
	if "`statistics'" == "" {
		local statistics N mean sd
	}
	
	if "`wt'" == "" {
		tempvar wt
		qui gen byte `wt' = `touse'
	}
	qui replace `touse' = -`touse'
	
	if `"`format'"' != "" { 
		confirm numeric format `format' 
		local fmt `"`format'"'
	}
	else local fmt "%9.0g"
	
	if `"`saving'"'=="" & "`excel'"!="" {
		dis in r "error: saving option must be specified when exporting Excel format!"
		exit 198
	}
	if `"`saving'"' != "" {
		local saving = subinstr(`"`saving'"', `"""', "", .)
		local saving = subinstr(`"`saving'"', " ", "", .)
		if strmatch(`"`saving'"', "*.*") {
			local suffix = trim(substr(`"`saving'"', strpos(`"`saving'"', ".")+1, .))
			local fname = trim(substr(`"`saving'"', 1, strpos(`"`saving'"', ".")-1))
			if strmatch(`"`suffix'"', "*,*replace*") {
				local suffix = trim(substr(`"`suffix'"', 1, strpos(`"`suffix'"', ",")-1))
			}
			if !inlist(`"`suffix'"', "dta", "xls", "xlsx") {
				dis in r "error: Only supports .dta .xls .xlsx suffix!"
				exit 198
			}
			else {
				if "`excel'" == "" & !inlist(`"`suffix'"', "dta") {
					dis in r `"error: unrecognizable stata suffix .`suffix'!"'
					exit 198
				}
				else if "`excel'" != "" & inlist(`"`suffix'"', "dta") {
					dis in r `"error: excel format is specified and .`suffix' is not a supported excel suffix!"'
					exit 198
				}
				else {
					local fname `"`fname'.`suffix'"'
				}
			}
		}
		else {
			local fname = trim(substr(`"`saving'"', 1, strpos(`"`saving'"', ",")-1))
			if "`excel'" == "" local fname `"`fname'.dta"'
			else local fname `"`fname'.xlsx"'
		}
	}
	
	local varcnt: word count `vars'
	local stacnt: word count `statistics'

*----------- 
*- get basic stats: N, mean, variance, other statistics         
*-----------
	tempname A B A1 B1 X
	qui tabstat `vars' [aweight=`wt'] if `touse', col(stat) by(`treat') ///
		stat(N mean variance sd) nototal longstub save
	mat `B' = r(Stat1)'
	mat `A' = r(Stat2)'
	mata: A = st_matrix("`A'")
	mata: B = st_matrix("`B'")
	mata: C = (A[.,2]:-B[.,2]):/sqrt((A[.,3]+B[.,3])/2)
	mata: D = A[.,3]:/B[.,3]
	if "`leftcontrol'"!="" {
		mata: C = -C
		mata: D = 1:/D
	}
	if "`absolute'" != "" {
		mata: C = abs(C)
	}
	
	if "`statistics'"=="" {
		if "`leftcontrol'"=="" {
			mata: X = A[., (1,2,4)], B[., (1,2,4)], C, D
		}
		else {
			mata: X = B[., (1,2,4)], A[., (1,2,4)], C, D
		}
	}
	else {
		qui tabstat `vars' [aweight=`wt'] if `touse', col(stat) by(`treat') ///
			stat(`statistics') nototal longstub save
		mat `B1' = r(Stat1)'
		mat `A1' = r(Stat2)'
		mata: A1 = st_matrix("`A1'")
		mata: B1 = st_matrix("`B1'")
		if "`leftcontrol'"=="" {
			mata: X = A1, B1, C, D
		}
		else {
			mata: X = B1, A1, C, D
		}
	}
	
	mata: st_matrix("`X'", X)
	mat rownames `X' = `vars'
	mat colnames `X' = `statistics' `statistics' SMD VR
	if "`leftcontrol'"=="" {
		mat coleq `X' = `="Treated "*`stacnt'' `="Control "*`stacnt'' Balance
	}
	else {
		mat coleq `X' = `="Control "*`stacnt'' `="Treated "*`stacnt'' Balance
	}
	
	di _newline(1)
	matlist `X', tw(12) lines(eq) border(bottom) showcoleq(comb) format(`fmt') //`options' 
	di _newline(1)
	
*----------- 
*- saving: excel/dta         
*-----------
	if `"`saving'"' != "" & "`excel'" == "" {
		preserve
		clear
		if "`leftcontrol'"=="" {
			mat coleq `X' = `="Treated_ "*`stacnt'' `="Control_ "*`stacnt'' Balance_
		}
		else {
			mat coleq `X' = `="Control_ "*`stacnt'' `="Treated_ "*`stacnt'' Balance_
		}
		qui svmat double `X', names(eqcol)
		format * `format'
		qui gen varname = ""
		order varname
		local k = 0
		foreach v in `vars' {
			local k = `k' + 1
			qui replace varname = "`v'" in `k'
		}
		foreach v of varlist _all {
			local vlab = subinstr("`v'", "_", " ", .)
			lab var `v' "`vlab'"
		}
		if "`absolute'" != "" label var Balance_SMD "Absolute Standardized Difference" 
		else label var Balance_SMD "Standardized Difference"
		label var Balance_VR "Variance Ratio"
		qui drop if Balance_SMD == .
		label data ""
		save `saving'
		display `"{stata `"use `fname', clear"' : use `fname', clear}"'
	}
	else if `"`saving'"' != "" & "`excel'" != "" {
// 		if (_caller()<14.1) {
// 			dis in r "excel option is not supported by stata lower than 14.1"
// 			exit 198
// 		}
		qui putexcel set `saving'
// 		mat coleq `X' = ""
		local r = 2
		putexcel A`r' = matrix(`X'), names nformat(number_d2) hcenter vcenter //"0.000"
		local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local C1_s = substr("`alphabet'", 2, 1)
		local C1_e = substr("`alphabet'", `=1+`stacnt'', 1)
		local C2_s = substr("`alphabet'", `=1+`stacnt'+1', 1)
		local C2_e = substr("`alphabet'", `=1+`stacnt'*2', 1)
		local C3_s = substr("`alphabet'", `=1+`stacnt'*2+1', 1)
		local C3_e = substr("`alphabet'", `=1+`stacnt'*2+2', 1)
		qui putexcel A1:`C3_e'1, merge hcenter font(bold) border(bottom)
		forvalue i = 1/3 {
			qui putexcel `C`i'_s'2:`C`i'_e'2, merge hcenter
		}
// 		qui putexcel `C1_s'2 "Treatment Group"
// 		qui putexcel `C2_s'2 "Control Group"
// 		qui putexcel `C3_s'2 "Balance"
		qui putexcel A3:`C3_e'3, border(bottom)
		qui putexcel A`=`varcnt'+3':`C3_e'`=`varcnt'+3', border(bottom)
		if "`vline'" != "" {
			qui putexcel A2:A`=`varcnt'+3', border(right)
			qui putexcel `C1_e'2:`C1_e'`=`varcnt'+3', border(right)
			qui putexcel `C2_e'2:`C2_e'`=`varcnt'+3', border(right)
		}
		if "`notitle'" == "" {
			qui putexcel A1 = "Table 1 Summary statistics and balance test"
		}
		if "`notes'" != "" {
			qui putexcel A`=`varcnt'+4':`C3_e'`=`varcnt'+4', merge left top font(Calibri, 9) txtwrap
			qui putexcel A`=`varcnt'+4' = "`notes'"
		}
		cap confirm file `fname'
		if _rc == 0 {
			display `"{stata `"shellout `fname'"' : shellout `fname'}"'
		}
		else {
			local fname = subinstr(`"`fname'"', ".xlsx", ".xls", .)
			cap confirm file `fname'
			if _rc == 0 {
				display `"{stata `"shellout `fname'"' : shellout `fname'}"'
			}
		}
	}

	/* store results */
	mata: st_local("masd", strofreal(abs(mean(C))))    // mean of the absolute standardized diffs
	mata: st_local("mvr", strofreal(abs(mean(D))))     // mean of the variance ratios
	return scalar masd = `masd'
	return scalar mvr = `mvr'
	return matrix table = `X'
	return scalar varcnt = `varcnt'
	return scalar stacnt = `stacnt'
end
