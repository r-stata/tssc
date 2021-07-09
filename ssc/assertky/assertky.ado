/*
assertky.ado
By David Kantor, 8-9-2002.
*/

*! version 1.2.4 11-8-2006
/* prior version:
 1.2.3 9-28-2006
 1.2.2 7-16-2006
 1.2.1 1-4-2006
  and others
*/

prog def assertky
version 8.0

/*
By David Kantor, Institute for Policy Studies, Johns Hopkins University.

Test for whether a given varlist (`basis') is a key.

This replicates part of what funcdep can do, but is simpler.

This always asserts; it is not rclass.

This will sort the data!

4-8-2003: Previously, the basis vars were brought in via the -basis- option.
Now I also will allow it to be a varlist, which is easier to use.  You can do
it either way, but not both.

Actually, a varlist is more natural. I would prefer it that way, but this is
already in use the "old" way in many places.  So I give both possibilities,
for backward compatibility.

(Setting version to 8; 6 would still be ok.)

Note that this is similar in spirit to the Stata-provided -isid- program,
though much simpler.


1-4-2006: adding -if- and -in- capabilities, borrowing code from funcdep.ado.
(Funcdep acquired its -if- and -in- capabilities on 3-19-2004.)
Later on 1-4-2006, changing from...
 sort `touse' `basis'
to...
 sort `basis' `touse'

The reason being that, with -sort `touse' `basis'-, after the program exits,
the sort information is lost, because the first part of the sort varlist is
dropped (automatically).  But (~~~ we hope) that with -sort `basis' `touse'-,
this will not happen; the first part of the sort varlist will remain, though
the later part (if any) will drop out.

Note that with -sort `basis' `touse'-, the orders you get with and without an
-if- or -in- are very similar; but with -sort `touse' `basis'-, they are very
different.  With the latter, ALL "out" cases come at the front of the whole
dataset.  With -sort `basis' `touse'-, the "out" cases come at the front of
each subset, by `basis'.


2-5-2006: fixing comments.

7-16-2006: giving the -stable- option, to make the sort stable.  So if this
is used and fails, then the sets of colliding observations are left in their
original relative orders, in case that is important.


Also doing the gen_n and gen_N options.
These are produced only under a failure condition.
And gen_n may be inconsistent if -stable- is not specified.

9-28-2006: Fixing a bug in the gen_n & gen_N options; they needed "if `touse'".

11-8-2006: Merely cut out -capture prog drop assertky-; not needed in ado
files.


*/

syntax [varlist(default=none)] [if] [in] [,basis(varlist) stable gen_n(name) gen_N(name)]
marksample touse, novarlist


if "`varlist'" =="" {
  if "`basis'" =="" {
    disp as error "(assertky) You must specify either a varlist or (option) basis."
    exit 198
  }
  else {
    local key_spec_typ "basis"
  }
}
else {
  if "`basis'" =="" {
    // transfer varlist to basis:
    local basis "`varlist'"
    local key_spec_typ "varlist"
  }
  else {
    disp as error "(assertky) You may not specify both a varlist and (option) basis."
    exit 198
  }
}


sort `basis' `touse', `stable'
/* Note that the "out" cases (if any) are at the front of each by-group,
by `basis'.
*/

capture by `basis' `touse' : assert _n == 1 if `touse'
if _rc~=0 {
  disp as error "`key_spec_typ' is not a key"

  if "`gen_n'" ~= "" {
   confirm new var `gen_n'
   by `basis' `touse': gen long `gen_n' = _n  if `touse'
   qui compress `gen_n'
  }

  if "`gen_N'" ~= "" {
   confirm new var `gen_N'
   by `basis' `touse': gen long `gen_N' = _N  if `touse'
   qui compress `gen_N'
  }


  exit 459
}

end /* assertky */

