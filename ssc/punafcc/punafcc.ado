#delim ;
prog def punafcc, rclass;
version 14.0;
/*
  Estimate log scenario rate ratios and log population unattributable fractions
  from existing estimation results assumed to contain parameters
  of a model whose predicted values are case-control or survival rate ratios that can be logged,
  and calculate a confidence interval for the population attributable fraction.
*! Author: Roger Newson
*! Date: 08 December 2016
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
_punafcc `if' `in' [`weight'`exp'] , `options' level(`level') cimatrix(`cimat');

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
return local exp_atspec `"`e(exp_atspec)'"';
return local exp_atzero `"`e(exp_atzero)'"';
return local atspec `"`e(atspec)'"';
return local atzero `"`e(atzero)'"';

if "`post'"=="" {;
 cap estimates restore `oldest';
};

end;

prog def _punafcc, eclass;
version 14.0;
/*
  Estimate log scenario rate ratios and log population unattributable fractions
  from existing estimation results assumed to contain parameters
  of a model whose predicted values are conditional rate ratios that can be logged,
  and calculate a confidence interval for the population attributable fraction.
*/

*
 Find last estimation command
*;
local cmd "`e(cmd)'";
if `"`cmd'"'=="" {;error 301;};

local options "EForm Level(cilevel) CImatrix(name)";
if "`cmd'"=="punafcc" {;
  * Replay old estimation results *;
  syntax [, `options'];
};
else {;
  * Create new estimation results *;
  
  syntax [if] [in] [pweight aweight fweight iweight], [
    ATspec(string asis)
    subpop(string asis)
    `options'  vce(passthru) df(passthru) noEsample force ITERate(passthru)
    ];

  *
   Assign default atspec() and atzero() options
   and check that each one returns only 1 scenario
   and only specifies as-observed or a constant value
   for a factor or variable
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
        local statlist `"`r(statlist)'"';
        foreach STAT in `statlist' {;
          if !inlist("`STAT'","asobserved","value","values") {;
            disp _n as error `"Option `AO'(``AO'') specifies disallowed statistic:"'
              _n as error `"`STAT'"';
            error 498;
          };
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

  *
   Create subpopulation indicator variable
   identifying observations in the input subpop() subpopulation
   which are also cases or deaths
  *;
  tempvar subpopind subpopind1 subpopind2;
  * Generate subpopind1 from case or death variable *;
  if inlist(`"`e(cmd2)'"',"stcox","stcrreg") | (`"`e(cmd2)'"'=="" & inlist(`"`e(cmd)'"',"stcox","stcrreg")) {;
    qui gene `subpopind1'=_d if `touse';
  };
  else {;
    cap conf numeric var `e(depvar)';
    if _rc {;
      disp _n as error "Valid dependent variable e(depvar) not available";
      error 498;
    };
    qui gene `subpopind1'=`e(depvar)' if `touse';
  };
  qui compress `subpopind1';
  * Generate subpopind2 from supplied subpop() option *;
  local subpopvar: word 1 of `subpop';
  cap conf numeric var `subpopvar';
  if _rc {;
    local subpopopt `"1 `subpop'"';
  };
  else {;
    local subpopopt `"`subpop'"';
  };
  cap gene `subpopind2'=`subpopopt';
  if _rc {;
    disp _n as error "Invalid subpop() option";
    error 498;
  };
  qui compress `subpopind2';
  * Create subpopind from subpopind1 and subpopind2 *;
  qui gene byte `subpopind'=`subpopind1' & `subpopind2' if !missing(`subpopind1') & !missing(`subpopind2');
  qui compress `subpopind';

  *
   Create expression() options for at-specifications for margins
  *;
  tempname atmat bscenmat scenval;
  matr def `bscenmat'=e(b);
  local BScols=colsof(`bscenmat');
  local BSnames: colnames `bscenmat';
  foreach AO in atzero atspec {;
    _ms_at_parse ``AO'', asobserved;
    matr def `atmat'=r(at);
    local AOcols=colsof(`atmat');
    local AOnames: colnames `atmat';
    local exp_`AO' "";
    forv i1=1(1)`BScols' {;
      * Extract variable names and factor levels *;
      local BScolcur: word `i1' of `BSnames';
      _ms_parse_parts `BScolcur';
      if inlist("`r(type)'","interaction","product") {;
        local BScurk_names=r(k_names);
        local BScurnames "";
        local BScurlevels "";
        forv i2=1(1)`BScurk_names' {;
          local BScurnames `"`BScurnames' `r(name`i2')'"';
          local BScurlevels `"`BScurlevels' `r(level`i2')'"';
        };
      };
      else {;
        local BScurk_names=1;
        local BScurnames `"`r(name)'"';
        local BScurlevels `"`r(level)'"';
      };
      * Evaluate scenario value of factor varlist element *;
      scal `scenval'=.;
      forv i2=1(1)`AOcols' {;
        local AOnamecur: word `i2' of `AOnames';
        _ms_parse_parts `AOnamecur';
        local namecur2 "`r(name)'";
        local levelcur2 "`r(level)'";
        forv i3=1(1)`BScurk_names' {;
          local namecur3: word `i3' of `BScurnames';
          local levelcur3: word `i3' of `BScurlevels';
          if (`"`namecur3'"'==`"`namecur2'"') & (`"`levelcur3'"'==`"`levelcur2'"') {;
            if missing(`scenval') {;
              scal `scenval'=el(`atmat',1,`i2');
            };
            else {;
              scal `scenval'=`scenval'*el(`atmat',1,`i2');
            };
          };
        };
      };
      * Update expression if appropriate *;
      if !missing(`scenval') {;
        local exp_`AO' `"`exp_`AO'' + _b[`BScolcur']*(`=`scenval''-`BScolcur')"';
      };
    };
    * Finalize expression *;
    local exp_`AO' `"exp(0`exp_`AO'')"';
  };  

  *
   Create estimation results
  *;
  qui margins if `touse' [`weight'`exp'], exp(`exp_atspec') subpop(`subpopind') `vce' `df' `esample' `force' post;
  * Collect scalar e-results from margins *;
  local mscalars: e(scalars);
  local i1=0;
  foreach rname in `mscalars' {;
    local i1=`i1'+1;
    tempname ms_`i1';
    scal `ms_`i1''=e(`rname');
  };
  qui nlcom ("PUF":log(_b[_cons])), `iterate' `df' post;
  * Post scalar e-results from margins *;
  local nmscalar: word count `mscalars';
  forv i1=`nmscalar'(-1)1 {;
    local ename: word `i1' of `mscalars';
    if !missing(`ms_`i1'') {;
      ereturn scalar `ename'=`ms_`i1'';
    };
  };
  * Post local e-results *;
  ereturn local exp_atspec `"`exp_atspec'"';
  ereturn local exp_atzero `"`exp_atzero'"';
  ereturn local atspec `"`atspec'"';
  ereturn local atzero `"`atzero'"';
  ereturn local predict "punafcc_p";
  ereturn local cmdline `""';
  ereturn local cmd "punafcc";

};

*
 Display estimation results
*;
if "`eform'"!="" {;
  local eformopt "eform(Ratio)";
  disp as text "Scenario 0: " as result `"`atzero'"'
    _n as text "Scenario 1: " as result `"`atspec'"'
    _n as text "Confidence interval for the population unattributable faction (PUF)";
};
else {;
  local eformopt "";
  disp as text "Scenario 0: " as result `"`atzero'"'
    _n as text "Scenario 1: " as result `"`atspec'"'  
    _n as text "Confidence interval for the log population unattributable faction (PUF)";
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
* Extract estimate amd standard error for log PUF *;
tempname estmat varmat;
matr def `estmat'=e(b);
matr def `varmat'=e(V);
tempname estscal lb ub hwid;
scal `estscal'=`estmat'[1,1];
scal `hwid'=`varmat'[1,1];
scal `hwid'=sqrt(`hwid')*`mult';
scal `ub'=`estscal'-`hwid';
scal `lb'=`estscal'+`hwid';
foreach Y in `estscal' `lb' `ub' {;
  scal `Y'=1-exp(`Y');
};
matr def `cimatrix'=J(1,3,.);
matr rownames `cimatrix'="PAF";
matr colnames `cimatrix'="Estimate" "Minimum" "Maximum";
matr def `cimatrix'[1,1]=`estscal';
matr def `cimatrix'[1,2]=`lb';
matr def `cimatrix'[1,3]=`ub';

*
 Display CI matrix
*;
disp _n as text "`level'% CI for the population attributable fraction (PAF)";
matlist `cimatrix', noheader noblank nohalf lines(none) names(all) format(%9.0g);

end;
