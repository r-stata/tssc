program define tcod, rclass sortpreserve byable(recall)
	version 9.2
	syntax varname (numeric) [if] [in]  [, 			///
		Level(cilevel)   	///
		Reps(int 50)   	///
		Stdr(numlist >=0)]					
	if "`level'"!=""{
		if `level' <= 0 | `level' >= 100 {
		di as err "level() must be between 0 and 100"
		exit 198
		}
	}
	marksample touse 
	qui count if `touse'
	local ntouse = r(N)
	if r(N) == 0 {
		di as error "There are no observations!"
		exit 2000
	}
	tempvar alpha
	qui {
		sum `varlist' if `touse', detail
		ret scalar Var=r(Var)
		ret scalar sd= r(sd) /* Std Deviation */
		ret scalar p50 = r(p50)
		ret scalar N = r(N)
		ret scalar df=return(N)-1
		ret scalar mean=r(mean)
		rcod `varlist' if `touse'
		ret scalar cod=r(cod)
	}
	scalar `alpha' = (1-`level'/100)/2
	ret scalar cisd_ub=sqrt(((return(df))*return(Var))/invchi2(return(df),`alpha'))
	ret scalar cisd_lb=sqrt(((return(df))*return(Var))/invchi2tail(return(df),`alpha'))
	ret scalar cicov_ub=100*return(cisd_ub)/return(mean)
	ret scalar cicov_lb=100*return(cisd_lb)/return(mean)
	ret scalar cicod_ub=return(cicov_ub)*0.80
	ret scalar cicod_lb=return(cicov_lb)*0.80
	di _newline(1)"{p}{error}Warning: {result}for a large # of bootstrap replications, " /*
	*/ "the process {break} might take a little bit longer...Please, wait{p_end}"
	di in text _newline(1)"{hline 37}{c TT}{hline 18}
	di "{input}{bf}  Coefficient of Dispersion (%){sf}{col 38}{c |}"/*
	*/as result %12.2f return(cod)
	di in text"{hline 37}{c +}{hline 18}
	di "{input}{bf}  Conf. Intervals for COD  {sf}{col 38}{c |}"
	di in text"{hline 37}{c +}{hline 18}
	di in text "   Parametric Method*  {col 38}{c |}"
	di in text "     `level'" "%  " "Lower Limit {col 38}{c |}"/*
	*/as result %12.3f return(cicod_lb)
	di in text "     `level'" "%  " "Upper Limit {col 38}{c |}"/*
	*/as result %12.3f return(cicod_ub)
	qui{	
		bootstrap r(cod), rep(`reps') bca: rcod `varlist'
		matrix bst=e(ci_bca)
		local bci_lb=bst[1,1]
		local bci_ub=bst[2,1]
	}
	di in text "   Bootstrap: BCa Conf. Interval**  {col 38}{c |}"
	di in text "     Replications {col 38}{c |}"/*
	*/as result %12.0f `reps'
	di in text "     `level'" "%  " "Lower Limit {col 38}{c |}"/*
	*/as result %12.3f `bci_lb'
	di in text "     `level'" "%  " "Upper Limit {col 38}{c |}"/*
	*/as result %12.3f `bci_ub'
	di in text"{hline 37}{c +}{hline 18}
	if `"`stdr'"'=="" {
		local stdr "15"
	}
	foreach num of numlist `stdr'{
		display "{input}{bf}  Testing Ho: COD <= `num' ""%{text}{sf}{col 38}{c |}""  
		di in text"{hline 37}{c +}{hline 18}
		ret scalar chi2cod = return(df)*return(cod)^2/`num'^2
		local ctail = invchi2tail(return(df), 1-`level'/100)
		ret scalar tf=sqrt(`ctail'/return(df))
		ret scalar maxcod= `num'* return(tf)
		local pu = chiprob(return(df), return(chi2cod)) 	/*Ho: COD<CODSTD*/
		local pl = 1 - chiprob(return(df), return(chi2cod)) 	/*Ho: COD>CODSTD*/
		local p=min(2*`pl', 2*`pu')		/*Ho: COD=CODSTD*/
		di in text "    Degree of freedom{col 38}{c |}"/*
		*/as result %12.0f return(df)
		di in text "    Chi-square value {col 38}{c |}"/*
		*/as result %12.2f return(chi2cod)
		di in text "    Critical value (at ""`level'" "%"") {col 38}{c |}"/*
		*/as result %12.2f `ctail'
		di in text "    P-value(1-tail){col 38}{c |}"/*
		*/as result %12.3f `pu'
		di in text "    Maximum acceptable COD (MAXCOD){col 38}{c |}"/*
		*/as result %12.2f return(maxcod)
		di "{text} {col 38}{c |}"
	}
	di in text"{hline 37}{c BT}{hline 18}
	di "*  Assumes normality"
	di "** Bias-Corrected and Accelerated"

end
program define rcod, rclass
	syntax varname (numeric min=1 max=1) [if] [in] 
	marksample touse 
	qui{
		sum `varlist' if `touse', detail
		local median = r(p50)
		local s = r(N)
	}	
		if `median'==0 {
			di as err /*
			*/ "The median equals zero. No COD"
			exit 198
		}
		else {
			tempvar absl
			qui{		
			gen `absl'=abs((`varlist'-`median'))
			sum `absl' if `touse'
			local tabsl=r(sum)
			local dev= (`tabsl'/`s')*100 
			return scalar cod= `dev'/`median'
			}
		}
end

exit



