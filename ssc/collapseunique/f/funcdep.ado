/*
funcdep.ado
By David Kantor, 6-13-2002.
Based on, and replaces, testfd.ado.
*/
*! version 1.4.2 Jun 19, 2008
/*
Prior:
 version 1.3.0 Mar 19, 2004
 version 1.4.2 Oct 20, 2006
*/

/*
19jun2008: Renamed funcdep to funcdep_base and removed its sortpreserve
designation. Then created the wrapper programs
funcdep and funcdep_sortpreserve so as to enable funcdep to have a
-sortpreserve- option.

Note that none of the wrappers are rclass; funcdep_base is, and the wrapper
programs do not have any intervening rclass operations, so the return
values from funcdep_base remain.

I note that this is a "poorly designed" program in that it both reports information
and can add to the dataset. But the latter action happens only as an option
(gen()).
*/




prog def funcdep
version 7

syntax [varlist(default=none)] [if] [in], ///
 [basis(passthru) assert key testsep gen(passthru) sortpreserve]

if "`sortpreserve'" ~= "" {
 funcdep_sortpreserve ///
  `varlist' `if' `in', `basis' `assert' `key' `testsep' `gen'
}
else {
 funcdep_base ///
  `varlist' `if' `in', `basis' `assert' `key' `testsep' `gen'
}
end



prog def funcdep_sortpreserve, sortpreserve
syntax [varlist(default=none)] [if] [in], ///
 [basis(passthru) assert key testsep gen(passthru) ]

funcdep_base `varlist' `if' `in', `basis' `assert' `key' `testsep' `gen'
end






prog def funcdep_base, rclass

/*
By David Kantor, Institute for Policy Studies, Johns Hopkins University.

Test for functional dependence ("f.d.").

Test whether `varlist' is functionally dependent on `basis'.
Also (first) tests whether `basis' is a key.
If so, then ANY `varlist' is necessarily f.d. on `basis'.

A null `varlist' is f.d. on any `basis'.
Any `varlist' is f.d. on an absent `basis'.


Note: if you are just interested in whether you have a key, you can use
assertky or isid.

---- revision history:

6-17-2003;  Added the nodispkeytest option.
Note that I have Stata 8, but keeping this in version 6 as originally written
so it can be used by Stata 6 and 7 users.
P.S. (from 3-11-2004) I now use long macro names; need version 7.


But note that this still distinguishes the Stata-8 extended missing values
regardless (if you are running Stata 8),  This is a property of -by-.
P.S. (from 3-11-2004) I communicated this to Stata Corp.  They *might*
change that.  See emails on 3-10-2004.


7-7-2003: cutting out the nodispkeytest option; installing a testsep option.
(nodispkeytest was used only by calling contexts that did their own "testsep"
functionality (such as in collapseunique); it made for cleaner output.
But haveing testsep built into here obviates the need for nodispkeytest.)

3-4-2004: making this leave the data sorted by `basis' -- not with all the other
tested vars.  (Actual data sort order will will be no different from before;
just removing those extra vars from the official list of sort-by vars.)
To do so, just putting in "sort `basis'" at the end of test_funcdep.
This is for purely cosmetic reasons.  Otherwise, the reported sort-by list has
lots of extraneous items, which can be confusing.
[p.s. (3-22-2004) that is no longer relevant; we now have sortpreserve.
p.p.s. (6-19-2008) sortpreserve is controlable.
]


3-9-2004: fixed bug that yielded false negatives when using testsep -- where,
formerly, we passed `n2' into test_funcdep.  See comments therein regarding
`n2'.  [p.s., 3-19-2004: now we don't even gen it in funcdep.]

3-11-2004: Making basis optional.  If absent, we are testing whether
`varlist' is constant over the whole set.
Also, making this properly handle empty datasets (any vars are keys, any
vars are f.d. on any vars).

Making version 7, so as to use long macro names.

3-19-2004 adding -if- and -in- capabilities.  This actually simplifies much
of the code (!), as we no longer have do deal with the possibilities of
`basis' or `varlist' being absent.  This is because, now, all -sort-s and
-by-s start...
 sort `touse' ...
 by `touse' ...:

Also, we used to do
 by...: gen `n2'=_n
 and test it for being ==1.  Now we just do
 by...: assert _n==1 ...
which simplified the code a lot.

Also making this sortpreserve; it no longer leaves the dataset sorted.
[that's controlable as of 19jun2008]

3-22-2004: edited comments.


10-19-2006: Adding the gen() option.
Also plan to invert the by: order.  May be more efficient (less jostling) when
specifying -if- or -in-.



Note: The default behavior is to not stop if the functional dependency test
fails.  In retrospect, I should have done it the other way: default would
be to exit with an error condition.  But it is too late to change.

10-20-2006: made it so that gen(genvars) are generated even if varlist is a
key.

.Not sure whether to make genvars 1 or 0 for the failure cases.  I make them
1 -- to indicate failure cases, since that seems natural, BUT it is the
opposite of the r(funcdep).

*/


