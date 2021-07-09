/*
mark_changes.ado;  10-11-2006
By David Kantor
*/

*! version 1.0.0 10-11-2006

/*
This looks in the sequence of records in the existing sort order; it marks
ones that change anywhere in a given set of variables.

Can be used with -by-; the first record in any by-group is also marked.
You typically call this with a 2-part by, as in
 by person (effdate): mark_changes ...
The reason is that you want to respect the primary divisions (marking the
first record in each group), but you typically also want a specific order
within these groups.


No -if- or -in- features are allowed; they could be added if needed.
On the other hand, it would require some decisions as to what it means to
exclude some observations, so this issue is not so clear-cut.




[Edits had been done 2-25-2008; don't know if is was a substantial change or
just comments.]

6-19-2008 and 4-17-2008: Just edited comments.

Help file was created 16apr2009.

*/


prog def mark_changes, byable(onecall)

version 8.2
syntax varlist, gen(name)

confirm new var `gen'

if _by() {
 local by "by `_byvars' :"
}

`by' gen byte `gen' = _n==1

foreach v of local varlist {
 quietly `by' replace `gen' = 1 if _n>1 & `v' ~= `v'[_n-1]
}

end

