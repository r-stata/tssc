/*
ado\mahapick.ado
David Kantor, kantor.d@att.net (formerly dkantor@jhu.edu)


Initially developed at The Institute for Policy Studies,
Johns Hopkins University


Began 4-4-2003



This is to perform a mahalanobis selection.
See mahascore.ado for the score generation.

*/

*! version 1.2.1 2012feb8
/*
prior  1.2.0 3-31-2008 (fix comments, 4-2-2008)
Prior 1.1.12 1-24-2006
*/

/*
Revisions

5-9-2003: Making the variance to be calculated on the treated set -- not on
the whole set.  There are corresponding changes to mahascore and variancemat.

9-9-2003: multiple picks.

We do stable sorts, so as to have consistent results whenever there are
ambiguous choices.  You may want to do a pre-sort in order to make this
truly consistent.

9-24-2003: accomodate string id vars.  (Some additional code needed in the use
of the -clear- option. Otherwise, this already allowed for string id vars.)

11-7-2003: remove the treated() option from the call to mahascore; accomodates
a change to mahascore.

11-21-2003: adding the -common- option [removed 3-26-2008 -- but in the new
scheme, it is always "common", based on how covariancemat works];
simply passes this on to variancemat.
The effect is to limit the variace calculations to those cases that are
nonmissing on all the covariates (varlist).

Displaying the varmat; cancelling the use of disp_var.

12-3-2003: Implementing -omitmiszer- option to drop vars from varlist if
variance is missing or zero.  [removed 3-26-2008]

Also, some improvements in the reporting of failures by mahapicksome.
Also, in mahapicksome, if there are no non-treated non-ref obs, it used to
cause an error; now it just continues, with no matches assigned.

Also, putting in a preserve/restore that applies to sliceby.  A -fast- option
goes with that.


12-11-2003: putting in the option to generate a new file (using -post-) in
long form; the option is -genfile-.  This is an alternative to -pickids-.
Note that pickids makes a wide data set of match ids.

Consequently, pickids now becomes optional.
NEW options: genfile replace prime_id matchnum nummatches full

1-6-2004: ??

2-15-2005: using idvarmisval where -clear- is implemented; moving the setting
of idvarmisval to an earlier point.
Also, making it mandatory that pickids components have the same type as
idvar.

Also, making clear valid only if pickids is specified.

2-16-2005: continuing.

2-17-2005: correcting the detection of multiple score values at end of 
mahapicksome.

4-25-2005 & 4-26-2005: adding the -score-, -scorevar-, and -all- options.

Also, switching the order of vars in the genfile post; putting prime_id first.
(Has no substantive effect.)


5-23-2005 ??

1-24-2006: just fixing some comments.

3-26-2008: use a new version of mahascore. It generates a true Mahalanobis
measure -- not the normalized Euclidean, as was done previously.
(But see euclidean option.)

Call covariancemat instead of variancemat.
Cancel the common option; it is now always "common".
Cancel the omitmiszer option.
Put in a euclidean option -- equivalent to old behavior.
Added weights -- for the covariance computation.
Added option unsquared.
Added option float.
(But note that `float' is NOT passed to mahascore, as it is not necessary to
make that limitation there, and it may enable more ties.  Instead, just let
the score variable (in genfile) be float; that's where it has a real effect.)

Using a tempname for the genfile handle; improves break behavior.
Fixed bug in under-reporting of equal scores.


2012feb8: enhanced handling of errors from covariancemat.


*/


prog def mahapick
version 8.2

#delimit ;
syntax varlist(numeric) [aw fw iw pw],
 idvar(varname) treated(varname numeric)
 [
 pickids(varlist)
 genfile(string) prime_id(name) replace
 matchnum(name) scorevar(name) nummatches(integer 1) full
 matchon(varlist) sliceby(varlist) clear fast
 score all
 UNSQuared EUCLidean float
 DISPlay(string)
 noCOVTRLIMitation
 ]
 ;
#delimit cr



