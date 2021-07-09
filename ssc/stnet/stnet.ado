*! version 1.0.8 11Jun2020. 
* Command computing net survival according to Pohar Perme and coll. method
* Brenner standardisation and individual weights included
* Confidence intervals on log scale
* Unique option

program define stnet
	version 11
	st_is 2 analysis
	syntax [if] [in] using/ [iw/], Mergeby(namelist) DIAGdate(varname numeric) BIRTHdate(varname numeric) ///
                  [ BReaks(string) UNIQUE BY(varlist) ATTAGE(name) ATTYEAR(name) SURVprob(name) MAXAGE(int 99) EDerer2 CILOG STANDstrata(varname numeric) ///
				    LIst(namelist) LISTYEARLY AT(numlist ascending >0) Format(string) noTABles noSHow SAVING(string asis) SAVSTand(string asis) ///
					BRENNER INDWEight(varname numeric) Level(integer $S_level) ENDwei ]

/* Relevant sample */
	marksample touse
	markout `touse' `diagdate' `birthdate' `by' `standstrata', strok

	if "`_dta[st_id]'" !="" {
		cap bysort `_dta[st_id]' : assert _N==1
		if _rc {
			di as err /*
			*/ _n "stnet requires that the data are stset with only one observation per individual"
			exit 198
		}   
	}

	cap noi isid `mergeby' using `"`using'"'
	if _rc {
		if _rc==459 {
			di as err "in the `using' file"
			exit 459
		}
		else exit _rc
	}

/*Check standard strata var and weights */
	if "`exp'" != "" {
		cap confirm numeric var `exp'
		if _rc {
			di as err _n "iweight error: weight variable must be numeric"
			exit 198
		}
		else	unab wei: `exp', max(1) name(iweight uncorrected)
		cap assert `wei' > 0
		if _rc {
			di as err _n "iweight error: negative weights not allowed"
			exit 198
		}
		cap assert `wei' < 1
		if _rc {
			di as err _n "iweight error: weights must be less than 1"
			exit 198
		}
		if "`standstrata'" == "" {
			di as err _n "{p 0 4 2}iweight error: must also specify standstrata(varname) to " 
			di as err "standardize survival estimates when specifying weights.{p_end}" 
			exit 198
		}
	}
	
	if "`standstrata'" != ""{
		if "`exp'" =="" {
			di as err _n "{p 0 4 2}must also specify weights (using iweight=varname) to standardize"
			di as err "survival estimates across strata of `standstrata'{p_end}"
			exit 198
		}
		cap bysort `by' `standstrata' : assert `wei' == `wei'[_n-1] if _n!=1
		if _rc {
			di as err _n "iweight error: weights are not constant within each level of `standstrata'"
			exit 198
		}
		if "`saving'" != "" & "`brenner'"=="" {
			di as err _n "To save standardised net survival estimates in a file you must specify savst(filename) option"
			exit 198
		}
	}

	if "`indweight'" != ""{
		if "`standstrata'" != "" | "`brenner'" != "" {
				di as err _n "standstrata or brenner option cannot be specified if you use individual weights"
			exit 198
		}
	}
	
	/* Saving instruction */
	// savgroup(filename[, replace]) 
	if "`saving'" != "" {
		gettoken grfile saving : saving, parse(",")
		gettoken comma saving : saving, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outrgro saving : saving, parse(" ,")
			gettoken comma saving : saving, parse(" ,")
			if `"`outrgro'"' != "replace" | `"`comma'"'!="" { 
				di as err "option saving() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			di as err "option saving() invalid"
			exit 198
		}
		else 	confirm new file `"`grfile'.dta"'
	}
	// savstand(filename[, replace]) 
	if "`savstand'" != "" {
		gettoken standfile savstand : savstand, parse(",")
		gettoken comma savstand : savstand, parse(",") 
		if `"`comma'"' == "," { 
			gettoken outrsta savstand : savstand, parse(" ,")
			gettoken comma savstand : savstand, parse(" ,")
			if `"`outrsta'"' != "replace" | `"`comma'"'!="" { 
				di as err "option savstand() invalid"
			exit 198
			}
		}
		else if `"`comma'"' != "" {
			di as err "option savstand() invalid"
			exit 198
		}
		else 	confirm new file `"`standfile'.dta"'
	}

