#delim ;
prog def xglm, eclass byable(recall) prop(ml_score swml svyb svyj svyr mi);
version 13.0;
*
 Extended version of glm
 with added estimation results
*!Author: Roger Newson
*!Date: 17 March 2016
*;

if(replay()){;
*
 Beginning of replay section (not indented)
*;

if "`e(cmd)'"!="glm"{;error 301;};
if _by() {;error 190;};
syntax [, Level(cilevel) EForm ];
glm, level(`level') `eform';

*
 End of replay section (not indented)
*;
};
else{;
*
 Beginning of non-replay section (not indented)
*;

syntax varlist(numeric fv ts) [if] [in] [fweight pweight iweight aweight] [, Level(cilevel) EForm * ];
marksample touse;
glm `varlist' if `touse' [`weight'`exp'] , level(`level') `eform' `options';
* Change e(cmdline) (but not e(cmd)) to refer to xglm *;
ereturn local cmdline `"xglm `0'"';
* Add e(depvarsum) *;
local yvar "`e(depvar)'";
if "`e(wtype)'"=="fweight" {;
  qui summ `yvar' [`e(wtype)'`e(wexp)'] if e(sample), meanonly;
};
else {;
  qui summ `yvar' if e(sample), meanonly;
};
ereturn scalar depvarsum=r(sum);
* Add e(msum) *;
if `"`e(m)'"'!="" {;
  tempvar mvar;
  qui gene long `mvar'=`e(m)';
  qui compress `mvar';
  if "`e(wtype)'"=="fweight" {;
    qui summ `mvar' [`e(wtype)'`e(wexp)'] if e(sample), meanonly;
  };
  else {;
    qui summ `mvar' if e(sample), meanonly;
  };  
};
ereturn scalar msum=r(sum);

*
 Restore r() results
*;
if "`eform'"=="eform" {;
  local exteform "eform(exp(b))";
};
qui ereturn display, level(`level') `exteform';

*
 End of non-replay section (not indented)
*;
};

end;
