#delim ;
prog def marglmean, rclass;
version 14.0;
/*
  Estimate marginal log mean (scenario log mean)
  from existing estimation results assumed to contain parameters
  of a model whose predicted values
  are positive conditional arithmetic means.
*! Author: Roger Newson
*! Date: 03 September 2015
*/

syntax [if] [in] [pweight aweight fweight iweight], [ , Level(cilevel) post * ];

if "`post'"=="" {;
 tempname oldest;
 cap estimates store `oldest';
};

*
 Create estimation results
*;
_marglmean `if' `in' [`weight'`exp'] , `options' level(`level');

*
 Copy e() results to r()
*;
return scalar level=`level';
local mscalars: e(scalars);
local nmscalar: word count `mscalars';
forv i1=`nmscalar'(-1)1 {;
  tempname ms_`i1';
  local ename: word `i1' of `mscalars';
  scal `ms_`i1''=e(`ename');
  if !missing(`ms_`i1'') {;
    return scalar `ename'=`ms_`i1'';
  };
};
tempname btemp Vtemp;
matr def `btemp'=e(b);
matr def `Vtemp'=e(V);
return matrix V=`Vtemp';
return matrix b=`btemp';
return local atspec `"`e(atspec)'"';

if "`post'"=="" {;
 cap estimates restore `oldest';
};

end;

prog def _marglmean, eclass;
version 14.0;
/*
  Estimate marginal log mean (scenario log mean)
  from existing estimation results assumed to contain parameters
  of a model whose predicted values
  are positive conditional arithmetic means.
*/

*
 Find last estimation command
*;
local cmd "`e(cmd)'";
if `"`cmd'"'=="" {;error 301;};

local options "EForm Level(cilevel)";
if "`cmd'"=="marglmean" {;
  * Replay old estimation results *;
  syntax [, `options'];
};
else {;
  * Create new estimation results *;
  syntax [if] [in] [pweight aweight fweight iweight], [ ATspec(string asis)
    `options' subpop(passthru) PRedict(passthru) vce(passthru) df(passthru) noEsample force ITERate(passthru)
    ];
  *
   Assign default atspec() option
   and check that it returns only 1 scenario
  *;
  foreach AO in atspec {;
    cap _ms_at_parse ``AO'', asobserved;
    if _rc {;
      disp _n as error `"Invalid at-specification - `AO'(``AO'')"';
      error 498;
    };
    else {;
      cap conf matrix r(at);
      if !_rc {;
        local AOrows=rowsof(r(at));
        if `AOrows'>1 {;
          disp _n as error `"Option `AO'(``AO'') returns `AOrows' scenarios"'
            _n "Only 1 scenario allowed";
          error 498;
        };
        if `"``AO''"'=="" {;
          local `AO' "(asobserved) _all";
        };       
      };
    };
  };
  marksample touse;
  qui margins if `touse' [`weight'`exp'], at(`atspec') `subpop' `predict' `vce' `df' `esample' `force' post;
  * Collect scalar e-results from margins *;
  local mscalars: e(scalars);
  local i1=0;
  foreach ename in `mscalars' {;
    local i1=`i1'+1;
    tempname ms_`i1';
    scal `ms_`i1''=e(`ename');
  };
  qui nlcom ("Scenario_1":log(_b[_cons])), `iterate' `df' post;
  * Post scalar e-results from margins *;
  local nmscalar: word count `mscalars';
  forv i1=`nmscalar'(-1)1 {;
    local ename: word `i1' of `mscalars';
    if !missing(`ms_`i1'') {;
      ereturn scalar `ename'=`ms_`i1'';
    };
  };
  * Post local e-results *;
  ereturn local atspec `"`atspec'"';
  ereturn local predict "marglmean_p";
  ereturn local cmdline `""';
  ereturn local cmd "marglmean";
};

*
 Display estimation results
*;
if "`eform'"!="" {;
  local eformopt "eform(Mean)";
  disp as text "Scenario 1: " as result `"`atspec'"'  
    _n as text "Asymmetric confidence interval for the marginal mean"
    _n "under Scenario 1";
};
else {;
  disp as text "Scenario 1: " as result `"`atspec'"'  
    _n as text "Symmetric confidence interval for the log marginal mean"
    _n "under Scenario 1";
};
disp as text "Total number of observations used: " as result e(N);
ereturn display, `eformopt' level(`level');

end;
