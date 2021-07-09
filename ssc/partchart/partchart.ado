*** Baseline Characteristics Table: table1.ado ***

/*
program drop partchart
*/ 

program define partchart
   syntax varlist [if] [in], FILE(string) [SHEET(string) ///
          catcut(integer 9) constats(string) conprec(integer 2) consep(string asis) catsep(string asis) ///
		    by(varname) cattest(string) contest(string) nobase(varlist)] 
			
	version 10.0
			
	quietly set more off
   
	tempvar touse
	quietly gen `touse' = 0 
	quietly replace `touse' = 1 `if' `in'
	local byvar `by'
   *quietly capture ssc install unique
   *quietly capture ssc install mat2txt
   *quietly capture ssc install lstrfun
   *quietly capture ssc install tabcount
   *quietly capture ssc install dataout
   
   if "`constats'"=="" {
		local constats mean sd
   }
   
   if "`sheet'"=="" {
		local sheet partchartraw
   }
   
   preserve
   
      quietly misstable summarize `byvar'
	  if `r(max)'==. local missing
   
   *local twowaycount: word count `varlist'

   clear matrix

	quietly ds `varlist', has(type string)
	local strnum: word count of `r(varlist)'
	if `strnum'!=1 {
		display as error "String variables (`r(varlist)') not allowed"
		exit 101
	}

   
   if "`by'"=="" {
		quietly summ if `touse'
		local N=`r(N)'
		local catcutm1=`catcut'-1
		local categ
		local cont
		unab allvar: `varlist'
		foreach x of varlist `allvar' {
			quietly inspect `x' if `touse'
			if r(N_unique)<= `catcut' {
				local categ `categ' `x'
			}
			if r(N_unique) > `catcutm1' {
				local cont `cont' `x'
			}
		}
		
		if "`categ'" != "" {
		
			foreach var of varlist `categ' {
				quietly summ `var' if `touse'
				local min = r(min)
				if (`min' != 0 & `min' != 1) & "`if'"=="" {
					display as error "Categorical variables (`var') must start at 0 or 1. Use recode, replace, or generate new variable. This doesn't apply when using [if]"
					exit 121
				}
				local max = r(max)
				local rangep1 = r(max)-r(min)+1
				quietly tabcount `var' if `touse', v(`min'/`max') matrix(matrow)
				quietly svmat matrow, names(freq`var')
				quietly tab `var' if `touse'
				quietly gen pc`var'=100*(freq`var'1/r(N))
				quietly replace pc`var' = round(pc`var')
				quietly gen categorical = 1 in 1/`rangep1'
				mkmat freq`var'1 pc`var' categorical if categorical==1, matrix(`var')
				local rownames
				forvalues j = `min'/`max' {
					local rownames `rownames' `var'`j'
				}
				mat rownames `var' = `rownames'
				mat colnames `var' = FirstStat SecondStat categorical
				clear
				restore
				preserve
			}
		
		}
		
		if "`cont'" != "" {
		
			foreach var of varlist `cont' {
				quietly tabstat `var' if `touse', statistics(`constats') save
				mat `var'first = r(StatTotal)'
				mat categoricalmat = (0)
				mat `var' = `var'first,categoricalmat
				mat colnames `var' = FirstStat SecondStat categorical
				mat rownames `var' = `var'
				clear
				restore 
				preserve
			}
		
		}
		foreach var in `nobase' {
			quietly tab `var', matrow(a)
			local `var'd=a[1,1]
		}
		clear
		local matorder: subinstr local varlist " " "\", all
		quietly mat output = `matorder'
		quietly mat colnames output = FirstStat SecondStat categorical
		quietly mat2txt, matrix(output) saving(dummyout) replace
		quietly insheet using "dummyout.txt" , tab clear names case
		quietly tostring FirstStat SecondStat, replace format(%12.`conprec'f) force
		quietly replace FirstStat = reverse(substr(reverse(FirstStat),`conprec'+2,.)) if categorical==1
		quietly replace SecondStat = reverse(substr(reverse(SecondStat),`conprec'+2,.)) if categorical==1
		if `"`consep'"' != "" & regexm(substr(`"`consep'"',2,2),`"""') == 1  {
			quietly gen smush = FirstStat + `consep' + SecondStat if categorical==0
		}
		else if `"`consep'"' != "" & regexm(substr(`"`consep'"',2,2),`"""') != 1  {
			quietly gen smush = FirstStat + " " + substr(`"`consep'"',2,1) + SecondStat + substr(`"`consep'"',3,1) if categorical==0 
		}
		else {
			quietly gen smush = FirstStat + " (" + SecondStat + ")" if categorical==0
		}
		if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') == 1 & regexm(`"`catsep'"', "nopercent") != 1 {
			quietly replace smush = FirstStat + `catsep' + SecondStat + "%" if categorical==1
		}		
		else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') == 1 & regexm(`"`catsep'"', "nopercent") == 1 {
			quietly replace smush = FirstStat + substr(`"`catsep'"',2,1) + SecondStat if categorical==1
		}	
		else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') != 1 & regexm(`"`catsep'"', "nopercent") != 1 {
			quietly replace smush = FirstStat + " " + substr(`"`catsep'"',2,1) + SecondStat + "%" + substr(`"`catsep'"',3,1) if categorical==1			
		}
		else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') != 1 & regexm(`"`catsep'"', "nopercent") == 1 {
			quietly replace smush = FirstStat + " " + substr(`"`catsep'"',2,1) + SecondStat + substr(`"`catsep'"',3,1) if categorical==1			
		}
		else {
			quietly replace smush = FirstStat + " (" + SecondStat + "%)" if categorical==1
		}
		quietly keep v1 smush
		rename v1 variable
		rename smush total
		local op1=_N+1
		quietly set obs `op1'
		quietly replace variable="Sample Size" in `op1'
		quietly replace total="`N'" in `op1'
		foreach var in `nobase' {
			quietly drop if variable=="`var'``var'd'"
		}
		if regexm(`"`file'"',`"[.]"') == 0 {
			export excel using "`file'.xlsx", sheet("`sheet'") sheetreplace 
		}
		if regexm(`"`file'"',`"xls"') == 1 {
			export excel using "`file'", sheet("`sheet'") sheetreplace 
		}
		if regexm(`"`file'"',`"txt"') == 1 {
			outsheet using "`file'", replace noquote nonames
		}
		if regexm(`"`file'"',`"csv"') == 1 {
			outsheet using "`file'", comma replace nonames
		}
		if regexm(`"`file'"',`"tex"') == 1 {
			dataout, save("`file'") tex replace
		}	
		quietly capture erase "dummyout.txt"

   }
   
   if "`by'"!="" {
   		local catcutm1=`catcut'-1
		local categ
		local cont
		unab allvar: `varlist'
		foreach x of varlist `allvar' {
			quietly inspect `x' if `touse'
			if r(N_unique)<= `catcut' {
				local categ `categ' `x'
			}
			if r(N_unique) > `catcutm1' {
				local cont `cont' `x'
			}
		}
		
		if "`categ'" != "" {
		
			foreach var of varlist `categ' {
				quietly summ `var' if `touse'
				local min = r(min)
				if (`min' != 0 & `min' != 1) & "`if'"=="" {
					display as error "Categorical variables (`var') must start at 0 or 1. Use recode, replace, or generate new variable. This doesn't apply when using [if]"
					exit 121
				}
				local max = r(max)
				local rangep1 = r(max)-r(min)+1
				quietly tabcount `var' if `touse', v(`min'/`max') matrix(matrow)
				quietly svmat matrow, names(freq`var')
				quietly tab `var' if `touse'
				quietly gen pc`var'=100*(freq`var'1/r(N))
				quietly replace pc`var' = round(pc`var')
				quietly gen categorical = 1 in 1/`rangep1'
				mkmat freq`var'1 pc`var' categorical if categorical==1, matrix(`var')
				local rownames
				forvalues j = `min'/`max' {
					local rownames `rownames' `var'`j'
				}
				mat rownames `var' = `rownames'
				mat colnames `var' = FirstStat SecondStat categorical
				clear
				restore
				preserve
			}
		
		}
		
		if "`cont'" != "" {
		
			foreach var of varlist `cont' {
				quietly tabstat `var' if `touse', statistics(`constats') save
				mat `var'first = r(StatTotal)'
				mat categoricalmat = (0)
				mat `var' = `var'first,categoricalmat
				mat colnames `var' = FirstStat SecondStat categorical
				mat rownames `var' = `var'
				clear
				restore 
				preserve
			}
		
		}

		clear
		local matorder: subinstr local varlist " " "\", all
		mat output = `matorder'
		mat colnames output = FirstStat SecondStat categorical
		quietly mat2txt, matrix(output) saving(dummyout) replace
		quietly insheet using "dummyout.txt" , tab clear names case
		quietly tostring FirstStat SecondStat, replace format(%12.`conprec'f) force
		quietly replace FirstStat = reverse(substr(reverse(FirstStat),`conprec'+2,.)) if categorical==1
		quietly replace SecondStat = reverse(substr(reverse(SecondStat),`conprec'+2,.)) if categorical==1
		if `"`consep'"' != "" & regexm(substr(`"`consep'"',2,2),`"""') == 1  {
			quietly gen smush = FirstStat + `consep' + SecondStat if categorical==0
		}
		else if `"`consep'"' != "" & regexm(substr(`"`consep'"',2,2),`"""') != 1  {
			quietly gen smush = FirstStat + " " + substr(`"`consep'"',2,1) + SecondStat + substr(`"`consep'"',3,1) if categorical==0 
		}
		else {
			quietly gen smush = FirstStat + " (" + SecondStat + ")" if categorical==0
		}
		if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') == 1 & regexm(`"`catsep'"', "nopercent") != 1 {
			quietly replace smush = FirstStat + `catsep' + SecondStat + "%" if categorical==1
		}		
		else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') == 1 & regexm(`"`catsep'"', "nopercent") == 1 {
			quietly replace smush = FirstStat + substr(`"`catsep'"',2,1) + SecondStat if categorical==1
		}	
		else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') != 1 & regexm(`"`catsep'"', "nopercent") != 1 {
			quietly replace smush = FirstStat + " " + substr(`"`catsep'"',2,1) + SecondStat + "%" + substr(`"`catsep'"',3,1) if categorical==1			
		}
		else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') != 1 & regexm(`"`catsep'"', "nopercent") == 1 {
			quietly replace smush = FirstStat + " " + substr(`"`catsep'"',2,1) + SecondStat + substr(`"`catsep'"',3,1) if categorical==1			
		}
		else {
			quietly replace smush = FirstStat + " (" + SecondStat + "%)" if categorical==1
		}
		quietly keep smush
		quietly rename smush total
		quietly save totaldatadummy, replace
		quietly capture erase "dummyout.txt"
		
		restore
		preserve
		
		*local byvar `: word `twowaycount' of `varlist''
		quietly tab `byvar' if `touse', matrow(tabvals)
		clear
		quietly svmat tabvals, names(col)
		if c1[1] != 0 & c1[1] != 1 {
			display as error "The '""by""' variable (`byvar') values must be sequential integers starting at 0 or 1 (i.e... 0,1,2,3 or 1,2,3,4). Use recode, replace, or generate new variable."
			exit 121
		}
		local nm = _N-1
		forvalues i = 1/`nm' {
			local j=`i'+1
			if c1[`i']+1 != c1[`j'] {
				display as error "The '""by""' variable (`byvar') values must be sequential integers starting at 0 or 1 (i.e... 0,1,2,3 or 1,2,3,4). Use recode, replace, or generate new variable."
				exit 121
			}
		}
		restore
		preserve
		
		
		quietly levelsof `byvar' if `touse', local(bylevs)
		local firstbylev : word 1 of `bylevs'
		local tempbylevs = "`bylevs'"
		quietly inspect `byvar' if `touse'
		if r(N_0) > 0 { 
			local bylevs
			 foreach num of numlist `tempbylevs' {
				local newnum=`num'+1
				local bylevs `bylevs' `newnum'
			 }
		}
		
		local bywordcount: word count `bylevs'
	
		local lastbylev `: word `bywordcount' of `bylevs''
				
		local varlist: subinstr local varlist "`byvar'" ""
		
		local catcutm1=`catcut'-1
		local categ
		local cont
		unab allvar: `varlist'
		foreach x of varlist `allvar' {
			quietly inspect `x' if `touse'
			if r(N_unique)<= `catcut' {
				local categ `categ' `x'
			}
			if r(N_unique) > `catcutm1' {
				local cont `cont' `x'
			}
		}
	
		if "`categ'" != "" {
		
			foreach var of varlist `categ' {

				quietly levelsof(`var') if `touse', local(`var'levs)
				local wordcount: word count ``var'levs'
				local lastlev `: word `wordcount' of ``var'levs''
			
				local templastlev = "``var'levs'"
				quietly inspect `var' if `touse'
				if r(N_0) > 0 { 
				local temp2lastlev
				 foreach num of numlist `templastlev' {
					local newnum=`num'+1
					local temp2lastlev `temp2lastlev' `newnum'
				 }
				 local lastlevwordcount: word count `temp2lastlev'
				 local lastlev `: word `lastlevwordcount' of `temp2lastlev''
				}
				
				
				if "`cattest'" == "exact" {
					quietly summ `var' if `touse'
					local min1 = r(min)
					local max1 = r(max)
					quietly summ `byvar' if `touse'
					local min2 = r(min)
					local max2 = r(max)
					quietly tabcount `var' `byvar' if `touse', v1(`min1'/`max1') v2(`min2'/`max2') matrix(`var'freqmat)
					quietly tab `var' `byvar' if `touse', exact
					local catpval = r(p_exact) 
				} 
				else {
					quietly summ `var' if `touse'
					local min1 = r(min)
					local max1 = r(max)
					quietly summ `byvar' if `touse'
					local min2 = r(min)
					local max2 = r(max)
					quietly tabcount `var' `byvar' if `touse', v1(`min1'/`max1') v2(`min2'/`max2') matrix(`var'freqmat)
					quietly tab `var' `byvar' if `touse', chi2
					local catpval = r(p)
				}
								
				mat pmat = J(`lastlev', 1, 0)
				forvalues i = 1/`lastlev' {
					mat pmat[`i',1] = `catpval'
				}
				
				mat catmat = J(`lastlev',1,1)
				
				local tempmatsmush
				
				foreach blev of numlist `bylevs' {
					mat `var'submat`blev' = `var'freqmat[1..`lastlev',`blev']
					mat `var'pcmat`blev' = (100/(trace(diag(`var'submat`blev'))))*`var'submat`blev'
					mat `var'submat`blev'pcmat`blev' = `var'submat`blev' , `var'pcmat`blev'
					
					local tempmatsmush `tempmatsmush' `var'submat`blev'pcmat`blev'
					
					clear
					restore
					preserve
					
				}
				
				local matsmush : subinstr local tempmatsmush " " "," , all
				mat `var' = `matsmush',pmat,catmat
				
				local colnames
				forvalues i = 1/`lastbylev' {
					local colnames `colnames' FirstStat`i' SecondStat`i'
				}
				
				mat colnames `var' = `colnames' pvalue categorical
				
				local rownames
				
				forvalues j = `min1'/`max1' {
					local rownames `rownames' `var'`j'
				}
				
				mat rownames `var' = `rownames'
				
			}
		
		}
		
		if "`cont'" != "" {
		
			foreach var of varlist `cont' {

				local tempconmat
				local firststat: word 1 of `constats'
				local twostat: word 2 of `constats'
				
				if "`firststat'"=="mean" | "`firststat'"=="me" {
					local firststat1 r(mean)
				}
				if "`twostat'"=="mean" | "`twostat'"=="me" {
					local twostat1 r(mean)
				}
				
				if "`firststat'"=="count" | "`firststat'"=="co" | "`firststat'"=="n" {
					local firststat1 r(N)
				}
				if "`twostat'"=="count" | "`twostat'"=="co" | "`twostat'"=="n" {
					local twostat1 r(N)
				}
				
				if "`firststat'"=="sum" | "`firststat'"=="su" {
					local firststat1 r(sum)
				}
				if "`twostat'"=="sum" | "`twostat'"=="su" {
					local twostat1 r(sum)
				}
				
				if "`firststat'"=="max" | "`firststat'"=="ma" {
					local firststat1 r(max)
				}
				if "`twostat'"=="max" | "`twostat'"=="ma" {
					local twostat1 r(max)
				}
				
				if "`firststat'"=="min" | "`firststat'"=="mi" {
					local firststat1 r(min)
				}
				if "`twostat'"=="min" | "`twostat'"=="mi" {
					local twostat1 r(min)
				}
				
				if "`firststat'"=="range" | "`firststat'"=="r" {
					local firststat1 r(max)-r(min)
				}
				if "`twostat'"=="range" | "`twostat'"=="r" {
					local twostat1 r(max)-r(min)
				}
				
				if "`firststat'"=="sd" {
					local firststat1 r(sd)
				}
				if "`twostat'"=="sd" {
					local twostat1 r(sd)
				}
				
				if "`firststat'"=="variance" | "`firststat'"=="v" {
					local firststat1 r(Var)
				}
				if "`twostat'"=="variance" | "`twostat'"=="v" {
					local twostat1 r(Var)
				}
				
				if "`firststat'"=="cv" {
					local firststat1 r(sd)/r(mean)
				}
				if "`twostat'"=="cv" {
					local twostat1 r(sd)/r(mean)
				}
				
				if "`firststat'"=="semean" | "`firststat'"=="sem" {
					local firststat1 r(sd)/sqrt(r(N))
				}
				if "`twostat'"=="semean" | "`twostat'"=="sem" {
					local twostat1 r(sd)/sqrt(r(N))
				}
				
				if "`firststat'"=="skewness" | "`firststat'"=="sk" {
					local firststat1 r(skewness)
				}
				if "`twostat'"=="skewness" | "`twostat'"=="sk" {
					local twostat1 r(skewness)
				}
				
				if "`firststat'"=="kurtosis" | "`firststat'"=="k" {
					local firststat1 r(kurtosis)
				}
				if "`twostat'"=="kurtosis" | "`twostat'"=="k" {
					local twostat1 r(kurtosis)
				}
				
				if "`firststat'"=="p1" {
					local firststat1 r(p1)
				}
				if "`twostat'"=="p1" {
					local twostat1 r(p1)
				}
				
				if "`firststat'"=="p5" {
					local firststat1 r(p5)
				}
				if "`twostat'"=="p5" {
					local twostat1 r(p5)
				}
				
				if "`firststat'"=="p10" {
					local firststat1 r(p10)
				}
				if "`twostat'"=="p10" {
					local twostat1 r(p10)
				}
				
				if "`firststat'"=="p25" {
					local firststat1 r(p25)
				}
				if "`twostat'"=="p25" {
					local twostat1 r(p25)
				}
				
				if "`firststat'"=="p50" | "`firststat'"=="median" | "`firststat'"=="med" {
					local firststat1 r(p50)
				}
				if "`twostat'"=="p50" | "`twostat'"=="median" | "`twostat'"=="med" {
					local twostat1 r(p50)
				}
				
				if "`firststat'"=="p75" {
					local firststat1 r(p75)
				}
				if "`twostat'"=="p75" {
					local twostat1 r(p75)
				}
				
				if "`firststat'"=="p90" {
					local firststat1 r(p90)
				}
				if "`twostat'"=="p90" {
					local twostat1 r(p90)
				}
				if "`firststat'"=="p95" {
					local firststat1 r(p95)
				}
				if "`twostat'"=="p95" {
					local twostat1 r(p95)
				}
				if "`firststat'"=="p99" {
					local firststat1 r(p99)
				}
				if "`twostat'"=="p99" {
					local twostat1 r(p99)
				}
				
				if "`firststat'"=="iqr" {
					local firststat1 r(p75)-r(p25)
				}
				if "`twostat'"=="iqr" {
					local twostat1 r(p75)-r(p25)
				}
				
				
				foreach num of numlist `tempbylevs' {
					quietly summ `var' if `byvar' == `num' & `touse', detail
					
					mat `var'first`num' = J(1,2,0)
					mat `var'first`num'[1,1] = `firststat1'
					mat `var'first`num'[1,2] = `twostat1'
					
					local tempconmat `tempconmat' `var'first`num'
				}
				
				local `var'first : subinstr local tempconmat " " "," , all
				mat `var'first = ``var'first'
				
				
				if "`contest'"=="kwallis" {
					quietly kwallis `var' if `touse', by(`byvar')
					local conpval = chi2tail(r(df),r(chi2_adj))
				}
				else {
					quietly anova `var' `byvar' if `touse'
					local conpval = Ftail(e(df_m), e(df_r),e(F))
				}
				
				mat pmat = (`conpval')
				mat categoricalmat = (0)
				mat `var' = `var'first,pmat,categoricalmat
				local colnames
				forvalues i = 1/`lastbylev' {
					local colnames `colnames' FirstStat`i' SecondStat`i'
				}
				mat colnames `var' = `colnames' pvalue categorical
				mat rownames `var' = `var'
				clear
				restore 
				preserve
			}
			
		}
		
	   foreach var in `nobase' {
			quietly tab `var', matrow(a)
			local `var'd=a[1,1]
		}
		
		*********************************************
		quietly levelsof `byvar' if `touse', local(bylevs)
		local firstbylev : word 1 of `bylevs'
		local tempbylevs = "`bylevs'"
		quietly inspect `byvar' if `touse'
		if r(N_0) > 0 { 
			local bylevs
			 foreach num of numlist `tempbylevs' {
				local newnum=`num'+1
				local bylevs `bylevs' `newnum'
			 }
		}
		
		local bywordcount: word count `bylevs'
	
		local lastbylev `: word `bywordcount' of `bylevs''
		
				quietly tab `byvar' `byvar' if `touse', matcell(a)
				local lp1=`lastbylev'+2
				mat ss = J(1,`lp1',0)
				quietly summ if `touse'
				local N=r(N)
				mat ss[1,2]=`N'
				forvalues i=3/`lp1' {
					local j=`i'-2
					mat ss[1,`i']=a[`j',`j']
				}
			  		local colnames
			  		forvalues i = 1/`lastbylev' {
						if "`firstbylev'"=="1" local j=`i'
						if "`firstbylev'"=="0" local j=`i'-1
						local colnames `colnames' `byvar'`j'
					}
					mat colnames ss = variable total `colnames'

				clear
				quietly svmat ss, names(col)
				quietly tostring *, replace
				quietly save "sampsizexxx", replace
       ************************************************


		
		clear
		local firstmatorder: subinstr local varlist " " "\", all
		local lfirstmatorder: length local firstmatorder
		local uselength = `lfirstmatorder'
		quietly lstrfun matorder, substr("`firstmatorder'",1,`uselength')
		mat output = `matorder'
		local colnames
		forvalues i = 1/`lastbylev' {
			local colnames `colnames' FirstStat`i' SecondStat`i'
		}
		mat colnames output = `colnames' pvalue categorical
		quietly mat2txt, matrix(output) saving(dummyout) replace
		quietly insheet using "dummyout.txt" , tab clear names case		
		forvalues i = 1/`lastbylev' { 
		    quietly replace SecondStat`i' = round(SecondStat`i') if categorical==1
			quietly tostring FirstStat`i' SecondStat`i', replace format(%12.`conprec'f) force
			quietly tostring pvalue, replace format(%9.3f) force
			quietly replace pvalue = "<0.001" if pvalue == "0.000"
		    quietly replace FirstStat`i' = reverse(substr(reverse(FirstStat`i'),`conprec'+2,.)) if categorical==1
		    quietly replace SecondStat`i' = reverse(substr(reverse(SecondStat`i'),`conprec'+2,.)) if categorical==1
			if `"`consep'"' != "" & regexm(substr(`"`consep'"',2,2),`"""') == 1  {
				quietly gen smush`i' = FirstStat`i' + `consep' + SecondStat`i' if categorical==0
			}
			else if `"`consep'"' != "" & regexm(substr(`"`consep'"',2,2),`"""') != 1  {
				quietly gen smush`i' = FirstStat`i' + " " + substr(`"`consep'"',2,1) + SecondStat`i' + substr(`"`consep'"',3,1) if categorical==0 
			}
			else {
				quietly gen smush`i' = FirstStat`i' + " (" + SecondStat`i' + ")" if categorical==0
			}
			if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') == 1 & regexm(`"`catsep'"', "nopercent") != 1 {
				quietly replace smush`i' = FirstStat`i' + `catsep' + SecondStat`i' + "%" if categorical==1
			}		
			else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') == 1 & regexm(`"`catsep'"', "nopercent") == 1 {
				quietly replace smush`i' = FirstStat`i' + substr(`"`catsep'"',2,1) + SecondStat`i' if categorical==1
			}	
			else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') != 1 & regexm(`"`catsep'"', "nopercent") != 1 {
				quietly replace smush`i' = FirstStat`i' + " " + substr(`"`catsep'"',2,1) + SecondStat`i' + "%" + substr(`"`catsep'"',3,1) if categorical==1			
			}
			else if `"`catsep'"' != "" & regexm(substr(`"`catsep'"',2,2),`"""') != 1 & regexm(`"`catsep'"', "nopercent") == 1 {
				quietly replace smush`i' = FirstStat`i' + " " + substr(`"`catsep'"',2,1) + SecondStat`i' + substr(`"`catsep'"',3,1) if categorical==1			
			}
			else {
				quietly replace smush`i' = FirstStat`i' + " (" + SecondStat`i' + "%)" if categorical==1
			}
			quietly drop FirstStat`i' SecondStat`i'
        }
		quietly drop categorical
		quietly order v1 smush1-smush`lastbylev' pvalue
		quietly rename v1 variable		
		forvalues num = 1/`lastbylev' {
			local minusone = `num' - 1
			if `firstbylev' == 0 {
				quietly rename smush`num' `byvar'`minusone'
			}
			if `firstbylev' != 0 {
				quietly rename smush`num' `byvar'`num'
	        }	
		}
		quietly keep variable-pvalue
		
		quietly merge 1:1 _n using totaldatadummy, nogen
		quietly order variable total
		quietly drop if missing(variable)
		quietly append using "sampsizexxx.dta"		
		local N=_N
		quietly replace variable="Sample Size" in `N'

		foreach var in `nobase' {
			quietly drop if variable=="`var'``var'd'"
		}
		
		
		if regexm(`"`file'"',`"[.]"') == 0 {
			export excel using "`file'.xlsx", sheet("`sheet'") sheetreplace firstrow(variables)
		}
		if regexm(`"`file'"',`"xls"') == 1 {
			export excel using "`file'", sheet("`sheet'") sheetreplace firstrow(variables)
		}
		if regexm(`"`file'"',`"txt"') == 1 {
			outsheet using "`file'", replace noquote
		}
		if regexm(`"`file'"',`"csv"') == 1 {
			outsheet using "`file'", comma replace
		}	
		if regexm(`"`file'"',`"tex"') == 1 {
			dataout, save("`file'") tex replace
		}	
		quietly capture erase "dummyout.txt"		
		quietly capture erase "totaldatadummy.dta"		
		quietly capture erase "sampsizexxx.dta"		
   }
   
   				if "`firststat'"=="" {
					local firststat mean
				}
   				if "`twostat'"=="" {
					local twostat sd
				}

   list, noobs sep(1000) table
   
   display "*The table contains `firststat's and `twostat's for continuous variables (`cont') and counts and percentages for categorical variables (`categ')."
   
   *macro list _all
   *mat list ss
restore
   
end   

