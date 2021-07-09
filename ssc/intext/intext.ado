#delim ;
prog def intext, rclass;
version 13.0;
/*
 Input a text file into a Stata data set in memory
 containing as many string variables as necessary,
 each containing a portion of the record
 with a user-specified maximum length.
*! Author: Roger Newson
*! Date: 31 March 2017
*/

syntax using , Generate(string) [ LEngth(integer 80) CLEAR ];
/*
  generate() is the prefix for generated string variables.
  length()is maximum length of string variables.
  clear() indicates that any existing data set in memory may be cleared.
*/

*
 Check that length() is legal
*;
local maxlength=c(maxstrlvarlen);
if `length'<=0 {;
  disp as error "Nonpositive length(`length') not allowed";
  error 498;
};
if `length'>`maxlength' {;
  disp as error "length(`length') greater than the maximum of `maxlength'";
  error 498;
};

*
 Measure number of records in input file and maximum record length
*;
tempname intf;
tempname curbyte;
file open `intf' `using', binary read;
local nobs=0;
local mrecl=0;
file read `intf' %1bu `curbyte';
while r(eof)==0 {;
  local nobs=`nobs'+1;
  local recl=0;
  while !inlist(`curbyte',10,13,.) {;
    local recl=`recl'+1;
    file read `intf' %1bu `curbyte';
  };
  if `recl'>`mrecl' {;
    local mrecl=`recl';
  };
  if `curbyte'==13 {;
    file read `intf' %1bu `curbyte';
  };
  if `curbyte'==10 {;
    file read `intf' %1bu `curbyte';
  };

};
file close `intf';
if `mrecl'==0 {;local nsect=1;};
else {;local nsect=int((`mrecl'-1)/`length')+1;};

disp as text "Number of records: " as result `nobs'
 _n as text "Maximum record length: " as result `mrecl'
 _n as text "Number of string variables of length `length' required as record sections: " as result `nsect';
 
preserve;

if "`clear'"!="" {;drop _all;lab drop _all;};

*
 Create initially empty generated string variables
*;
local newobs=max(_N,`nobs');
qui set obs `newobs';
forv i1=1(1)`nsect' {;qui gene str1 `generate'`i1'="";};

* Assign values to generated string variables *;
file open `intf' `using',binary read;
local obs=0;
file read `intf' %1bu `curbyte';
while r(eof)==0 {;
  local obs=`obs'+1;
  local recl=0;
  while !inlist(`curbyte',10,13,.) {;
    local recl=`recl'+1;
    local varseq=int((`recl'-1)/`length')+1;
    qui replace `generate'`varseq'=`generate'`varseq'+char(`curbyte') in `obs';
    file read `intf' %1bu `curbyte';
  };
  if `curbyte'==13 {;
    file read `intf' %1bu `curbyte';
  };
  if `curbyte'==10 {;
    file read `intf' %1bu `curbyte';
  };
};
file close `intf';

* Labels and formats for variables *;
forv i1=1(1)`nsect' {;
  local typei1:type `generate'`i1';
  local leni1=subinstr("`typei1'","str","",1);
  if `"`leni1'"'=="L" {;
    format `generate'`i1' %-`=c(maxstrvarlen)'s;
  };
  else {;
    format `generate'`i1' %-`leni1's;
  };
  lab var `generate'`i1' "Section `i1'";
};

restore,not;

* Return results *;
return scalar nobs=`nobs';
return scalar mrecl=`mrecl';
return scalar nsect=`nsect';

end;
