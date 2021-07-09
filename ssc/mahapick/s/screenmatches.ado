/*
ado\screenmatches.ado  1-7-2004

This is part of a suite of programs for use with mahapick.ado.

This is to be used at the analysis phase, after all the matching and data-
assembly is completed.

This allows you to have a large pool of matches (controls), but to do analyses
on a smaller set.  For example, you may have 8 controls per treated case, but
you want to use only 3.

It is not enough to simply cut down the set to the first n control per treated
case.  What we want is, for a given set of variables, find the best n controls
per treated case that have no missing data on all the variables.

The whole point of this is that you can tweak the set of variables in the
analysis, and you don't need to redo the matching due to resulting shifts in
the "active" set of observations.

Without this capability, you may be compelled, in the matching process, to
consider what variables are to be analyzed -- limiting the control pool to
cases that are nonmissing on a given set of variables.  Subsequent tweaking
of this set would force you to either redo the matching, or to accept a
diminished set of observations in the analysis.  (Also, in the latter
situation, you might, say, end up with 3 controls for some treated cases, and
2 controls for others.)

The present program helps avoid these problems.  It allows you to ignore the
set of analysis variables at the time you create the matching.  The idea is
to get a large set of controls per treated case (call it n0) in the matching
process.  Then at analysis time, you pick a smaller number of controls per
treated case (call it n1), but for the given analysis, it is the best n1
cases per treated cases that are possible.  If n0 is sufficiently large, then
all treated cases will get the full n1 controls cases (not fewer).



IMPORTANT: this is based on the structure you get out of mahapick, using the
genfile option -- or the pickids option with appropriate stacking/reshaping.

That is, we assume a "matchnum" variable which is 0 for the treated case,
and 1, 2, 3, etc., for the controls -- where 1 is for the best match, 2 is
the next best match, and so on.





This is adapted from code in psid012\tab060.do, with certain items converted
to (required) options, rather than being hard-coded names.


*/




prog def screenmatches, sortpreserve
/*
screen a set of match cases (along with the "treated") to have at most
`nummatches' matches.  Take the first `nummatches' cases (in terms of
`matchnum') that have no missings on varlist.

Not that typically, this `nummatches' is smaller than the `nummatches'
used in mahapick.
 
*/
version 8.2
*! version 0.0.4  2-9-2006


/*
prior versions
 0.0.0  1-8-2004
 0.0.1  1-16-2004
 0.0.2  1-22-2004
 0.0.3  2-5-2006

History:
1-7-2004: began coding, adapted from part of psid012\tab060.do (identical
program found in several related psid012 do files.).
1-8-2004: finished first working version.
1-16-2004: added Verbose option.
1-22-2004: implementing summ and tab options.
 summ will calculate and summarize the min and max matchnum values for
  control cases screened in.
 tab applies only if summ is specified; will also do tabs of these min and max.

2-5-2006: Just fixed comments.
2-9-2006: Just fixed version.

*/

syntax varlist [if], gen(string) nummatches(integer) ///
 matchnum(varname)  prime_id(varname) [Verbose summ tab]

confirm new var `gen'
confirm numeric var `matchnum'
confirm numeric var `prime_id'

marksample m

tempvar out control
gen byte `out' = ~`m'
gen byte `control' = `matchnum' >0

sort `prime_id' `control' `out' `matchnum'

by `prime_id' `control': gen byte `gen' = _n<= `nummatches' & `m'
// The `m' limits this to cases that are themselves okay.

quietly by `prime_id': replace `gen' = 0 if ~`m'[1]
/* This limits this to cases where the prime case (the treated)
is okay.  This feature added 11-11-2003 in tab060.do.

*/


/* Debug stuff:
 tempvar q

 egen byte `q' = max(`out'), by(`prime_id')

 list `prime_id' `control' `matchnum' `m' `gen' if `q' , sepby(id_prime)
*/

if "`verbose'" ~= "" {

 qui count if ~`control' & `gen'
 local n_treated "`r(N)'"

 qui count if `control' & `gen'
 local n_control "`r(N)'"

 disp "screenmatches; num treated = `n_treated';  num control = `n_control'"
}

if "`summ'" ~= "" {
 /* Summarize the ranges of the matchnums taken (among controls). */
 tempvar matchnum02
 gen long `matchnum02' = `matchnum' if `control' & `gen'
 tempvar min02 max02 n1
 egen long `min02' = min(`matchnum02'), by(`prime_id')
 egen long `max02' = max(`matchnum02'), by(`prime_id')
 bysort `prime_id': gen int `n1' = _n
 disp "summ of the min and max of control matchnums screened"
 summ `min02' `max02' if `n1' == 1

 if "`tab'" ~= "" {
  disp "tabs of the min and max of control matchnums screened"
  tab `min02' if `n1' == 1
  tab `max02' if `n1' == 1
 }
}
end // screenmatches


