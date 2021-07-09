*! version 1.0
*! Chris Nelson 16/MAY/2008

program strsrcs_pred
	version 9.0
	syntax newvarname [if] [in], [Survival] [Hazard] [HRatio] [CI] [LEVel(string)]
	marksample touse, novarlist
	local newvarname `varlist'
	qui count if `touse'
	if r(N)==0 ///
	{
		error 2000          /* no observations */
	}

*************** CHECK THAT EITHER SURVIVAL OR HAZARD IS SPECIFIED

	if `"`survival'"'=="" & `"`hazard'"' =="" & `"`hratio'"' ==""  ///
	{
		display as error "You must specify either the survival, hazard or hratio option"
		exit 198
	}
	if (`"`survival'"'!="" & `"`hazard'"' !="") ///
	{
		display as error "Only one of the survival, hazard or hratio options can be specified"
		exit 198
	}
	if (`"`survival'"'!="" & `"`hratio'"' !="") ///
	{
		display as error "Only one of the survival, hazard or hratio options can be specified"
		exit 198
	}

	if (`"`hazard'"'!="" & `"`hratio'"' !="") ///
	{
		display as error "Only one of the survival, hazard or hratio options can be specified"
		exit 198
	}


*************** LEVEL FOR CONFIDENCE INTERVAL
	
	tokenize 'level'
	local level_n : word count `level'
	if `level_n' == 0 ///
	{
		local levelopt `"level(95)"'
	}
	else if `level_n' == 1 ///
	{
		local levelopt `"level(`level')"'
	}

*************** OBTIAN LINEAR PREDICTORS 

	local p: word count `e(rcs_xb)'
	forvalues i=1/`p' ///
	{
		local rcs "`rcs' xb(s`i')*_rcs`i'"
		if `i' != `p' local rcs "`rcs' + "
		local drcs "`drcs' xb(s`i')*_d_rcs`i'"
		if `i' != `p' local drcs "`drcs' + "
	}

*************** PREDICT SURVIVAL

	if "`e(scale)'" =="Hazard"  ///
	{
		if "`survival'" != "" ///
		{
			tempvar lnH lnHlci lnHuci 
			if `"`ci'"' != "" ///
			{
				local survci "ci(`lnHlci' `lnHuci')"
			}	
			qui predictnl double `lnH' = xb(xb) + `rcs' if `touse', `survci' `levelopt'
			* di "log(hazard) = xb(xb) + `rcs'"
			qui gen double `newvarname' = exp(-exp(`lnH')) if `touse'
			if `"`ci'"' != "" ///
			{
				qui gen double `newvarname'_lci = exp(-exp(`lnHlci')) if `touse'
				qui gen double `newvarname'_uci = exp(-exp(`lnHuci')) if `touse'
			}
		*************** REPORT NEW VARIABLE CREATION

			display in green "note: New variable `newvarname' has been created"
			if `"`ci'"' != "" ///
			{
				display in green "      lower bound in `newvarname'_lci"
				display in green "      upper bound in `newvarname'_uci"
			}
		}
	}
	else if "`e(scale)'" =="Odds" ///
	{
		if "`survival'" != "" ///
		{
			tempvar lnO lnOlci lnOuci 
			if `"`ci'"' != "" ///
			{
				local osurvci "ci(`lnOlci' `lnOuci')"
			}	
			qui predictnl double `lnO' = xb(xb) + `rcs' if `touse', `osurvci' `levelopt'
			qui gen double `newvarname' = 1/(1+exp(`lnO')) if `touse'
			if `"`ci'"' != "" ///
			{
				qui gen double `newvarname'_lci = 1/(1+exp(`lnOlci')) if `touse'
				qui gen double `newvarname'_uci = 1/(1+exp(`lnOuci')) if `touse'
			}
		*************** REPORT NEW VARIABLE CREATION

			display in green "note: New variable `newvarname' has been created"
			if `"`ci'"' != "" ///
			{
				display in green "      lower bound in `newvarname'_lci"
				display in green "      upper bound in `newvarname'_uci"
			}
		}
	}

*************** TEMPORARY TIMEVAR

	tempvar timevar
	quietly generate double `timevar'=_t

*************** PREDICT HAZARD

	if "`e(scale)'" =="Hazard" ///
	{
		if "`hazard'" != "" ///
		{
			tempvar  lh lhlci lhuci 
			if `"`ci'"' != "" ///
			{
				local hazci "ci(`lhlci' `lhuci')"
			}
			qui predictnl double `lh'=-ln(`timevar') + ln(`drcs') + (xb(xb) +`rcs') if `touse', `hazci' `levelopt'
			qui gen double `newvarname'=exp(`lh')
			if `"`ci'"' != "" ///
			{
				qui gen double `newvarname'_lci = exp(`lhlci') if `touse'
				qui gen double `newvarname'_uci = exp(`lhuci') if `touse'
			}
		*************** REPORT NEW VARIABLE CREATION

			display in green "note: New variable `newvarname' has been created"
			if `"`ci'"' != "" ///
			{
				display in green "      lower bound in `newvarname'_lci"
				display in green "      upper bound in `newvarname'_uci"
			}
		}
	}
	else if "`e(scale)'" =="Odds" ///
	{
		if "`hazard'" != "" ///
		{
			tempvar  lo lolci louci 
			if `"`ci'"' != "" ///
			{
				local ohazci "ci(`lolci' `louci')"
			}
			qui predictnl double `lo'=-ln(`timevar') + ln(`drcs') + (xb(xb) +`rcs') -ln(1+exp(xb(xb) +`rcs')) if `touse', `ohazci' `levelopt'

			qui gen double `newvarname'=exp(`lo') 
			if `"`ci'"' != "" ///
			{
				qui gen double `newvarname'_lci = exp(`lolci') if `touse'
				qui gen double `newvarname'_uci = exp(`louci') if `touse'
			}
		*************** REPORT NEW VARIABLE CREATION

			display in green "note: New variable `newvarname' has been created"
			if `"`ci'"' != "" ///
			{
				display in green "      lower bound in `newvarname'_lci"
				display in green "      upper bound in `newvarname'_uci"
			}
		}
	}


