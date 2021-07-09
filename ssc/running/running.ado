*! 3.1.1 PR/NJC 3 Dec 2008
*! 3.1.1 PR/NJC/PS 4 Dec 2008 
*! 3.1.0 NJC 1 Dec 2008 
*! 3.0.1 PR/NJC 11jan2007
*! 3.0.0 PR/NJC 01apr2005
*! 2.0.0 PS/PR 10Jun97.     STB-41 sed9.1
*!! Based on Peter Sasieni's "running4.ado" emailed 09Jun97
program running, sort rclass 
	version 8.0
	syntax varlist(numeric min=1 max=2) [if] [in] [aweight]   ///
	[, CI Double Knn(str) LOGit Mean Repeat(int 1) SPan(real 0) TWice ///
	GENB(str) GENerate(string) GENSE(str) REPLACE /// 
	CIOPts(str asis) LINEOPts(str asis) noGraph noVJitter SCatter(str asis) ///
	plot(str asis) addplot(str asis) nopts * ] 
	
	local nv = (2 - ("`mean'" != "")) * (8 + 16) + ///
	           9 + 12 * ("`weight'" != "") + 8 * (1 - ("`twice'" != ""))
	memchk byte `nv'
	if _rc == 900 error 900

	if "`replace'" == "" local cnv confirm new var
	else local cnv cap drop

	if "`generate'" != "" `cnv' `generate'
	if "`genb'" != "" { 
		if "`twice'`mean'`logit'" != "" {
			di as err "genb not available with mean, twice or logit"
			exit 198
		}
		`cnv' `genb' 
	}
	if "`gense'" != "" { 
		`cnv' `gense' 
		if `repeat' > 1 | "`double'`logit'`twice'" != "" {
			di as err ///
			"gense not available with repeat > 1, twice or logit"
			exit 198
		}
	}
	
	if "`ci'" != "" {
		if `repeat' > 1 | "`double'`logit'`twice'" != "" {
			di as err ///
			"ci not available with repeat > 1, twice or logit"
			exit 198
		}
	}
	
	if `span' != 0 & "`knn'" != "" {
		di as err "cannot specify both span and knn"
		exit 198
	}
	if `span' < 0 | `span' > 2 - ("`mean'" != "") {
		di as err "span must be between 0 and " 2 - ("`mean'" != "")
		exit 198
	}
	if "`knn'" == "" local knn 0 
	else {
		cap confirm var `knn'
		if _rc confirm integer num `knn'
		else unab kvec : `knn'
	}
	
	if "`double'" != "" local repeat = 2 * `repeat' 
	local nrep `repeat'
	if `repeat' > 7 {
		local repeat 7
		noi di as txt "[repeat set to 7]"
	}
	
	tokenize "`varlist'"
	args y x
	tempvar Y X smooth sy rsy kr kl
	
	quietly {
		marksample touse
		if "`weight'" != "" { 
			tempvar sw w wt
			gen  `w' `exp'
			replace `w' = . if `w' <= 0
			local exp "[`weight'=`w']"
		}
		
		count if `touse'
		local cnt = r(N)
		local IN "in 1/`cnt'"
		if `cnt' < 5 error 2001
		
		if `span' != 0 local knn = (`cnt' * `span' - 1)/2 
		else {
			if `knn' == 0 local knn = .5 * `cnt'^0.8 
			local span = (2 * `knn' + 1) / `cnt'
		}
		if "`kvec'" != "" { 
			su `kvec' if `touse', meanonly 
			if r(min) < 1 | r(N) != `cnt' {
				di as err /// 
				"knn variable must be positive and non-missing"
				exit 498 
			}
			local kk = int(`kvec' / sqrt(`repeat') +.5)
		}
		else {
			local kk = int(`knn' / sqrt(`repeat') +.5)
			if `kk' <= 0 {
				di as err "span too small: increase span or knn"
				exit 2002
			}
		}
		if `knn' <= 1 & "`ci'" != "" { 
			noi di as txt "[ci not produced when knn = 1]"
		}
		
		su `y' `exp' if `touse', meanonly 
		local ycen = r(mean)
		gen  `Y' = `y' - `ycen' if `touse'
		_crcslbl `Y' `y'
		if "`x'" != ""{
			gen  `X' = `x' if `touse'
			_crcslbl `X' `x'
		}
		else {
			gen `X' = _n if `touse'
			lab var `X' "observation"
		}
		
		sort `X'
		if "`weight'" != "" { 
			gen double `sw' = .
			replace `w' = . if !`touse'
			su `w', meanonly 
			noi di as txt "(sum of weight is " r(sum) ")"
			replace `w' = `w' / r(mean)
			gen `wt' = `w'
			local ks "(`sw'[_n+`kr']-cond(_n>`kl',`sw'[_n-`kl'],0))"
			local d3 "`sw'[_N]"
			local wX "`w'*"
			local wtX "`wt'*"
			local wn "`wt'`nk'*"
			local g_swby "by `X': replace `sw' = sum(`w') "   
			local g_wt   "by `X': replace `wt' = `sw'[_N]/_N  "
			local gen_swt "replace `sw' = sum(`wt') `IN'"
		}
		else {
			local ks "(`kr'+`kl')"
			local d3 "_N"
		}
		
		gen  `smooth' = `Y'
		lab var `smooth' "Smooth fit"
		gen double `sy' = sum(`X' == `X'[_n-1]) `IN'
		gen `rsy' = .
		local ties = `sy'[`cnt']
		local xcen = (`X'[1] + `X'[`cnt']) / 2
		replace `X' = `X' - `xcen' `IN'
		sort `X'

		gen int `kl' = min(`kk' + 1, _n)
		gen int `kr' = min(`kk', `cnt' - _n)
		
		if `ties' > 0 {
			tempvar Yt 
			`g_swby'	// sw must be defined before d3 is used */
			`g_wt'
			by `X': replace `sy' = sum(`wX'`Y') if `touse'  
			by `X': replace `smooth' = `sy'[_N] / `d3' if `touse' 
			if "`twice'" != "" gen `Yt' = `smooth'
			***** Use tied x-values for neighbours as far as possible ******
			by `X' : replace `kl'=max(1,min(2*`kk'+1,`kl' + int(_n-(_N+1)/2))) if `touse'
			by `X' : replace `kr'=max(0,min(2*`kk',`kr' - int(_n-(_N+1)/2))) if `touse'
			replace `kl' = min(`kl', _n) `IN'
			replace `kr' = min(`kr', `cnt' - _n) `IN'
			********
		}
		else local Yt "`Y'" 
		
		`gen_swt'
		
		if "`mean'" == "" {
			local mean "line"
			tempvar sxy rsxy beta rsx rsxx 
			gen `beta' = . 
			gen double `sxy' = sum(`wtX'`X') `IN'
			diff `rsx' `sxy' `kr' `kl' `ks' `cnt' gen
			replace `sxy' = sum(`wtX'((`X')^2)) `IN'
			diff `rsxx' `sxy' `kr' `kl' `ks' `cnt' gen
			gen  `rsxy' = .
		}
		
		forval r = `repeat'(-1)1 {
			replace `sy' = sum(`wtX'`smooth') `IN'
			diff `rsy' `sy' `kr' `kl' `ks' `cnt' replace
			
			if "`mean'" == "line" {
			     replace `sxy' = sum(`wtX'`X' * `smooth') `IN'
			     diff `rsxy' `sxy' `kr' `kl' `ks' `cnt' replace
			     replace `beta' = ///
			     (`rsxy' - `rsx' * `rsy') / (`rsxx' - (`rsx')^2) `IN'
			     replace `smooth' = ///
			     cond((`rsxx' - `rsx' * `rsx') > max(0, `rsxx' / 1e8), ///
			     `rsy' + `beta' * (`X' - `rsx'), `rsy') `IN'
			}
			else replace `smooth' = `rsy' `IN'
		}
		
		if "`twice'" != "" {
			tempvar res
			gen `res' = `Yt' - `smooth'
			local repeat `nrep'
			forval r = `repeat'(-1)1 {
				replace `sy' = sum(`wtX'`res') `IN'
				diff `rsy' `sy' `kr' `kl' `ks' `cnt' replace
				if "`mean'" == "line" {
					replace `sxy' = sum(`wtX'`X' * `res') `IN'
					diff `rsxy' `sxy' `kr' `kl' `ks' `cnt' replace
					replace `beta' = ///
					(`rsxy' - `rsx' * `rsy') / (`rsxx' - (`rsx')^2) `IN'
					replace `res' = ///
					cond((`rsxx' - `rsx' * `rsx') > max(0, `rsxx'/1e8), ///
					`rsy' + `beta' * (`X' - `rsx'), `rsy') `IN' 
				}
				else replace `res' = `rsy' `IN'
			}
		   	replace `smooth' = `smooth' + `res' `IN'
		}
		if `ties' > 0 {
			by `X': replace `sy' = sum(`smooth')  if `touse'
			by `X': replace `smooth' = `sy'[_N] / _N   if `touse'
		}
		if "`ci'" != "" | "`gense'" != "" {
			drop `sy' `rsy' 
			tempvar se sigma2
			gen double `se' = (`Y' - `smooth')^2
			if `ties' > 0 {
				`g_swby'
				by `X': replace `se' = sum(`wX'`se')  if `touse'
				by `X': replace `se' = `se'[_N] / `d3'  if `touse'
			}
			`gen_swt'
			replace `se' = sum(`wtX'`se') `IN'
			// Adjustment for estimating parameters made in se not sigma2
			diff `sigma2' `se' `kr' `kl' `ks' `cnt' gen
			if "`mean'" == "line" {
				replace `se' = sqrt(`sigma2' * ///
				cond((`rsxx' - `rsx' * `rsx') > max(0, `rsxx' / 1e8), ///
				((`kl' + `kr')/(`kl' + `kr' - 2)) * ///
				(1 + (`X' - `rsx')^2 / (`rsxx' - (`rsx')^2)) / `ks', ///
				1 / (`kl' + `kr' - 1)))  `IN'  
			}
			else replace `se' = sqrt(`sigma2' / (`kl' + `kr' - 1)) `IN'
			drop `sigma2' 
			if `ties' > 0 {
				`g_swby'
				by `X': replace `se' = sum(`se'^2) if `touse'
				by `X': replace `se' = sqrt(`se'[_N] / _N) if `touse'  
			}
		}
		replace `X' = `X' + `xcen'	 `IN'
		replace `Y' = `Y' + `ycen'	 `IN'
		replace `smooth' = `smooth' + `ycen' `IN'	
		if "`mean'" == "mean" & " `kvec'" == "" {
			local k2 = `cnt' + 1 - `kk'
			replace `smooth' = . in 1/`kk'
			replace `smooth' = . in `k2'/l
		}
		if "`logit'" != "" {
			su `y' if `touse', meanonly 
			if r(min) < -5e-9 | r(max) > 1 + 5e-9 {
				noi di as txt ///
				"[y variable out of range [0,1]: logit not available]"
			} 
			else {
				
				su `y' if `y' > 0 & `y' < 1 & `touse', meanonly
				local aL = min(1 / (min(`span', 1) * `cnt' + 1), r(min))
				local aU = max(1 - 1 / (min(`span', 1) * `cnt' + 1), r(max))
				replace `smooth' = ///
				cond(`smooth' < `aL', logit(`aL'), ///
				cond(`smooth' > `aU', logit(`aU'), ///
				logit(`smooth'))) if `smooth' < . `IN'
				local laL = logit(`aL')
				local laU = logit(`aU')
				local adj = (`laU' - `laL') / 25
				if "`vjitter'" != "" { 
					replace `Y' = ///
				cond(`y' < `aL', `laL' - 1.8 * `adj', ///
			 	cond(`y' > `aU', `laU' + 1.8 * `adj', ///
			 	logit(`y') )) `IN'
				}
				else 	replace `Y' = ///
				cond(`y' < `aL', `laL' - (1.3 + uniform()) * `adj', ///
			 	cond(`y' > `aU', `laU' + (1.3 + uniform()) * `adj', ///
			 	logit(`y') )) `IN'
			}
		}
		
		// GRAPH (If required)
		if "`graph'" != "nograph" {
			if "`ci'" != "" {
				local df = `kl' + `kr' - ("`mean'" == "line")
				local t = invttail(`df', ${S_level}/100)
				tempvar l u
				gen `l' = `smooth' - `t' * `se'
				gen `u' = `smooth' + `t' * `se'
				local cicall rarea `l' `u' `X', pstyle(ci) `ciopts' 
			}

			local ytitle `"ytitle("`: variable label `Y''")"' 
			local title "title(Running `mean' smoother)" 
			local ms = cond(`cnt' < 300, "ms(oh)", "ms(p)") 
			drop `kl' `kr' `touse'

			if "`pts'"!="nopts" {
				local addscatter "scatter `Y' `X' `exp', `ms' `scatter' ||" 
			}
			noi twoway `cicall' || ///
			`addscatter'  ///
			line `smooth' `X', ///
			`ytitle' `title' legend(off) `lineopts' `options' || ///
			`plot' || /// 
			`addplot'
		}
		
		if "`generate'`genk'`gense'" != "" drop `Y' `X'
		if "`generate'"   != "" rename `smooth' `generate'
		if "`gense'" != "" rename `se' `gense'
		if "`genb'"  != "" rename `beta' `genb'
	}
	
	return scalar knn = `knn'
	return scalar span = `span'

	// backwards compatibility 
	global S_1 `knn'
	global S_2 `span'
end

program diff 
	args new old kr kl ks cnt com 
	`com' `new'  = ///
	(`old'[_n + `kr'] - cond(_n > `kl', `old'[_n - `kl'], 0)) / `ks' in 1/`cnt'
end 

* 1.1.0 23 March 2005 
* 1.0  17 Jun 1997
program memchk
	version 8 
	quietly describe, detail short 
	local width = r(width) 
	local ws = r(widthmax)
	
	while "`1'" != "" { 
		if "`2'" == "" error 198
		confirm integer number `2' 
		if "`1'" == "int"     local width = `width' + 2 * `2'
		else if "`1'" == "byte" local width = `width' + `2'
		else if "`1'" == "long" | "`1'" == "float" {
			local width = `width' + 4 * `2'
		}
		else if "`1'" == "double" local width = `width' + 8 *`2'
		else if substr("`1'", 1, 3) == "str" { 
			local len = substr("`1'", 4, .)
			confirm integer number `len'
			local width = `width' + `len'* `2'
		}
		else error 198 
		mac shift 2
	}
	if `width' > `ws' { 
		di as err "insufficient memory" 
		exit 900
	}
end

