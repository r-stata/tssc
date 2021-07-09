program define apc_ie, eclass sortpreserve
*! v1.2 24July2006 SSW
#delim ;

version 9.2;

if !replay() {;

  syntax varlist(numeric ts) [fw aw pw iw] [if] [in],
    [age(varname numeric) period(varname numeric) cohort(varname numeric)
     GENerate(name) eigenvectors_in(name) eigenvectors_out(name)
     design_in(name) design_out(name) xe_in(name) xe_out(name)
     noCONStant EXPosure(varname numeric) OFFset(varname numeric)
     SCAle(string) LEvel(cilevel) EForm 
     noHEADer notable nodisplay *];

  marksample touse;
  markout `touse' `age' `period' `cohort' `offset' `exposure';

  *how many additional explanatory variables?;
  local n_extra: word count `varlist';
  local n_extra=`n_extra'-1;

  *check that at least two of a, p, c are present;
  if ("`age'"=="" & ("`period'"=="" | "`cohort'"=="")) |
    ("`period'"=="" & "`cohort'"=="") {;
    di as error "must specify at least two of age, period and cohort";
    exit=1;
    };

  *create missing apc variable if necessary;
  if "`generate'"~="" confirm new variable `generate';
  else tempvar generate;
  if "`age'"=="" {;
    local age "`generate'";
    quietly generate `age'=`period'-`cohort' if `touse';
    };
  else if "`period'"=="" {;
    local period "`generate'";
    quietly generate `period'=`cohort'+`age' if `touse';
    };
  else if "`cohort'"=="" {;
    local cohort "`generate'";
    quietly generate `cohort'=`period'-`age' if `touse';
    };
  else {;
    *all three variables present. check validity;
    quietly count if `cohort'+`age'-`period'~=0 & `touse';
    if r(N)~=0 {;
      di as error "data do not satisfy cohort(`cohort')+age(`age')=period(`period')";
      exit=1;
      };
    };

  if "`constant'"=="" local cshift=1;
  else local cshift=0;

  tempname Avals Pvals Cvals gamma x xpx evecs evals 
    evecs_exp Proj Proj2 ProjBig Proj2Big b vcv;

  *count ages and periods;
  quietly tab `age' if `touse', matrow(`Avals');
  quietly tab `period' if `touse', matrow(`Pvals');
  matrix `Pvals'=`Pvals'';
  local a=rowsof(`Avals');
  local p=colsof(`Pvals');

  *useful macros;
  local am1=`a'-1;
  local pm1=`p'-1;
  local apm2=`a'+`p'-2;
  local apm1=`a'+`p'-1;
  local comps=2*`a'+2*`p'-4;
  local princomps=2*`a'+2*`p'-5;
  local n_extrap1=`n_extra'+1;

  *produce the design matrix;
  if "`design_in'"~="" matrix `x'=`design_in';
  else {;
    matrix `gamma'=(I(`a'+`p'-2) \ J(1,`a'+`p'-2,-1));
    matrix `x'=J(`a'*`p',`comps',.);
    matrix `x'[1,1]= (I(`a'-1) \ J(1,`a'-1,-1)) # J(`p',1,1);
    matrix `x'[1,`a']=J(`a',1,1) # (I(`p'-1) \ J(1,`p'-1,-1));
    forvalues i=1(1)`a' {;
      forvalues j=1(1)`p' {;
        matrix `x'[(`i'-1)*`p'+`j',`a'+`p'-1]=`gamma'[`a'-`i'+`j',1..`apm2'];
        };
      };
    };
  if "`design_out'"~="" matrix `design_out'=`x';

  *produce principal components;
  if "`eigenvectors_in'"~="" matrix `evecs'=`eigenvectors_in';
  else {;
    matrix `xpx'=`x''*`x';
    matrix symeigen `evecs' `evals' = `xpx';
    };
  if "`eigenvectors_out'"~="" matrix `eigenvectors_out'=`evecs';
  if "`xe_in'"~="" matrix `x'=`xe_in';
  else matrix `x'=`x'*`evecs'[1..`comps',1..`princomps'];
  if "`xe_out'"~="" matrix `xe_out'=`x';

  *turn principal components into variables;
  local xnames "";
  tempvar lll;
  quietly gen `lll'=.;
  forvalues j=1(1)`a' {;
    forvalues k=1(1)`p' {;
      local l=(`j'-1)*`p'+`k';
      quietly replace `lll'=`l'
        if `age'==`Avals'[`j',1] & `period'==`Pvals'[1,`k'];
      };
    };
  forvalues i=1(1)`princomps' {;
    tempvar x`i';
    local xnames "`xnames' `x`i''";
    };
  mat colnames `x' = `xnames';
  preserve;
  drop _all;
  quietly svmat `x', names(col);
  quietly gen `lll'=_n;
  sort `lll';
  tempfile tempfile;
  quietly save `tempfile';
  restore;
  sort `lll';
  quietly merge `lll' using `tempfile', uniqusing;
  drop _merge;

  *estimate;
  if "`exposure'"~="" local exposurestr "exposure(`exposure')";
  if "`offset'"~="" local offsetstr "offset(`offset')";
  glm `varlist' `xnames' if `touse' [`weight' `exp'], `constant'
    `exposurestr' `offsetstr' scale(`scale') `options' nodisplay;

  *check whether a regressor was dropped;
  *if so, give up because we can't transform back to original coordinates;
  if `princomps'+`cshift'+`n_extra'>e(k) {;
    di as error "regressor collinear with age, period or cohort variables, or too many empty cells in age-by-period matrix";
    exit=1;
    };

  *transform back to original coordinates,
    use normalization to calculate coefficients not estimated;
  matrix `Proj'=J(`comps'+3+`cshift',`comps'+`cshift',0);
  matrix `Proj'[1,1]=I(`a'-1);
  matrix `Proj'[`a',1]=J(1,`a'-1,-1);
  matrix `Proj'[`a'+1,`a']=I(`p'-1);
  matrix `Proj'[`a'+`p',`a']=J(1,`p'-1,-1);
  matrix `Proj'[`a'+`p'+1,`a'+`p'-1]=I(`a'+`p'-2);
  matrix `Proj'[2*`a'+2*`p'-1,`a'+`p'-1]=J(1,`a'+`p'-2,-1);
  if "`constant'"=="" matrix `Proj'[2*`a'+2*`p',`comps'+1]=1;
  matrix `ProjBig'=J(`n_extra'+`comps'+3+`cshift',`n_extra'+`comps'+`cshift',0);
  if `n_extra'>0 matrix `ProjBig'[1,1]=I(`n_extra');
  matrix `ProjBig'[`n_extrap1',`n_extrap1']=`Proj';
  matrix `evecs_exp'=I(`comps'+`cshift'+`n_extra');
  matrix `evecs_exp'[`n_extrap1',`n_extrap1']=`evecs';
  matrix `Proj2'=J(`comps'+`cshift',`comps'-1+`cshift',0);
  matrix `Proj2'[1,1]=I(`princomps');
  if "`constant'"=="" matrix `Proj2'[`comps'+1,`comps']=1;
  matrix `Proj2Big'=J(`comps'+`cshift'+`n_extra',`comps'-1+`cshift'+`n_extra',0);
  if `n_extra'>0 matrix `Proj2Big'[1,1]=I(`n_extra');
  matrix `Proj2Big'[`n_extrap1',`n_extrap1']=`Proj2';
  matrix `b'=e(b)*`Proj2Big''*`evecs_exp''*`ProjBig'';
  matrix `vcv'=`ProjBig'*`evecs_exp'*`Proj2Big'*e(V)
    *`Proj2Big''*`evecs_exp''*`ProjBig'';

  *save useful info from glm;
  tempname e_ll e_chi2 e_aic e_bic e_df e_df_m e_vf e_phi e_dispers 
    e_deviance e_dispers_ps e_deviance_ps e_dispers_p e_deviance_p 
    e_dispers_s e_deviance_s;
  capture {;
    scalar `e_ll'=e(ll);
    scalar `e_chi2'=e(chi2);
    scalar `e_aic'=e(aic);
    local e_N=e(N);
    scalar `e_bic'=e(bic);
    scalar `e_df'=e(df);
    scalar `e_df_m'=e(df_m);
    scalar `e_vf'=e(vf);
    scalar `e_phi'=e(phi);
    scalar `e_dispers'=e(dispers);
    scalar `e_deviance'=e(deviance);
    scalar `e_dispers_ps'=e(dispers_ps);
    scalar `e_deviance_ps'=e(deviance_ps);
    scalar `e_dispers_p'=e(dispers_p);
    scalar `e_deviance_p'=e(deviance_p);
    scalar `e_dispers_s'=e(dispers_s);
    scalar `e_deviance_s'=e(deviance_s);
    local e_offset=e(offset);
    local e_vcetype=e(vcetype);
    local e_linkt=e(linkt);
    local e_linkf=e(linkf);
    local e_varfunct=e(varfunct);
    local e_varfuncf=e(varfuncf);
    local e_opt=e(opt);
    local e_opt1=e(opt1);
    local e_opt2=e(opt2);
    if "`e_opt2'"=="." local e_opt2 "";
    local e_crittype=e(crittype);
    };

  *coefficient names
  local labels "";
  forvalues i=1(1)`n_extra' {;
    local j=`i'+1;
    local k : word `j' of `varlist';
    local labels "`labels' `k'";
    };
  forvalues i=1(1)`a' {;
    local j=`Avals'[`i',1];
    local labels "`labels' age_`j'";
    };
  forvalues i=1(1)`p' {;
    local j=`Pvals'[1,`i'];
    local labels "`labels' period_`j'";
    };
  quietly tab `cohort' if `touse', matrow(`Cvals');
  forvalues i=1(1)`apm1' {;
    local j=`Cvals'[`i',1];
    local labels "`labels' cohort_`j'";
    };
  if "`constant'"=="" local labels "`labels' _cons";
  mat colnames `b' = `labels';
  mat rownames `vcv' = `labels';
  mat colnames `vcv' = `labels';

  *return results;
  local depvar : word 1 of `varlist';
  ereturn post `b' `vcv', depname(`depvar') obs(`e_N') esample(`touse');
  capture {;
    ereturn scalar ll=`e_ll';
    ereturn scalar chi2=`e_chi2';
    ereturn scalar aic=`e_aic';
    ereturn scalar bic=`e_bic';
    ereturn scalar df=`e_df';
    ereturn scalar df_m=`e_df_m';
    ereturn scalar vf=`e_vf';
    ereturn scalar phi=`e_phi';
    ereturn scalar dispers=`e_dispers';
    ereturn scalar deviance=`e_deviance';
    ereturn scalar dispers_ps=`e_dispers_ps';
    ereturn scalar deviance_ps=`e_deviance_ps';
    ereturn scalar dispers_p=`e_dispers_p';
    ereturn scalar deviance_p=`e_deviance_p';
    ereturn scalar dispers_s=`e_dispers_s';
    ereturn scalar deviance_s=`e_deviance_s';
    if "`e_offset'"~="." ereturn local offset "`e_offset'";
    ereturn local vcetype "`e_vcetype'";
    ereturn local linkt "`e_linkt'";
    ereturn local linkf "`e_linkf'";
    ereturn local varfunct "`e_varfunct'";
    ereturn local varfuncf "`e_varfuncf'";
    ereturn local opt "`e_opt'";
    ereturn local opt1 "`e_opt1'";
    ereturn local opt2 "`e_opt2'";
    ereturn local crittype "`e_crittype'";
    ereturn local scale "`scale'";
    ereturn local depvar "`depvar'";
    ereturn local cmd apc_ie;
    };
  };