/* Check that format is valid */
	if "`format'" == "" local format %6.4f
	if "`format'" != "" {
		if index("`format'",",") local format = subinstr("`format'", "," , "." , 1) /* european numeric format */
		local fmt = substr("`format'",index("`format'",".")-1,3) 
		capture {
			assert substr("`format'",1,1)=="%" & substr("`format'",2,1)!="d" ///
				& substr("`format'",2,1)!="t" & index("`format'","s")==0
			confirm number `fmt'
		}
		if _rc {
			di as err _n "invalid format. format has been set to default %6.4f"
			local format %6.4f
		}
	}

/* Check attage, attyear, mergeby and survprob */
	if "`attage'"=="" {
		cap confirm new var _age
		if _rc {
			display as err _n "You must specify the variable containing attained age" ///
				" (i.e. age at the time of follow-up)." _n ///
				"This variable cannot exist in the patient data file, but must exist in" ///
    				" the `using' file."
			exit _rc
		}   
		local attage _age
	}
	else {
		capture confirm new variable `attage'
		if _rc {
			display as err _n "The variable `attage' (specified in the attage option) already exists" ///
       			" in the patient data file." _n ///
      			"This variable cannot exist in the patient data file but must exist in the `using' file."
			exit _rc
		}
	}
	if "`attyear'"=="" {
		cap confirm new var _year
		if _rc {
			display as err _n "You must specifies the variable containing attained calendar year" ///
				" (i.e. calendar year at the time of follow-up)." _n ///
				"This variable cannot exist in the patient data file, but must exist in" ///
				" the `using' file."
			exit _rc
		}   
		local attyear _year
	}
	else {
		capture confirm new variable `attyear'
		if _rc {
			display as err _n "The variable `attyear' (specified in the attyear option) already exists" ///
      			" in the patient data file." _n ///
      			"This variable cannot exist in the patient data file but must exist in the `using' file."
			exit _rc
		}
	}
	local inmerby = subinword("`mergeby'","`attage'","",1)
	if "`inmerby'" == "`mergeby'"{			// mergeby does not contain a suitable attained age variable 
		display as err _n "{p}Variable specifying attained age must be specified in mergeby option."
		display as err "It cannot exist in the patient data file.{p_end}"
			exit 198
	}
	local ininmerby = subinword("`inmerby'","`attyear'","",1)
	if "`ininmerby'" == "`inmerby'"{			// mergeby does not contain a suitable attained year variable 
		display as err _n "{p}Variable specifying attained year must be specified in mergeby option."
		display as err "It cannot exist in the patient data file.{p_end}"
			exit 198
	}
	if "`ininmerby'" ~= "" {
		foreach name of local ininmerby {
			capture confirm variable `name'
			if _rc	{
      				display as err _n "mergeby option incorrectly specified." _n ///
        			"`name' must exist in the patient data file."
      				exit _rc
			}
		}
