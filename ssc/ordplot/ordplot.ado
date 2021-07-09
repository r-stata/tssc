program def ordplot
*! 1.2.1 NJC 23 Oct 2000 
* 1.2.0 NJC 23 Oct 2000 
* 1.1.1 NJC 18 Oct 2000 
* 1.0.0 NJC 12 Oct 2000 
	version 6.0 
	syntax varname(numeric) [if] [in] [fweight] [ , SCale(str) /* 
	*/ POWer(real 0) by(varname) sep(str) Connect(str) Keys(str) /* 
	*/ L1title(str asis) L2title(str asis) ASSCores(numlist asc) /* 
	*/ le lt ge gt PRob Fraction MISSing REVerse  /* 
	*/ PLAbel(numlist >=0 <=100) PLIne(numlist >=0 <=100) /* 
	*/ PTIck(numlist >=0 <=100) Gap(int 4) YLAbel YLAbel(numlist) /* 
	*/ YTIck YTick(numlist) YLIne YLIne(numlist) * ] 
	
	local ineq = trim("`le' `lt' `ge' `gt'") 
	local nineq : word count `ineq' 
	if `nineq' > 1 { 
		di in r "must choose between `ineq' options" 
		exit 198 
	}

	if "`reverse'" != "" & "`le'`lt'" != "" { 
		di in r "`le'`lt' option not allowed with reverse option" 
		exit 198 
	} 
	else if "`reverse'" == "" & "`ge'`gt'" != "" { 
		di in r "`ge'`gt' option requires reverse option"
		exit 198 
	} 	

	if "`scale'" == "percent" & "`fraction'" != "" { 
		di in r /* 
		*/ "must choose between scale(percent) and fraction options" 
		exit 198 
	} 
	
	if "`scale'" == "percent" { local desc "percent" } 
	else if "`fraction'" != "" { local desc "fraction" } 
	else local desc "probability" 

	if "`scale'" != "" {  
		local OK 0 
		if "`scale'" == "logit" { local OK 1 } 
		else if "`scale'" == "flog" { local OK 1 } 
		else if "`scale'" == "froot" { local OK 1 } 
		else if "`scale'" == "folded" { 
			if `power' == 0 { 
				di in r "need power( ) with folded scale" 
				exit 198 
			} 
			local OK 1 
		} 
		else if "`scale'" == "loglog" { local OK 1 } 
		else if "`scale'" == "cloglog" { local OK 1 } 
		else if "`scale'" == "normal" { local OK 1 } 
		else if "`scale'" == "gaussian" { 
			local scale "Gaussian" 
			local OK 1 
		}
		else if "`scale'" == "Gaussian" { local OK 1 } 
		else if "`scale'" == "percent" { local OK 1 } 
		else if "`scale'" == "raw" { local OK 1 } 
		if !`OK' { 
			di in r "invalid scale( ) option" 
			exit 198 
		}
	} 
	else local scale "raw" 

	if "`plabel'" != "" {
		if "`ylabel'" != "" { 
			di in r /* 
			*/ "must choose between plabel and ylabel options" 
			exit 198 
		} 	
		if "`scale'" == "raw" | "`scale'" == "percent" { 
			di in r /* 
			*/ "use ylabel( ) not plabel( ) with scale(`scale')" 
			exit 198 
		} 
		local npla : word count `plabel' 
		local pmax : word `npla' of `plabel' 
		if `pmax' > 1 { local desc "percent" } 
	} 	

	if "`pline'" != "" { 
		if "`yline'" != "" { 
			di in r /* 
			*/ "must choose between pline and yline options" 
			exit 198 
		} 	
		if "`scale'" == "raw" | "`scale'" == "percent" { 
			di in r /* 
			*/ "use yline( ) not pline( ) with scale(`scale')" 
			exit 198 
		} 
		local npli : word count `pline' 
		local pmax : word `npli' of `pline' 
		if `pmax' > 1 { local desc "percent" } 
	} 
	
	if "`ptick'" != "" { 
		if "`ytick'" != "" { 
			di in r /* 
			*/ "must choose between ptick and ytick options" 
			exit 198 
		} 	
		if "`scale'" == "raw" | "`scale'" == "percent" { 
			di in r /* 
			*/ "use ytick( ) not ptick( ) with scale(`scale')" 
			exit 198 
		} 
		local npti : word count `ptick' 
		local pmax : word `npti' of `ptick' 
		if `pmax' > 1 { local desc "percent" } 
	} 	
	
	local y "`varlist'" 
	
	if "`by'" == "" {
		local onevar 1 
		tempvar x  
		gen byte `x' = 1 
	} 	
	else { 
		local onevar 0 
		capture confirm numeric variable `by' 
		if _rc { 
			tempvar x 
			encode `by', gen(`x') 
		} 	
		else local x "`by'" 
	} 	
	
	marksample touse
	if "`missing'" == "" & !`onevar' { 
		markout `touse' `x' 
	} 

	if !`onevar' { 
		qui tab `x' if `touse', `missing'  
		if `r(r)' > 10 { 
			di in r "`x' has too many categories to plot" 
			exit 198 
		} 
	} 

	if "`asscores'" != "" {		
		local nsc : word count `asscores'
		tempname yval ylbl  
		qui tab `y' if `touse', matrow(`yval')  
		local nvals = `r(r)' 
		if `nsc' != `nvals' { 
			di in r /* 
		*/ "`nsc' values in asscores( ), `nvals' values of `y'"
			exit 198 
		}
	} 

	preserve 

	if "`asscores'" != "" { 
		tempvar scores 
		qui gen `scores' = .
		local vallbl : value label `y' 
		local i = 1 
		qui while `i' <= `nvals' { 
			local as : word `i' of `asscores' 
			local val = `yval'[`i',1]
			replace `scores' = `as' if `y' == `val' 
			if "`vallbl'" != "" { 
				local val : label `vallbl' `val' 
			} 
			capture label def `ylbl' `as' "`val'", modify  
			local i = `i' + 1 
		}
		capture label val `scores' `ylbl' 
		_crcslbl `scores' `y' 
		local y "`scores'" 
	} 	

	contract `x' `y' if `touse' [`weight' `exp'], zero 
	
	tempvar total pr show  
	qui by `x' : gen `total' = sum(_freq) 
	qui by `x' : replace `total' = `total'[_N] 
	gen `pr' = _freq / `total' 
	
	qui if "`prob'" == "" { 
		if "`le'`gt'" != "" { /* <= or > */ 
			by `x' : gen `show' = sum(`pr') 
		} 
		else if "`lt'`ge'" != "" { /* < or >= */ 
			by `x' : gen `show' = sum(`pr'[_n-1]) 
		} 	
		else by `x' : gen `show' = 0.5 * `pr' + sum(`pr'[_n-1]) 
		if "`reverse'" != "" { replace `show' = 1 - `show' } 
		local cumul "cumulative " 
	} 
	else local show "`pr'" 
	
	if "`scale'" == "logit" | "`scale'" == "flog" { 
		qui replace `show' = log(`show' / (1 - `show')) 
	} 
	else if "`scale'" == "froot" { 
		qui replace `show' = sqrt(`show') - sqrt(1 - `show') 
	} 
	else if "`scale'" == "folded" { 
		qui replace `show' = `show'^`power' - (1 - `show')^`power' 
		local Power " ^`power'" 
	} 	
	else if "`scale'" == "loglog" { 
		qui replace `show' = -log(-log(`show')) 
	}
	else if "`scale'" == "cloglog" { 
		qui replace `show' = log(-log(1 - `show')) 
	}	
	else if "`scale'" == "normal" | "`scale'" == "Gaussian" { 
		qui replace `show' = invnorm(`show') 
	}
	else if "`scale'" == "percent" {
		qui replace `show' = 100 * `show' 
	} 	
	
	if "`sep'" == "" { local sep "\" }

	if "`plabel'`pline'`ptick'" != "" { 
		qui replace `show' = 1000 * `show' 
	} 	
				
	if `onevar' {  
		local vallist " " 
	} 
	else {
		tempname xval
		local vallbl : value label `x' 
		qui tab `x', matrow(`xval') `missing'  
		local nvals = r(r)
		local Sep "`sep'" 
		local i = 1 
		while `i' <= `nvals' { 
			local val = `xval'[`i',1] 
			if "`vallbl'" != "" { 
				local val : label `vallbl' `val' 
			} 
			if `i' == `nvals' { local Sep } 
			local vallist "`vallist' `val'`Sep'" 
			local i = `i' + 1 
		} 
		qui separate `show', by(`x') g(_ord) `missing' 
		local show "`r(varlist)'" 
	}	

	if "`plabel'" != "" { 
		tempname tplabel 
		tokenize `plabel'
		while "`1'" != "" {
			local one `1' 
			t_to_p `1' tpla `desc' `scale' `power'
			if `tpla' < . { 
				label def `tplabel' `tpla' "`one'", modify
				local tla "`tla' `tpla'" 
			} 	
			mac shift
		}
		local show1 : word 1 of `show' 
		label val `show1' `tplabel'
		local yla "yla(`tla')" 
	} 	
        else if "`ylabel'" == "" | "`ylabel'" == "ylabel" { 
		local yla "yla" 
	}
	else if "`ylabel'" != "" { 
		local yla "yla(`ylabel')"  
	} 	
	
	if "`pline'" != "" { 
		tokenize `pline'
		while "`1'" != "" {
			t_to_p `1' tpli `desc' `scale' `power' 
			if `tpli' < . { 
				local tli "`tli' `tpli'" 
			} 	
			mac shift
		}
		local yli "yli(`tli')" 
	} 
	else if "`yline'" == "yline" { 
		local yli "yli" 
	}
	else if "`yline'" != "" { 
		local yli "yli(`yline')"  
	} 	

	if "`ptick'" != "" { 
		tokenize `ptick'
		while "`1'" != "" {
			t_to_p `1' tpti `desc' `scale' `power' 
			if `tpti' < . { 
				local tti "`tti' `tpti'" 
			} 	
			mac shift
		}
		local yti "yti(`tti')" 
	} 	
	else if "`ytick'"  == "ytick" { 
		local yti "yti" 
	}
	else if "`ytick'" != "" { 
		local yti "yti(`ytick')"  
	} 	

	if "`connect'" == "" { 
		local ny : word count `show' 
		local connect : di _dup(`ny') "L" 
	} 
	if `"`l1title'"' == "" {
		if "`scale'" != "raw" & "`scale'" != "percent" { 
			local Scale ", `scale' scale `Power'" 
		} 
		local l1title "`cumul'`desc'`Scale'" 
	} 
	if `"`l2title'"' == "" {
		if "`prob'" == "" {
			if "`le'" != "" { 
				local l2title "(<= `y')"
			} 
			else if "`lt'" != "" { 
				local l2title "(< `y')" 
			}	
			else if "`ge'" != "" { 
				local l2title "(>= `y')" 
			} 
			else if "`gt'" != "" { 
				local l2title "(> `y')"
			} 	
			else local l2title "(to mid-class)" 
		} 
		else local l2title `"" ""'  
	} 	
	if "`keys'" == "" { 
		local keys "`vallist'" 
	} 
	
	keyplot `show' `y', l1(`l1title') l2(`l2title') gap(`gap')  /* 
 	*/ c(`connect') keys(`keys') sep(`sep') `options' `yla' `yli' `yti' 
end 	

program def t_to_p
* converts transformed value t to result given desc scale [power] 
	version 6.0 
	args t p desc scale power 
	
	if "`desc'" == "percent" { local t = `t' / 100 } 
	
	if "`scale'" == "logit" | "`scale'" == "flog" { 
		local P = round(1000 * log(`t' / (1 - `t')),1) 
	}
	else if "`scale'" == "froot" { 
		local P = round(1000 * (sqrt(`t') - sqrt(1 - `t')),1) 
	} 			
	else if "`scale'" == "folded" { 
		local P = round(1000 * (`t'^`power' - (1 - `t')^`power'),1) 
	} 	
	else if "`scale'" == "loglog" { 
		local P = round(1000 * -log(-log(`t')),1)  
	}
	else if "`scale'" == "cloglog" { 
		local P = round(1000 * log(-log(1 - `t')),1) 
	}
	else if "`scale'" == "normal" | "`scale'" == "Gaussian" { 
		local P = round(1000 * invnorm(`t'),1) 
	} 	
	
	c_local `p' = `P' 
end 
