/*
ado\mahaselectunique.ado, began 2012oct12

David Kantor; kantor.d@att.net

*/


prog def mahaselectunique
version 8.2 /* for compatibility with other maha... programs. */
*! version 1.0.2 2012nov12

/*
Given a file that is the -genfile- output of mahapick, select a set of unique matches for the treated set.

This will -use- that file, so you need to start out empty or have non-altered content, or use the -clear- option.
The results will be written to a file using post.

*/


#delimit ;
syntax ,
	usefile(string) 
	writefile(string)
	idvar(name)
	[
	prime_id(name)
	matchnum(name)
	scorevar(name)
	replace
	clear
	nmatch(integer 1)
	seed(string)
	nostrict
	]
	;

#delimit cr
/* seed is either an integer or a seed code ("X" + 36-digit hex value (possibly limited values)). */


if "`prime_id'" == "" {
	local prime_id "_prime_id"
}

if "`matchnum'" == "" {
	local matchnum "_matchnum"
}


capture des using `"`usefile'"'
if _rc == 601{
	disp as err "could not find file `usefile'"
	exit _rc
}
else if _rc == 610 {
	disp as err "file `usefile' not in Stata format"
	exit _rc
}
else if _rc {
	disp as err "unexpected error in seeking file `usefile'"
	exit _rc
}

local varstoseek "`prime_id' `idvar' `matchnum' `scorevar'" 

foreach v of local varstoseek {
	capture des `v' using `"`usefile'"'
	if _rc == 111 {
		disp as err "could not find var `v' in `usefile'"
		exit _rc
	}
	else if _rc{
		disp as err "unexpected error in seeking var `v' in file `usefile'"
		exit _rc
	}
}


local scorevar2 "`scorevar'"
if "`scorevar'" == "" {
	local scorevar2 "_score"
	capture des `scorevar2' using `"`usefile'"'
	if _rc {
		local scorevar2
	}
}
/*
scorevar may or may not be present in the file.
`scorevar' is either user-specified or empty.
`scorevar2' is, at this point,...
	a user-specified name -- if the specified var exists in usefile, else...
	"_score", if that variable exists in usefile,
	blank, otherwise.
*/

/* disp "scorevar2 = `scorevar2'" */

if "`replace'" == "" {
	if lower(substr("`writefile'", -4, .)) ~= ".dta" {
		local suffix ".dta"
	}
	confirm new file `writefile'`suffix'
}



if "`seed'" ~= "" {
	set seed `seed'
}


/* ~~~debug~~~ disp "---strict = `strict'" */

if "`strict'" == "" {
	local restriction "if `matchnum' ==0"
}

/* ~~~~debug~~~~ disp `"----use command: use `prime_id' `matchnum' using `"`usefile'"' `restriction' , `clear'"' */
use `prime_id' `matchnum' using `"`usefile'"' `restriction' , `clear'

qui bysort `prime_id': keep if _n==1 /* no effect for properly formed files using -strict- */

drop `matchnum'
forvalues jj = 1/`nmatch' {
	tempvar t1
	gen double `t1' = uniform()
	sort `t1', stable
	tempname key`jj'
	gen long `key`jj'' = _n
	drop `t1'
}

sort `prime_id'
by `prime_id': assert _N ==1
tempfile keys
save `keys'



use `"`usefile'"' if `matchnum' >0
sort `prime_id'
qui merge `prime_id' using `keys', uniqus

if "`strict'" == "" {
	qui count if _merge==1
	if r(N) >0 {
		disp as err r(N) " non-matched records; " as text "will be dropped; alternatively use " as input "nostrict" as text " option."
		tempvar n1
		bysort `prime_id': gen int `n1' = _n
		disp "list of prime_id values unmatched -- to be dropped"
		list `prime_id' if _merge==1 & `n1' ==1, noobs
		drop if _merge==1
	}
}
else {
	assert _merge==2 | _merge==3
}

assert mi(`matchnum') == (_merge==2) /* `prime_id' had no matches in the mahapick process. */
qui replace `matchnum' = -1 if mi(`matchnum')
assert (`matchnum'<0) == (_merge==2)
drop _merge


/* adapting some code from mahapick
Use the name genfile_handle, adapted from mahapick, though the current filename is stored in writefile. */
 */

if "`scorevar2'" ~= "" {
	local scoretyp : type `scorevar2'
	local score_elt "`scoretyp' `scorevar2'"
	local score_elt2 "(`scorevar2'[\`kk'])"
	local score_elt_mis "(.)"
}

local typ1: type `idvar'
if substr("`typ1'",1,3) == "str" {
	local idvarmisval `""""'
}
else {
	local idvarmisval "."
}

tempname genfile_handle

postfile `genfile_handle' `typ1' (`prime_id' `idvar') int `matchnum' `score_elt' using `writefile', `replace'
disp as text "file `writefile' opened for posting"


tempname primeval end_group2
tempvar taken
gen byte `taken' =0

forvalues jj = 1/`nmatch' {
	sort `key`jj'' `matchnum'
	by `key`jj'' `matchnum': assert _N==1
	tempvar n end_of_group
	gen long `n' = _n
	by `key`jj'': gen long `end_of_group' = `n'[_N]
	local kk = 1
	while `kk' <= _N {
		scalar `primeval' = `prime_id'[`kk']
		scalar `end_group2' = `end_of_group'[`kk']  /* capture the value */
		while `kk' <= scalar(`end_group2') & `taken'[`kk'] {
			local `kk++'
		}
		if `kk' <= scalar(`end_group2') {
			/* must be ~`taken'[`kk'] */
			post `genfile_handle' (scalar(`primeval')) (`idvar'[`kk']) (`matchnum'[`kk']) `score_elt2'

			qui replace `taken' = 1 in `kk'
			if ~mi(`idvar'[`kk']) {
				qui replace `taken' = 1 if `idvar' == `idvar'[`kk']
			}
			local kk = scalar(`end_group2') + 1
		}
		else { /* `kk' > scalar(`end_group2') */
			post `genfile_handle' (scalar(`primeval')) (`idvarmisval') (.) `score_elt_mis'

		}
	}
	drop `n' `end_of_group'
}

postclose `genfile_handle' 
disp as text "file `writefile' closed"
end
