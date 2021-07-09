program define apc_cglim, eclass
*! v1.0 30June2006 SSW
#delim ;

version 9.2;

if !replay() {;

  syntax varlist(numeric ts) [fw aw pw iw] [if] [in], constraint(string)
    agepfx(string) periodpfx(string) cohortpfx(string)
    [age(varname numeric) period(varname numeric) cohort(varname numeric)
     GENerate(name) offset(varname numeric) exposure(varname numeric) *];

  marksample touse;
  markout `touse' `age' `period' `cohort' `offset' `exposure';

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

  *possible values of a, p, c;
  tempname Avals Pvals Cvals;
  quietly tab `age' if `touse', matrow(`Avals');
  local a=r(r);
  quietly tab `period' if `touse', matrow(`Pvals');
  local p=r(r);
  quietly tab `cohort' if `touse', matrow(`Cvals');
  local c=r(r);

  *parse the constraint;
  local constraint=trim(itrim(subinstr("`constraint'","="," ",.)));
  local lc : word count `constraint';
  if `lc'~=2 error 1;
  local c1 : word 1 of `constraint';
  local c1group=substr("`c1'",1,1);
  local c1num=substr("`c1'",2,.);
  confirm number `c1num';
  if "`c1group'"=="a" {;
    quietly count if `age'==`c1num' & `touse';
    if (`c1num'==`Avals'[1,1] | r(N)==0) error 1;
    };
  else if "`c1group'"=="p" {;
    quietly count if `period'==`c1num' & `touse';
    if (`c1num'==`Pvals'[1,1] | r(N)==0) error 1;
    };
  else if "`c1group'"=="c" {;
    quietly count if `cohort'==`c1num' & `touse';
    if (`c1num'==`Cvals'[1,1] | r(N)==0) error 1;
    };
  else error 1;
  local c2 : word 2 of `constraint';
  local c2group=substr("`c2'",1,1);
  local c2num=substr("`c2'",2,.);
  confirm number `c2num';
  if "`c2group'"=="a" {;
    quietly count if `age'==`c2num' & `touse';
    if r(N)==0 error 1;
    };
  else if "`c2group'"=="p" {;
    quietly count if `period'==`c2num' & `touse';
    if r(N)==0 error 1;
    };
  else if "`c2group'"=="c" {;
    quietly count if `cohort'==`c2num' & `touse';
    if r(N)==0 error 1;
    };
  else error 1;
  if "`c1group'"=="`c2group'" & "`c1num'"=="`c2num'" error 1;
  local constraintstring "";
  if "`c1group'"=="a" local constraintstring "`agepfx'_`c1num'=";
  else if "`c1group'"=="p" local constraintstring "`periodpfx'_`c1num'=";
  else if "`c1group'"=="c" local constraintstring "`cohortpfx'_`c1num'=";
  if "`c2group'"=="a" local constraintstring "`constraintstring'`agepfx'_`c2num'";
  else if "`c2group'"=="p" local constraintstring "`constraintstring'`periodpfx'_`c2num'";
  else if "`c2group'"=="c" local constraintstring "`constraintstring'`cohortpfx'_`c2num'";

  *generate dummy variables;
  local anames "";
  forvalues i=2(1)`a' {;
    if "`c1group'"~="a" | `c1num'~=`Avals'[`i',1] {;
      local j=`Avals'[`i',1];
      quietly gen `agepfx'_`j'=(`age'==`j') if `touse';
      local anames "`anames' `agepfx'_`j'";
      };
    };
  local pnames "";
  forvalues i=2(1)`p' {;
    if "`c1group'"~="p" | `c1num'~=`Pvals'[`i',1] {;
      local j=`Pvals'[`i',1];
      quietly gen `periodpfx'_`j'=(`period'==`j') if `touse';
      local pnames "`pnames' `periodpfx'_`j'";
      };
    };
  local cnames "";
  forvalues i=2(1)`c' {;
    if "`c1group'"~="c" | `c1num'~=`Cvals'[`i',1] {;
      local j=`Cvals'[`i',1];
      quietly gen `cohortpfx'_`j'=(`cohort'==`j') if `touse';
      local cnames "`cnames' `cohortpfx'_`j'";
      };
    };

  *constraint;
  if ~ (
       ("`c2group'"=="a" & `c2num'==`Avals'[1,1]) |
       ("`c2group'"=="p" & `c2num'==`Pvals'[1,1]) |
       ("`c2group'"=="c" & `c2num'==`Cvals'[1,1]) ) {;
    if "`c2group'"=="a" {;
      if "`c1group'"=="a" qui replace `agepfx'_`c2num'=1 if `age'==`c1num';
      else if "`c1group'"=="p" qui replace `agepfx'_`c2num'=1 if `period'==`c1num';
      else if "`c1group'"=="c" qui replace `agepfx'_`c2num'=1 if `cohort'==`c1num';
      };
    else if "`c2group'"=="p" {;
      if "`c1group'"=="a" qui replace `periodpfx'_`c2num'=1 if `age'==`c1num';
      else if "`c1group'"=="p" qui replace `periodpfx'_`c2num'=1 if `period'==`c1num';
      else if "`c1group'"=="c" qui replace `periodpfx'_`c2num'=1 if `cohort'==`c1num';
      };
    else if "`c2group'"=="c" {;
      if "`c1group'"=="a" qui replace `cohortpfx'_`c2num'=1 if `age'==`c1num';
      else if "`c1group'"=="p" qui replace `cohortpfx'_`c2num'=1 if `period'==`c1num';
      else if "`c1group'"=="c" qui replace `cohortpfx'_`c2num'=1 if `cohort'==`c1num';
      };
    };
  *otherwise we are constraining the coefficient to be
   zero and we need not do anything; 

  *estimate;
  glm `varlist' `anames' `pnames' `cnames' `if' `in' [`weight' `exp'],
    offset(`offset') exposure(`exposure') `options';
  di "`constraintstring'";
  ereturn local cmd apc_cglim;
  ereturn local constraint1 `constraint';
  ereturn local constraint2 `constraintstring';

  };

else {;
  if "`e(cmd)'"~="apc_cglim" error 301;
  syntax [, *];
  ereturn local cmd glm;
  if "`options'"=="" glm;
  else glm, `options';
  di e(constraint2);
  ereturn local cmd apc_cglim;
  };

end;
