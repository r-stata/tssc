#delim ;
prog def regpar, rclass;
version 14.0;
/*
  Estimate logit scenario proportions
  and z-transformed population attributable risk
  from existing estimation results assumed to contain parameters
  of a model whose predicted values are proportions bounded between 0 and 1,
  and calculate confidence intervals for the scenario proportions
  and the untransformed population attributable risk.
*|Author: Roger Newson
*!Date: 03 September 2015.
*/

syntax [if] [in] [pweight aweight fweight iweight], [ , Level(cilevel) post * ];

if "`post'"=="" {;
 tempname oldest;
 cap estimates store `oldest';
};

*
 Create estimation results
*;
tempname cimat;
_regpar `if' `in' [`weight'`exp'] , `options' level(`level') cimatrix(`cimat');

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
return matrix cimat=`cimat';
return local atspec `"`e(atspec)'"';
return local atzero `"`e(atzero)'"';

if "`post'"=="" {;
 cap estimates restore `oldest';
};

end;

prog def _regpar, eclass;
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

local options "Level(cilevel) CImatrix(name)";
if "`cmd'"=="regpar" {;
  * Replay old estimation results *;
  syntax [, `options'];
};
else {;
  * Create new estimation results *;
  syntax [if] [in] [pweight aweight fweight iweight], [ ATspec(string asis) ATZero(string asis)
    `options' subpop(passthru) PRedict(passthru) vce(passthru) df(passthru) noEsample force ITERate(passthru)
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
  qui nlcom ("Scenario_0":logit(_b[1._at])) ("Scenario_1":logit(_b[2._at])) ("PAR":atanh(_b[1._at]-_b[2._at])), `iterate' `df' post;
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
  ereturn local predict "regpar_p";
  ereturn local cmdline `""';
  ereturn local cmd "regpar";
};

*
 Display estimation results
*;
disp as text "Scenario 0: " as result `"`atzero'"'
  _n as text "Scenario 1: " as result `"`atspec'"'  
  _n as text "Symmetric confidence intervals for the logit proportions"
    _n "under Scenario 0 and Scenario 1"
  _n as text "and for the z-transformed population attributable risk (PAR)";
disp as text "Total number of observations used: " as result e(N);
ereturn display, level(`level');

*
 Calculate CI matrix
*;
if "`cimatrix'"=="" {;
  tempname cimatrix;
};
* Define multiplier for creation of confidence intervals *;
tempname mult clfloat;
scal `clfloat'=`level'/100;
if !missing(e(df_r)) {;
  * Student's t-distribution *;
  local dof=e(df_r);
  scal `mult'=invttail(`dof',0.5*(1-`clfloat'));
};
else {;
  * Normal distribution *;
  scal `mult'=invnormal(0.5*(1+`clfloat'));
};
* Extract estimates amd standard errors for untransformed parameters *;
tempname estmat varmat;
matr def `estmat'=e(b);
matr def `varmat'=e(V);
matr def `cimatrix'=J(3,3,.);
matr rownames `cimatrix'="Scenario_0" "Scenario_1" "PAR";
matr colnames `cimatrix'="Estimate" "Minimum" "Maximum";
tempname estscal lb ub hwid;
* Untransformed scenario proportions *;
forv i1=1(1)2 {;
  scal `estscal'=`estmat'[1,`i1'];
  scal `hwid'=`varmat'[`i1',`i1'];
  scal `hwid'=sqrt(`hwid')*`mult';
  scal `lb'=`estscal'-`hwid';
  scal `ub'=`estscal'+`hwid';
  foreach Y in `estscal' `lb' `ub' {;
    scal `Y'=invlogit(`Y');
  };
  matr def `cimatrix'[`i1',1]=`estscal';
  matr def `cimatrix'[`i1',2]=`lb';
  matr def `cimatrix'[`i1',3]=`ub';
};
* Untransformed PAR *;
scal `estscal'=`estmat'[1,3];
scal `hwid'=`varmat'[3,3];
scal `hwid'=sqrt(`hwid')*`mult';
scal `lb'=`estscal'-`hwid';
scal `ub'=`estscal'+`hwid';
foreach Y in `estscal' `lb' `ub' {;
  scal `Y'=tanh(`Y');
};
matr def `cimatrix'[3,1]=`estscal';
matr def `cimatrix'[3,2]=`lb';
matr def `cimatrix'[3,3]=`ub';

*
 Display CI matrix
*;
disp _n as text "Asymmetric `level'% CIs for the untransformed proportions"
  _n "under Scenario 0 and Scenario 1"
  _n "and for the untransformed population attributable risk (PAR)";
matlist `cimatrix', noheader noblank nohalf lines(none) names(all) format(%9.0g);

end;