/* Missing values not allowed for variables specified in mergeby option */
		qui count if `touse'
		local nuse = `r(N)'
		markout `touse' `ininmerby', strok
		qui count if `touse'
		if `nuse' > `r(N)' {
			display as err _n "Missing values found in variables specified in mergeby() option." 
			exit 198
		}
	}
	if "`survprob'"=="" {
		cap confirm new var prob
		if _rc {
			display as err _n "You must specify a variable in the `using' file which" ///
				" contains the general population survival probabilities." _n ///
				"This variable cannot exist in the patient data file, but must exist in" ///
				" the `using' file."
			exit _rc
		}   
		local survprob prob
	}
	else {
		capture confirm new variable `survprob'
		if _rc {
			display as err _n "The variable `survprob' (specified in the survprob option) already exists" ///
      			" in the patient data file." _n ///
      			"This variable cannot exist in the patient data file but must exist in the `using' file."
			exit _rc
		}
	}

	tempvar diagage diagyear 
	g `diagage' = (`diagdate' - `birthdate') / 365.241
	qui replace `diagage'=year(`diagdate') - year(`birthdate') if day(`diagdate')==day(`birthdate') & month(`diagdate')==month(`birthdate') 
	g `diagyear' = year(`diagdate') + (doy(`diagdate')-1) / doy(date("31/12/" + string(year(`diagdate')), "DMY"))

	/* UNIQUE option and break list are alternative */
	if "`unique'" != "" & "`breaks'"!="" {
		display as err _n "unique and breaks() cannot be both specified"
		exit 198
	}
	
/* Stardardised estimates are not available when unique is specified 
	if "`unique'" != "" & "`standstrata'" != ""{
		display as err _n "Standardised estimates are not available if option -unique- is specified"
		exit 198
	}
*/
	/* Break list and time must start from 0 */
	if "`unique'" == ""  {
		tokenize `breaks', parse("( ) /")
		if "`1'" != "0" {
			display as err _n "The lifetable intervals in the breaks option must start from 0"
			exit 198
		}
	}
	su _t0 if _st==1, meanonly
	if `r(min)'!=0{
		display as err _n "The time at risk must start from 0"
		exit 198
	}
	if `r(max)' > 0 {
		di as result _newline "Late entry detected for at least one observation (probably because you are using a"
		di as result "period analysis)". 
		local period period
	}
	if "`brenner'" != ""{
		if "`standstrata'" == "" {
			di as err "standstrata(varname) must also be specified when using brenner option"
			exit 198
		}
		if "`exp'" == "" {
			exit 198
		}
			*Check sum of the weights = 1 
		if "`by'"!="" local byby "by `by' : "
		tempvar chkbrw
		qui bysort `by' `standstrata' : g `chkbrw' = `wei' if _n==1
		qui `byby' replace `chkbrw' = sum(`chkbrw')
		cap `byby' assert  round(`chkbrw'[_N],0.01)==1
		if _rc {
			di as err "Using the Brenner adjustment the sum of weigths in the standard population must sum to 1"
			exit 198
		}
	}
	
    if `level'<50 | `level'>99 {
		di in red "level() invalid"
		exit 198
	}
	local level = invnorm((1-`level'/100)/2 + `level'/100)

	if "`listyearly'" != "" & "`at'"!="" {
			di as err _n "listyearly and at(numlist) cannot be both specified"
		exit 198
	}
	if "`listyearly'" != "" & "`unique'"!="" {
			di as err _n "listyearly and unique cannot be combined. When unique is specified you can use at(numlist) to show results at specified times from diagnosis."
		exit 198
	}

	qui replace `touse' = 0 if _st==0
	tempvar group y d_star p_star weipoharend weipohar N weibr t0
	
/* Brenner weights generated as the ratio between relative proportion of patients in the standard population and in the study population */
	if "`brenner'"!="" {
		g `t0' = _t0==0
		qui bysort `by' `touse' `t0': g long `N' = _N   // In case of period analysis it should be considered only diagnoses in the time window (Mark)
		qui bysort `by' `touse' `t0' `standstrata' : g `weibr' = `exp'/(_N/ `N') if `touse' & `t0'
		if "`period'" !="" 		bysort `by' `standstrata' `touse' (_t0): replace `weibr' = `weibr'[1] if `touse'
		local standstrata
		local wei
	}
	
* Individual weights	
	else if "`indweight'" != "" 	g `weibr' = `indweight'
	
* For usual Pohar Perme weights	
	else g `weibr' = 1
	
	if "`ederer2'"!="" 	tempvar p_y 
	
	cap confirm matrix I
	if !_rc {
		tempname ORI
		matrix `ORI' = I
		local isI isI
	}

/* By-Standstrata option */
	if "`by'"=="" &	"`standstrata'"=="" qui g byte `group' = 1 if `touse'
	else 	qui egen `group' = group(`by' `standstrata') if `touse'
	su `group' if `touse',meanonly
	local ng = `r(max)'
	if `ng' > 1 {
		preserve
		tempfile bygr
		qui bysort `group' : keep if _n==1 & `touse'
		keep `group' `by' `standstrata' `wei'
		rename `group' gr
		qui save `bygr'
		restore
	}

	su `_dta[st_bt]', meanonly
	local maxfu = `r(max)'
	st_show `show'
	preserve
	qui {
		keep if `touse'
		g `attage' = .
		g `attyear'= .
		g `y'      = .
		if "`ederer2'"!="" g `p_y' = .
		g `d_star'    = .
		g `p_star'    = .
		g double `weipoharend' = `weibr'
		gen `weipohar' = `weibr'
	}
	tempname start end
	local obs = 0
	scalar `start' = 0

	if "`unique'" != "" {
		tempvar event T
		qui bys `touse' _t (_d) : gen byte `event' = cond(_n==_N & _d==1, -1, .) if `touse'
		sort `touse' `event' _t
		local nobs = _N
		qui count if `event' == -1
		local nevent = r(N)
		if `nevent' == 0 {
			noi di as txt "(there are no failures)"
			exit 0
		}

		/* count distinct failure times within strata 
		   nEventStrata = #failures per stratum (may be 0) */
		if `ng' > 1 {
			tempname nEventStrata mfail
			gen byte `mfail' = `event' == -1
			qui tab `group', matcell(`nEventStrata') subpop(`mfail')
			local nStrata = rowsof(`nEventStrata')
			drop `mfail'
			forv is = 1/`ng' {
				if `nEventStrata'[`is',1] == 0 {
					local zerofound 1
				}
			}
			if "`zerofound'" != "" {
				noi di as txt "note: there are strata without failures"
			}
		}
		qui gen double `T' = _t in 1/`nevent'
		local cicle "forval i = 1/ `nevent'"
		local eqs   "="
	}
	else {
		local cicle "forval i = `breaks'" 
	}

	`cicle' {
		if `i' != 0 {
			qui {
				drop if _t  <`eqs' `start'
				if "`unique'" !="" 	scalar `end'  = `T'[1]
				else 				scalar `end'  = `i'
				replace `attage'  = min(int(`diagage'+`start'),`maxage') 
				replace `attage'  = min(`attage'+1,`maxage') if (`diagage'+`start')-`attage' >=0.9999  // If interval length is 0.0833333 (in month)
				replace `attyear' = int(`diagyear'+`start')                                 // attained age and year must be rounded to
				replace `attyear' = `attyear'+1 if (`diagyear'+`start')- `attyear'>=0.9999  // the upper integer when they become #.9999
			/* Merge in the external rates */
				merge m:1 `mergeby' using "`using'", keepus(`survprob')
			/* Print a warning message if any records do not match with general population file and exit */
				count if _merge==1 & `_dta[st_o]' +`start'*`_dta[st_bs]' <= `maxfu'
			}
			if r(N) {
			di in red "`r(N)' records fail to match with the population file (`using'.dta)."
				di in red "That is, there are combinations of the mergeby() variables that do not exist in `using'.dta."
				di in red _newline "This will occur, for example, when patients are followed-up beyond" 
				di in red "the last year for which population mortality data are available." 
				di in red _newline "Records that did not match have been written to _merge_error_.dta)."
					qui keep if _merge==1 & `_dta[st_o]' +`start'*`_dta[st_bs]' <= `maxfu'
					qui save _merge_error_.dta, replace
					exit 459 
			}
			qui {
				keep if _merge==3 /* Keep only if observations exists in both files */
				drop _merge
	* Old code for y when IPW are estimated at the end of each interval - preparing py for Ederer II results
				if "`endwei'"!="" | "`ederer2'"!=""{  
					replace `y' = min(_t-`start', `end'-`start') 
					replace `y' = . if _t0 >= `end'
					replace `y' = min(`y', `end'-_t0) if `y'<.	// if the subject enters in the interval
					replace `y' = min(`y', _t-_t0) if `y'<.		// if the subject dies in the interval he enters
					if "`ederer2'"!="" replace `p_y' = `y'
				}
	* New code for y when IPW are estimated at the mid-pointd of each interval - y is 0.5 interval for deaths and censored within the interval
				if "`endwei'"=="" { 
					replace `y' = `end'-`start' 
					replace `y' = . if _t0 >= `end'
					replace `y' = min(`y', `end'-_t0) if `y'<.     // if the subject enters in the interval
					if "`unique'" == "" replace `y' = 0.5*`y' if  `y'<. & _t<`end'     // if subject dies or is censored in the interval
				}
				replace `d_star'=-ln(`survprob')*`y' 
				replace `p_star'=`survprob'^(`end'-`start') 
				replace `weipoharend' = 1/`p_star' * `weipoharend'

	* Seppa and Pokhrel : expected survival proportion at the mid-point of the interval should provide better weights
				if "`endwei'"!="" 	replace `weipohar' = `weipoharend' 
				else 				replace `weipohar' = `weipoharend' * sqrt(`p_star')
				forval ni = 1/`ng' {
					count if _d!=. & _t0<`eqs'`end' & `group'==`ni'  // In ltable intervals are in the form [ t )
					local n = `r(N)' 
					if `n' > 0 {
						su _d if _d == 1 & _t<`eqs'`end' & `group'==`ni' [iw = `weibr'], meanonly
						local d = `r(sum)' 
						su _d if _t<`eqs'`end' & `group'==`ni' & _d==1 [iw = `weipohar'], meanonly
						local d_poh = `r(sum)' 
						su _d if _t<`eqs'`end' & `group'==`ni' & _d==1 [iw = `weipohar'^2], meanonly
						local d_pohsq = `r(sum)' 
						su `d_star' if `group'==`ni' [iw = `weipohar'], meanonly
						local d_starpoh = `r(sum)'
						su `y' if `group'==`ni' [iw = `weipohar'], meanonly
						local y_poh = `r(sum)' 
						if "`ederer2'"!="" {
							su `p_y' if `group'==`ni' [iw = `weibr'], meanonly
							local py = `r(sum)' 
							replace `p_star' = . if _t0 >= `end'
							su `p_star' if `group' == `ni' [iw = `weibr'], meanonly
							local ces = `r(mean)'
							if "`brenner'"!= "" | "`indweight'"!="" {
								su _d if _t<`eqs'`end' & `group'==`ni' & _d==1 [iw = `weibr'^2], meanonly
								local d_sq = `r(sum)' 							
							}
							else local d_sq = `d'
						}
						mat I = `ni', `start', `end', `n', `d', `d_poh', `d_pohsq', `d_starpoh', `y_poh'
						if "`ederer2'"!="" mat I = I, `py', `ces', `d_sq'
						mata : genmat()
						local ++obs
					}
				}
			}
			sort `touse' `event' _t
			if "`unique'" !="" 	scalar `start'  = `T'[1]
			else 				scalar `start'  = `i'
