*! version 1.00 12jan2011 Sergiy Radyakin
*! Generate true random numbers utilizing RANDOM.ORG web service
*! written completely in Stata's built-in commands. does not use a single ado-file. not even standard Stata ado-files.
*! can run in Stata 7 (including Small Stata).

program define truernd

	version 7.0

	if (`"`0'"'=="") {
		display_about_msg
		exit
	}

	capture syntax anything
	if !_rc {
		if (`"`anything'"'=="recheck") {
			recheck_quota
			exit
		}
	}

	capture syntax , matrix(string)
	if !_rc {

		if (_caller()>=8.0) {
			confirm_matrix8, matrix(`matrix')
		}
		else {
			confirm_matrix7, matrix(`matrix')
		}

		generate_random_matrix `0'
		exit
	}
	
	capture syntax , count(integer) [*]
	if !_rc {
		generate_random_var `0'
		exit
	}

	error 111
end

program define confirm_matrix7
	
	version 7.0

	syntax , matrix(string)

	capture confirm number `=rowsof(`matrix')'

	if _rc {
		display as error "matrix `matrix' not found"
		error 111
	}
end

program define confirm_matrix8

	version 8.0

	syntax , matrix(string)

	confirm matrix `matrix'
end

program define generate_random_matrix

	version 7.0

	syntax , matrix(string)

	local rlimit "1000000000"
	local nlimit "10000"

	local nrows = rowsof(`matrix')
	local ncols = colsof(`matrix')

	local rnd_numbers = `nrows' * `ncols'
	if (`rnd_numbers'>`nlimit') {
		display as error _n "Matrix is too large. Must be no more than `nlimit' elements, actual size is `rnd_numbers' elements"
		error 994
	}

	tempfile rndtable
	get_rnd_internal using `"`rndtable'"', n(1) rnd_numbers(`rnd_numbers') min(0) max(`rlimit')
	read_matrix_from_file using `"`rndtable'"', matrix(`matrix')
end

program define read_matrix_from_file

	version 7.0

	syntax using/, matrix(string)

	local rlimit "1000000000"
	local nrows = rowsof(`matrix')
	local ncols = colsof(`matrix')

	tempname fh
	file open `fh' using `"`using'"', read text
	
	forvalues i=1/`nrows' {
		forvalues j=1/`ncols' {
			file read `fh' oneline
			matrix `matrix'[`i',`j'] = `oneline'/`rlimit'
		}
	}
	
	file close `fh'
end

program define generate_random_var

	version 7.0

	syntax , count(integer) [ n(integer 1) min(integer 0) max(integer 100) clear ]

	local nlimit = "10000"

	if (`n'>`nlimit') {
		display as error _n `"Number of variables is too large. Must be: n<=`nlimit', requested:n=`n'"'
		error 999
	}

	local rnd_numbers = `count'*`n'
	if (`rnd_numbers'>`nlimit') {
		display as error _n `"The total number of random numbers is too large. Must be: count*n<=`nlimit', requested:`count'*`n'=`rnd_numbers'"'
		error 995
	}

	tempfile rndtable
	get_rnd_internal using `"`rndtable'"', n(`n') rnd_numbers(`rnd_numbers') min(`min') max(`max')
	insheet using `"`rndtable'"', `clear'
end

program define get_rnd_internal
	
	version 7.0

	syntax using/ , n(integer) rnd_numbers(integer) min(integer) max(integer)

	local rlimit "1000000000"
	if (inrange(`min',-`rlimit',`rlimit')==0) {
		display as error _n `"Parameter out of range: min must be in [-`rlimit';`rlimit']"' _n
		error 998
	}
	
	if (inrange(`max',-`rlimit',`rlimit')==0) {
		display as error _n `"Parameter out of range: max must be in [-`rlimit';`rlimit']"' _n
		error 997
	}

	if (`min'>`max') {
		display as error _n `"Inconsistent parameters: min must be less than max."'
		display as error "Received parameters: min=`min' and max=`max'" _n
		error 996
	}

	check_quota	

	local rnd_srvc_site "http://www.random.org/integers/"
	local rnd_srvc_query "?num=`rnd_numbers'&min=`min'&max=`max'&col=`n'&base=10&format=plain&rnd=new"
	
	capture copy `"`rnd_srvc_site'`rnd_srvc_query'"' `"`using'"'
	if _rc {
		failed_retrieve_rnd_table `_rc'
	}
	
	check_for_error using `"`using'"'
end

program define failed_retrieve_rnd_table

	version 7.0

	display as error _n "Failed to retrieve the random numbers from the server"
	*** Note: Stata does not allow to retrieve the actual HTTP error code

	error 991
end

program define check_for_error

	version 7.0

	syntax using
	tempname fh
	file open `fh' `using', read text
	file read `fh' first_line
	file close `fh'
	
	local first_line = upper(`"`first_line'"')
	if (index(`"`first_line'"',"ERROR")>0) {
		display as error _n `"Service responded with an error message: `first_line'"'
		error 990
	}
end

program define recheck_quota

	version 7.0

	macro drop RND2_LAST_QUOTA_CHECKED RND1_LAST_QUOTA
	check_quota
	display as text _n "Your current quota is: " as result "$RND1_LAST_QUOTA"
end