syntax [varlist(default=none)] [if] [in], ///
 [basis(varlist) assert key testsep gen(namelist)]

marksample touse, novarlist



/* We test both for functional dependence and whether `basis' is a key.
Results (values 0 or 1) are returned in r(funcdep) and r(key), respectively.
If assert is specified, we assert the functional dependence, i.e., fail if
not f.d..

If assert and key are specified, we also assert that `basis' is a key.
(Thus, -key- makes -assert- a stronger requirement; key without assert has no
effect.)

If the `basis' turns out to be a key, then we don't actually test for
functional dependence since this key condition IMPLIES that any vars must be
functionally dependent on the key.  Thus, a successful key test substitutes
for a successful func. dep. test.

Generally, a var or varlist can be tested against a given basis.  To test
several vars is equivalent to testing all of them separately -- and then asking
whether all of them passed.  -testsep- does them one at a time.  Thus, if
the test fails, using the -testsep- option will tell you WHICH var(s) is(are)
the culprit.  (Otherwise, if the test fails, and you are testing several vars,
you don't know which of them fail and which pass.)  The foregoing remarks are
about the vars in varlist; on the other hand, the `basis' vars are always taken
together if there are more than one.

Note that if the `basis' is a key, then `testsep' has no effect and `gen'
is not generated.

*/


/*
We will require that gen be...
 1 var if not testsep, or
 as many as there are in varlist if testsep.
*/

if "`gen'" ~= "" {
        confirm new var `gen'
        local numgens: list sizeof gen
        if "`testsep'" == "" { /* testsep was not specified */
                if `numgens' ~= 1 {
                        disp as error "without testsep, gen must have one var"
                        exit 198
                }
        }
        else {  /* testsep was specified */
                local numvars: list sizeof varlist
                if `numgens' ~= `numvars' {
                        disp as error "with testsep, gen and varlist must have equal number of vars"
                        exit 198
                }
        }
}



return scalar key = 0
return scalar funcdep = 0



sort `basis' `touse'


capture by `basis' `touse': assert _n == 1 if `touse'  // note 3

if _rc == 0 {
        return scalar key = 1
        return scalar funcdep = 1
        disp as text "basis (" as res "`basis'" as text ") is a key"
          /* -- and any var must be func. dep. on it. */
        foreach g of local gen {
                gen byte `g' = 0
        }
}
else {
        disp as text "basis (" as res "`basis'" as text ") is not a key"

        if "`testsep'" == "" {
                test_funcdep `varlist' if `touse', basis(`basis') gen(`gen')
                return scalar funcdep = r(funcdep)  // as returned from test_funcdep
        }
        else {
                return scalar funcdep = 1
                local j = 1
                tokenize `gen'
                foreach var of local varlist {
                        test_funcdep `var' if `touse', basis(`basis') gen(``j'')
                        return scalar funcdep = return(funcdep) & r(funcdep)
                        /* Note 1 */
                        local ++j
                }
                if "`varlist'" == "" {
                        disp as text "() IS f.d. on (" as res "`basis'" as text ")"  // note 2

                }
        }
}


