*! xtsum2docx.ado ver.1.7.1 Futoshi Narita 2019/01/18
*! Allow statistics to list in an order specified as:
*!     order(stat1 stat2 ...), e.g., order(mean sd obs),
*! and add two statistics from xtsum, specified as options as follows:
*!     xtn for r(n), xttbar for r(Tbar), xtsdb for r(sd_b), xtmaxw for r(max_w), 
*!     and so on. 
*! 
*! Based on sum2docx.ado - with my huge thanks to the authors!
*! The original authors of sum2docx.ado:
*!     Chuntao LI
*!     China Stata Club(爬虫俱乐部)
*!     Wuhan, China
*!     chtl@zuel.edu.cn
*! 
*!     Yuan XUE
*!     China Stata Club(爬虫俱乐部)
*!     Wuhan, China
*!     xueyuan19920310@163.com
program define xtsum2docx

	version 15.0 //使用putdocx，只能在Stata15中使用
	
	syntax varlist(numeric) [if] [in] using/, [append replace title(string) obs OBSfmt(string) ///
	mean MEANfmt(string) var VARfmt(string) sd SDfmt(string) skewness ///
	SKEWNESSfmt(string) kurtosis KURTOSISfmt(string) sum SUMfmt(string) min ///
	MINfmt(string) max MAXfmt(string) p1 P1fmt(string) p5 P5fmt(string) p10 ///
	P10fmt(string) p25 P25fmt(string) median MEDIANfmt(string) p50 P50fmt(string) p75 P75fmt(string) ///
	p90 P90fmt(string) p95 P95fmt(string) p99 P99fmt(string) ///
	xtn XTNfmt(string) xttbar XTTBARfmt(string) ///
	xtmaxw XTMAXWfmt(string) xtminw XTMINWfmt(string) ///
	xtmaxb XTMAXBfmt(string) xtminb XTMINBfmt(string) ///
	xtsdw XTSDWfmt(string) xtsdb XTSDBfmt(string) ///
	order(string)]
	
	// statistics available via summarize (already available for sum2docx), 
	// except for N, median, and Var (which are separately treated):
	local statlist mean sd skewness kurtosis sum max min p1 p5 p10 p25 p50 p75 p90 p95 p99
	// statistics available via xtsum (added for xtsum2docx):
	local xtstatlist n Tbar max_w min_w max_b min_b sd_w sd_b

	if "`append'" != "" & "`replace'" != "" { //append和replace不能同时定义
		disp as error "You cannot specify both append and replace."
		exit 198
	}
	
	tempname post_sum
	tempfile postsum
	
	local varlen = 0
	foreach v of varlist `varlist' {
		if length(`"`v'"') > `varlen' local varlen = length(`"`v'"')
	}
	
	local num = 0
	
	if "`obs'" != "" | "`obsfmt'" != "" {
		local postvar "`postvar'obs " //如果输出样本量，添加Obs
		local postcontent `"`postcontent'(r(N)) "'
		local num = `num' + 1
		if "`obsfmt'" == "" local obsfmt %9.0f //Default
	}
	
	if "`var'" != "" | "`varfmt'" != "" { //输出方差
		local postvar = "`postvar'var "
		local postcontent `"`postcontent'(r(Var)) "'
		local num = `num' + 1
		if "`varfmt'" == "" local varfmt %9.1f //Default
	}

	if "`median'" != "" | "`medianfmt'" != "" {
		local postvar = "`postvar'median "
		local postcontent `"`postcontent'(r(p50)) "'
		local num = `num' + 1
		if "`medianfmt'" == "" local medianfmt %9.1f //Default 
	}
	
	// Loop for the same procedure.
	foreach stat of local statlist {
		if "``stat''" != "" | "``stat'fmt'" != "" {
			local postvar = "`postvar'`stat' "
			local postcontent `"`postcontent'(r(`stat')) "'
			local num = `num' + 1
			if "``stat'fmt'" == "" local `stat'fmt %9.1f //Default 
		}
	}
	
	// Only valid after xtset (or tsset) 
	local flg_panel = 0
	foreach xtstat of local xtstatlist {
		local xtstat2: subinstr local xtstat "_" "", all
		local xtstat2 = strlower("`xtstat2'")
		if "`xt`xtstat2''" != "" | "`xt`xtstat2'fmt'" != "" {
			local postvar "`postvar'xt`xtstat2' " 
			local postcontent `"`postcontent'(xt_r_`xtstat') "'
			local num = `num' + 1
			if "`xt`xtstat2'fmt'" == "" {
				local xt`xtstat2'fmt %9.1f //Default 
				// Default for xtnfmt is %9.0f
				if "`xtstat2'" == "n" local xt`xtstat2'fmt %9.0f 
			}
			local flg_panel = 1
		}
	}
	
	// If no statistics is specified, throw an error
	if length(trim(`"`postvar'"')) == 0 { 
		di as err "At least one statstics must be specified (e.g., mean) in the option."
		exit 198
	}
	
	// Re-order statistics based on `order'; if not fully specified, 
	// put listed ones first and the rest is in the order just as above.
	// Create a local variable "original_order" that contains "1 2 3 ... `num'"
	local original_order 
	forvalues j=1/`num' {
		local original_order "`original_order'`j' "
	}
	local rest_order `original_order'
	
	// Tokenize "postvar" and "postcontent"
	tokenize `postvar'
	forvalues j=1/`num' {
		local v`j' ``j''
	}
	tokenize `postcontent'
	forvalues j=1/`num' {
		local c`j' ``j''
	}
		
	// Create a local variable "re_order" that contains the specified order
	tokenize `postvar'
	local re_order 
	local cnt_order: word count `order'
	forvalues i=1/`cnt_order' {
		local y: word `i' of `order'
		forvalues j=1/`num' { 
			if "`y'" == "`v`j''" {
				local re_order "`re_order'`j' "
				local rest_order: subinstr local rest_order "`j'" "", word
			}
		}
	}
	if "`rest_order'" != "" {
		local re_order "`re_order'`rest_order' "
	}

	// Re-order postvar based on `re_order'
	local re_postvar 
	local re_postcontent 
	tokenize `re_order'
	forvalues j=1/`num' {
		local re_postvar "`re_postvar'`v``j''' "
		local re_postcontent `"`re_postcontent'`c``j''' "'
	}	
	local postvar `re_postvar'
	local postcontent `re_postcontent'
		
	// Add variable name at the beginning.
	local postvar "str`varlen' VarName `postvar'"
	local num = `num' + 1	
	
	qui {
		postfile `post_sum' `postvar' using `postsum.dta', replace
		
		foreach var of varlist `varlist' {
			local postcontent_v "`postcontent'"
			if `flg_panel' == 1 {
				xtsum `var' `if' `in'
				foreach xtstat of local xtstatlist {
					local xt_r_`xtstat' = r(`xtstat')
					local postcontent_v: subinstr local postcontent_v "(xt_r_`xtstat')" "(`xt_r_`xtstat'')", word
				}
			}
			sum `var' `if' `in', d
			post `post_sum' ("`var'") `postcontent_v' 
		}
		
		postclose `post_sum'
		
		preserve
		use `postsum.dta', clear
		local row = _N + 1
		// Loop for formating
		foreach stat in obs var median `statlist' {
			if "``stat''" != "" | "``stat'fmt'" != "" format ``stat'fmt' `stat'
		}		
		foreach xtstat of local xtstatlist {
			local xtstat2: subinstr local xtstat "_" "", all
			local xtstat2 = strlower("`xtstat2'")
			if "`xt`xtstat2''" != "" | "`xt`xtstat2'fmt'" != "" format `xt`xtstat2'fmt' xt`xtstat2'
		}

		compress
		capture putdocx clear
		putdocx begin
		if `"`title'"' != "" {
			putdocx paragraph, spacing(after, 0)
			putdocx text (`"`title'"')
		}
		putdocx table sumtable = data("_all"), varnames border(all, nil) border(bottom) border(top)
		putdocx table sumtable(1,1), border(bottom)
		forvalues i = 2/`num' {
			putdocx table sumtable(1,`i'), border(bottom)
			forvalues j = 1/`row' {
				putdocx table sumtable(`j',`i'), halign(right)
			}
		}
		if "`replace'" == "" & "`append'" == "" { //如果既没有replace也没有append，直接save
			putdocx save `using'
		}
		else {
			putdocx save `using', `replace'`append'
		}
		restore
	}

end
