#delim ;
prog def vallabdef, rclass;
version 10.0;
/*
 Define value labels using 3 input variables,
 containing the label names, numeric code values,
 and value labels, respectively.
*!Author: Roger Newson
*!Date: 15 January 2018
*/

syntax varlist(min=3 max=3) [if] [in];
local labnamevar: word 1 of `varlist';
local codevar: word 2 of `varlist';
local labvar: word 3 of `varlist';

*
 Check that input variables have correct types
*;
conf string variable `labnamevar';
conf numeric var `codevar';
conf string var `labvar';

marksample touse, strok novarlist;
qui replace `touse'=0 if missing(`labnamevar');
qui replace `touse'=0 if `codevar'==.;

*
 Create variable labels
*;
tempname codecur labcur;
local Nobs=_N;
forv i1=`Nobs'(-1)1 {;
  if `touse'[`i1'] {;
    local labname=`labnamevar'[`i1'];
    cap conf name `labname';
    if !_rc {;
      scal `codecur'=`codevar'[`i1'];
      scal `labcur'=`labvar'[`i1'];
      mata: st_vlmodify(st_local("labname"),st_numscalar("`codecur'"),st_strscalar("`labcur'"));
    };
  };
};

*
 Create list of labels modified
*;
qui levelsof `labnamevar' if `touse', lo(names);
qui lab dir;
local allnames "`r(names)'";
local names: list names & allnames;
local names: list clean names;
local names: list sort names;

*
 Return names
*;
return local names `"`names'"';

end;