if "`assert'" ~= "" {
    capture assert return(funcdep)
    if _rc~= 0 {
        disp as error "functional dependency condition fails"
        /* It's necessarily also not a key. */
        exit 459
    }
    if "`key'" ~= "" {
        capture assert return(key)
        if _rc~= 0 {
            disp as error "key condition fails"
            exit 459
        }
    }
}


end /* funcdep */

/*
Notes for funcdep:

Note 1:
return(funcdep) is local info.
r(funcdep) is what comes back from test_funcdep.

Note 2: That is to give you a message about the varlist being f.d. on the
`basis' -- when the varlist is null and you used -testsep- (and `basis' is
not a key).  In this case, without this bit of code, you would not get any
message about the (null) varlist passing the f.d. test, since no test was
actually run.  Thus, this corrects a minor inconsistency.  But the return
values work out fine regardless.


Note 3:
We used to do...

 tempvar n2

 if "`basis'" ~= "" {
  sort `basis'
  local by_basis "by `basis':"
 }

 `by_basis'  gen long `n2'=_n
 capture assert `n2'== 1
 if _rc == 0 | _N==0

That "_N==0" was to handle a special case -- when there are no
observations but there IS a basis variable.  In that case, the...
 `by_basis'  gen long `n2'=_n
command runs but does NOT generate `n2'.  Subsequently,...
 capture assert `n2'== 1
would fail because `n2' does not exist.

(If there are no obs, and there is no basis var, then all is okay; `n2' is
created.)

BUT this is all moot, as the newer code is much simpler.

*/


/* -------- */




prog def test_funcdep, rclass
/* Do the actual test of functional dependence.
This is a subprogram to funcdep; if it weren't called in two places, it would
have been just plain code within funcdep.
*/

syntax [varlist(default=none)] [if], [basis(varlist) gen(name)]
marksample touse, novarlist

/* We re-compute an `n2', since here, `n1' and `n2' must be done on the same
sort.

(Previously, we had `n2' as a required option passed in -- to avoid redundant
computation of `n2' [but that is no longer generted within funcdep anyway --
as of 3-19-2004].  It caused a bug, yielding false negatives!)

Other solutions: sort `basis' `n2'; then sort `basis' `varlist', stable.
That might work. (?)
Another is to use _N rather than _n.
But the safest is to just recompute `n2' here.  It's not worth trying any
tricks.

10-19-2006: here, gen is a single variable.
It is a constant by basis, indicating whether the varlist is not functionally
dependent (not constant) within that by-group.

6-19-2008: Just note that the data are already sorted by `basis'; actually
it is sorted by `basis' `touse', though `touse', is a local macro from the
calling context and is out of scope (though its variable is present -- with
a tempname such as __000000). A new `touse' will be created here,
which is identical to the caller's `touse'.
Here, we will further sort by `basis' `touse' `varlist'.
(I was attempting to eliminate a redundant sort, but it ultimately needs to
stay.)

*/

tempvar n1 n2
return scalar funcdep = 0



sort `basis' `touse' `varlist'

by `basis' `touse' `varlist': gen long `n1'=_n
quietly compress `n1'
by `basis' `touse' : gen long `n2'=_n
quietly compress `n2'

capture assert `n1' == `n2' if `touse'
if _rc == 0 {
        return scalar funcdep = 1
        disp as text "(" as res "`varlist'" as text") IS f.d. on (" ///
         as res "`basis'" as text ")"
}
else {
        disp as text "(" as res "`varlist'" as text") is NOT f.d. on (" ///
         as res "`basis'" as text ")"
}

if "`gen'" ~= "" {
        confirm new var `gen'
        tempvar diff
        gen byte `diff' = `n1' ~= `n2'
        /* We now want the equivalent of...
          -by `basis' `touse': egen byte `gen'= max(`diff')-
        but I don't want this to depend on egen.
        We will do the equivalent.
        */

        sort `basis' `touse' `diff'
        by `basis' `touse' (`diff'): gen byte `gen' = `diff'[_N] if `touse'

}



end // test_funcdep


