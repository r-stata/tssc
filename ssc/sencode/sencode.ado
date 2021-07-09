#delim ;
program define sencode;
version 10.0;
/*
 Sequentially encode string label -varname- into -generate-
 encoding in order of appearance,
 using variable label -label'- if specified
 (like encode,
 except that the codes are in order of appearance in the data set
 instead of in alphabetical order).
*! Author: Roger Newson
*! Date: 24 September 2013
*/
syntax varname(string) [if] [in] , [ Generate(string) replace Label(string) fast * ];
/*
  -generate- is the name of the new coded variable to be generated.
  -replace- specifies that the new coded variable will replace the input string variable.
  -label- is the name of a variable label to be used (and added to if necessary).
  -fast- specifies that no action should be taken to restore the original data
    if the user presses -Break-.
*/

*
 Check that either -generate- or -replace- is present (but not both)
 and initialise -generate- accordingly
 *;
if "`replace'"!="" {;
  if "`generate'"!="" {;
    disp as error "options generate() and replace are mutually exclusive";
    error 198;
  };
  * Save old variable order *;
  unab oldvars: *;
  tempvar generate;
};
else {;
  if "`generate'"=="" {;
    disp as error "must specify either generate() or replace option";
    error 198;
  };
  confirm new variable generate;
};

*
 Parse -label-,
 extracting -lreplace- if present,
 and initializing -label- if -label- is absent
*;
_labelparse `label';
local label "`r(label)'";
local lreplace "`r(lreplace)'";
if("`label'"==""){;
  if "`replace'"!="" {;
    local label "`varlist'";
  };
  else {;
    local label "`generate'";
  };
};

if "`fast'"=="" {;preserve;};

*
 Call _sencode to do the work involving sorting and resorting
 (which should be protected by -sortpreserve-)
*;
tempvar generate2;
_sencode `varlist' `if' `in' , generate(`generate2') label(`label') `lreplace' `options';

*
 Replace input string variable with generated coded variable
 if -replace- is specified
*;
if "`replace'"!="" {;
  char rename `varlist' `generate2';
  drop `varlist';
  rename `generate2' `varlist';
  order `oldvars';
};
else {;
  rename `generate2' `generate';
};

if "`fast'"=="" {;restore,not;};

end;

prog def _labelparse, rclass;
version 10.0;
/*
  Parse -label()- option
  and return label name and replacement options
*/

syntax [ name ] [ , replace ];
/*
  -replace- specifies that any existing value label with the input label name
    will be dropped.
*/

if "`replace'"!="" {;
  return local lreplace "lreplace";
};
return local label "`namelist'";

end;

program define _sencode, sortpreserve;
version 10.0;
/*
 Execute the middle parts of the -sencode- process,
 involving sorting and resorting of data
 (which should be protected by -sortpreserve-).
*/
syntax varname(string) [if] [in] , Generate(string)
  [ Label(string) lreplace GSort(string) MANyto1 noExtend ];
/*
  -generate()- is the name of the new coded variable to be generated.
  -label()- is the name of a value label to be used (and added to if necessary).
  -lreplace- specifies that any existing value label with the name given by -label()-
    will be dropped.
  -gsort()- specifies the order in which numbers are allocated to the labels.
  -manyto1- specifies that the mapping from string values to encoded numeric values
   can be many-to-one (so repeated string values have multiple codes).
*/

marksample touse,strok;

* Name of input string variable *;
local inputstr "`varlist'";

* Check that -label()- exists and is a label *;
mata: st_local("labpres",strofreal(st_vlexists("`label'")));
if !`labpres' & ("`extend'"=="noextend") {;
  disp _n as error "noextend cannot be specified as label `label' does not exist";
  error 198;
};

