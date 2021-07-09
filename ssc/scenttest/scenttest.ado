#delim ;
prog def scenttest, rclass;
version 14.0;
/*
  Estimate scenario arithmetic (or geometric) means
  and their difference (or ratio)
  from existing estimation results assumed to contain parameters
  of a model whose predicted values are conditional arithmetic means.
*!Author: Roger Newson
*!Date: 03 September 2015
*/

syntax [if] [in] [pweight aweight fweight iweight], [ , Level(cilevel) post * ];

if "`post'"=="" {;
 tempname oldest;
 cap estimates store `oldest';
};

*
 Create estimation results
*;
_scenttest `if' `in' [`weight'`exp'] , `options' level(`level');

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
return local atzero `"`e(atzero)'"';

if "`post'"=="" {;
 cap estimates restore `oldest';
};

end;

prog def _scenttest, eclass;
version 14.0;
/*
  Estimate logit scenario proportions and z-transformed population attributable risk
  from existing estimation results assumed to contain parameters
  of a model whose predicted values are conditional proportions bounded between 0 and 1,
  and calculate confidence intervals for the population proportions
  and the untransformed population attributable risk.
*/

*
 Find last estimation command
*;
local cmd "`e(cmd)'";
if `"`cmd'"'=="" {;error 301;};

local options "EForm Level(cilevel)";
if "`cmd'"=="scenttest" {;
  * Replay old estimation results *;
  syntax [, `options'];
};
else {;
  * Create new estimation results *;
  syntax [if] [in] [pweight aweight fweight iweight], [ ATspec(string asis) ATZero(string asis)
    `options' subpop(passthru) PRedict(passthru) vce(passthru) df(passthru) noEsample FORCE ITERate(passthru)
    ];
  *
   Assign default atspec() and atzero() options
   and check that each one returns only 1 scenario
  *;
  foreach AO in atzero atspec {;
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
  if `"`atspec'"'=="" & `"`atzero'"'=="" {;
   disp as error "Scenarios cannot be compared after a constant-only model";
   error 498;
  };
  marksample touse;
  qui margins if `touse' [`weight'`exp'], at(`atzero') at(`atspec') `subpop' `predict' `vce' `df' `esample' `force' post;
  * Collect scalar e-results from margins *;
  local mscalars: e(scalars);
  local i1=0;
  foreach ename in `mscalars' {;
    local i1=`i1'+1;
    tempname ms_`i1';
    scal `ms_`i1''=e(`ename');
  };
  qui nlcom ("Scenario_0":_b[1._at]) ("Scenario_1":_b[2._at]) ("Comparison":_b[1._at]-_b[2._at]), `iterate' `df' post;
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
  ereturn local atzero `"`atzero'"';
  ereturn local predict "scenttest_p";
  ereturn local cmdline `""';
  ereturn local cmd "scenttest";
};

*
 Display estimation results
*;
if "`eform'"!="" {;
  local eformopt "eform(GM/Ratio)";
  disp as text "Scenario 0: " as result `"`atzero'"'
    _n as text "Scenario 1: " as result `"`atspec'"'
    _n as text "Confidence intervals for the geometric means under Scenario 0 and Scenario 1"
    _n as text "and for their comparison (geometric mean ratio)";
};
else {;
  local eformopt "";
  disp as text "Scenario 0: " as result `"`atzero'"'
    _n as text "Scenario 1: " as result `"`atspec'"'  
    _n as text "Confidence intervals for the arithmetic means under Scenario 0 and Scenario 1"
    _n as text "and for their comparison (arithmetic mean difference)";
};
disp as text "Total number of observations used: " as result e(N);
ereturn display, `eformopt' level(`level');

end;
