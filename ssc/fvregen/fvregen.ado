#delim ;
prog def fvregen, rclass;
version 11.0;
/*
 Regenerate a newvarlist of factor variables
 from a parameter name variable containing e(b) column stripe elements.
*!Author: Roger Newson
*!Date: 19 February 2012
*/

syntax [ newvarlist(default=none) ] [if] [in] [,
  FRom(varlist string) DOfile(string) FMissing(name)
  ];
/*
  from() specifies the input parameter name variables
    (defaulting to parm as provided by a parmest resultsset).
  dofile() specifies the name of a do-file,
    possibly created using the dofile()option of the descsave package,
    to be executed after the factors have been created.
  fmissing() specifies a new variable to be generated,
    with missing values in observations excluded by the if and in qualifiers,
    zero values in observations with at least one monmissing value in a generated factor,
    and values of 1 in observations included by the if and in qualifiers
    with no nonmissing values in any generated factor.
*/


*
 Default parameter values
*;
if "`from'"=="" {;
  local from "parm";
  cap confirm string variable `from';
  if _rc!=0 {;
    disp as error "variable `from' not found";
    error 498;
  };
};


* Mark sample for use *;
marksample touse, novarlist;


* Count observations *;
local nobs=_N;


*
 Fill in the varlist from from() if not given
*;
if "`varlist'"=="" {;
  forv i1=1(1)`nobs' {;
    if `touse'[`i1'] {;
      foreach FR of var `from' {;
        local parmcur=`FR'[`i1'];
        cap _ms_parse_parts `"`parmcur'"';
        if _rc==0 {;
          local k_names=r(k_names);
          local mstype `"`r(type)'"';
          if `"`mstype'"'=="factor" {;
            local namecur `"`r(name)'"';
            local levcur=r(level);
            if !missing(`levcur') {;
              local varlist `"`varlist' `namecur'"';
            };
          };
          else if inlist(`"`mstype'"',"interaction","product") {;
            forv i2=1(1)`k_names' {;
              local namecur `"`r(name`i2')'"';
              local levcur=r(level`i2');
              if !missing(`levcur') {;
                local varlist `"`varlist' `namecur'"';
              };
            };
          };
          local varlist: list uniq varlist;
        };
      };
    };
  };
};  

*
 Create factor variables filled with missing values
*;
if "`varlist'"=="" {;
  disp as text "No factor variables generated";
  exit;
};
confirm new variable `varlist';
if _rc!=0 {;
  disp as error "Variables cannot be created: `varlist'";
  error 498;
};
foreach X of new `varlist' {;
  qui gene long `X'=.;
};


*
 Input the factor values from from()
*;
forv i1=1(1)`nobs' {;
  if `touse'[`i1'] {;
    foreach FR of var `from' {;
      local parmcur=`FR'[`i1'];
      cap _ms_parse_parts `"`parmcur'"';
      if _rc==0 {;
        local k_names=r(k_names);
        local mstype `"`r(type)'"';
        if `"`mstype'"'=="factor" {;
          local namecur `"`r(name)'"';
          local levcur=r(level);
          if !missing(`levcur') {;
            local toassign: list namecur in varlist;
            if `toassign' {;
              qui replace `namecur'=`levcur' in `i1';
            };
          };
        };
        else if inlist(`"`mstype'"',"interaction","product") {;
          forv i2=1(1)`k_names' {;
            local namecur `"`r(name`i2')'"';
            local levcur=r(level`i2');
            if !missing(`levcur') {;
              local toassign: list namecur in varlist;
              if `toassign' {;
                qui replace `namecur'=`levcur' in `i1';
              };
            };
          };
        };
      };
    };
  };
};


*
 Compress factor variables
*;
qui compress `varlist';


*
 Execute -dofile- if provided
*;
if `"`dofile'"'!="" {;
  run `"`dofile'"';
};


* Add -fmissing()- variable *;
if `"`fmissing'"'!="" {;
  conf new var `fmissing';
  qui gene byte `fmissing'=1 if `touse';
  foreach X of var `varlist' {;
    qui replace `fmissing'=0 if `touse' & !missing(`X');
  };
  lab var `fmissing' "Missing:`varlist'";
};


* Notify user of factor variables generated *;
disp as text "Factor variables generated:"
  _n as result "`varlist'";


* Returned results *;
return local varlist `"`varlist'"';


end;