*			di "start = " `start'
			drop `survprob'
		}
	}

	if "`grfile'" != "" local filename `c(filename)'
	clear
	qui set obs `obs'
	if "`ederer2'"==""	mata: genres(*netsurvmat)
	else			mata: genresed(*netsurvmat)
	matrix drop I
	if "`isI'" != "" matrix I = `ORI'
	qui {
		sort gr start
		by gr (start) : g double cns   = exp(sum(-(end-start)*(dpoh-dstarpoh)/ypoh))
		by gr (start) : g double secns = cns * sqrt(sum((end-start)^2 * dpohsq/ypoh^2)) 
		if "`cilog'" =="" {
			g double locns = exp(-exp(log(-log(cns)) - secns*`level'/(cns*log(cns))))
			g double upcns = exp(-exp(log(-log(cns)) + secns*`level'/(cns*log(cns))))
			replace locns = cns if cns<=0 | cns>=1 
			replace upcns = cns if cns<=0 | cns>=1 
		}
		else {
			g double locns = cns*exp(-secns*`level'/cns)
			g double upcns = cns*exp(secns*`level'/cns)
		}
		if "`ederer2'"!="" {
			by gr (start) : g double cs=exp(sum(ln(exp(-(end-start)*d/py)))) if exp(-(end-start)*d/py)!=0
			replace cs=0 if exp(-(end-start)*d/py)==0 
			by gr (start) : replace ces=exp(sum(ln(ces)))
			g double cre2   = cs / ces
			by gr (start) : g double secs   = cs * sqrt(sum((end-start)^2*d_sq/py^2))  // d_sq is the sum of events or, if Brenner, the sum of events with squared Brenner weights
			g double secre2 = secs / ces
			if "`cilog'" =="" {
				g double locre2 = exp(-exp(log(-log(cs))-secs*`level'/(cs*log(cs)))) / ces
				g double upcre2 = exp(-exp(log(-log(cs))+secs*`level'/(cs*log(cs)))) / ces
				replace locre2 = cre2 if cre2<=0 | cre2>=1 
				replace upcre2 = cre2 if cre2<=0 | cre2>=1 
			}
			else {
				g double locre2 = cs*exp(-secs*`level'/cs) / ces
				g double upcre2 = cs*exp(secs*`level'/cs) / ces 
			}
		}
	}
	if `ng' > 1 qui merge m:1 gr using `bygr'
	format start end %6.0g
	format n d %7.0f
	format dpoh dstarpoh ypoh %8.2f
	format cns secns upcns locns `format'
	if "`ederer2'" != "" {
		format py %8.2f
		format cs ces cre2 secre2 locre2 upcre2 `format'
	}
	/* Show tables */
	if "`tables'" == "" {
		if `ng' > 1	local byst "bysort `by' `standstrata': "
		if "`at'" != "" {
			tempvar toshow
			g byte `toshow' = 0
			qui g Time = .
			local timevals `at'
			if `ng' > 1 {
				forval l = 1/`ng' {
					foreach t of numlist `timevals' {
							summarize end if gr==`l' &  end<=`t', meanonly
							qui replace `toshow' = 1 if gr==`l' &  float(end)==float(`r(max)')
							qui replace Time = `t' if gr==`l' &  float(end)==float(`r(max)')
					}
				}
			}
			else {
				foreach t of numlist `timevals' {
						summarize end if  end<=`t', meanonly
						qui replace `toshow' = 1 if float(end)==float(`r(max)')
						qui replace Time = `t' if float(end)==float(`r(max)')
				}
			}
			local atsh "if `toshow'"
		}
		if "`listyearly'" != "" {
			tempvar toshow
			g byte `toshow' = int(end) 
			qui bysort `by' `standstrata' `toshow' (end): replace `toshow' = 0 if _n>1
			qui replace `toshow' = 0 if int(end)==0
			local listye "if `toshow'"
		}
		if "`list'"==""{
			if "`brenner'"!="" 	di as res _n "Adjusted survival estimates weighting individual observations as proposed by Brenner."
			if "`indweight'"!="" 	di as res _n "Adjusted survival estimates weighting individual observations with weights in `indweight'."
			if "`ederer2'" == "" di as result _newline "Cumulative net survival according to Pohar Perme, Stare and Estève method."
			else		     di as result _newline "Cumulative relative survival according to Ederer II method."
			if "`at'" == "" {
				if `ng' > 1 {
					if "`ederer2'" == "" `byst' list start end n d cns locns upcns secns `listye', table noobs 
					else		     `byst' list start end n d py cs ces cre2 locre2 upcre2 `listye', table noobs 
				}
				else {
					if "`ederer2'" == ""         list start end n d cns locns upcns secns `listye', table noobs 
					else			     list start end n d py cs ces cre2 locre2 upcre2 `listye', table noobs  
				}
			}
			if "`at'" != "" {
				if `ng' > 1 {
					if "`ederer2'" == "" `byst' list Time cns locns upcns secns `atsh', table noobs 
					else		     `byst' list Time cs ces cre2 locre2 upcre2 `atsh', table noobs 
				}
				if `ng' == 1 {
					if "`ederer2'" == ""         list Time cns locns upcns secns `atsh', table noobs 
					else			     list Time cs ces cre2 locre2 upcre2 `atsh', table noobs  
				}
			}
		}		
		if "`list'"!="" {
			foreach name of local list {
				cap confirm var `name'
				if _rc    di as err "WARNING: `name' invalid or ambiguous in list option" 
			}
			local list : list uniq list
			local st_end "start end"
			if "`by'" != "" local list : list list - by
			local flist : list list - st_end
			if "`brenner'"!="" 	di as res _n "Adjusted survival estimates weighting individual observations as proposed by Brenner."
			if "`indweight'"!="" 	di as res _n "Adjusted survival estimates weighting individual observations with weights in `indweight'."
			di as result _newline "Cumulative net survival according to Pohar Perme, Stare and Estève method."
			if "`ederer2'" != "" di as result "and cumulative relative survival according to Ederer II method."
			if "`at'" == "" {
				if `ng' > 1 	`byst' list start end `flist' `listye', table noobs
				if `ng' == 1 	list start end `flist' `listye', table noobs 
			}
			if "`at'" != "" {
				local nd "n d"
				local flist : list flist - nd
				if `ng' > 1 	`byst' list  Time `flist' if gr==`ni' `atbysh', table noobs
				if `ng' == 1 	list Time `flist' `atsh', table noobs 
			}
		}
	}
	if "`grfile'" != "" {
		label variable start "Start time of interval"
		label variable end "End time of interval"
		label variable n "Alive at start"
		label variable d "Deaths during the interval"
		label variable cns "Cumulative net survival (Pohar Perme et al)"
		label variable secns "Standard error of CNS (Pohar Perme et al)"
		label variable locns "Lower 95% CI for CNS (Pohar Perme et al)"
		label variable upcns "Upper 95% CI for CNS (Pohar Perme et al)"
		label variable dpoh "Weighted deaths during the interval (Pohar Perme et al)"
		label variable dstarpoh "Weighted expected deaths during the interval (Pohar Perme et al)"
		label variable ypoh "Weighted person-years at risk (Pohar Perme et al)"
		if "`standstrata'"!=""  label var `wei' "Weight"
		if "`ederer2'" != "" {
			label variable py "Person-years at risk"
			label variable cs "Cumulative observed survival"
			label variable cre2 "Cumulative relative survival (Ederer II)"
			label variable ces "Cumulative expected survival (Ederer II)"
			label variable secre2 "Standard error of cre2 (Ederer II)"
			label variable locre2 "Lower 95% CI for cre2 (Ederer II)"
			label variable upcre2 "Upper 95% CI for cre2 (Ederer II)"
		}
		if "`ederer2'"=="" keep `by' `standstrata' `wei' start end n d dpoh dpohsq dstarpoh ypoh cns secns locns upcns // cumypoh
		else  keep `by' `standstrata' `wei' start end n d dpoh dstarpoh dpohsq ypoh cns secns locns upcns py cs ces cre2 secre2 locre2 upcre2
		if "`brenner'" != "" {
			label data "Age-adjusted survival data using the Brenner approach"
			note: According to Brenner and Hakulinen approach weights have been assigned at each individual. Therefore the saved data contain a weighted life table. 
		}
		if "`indweight'" != "" {
			label data "Weighted survival data."
			note: Weights specified in `indweight' have been assigned at each individual. Therefore the saved data contain a weighted life table. 
		}
		label data "Collapsed survival data created from `filename'"
		save "`grfile'", `outrgro'
	}

	/* Weighted average of survival estimate */
	if "`standstrata'"!="" {
			/* AIRTUM Analysis April 2011 - When hybrid or period approach is applied to rare tumours it may happen
			   that survival estimates are indeterminate in the first or intermediate intervals.
			   In this case standardized survival cannot be estimated after the interval where the survival is indeterminate. */
		su end,meanonly
		cap bysort `by' `standstrata' (start) : assert float(end[1])==float(`r(min)')
		if _rc {
			qui bysort `by' `standstrata' (start) : drop if float(end[1])!=float(`r(min)')
			di in smcl as txt "{p}Note that in some `by' group adjusted estimates cannot be computed " ///
				"because the survival estimates does not start from the first interval.{p_end}"
		}
		qui bysort `by' `standstrata' (start): g byte chkseq = 1 if start!=end[_n-1] & _n!=1
		qui bysort `by' `standstrata' (start): replace chkseq = sum(chkseq)
		qui drop if chkseq>0
		/*  11 may 2011 - Age-standardized survival estimates cannot be computed from the interval where -n- becomes 0 in an age group, 
		     typically age>75. But we should distinguish two situations:
		    1) the survival probability decreases to 0, i.e. all cases present at the start of the interval die within the interval.
		       In the following intervals -n- is 0, but the survival is still 0 (not indeterminate). Therefore, the standardized survival 
		       can be calculated.  
		    2) -n- becomes 0 because of withdrawals (and not for deaths) in the previous interval.
		       In this case the survival is indeterminate and the standardized survival cannot be calculated. */
		 /* 24 jan 2013 Pohar Perme net survival can be greater than 0 when all observed subjects at the start of the follow up
		    die within the interval. In the following intervals the net survival should be indeterminate */
		local cr_stand cns secns
		if "`ederer2'"!="" {
			local cr_standed cre2 secre2
			qui {
				count if cs==0
				if `r(N)'>0 {
					fillin `by' `standstrata' end
					count if _f==1
					if `r(N)' > 0 {
						bysort `by' `standstrata' (end) : replace `wei'=`wei'[_n-1] if `wei'==.
						foreach var of varlist `cr_standed' {
							bysort `by' `standstrata' (end) : replace `var'=`var'[_n-1] if cre2[_n-1]==0 
						}
						drop if cre2==.
						bysort `by' `standstrata' (end) : replace start=end[_n-1] if start==.
					}
					drop _f
				}
			}
		}
			* Erase intervals where some standstrata are missing
		qui inspect `standstrata'
		qui bysort `by' start: drop if _N!=`r(N_unique)'
			/* Confidence Intervals for Standardized Estimates according to the formula used in Eurocare IV.
			   Thanks to Roberta De Angelis 25 mar 2011
			   SE_CRstandardized =  [Summ_k (w_k * SE_k)^2]^1/2  =  [Summ_k w_k*(w_k * SE_k^2)]^1/2	*/
		qui replace secns = `wei'*secns^2
		if "`ederer2'" != ""	qui replace secre2  = `wei'*secre2^2  // 
		collapse `cr_stand' `cr_standed' [iw=`wei'], by(`by' start end)
		qui replace secns = sqrt(secns)
		if "`cilog'"=="" {
			gen locns = cond(cns<=1,cns^exp(`level'  * abs(secns /(cns *log(cns)))),.)  
			gen upcns = cond(cns<=1,cns^exp(-`level' * abs(secns /(cns *log(cns)))),.) 
		}
		else {
			gen locns = cns*exp(-`level'*secns /cns)  
			gen upcns = cns*exp(`level'*secns /cns)		
		}
		label var cns "Standardized CNS (Pohar Perme et al)"
		label var locns "Lower 95% CI for standardized CNS (Pohar Perme et al)"
		label var upcns "Upper 95% CI for standardized CNS (Pohar Perme et al)"
		label var secns "Standard error of standardized CNS (Pohar Perme et al)"
		local cr_stand cns secns locns upcns
		if "`ederer2'" != "" {
			qui replace secre2 = sqrt(secre2)
			if "`cilog'"=="" {
				gen locre2 = cond(cre2<=1,cre2^exp(`level'  * abs(secre2 /(cre2 *log(cre2)))),.)  
				gen upcre2 = cond(cre2<=1,cre2^exp(-`level' * abs(secre2 /(cre2 *log(cre2)))),.) 
			}
			else {
				gen locre2 = cre2*exp(-`level'*secre2 /cre2)  
				gen upcre2 = cre2*exp(`level'*secre2 /cre2)		
			}
			label var cre2 "Standardized CR (Ederer II)"
			label var locre2 "Lower 95% CI for standardized CR (Ederer II)"
			label var upcre2 "Upper 95% CI for standardized CR (Ederer II)"
			label var secre2 "Standard error of standardized CR (Ederer II)"
			local cr_stand `cr_stand' cre2 secre2 locre2 upcre2
		}
		format `cr_stand' `format'
		if "`tables'" == "" {
			if "`by'"!=""	local byby "by `by': "
			di in smcl as res _n "{p}Adjusted survival estimates weighting stratum-specific survival in each group" ///
				" of `standstrata' by `exp' weights.{p_end}"
			if "`list'"!=""		local cr_stand : list cr_stand & flist
			if "`at'" != "" {
				tempvar toshow
				g byte `toshow' = 0
				g Time = .
				local timevals `at'
				if "`by'"!="" {
					qui levelsof `by', local(levels)
					foreach l of local levels {
						foreach t of numlist `timevals' {
								summarize end if `by'==`l' &  end<=`t', meanonly
								qui replace `toshow' = 1 if `by'==`l' &  float(end)==float(`r(max)')
								qui replace Time = `t' if `by'==`l' &  float(end)==float(`r(max)')
						}
					}
				}
				else {
					foreach t of numlist `timevals' {
							summarize end if end<=`t', meanonly
							qui replace `toshow' = 1 if float(end)==float(`r(max)')
							qui replace Time = `t' if float(end)==float(`r(max)')
					}
				}
				`byby' list Time `cr_stand' if `toshow', table noobs
				drop `toshow'
			}
			else {
				if "`listyearly'" != "" {
					g byte `toshow' = int(end) 
					qui bysort `by' `toshow' (end): replace `toshow' = 0 if _n>1
					qui replace `toshow' = 0 if int(end)==0
				}
				`byby' list start end `cr_stand' `listye', table noobs
				if "`listyearly'" != "" drop `toshow'
			}
		}
		*Save standardised estimates
		if "`standfile'" != "" save "`standfile'", `outrsta'
	}

end


version 11
mata:
mata set matastrict on
function genmat()
{ 
	real matrix A
	real matrix netsurvmat
	A =  st_matrix("I")
	pointer() scalar p 
	if ( (p = findexternal("netsurvmat")) == NULL) {
		p = crexternal("netsurvmat")
		*p = (&A)
	}
	else {
		netsurvmat = *(*p) \ A
		*p = (&netsurvmat) 
	}
}

function genres(real matrix A)
{ 
	real scalar newvars
	newvars = st_addvar("float", ("gr", "start", "end", "n", "d", "dpoh", "dpohsq", "dstarpoh", "ypoh")) 
	st_store(., newvars, A )
	rmexternal("netsurvmat")
}

function genresed(real matrix A)
{ 
	real scalar newvars
	newvars = st_addvar("float", ("gr", "start", "end", "n", "d", "dpoh", "dpohsq", "dstarpoh", "ypoh", "py", "ces", "d_sq")) 
	st_store(., newvars, A )
	rmexternal("netsurvmat")
}
end

