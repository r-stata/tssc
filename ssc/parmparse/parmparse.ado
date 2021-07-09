#delim ;
prog def parmparse, rclass;
version 11.0;
/*
 Parse a parameter name variable
 with the format of Stata estimation parameter names,
 as produced by parmest,
 and output variables extracted from the results returned
 by _ms_parse_parts.
*!Author: Roger Newson
*!Date: 03 August 2011
*/

syntax varname(string default=none) [if] [in] [,
  OMit(name) TYpe(name) NAme(name) BAse(name) LEvel(name) OP(name) TSop(name)
  DElimiter(string)
  fast
  ];
/*
  omit() specifies an output numeric variable,
    indicating parameter omit status.
  type() specifies an output type variable,
    containing parameter type
    (eg variable, error, factor, interaction, or product).
  name() contains a list of names of variables involved in the parameter.
  base() specifies an output base list variable,
    containing a list of indicators (1 or 0) of baseline status
    for the variables listed in name().
  level() specifies an output variable
    containing a list of integer factor levels
    corresponding to the variables listed in name().
  op() specifies an output variable
    containing a list of full operator portions
    corresponding to the variables listed in name().
  tsop() specifies an output variable
    containing a list of time series operator portions
    corresponding to the variables listed in name().
  delimiter() specifies a delimiter string
    used to separate elements in the list output variables.
  fast specifies that Stata will not restore the original dataset
    in the event of failure.
*/


local parmvar `varlist';


*
 Default parameter values
*;
if `"`delimiter'"'=="" {;
  local delimiter " ";
};
foreach V in omit type name base level op tsop {;
  if "``V''"=="" {;
    tempvar `V';
  };
};


if "`fast'"=="" {;preserve;};


* Mark sample for use *;
marksample touse, novarlist;


* Count observations *;
local nobs=_N;

*
 Assign variables
*;
qui gene byte `omit'=.;
foreach V in type name base level op tsop {;
  qui gene str1 ``V''="";
};
lab var `omit' "Parameter omit status";
lab var `type' "Parameter matrix stripe element type";
lab var `name' "Parameter name portion list";
lab var `base' "Parameter base status list";
lab var `level' "Parameter factor level list";
lab var `op' "Parameter full operator portion list";
lab var `tsop' "Parameter ts operator portion list";
forv i1=1(1)`nobs' {;
  if `touse'[`i1'] {;
    local parmcur=`parmvar'[`i1'];
    cap _ms_parse_parts `"`parmcur'"';
    if _rc==0 {;
      * Variables can be reassigned *;
      qui replace `omit'=r(omit) in `i1';
      qui replace `type'=r(type) in `i1';
      if inlist(r(type),"variable","error","factor") {;
        * Unique returned results *;
        qui {;
          replace `name'=r(name) in `i1';
          replace `base'=string(r(base)) in `i1';
          replace `level'=string(r(level)) in `i1';
          replace `op'=`"`r(op)'"' in `i1';
          replace `tsop'=`"`r(ts_op)'"' in `i1';
        };
      };
      else if inlist(r(type),"interaction","product") {;
        * Multiple returned results *;
        local k_names=r(k_names);
        qui {;
          replace `name'=r(name1) in `i1';
          replace `base'=string(r(base1)) in `i1';
          replace `level'=string(r(level1)) in `i1';
          replace `op'=`"`r(op1)'"' in `i1';
          replace `tsop'=`"`r(ts_op1)'"' in `i1';
          forv i2=2(1)`k_names' {;
            replace `name'=`name'+`"`delimiter'"'+r(name`i2') in `i1';
            replace `base'=`base'+`"`delimiter'"'+string(r(base`i2')) in `i1';
            replace `level'=`level'+`"`delimiter'"'+string(r(level`i2')) in `i1';
            replace `op'=`op'+`"`delimiter'"'+`"`r(op`i2')'"' in `i1';
            replace `tsop'=`tsop'+`"`delimiter'"'+`"`r(ts_op`i2')'"' in `i1';
          };
        };
      };
    };
  };
};


if "`fast'"=="" {;restore, not;};


end;