/*
For each treated item, form the score and then pick the lowest scored
untreated case.

This is matching with replacement.


Note that the score is distinct for each treated case.
(You _could_ have a var for each, but that would make for MANY vars.
Actually, it might not be a bad thing, but I am not doing it for now.

P.S., under the genfile and score options, you can save the scores in LONG
form.  And with -all-, you can get all possible matches and the scores
)

The -scorevar- option is what to name the score variable in the -score-
suboption of -genfile-.  It is not exactly the same as the scorevar option
to mahapicksome (which is passed as a tempvar), though they are effectively
the same entity.




See mahascore.ado

We expect that the pickids are of the same type as idvar.

Originally pickid was passthru, but now (4-7-2003) I want to check to see that
it starts out as missing -- or clear it.  Adding the clear option.

4-14-2003: sliceby is implemented.
Note that the sorting seems to be the big time user-upper.  If you could
partition the set by some subset of the matchon values (but use the
already-made scores) then this might speed-up considerably.
This is what sliceby does.

*/



capture assert `treated'==0 | `treated'==1
if _rc ~=0 {
  disp as error "treated must be valued {0, 1}"
  exit 198
}

if "`covtrlimitation'" =="" {
 local iftreated_for_cov "if `treated'"
}


if "`pickids'" == "" & "`genfile'" == "" {
 disp as error "You must use -genfile- or -pickids- (or both)."
 exit 198
}

if "`pickids'" == "" & "`clear'" ~= "" {
 disp as error "-clear- not valid without -pickids-"
 exit 198
}





local typ1: type `idvar'
if substr("`typ1'",1,3) == "str" {
 local idvarmisval `""""'
}
else {
 local idvarmisval "."
}



if "`pickids'" ~= "" {

 foreach var of local pickids {
  local typ2: type `var'
  capture assert "`typ2'" == "`typ1'"
  if _rc {
   disp as error "var `var' of pickids is not the same type as idvar `idvar'"
   exit 198
  }


  if "`clear'" == "" { // -clear- was NOT specified
   capture assert mi(`var')
   if _rc ~= 0 {
     disp as error "pickid (`var') must be all missing to start, or use the " as input "clear" as error " option."
     exit 198
   }
  }
  else {  // -clear- WAS specified

   qui replace `var' = `idvarmisval'

  }
 }
}




if "`genfile'" ~= "" {

 if "`prime_id'" == "" {
  local prime_id "_prime_id"
 }

 if "`matchnum'" == "" {
  local matchnum "_matchnum"
 }

 if "`scorevar'" == "" {
  local scorevar "_score"
 }

 /* We could assure that the original `scorevar' is specified only if -score-
 is specified.  Let's not get that picky.
 */


 assert_distinct prime_id matchnum `prime_id' `matchnum'
 assert_distinct prime_id scorevar `prime_id' `scorevar'
 assert_distinct matchnum scorevar `matchnum' `scorevar'




 if "`replace'" == "" {
  confirm new file `genfile'
 }
 else {
  capture confirm new file `genfile'
   local rc1 = _rc
  capture confirm file `genfile'
   local rc2 = _rc
  if `rc1' & `rc2' {
    disp as error "filespec for genfile invalid: `genfile'"
    exit 198
  }
 }

 if "`score'" ~= "" {
  local scoretyp "double"
  if "`float'" ~= "" {
   local scoretyp "float"
  } 

  local score_elt "`scoretyp' `scorevar'"
 }

 tempname genfile_handle

 postfile `genfile_handle' `typ1' (`prime_id' `idvar') int `matchnum' `score_elt' using `genfile', `replace'
 disp as text "file `genfile' opened for posting"
}
else { // no genfile
 local x_without_genfile 0
 if "`prime_id'" ~= "" {
  disp as error "prime_id invalid without genfile"
  local x_without_genfile 1
 }
 if "`matchnum'" ~= "" {
  disp as error "matchnum invalid without genfile"
  local x_without_genfile 1
 }
 if "`replace'" ~= "" {
  disp as error "replace invalid without genfile"
  local x_without_genfile 1
 }
 if "`full'" ~= "" {
  disp as error "full invalid without genfile"
  local x_without_genfile 1
 }
 if "`score'" ~= "" {
  disp as error "score invalid without genfile"
  local x_without_genfile 1
 }
 if "`scorevar'" ~= "" {
  disp as error "scorevar invalid without genfile"
  local x_without_genfile 1
 }
 if "`all'" ~= "" {
  disp as error "all invalid without genfile"
  local x_without_genfile 1
 }

 if `nummatches' > 1 {
  /* We don't test for "`nummatches'" ~= "" because it is always present.
  That is because it is an optional integer, and thus must have a default
  value.  This is a quirk of stata syntax.
  Thus, given this code, you can type nummatches(1) without genfile -- and
  get away with it.
  */

  disp as error "nummatches invalid without genfile"
  local x_without_genfile 1
 }

 if `x_without_genfile' {
  exit 198
 }

}




quietly count if `treated'
local Ntreated = r(N)

