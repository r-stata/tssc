program define sratio, rclass sortpreserve byable(recall)
	version 9.2
	syntax varlist(min=2 max=2 numeric) [if] [in] [, 			///
		Level(cilevel)   	///
		ioc(numlist min=2 max=2 sort)   	///
		pioc(numlist >=0 <=100)   		///
		Sample					///
		ASsess 					///
		RELiable					///
		UNIform					///
		COC						///
		DISPerse					///
		BRief						///
		DETail ]					
	if "`brief'" == "" & "`detail'" == ""  & "`sample'" == "" & "`assess'" == "" & /*
		*/ "`reliable'" == "" & "`uniform'" == "" & "`coc'" == "" & "`disperse'" == ""{
		local detail detail
	}
	if "`brief'"!="" & ( "`detail'"!=""|"`sample'"!="" |"`assess'"!="" |"`uniform'"!=""/*
		*/ |"`reliable'"!=""|"`coc'"!=""|"`disperse'"!=""){
		di as err "may not specify brief with assess, uniform, reliable, coc, or detail""
		exit 198
	}
	if "`detail'"!="" & ( "`brief'"!="" |"`sample'"!=""| "`assess'"!="" |"`uniform'"!=""/*
		*/ |"`reliable'"!=""|"`coc'"!=""|"`disperse'"!=""){
		di as err "may not specify detail with assess, uniform, reliable, coc, or brief""		
		exit 198
	}
	if "`uniform'" != "" & (`"`disperse'"'!= "" | "`coc'"!= ""){
		di as err "may not specify both uniform and disperse/coc"
		exit 198
	}
	if "`level'"!=""{
		if `level' <= 0 | `level' >= 100 {
			di as err "level() must be between 0 and 100"
			exit 198
		}
	}
	*Compute Statistics
	*------------------
	marksample touse 
	qui count if `touse'
	local ntouse = r(N)
	if r(N) == 0 {
		di as error "There are no observations!"
		exit 2000
	}
	tokenize `ioc'
	local lioc "`1'"
	local uioc "`2'"
	if "`lioc'"=="" {
		local lioc "0.90"
	}
	if "`uioc'"=="" {
		local uioc "1.10"
	}
	tokenize `varlist'
	local v "`1'" 
	local p "`2'"
	if "`pioc'"=="" {
		local pioc "10"
	}
	tokenize `varlist'
	local v "`1'" 
	local p "`2'"
	if `v'<0 {
		di as err /*
		*/"`v' must be positive"
		exit 198
	}
	if `p'<0 {
		di as err /*
		*/"`p' must be positive"
		exit 198
	}
	tempvar srat dev wdev pcv p2 v2 pv  
	quietly {
		gen `srat'=`v'/`p'
		sum `srat' if `touse', detail
		ret scalar N= r(N)
		ret scalar mean= r(mean) /* Mean Ratio */
		ret scalar p50 = r(p50) /* Median Ratio */
		ret scalar min= r(min)
		ret scalar max= r(max)
		ret scalar range= r(max)-r(min) /* Range */
		ret scalar sd= r(sd) /* Std Deviation */
		ret scalar iqr=r(p75)-r(p25)
		ret scalar cov= (r(sd)/r(mean))*100  /* coefficient of variation */
		sum `v' if `touse'
		local tv=r(sum)
		local atv=`tv'/r(N)
		sum `p' if `touse'
		local tp=r(sum)
		local atp=`tp'/r(N)
		ret scalar wmean=`tv'/`tp' /* Weighted Mean */
		ret scalar prd=return(mean)/return(wmean)
		gen `dev'=abs(`srat'-return(p50))
		sum `dev' if `touse'
		local absl=r(sum)
		gen `wdev'=`p'/`atp'*`dev' if `touse'
		sum `wdev' if `touse'
		local wabsl=r(sum)
		ret scalar aad =(`absl'/return(N)) /* Average Absolute Deviation */
		ret scalar cod= 100*(return(aad)/return(p50)) /* coefficient of Dispersion */
		local waad= `wabsl'/return(N)
		ret scalar wcod=100*(`waad'/return(p50)) /* weighted coefficient of Dispersion */
		gen `pcv'=(`p'/`atp')*`dev'^2 if `touse'
		sum `pcv' if `touse'
		local wcv=r(sum)
		ret scalar wcov=sqrt(`wcv'/(return(N)-1))*(100/return(mean)) /* weighted coefficient of variation */
		ci `srat' if `touse', level(`level')
		ret scalar ub_mean= r(ub) /* Mean CI Upper bound	*/
		ret scalar lb_mean= r(lb) /* Mean Lower bound	*/
		centile  `srat' if `touse', centile(50) cci level(`level')
		ret scalar ub_med=r(ub_1)/* Median CI Upper bound	*/
		ret scalar lb_med=r(lb_1)/* Median CI Upper bound	*/
		ameans `srat' if `touse',  level(`level')
		ret scalar gmean=r(mean_g) /* Geometric Mean	*/
		ret scalar lb_gmean=r(lb_g) 
		ret scalar ub_gmean=r(ub_g)
		gen `p2' = `p'^2
		gen `v2' = `v'^2
		gen `pv'=`v' * `p'
		sum `p2' if `touse'
		local tp2=r(sum)
		sum `v2' if `touse'
		local tv2=r(sum)
		sum `pv' if `touse'
		local tpv=r(sum)
		tempname t alpha se
		scalar `se'=sqrt(`tv2'-(2*return(wmean)*`tpv')+((return(wmean)^2)*`tp2'))/((`tp'/return(N))* sqrt(return(N)* (return(N)-1)))
		scalar `alpha' = (1-`level'/100)/2
		scalar `t' = invttail(return(N)-1, `alpha') 
		ret scalar ub_wmean=return(wmean)+(`t'*`se')
		ret scalar lb_wmean=return(wmean)-(`t'*`se')
		count  if `srat'>=`lioc' & `srat'<=`uioc' & `touse'
		local q1=r(N)
		ret scalar icoc=(`q1'/return(N))*100
	}
	*Display Results
	*------------------
	local lv : var l `v'
	local lp : var l `p'
	di ""
	if "`lv'" != "" & "`lp'" != ""{
		display as result "{bf} Ratio Statistics for  " "`lv'""/""`lp'"
	}
	else {
		display as result "{bf} Ratio Statistics for  " "`v'""/""`p'"
	}	  
	di in text"{hline 37}{c TT}{hline 18}
	if `"`sample'"'!="" |"`detail'"!=""{
		display "{input}{bf} Sample Profile{text}{sf} {col 37} {c |}"
		di in text"{hline 37}{c +}{hline 18}	  
		di in text "  Sample Size 	{col 38}{c |}" /*
		*/as result %12.0f return(N)
		di in text "  Total Market Value {col 38}{c |}"/*
		*/as result %12.3gc `tp' 
		di in text "  Total Appraised Value	{col 38}{c |}"/*
		*/as result %12.3gc `tv'
		di in text "  Average Market Value	{col 38}{c |}"/*
		*/as result %12.3gc `atp'
		di in text "  Average Appraised Value	{col 38}{c |}"/*
		*/as result %12.3gc `atv'
		if "`assess'"!="" |"`uniform'"!="" |"`reliable'"!="" |"`coc'"!=""|"`disperse'"!=""{
			di in text"{hline 37}{c +}{hline 18}
		}
		else	{
			if "`sample'"=="" {
			di in text"{hline 37}{c +}{hline 18}
			}
			else {
			di in text"{hline 37}{c BT}{hline 18}
			}
		}
	}
	if "`assess'"!="" |"`brief'"!="" |"`detail'"!=""{
		display "{input}{bf} Measures of Appraisal Level{text}{sf} {col 37} {c |}"
		di in text"{hline 37}{c +}{hline 18}
		di in text "  Mean Ratio 	{col 38}{c |}" /*
		*/as result %12.3f return(mean)
		di in text "  Median Ratio 	{col 38}{c |}"/*
		*/as result %12.3f return(p50)
		di in text "  Weighted Mean Ratio 	{col 38}{c |}"/*
		*/as result %12.3f return(wmean)
		di in text "  Geometric Mean Ratio	{col 38}{c |}"/*
		*/as result %12.3f return(gmean)
		if "`uniform'"!="" |"`reliable'"!="" |"`coc'"!="" |"`disperse'"!=""{
			di in text"{hline 37}{c +}{hline 18}
		}
		else	{
			if "`assess'"==""{
			di in text"{hline 37}{c +}{hline 18}
			}
			else{
			di in text"{hline 37}{c BT}{hline 18}
			}
		}
	}
	if "`disperse'"!=""|"`brief'"!="" |"`detail'"!=""|"`uniform'"!=""{
		display  "{input}{bf} Measures of Dispersion {text}{sf} {col 38}{c |}"
		di in text"{hline 37}{c +}{hline 18}
		di in text "  Price-related differential {col 38}{c |}"/*
		*/as result %12.3f return(prd) 
		di in text "  Average Absolute Deviation {col 38}{c |}"/*
		*/as result %12.3f return(aad) 
		di in text "  Coefficient of dispersion(%){col 38}{c |}"/*
		*/as result %12.2f return(cod)
		di in text "  Coefficient of variation (%) {col 38}{c |}"/*
		*/as result %12.2f return(cov) 
		if "`reliable'"!="" |"`coc'"!=""{
			di in text"{hline 37}{c +}{hline 18}
		}
		else	{
			di in text"{hline 37}{c +}{hline 18}
		}
				
	}
	if "`detail'"!="" | "`disperse'"!=""{
		di in text "  Wtd coefficient of dispersion {col 38}{c |}"/*
		*/as result %12.2f return(wcod)
		di in text "  Wtd coefficient of variation {col 38}{c |}"/*
		*/as result %12.2f return(wcov)
		di in text "  Standard deviation {col 38}{c |}"/*
		*/as result %12.3f return(sd)
		di in text "  Minimum {col 38}{c |}"/*
		*/as result %12.3f return(min)
		di in text "  Maximum {col 38}{c |}"/*
		*/as result %12.3f return(max)
		di in text "  Range {col 38}{c |}"/*
		*/as result %12.3f return(range)
		di in text "  Interquartile Range {col 38}{c |}"/*
		*/as result %12.3f return(iqr)
		if "`disperse'"=="" | "`coc'"!=""{
			di in text"{hline 37}{c +}{hline 18}
		}
		else{
			di in text"{hline 37}{c BT}{hline 18}
		}
	}
	if `"`reliable'"'!="" |"`brief'"!="" | "`detail'"!=""{
		display "{input}{bf} Measures of Reliability{text}{sf} {col 38}{c |}"
		di in text"{hline 37}{c +}{hline 18}
		di in text "  Conf. Interval for Mean {col 38}{c |}"
		di in text "    `level'" "%  " "Lower Limit {col 38}{c |}"/*
		*/as result %12.3f return(lb_mean)
		di in text "    `level'" "%  " "Upper Limit {col 38}{c |}"/*
		*/as result %12.3f return(ub_mean)
		di in text "  Conf. Interval for Median {col 38}{c |}"
		di in text "    `level'" "%  " "Lower Limit {col 38}{c |}"/*
		*/as result %12.3f return(lb_med)
		di in text "    `level'" "%  " "Upper Limit {col 38}{c |}"/*
		*/as result %12.3f return(ub_med)
		di in text "  Conf. Interval for Wtd. Mean  {col 38}{c |}"
		di in text "    `level'" "%  " "Lower Limit {col 38}{c |}"/*
		*/as result %12.3f return(lb_wmean)
		di in text "    `level'" "%  " "Upper Limit {col 38}{c |}"/*
		*/as result %12.3f return(ub_wmean)
		di in text "  Conf. Interval for Geom. Mean {col 38}{c |}"
		di in text "    `level'" "%  " "Lower Limit {col 38}{c |}"/*
		*/as result %12.3f return(lb_gmean)
		di in text "    `level'" "%  " "Upper Limit {col 38}{c |}"/*
		*/as result %12.3f return(ub_gmean)
		if 	"`coc'"!=""|"`detail'"!="" {
			di in text"{hline 37}{c +}{hline 18}
		}
		else	{
			if "`reliable'"!="" | "`brief'"!=""{
			di in text"{hline 37}{c BT}{hline 18}
			}
		}	
	}
	if `"`coc'"'!="" |"`detail'"!="" |"`uniform'"!=""{
		display "{input}{bf} Measures of Concentration{text}{sf} {col 38}{c |}"
		di in text"{hline 37}{c +}{hline 18}
		di in text "  % within " "[`lioc', `uioc']"" {col 38}{c |}"/*
		*/as result %12.2f return(icoc)
		di in text"{hline 37}{c +}{hline 18}
		
		foreach num of numlist `pioc'{
			qui { 
				count  if `srat'>=(1-(`num'/100))*return(p50) & `srat'<=(1+(`num'/100))*return(p50)  & `touse'
				local q2=r(N)
				ret scalar pcoc`num'=(`q2'/return(N))*100
				
			}
			di in text "  % within ""`num'""% of median inclusive"" {col 38}{c |}"/*
			*/as result %12.2f return(pcoc`num')
		}
		di in text"{hline 37}{c BT}{hline 18}
	}
end


