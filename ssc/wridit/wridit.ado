#delim ;
prog def wridit, sortpreserve;
version 10.0;
/*
 Calculate weighted ridits for an input variable.
*! Author: Roger Newson
*! Date: 29 February 2012
*/

syntax varname [if] [in] [fweight pweight aweight iweight] , Generate(name) [ by(varlist) FOLded REVerse PERCent float ];
/*
 generate() specifies the output variable name.
 by() specifies by-variables.
 folded specifies folded ridits.
 reverse specifies reverse ridits.
 percent specifies percent ridits (instead of proportional ridits).
 float specifies that the output variable
*/

marksample touse, zeroweight;
if `"`exp'"'=="" {;local exp "=1";};

tempvar wt minus subtotal total summand tempgen;
qui {;
  gene double `wt' `exp' if `touse';
  gene double `minus'=-`varlist';
  sort `touse' `by' `varlist';
  by `touse' `by': egen double `total'=total(`wt') if `touse';
  by `touse' `by' `varlist': egen double `subtotal'=total(`wt') if `touse';
  by `touse' `by' `varlist': gene `summand'=`subtotal'*(_n==_N) if `touse';
  by `touse' `by': gene double `tempgen' = sum(`summand'[_n-1]) if `touse';
  sort `touse' `by' `minus';
  by `touse' `by' `minus': replace `summand'=`subtotal'*(_n==_N) if `touse';
  by `touse' `by': replace `tempgen' = (`tempgen'-sum(`summand'[_n-1]))/`total' if `touse';
  if "`reverse'" != "" {;replace `tempgen' = -`tempgen';};
  if "`folded'"=="" {;replace `tempgen' = (`tempgen'+1)/2;};
  if "`percent'" != "" {;replace `tempgen' = 100 * `tempgen';};
  if "`float'"!="" {;recast `tempgen' float;};
  compress `tempgen';
};

rename `tempgen' `generate';

end;