disp as text "mahapick called; num treated: `Ntreated'"
if "`sliceby'" ~="" {
 disp as text "sliceby = `sliceby'"
}
else {
 disp as text "sliceby not specified"
}


if index("`display'", "summ") {
 disp _new as text "summary of covars for the treated cases:"
 disp as text "number of treated cases: `Ntreated'"
 sum `varlist' [`weight' `exp'] if `treated', sep(0)
}



/* Get an inverse covariance matrix; adapt some code from mahascores. */

/* covariancemat is an ado by d.k. */
tempname cov invcov
capture covariancemat `varlist' `iftreated_for_cov' [`weight' `exp'], covarmat(`cov')
if _rc {
	disp as err "error from covariancemat"
	error _rc
}


if "`euclidean'" ~= "" {
 /* -euclidean- option means to zero the off-diagonal elements.  It should
 be equivalent to the behavior of the old mahascore or mahapick.
 This needs to be done BEFORE the inverting.
 The resulting inverted matrix should be just the reciprocals in the diagonal.
 */

 local crows = rowsof(`cov')
 // local ccols = colsof(`cov') -- should equal crows
 forvalues j = 2 / `crows' {
  forvalues k = 1 / `=`j'-1' {
   mat `cov'[`j', `k'] = 0
   mat `cov'[`k', `j'] = 0
  }
 }
}

if index("`display'", "covar") {
 disp _new as text "covariance matrix:"
 mat list `cov'
}


/* disp "begin inv(cov)" */
mat `invcov' = inv(`cov')
/* -- you may be able to do invsym(`cov')
But there are pitfalls, if `cov' is not positive-definite.
(It ought to be at least positive-semidefinite.)
But the most general choice is inv().
*/
/* disp "end inv(cov)" */

/* End of segment adapted from mahascores. */


/*
The use of covariancemat speeds up mahascore.
But also note that variancemat is called for the whole set of treated obs.
This is done so as to get a covariance matrix for the whole set -- not for
each slice separately (if `sliceby' is used), which is what you would get if
this weren't here.
*/


if index("`display'", "invcov") {
 disp _new as text "invcovariance matrix:"
 mat list `invcov'
}





/*
Form groups by `sliceby', if it exists. This is supposed to speed up the
process, as the big time-waster is the sorting that occurs on each pick.

sliceby, generally speaking, is like extra matchon vars.  BUT to avoid
confusion, we will require that it be a subset of matchon.

(Generally, the actual set of vars on which we are constrained to match,
is the  sliceby _union_ matchon.)
*/

if "`sliceby'" ~="" {
 if "`matchon'" == "" {
  disp as err "You must specify matchon with sliceby"
  exit 198
 }
 foreach var of local sliceby {
  if ~index("`matchon'", "`var'") {
   disp as error "sliceby must be a subset of matchon"
   exit 198
  }
 }

 /* As I mentioned, it is not functionally necessary for sliceby to be a
 subset of matcho.  I just think it makes for clearer syntax.
 */


 tempvar group1
 egen long `group1' = group(`sliceby'), mis  // note: egen is sortpreserve
 sum `group1', meanonly
 local numslices = r(max)


 if "`fast'" == "" {
  preserve
 }


 tempfile base1
 save `base1'

 /* Note: here's where it will help if the file is reduced to only vars that
 are necessary.
 */

 disp as text "numslices = " as res "`numslices'"

 disp _new "---- sliceby has been specified"


 forvalues fileno = 1 / `numslices' {

  use  if `group1' == `fileno' using `base1'

  quietly count
  local N1 "`r(N)'"
  quietly count if `treated'
  local Ntr "`r(N)'"
  /* Note: Ntr is the count of treated cases in the present slice; there is
  also Ntreated, the count of the treated cases in the full set.
  */

  disp _new as text " processing slice " as res "`fileno'" as text "; N=" as res "`N1'" as text "; treated=" as res "`Ntr'"
  mahapick_from_slice `varlist', idvar(`idvar') treated(`treated') ///
   pickids(`pickids') ///
   postfilehandle(`genfile_handle') ///
   matchon(`matchon') invcovarmat(`invcov') ///
   genfile(`genfile') nummatches(`nummatches') `full' `score' `all' ///
  `unsquared'

  tempfile t_`fileno'
  save `t_`fileno''
 }


 drop _all
 forvalues fileno = 1 / `numslices' {
  if `fileno' ==1 {
   use `t_`fileno''
  }
  else {
   append using `t_`fileno''
  }
 }


 if "`fast'" == "" {
  restore, not
 }

}
else {
 // sliceby was not specified.

 disp as text _new "---- sliceby was not specified"
 mahapick_from_slice `varlist', idvar(`idvar') treated(`treated') ///
  pickids(`pickids') ///
  postfilehandle(`genfile_handle') ///
  matchon(`matchon') invcovarmat(`invcov') ///
  genfile(`genfile') nummatches(`nummatches') `full' `score' `all' ///
  `unsquared'

/*
Note that this could have been programmed as a degenerate case of the slices
-- with just one slice.  It would have been simple code, and it is tempting to
do that.  But it would imply it being saved and re-used for no good reason.
(But maybe that could be programmed around.  Something to consider.)
*/

}



if "`genfile'" ~= "" {
 postclose `genfile_handle'
 disp as text "file `genfile' closed"
}


end //mahapick





prog def mahapick_from_slice
/* Pick from the current slice of the file. */
version 8.2

#delimit ;
syntax varlist, idvar(passthru) treated(varname) invcovarmat(passthru)
 [
 pickids(passthru) matchon(passthru)
 genfile(passthru) nummatches(passthru) full all
 postfilehandle(passthru)
 score
 UNSQuared /* float */
 ]
 ;
#delimit cr


tempvar not_treated
gen byte `not_treated' = ~`treated'

tempvar score1
sort `not_treated', stable


quietly count if `treated'
local Ntreated = r(N)



forvalues n1 = 1 / `Ntreated' {

 mahascore `varlist', refobs(`n1') gen(`score1') `invcovarmat' ///
  `unsquared' /* `float' */
 /* treated(`treated') */

 // sum `score1'

 mahapicksome, `idvar' refobs(`n1') treated(`treated') scorevar(`score1') ///
  `matchon' `pickids' `genfile' `nummatches' `full' `score' `all' `postfilehandle'

 // mahapicksome is sortpreserve; so don't worry about the sort order.


 drop `score1'
 // disp "time: $S_TIME"
}




end // mahapick_from_slice






prog def mahapicksome, sortpreserve
/* This used to be mahapick1, but I am adapting it to pick several matches. */
version 8.2

#delimit ;
syntax , idvar(varname) refobs(integer) treated(varname)
 scorevar(varname)
 [
 pickids(varlist)
 matchon(varlist)
 genfile(string) nummatches(integer 1) full all
 postfilehandle(name)
 score
 ]
 ;

#delimit cr

/*
Given a scoring, select an observation to match a given refobs. Later
(9-9-2003), this was expanded to possibly multiple observations -- as many as
there are variables in `pickids'.

This does matching WITH REPLACEMENT.  There is no guarantee that replicated
selections won't be made.  But with a large set to choose from, you generally
don't get too much replication.


If multiple equal-scored items are found, the first is picked.
I have made all the sorting stable, so, if there are any such cases, the
results will be consistent, provided that the initial sort order is
consistent.


This will sort; but will implicity restore order (sortpreserve).
That sortpreserve is important.  The calling program needs to have the same
order after the return.

If matchon is specified, then the matching is constrained to cases that match
on these vars.  Best if they are integer-valued.

Note that the sorting seems to be the big time waster.
Thus, this is improved when the calling program slices up the data into
smaller pieces.

If the score is missing on the selected item, then return missing; i.e., do
not select this one; there is no basis for choosing it.  This is a change as
of 4-18-2003.  Previously we did issue a warning, but also returned the
selected case.

9-9-2003: Previously, this was rclass, and returned the result in r(pick); the
calling program then set the pickid.  But now, I am making this do the
setting of pickid.  To do this, we needed to set up a pickid option (required).

One fault with the old system: the pickid must be numeric.  I believe that now,
this will work on any data type for the pickids.

Part of this change is to place the refobs into position 1 in the sort.  Thus,
all pickid values are loaded into [1].

Making pickid a varlist rather than a varname; i.e., it can have several vars.
Thus renaming it to pickids.

Note that the vars in pickids should be all of the same type, which should be
the same as that of idvar.

*/

disp "mahapicksome called; refobs= " as res "`refobs'" as text "; id (`idvar') = " %12.0f as res `idvar'[`refobs']


capture assert `refobs' >=1 & `refobs' <= _N
if _rc ~=0 {
  disp as error "refobs must be in the range 1 .. _N"
  exit 198
}


capture confirm numeric var `treated'
if _rc ~=0 {
  disp as error "treated must be a numeric var"
  exit 198
}

capture assert `treated'==0 | `treated'==1
if _rc ~=0 {
  disp as error "treated must be valued {0, 1}"
  exit 198
}

capture assert `treated'[`refobs']
if _rc ~=0 {
  disp as error "Warning: refobs `refobs' is not treated."
  // but this is not fatal
}

if index("`matchon'", "`treated'") {
  disp as error "treated(`treated') may not be part of the matchon vars."
  exit 198
}




tempvar is_refobs not_refobs
gen byte `is_refobs' = _n == `refobs'
quietly count if `is_refobs'
assert r(N) ==1

gen byte `not_refobs' = ~`is_refobs'




tempvar is_treated_or_ref
gen byte `is_treated_or_ref' = `treated' | `is_refobs' 
// We expect, usually, but do not require, that the ref is treated.

tempvar not_treated_or_ref
gen byte `not_treated_or_ref' = ~`is_treated_or_ref'

quietly count if `is_treated_or_ref'
local k1 = r(N) + 1
drop `is_treated_or_ref'

if `k1' > _N {
 disp as error "no non-treated non-ref obs; no matches to be made"
 exit
 /* formerly exit 198, but now (12-3-2003) just exit and continue, not an
  error; but no matches will be made.
 */
}


tempvar matchok  not_matchok
gen byte `matchok' = 1

foreach var of local matchon {
 quietly replace `matchok' = `matchok' & (`var' == `var'[`refobs'])
}

gen byte `not_matchok' = ~`matchok'


sort  `not_treated_or_ref' `not_refobs' `not_matchok' `scorevar', stable
/*
That could have been done with gsort -- eliminating the confusing use of the
"not_..." variables, but gsort doesn't have -stable-.
*/

assert `is_refobs'[1]
/*
 -- that means that, the refobs will land in place 1. (Remember
that only one obs is `is_refobs'.)  This will be useful in the following,
where we replace something -in 1-.

We could have do replace ... if `is_refobs', but the other is more efficient,
especially if we will be doing multiple picks, as we plan to do later.
*/
drop `is_refobs'


local num_pickids "0"


if "`pickids'" ~= "" {

 local d1 "0"
 local nmiss "0"
 local notokay "0"


 foreach var of local pickids {
  local ++num_pickids

  capture assert mi(`var'[1])
  if _rc ~=0 {
   disp as error "pickid (`var') must be missing in refobs (`refobs')"
   exit 198
  }
  local k2 = `k1'+`d1'

  if `k2' <= _N & `matchok'[`k2'] {

   if mi(`scorevar'[`k2']) {
    local ++nmiss
    local pickidscoremis "`pickidscoremis' `var'"
   }
   else {
    quietly replace `var' = `idvar'[`k2'] in 1
   }
  }
  else {
   local ++notokay
   local pickidnotokay "`pickidnotokay' `var'"
  }
 local ++d1
 }


 if `nmiss' >0 {
  disp as error "Warning: distance measure missing for `nmiss' of the pickids:"
  disp as error " `pickidscoremis'"
 }

 if `notokay' >0 {
  disp as error "Warning: no matching obs found for `notokay' of the pickids."
  disp as error " `pickidnotokay'"
  /* -- that refers to a lack of qualified match candidates (possibly limited
  by the use of -matchon-).
  */
 }
}


