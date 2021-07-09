cap program drop ultimatch
program define ultimatch, rclass
	version 9.0
	syntax [varlist(default=none)] [if] [in], [EXAct(varlist)] [CAliper(real -1.0)] [Draw(integer -1)] [EXP(string)] [Limit(string)] Treated(varname) [REport(varlist))] [UNIt(varlist)] [Between] [Greedy] [SIngle] [SUpport] [UNMatched] [COpy] [Full] [RANk] [EUclid] [Mahalanobis] [RADius]
	tempvar axis tr mark cell nouse base cluster claim cnt trcnt ctcnt miss
	tempname table cell matrix row
	matrix `matrix' = (.)
	return matrix match = `matrix'
	if `caliper' <= 0 {
		local caliper = .
	}
	if `draw' <= 0 {
		local draw = .
	}
	tokenize `"`varlist'"'
	local copy = "`copy'"' != ""
	local unmatched = "`unmatched'" != ""
	local between = "`between'" != ""
	local greedy = "`greedy'" != ""
	local single = "`single'" != ""
	local support = "`support'" != ""
	local rank = "`rank'" != ""
	local euclid = "`euclid'" != ""
	local mahalanobis = "`mahalanobis'" != ""
	local full = "`full'" != ""
	local radius = "`radius'" != ""
	local clustered = 0
	local method = ""
	if `greedy' & `copy' {
		di as error "options greedy and copy are mutually exclusive"
		error 999
	}
	if `euclid' & `mahalanobis' {
		di as error "options euclid and mahalanobis are mutually exclusive"
		error 999
	}
	if `full' & `copy' == 0 {
		di as error "full is a sub-option of copy"
		error 999
	}
	if `unmatched' & "`report'" == "" {
		di as error "unmatched is a sub-option of report"
		error 999
	}
	if `"`1'"' != "" {
		if `"`2'"' != "" {
			local method = "Distance"
		}
		else {
			local method = "Score"
		}
	}
	if "`method'" == "" {
		if `"`exact'"' != "" {
			if  `draw' != . | `caliper' != . | `between' | `greedy' | `support' | `copy' | `rank' | `euclid' | `mahalanobis' | `radius' {
				di as error "coarsened exact mode does not support following options: draw, caliper, between, greedy, support, copy, rank, single, euclid, mahalanobis, radius"
				error 999
			}
			local draw = .
			local caliper = 1
		}
		else {
			di as error "if varlist is empty, exact option has to be specified"
			error 999
		}
	}
	if "`method'" == "Distance" & (`draw' != . | `between') {
		di as error "distance based matching does not support following options: draw, between"
		error 999
	}
	if "`method'" == "Score" & (`euclid' | `mahalanobis') {
		di as error "score based matching does not support following options: euclid, mahalanobis"
		error 999
	}
	if `radius' & (`between' | `greedy' | `single' | `draw' != .) {
		di as error "radius matching does not support following options: between, greedy, single, draw"
		error 999
	}
	if `radius' & `caliper' == . {
		di as error "radius matching requires the specification of option: caliper"
		error 999
	}
	if "`method'" == "Distance" {
		if `rank' {
			if `mahalanobis' == 0 {
				local euclid = 1
			}
		}
		else {
			if `euclid' == 0 {
				local mahalanobis = 1
			}
		}
	}
	if `full' {
		local copy = 2
	}
	local matching = cond(`copy',"Copying ","")
	local matching = "`matching'" + cond(`support',"Supported ","")
	local matching = "`matching'" + cond(`single',"Single ","")
	local matching = "`matching'" + cond(`greedy',"Greedy ","")
	local matching = "`matching'" + cond(`between',"Sandwiched ","")
	local matching = "`matching'" + cond(`euclid',"Euclidean ","")
	local matching = "`matching'" + cond(`mahalanobis',"Mahalanobis ","")	
	local matching = "`matching'" + cond("`method'" != "","`method'-based ", "")
	local matching = "`matching'" + cond(`rank',"Percentile Rank ", "")
	local matching = "`matching'" + cond(`radius',"Radius ", "")
	local matching = "`matching'" + cond("`method'" != "" & `radius' == 0,"Neighborhood ", "")
	local matching = "`matching'" + cond("`method'" == "","Coarsened Exact ", "")
	local matching = "`matching'" + "Matching"
	cap confirm var _match
	if _rc == 0 {
		di as error "_match is already defined"
		error 999
	}
	cap confirm var _weight
	if _rc == 0 {
		di as error "_weight is already defined"
		error 999
	}
	if "`Method'" != "" {
		cap confirm var _distance
		if _rc == 0 {
			di as error "_distance is already defined"
			error 999
		}
		if `greedy' == 0 {
			cap confirm var _copy
			if _rc == 0 {
				di as error "_copy is already defined"
				error 999
			}
		}
	}
	if `support' {
		cap confirm var _support
		if _rc == 0 {
			di as error "_support is already defined"
			error 999
		}
	}
	di as text "`matching'"
	return local matching = "`matching'"
	if "`exp'" != "" {
		local exp = "`exp' "
		local cmd = ""
		local var = ""
		local prev = ""
		local len = length("`exp'")
		forvalue i = 1/`len' {
			local chr = substr("`exp'",`i',1)
			if "`var'" == "" {
				if regexm("`chr'","[a-zA-Z._]") {
					local var = "`chr'"
				}
				else {
					local cmd = "`cmd'`chr'"
				}
			}
			else {
				if regexm("`chr'","[a-zA-Z._0-9]") {
					local var = "`var'`chr'"
				}
				else if "`chr'" == "(" {
					local cmd = "`cmd'`var'`chr'"
					local var = ""
				}
				else {
					if regexm("`var'","t\..+") {
						local var = substr("`var'",3,.)
						cap confirm var `var'
						if _rc == 0 {
							local var = "`var'[t]"
						}
					}
					else {
						cap confirm var `var'
						if _rc == 0 {
							local var = "`var'[c]"
						}
					}
					local cmd = "`cmd'`var'`chr'"
					local var = ""
				}
			}
		}
		local test = subinstr(subinstr(`"`cmd'"',"[c]","[2]",.),"[t]","[1]",.)
		cap local test = `test'
		if _rc != 0 {
			di as error `"invalid expression: `exp'"'
			error 999
		}
	}
	else {
		local cmd = ""
	}
	qui des, varlist
	local names = r(varlist)
	qui gen byte `nouse' = 9
	qui replace `nouse' = 0 `if' `in'
	qui replace `nouse' = 9 if `treated' == .
	if "`exact'" != "" {
		qui egen long `miss' = rmiss(`exact') if `nouse' == 0
		qui replace `nouse' = 9 if `miss' > 0 & `miss' != .
		qui drop `miss'
	}
	if "`method'" != "" {	
		qui egen long `miss' = rmiss(`*') if `nouse' == 0
		qui replace `nouse' = 9 if `miss' > 0 & `miss' != .
		qui drop `miss'
		local score = `"`1'"'
	}
	qui gen byte `tr' = (`treated' == 1) if `nouse' == 0
	if `support' {
		qui sum `score' if `nouse' == 0 & `tr' == 1
		local Ns = r(N)
		local max = r(max)
		local min = r(min)
		qui sum `score' if `nouse' == 0 & `tr' == 0
		local Ns = `Ns'+r(N)
		local max = min(r(max), `max')
		local min = max(r(min), `min')
		qui gen byte _support = `score' <= `max' & `score' >= `min' if `nouse' == 0
		label var _support "common support"
		qui replace `nouse' = 7 if `nouse' == 0 & _support == 0 // non-supported nouse < general nouse
	}
	if "`limit'" != "" | `rank' {
		local vars = ""
		local range = ""
		local i = 1
		local var = word("`limit'", `i')
		while "`var'" != "" {
			cap confirm var `var'
			if _rc != 0 {
				di as error `"invalid limitation variable `var'"'
				error 999
			}
			local j = `j'+1
			local vars = "`vars' `var'"
			local i = `i'+1
			local var = word("`limit'", `i')
			cap confirm number `var'
			if _rc == 0 {
				local ranges = "`ranges' `var'"
				local i = `i'+1
				local var = word("`limit'", `i')
			}
			else {
				local ranges = "`ranges' 5"
			}
		}
		if "`vars'" != "" {
			local vars = trim("`vars'")
			local ranges = trim("`ranges'")
			qui egen long `miss' = rmiss(`vars') if `nouse' == 0
			qui replace `nouse' = 9 if `miss' > 0 & `miss' != .
			qui drop `miss'
		}
		if `rank' {
			local vars = "`vars' `*'"
			local vars = trim("`vars'")
		}
		qui count if `nouse' == 0
		local N = r(N)
		local limit = ""
		local ranks = ""
		local i = 1
		local var = word("`vars'", `i')
		local range = word("`ranges'", `i')
		while `"`var'"' != "" {
			tempvar r`i'
			sort `nouse' `var'
			qui egen double `cnt' = count(1) in 1/`N', by(`nouse' `var')
			qui gen double `r`i'' = (_n - 1 + 0.5 * `cnt')/`N' * 100 in 1/`N' if `var' != `var'[_n-1]
			qui replace `r`i'' = `r`i''[_n-1] in 1/`N' if `r`i'' == .
			qui drop `cnt'
			if "`range'" != "" {
				local limit = `"`limit' & abs(`r`i''[t]-`r`i''[c]) <= `range'"'
			}
			else {
				local ranks = "`ranks' `r`i''"
			}
			local i = `i'+1
			local var = word("`vars'", `i')
			local range = word("`ranges'", `i')
		}
		local limit = substr(trim(`"`limit'"'),3,.)
		local ranks = trim("`ranks'")
	}
	else {
		qui count if `nouse' == 0
		local N = r(N)
		sort `nouse'
	}
	local obs1 = _N
	if "`unit'" != "" {
		if word("`unit'",2) == "" {
			local cluster = "`unit'"
		}
		else {
			qui egen long `cluster' = group(`unit') in 1/`N'
		}
		local clustered = 1
	}
	else {
		qui gen long `cluster' = _n in 1/`N'
	}
	if `"`report'"' != "" & `unmatched' {
		qui gen byte `base' = (`nouse' == 0)
	}
	if `"`exact'"' != "" {
		sort `exact' in 1/`N'
		qui egen long `cell' = group(`exact') in 1/`N'
	}
	else {
		qui gen byte `cell' = 1 in 1/`N'
	}
	if "`method'" == "Distance" {
		if `radius' {
			qui gen long _match = .
			qui gen double _weight = .
			qui gen double _distance = .
			label var _match "match id"
			label var _weight "pweight"
			if `rank' {
				if `mahalanobis' {
					label var _distance "closest mahalanobis rank radius distance"
				}	
				else {
					label var _distance "closest euclidean rank radius distance"
				}
				local distvars = "`ranks'"
			}
			else {
				if `mahalanobis' {
					label var _distance "closest mahalanobis radius distance"
				}	
				else {
					label var _distance "closest euclidean radius distance"
				}
				local distvars = "`*'"
			}
			qui gen double `axis' = .
			order `nouse' `axis' `cell' `tr' _match _distance _weight `distvars'
			local varcnt = wordcount("`distvars'")
			if `mahalanobis' {
				qui corr `distvars' in 1/`N', covar noformat
				matrix `matrix' = invsym(r(C))
			}
			else {
				matrix `matrix' = diag(J(1,`varcnt',1)) // identity matrix replaces inverted covariance matrix for eucledian distance
			}
			mata: _ultimatchdistanceaxis(`N', 2, 8, "`matrix'")
			sort `nouse' `cell' `axis' `tr'
			mata: _ultimatchradius(`varcnt', "`matrix'", `caliper', `copy')
			local M = r(obs)
			if r(match) == 0 {
				di as error "unable to match"
				drop _match _weight _distance
				error 999
			}
			return scalar comp = r(comp)
			order _match _weight _distance
		}
		else {
			qui gen long `claim' = .
			qui gen long _match = .
			qui gen double _weight = .
			qui gen double _distance = .
			label var _match "match id"
			label var _weight "pweight"
			if `rank' {
				if `mahalanobis' {
					label var _distance "nearest mahalanobis rank distance"
				}	
				else {
					label var _distance "nearest euclidean rank distance"
				}
				local distvars = "`ranks'"
			}
			else {
				if `mahalanobis' {
					label var _distance "nearest mahalanobis distance"
				}	
				else {
					label var _distance "nearest euclidean distance"
				}
				local distvars = "`*'"
			}
			qui gen double `axis' = .
			order `nouse' `axis' `cell' `tr' _match _distance _weight `claim' `distvars'
			local varcnt = wordcount("`distvars'")
			if `mahalanobis' {
				qui corr `distvars' in 1/`N', covar noformat
				matrix `matrix' = syminv(r(C))
			}
			else {
				matrix `matrix' = diag(J(1,`varcnt',1)) // identity matrix replaces inverted covariance matrix for eucledian distance
			}
			mata: _ultimatchdistanceaxis(`N', 2, 9, "`matrix'")
			sort `nouse' `cell' `axis' `tr'
			mata: _ultimatchdistance(`varcnt', "`matrix'", `caliper', `single', `greedy', `copy')
			qui drop `claim'
			local M = r(obs)
			if r(match) == 0 {
				di as error "unable to match"
				drop _match _weight _distance
				error 999
			}
			return scalar comp = r(comp)
			order _match _weight _distance
		}
	}
	else if "`method'" == "Score" {
		if `radius' {
			qui gen long _match = .
			qui gen double _weight = .
			qui gen double _distance = .
			label var _match "match id"
			label var _weight "pweight"
			if `rank' {
				label var _distance "closest rank radius distance"
				local distvars = "`ranks'"
			}
			else {
				label var _distance "closest radius distance"
				local distvars = "`score'"
			}
			sort `nouse' `cell' `distvars' `tr'	
			order `nouse' `distvars' `cell' `tr' _match _distance _weight
			mata: _ultimatchradius(1, "", `caliper', `copy')
			local M = r(obs)
			if r(match) == 0 {
				di as error "unable to match"
				drop _match _weight _distance
				error 999
			}
			return scalar comp = r(comp)
			order _match _weight _distance
		}
		else {
			qui gen long `claim' = .
			qui gen long _match = .
			qui gen double _weight = .
			qui gen double _distance = .
			label var _match "match id"
			label var _weight "pweight"
			if `rank' {
				label var _distance "nearest rank distance"
				local distvars = "`ranks'"
			}
			else {
				label var _distance "nearest distance"
				local distvars = "`score'"
			}
			if `draw' == . {
				local draw = 1
			}
			sort `nouse' `cell' `distvars' `tr'	
			order `nouse' `distvars' `cell' `tr' _match _distance _weight `claim'
			mata: _ultimatchneighbor(`caliper', `single', `draw', `between', `greedy', `copy')
			qui drop `claim'
			local M = r(obs)
			if r(match) == 0 {
				di as error "unable to match"
				drop _match _weight _distance
				error 999
			}
			return scalar comp = r(comp)
			order _match _weight _distance
		}
	}
	else {
		sort `nouse' `cell' 
		qui egen double `trcnt' = sum(`tr') in 1/`N', by(`cell')
		qui egen double `ctcnt' = sum(1-`tr') in 1/`N', by(`cell')
		qui gen double _weight = `trcnt'/`ctcnt' in 1/`N' if `trcnt' > 0 & `ctcnt' > 0 
		label var _weight "pweight"
		qui drop `trcnt' `ctcnt'
		qui replace _weight = 1 in 1/`N' if `tr' == 1 & _weight != .
		qui egen long _match = group(`cell') in 1/`N' if _weight != .
		label var _match "match id"
		local M = `N'
		qui count in 1/`N' if _match != .
		if r(N) == 0 {
			di as error "unable to match"
			drop _match _weight
			error 999
		}
		order _match _weight
	}
	if `copy' {
		qui gen byte _copy = .
		label var _copy "copied observation"	
		local obs1 = `obs1'+1
		local obs2 = _N
		if `obs1' <= `obs2' {
			qui replace _copy = 1 in `obs1'/`obs2'
			local clustered = 1
		}
	}
	order `names'
	di as text "{hline 17}{c TT}{hline 32}"
	di as text "{ralign 16:Support} {c |}        Treated         Control"
	di as text "{hline 17}{c +}{hline 32}"
	if `support' {
		qui tab _support `tr' in 1/`Ns', matcell(`cell') matrow(`row')
		if `row'[2,1] == . {
			if `row'[1,1] == 1 {
				matrix `cell' = J(1,2,0) \ `cell'
			}
			else {
				matrix `cell' = `cell' \ J(1,2,0)
			}
		}
		di as text "{ralign 16:Total} {c |} " as result %14.9g `cell'[1,2]+`cell'[2,2] "  "  %14.9g `cell'[1,1]+`cell'[2,1]
		di as text "{ralign 16:Without} {c |} " as result %14.9g `cell'[1,2] "  "  %14.9g `cell'[1,1]
		di as text "{ralign 16:With} {c |} " as result %14.9g `cell'[2,2] "  "  %14.9g `cell'[2,1]
		matrix `matrix' = (`cell'[1,2]+`cell'[2,2],`cell'[1,1]+`cell'[2,1],.,.,.)
		matrix `matrix' = `matrix' \ (`cell'[1,2],`cell'[1,1],.,.,.)
		matrix `matrix' = `matrix' \ (`cell'[2,2],`cell'[2,1],.,.,.)
	}
	else {
		qui count in 1/`M' if `tr' == 1
		di as text "{ralign 16:Total} {c |} " as result %14.9g r(N) "  "  %14.9g `M'-r(N)
		di as text "{ralign 16:Without} {c |} " as result %14.9g 0 "  "  %14.9g 0
		di as text "{ralign 16:With} {c |} " as result %14.9g r(N) "  "  %14.9g `M'-r(N)
		matrix `matrix' = (r(N), `M'-r(N),.,.,.)
		matrix `matrix' = `matrix' \ (0,0,.,.,.)
		matrix `matrix' = `matrix' \ (r(N), `M'-r(N),.,.,.)
	}
	local rownames = "total without with "
	qui replace `nouse' = 1 if _match == 0 | _match == .
	sort `nouse' `tr' `cluster'
	qui count if `nouse' == 0
	local N = r(N)
	if `N' == 0 {
		di as text "{hline 17}{c BT}{hline 32}
		di as error "no observations"
		error 999
	}
	qui count in 1/`N' if `tr' == 0
	local ntr = r(N)
	local tre = `ntr'+1
	if `ntr' == 0 {
		di as text "{hline 17}{c BT}{hline 32}
		di as error "no control observations"
		error 999
	}
	if `tre' > `N' {
		di as text "{hline 17}{c BT}{hline 32}
		di as error "no treated observations"
		error 999
	}
	di as text "{hline 17}{c +}{hline 32}
	matrix `cell' = (`N'-`ntr',`ntr')
	di as text "{ralign 16:Matched} {c |} " as result %14.9g `cell'[1,1] "  "  %14.9g `cell'[1,2]
	matrix `matrix' = `matrix' \ (`cell'[1,1],`cell'[1,2],.,.,.)
	local rownames = "`rownames' matched"
	qui gen byte `mark' = 1 in 1/`ntr' if `cluster' == `cluster'[_n-1] | `cluster' == `cluster'[_n+1] 
	qui replace `mark' = `cluster' == `cluster'[`ntr'-1] in `ntr'
	qui count in 1/`ntr' if `mark' == 1 
	local cluc = r(N)
	qui drop `mark'
	qui gen byte `mark' = 1 in `tre'/`N' if `cluster' == `cluster'[_n-1] | `cluster' == `cluster'[_n+1] 
	qui replace `mark' = `cluster' == `cluster'[`N'-1] in `N'
	qui count in `tre'/`N' if `mark' == 1 
	local clutr = r(N)
	qui drop `mark'
	di as text "{ralign 16:Clustered} {c |} " as result %14.9g `clutr' "  "  %14.9g `cluc'
	matrix `matrix' = `matrix' \ (`clutr',`cluc',.,.,.)
	local rownames = "`rownames' clustered"
	qui count in 1/`ntr' if `cluster' != `cluster'[_n-1]
	local cluc = r(N)
	qui count in `tre'/`N' if `cluster' != `cluster'[_n-1]
	local clutr = r(N)
	if `cluster'[`tre'] == `cluster'[`tre'-1] {
		local clutr = `clutr'+1
	}
	di as text "{ralign 16: Clusters} {c |} " as result %14.9g `clutr' "  "  %14.9g `cluc'
	matrix `matrix' = `matrix' \ (`clutr',`cluc',.,.,.)
	local rownames = "`rownames' clusters"
	if "`report'" == "" {
		di as text "{hline 17}{c BT}{hline 32}"
	}	
	if "`report'" != "" {
		di as text "{hline 17}{c +}{hline 32}{c TT}{hline 26}"
		if `unmatched' {
			if "`unit'" != "" & `clustered' {
				di as text "{dup 7: }Unmatched {c |}        Treated         Control {c |} CluStdErr        t  p>|t|"
			}
			else {
				di as text "{dup 7: }Unmatched {c |}        Treated         Control {c |}    StdErr        t  p>|t|"
			}
			di as text "{hline 17}{c +}{hline 32}{c +}{hline 26}"
			foreach v of varlist `report' {
				if "`unit'" == "" & `clustered' {
					qui reg `v' `tr' if `base' == 1, vce(cluster `cluster')
				}
				else {
					qui reg `v' `tr' if `base' == 1
				}
				matrix `table' = r(table)
				local tmean = `table'[1,1]+`table'[1,2]
				local cmean = `table'[1,2]
				local r = `table'[2,1]
				local t = `table'[3,1]
				local p = `table'[4,1]
				local var = substr("`v'",1,16)
				di as text "{ralign 16:`var'} {c |} " as result %14.9g `tmean' "  "  %14.9g `cmean' as text " {c |} " as result %9.6g `r' "  " %7.2f `t' "  " %5.3f `p'
				matrix `matrix' = `matrix' \ (`tmean',`cmean',`r',`t',`p')
				local rownames = "`rownames' u_`v'"
			}		
			di as text "{hline 17}{c +}{hline 32}{c +}{hline 26}"
		}
		if `clustered' {
			di as text "{dup 9: }Matched {c |}        Treated         Control {c |} CluStdErr        t  p>|t|"
		}
		else {
			di as text "{dup 9: }Matched {c |}        Treated         Control {c |}    StdErr        t  p>|t|"
		}
		di as text "{hline 17}{c +}{hline 32}{c +}{hline 26}"
		foreach v of varlist `report' {
			if `clustered' {
				qui reg `v' `tr' [pweight=_weight] in 1/`N', vce(cluster `cluster')
			}
			else {
				qui reg `v' `tr' [pweight=_weight] in 1/`N'
			}
			matrix `table' = r(table)
			local tmean = `table'[1,1]+`table'[1,2]
			local cmean = `table'[1,2]
			local r = `table'[2,1]
			local t = `table'[3,1]
			local p = `table'[4,1]
			local var = substr("`v'",1,16)
			di as text "{ralign 16:`var'} {c |} " as result %14.9g `tmean' "  "  %14.9g `cmean' as text " {c |} " as result %9.6g `r' "  " %7.2f `t' "  " %5.3f `p'
			matrix `matrix' = `matrix' \ (`tmean',`cmean',`r',`t',`p')
			local rownames = "`rownames' m_`v'"
		}		
		di as text "{hline 17}{c BT}{hline 32}{c BT}{hline 26}"
	}
	matrix rownames `matrix' = `rownames'
	if "`report'" == "" {
		matrix `matrix' = `matrix'[.,1..2]
		matrix colnames `matrix' = treated control
	}
	else {
		matrix colnames `matrix' = treated control stderr t p
	}
	return matrix match = `matrix'
end

mata:
void _ultimatchneighbor(real scalar caliper, real scalar single, real scalar draw, real scalar between, real scalar greedy, real scalar copy)
{	real matrix D, neighbor, nb, miss
	real scalar hood, top, bot, tgo, bgo, tdif, bdif, tprev, bprev, tcnt, bcnt, cnt, rows
	real scalar i, j, w, reset, claim
	real scalar match, obs, uselimit, usecmd
	string scalar limit, cmd, explimit, expcmd, exp, str
	real scalar comp
	
	obs = st_nobs()
	for (i=1; i <= obs; i++)
	{	if (_st_data(i,1) != 0) // nouse
		{	break
		}
	}
	obs = i-1
	if (obs <= 0)
	{	st_numscalar("r(obs)", 0)	
		st_numscalar("r(match)", 0)
		return
	}
	st_view(D=.,(1,obs),(2..8)) // score:1, cell:2, treated:3, match:4, distance:5, weight:6, claim:7
	limit = st_local("limit")
	cmd = st_local("cmd")
	uselimit = 0
	usecmd = 0
	if (limit != "")
	{	limit = "local limitok = "+limit
		uselimit = 1
	}
	if (cmd != "")
	{	cmd = "local cmdok = "+cmd
		usecmd = 1
	}
	if (greedy)
	{	copy = 0
	}
	comp = 0
	miss = J(1,4,.)
	neighbor = J(obs,3,0)
	match = 0
	i = 0
	while (1)
	{	i++
		if (i > obs)
		{	break
		}
		if (D[i,3] == 0)
		{	continue
		}
		if (D[i,4] != .)
		{	match = D[i,4]
			if (D[i,6] != .)
			{	continue
			}
		}
		else
		{	match++
		}
		if (uselimit)
		{	explimit = subinstr(limit,"[t]","["+strofreal(i)+"]")
		}
		if (usecmd)
		{	expcmd = subinstr(cmd,"[t]","["+strofreal(i)+"]")
		}
		top = i
		bot = i
		tgo = 1
		bgo = 1
		tcnt = 0
		bcnt = 0
		tprev = .
		bprev = .
		hood = 0
		while (1)
		{	while (tgo & top != .)
			{	top--
				if (top < 1)
				{	top = .
					break
				}
				if (D[i,2] != D[top,2])
				{	top = .
					break
				}
				if (D[top,3] == 1)
				{	continue
				}
				if (greedy & D[top,4] == match)
				{	tdif = D[top,5]
					D[top,4..7] = miss
					comp++
					break
				}
				tdif = D[i,1]-D[top,1]
				if (tdif > caliper)
				{	top = .
					break
				}
				comp++
				if (greedy & tdif >= D[top,5])
				{	continue
				}
				if (uselimit | usecmd)
				{	str = strofreal(top)
					if (uselimit)
					{	exp = subinstr(explimit,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("limitok") != "1")
						{	continue
						}
					}
					if (usecmd)
					{	exp = subinstr(expcmd,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("cmdok") != "1")
						{	continue
						}
					}
				}
				break
			}
			while (bgo & bot != .)
			{	bot++
				if (bot > obs)
				{	bot = .
					break
				}
				if (D[i,2] != D[bot,2])
				{	bot = .
					break
				}
				if (D[bot,3] == 1)
				{	continue
				}

				if (greedy & D[bot,4] == match)
				{	bdif = D[bot,5]
					D[bot,4..7] = miss
					comp++
					break
				}
				bdif = D[bot,1]-D[i,1]
				if (bdif > caliper)
				{	bot = .
					break
				}
				comp++
				if (greedy & bdif >= D[bot,5])
				{	continue
				}
				if (uselimit | usecmd)
				{	str = strofreal(bot)
					if (uselimit)
					{	exp = subinstr(explimit,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("limitok") != "1")
						{	continue
						}
					}
					if (usecmd)
					{	exp = subinstr(expcmd,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("cmdok") != "1")
						{	continue
						}
					}
				}
				break
			}
			bgo = 0
			tgo = 0
			if (top != . & (between | bot == . | tdif <= bdif))
			{	tgo = 1
				if (tprev != tdif)
				{	tcnt++
					if (between)
					{	if (tcnt > draw)
						{	top = .
						}
					}
					else
					{	if (tcnt+bcnt > draw)
						{	top = .
							bot = .
						}
					}
				}
				if (top != .)
				{	tprev = tdif
					hood++
					neighbor[hood,1] = top
					neighbor[hood,2] = tdif
					neighbor[hood,3] = 0
				}
			}
			if (bot != . & (between | top == . | bdif < tdif))
			{	bgo = 1
				if (bprev != bdif)
				{	bcnt++
					if (between)
					{	if (bcnt > draw)
						{	bot = .
						}
					}
					else
					{	if (tcnt+bcnt > draw)
						{	top = .
							bot = .
						}
					}
				}
				if (bot != .)
				{	bprev = bdif
					hood++
					neighbor[hood,1] = bot
					neighbor[hood,2] = bdif
					neighbor[hood,3] = 1
				}
			}
			if (bot == . & top == .)
			{	break
			}
		}
		if (hood == 0)
		{	D[i,4..7] = miss
			match--
			continue
		}
		if (single)
		{	nb = _ultimatchsingle(neighbor[1..hood,.],between,draw)
			hood = rows(nb)
		}
		else
		{	nb = neighbor[1..hood,.]
		}
		w = 1/hood
		D[i,4] = match
		D[i,5] = 0
		D[i,6] = 1
		if (copy == 1)
		{	for (j = 1; j <= hood; j++)
			{	pos = nb[j,1]
				dif = nb[j,2]
				if (D[pos,4] == .)
				{	D[pos,4] = match
					D[pos,5] = dif
					D[pos,6] = w
				}
				else
				{	_ultimatchcopy(pos)
					_st_store(st_nobs(), 5, match)
					_st_store(st_nobs(), 6, dif)
					_st_store(st_nobs(), 7, w)
				}
			}
		}
		else if (copy == 2)
		{	D[i,6] = w
			for (j = 1; j <= hood; j++)
			{	pos = neighbor[j,1]
				dif = neighbor[j,2]
				if (j > 1)
				{	match++
					_ultimatchcopy(i)
					_st_store(st_nobs(), 5, match)
				}
				if (D[pos,4] == .)
				{	D[pos,4] = match
					D[pos,5] = dif
					D[pos,6] = w
				}
				else
				{	_ultimatchcopy(pos)
					_st_store(st_nobs(), 5, match)
					_st_store(st_nobs(), 6, dif)
					_st_store(st_nobs(), 7, w)
				}
			}
		}
		else if (greedy)
		{	reset = i
			for (j = 1; j <= hood; j++)
			{	pos = nb[j,1]
				dif = nb[j,2]
				claim = D[pos,7]
				if (claim != .)
				{	if (claim < reset)
					{	reset = claim
					}
					D[claim,6] = .
				}
				D[pos,4] = match
				D[pos,5] = dif
				D[pos,6] = w
				D[pos,7] = i
			}
			if (reset < i)
			{	i = reset-1
			}
		}
		else
		{	for (j = 1; j <= hood; j++)
			{	pos = nb[j,1]
				dif = nb[j,2]
				if (dif < D[pos,5])
				{	D[pos,4] = match
					D[pos,5] = dif
				}
				if (D[pos,6] == .)
				{	D[pos,6] = w
				}
				else
				{	D[pos,6] = D[pos,6] + w
				}
			}
		}
	}
	st_numscalar("r(obs)", obs)	
	st_numscalar("r(match)", match)
	st_numscalar("r(comp)", comp)
	return
}

void _ultimatchradius(real scalar varcnt, string scalar covmat, real scalar caliper, real scalar copy)
{	real matrix D, M, C, neighbor, difvec
	real scalar hood, top, bot, dif, dist, distance
	real scalar i, j, w
	real scalar match, obs, uselimit, usecmd
	string scalar limit, cmd, explimit, expcmd, exp, str
	real scalar comp
	
	obs = st_nobs()
	for (i=1; i <= obs; i++)
	{	if (_st_data(i,1) != 0) // nouse
		{	break
		}
	}
	obs = i-1
	if (obs <= 0)
	{	st_numscalar("r(obs)", 0)	
		st_numscalar("r(match)", 0)
		return
	}
	st_view(D=.,(1,obs),(2..7)) // score:1, cell:2, treated:3, match:4, distance:5, weight:6
	if (varcnt > 1)
	{	st_view(M=.,(1,obs),(8..8+varcnt-1)) // distance variables
		C = st_matrix(covmat)
		distance = 1
	}
	else
	{	distance = 0
	}
	limit = st_local("limit")
	cmd = st_local("cmd")
	uselimit = 0
	usecmd = 0
	if (limit != "")
	{	limit = "local limitok = "+limit
		uselimit = 1
	}
	if (cmd != "")
	{	cmd = "local cmdok = "+cmd
		usecmd = 1
	}
	comp = 0
	neighbor = J(obs,2,.)
	match = 0
	i = 0
	while (1)
	{	i++
		if (i > obs)
		{	break
		}
		if (D[i,3] == 0)
		{	continue
		}
		if (uselimit)
		{	explimit = subinstr(limit,"[t]","["+strofreal(i)+"]")
		}
		if (usecmd)
		{	expcmd = subinstr(cmd,"[t]","["+strofreal(i)+"]")
		}
		match++
		top = i
		bot = i
		hood = 0
		while (1)
		{	top--
			if (top < 1)
			{	break
			}
			if (D[i,2] != D[top,2])
			{	break
			}
			dif = D[i,1]-D[top,1]
			if (dif > caliper)
			{	break
			}
			if (D[top,3] == 1)
			{	continue
			}
			comp++
			if (uselimit | usecmd)
			{	str = strofreal(top)
				if (uselimit)
				{	exp = subinstr(explimit,"[c]","["+str+"]")
					stata(exp,1,1)
					if (st_local("limitok") != "1")
					{	continue
					}
				}
				if (usecmd)
				{	exp = subinstr(expcmd,"[c]","["+str+"]")
					stata(exp,1,1)
					if (st_local("cmdok") != "1")
					{	continue
					}
				}
			}
			if (distance)
			{	difvec = M[i,.] :- M[top,.]
				difvec = difvec * C * difvec'
				dist = sqrt(difvec[1,1])
				if (dist <= caliper)
				{	hood++
					neighbor[hood,1] = top
					neighbor[hood,2] = dist
				}
			}
			else
			{	hood++
				neighbor[hood,1] = top
				neighbor[hood,2] = dif
			}
		}
		while (1)
		{	bot++
			if (bot > obs)
			{	break
			}
			if (D[i,2] != D[bot,2])
			{	break
			}
			dif = D[bot,1]-D[i,1]
			if (dif > caliper)
			{	break
			}
			if (D[bot,3] == 1)
			{	continue
			}
			comp++
			if (uselimit | usecmd)
			{	str = strofreal(bot)
				if (uselimit)
				{	exp = subinstr(explimit,"[c]","["+str+"]")
					stata(exp,1,1)
					if (st_local("limitok") != "1")
					{	continue
					}
				}
				if (usecmd)
				{	exp = subinstr(expcmd,"[c]","["+str+"]")
					stata(exp,1,1)
					if (st_local("cmdok") != "1")
					{	continue
					}
				}
			}
			if (distance)
			{	difvec = M[i,.] :- M[bot,.]
				difvec = difvec * C * difvec'
				dist = sqrt(difvec[1,1])
				if (dist <= caliper)
				{	hood++
					neighbor[hood,1] = bot
					neighbor[hood,2] = dist
				}
			}
			else
			{	hood++
				neighbor[hood,1] = bot
				neighbor[hood,2] = dif
			}
		}
		if (hood == 0)
		{	match--
			continue
		}
		w = 1/hood
		D[i,4] = match
		D[i,5] = 0
		D[i,6] = 1
		if (copy == 1)
		{	for (j = 1; j <= hood; j++)
			{	pos = neighbor[j,1]
				dif = neighbor[j,2]
				if (D[pos,4] == .)
				{	D[pos,4] = match
					D[pos,5] = dif
					D[pos,6] = w
				}
				else
				{	_ultimatchcopy(pos)
					_st_store(st_nobs(), 5, match)
					_st_store(st_nobs(), 6, dif)
					_st_store(st_nobs(), 7, w)
				}
			}
		}
		else if (copy == 2)
		{	D[i,6] = w
			for (j = 1; j <= hood; j++)
			{	pos = neighbor[j,1]
				dif = neighbor[j,2]
				if (j > 1)
				{	match++
					_ultimatchcopy(i)
					_st_store(st_nobs(), 5, match)
				}
				if (D[pos,4] == .)
				{	D[pos,4] = match
					D[pos,5] = dif
					D[pos,6] = w
				}
				else
				{	_ultimatchcopy(pos)
					_st_store(st_nobs(), 5, match)
					_st_store(st_nobs(), 6, dif)
					_st_store(st_nobs(), 7, w)
				}
			}
		}
		else
		{	for (j = 1; j <= hood; j++)
			{	pos = neighbor[j,1]
				dif = neighbor[j,2]
				if (dif < D[pos,5])
				{	D[pos,4] = match
					D[pos,5] = dif
				}
				if (D[pos,6] == .)
				{	D[pos,6] = w
				}
				else
				{	D[pos,6] = D[pos,6] + w
				}
			}
		}
	}
	st_numscalar("r(obs)", obs)	
	st_numscalar("r(match)", match)
	st_numscalar("r(comp)", comp)
	return
}

void _ultimatchdistance(real scalar varcnt, string scalar covmat, real scalar caliper, real scalar single, real scalar greedy, real scalar copy)
{	real matrix D, M, C, difvec, miss, neighbor
	real scalar hood, top, bot, dist, tradius, bradius, radius, nearest, pos, w, reset
	real scalar i, j, match, obs, uselimit, usecmd
	string scalar limit, cmd, explimit, expcmd, exp, str
	real scalar comp
	
	obs = st_nobs()
	for (i=1; i <= obs; i++)
	{	if (_st_data(i,1) != 0) // nouse
		{	break
		}
	}
	obs = i-1
	if (obs <= 0)
	{	st_numscalar("r(obs)", 0)	
		st_numscalar("r(match)", 0)
		return
	}
	st_view(D=.,(1,obs),(2..8)) // score:1, cell:2, treated:3, match:4, distance:5, weight:6, claim:7
	st_view(M=.,(1,obs),(9..9+varcnt-1)) // distance variables
	C = st_matrix(covmat)
	limit = st_local("limit")
	cmd = st_local("cmd")
	uselimit = 0
	usecmd = 0
	if (limit != "")
	{	limit = "local limitok = "+limit
		uselimit = 1
	}
	if (cmd != "")
	{	cmd = "local cmdok = "+cmd
		usecmd = 1
	}
	if (greedy)
	{	copy = 0
	}
	comp = 0
	miss = J(1,4,.)
	neighbor = J(obs,1,0)
	match = 0
	i = 0
	while (1)
	{	i++
		if (i > obs)
		{	break
		}
		if (D[i,3] == 0)
		{	continue
		}
		if (D[i,4] != .)
		{	match = D[i,4]
			if (D[i,6] != .)
			{	continue
			}
		}
		else
		{	match++
		}
		if (uselimit)
		{	explimit = subinstr(limit,"[t]","["+strofreal(i)+"]")
		}
		if (usecmd)
		{	expcmd = subinstr(cmd,"[t]","["+strofreal(i)+"]")
		}
		top = i
		bot = i
		radius = 0
		nearest = .
		hood = 0
		while (1)
		{	while (top != .)
			{	top--
				if (top < 1)
				{	top = .
					tradius = .
					break
				}
				if (D[i,2] != D[top,2])
				{	top = .
					tradius = .
					break
				}
				tradius = D[i,1]-D[top,1]
				if (D[top,3] == 1)
				{	break
				}
				comp++
				if (uselimit | usecmd)
				{	str = strofreal(top)
					if (uselimit)
					{	exp = subinstr(explimit,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("limitok") != "1")
						{	break
						}
					}
					if (usecmd)
					{	exp = subinstr(expcmd,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("cmdok") != "1")
						{	break
						}
					}
				}
				if (greedy & D[top,4] == match)
				{	dist = D[top,5]
					D[top,4..7] = miss
				}
				else
				{	difvec = M[i,.] :- M[top,.]
					difvec = difvec * C * difvec'
					dist = sqrt(difvec[1,1])
					if (greedy & dist >= D[top,5])
					{	break
					}
				}
				if (dist < nearest)
				{	hood = 1
					neighbor[hood,1] = top
					nearest = dist
				}
				else if (dist == nearest)
				{	hood++
					neighbor[hood,1] = top
				}
				break
			}
			while (bot != .)
			{	bot++
				if (bot > obs)
				{	bot = .
					bradius = .
					break
				} 			
				if (D[i,2] != D[bot,2])
				{	bot = .
					bradius = .
					break
				}
 				bradius = D[bot,1]-D[i,1]
				if (D[bot,3] == 1)
				{	break
				}
				comp++
				if (uselimit | usecmd)
				{	str = strofreal(bot)
					if (uselimit)
					{	exp = subinstr(explimit,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("limitok") != "1")
						{	break
						}
					}
					if (usecmd)
					{	exp = subinstr(expcmd,"[c]","["+str+"]")
						stata(exp,1,1)
						if (st_local("cmdok") != "1")
						{	break
						}
					}
				}
				if (greedy & D[bot,4] == match)
				{	dist = D[bot,5]
					D[bot,4..7] = miss
				}
				else
				{	difvec = M[i,.] :- M[bot,.]
					difvec = difvec * C * difvec'
					dist = sqrt(difvec[1,1])
					if (greedy & dist >= D[bot,5])
					{	break
					}
				}
				if (dist < nearest)
				{	hood = 1
					neighbor[hood,1] = bot
					nearest = dist
				}
				else if (dist == nearest)
				{	hood++
					neighbor[hood,1] = bot
				}
				break
			}
			radius = min((tradius,bradius))
			if ((top != . | bot != .) & nearest >= radius)
			{	continue
			}
			if (hood == 0 | nearest > caliper)
			{	D[i,4..7] = miss
				match--
				break
			}
			if (single)
			{	_jumble(neighbor[1..hood,1])
				hood = 1
			}
			w = 1/hood
			D[i,4] = match
			D[i,5] = 0
			D[i,6] = 1
			if (copy == 1)
			{	for (j = 1; j <= hood; j++)
				{	pos = neighbor[j,1]
					if (D[pos,4] == .)
					{	D[pos,4] = match
						D[pos,5] = nearest
						D[pos,6] = w
					}
					else
					{	_ultimatchcopy(pos)
						_st_store(st_nobs(), 5, match)
						_st_store(st_nobs(), 6, nearest)
						_st_store(st_nobs(), 7, w)
					}
				}
			}
			else if (copy == 2)
			{	D[i,6] = w
				for (j = 1; j <= hood; j++)
				{	pos = neighbor[j,1]
					if (j > 1)
					{	match++
						_ultimatchcopy(i)
						_st_store(st_nobs(), 5, match)
					}
					if (D[pos,4] == .)
					{	D[pos,4] = match
						D[pos,5] = nearest
						D[pos,6] = w
					}
					else
					{	_ultimatchcopy(pos)
						_st_store(st_nobs(), 5, match)
						_st_store(st_nobs(), 6, nearest)
						_st_store(st_nobs(), 7, w)
					}
				}
			}
			else if (greedy)
			{	reset = i
				for (j = 1; j <= hood; j++)
				{	pos = neighbor[j,1]
					claim = D[pos,7]
					if (claim != .)
					{	if (claim < reset)
						{	reset = claim
						}
						D[claim,6] = .
					}
					D[pos,4] = match
					D[pos,5] = nearest
					D[pos,6] = w
					D[pos,7] = i
				}
				if (reset < i)
				{	i = reset-1
				}
			}
			else
			{	for (j = 1; j <= hood; j++)
				{	pos = neighbor[j,1]
					if (nearest < D[pos,5])
					{	D[pos,4] = match
						D[pos,5] = nearest
					}
					if (D[pos,6] == .)
					{	D[pos,6] = w
					}
					else
					{	D[pos,6] = D[pos,6] + w
					}
				}
			}
			break
		}
	}
	st_numscalar("r(obs)", obs)	
	st_numscalar("r(match)", match)
	st_numscalar("r(comp)", comp)
	return
}

void _ultimatchcopy(real scalar from)
{	real scalar i, to
	st_addobs(1)
	to = st_nobs()
	for (i = 1; i <= st_nvar(); i++)
	{	if (st_isstrvar(i))
		{	_st_sstore(to, i, _st_sdata(from, i))
		}
		else
		{	_st_store(to, i, _st_data(from, i))
		}
	}
}

void _ultimatchdistanceaxis(real scalar obs, real scalar axispos,  real scalar varpos, string scalar covmat)
{	real matrix S, M, base, dif
	real scalar i, varcnt
	
	cov = st_matrix(covmat) 
	st_view(S=.,(1,obs),(axispos))
	st_view(M=.,(1,obs),(varpos..varpos+cols(cov)-1)) // distance variables
	base = colmin(M)
	base =  base :- 1
	for (i = 1; i <= obs; i++)
	{	dif = base :- M[i, .]
		dif = dif * cov * dif'
		S[i,1] = sqrt(dif[1,1])
	}
}

real matrix _ultimatchsingle(real matrix neighbor, real scalar between, real scalar draw)
{	real matrix top, bot
	real scalar i
	if (between)
	{	neighbor = sort((neighbor,runiform(rows(neighbor),1)),(3,2,4))
		top = select(neighbor,neighbor[.,3]:<1)
		if (rows(top) == 0 | rows(top) == rows(neighbor))
		{	return(neighbor[1..min((rows(neighbor),draw)),.])
		}
		bot = neighbor[(rows(top)+1)..rows(neighbor),.]
		top = top[1..min((rows(top),draw)),.]
		bot = bot[1..min((rows(bot),draw)),.]
		return(top\bot)
	}
	neighbor = sort((neighbor,runiform(rows(neighbor),1)),(2,4))
	return(neighbor[1..min((rows(neighbor),draw)),.])
}

end		
		