* Drop value label given by -label()- if requested *;
if "`lreplace'"!="" {;
  if "`extend'"=="noextend" {;
    disp _n as error "You cannot specify noextend and the replace suboption of label()";
    error 198;
  };
  cap lab drop `label';
};

*
 Find old maximum value for -label()-
*;
tempname ovalmax;
mata: sencode_addedlabelledvalue0("`label'","`ovalmax'");

* Set -gsort- to default value if missing *;
if `"`gsort'"'=="" {;local gsort "`_sortindex'";};

*
 Group observations
 and define first version of new variable -generate-
 (with groups numbered from maximum existing code + 1
 to maximum existing code + number of possible new codes)
*;
gsort_parse `gsort';
local gsort_list `"`r(gsort_list)'"';
local gsort_opts `"`r(gsort_opts)'"';
gsort `touse' `gsort_list' `inputstr', gene(`generate') `gsort_opts';
if "`manyto1'"=="" {;
  * One-to-one mapping from codes to string labels *;
  sort `touse' `inputstr' `generate' `_sortindex';
  qui by `touse' `inputstr':replace `generate'=`generate'[1];
  tempvar generate2;
  gsort `touse' `generate',gene(`generate2');
  qui replace `generate'=`generate2';
  drop `generate2';
};
sort `_sortindex';
qui summ `generate' if `touse';
if r(N)>0 {;
  qui replace `generate'=`generate'-r(min)+1+`ovalmax' if `touse';
};
qui replace `generate'=. if !`touse';

*
 Create new value labels
 and final version of new variable -generate-
*;
qui summ `generate' if `touse';
if r(N)>0 {;
  local genmin=r(min);
  local genmax=r(max);
  if "`manyto1'"=="" {;
    * One-to-one mapping from codes to string labels *;
    forv i1=`genmin'(1)`genmax' {;
      encode `inputstr' if `generate'==`i1', label(`label') gene(`generate2') `extend';
      drop `generate2';
    };
    drop `generate';
    encode `inputstr' if `touse', label(`label') gene(`generate') `extend';
  };
  else {;
    * Many-to-one mapping from codes to string labels *;
    if "`extend'"=="noextend" {;
      disp as error "You cannot specify noextend and manyto1";
      error 198;
    };
    * Ensure that -label()- exists (and is possibly empty) *;
    tempvar generate3;
    encode `inputstr' if 0, gene(`generate3') label(`label');
    drop `generate3';
    forv i1=`genmin'(1)`genmax' {;
      qui summ `_sortindex' if `generate'==`i1';
      local i2=r(min);
      local labcur=`inputstr'[`i2'];
      *
       Add leading blanks to label if necessary.
       (This bug fix was added to deal with non-missing blank labels
       by Roger Newson on 9 June 2003.)
      *;
      local nlblanks=length(`inputstr'[`i2'])-length(`"`labcur'"');
      local lblanks "";
      forv i3=1(1)`nlblanks' {;local lblanks "_`lblanks'";};
      local lblanks:subinstr local lblanks "_" " ",all;
      label define `label' `i1' `"`lblanks'`labcur'"', add nofix;
    };
  };
};
qui compress `generate';
lab val `generate' `label';
local inputlab:var lab `inputstr';
lab var `generate' `"`inputlab'"';

end;

prog def gsort_parse, rclass;
version 10.0;
/*
 Parse gsort options
 and return results.
*/

syntax anything(name=gsort_list id="gsort list") [ , * ];

return local gsort_list `"`gsort_list'"';
return local gsort_opts `"`options'"';

end;

#delim cr
version 10.0
/*
  Private Mata programs
*/
mata:

void sencode_addedlabelledvalue0(string scalar labname,string scalar ovalmax)
{
/*
  Input label name in labname
  and output first value to add if extending the label
  to scalar with name stored in ovalmax.
*/
real scalar zval;
real vector existvals;
string vector existlabs;
/*
  zval will contain the maximum existing value
    (or 0 if no existing values are present).
  existvals will contain the existing values for the value label.
  existlabs will contain the existing labels for the value label.
*/

/*
  Calculate and return first value to add.
*/
if(!st_vlexists(labname)){
  zval=0;
}
else {
  st_vlload(labname,existvals,existlabs);
  zval=ceil(max(existvals));
  if(missing(zval) | zval<0){
    zval=0;
  }
}
st_numscalar(ovalmax,zval);

}

end