*************** PREDICT HAZARD RATIO 

	if "`e(scale)'" =="Hazard" ///
	{
	  if "`hratio'" != ""  ///
	  {
	     local nk : word count `e(strata)'
  	     local i=1 
	     tokenize "`e(strata)'"
	     while "``i''" != "" ///
	     {
		local k`i' ``i''
		local i=`i'+1
	     }

*************** CREATE REGRESSION VARIABLES

	   tempvar  t

	   forvalues i=1/`e(df)' ///
	   {
	      local rcs0 "`rcs0' [s`i'][_cons]*_rcs`i'"
	      forvalues j= 1/`nk' ///
	      {
		   tempvar lhr`j' lhr`j'_lci lhr`j'_uci
		   local rcs`j' "`rcs`j'' [s`i'][_cons]*_rcs`i' + [s`i'][``j'']*_rcs`i'"
		}
  	      if `i' != `e(df)' ///
		{
		   local rcs0 "`rcs0' + "
	         forvalues j= 1/`nk' ///
	         {
		      local rcs`j' "`rcs`j'' + "
		   }
		}
	      local drcs0 "`drcs0' [s`i'][_cons]*_d_rcs`i'"
	      forvalues j= 1/`nk' ///
	      {
	         local drcs`j' "`drcs`j'' [s`i'][_cons]*_d_rcs`i' + [s`i'][``j'']*_d_rcs`i'"
		}
		if `i' != `e(df)' ///
		{
		   local drcs0 "`drcs0' + "
	         forvalues j= 1/`nk' ///
		   {
			local drcs`j' "`drcs`j'' + "
		   }
		}
	   }
	   gen `t'=_t
         forvalues j= 1/`nk' ///
	   {  
	   qui predictnl double `lhr`j''= (-ln(`t') + ln(`drcs`j'') + ([xb][_cons]+ [xb][``j''] +`rcs`j'')) - ///
					    (-ln(`t') + ln(`drcs0') + ([xb][_cons] +`rcs0')) if `touse' , ci(`lhr`j'_lci' `lhr`j'_uci') `levelopt'
	   qui gen double `newvarname'`j'=exp(`lhr`j'')
	      if `"`ci'"' != "" ///
	      {
	         qui gen double `newvarname'`j'_lci=exp(`lhr`j'_lci')  if `touse'
	         qui gen double `newvarname'`j'_uci=exp(`lhr`j'_uci')  if `touse'
	      }
	      display in green "note: new variable `newvarname'`j' has been created"
	      if `"`ci'"' != "" ///
	      {
	         display in green "      lower bound in `newvarname'`j'_lci"
	         display in green "      upper bound in `newvarname'`j'_uci"
	      }
	   }
      }
	}
	else if "`e(scale)'" =="Odds" ///
	{
		if "`hratio'" != "" ///
		{
		display "NOT YET AVAILABLE !!"	
		}
	}


end