if "`genfile'" ~= "" {

 local nmiss "0"
 local notokay "0"

 local typ1: type `idvar'
 if substr("`typ1'",1,3) == "str" {
  local idvarmisval `""""'
 }
 else {
  local idvarmisval "."
 }


 if "`score'" ~= "" {
  local score_elt "(`scorevar'[1])"  // ought to be 0
 }

 post `postfilehandle' (`idvar'[1])  (`idvar'[1]) (0) `score_elt'

 if "`all'" ~= "" {  // take ALL possible matches
  count if `matchok' & `not_treated_or_ref'
  local nummatches = max(`nummatches', r(N))
  //-- replace it with the actual number of available matches, if larger.

 }

 forvalues j1 = 1 / `nummatches' {

  local k2 = `k1'+`j1' - 1

  if ("`full'" == "") & (`k2' > _N) {
   continue, break
  }

  local ok_to_post 0

  if "`score'" ~= "" {
   local score_elt "(`scorevar'[`k2'])"
  }

  if `k2' <= _N & `matchok'[`k2'] {

   if mi(`scorevar'[`k2']) {
    local ++nmiss
   }
   else {
    local ok_to_post 1
   }
  }
  else {
   local ++notokay
   if "`score'" ~= "" {
    local score_elt "(.)"  // note 1
   }
  }

  if `ok_to_post' {
   post `postfilehandle'  (`idvar'[1]) (`idvar'[`k2']) (`j1') `score_elt'
  }
  else if "`full'" ~= "" {
   post `postfilehandle'  (`idvar'[1]) (`idvarmisval') (`j1') `score_elt' // note 2
  }

 }

 if `nmiss' >0 {
  disp as error "Warning: distance measure missing for `nmiss' candidates"
 }

 if `notokay' >0 {
  disp as error "Warning: no matching obs found for `notokay' of the nummatches"
  /* -- that refers to a lack of qualified match candidates (possibly limited
  by the use of -matchon-).
  */
 }

}

