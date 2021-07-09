#delim ;
prog def cprdentcode, rclass;
version 13.0;
*
 Decode a list of CPRD entity data variables
 to a list of numeric variables,
 using a lookup list and (optionally) a description list.
 Add-on packages required:
 chardef
*!Author: Roger Newson
*!Date: 15 May 2019
*;

syntax [if] [in], Generate(name) [ LOOkuplist(string asis) DESclist(string asis) DOfile(string) float ];
/*
 generate() specifies a stub to prefix the output numeric variables.
 lookuplist() specifies a lookup list to guide the encoding.
 desclist() specifies a description list to provide output variable labels.
 dofile() specifies a do-file to define the value labels.
 float specifies that non-date variables will have maximum precision of float.
*/

marksample touse, novarlist;

* Count lookups *;
local Nlookup: word count `lookuplist';

*
 Define value labels if dofile() is specified
*;
if `"`dofile'"'!="" {;
  run `dofile';
};

*
 Decode data variables to decoded output variables
*;
local cdatalist "";
forv i1=1(1)`Nlookup' {;
  local desccur: word `i1' of `desclist';
  local lookupcur: word `i1' of `lookuplist';
  local lookupcur=lower(trim(`"`lookupcur'"'));
  tempvar cdatacur;
  cap conf string var data`i1';
  if !_rc {;
    if "`lookupcur'"=="dd/mm/yyyy" {;
      qui {;
        gene long `cdatacur'=date(data`i1',"DMY") if `touse';
        compress `cdatacur';
        format `cdatacur' %tdCCYY/NN/DD;
      };
    };
    else if "`lookupcur'"=="hhmm" {;
      qui {;
        gene `cdatacur'=data`i1' if `touse';
        destring `cdatacur', force replace `float';
        charundef `cdatacur';
        replace `cdatacur'=hms(int(`cdatacur'/100),mod(`cdatacur',60),0) if `touse';
        compress `cdatacur';
        format `cdatacur' %tcHH:MM;       
      };
    };
    else if length(`"`lookupcur'"')<=4 & strtoname(`"`lookupcur'"')==`"`lookupcur'"' {;
      qui {;
        gene `cdatacur'=data`i1' if `touse';
        destring `cdatacur', force replace `float';
        charundef `cdatacur';
        cap lab val `cdatacur' `lookupcur';
      };
    };
    else {;
      qui {;
        gene `cdatacur'=data`i1' if `touse';
        destring `cdatacur', force replace `float';
        charundef `cdatacur';
      };
    };
  };
  cap compress `cdatacur';
  cap char `cdatacur'[lookup] `"`lookupcur'"';
  cap lab var `cdatacur' `"`desccur'"';
  local cdatalist "`cdatalist' `cdatacur'";
};

*
 Remove non-existent value labels for new variables
*;
if "`cdatalist'"!="" {;
  foreach X of var `cdatalist' {;
    local Xvallab: val lab `X';
    if "`Xvallab'"!="" {;
      mata: st_local("labpres",strofreal(st_vlexists("`Xvallab'")));
      if !`labpres' lab val `X';
    };
  };
};

*
 Rename and list decoded output variables
*;
local newvars "";
forv i1=1(1)`Nlookup' {;
  local Xcur: word `i1' of `cdatalist';
  cap conf numeric var `Xcur';
  if !_rc {;
    rename `Xcur' `generate'`i1';
    local newvars "`newvars' `generate'`i1'";
  };
};
local newvars: list retokenize newvars;

*
 Return results
*;
return local newvars "`newvars'";

*
 Display output variables
*;
if "`newvars'"=="" {;
  disp as text "Note: No new variables generated.";
};
else {;
  desc `newvars', fu;
};

end;
