#delim ;
prog def varlabdef, rclass;
version 10.0;
/*
 Define a value label with a user-supplied name
 with 1 label for each variable in a varlist
*!Author: Roger Newson
*!Date: 09 April 2009
*/

syntax name(id="label name") [, Vlist(string) FRom(string) nofix replace ];
/*
  vlist() is the list of variables used to create the value label.
  from() specifies the source from which the value labels are copied,
    defaulting to the variable labels.
  nofix acts as the nofix option of label define.
  replace specifies that any existing value label of the given name
    will be replaced.
*/

*
 Generate vlist
*;
vlistgen `vlist';
local vlist `"`r(vlist)'"';
if `"`vlist'"'=="" {;
  disp as error "No variables present";
  error 498;
};

*
 Parse from(), setting default if necessary
*;
if `"`from'"'=="" {;local from "varlab";};
cap confirm names `from';
if _rc!=0 {;
  disp as error `"Invalid from() option: `from'"';
  error 498;
};
local nfrom: word count `from';
if `nfrom'>2 {;
  disp as error `"Invalid from() option: `from'"';
  error 498;
};
local source: word 1 of `from';
if !inlist("`source'","order","name","type","format","vallab","varlab","char") {;
  disp as error `"Invalid from() option: `from'"';
  error 498;
};
if "`source'"=="char" {;
  local charname: word 2 of `from';
  if "`charname'"=="" {;
    disp as error `"Invalid from() option: `from'"'
      _n as error "No characteristic name supplied";
    error 498;
  };
};
else {;
  local from `source';
};

*
 Create value label
*;
if "`replace'"!="" {;
  cap lab drop `namelist';
};
tempname firstval;
mata: varlabdef_addedlabelledvalue1("`namelist'","`firstval'");
local nvar: word count `vlist';
forv i1=1(1)`nvar' {;
  local i2=`firstval'+`i1'-1;
  local X: word `i1' of `vlist';
  if "`source'"=="order" {;
    local Xlab "`i1'";
  };
  else if "`source'"=="name" {;
    local Xlab "`X'";
  };
  else if "`source'"=="type" {;
    local Xlab: type `X';
  };
  else if "`source'"=="format" {;
    local Xlab: format `X';
  };
  else if "`source'"=="vallab" {;
    local Xlab: val lab `X';
  };
  else if "`source'"=="varlab" {;
    local Xlab: var lab `X';
  };
  else if "`source'"=="char" {;
    local Xlab `"``X'[`charname']'"';
  };
  qui lab def `namelist' `i2' `"`Xlab'"', modify `fix';
};

*
 Return results
*;
return local from `from';
return local vlist `"`vlist'"';
return scalar lastval=`firstval'+`nvar'-1;
return scalar firstval=`firstval';

end;

prog def vlistgen, rclass;
version 10.0;
/*
  Generate variable list
*/

syntax [ varlist ];
return local vlist "`varlist'";

end;

#delim cr
version 10.0
/*
  Private Mata programs
*/
mata:

void varlabdef_addedlabelledvalue1(string scalar labname,string scalar firstval)
{
/*
  Input label name in labname
  and output first value to add if extending the label
  to scalar with name stored in firstval.
*/
real scalar fval;
real vector existvals;
string vector existlabs;
/*
  fval will contain the first value to add.
  existvals will contain the existing values for the value label.
  existlabs will contain the existing labels for the value label.
*/

/*
  Calculate and return first value to add.
*/
if(!st_vlexists(labname)){
  fval=1;
}
else {
  st_vlload(labname,existvals,existlabs);
  fval=ceil(max(existvals))+1;
  if(missing(fval) | fval<=0){
    fval=1;
  }
}
st_numscalar(firstval,fval);

}

end
