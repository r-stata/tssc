
/* elapse.ado   10/24/97 */

program define elapse 		/* start_time  name_of_operation (optional)*/

	version 5.0
	local hdiff = real(substr("$S_TIME",1,2)) - real(substr("`1'",1,2))
	local mdiff = real(substr("$S_TIME",4,2)) - real(substr("`1'",4,2))
	local sdiff = real(substr("$S_TIME",7,2)) - real(substr("`1'",7,2))
	if `sdiff' < 0 {
		local sdiff = `sdiff' + 60
		local mdiff = `mdiff' -1
	}
	if `mdiff' < 0  {
		local mdiff = `mdiff' + 60
		local hdiff = `hdiff' -1
	}
	if `hdiff' < 0 {
		local hdiff = `hdiff' + 24
	}
	local selap = 10000 * `hdiff' + 100 * `mdiff' + `sdiff'
	global S_elap = `selap'

	local hdiff = string(`hdiff')
	local mdiff = string(`mdiff')
	local sdiff = string(`sdiff')

	if "`2'" == "" {
		if `hdiff' > 0 {
			di in ye "Elapsed time was " in wh "`hdiff'" _c
			if `hdiff' > 1 {di in ye " hours, " _c}
			else { di in ye " hour, " _c}  
			di in wh "`mdiff'" _c
			if `mdiff' > 1 {di in ye " minutes, " _c}
			else {di in ye " minute, " _c}
			di  in wh "`sdiff'" _c
			if `sdiff' > 1 {di in ye " seconds."}
			else {di in ye " second."}
	   	}
		else if `mdiff' > 0 {
			di in ye "Elapsed time was " in wh "`mdiff'" _c
			if `mdiff' > 1 {di in ye " minutes, " _c}
			else {di in ye " minute, " _c}
			di  in wh "`sdiff'" _c
			if `sdiff' > 1 {di in ye " seconds."}
			else {di in ye " second."}
		}
		else {
			di in ye "Elapsed time was " in wh "`sdiff'" _c
			if `sdiff' > 1 {di in ye " seconds."}
			else {di in ye " second."}
		}
	}
	else {
		if `hdiff' > 0 {
			di in ye "`2' took " in wh "`hdiff'" _c
			if `hdiff' > 1 {di in ye " hours, " _c}
			else { di in ye " hour, " _c}  
			di in wh "`mdiff'" _c
			if `mdiff' > 1 {di in ye " minutes, " _c}
			else {di in ye " minute, " _c}
			di  in wh "`sdiff'" _c
			if `sdiff' > 1 {di in ye " seconds."}
			else {di in ye " second."}
	   	}
		else if `mdiff' > 0 {
			di in ye "`2' took " in wh "`mdiff'" _c
			if `mdiff' > 1 {di in ye " minutes, " _c}
			else {di in ye " minute, " _c}
			di  in wh "`sdiff'" _c
			if `sdiff' > 1 {di in ye " seconds."}
			else {di in ye " second."}
		}
		else {
			di in ye "`2' took " in wh "`sdiff'" _c
			if `sdiff' > 1 {di in ye " seconds."}
			else {di in ye " second."}
		}
	}

end
