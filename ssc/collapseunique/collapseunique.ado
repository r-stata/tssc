/*
collapseunique.ado  6-17-2003

David Kantor, Institute for Policy Studies, Johns Hopkins University

This does a kind of collapsing operation, akin to -collapse-, but just takes
unique values of variables.  Specifically,...
 1, confirm that, within by-groups (formed according to the `by' variables),
 the values in the main varlist are unique, i.e., constant.  (In other words,
 `varlist' is functionally dependent on `by'.)
 2, if the first test passes, then collapse to one observation per by-group,
 taking the unique values in `varlist'
 3, finally, keep only those variables mentioned in `by' and `varlist'.

This will make use of funcdep (a test for functional dependence), another of
my ados.

7-8-2003: adapting to changes in funcdep.ado; the -testsep- option is coded
THERE, so the present program becomes simpler.

10-9-2003; making varlist optional.  With an empty varlist, this should just
collapse to unique values of `by'.

3-11-2004: making by(varlist) optional (that's varlist2 in the help).  The
same was done for funcdep (basis()).
If it is absent,then this considers the whole dataset as one by-group
-- as if you had done...
 gen byte one=1
 collapseunique varlist, by(one)

It is required to have at least at least one of varlist or by().


3-19-2004 funcdep is now sortpreserve; we must do our own sorting herein.
(That's a bit wasteful, as we re-sort here.)
[That's changed as of 6-19-2008.]


3-22-2004: edited comments.

Note: why not try to make this as an additional feature on -collapse- (another
stat item)?  The reason is that there is a fundamental difference between
this and -collapse-: this will sometimes refuse to do any action at all,
depending on the content of the data, whereas -collapse- always does some
kind of collapsing.

One possibility would be to add this in to -collapse-, but to yield missing
values where the var is not functionally dependent on the by-vars.

More on 3-22-2004: adding the emptyvarlist option.

Also, at the outset, we remove from varlist any vars in common with by.
There is no intrinsic need for this,  But it closes a loophole in the
requirement for emptyvarlist.  If it weren't for this, then you could do...
 collapseunique a, by(a b c)
which has the same effect as
 collapseunique, by(a b c)
but there would be no check for emptyvarlist.

Thus, emptyvarlist is required if varlist is empty -- or if it is a subset
of the by-vars.  The latter part of this is a consequence of the editing
of varlist.

3-23-2004: just added comments.

6-19-2008: funcdep is, by default, NOT sortpreserve. So we can skip the
-sort- command (once again).

*/


*! version 1.2.3 19jun2008

program define collapseunique
version 8  // it may work fine in 7 (?)

syntax [varlist(default=none)] [if] [in] , [by(varlist) testsep fast ///
 EMPTYVarlist]

marksample touse, novarlist

if "`varlist'" =="" & "`by'" =="" {
 disp as error "varlist or by() required; they may not both be absent"
 exit 198
}



/* remove from varlist any vars in common with by. */

local commonvars : list varlist & by
if trim("`commonvars'") ~= "" {  // trim probably not needed
 disp as text "Note: {it:varlist} and {it:by} have common elements: `commonvars'"
 disp as text "they are being removed from {it:varlist}."
 local varlist : list uniq varlist
 local varlist : list varlist - by
}

/* The use of -list uniq varlist- reduces repeated items.  Closes another
loophole: 
 collapseunique a a, by(a b c)
would pass otherwise.
*/




if "`varlist'" =="" & "`emptyvarlist'" =="" {
 disp as error "option emptyvarlist required if {it:varlist} is absent"
 exit 198
}




if "`fast'" == "" {
        preserve
}

tempname N1 N2
quietly {
        count
        scalar `N1' = r(N)
        keep if `touse'
        count
        scalar `N2' = `N1' - r(N)
        }

if `N2' >0 {
        disp as text "(" as res `N2' as text plural(`N2', " observation") ///
         " deleted due to " ///
         as input "if" as text " or " as input "in" as text " conditions)"
}


funcdep `varlist', basis(`by') assert `testsep'


/* At this point, we have confirmed that all the vars are functionally
dependent on `by'.  So we can proceed to reduce.
*/

if "`by'" ~= "" {
 /* sort `by' */
 local byby "by `by':"
}

quietly {
        count
        scalar `N1' = r(N)
        `byby' keep if _n==1  // reduce to one observation per by-group
        count
        scalar `N2' = `N1' - r(N)
        }
disp as text "(" as res `N2' as text plural(`N2', " observation") ///
 " deleted in the collapsing)"


keep `by' `varlist'

/* That last -keep- retains only the variables of interest.  Presumably,
any other variables might not be appropriate to keep.  (Any other variable
might not be functionally dependent on `by', and thus, would have an arbitrary
representative value retained.)
*/



if "`fast'" == "" {
        restore, not
}


end