program define check_quota

	version 7.0

	check_can_request_quota

	tempname fh
	tempfile quotafile

	capture copy `"http://www.random.org/quota/?format=plain"' `"`quotafile'"'
	file open `fh' using `"`quotafile'"', text read
	file read `fh' quota

	global RND2_LAST_QUOTA_CHECKED "`c(current_date)' `c(current_time)'"
	global RND1_LAST_QUOTA "`quota'"

	if (`quota'<0) {
		display as error _n `"Quota exhausted: `quota'<0"' _n
		di `"For additional information or to purchase additional allowance"' _n ///
		   `" visit the service's web page: {browse "http://www.random.org/quota/"}"' _n
		error 992
	}
end

program define check_can_request_quota

	version 7.0

	if (`"$RND1_LAST_QUOTA"'!="") {
		*** last quota is known, must implement the following rule:
		***   "If a quota check returns a negative value, your client
		***   should back off for at least ten minutes before issuing
		***   another quota check"

		local wait_interval = 10*60

		if ($RND1_LAST_QUOTA<0) {
			*** last quota was negative
			*** check if we can re-request quota

			elapsed_seconds

			if (`time_diff'<`wait_interval') {
				display _n
				display as error `"Quota exhausted. Must wait 10 minutes since last query. Please wait."'
				display as error `"Your last quota was checked on $RND2_LAST_QUOTA_CHECKED : $RND1_LAST_QUOTA"' _n
				error 993
			}

		}
		else {
			*** last quota was not negative
			*** to reduce server load must ensure there is at least 30 seconds interval between requests
			
			local wait_interval = 30

			elapsed_seconds

			if (`time_diff'<`wait_interval') {
				local rest = `wait_interval'-`time_diff'
				sleep `=`rest'*1000'
			}
		}
	}	
end

*** Begin of Stata 7 compatibility region ***

program define get_sec_begin_day

	version 7.0

	syntax anything
	assert length("`anything'")==8

	local hr = substr("`anything'",1,2)
	local mn = substr("`anything'",4,2)
	local sc = substr("`anything'",7,2)

	c_local sec_begin_day `=`hr'*60*60+`mn'*60+`sc''
end

program define get_time_diff

	version 7.0

	syntax , time1(string) time2(string)

	get_sec_begin_day `time1'
	local sec1 `sec_begin_day'
	get_sec_begin_day `time2'
	local sec2 `sec_begin_day'

	c_local t_diff `=`sec2'-`sec1''
end

program define time_diff_now

	version 7.0

	syntax , with_date(string) with_time(string)

	c_local t_diff 99999

	get_now_date_time

	if ("`now_date'"=="`with_date'") {
		get_time_diff, time1("`with_time'") time2("`now_time'")
		c_local t_diff `t_diff'
	}
end

program define recall_date_time

	version 7.0
	
	c_local w_date "`=substr("$RND2_LAST_QUOTA_CHECKED",1,11)'"
	c_local w_time "`=substr("$RND2_LAST_QUOTA_CHECKED",13,8)'"
end

program define get_now_date_time

	version 7.0

	local lock_date "`c(current_date)'"
	local now_time "`c(current_time)'"
	local now_date "`c(current_date)'"

	if ("`lock_date'"!="`now_date'") {
	  local now_time "`c(current_time)'"
	}

	c_local now_date "`now_date'"
	c_local now_time "`now_time'"
end

program define elapsed_seconds

	version 7.0

	if (_caller()>=10.0) {
		elapsed_seconds10
	}
	else {
		elapsed_seconds7
	}

	c_local time_diff = `time_diff'
end

program define elapsed_seconds10

	version 10.0

	get_now_date_time

	local t_current = clock("`now_date' `now_time'", "DMYhms")
	local t_last = clock("$RND2_LAST_QUOTA_CHECKED", "DMYhms")

	c_local time_diff =  floor((`t_current' - `t_last')/1000)
end

program define elapsed_seconds7

	version 7.0

	recall_date_time
	time_diff_now, with_date("`w_date'") with_time("`w_time'")

	c_local time_diff = `t_diff'
end

*** end of Stata 7 compatibility region ***

program define display_about_msg

	version 7.0

	display _n
	display as text `"{browse "http://www.random.org/":RANDOM.ORG} offers true random numbers to anyone on"' _n /*
                         */  "the Internet. The randomness comes from atmospheric" _n /*
			 */  "noise, which for many purposes is better than the" _n /*
			 */  "pseudo-random number algorithms typically used in" _n /*
			 */  "computer programs. People use RANDOM.ORG for holding" _n /*
			 */  "drawings, lotteries and sweepstakes, to drive games" _n /*
			 */  "and gambling sites, for scientific applications and" _n /*
			 */  "for art and music. The service has existed since 1998" _n /*
			 */ `"and was built and is being operated by {browse "http://www.dsg.scss.tcd.ie/Mads.Haahr":Mads Haahr} of"' _n /*
			 */ `"the {browse "http://www.scss.tcd.ie/":School of Computer Science and Statistics} at"' _n /*
			 */ `"{browse "http://www.tcd.ie/":Trinity College}, Dublin in Ireland."' _n

	display as text  "As of 01.01.2011, RANDOM.ORG has generated " as result "925.8 bln" _n /*
		         */ as text "random bits for the Internet community." _n

	display as text  "Stata module to query the true random number generator" _n /*
			 */ "at RANDOM.ORG is written by Sergiy Radyakin, Economist," _n /*
			 */ "The World Bank" _n
end


*** ===== end of file =====