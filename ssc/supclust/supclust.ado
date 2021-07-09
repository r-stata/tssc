*! version 1.0.6, Ben Jann, 16mar2006
program define supclust, sortpreserve rclass
	version 9.0
	syntax varlist(min=2) [if] [in], Generate(name) [ /*
	*/ ALTernating /*
	*/ Missing /*
	*/ mata    /* undocumented: force usage of the mata algorithm
	*/ ]
	confirm new v `generate'
	if "`missing'"=="" marksample touse, strok
	else marksample touse, nov
	qui count if `touse'
	if r(N) == 0 error 2000

	tempvar id
	if "`alternating'"!="" | "`mata'"!="" {
		confirm numeric v `varlist'
		mata: _traceclusters("`varlist'", "`id'", "`touse'", /*
		*/ "`_sortindex'", "`alternating'")
	}
	else {
		qui _traceclusters "`varlist'" "`id'" "`touse'"
	}

	sort `id'
	qui gen long `generate' = `id'!=`id'[_n-1] if `id'<.
	qui replace `generate' = sum(`generate') if `id'<.

	su `generate', meanonly
	di as txt r(max) " clusters in " r(N) " observations"
	return scalar N_clust = r(max)
	return scalar N = r(N)
end

program define _traceclusters
//note: _traceclusters, using standard stata commands, is faster (and uses
//less memory) than the mata function below; however, it cannot be used
//with the -alternating- option
	args varlist id touse
	sort `:word 1 of `varlist''
	qui gen long `id' = _n if `touse'
	local nvar: word count `varlist'
	tempvar test
	local more 1
	local null 0
	while `more' {
		foreach var of local varlist {
			bys `var' (`id'): /*
			*/ gen long `test' = cond(missing(`var'),`id',`id'[1]) if `touse'
			capt assert `test'==`id'
			if _rc==0 local null = `null' + 1
			else local null 0
			drop `id'
			rename `test' `id'
			if `null' == `nvar' {
				local more 0
				break
			}
		}
	}
end

version 9.0
mata:
void _traceclusters(varlist, id, touse, index, alt)
{
	real matrix X
	real scalar more
	real scalar changed
	real scalar nochange
	real scalar i
	real scalar j
	real scalar k
	real scalar r

	varlist = tokens(varlist)
	stata("sort "+varlist[1])
	pragma unset X
	st_view(X, ., touse, touse)
	r = rows(X)
	(void) st_addvar("long",id)
	st_store(., id, touse, (1::r))
	stata("sort "+index)
	X = st_data(., (index, id, varlist), touse)
	if ( alt != "" ) {
		for (j=4; j<=cols(X); j++) {
			i = j
			for (k=1; k<cols(varlist); k++) {
				i = (i , (j+k>cols(X) ? j+k-cols(X)+2 : j+k))
			}
			X = X \ ( J(r,1,.), X[(1::r), (2, i)])
		}
	}
	more = 1
	nochange = 0
	while ( more ) {
		for (j=3; j<=cols(X); j++) {
			changed = 0
			_sort(X,(j,2))
			for (i=2; i<=rows(X); i++) {
				if ( X[i,j]==X[i-1,j] & X[i,j]<. & X[i,2]!=X[i-1,2] ) {
					X[i,2] = X[i-1,2]
					changed = 1
				}
			}
			if ( changed ) nochange = 0
			else nochange++
			if ( nochange==cols(varlist) ) {
				more = 0
				break
			}
		}
	}
	_sort(X, (1))
	st_store(X[1::r,1], id, X[1::r,2])
}
end
