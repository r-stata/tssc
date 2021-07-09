*! Attaullah Shah, attaullah.shah@imsciences.edu.pk
*! Support website: www.OpenDoors.Pk
*! March 1, 2017
version 13
prog astx
syntax varlist [if] [in], by(varlist)[using(string) Title(string) DECemial(real 3) Stat(string)]


	marksample touse
	
	if "`using'"==""{
		loc using "Summary Statistics by `by'.xlsx"
	}
	loc TST "tstat"
	loc Tstat : list TST in stat

	
	if `Tstat'==1{
		loc b "mean semean tstat"
		loc stat : list stat - b
		loc lastc : word count `stat'
		loc stat "`stat' mean semean"
	}
	if "`title'"==""{
		loc title "Summary Statistics by `by'"
	}
	qui levelsof `by', local(groups)
	local i = 1
	foreach g of local groups{
		qui tabstat `varlist' if `by'==`g', statistics(`stat') save
		if `i'==1{
			mat T= r(StatTotal)'
			mat rowname T = `g'
			local i = `i'+1
			local rown `g'
		}
		else {
			mat T = T \ r(StatTotal)'
			local rown = "`rown' `g'"
		}
	}
	qui mat rowname T = `rown'
	
	* If t-stats are specified
		if `Tstat'==1{
		loc C = colsof(T)
		loc R = rowsof(T)
		loc i = 1
		
		foreach g of local groups{
			if `i'==1{
				mat tstat  = J(1,1, T[`i',`=`lastc'+1']/T[`i',`=`lastc'+2'])
				loc i = `i'+1
			}
			else {
				mat tstat  =tstat \J(1,1, T[`i',`=`lastc'+1']/T[`i',`=`lastc'+2'])
				loc i = `i'+1
			}
		
		}

		mat  colname tstat = T-values
		mat T = T  , tstat
		

		}
	
	* Write to Excel
	if  c(version)<=13{
	qui putexcel 						  ///
	A1=("Summary Statistics by `by'")    ///
	A2=matrix( T , names) 				///
	A2 = ("`by'") 					   ///
	using "`using'", replace
	}
	else if c(version)>=14{
	putexcel set "`using'", replace
	putexcel A2 = matrix( T ), names 
	putexcel A2 = ("`by'") 
	putexcel A1:F1 = "Summary Statistics by `by'", merge hcenter bold border(bottom, double)
	
	
	}

	 matlist T,     					 ///
	 title("`title'") tindent(8) 		///
	 line(eq)            			   ///
	 border(top bottom) 			  ///
	 format(%9.5f)     				 ///
	 twidth(6) 
	 di as smcl `"Click to Open File:  {browse "`using'"}"'

end