/*
Note 1: Give a missing score value -- in case we have
~`ok_to_post' and "`full'" ~= "" (and "`score'" ~= "").

Then, if `k2' <= _N & ~`matchok'[`k2'], then
the scores may well exist, but they are meaningless, in that they refer to
invalidated matches.  And the scores may likely be less than those among the
valid matches.  (I.e., the scores increas as you go down the list of ok
matches; but once you go past the `matchok' segment, the scores may restart
at a lower value.

Of course, if `k2' > _N, then there is no score at all.

But if we have
~`ok_to_post' and "`full'" ~= "", where the reason for ~`ok_to_post' is a
missing score, then the score_elt will naturally be missing.  So no need
to intervene in that case.


Note 2: We could have done this:
   if "`score'" ~= "" {
    local score_elt "(.)"
   }
   post `postfilehandle' (`idvar'[1]) (`idvarmisval') (`j1') `score_elt'
That would take care of all invalid-but-posted cases (due to -full- and
-score-), and it would obviate the need for setting score_elt at the point
where note 1 is.  But it would replace any extended missing values -- if any
(which I don't expect) with sysmis.

*/



/* Report scores of 0: */
quietly count if `scorevar'==0 &  `not_treated_or_ref' & `matchok'
if r(N) >1 {
 disp as text "Note: there are " r(N) " cases of score==0"
 // That's one possible cause of multiplicities.
}




