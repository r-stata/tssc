quietly {
	* Parse files
	local dofile = substr("`1'", 2, length("`1'")-2)
	
	* Parse stop/nostop option
	if "`4'" == "nostop" local nostop ", nostop"
	local quit "`5'"
	
	* Log for user
	log using `"`3'/iteration`2'.log"', replace name(userLog)
	noisily di as text "Executing following dofile: " as result "`dofile' " `2' "`nostop'" _newline "-------------------------------------------------------------------------------"
	sleep 3000
	
	* Execute dofile
	tempfile dofileCopy
	copy `"`dofile'"' `dofileCopy'
	cap noisily do `dofileCopy' `2' `nostop'
	local rc = _rc
	
	* Parse if it went successfully
	cap log open userLog
	noisily di "-------------------------------------------------------------------------------" _newline as text "Execution report: " _continue
	if `rc' == 0 noisily di "Success"
	else noisily di "Failure"
	
	* Close log
	cap log close userLog
	
	if "`quit'" != "noquit" {
		clear
		exit, STATA
	}
}
