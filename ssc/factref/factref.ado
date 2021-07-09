#delim ;
prog def factref,rclass;
version 7.0;
/*
 Insert new observations with reference values for a list of factors
 (assumed to be created by -factext-)
*! Author: Roger Newson
*! Date: 08 January 2003
*/
syntax varlist(min=1) [if] [in] [ , BY(varlist) REfind(string)
 RZero(varlist) RUnity(varlist) RMiss(varlist)
 RDef(string) ];
/*
 Insert new observations with reference values for a list of factors in -varlist-
 (one new observation for each factor for each by-group
 in which a non-missing value exists for that factor,
 with the value of the factor set to its -omit- characteristic).
 -by- is a list of variables defining the by-groups.
 -refind- is an indicator variable indicating that an observation is a reference observation
  for at least one factor.
 -rzero- is a list of existing variables to be set in reference observations
  to 0 if the variable is numeric and "0" if the variable is string.
 -runity- is a list of existing variables to be set in reference observations
  to 1 if the variable is numeric and "1" if the variable is string.
 -rmiss- is a list of existing variables to be set in reference observations
  to missing values, namely . if the variable is numeric and "" if the variable is string.
 -rdef- is a string indicating default lists of variables for -rzero-, -runity- and -rmiss-
  (and overriding any user-defined values for these lists).
  If -rdef- starts with "lf", then the -lform- (linear format) defaults are used.
  If -rdef- starts with "ef", then the -eform- (exponential format) defaults are used.
  (The -rdef- option is provisionally unpublicised.)
*/

preserve;

* List of existing variables to be assigned missing values *;
unab exivars : *;
local rmiss "";
foreach X of var `exivars' {;
  local normiss=0;
  foreach Y of var `varlist' `by' {;
    if "`X'"=="`Y'" {; local normiss=1; };
  };
  if !`normiss' {; local rmiss "`rmiss' `X'"; };
};

*
 Default replacement options specified by -rdef-
*;
if substr("`rdef'",1,2)=="lf" {;
  * Linear format defaults *;
  unab rzero: estimate stderr min* max*;
  local runity "";
  foreach X of any parmseq t z {;
    cap confirm variable `X';
    if _rc==0 {;local rmiss "`rmiss' `X'";};
  };
};
else if substr("`rdef'",1,2)=="ef" {;
  * Exponential format defaults *;
  unab rzero: stderr;
  unab runity: estimate min* max*;
  foreach X of any parmseq t z {;
    cap confirm variable `X';
    if _rc==0 {;local rmiss "`rmiss' `X'";};
  };
};

*
 Select sample for processing
 and record old sequence order
*;
marksample touse,strok novarlist;
tempvar oldseq;
qui gene long `oldseq'=_n;

* Name variable -refind- if necessary *;
if "`refind'"=="" {;
  tempvar refind;
};
else {;
  confirm new variable `refind';
};

*
 Insert new reference observations for each factor
 with value of that factor equal to its -omit- characteristic
*;
gene byte `refind'=0 if `touse';
lab var `refind' "Reference observation indicator";
tempvar fpres todup frefind;
foreach F of var `varlist' {;
  local ftype:type `F';
  local fomit `"``F'[omit]'"';
  if `"`fomit'"'=="" {;
    disp as error "Characteristic `F'[omit] not defined";
    disp as error "Cannot insert reference observations for `F'";
    error 498;
  };
  else {;
    qui {;
      gene byte `fpres'=`touse'&(!missing(`F'));
      sort `touse' `by' `fpres' `oldseq';
      by `touse' `by' `fpres':gene `todup'=`touse'&`fpres'&(_n==1);
      expgen =`todup'+1,copyseq(`frefind');
      replace `frefind'=`frefind'-1;replace `frefind'=. if !`touse';
      replace `refind'=1 if `frefind'==1;
      if index("`ftype'","str")==1 {;
        replace `F'=`"`fomit'"' if `frefind'==1;
      };
      else {;
        replace `F'=`fomit' if `frefind'==1;
      };
      drop `fpres' `todup' `frefind';
    };
  };
};

*
 Sort back to old order
 (with reference observations first in case of ties)
*;
gsort +`oldseq' -`refind';

*
 Replace values of -rmiss-, -rzero- and -runity- variables
 in reference observations
*;
if "`rmiss'"!="" {;
  foreach Y of any `rmiss' {;
    local ytype:type `Y';
    if index("`ytype'","str")==1 {;cap replace `Y'="" if `refind'==1;};
    else {;cap replace `Y'=. if `refind'==1;};
  };
};
if "`rzero'"!="" {;
  foreach Y of any `rzero' {;
    local ytype:type `Y';
    if index("`ytype'","str")==1 {;cap replace `Y'="0" if `refind'==1;};
    else {;cap replace `Y'=0 if `refind'==1;};
  };
};
if "`runity'"!="" {;
  foreach Y of any `runity' {;
    local ytype:type `Y';
    if index("`ytype'","str")==1 {;cap replace `Y'="1" if `refind'==1;};
    else {;cap replace `Y'=1 if `refind'==1;};
  };
};

restore,not;

end;

prog def expgen;
version 7.0;
*
 Expand by expression and generate new variables
 containing sequence number of original observation before duplication
 and copy sequence number after duplication,
 sorting the data set by these new variables
 to retain the original order.
 Author: Roger Newson
 Date: 20 February 2002
*;
syntax [newvarname]=/exp [if]  [in] [ , Oldseq(string) Copyseq(string) Zero Missing ];
*
 exp specifies number of copies of the observation.
 oldseq specifies variable to be generated containing sequence order
 of old observation in the original data set.
 copyseq specifies variable to be generated containing sequence order
 of copy in new data set
 (1 to number of copies).
 zero specifies that observations with zero or negative value of exp
 will have one copy in the new data set.
 missing specifies that observations with missing values of exp
 will have one copy in the new data set.
*;

* Mark sample defined by if and in *;
marksample touse,novarlist;

*
 Create macros ncopy (to contain variable name for number of copies)
 and ncexp (to contain expression for number of copies)
*;
if("`varlist'"==""){tempvar ncopy;};
else{local ncopy "`varlist'";};
local ncexp "`exp'";

*
 Check that oldseq and copyseq are valid variable names
 (filling them in with temporary variable names if necessary)
*;
if("`oldseq'"==""){tempvar oldseq;};
if("`copyseq'"==""){tempvar copyseq;};
local 0 "`oldseq'";syntax newvarname;
local 0 "`copyseq'";syntax newvarname;

preserve;

qui{
  keep if(`touse');
  * Evaluate expression for number of copies *;
  gene int `ncopy'=`ncexp';compress `ncopy';
  if("`missing'"==""){drop if(`ncopy'==.);};
  if("`zero'"==""){drop if(`ncopy'<1);};
  gene int `oldseq'=_n;compress `oldseq';
  expand =`ncopy';
  sort `oldseq';
  by `oldseq':gene int `copyseq'=_n;compress `copyseq';
  sort `oldseq' `copyseq';
};

restore,not;

end;
