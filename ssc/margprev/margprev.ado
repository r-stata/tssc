#delim ;
prog def margprev, rclass;
version 14.0;
/*
  Estimate logit marginal prevalence (scenario proportion)
  from existing estimation results assumed to contain parameters
  of a model whose predicted values are proportions bounded between 0 and 1,
  and calculate confidence intervals for the marginal prevalence.
*|Author: Roger Newson
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
tempname cimat;
_margprev `if' `in' [`weight'`exp'] , `options' level(`level') cimatrix(`cimat');

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

if "`post'"=="" {;
 cap estimates restore `oldest';
};

end;

prog def _margprev, eclass;
version 14.0;
/*
  Estimate logit marginal prevalence (scenario proportion)
  from existing estimation results assumed to contain parameters
  of a model whose predicted values are conditional proportions bounded between 0 and 1,
  and calculate confidence intervals for the marginal prevalence.
*/

*
 Find last estimation command
*;
local cmd "`e(cmd)'";
if `"`cmd'"'=="" {;error 301;};

local options "EForm Level(cilevel) CImatrix(name)";
if "`cmd'"=="margprev" {;
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
  qui nlcom ("Scenario_1":logit(_b[_cons])), `iterate' `df' post;
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
  ereturn local predict "margprev_p";
  ereturn local cmdline `""';
  ereturn local cmd "margprev";
};

*
 Display estimation results
*;
if "`eform'"!="" {;
  local eformopt "eform(Odds)";
  disp as text "Scenario 1: " as result `"`atspec'"'  
    _n as text "Confidence interval for the marginal odds"
    _n "under Scenario 1";
};
else {;
  disp as text "Scenario 1: " as result `"`atspec'"'  
    _n as text "Symmetric confidence interval for the logit marginal prevalence"
    _n "under Scenario 1";
};
disp as text "Total number of observations used: " as result e(N);
ereturn display, `eformopt' level(`level');

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
matr def `cimatrix'=J(1,3,.);
matr rownames `cimatrix'="Scenario_1";
matr colnames `cimatrix'="Estimate" "Minimum" "Maximum";
tempname estscal lb ub hwid;
* Untransformed scenario proportion *;
scal `estscal'=`estmat'[1,1];
scal `hwid'=`varmat'[1,1];
scal `hwid'=sqrt(`hwid')*`mult';
scal `lb'=`estscal'-`hwid';
scal `ub'=`estscal'+`hwid';
foreach Y in `estscal' `lb' `ub' {;
  scal `Y'=invlogit(`Y');
};
matr def `cimatrix'[1,1]=`estscal';
matr def `cimatrix'[1,2]=`lb';
matr def `cimatrix'[1,3]=`ub';

*
 Display CI matrix
*;
disp _n as text "Asymmetric `level'% CI for the untransformed marginal prevalence"
  _n "under Scenario 1";
matlist `cimatrix', noheader noblank nohalf lines(none) names(all) format(%9.0g);

end;
