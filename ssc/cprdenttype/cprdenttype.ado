#delim ;
prog def cprdenttype, rclass;
version 13.0;
*
 Extract entity attributes for a CPRD enttype
 from an entity lookup dataset.
*!Author: Roger Newson
*!Date: 26 October 2017
*;

syntax anything(name=enttype id="enttype") using , [ LLOOkuplist(name) LDESclist(name) ];
/*
 enttype specifies the input CPRD enttype.
 llookuplist specifies the name of a local macro to store the lookup list.
 ldesclist specifies the name of a local macro to store the description list.
*/

*
 Check that enttype is valid
*;
cap conf integer number `enttype';
if _rc {;
  disp as error "Invalid enttype specified - must be integer number";
  error 498;
};

preserve;

*
 Input entity data record for enttype
*;
use if enttype==`enttype' `using', clear;
if _N==0 {;
  disp as error "No observations in using dataset with enttype==`enttype'";
  error 498;
};
qui drop if _n>1;

*
 Extract attribute lists
*;
cap local description=description[1];
cap local filetype=filetype[1];
cap local category=category[1];
local data_fields=data_fields[1];
local lookuplist "";
local desclist "";
forv i1=1(1)`data_fields' {;
  local lookupcur=data`i1'_lkup[1];
  cap conf var data`i1';
  if _rc {;
    local desccur=data`i1'_desc[1];
  };
  else {;
    local desccur=data`i1'[1];
  };
  local lookuplist `"`lookuplist' `"`lookupcur'"'"';
  local desclist `"`desclist' `"`desccur'"'"';
};
local lookuplist: list retokenize lookuplist;
local desclist: list retokenize desclist;

restore;

*
  Set local macro options
*;
foreach X in lookuplist desclist {;
  if "`l`X''"!="" {;
    c_local `l`X'' `"``X''"';
  };
};

*
 Return results
*;
return local lookuplist `"`lookuplist'"';
return local desclist `"`desclist'"';
return scalar data_fields=`data_fields';
return scalar enttype=`enttype';
return local category `"`category'"'; 
return local filetype `"`filetype'"';
return local description `"`description'"';

*
 Display non-list results
*;
foreach X in enttype description filetype category data_fields {;
  if `"``X''"'!="" {;
    disp as text "`X': " as result `"``X''"';
  };
};
end;
