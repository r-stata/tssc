
/*
stackids.ado
12-9-2003

This is intended for use in conjunction with mahapick.ado.
This allows you to stack the id variables into a long-shaped dataset.
This is somewhat like -stack-, but with some of the particulars taken care
of for you.  (This is like rehape, too, but, as with -stack- the var names
are not constrained to have certain suffixes.)

This is adapted from code within psid012\prep586d.do  (or prep586 or prep585b,
etc...). Had this present program been written earlier, then those named
do-files would have made use of this.


Given that you have your matches -- the product of running -mahapick-,
you now want to put the results in a lon-shaped dataset.

Possibly, you will later attach content data to this set.


12-15-2003: finished main development work.


2-6-2006:  Note that mahapick now has two ways for recording the results.
The original, pickids(), records results in wide form.  The newer,
genfile(), puts results into long form.  genfile() is preferable; pickids
is kept for backward-compatibility.  The present program converts from the
wide to long form.

If you use genfile(), then you will not need this.

2-6-2006: Changing some options from string to name; then we don't need
to have confirm_new_var sub-program.  (It has been moved out to its own
file, but may not be needed elsewhere as well.)

2-8-2006: Removing the -confirm new var- commands; it is really okay to
recycle names.

*/



program define stackids
*! version 1.0.2  2-8-2006

syntax varlist , idvar(name) idprimevar(name) matchnumvar(name) clear ///
 [keepwideids]

/* Note that keepwideids was originally and erroneously named keeplongids.
Fixed on 2-6-2006.
*/


version 8.2
/*--->
confirm new var `idvar'
confirm new var `idprimevar'
confirm new var `matchnumvar'
<---*/

/*
The "primary" id is the first one in the list.
*/
tokenize `varlist'
local primeid `1'
mac shift
local othervars "`*'"
local typ1: type `primeid'
if substr("`typ1'", 1, 3) == "str" {
 local mis ""
}
else {
 local mis "."
}




tempvar seq000
gen long `seq000' = _n  // helps form key -- in case `idvar' is not a key.



if "`keepwideids'" ~= "" {
 /* keep the long form of the ids -- to merge onto the treated cases. */
 preserve
 keep `varlist' `seq000'
 sort `primeid' `seq000'
 quietly by `primeid' `seq000': assert _n==1
 ren `primeid' `idprimevar' // for the merge
 tempfile idsonly
 save `idsonly'

 restore
}



/* For the -stack-, we need to do one special thing: carry the "primamry"
id with each id -- so as to retain the correspondence.

Also carry `seq000' -- just in case we need it to make a key.
*/

local stackvars
foreach var of local varlist {
 local stackvars "`stackvars' `var' `primeid' `seq000'"
}


stack `stackvars', into(`idvar' `idprimevar' `seq000') clear

gen int `matchnumvar' = _stack -1
label var `matchnumvar' "match number (0=treated)"
drop _stack


label var `idprimevar' "id of corresponding treated case"


assert `idprimevar' == `idvar' if `matchnumvar'==0
/* -- and actually, if the data came from mahapick, you can expect
(I believe), (`idprimevar' == `idvar') == (`matchnumvar'==0).
*/



if "`keepwideids'" ~= "" {
 sort `idprimevar' `seq000'
 merge `idprimevar' `seq000' using `idsonly', uniqusing
 assert _merge==3
 drop _merge
 foreach var of local othervars {
  replace `var' = `mis' if `matchnumvar'~=0
 }
}


sort `idprimevar' `matchnumvar'

/* Note that if `idvar' was a key for the original set, then
`idprimevar' `matchnumvar' is now a key, and most likely so is
`idprimevar' `idvar' (but not necessarily).
*/

end

/* end of stackids.ado */