/* Report equal scores: */

local num_picks = max(`num_pickids', `nummatches')
local kmax = `k1' + `num_picks'
/* prior to 3-27-2008, kmax was `k1' + `num_picks' -1.
That captured all the scores of the chosen items.
BUT it omits one potential ambiguity: if the LAST item has the same score as
the next one in line.  E.g., if you pick 3 matches as match 3 has same score
as match 4 (were it to be included).  This higher value of kmax should
take care of that situation.
*/

forvalues j1 = `=`k1'+1' / `kmax' {
 if `j1' <= _N &  ~mi(`scorevar'[`j1']) {
  if (`scorevar'[`j1'] == `scorevar'[`j1'-1]) & ///
   ((`j1' < (`k1'+2)) | (`scorevar'[`j1'] ~= `scorevar'[`j1'-2]) ) {
   disp as text "Note: equal scores found; score: " as res `scorevar'[`j1']
   /* And an arbitrary choice was taken, the one that is earler in the order.
   */
  }
 }
 else {
  continue, break
 }
}

/*
Note: in the the above code, the extra condition,
 ((`j1' < (`k1'+2)) | (`scorevar'[`j1'] ~= `scorevar'[`j1'-2]) )
prevents multiple reports of the same repeated score.
Otherwise, if the same score value occurs more that twice, it would be
reported more than once.

Also note that this only checks adjacent pairs; that's all you need, since the
set is sorted by `scorevar'.
*/


end // mahapicksome



prog def assert_distinct
args name1 name2 c1 c2
/*
`name1' and `name2' are allegedly the names of macros.
`c1' and `c2' are supposed to be the corresponding contents.
We need to pass names and contents separately, because they are local to the
calling context.
*/
if "`c1'" == "`c2'" {
 disp as error "`name1' and `name2' must be distinct"
 exit 198
}
end  // assert_distinct
