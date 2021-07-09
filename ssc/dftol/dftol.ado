pr dftol, rclass sortpreserve
	version 12
	syntax varlist(max=1) [if] [in] [, Conf(numlist >0 <100 max=1) Beta(numlist >0 <100 max=1) Rlower Detail]
	capt mata mata which mm_root()
	if _rc{
		di as error "mm_root() from -moremata- is required; type -ssc install moremata- to install it"
		exit 499
	}
	local labvar: value label `varlist'
	if "`labvar'" != "" {
		di as error "`varlist' seems to be a categorical variable"
		exit 499
	}
   sort `varlist'	
	if "`conf'" == "" local conf = 95 
	if "`beta'" == "" local beta = 95
   local rodd "upper"
	if "`rlower'" != "" local rodd "lower"
	marksample touse 
	qui count if `touse'
	local n = r(N)
	if `n' == 0 error 2000
	tempname m r r1 r2 confprime lower upper
	scalar `m' = .
	qui mata: st_numscalar("`m'", find_m(`n', `conf'/100, `beta'/100))
	if int(`m') == 0 scalar `r' = 1
	else scalar `r' = int(`m')
	if !mod(`r', 2) {
		scalar `r1' = `r'/2
		scalar `r2' = `r1'
	}
	else{
		if "`rodd'" == "upper" {
			scalar `r1' = floor(`r'/2)
			scalar `r2' = `r1' + 1
		}
		else {
			scalar `r1' = ceil(`r'/2)
			scalar `r2' = `r1' - 1
		}
	}
	scalar `lower' = `r1'
	scalar `upper' = `n' - `r2' + 1
	local mprime = `r1' + `r2'
	scalar `confprime' = .
	mata: st_numscalar("`confprime'", 1 - ibeta(`n' - `mprime' + 1, `mprime', `beta'/100))
	if (`r1' == 0) | (`r2' == 0) {
		local caprodd = proper("`rodd'")
		local lim =`varlist'[``rodd'']
		di as txt "`caprodd' tolerance limit: " as res `lim'
		if "`detail'" != "" di as txt "Index of the observation defining the `rodd' tolerance limit: " as res ``rodd''
	}
	else { 
		local llim =`varlist'[`lower']
		local ulim =`varlist'[`upper']		
	   di as txt "Tolerance interval: " as res "("`llim' ", "`ulim' ")"
	   if "`detail'" != "" di as txt "Indices of the observations defining the interval: " as res `lower' as txt ", " as res `upper'
	}
	if "`detail'" != "" {
		di as txt "Number of blocks discarded: " as res `r'
		di as txt "Actual confidence level: " as res %4.3f `confprime'
	}
	return scalar actualconf = `confprime'
   return scalar removed = `r' 
	if (`upper' <= `n') {
      return scalar indexupper = `upper'
		return scalar upper = `varlist'[`upper']
	}
	if (`lower' > 0) {
      return scalar indexlower = `lower'
		return scalar lower = `varlist'[`lower']
	}
end
	
version 12
mata:
function find_m(n, conf, beta){
	rc = mm_root(x = ., &objective(), 0.1, n, 0, 1000, n, conf, beta)
	if (rc != 0) x = .
	return(x)
}
function objective(x, n, conf, beta){
	return(invibeta(n - x + 1, x, 1 - conf) - beta)
}
end
