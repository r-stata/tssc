*! version 2.1 abuxton 23sep2007. 23Oct2013
*! _cureregr8, version 8.2 cure model regression or parametric cure model PCM
* former - postcureregtask1, cure model regression or parametric cure model PCM
* post cureregr8 display survival estimates at(numlist times)
*! main program cureregr8.ado, called by predict after cureregr8 ...run via predict switch 

program define _cureregr8,rclass
version 8.2

		syntax [if] [in] , [At_points(numlist)] 	///
			[LEVELopt0(string)] [FMTprint(string)]	///
			[*]
			tempvar touse
			mark `touse' `if' `in' `e(sample)'
			qui count if `touse'
			if r(N)==0 {
				error 2000 			/* no observations */
				}
		if `"`at_points'"' ~= `""' {
			local Nlst = `"`at_points'"'
			numlist "`Nlst'" , min(1) sort ascending
			local timelst = r(numlist)
			local atopt 1
		}
		else {
			local atopt 0
		}
/* keep the whole typed command in case at() is not specified */
local alt_argument `"`0'"'
/* di `"macro alt: `alt_argument'"' */
local alt_options `"`options'"'
/* di `"macro options: `alt_options'"' */

tokenize `levelopt0'
	local level_n : word count `levelopt0'
	if `level_n' == 0 {
		local levelopt `"level(95)"'
	}
	else if `level_n' == 1 {
		local levelopt `"level(`levelopt0')"'
	}

tokenize `fmtprint'
	local fmtprint_n: word count `fmtprint'
	if `fmtprint_n' == 0 {
		local fmtprint `"%8.6f"'
	}
	else if `level_n' == 1 {
		local fmtprint `"`fmtprint'"'
	}

if `"`alt_options'"' ~= `""' & `atopt' == 1 {
	di `"{err}please type either at() or estimation options, not both at once{txt}"'
	exit
	}
else if `"`alt_options'"' == `""' & `atopt' == 0 {
	di `"{err}please type either at() or estimation options {txt}"'
	exit
	}
else {
	/* good to go on as one or the other not both at() & alt_options are specified */
	}

/*check e(varlist) if a constant model is fit ... there is nothing to contract statment below ...*/
tokenize `e(varlist)'
local varlist_n : word count `e(varlist)'
/*di `"e(varlist):`e(varlist)'"'*/
/*di `"varlist_n :`varlist_n'"'*/
if `varlist_n'==0 {
	local flag_cons_only=1
	}
else	{
	local flag_cons_only=0
}



/* define control for the models */
		local lnl = lower(substr(`"`e(user)'"',4,2))
		local krn = lower(substr(`"`e(user)'"',6,2))
		local cfl = lower(substr(`"`e(user)'"',8,2))

/* bgn if At_points exists -atopt- then do the following and exit the _cureregr8 */
if `"`timelst'"' ~= "" {
	preserve
		if `"`cfl'"' == `"01"' {
			local pi `"(1/(1+exp(-1*(xb(#1)))))"'
			}
		else if `"`cfl'"' == `"02"' {
			local pi `"(exp(-1*exp((xb(#1)))))"'
			}
		else if `"`cfl'"' == `"03"' {
			local pi `"((xb(#1)))"'
			}
		tempname S seS lci uci lmllci lmluci lmlS lml_lci lml_uci
		tempfile dtasetA

			qui keep if `touse'
                        if `flag_cons_only'==1 {
				capture drop cons /*in case it is already in incoming dataset that is preserved anyway*/
                        	gen byte cons=1 
				keep cons `e(depvar)'
                        }
			else {		
				keep `e(varlist)' `e(depvar)'
			}
			qui save `dtasetA',replace all
			/*di `"contract `e(varlist)'"'*/
                        if `flag_cons_only'==1 {
   			contract cons
   			}
   			else {
   			contract `e(varlist)'
   			}
			gen byte c=1
			order c
			local combinations = _N
capture noisily {
			foreach ic of numlist 1/`combinations' {
				/*di `" combination `combinations'"'*/
		use `dtasetA',clear
			qui keep if e(sample)
                        if `flag_cons_only'==1 {
   			contract cons
   			}
   			else {
   			contract `e(varlist)'
   			}
			/*gen byte c=1*/
			/*order c*/
				list if _n==`ic' , abbr(32)
				qui keep if _n==`ic'
	foreach time of numlist `timelst' {
			local ttfunction `"((exp(xb(#2)) * `time')^exp(xb(#3)))"'
		if `"`krn'"' == `"01"' {
			local kr `"(1-exp(-1*(`ttfunction')))"'
			}
		else if `"`krn'"' == `"02"' {
			local kr `"(norm(ln(`ttfunction')))"'
			}
		else if `"`krn'"' == `"03"' {
			local kr `"(`ttfunction'/(1 + `ttfunction'))"'
			}
		else if `"`krn'"' == `"04"' {
			local tt `"((`time')/exp(xb(#2)))"'
			local kr `"(gammap(exp(xb(#3)),`tt'))"'
			}
		else if `"`krn'"' == `"05"' {				// exponential dist gamma shape==1
			local tt `"((`time')/exp(xb(#2)))"'
			local kr `"(gammap(1,`tt'))"'
			}

		if `"`lnl'"' == `"00"'	{
			local function `"(1+((`pi'-1)*`kr'))"'
			}
		else if `"`lnl'"' == `"01"'	{
			local function `"((`pi')^(`kr'))"'
			}
		local lmlfunction `"ln(-1*ln(`function'))"'
		qui predictnl double `S' = `function' , se(`seS') ci(`lci' `uci') `levelopt' force iter(100)
		qui predictnl double `lmlS' = `lmlfunction' , ci(`lmllci' `lmluci') `levelopt' force iter(100)
			qui gen double `lml_lci'  = exp(-exp(`lmluci'))
			qui gen double `lml_uci'  = exp(-exp(`lmllci'))
			local surv : di `fmtprint' `S'
			local serr : di `fmtprint' `seS'
			local slci : di `fmtprint' `lml_lci'
			local suci : di `fmtprint' `lml_uci'
			di `"{res}time: "' `time', _col(12) `"S(t)= "' `surv', _col(27) `"se= "' `serr' _col(40) `"ci: ("' `slci' _col(52) `" - "' _col(55) `suci' `") {txt}"'
			qui drop `S' `seS' `lci' `uci' `lmllci' `lmluci' `lmlS' `lml_lci' `lml_uci'
			local rtn_time = `time'
	}
	}
	}
	di `"{txt}"'
	return scalar pcm_uci=`suci'
	return scalar pcm_lci=`slci'
	return scalar pcm_se=`serr'
	return scalar pcm_s=`surv'
	return scalar pcm_time=`rtn_time'
}
else {
	/* essentially postregrtask2.ado */
	/* di `"qui _cureregr8_gen if `touse' `alt_argument'"' */
	qui _cureregr8_gen if `touse' `alt_argument'
	}
/* end if At_points exists -atopt- then do the following and exit the _cureregr8 */

end /* _cureregr8 */
