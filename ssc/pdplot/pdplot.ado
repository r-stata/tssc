*! NJC 1.0.0 16 Nov 2006 
* Pareto dot plot 
* Wilkinson, Leland. 2006. Revising the Pareto chart. 
* American Statistician 60(4): 332-334. 
program pdplot, sort 
	version 9 
	syntax varname [if] [in] [fweight/] ///
	[, DOTSonly nreps(int 10000) Horizontal AIopts(str asis) ///
	Level(int `c(level)') * ] 

	quietly { 
		marksample touse, strok 
		count if `touse' 
		if r(N) == 0 error 2000 

		tempvar freq tag rank order 
		tempname ranklbl low high 

		if "`exp'" == "" local exp = 1 

		// frequencies 
		bysort `touse' `varlist' : gen `freq' = sum(`exp') 
		by `touse' `varlist' : replace `freq' = `freq'[_N] 

		// categories 
		bysort `touse' `freq' `varlist' : /// 
			gen byte `tag' = _n == 1 & `touse' 
		count if `tag'  
		local ncats = r(N) 

		su `freq' if `tag', meanonly 
		local nvals = r(sum) 
		
		// ranks 
		gen `rank' = `ncats' - sum(`tag') + 1 
		local label : var label `varlist' 
		if `"`label'"' == "" local label "`varlist'"
		label var `rank' `"`label'"' 

		// label ranks 
		gen long `order' = _n 
		capture confirm string var `varlist' 
		local isnum = _rc 

		forval i = 1/`ncats' {
			su `order' if `rank' == `i', meanonly 
			local value = `varlist'[r(min)] 
			if `isnum' local value : label (`varlist') `value' 
			label def `ranklbl' `i' `"`value'"', modify  
		}

		if "`dotsonly'" == "" { 
			// 95% acceptance intervals 
			mata: ///
		work(`nreps',`ncats',`nvals',`level',"`c(seed)'","`low'","`high'") 

			tempvar lo hi 
			gen `lo' = . 
			gen `hi' = . 
			char `lo'[varname]   "Lower" 
			char `hi'[varname]   "Upper" 

			forval i = 1/`ncats' { 
				local j = `ncats' - `i' + 1 
				replace `hi' = `high'[`j',1] if `rank' == `i' 
				replace `lo' = `low'[`j',1] if `rank' == `i' 
			}
		}	

		sort `touse' `tag' `rank' 

		// percent scale too 
		local pcmax = 100 * `freq'[_N - `ncats' + 1] / `nvals' 
		local step = cond(`pcmax' < 25, 5, 10) 
		local pcmax = `step' * ceil(`pcmax'/`step') 

		forval v = 0(`step')`pcmax' { 
			local val = `v' * `nvals'/100 
			local percents `"`percents' `val' "`v'""' 
		} 
	}	

	// list 
	char `freq'[varname] "Freq." 
	char `rank'[varname] "Rank" 
	list `varlist' `rank' `freq' `lo' `hi' if `tag', ///
		subvarname noobs sep(0) 

	if "`dotsonly'" == "" { 
		di as res "  (`level'% acceptance intervals from `nreps' random samples)" 
	}

	// graph
	label val `rank' `ranklbl'

	if "`dotsonly'" == "" { 
		#delimit ; 
		local bars  rbar `lo' `hi' `rank' if `tag',              
    		`horizontal' 
    		bcolor(none) 
    		barw(0.2) 
                note(`level'% acceptance intervals)
		`aiopts'            
		|| ; 
		#delimit cr 
	} 

	if "`horizontal'" != "" { 
		#delimit ; 
		twoway `bars' 
		scatter `rank' `freq' if `tag',                  
		xla(, ang(h)) 
		xaxis(1 2) 
		xla(`percents', ang(h) axis(1))           
		xtitle(Percent, axis(1))                             
		xtitle(Frequency, axis(2)) 
		yaxis(1 2)             
		yla(1/`ncats', ang(h) axis(1))                      
		yla(1/`ncats', ang(h) valuelabel noticks axis(2))   
		ytitle(Rank, axis(1)) ysc(reverse) 
		legend(off)       
		`options' ; 
		#delimit cr 
	}
	else {
		#delimit ; 
		twoway `bars' 
		scatter `freq' `rank' if `tag',                          
		yaxis(1 2) 
		yla(`percents', ang(h) axis(1))                   
		yla(, ang(h) axis(2)) 
		ytitle(Percent, axis(1))                                     
		ytitle(Frequency, axis(2)) 
		xaxis(1 2)                     
		xla(1/`ncats', valuelabel noticks axis(2))                  
		xla(1/`ncats', axis(1))                                     
		xtitle(Rank, axis(1)) ms(Oh)                                 
		legend(off)                          
		`options' ;
		#delimit cr 
	}	
end 

mata: 

void work(real scalar nreps, 
          real scalar ncats, 
	  real scalar nvals, 
	  real scalar level, 
	  string scalar seed,  
	  string scalar lowname, 
	  string scalar highname) 
{	  
	real colvector sample, low, high, counts 
	real matrix allcounts 
	real scalar i, j, nlow, nhigh 
	
	counts = J(ncats, 1, 0) 
	allcounts = J(nreps, ncats, .) 
	low = high = J(ncats, 1, 0) 
	uniformseed(seed) 

	for(i = 1; i <= nreps; i++) { 
		sample = ceil(ncats * uniform(nvals, 1)) 
		for(j = 1; j <= ncats; j++) { 
			counts[j,1] = sum(sample :== j) 
		} 
		counts = sort(counts, 1) 
		allcounts[i,] = counts' 
	} 	

	// explanation below  
	level = (100 - level) / 200  
	nlow = floor(0.5 + nreps * level) 
	nhigh = ceil(0.5 + nreps * (1 - level)) 

	for(j = 1; j <= ncats; j++) { 
		allcounts = sort(allcounts, j) 		
		low[j,1] = allcounts[nlow, j]
		high[j,1] = allcounts[nhigh, j]
	}

	st_matrix(lowname, low) 
	st_matrix(highname, high) 
}

end

/* 

Given level as a percent: say 95 for example. 

We work with alpha / 2 = (100 - level) / 200: in this example 0.025. 

We seek integer solutions i to 
	alpha / 2     = (i - 0.5) / n 
	1 - alpha / 2 = (i - 0.5) / n 
which will be integers close to 
	0.5 + n * alpha / 2       
	0.5 + n * (1 - alpha / 2)   
Arbitrarily, we round down the lower value using floor() and round up
the upper value using ceil(). 

*/ 

