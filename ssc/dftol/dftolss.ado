pr dftolss, rclass
	version 12
	syntax [, Conf(numlist >0 <100 max=1) Beta(numlist >0 <100 max=1) r(numlist integer >=1 max=1)]
	capt mata mata which mm_root()
	if _rc {
		di as error "mm_root) from -moremata- is required; type -ssc install moremata- to install it"
		exit 499
	}
	if "`conf'" == "" local conf = 95 
	if "`beta'" == "" local beta = 95
   if "`r'" == "" local r = 2 
   scalar n = .
	qui mata: st_numscalar("n", find_n(`conf'/100, `beta'/100, `r'))
	di as txt "n = " as res ceil(n)
	return scalar n = ceil(n)
end
	
version 12
mata:
function find_n(conf, beta, r){
	rc = mm_root(x = ., &objective(), r, 1e6, 0, 1000, conf, beta, r)
	if (rc != 0) x = .
	return(x)
}
function objective(x, conf, beta, r){
	return(1 - conf - ibeta(x - r + 1, r, beta))
}
end
