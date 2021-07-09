#delim ;
prog def lincomest, eclass;
version 10.0;
/*
 Call lincom, saving estimation results,
 and optionally holding the existing ones in a specified holdname.
*! Author: Roger Newson
*! Date: 18 July 2016
*/

*
 Extract formula and leave command line ready to be syntaxed
*;
gettoken token 0 : 0, parse(",= ");
while `"`token'"'!="" & `"`token'"'!="," {;
  if `"`token'"' == "=" {;
    di in red _quote "=" _quote " not allowed in expression";
    exit 198;
  };
  local formula `"`formula'`token'"';
  gettoken token 0 : 0, parse(",= ");
};
local 0 `",`0'"';

*
 Replay if -formula- is empty
 otherwise input -formula- to lincom
 and store the result in estimation results
*;
if `"`formula'"'=="" {;
  * Beginning of replay section *;
  if "`e(cmd)'"!="lincomest" {;error 301;};
  syntax [, EForm(passthru) Level(integer $S_level) ];
  * End of replay section *;
};
else{;
  *
   Beginning of non-replay section
  *;

  *
   Extract options *;
  *;
  syntax [ , HOldname(string) EForm(passthru) Level(integer $S_level) ];

  * Check that -holdname- is valid *;
  if `"`holdname'"'!="" {;
    cap confirm names `holdname';
    local retcode=_rc;
    if `retcode'!=0 {;
      disp as error "Invalid holdname:" _n `"`holdname'"';
      error 198;
    };
  };

  *
   Determine if the last estimation command belongs to the -svy- class
  *;
  is_svy;
  local is_svy=r(is_svy);

  *
   Call lincom in non-eform mode
   to extract non-eform estimate and SE
  *;
  qui lincom `formula', level(`level');

  * Extract estimation output *;
  local depname `"`e(depvar)'"';
  tempvar esample;
  tempname npsu;
  local obs=e(N);
  local dof=e(df_r);
  scal `npsu'=e(N_clust);
  gene byte `esample'=e(sample);

  * Extract output to lincom *;
  tempname estimate se vari;
  scal `estimate'=r(estimate);
  *
   In Stata 8, -lincom- after a -sv- command stores the estimate
   in -r(est)- instead of -r(estimate)-
  *;
  if missing(`estimate') {;scal `estimate'=r(est);};
  scal `se'=r(se);
  *
   Correct estimate and standard error if -logistic- has been invoked
   (because -lincom- saves the exponentiated parameter
   and its asymptotic standard error after -lincomest- has been invoked,
   even if the user does not specify any -eform()--like options).
  *;
  if "`e(cmd)'"=="logistic" {;
    scal `se'=`se'/`estimate';
    scal `estimate'=log(`estimate');
    if `"`eform'"'=="" {;
      local eform "eform(Odds Ratio)";
    };
  };
  scal `vari'=`se'*`se';
  * Extra -lincom- output for -svy- class commands *;
  if `is_svy' {;
    local svyscal "N_strata N_psu deff deft meft";
    tempname `svyscal';
    foreach X in `svyscal' {;
      scal ``X''=r(`X');
    };
  };

  * Create estimation and covariance matrices *;
  tempname beta vcov;
  matr def `beta'=J(1,1,0);
  matr def `vcov'=J(1,1,0);
  matr def `beta'=`estimate';
  matr def `vcov'=`vari';
  matr rownames `beta'="y1";
  matr colnames `beta'="(1)";
  matr rownames `vcov'="(1)";
  matr colnames `vcov'="(1)";

  * Replace estimates *;
  nobreak {;
    if "`holdname'"!="" {;
      _estimates hold `holdname';
    };
    if missing(`obs') {;local obsopt "";};else{;local obsopt "obs(`obs')";};
    if missing(`dof') {;local dofopt "";};else{;local dofopt "dof(`dof')";};
    ereturn post `beta' `vcov', `obsopt' `dofopt' esample(`esample');
    ereturn local cmdline `"lincomest `formula' `0'"';
    ereturn local cmd "lincomest";
    ereturn local depvar "`depname'";
    ereturn local predict "lincomest_p";
    ereturn local formula `"`formula'"';
    ereturn local holdname "`holdname'";
    if !missing(`dof') {;ereturn scalar df_r=`dof';};
    if !missing(`npsu'){;ereturn scalar N_clust=`npsu';};
    * Extra estimation results for -svy- class commands *;
    if `is_svy' {;
      foreach X in `svyscal' {;
        ereturn scalar `X'=``X'';
      };
    };
  };

  *
   End of non-replay section
  *;
};

*
 Check level
*;
if (`level'<10)|(`level'>99) {;
  disp as err "level() must be between 10 and 99 inclusive";
  exit 198;
};

* Display estimates *;
local eformopt="";
disp as text "Confidence interval for formula:" _n as result "`e(formula)'" _n;
ereturn disp, `eform' level(`level');

end;
