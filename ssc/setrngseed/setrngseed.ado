*! version 2.0.1  04oct2010

/*
	setrngseed 

	Authors:  
		Antoine Terracol, Université Paris 1, 
		Centre d'Économie de la Sorbonne

		William Gould, StataCorp

	-setrngseed- sets Stata's uniform pseudo-random-number generator's 
		seed to a value returned from http://www.random.org.

*/

program define setrngseed, rclass
	version 10

	syntax [, noSETseed Verify Query]

	/* ------------------------------------------------------------ */
					/* check syntax	*/
	if ("`query'"!="" & ("`setseed'"!="" | "`verify'"!="")) {
		di as error ///
"option query cannot be used concurrently with options nosetseed and verify" 
		exit 198
	}	



	/* ------------------------------------------------------------ */
					/* check quota	*/
	if ("`query'"!="") {
		check_quota 
		local quota=r(quota)
		return scalar quota=`quota'		
		exit
	}	

	/* ------------------------------------------------------------ */
					/* obtain real random seed	*/

	get_random_seed "`verify'"
	local value "`r(result)'"

	/* ------------------------------------------------------------ */
					/* set seed			*/

	if ("`setseed'"=="") {
		set seed `value'
		di as txt "(random-number seed set to `value')"
	}
	else {
		di as txt "random.org returns `value' (seed not set)"
	}

	/* ------------------------------------------------------------ */

	return scalar seed = `value'
end


program check_quota, rclass
	tempfile rndquota
	tempname myquota	

	local site "http://www.random.org"
	display as txt "(contacting `site', checking quota)"
	qui copy "`site'/quota/?format=plain" "`rndquota'"

	file open `myquota' using "`rndquota'", read text
	file read `myquota' quota
	file close `myquota'	

	local quotanum=floor(`quota'/31)	
	di as txt ///
	"current IP's 24-hour quota is `quota' bits, about `quotanum' random seeds" 
	return scalar quota=`quota'
end	

program get_random_seed, rclass
	args check 

	tempfile rndseed
	tempname myseed

	/* ------------------------------------------------------------ */
					/* obtain random number(s)	*/

	local min  -1000000000
	local max   1000000000
	local toadd 1000000000
	
	local num = cond("`check'"=="", 1, 2)

	local site "http://www.random.org"
	local args "/integers/?num=`num'&min=`min'&max=`max'"
	local args "`args'&col=1&base=10&format=plain&rnd=new"

	display as txt "(contacting `site')"
	qui copy "`site'`args'" "`rndseed'"

	file open `myseed' using "`rndseed'", read text
	file read `myseed' value1
	if ("`check'" != "") {
		file read `myseed' value2
	}
	file close `myseed'

	/* ------------------------------------------------------------ */
					/* check results		*/

	check_integer_result `"`value1'"'
	local value1 = `value1' + `toadd'

	if ("`check'" == "") {
		return local result `value1'
		exit
	}

	/* ------------------------------------------------------------ */
		/* check second value, and compare with the first       */

	check_integer_result `"`value2'"'
	local value2 = `value2' + `toadd'
	if (`value1' != `value2') {
		return local result `value1'
		exit
	}

	di as err "{p 0 4 2}"
	di as err "random.org behaved unexpectedly{break}"
	di as err "random.org returned the same"
	di as err "value twice, so the values are not"
	di as err "random or a very unlikely event occured."
	di as err "{p_end}"
	exit 674
end


program check_integer_result
	args value

	capture confirm integer number `value'
	if (_rc) {
		di as err "{p 0 4 2}"
		di as err "random.org behaved unexpectedly{break}"
		di as err `"value returned was "`value'", which"'
		di as err "was not an integer."
		di as err "{p_end}"
		exit 674
	}
end