else {;
  if "`e(cmd)'"~="apc_ie" error 301;
  syntax [, noHEADer LEvel(cilevel) EForm];
  };

if "`display'"~="nodisplay" {;
  if "`header'"~="noheader" {;
    *code mainly copied from glm.ado;
    di as txt "Intrinsic estimator of APC effects"
      _col(52) "No. of obs"  _col(68) "=" 
      _col(70) as res %9.0g e(N);
    di as txt "Optimization     : " as res "`e(opt1)'"
      as txt _col(52) "Residual df" _col(68) "="
      _col(70) as res %9.0g e(df);
    di as res _col(20) "`e(opt2)'" as txt _col(52) "Scale parameter"
      _col(68) "=" _col(70) as res %9.0g e(phi);
    di as txt "Deviance" _col(18) "=" as res _col(20) %12.0g e(deviance)
      as txt _col(52) "(1/df) Deviance"
      _col(68) "=" as res _col(70) %9.0g e(dispers);
    di as txt "Pearson" _col(18) "=" as res _col(20) %12.0g e(deviance_p)
      as txt _col(52) "(1/df) Pearson"
      _col(68) "=" as res _col(70) %9.0g e(dispers_p);
    di;
    di as txt "Variance function: " as res "V(u) = "
      as res _col(27) "`e(varfuncf)'"
      _col(52) as txt "[" as res "`e(varfunct)'" as txt "]";
    di as txt "Link function    : " as res "g(u) = "
      as res _col(27) "`e(linkf)'"
      _col(52) as txt "[" as res "`e(linkt)'" as txt "]";
    if "`e(ll)'" != "" {;
      local cr;
      di;
      local crtype = upper(substr(`"`e(crittype)'"',1,1)) +
        substr(`"`e(crittype)'"',2,.);
      local crlen=max(18,length(`"`crtype'"')+2);
      di as txt _col(52) "AIC" _col(68) "="
        as res _col(70) %9.0g e(aic);
      di as txt "`crtype'" _col(`crlen') "= "
        as res %12.0g e(ll) _c;
      };
    di as txt `cr' _col(52) "BIC" _col(68) "="
      as res _col(70) %9.0g e(bic);
    di;
    };
  if "`table'"~="notable" {;
    if "`eform'"=="" ereturn display, level(`level');
    else ereturn display, level(`level') eform("exp(b)");
    };
  };

end;
