/*
ado\gen_tail.ado
begun 7-21-2004
David Kantor

!version 1.0 7-21-2004

*/

program def gen_tail, byable(onecall)
version 8.2

/*
Given a quantity interpreted as a boolean, generate the "tail" of observaions
that are either indicated by that variable, or follow it within the by-group.

This was originally in psid016\prep007.do, but with some hard-coded variables
and without the byable.

We take nonzero values (including missing) in the input variable as "true".

Typically, you would call this via...
 bysort varlist1 (varlist2): gen_tail ...

Hopefully, varlist1 (varlist2) will make for a unique sort order.  If not,
you take a gamble, unless you pre-sort it by varlist1 (varlist2) and some
additional variable(s).  (There is no such thing as a bysort..., stable.)

You can also call it without bysort.
*/


syntax varname, gen(name)
confirm new var `gen'
// assert ~mi(`varlist')


// disp "gen_tail; the byvars are `_byvars'"

gen byte `gen' = `varlist' ~= 0

if _by() {
 local by "by `_byvars' :"
}

quietly `by' replace `gen' = 1 if _n>1 & `gen'[_n-1]
end // gen_tail

