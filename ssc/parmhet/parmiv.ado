#delim ;
prog def parmiv, sortpreserve;
version 10.0;
/*
 Input a varlist containing an estimates variable, a standard error variable,
 and (optionally) a  degrees of freedom variable,
 and (optionally) a list of by-variables.
 Output variables containing inverse-variance weights, semiweights,
 and other variables used in heterogeneity testing
 and inverse variance weighted meta-analyses.
*!Author: Roger Newson
*!Date: 23 September 2010
*/

syntax varlist(numeric min=2 max=3) [if] [in] [, EForm FLOAT DFCombine(string) BY(varlist)
  IVWeight(name) SWeight(name) SSTderr(name)
  CHI2het(name) DFhet(name) I2het(name) TAU2het(name)
  Fhet(name) RESdfhet(name)
  Phet(name)
  ];
/*
eform implies that the input estimate and standard error
  are for the exponentiated parameter.
float implies that the output variables will be float
  (instead of double).
dfcombine() specifies a degrees-of-freedom combination rule
  for use in the F-test.
by() specifies a list of by-variables.
ivweight() specifies an output variable containing inverse variance weights.
sweight() specifies an output variable containing semi-weights.
sstderr() specifies an output variable
  containing semi-weight-based standard errors.
chi2het() specifies an output variable (constant within by-groups),
  containing the heterogeneity chi-squared statistic.
dfhet() specifies an output variable (constant within by-groups),
  containing the heterogeneity degrees of freedom.
i2het() specifies an output variable (constant within by-groups),
  containing the heterogeneity I-squared statistic.
tau2het() specifies an output variable (constant within by-groups),
  containing the heterogeneity tau-squared statistic.
fhet() specifies an output variable (constant within by-groups),
  containing the heterogeneity F statistic
  (if input degrees of freedom are specified).
resdfhet() specifies an output variable (constant within by-groups),
  containing the heterogeneity residual degrees of freedom
  (if input degrees of freedom are specified).
phet() specifies an output variable (constant within by-groups),
  containing the heterogeneity P-value
  (from the F-test if input degrees of freedom are specified,
  or from the chi-squared test otherwise).   
*/

*
 Define new macro names for input variables
*;
local estimate: word 1 of `varlist';
local stderr: word 2 of `varlist';
local dof: word 3 of `varlist';

*
 Set default dfcombine() option
*;
if "`dfcombine'"=="" {;
  local dfcombine="welch";
};
cap assert inlist("`dfcombine'","welch","constant");
if _rc!=0 {;
  disp as error "Invalid dfcombine() option: `dfcombine'";
  error 498;
};

*
 Check that some output variable options are requested
 and that none already exist
*;
local OVlist "`ivweight' `sweight' `sstderr' `chi2het' `dfhet' `i2het' `tau2het' `fhet' `resdfhet' `phet'";
local OV1: word 1 of `OVlist';
if "`OV1'"=="" {;
  disp as error "No output variable options requested";
  error 498;
};
else {;
  foreach OV in `OVlist' {;
    cap conf new var `OV';
    if _rc {;
      disp as error "Variable `OV' already defined";
      error 110;
    };
  };
};

* Mark out the sample for use *;
marksample touse;

* Sort by to-use and by variables *;
sort `touse' `by', stable;

*
 Declare temporary variables
 (with names based on the notation
 of DerSimonian and Laird (1986)
 and of Cochran (1954)
 and of Higgins and Thompson (2002))
*;
tempvar y s w k sumw ybarw ydev Qw tausq svar wstar sse Fw nu1 nu2 isq pvalue;

*
 Assign values to temporary variables
*;

* Compute Normalized estimates and standard errors *;
qui {;
  if "`eform'"=="" {;
    gene double `s'=`stderr' if `touse';
    gene double `y'=`estimate' if `touse';
  };
  else {;
    gene double `s'=`stderr'/`estimate' if `touse';
    gene double `y'=log(`estimate') if `touse';
  };
};

*
 Compute inverse variance weights
 and heterogeneity chi-squared
*;
qui {;
  gene double `w'=1/(`s'*`s') if `touse';
  by `touse' `by': egen double `k'=count(1) if `touse';
  by `touse' `by': egen double `sumw'=total(`w') if `touse';
  by `touse' `by': egen double `ybarw'=total(`y'*(`w'/`sumw')) if `touse';
  gene double `ydev'=`y'-`ybarw' if `touse';
  by `touse' `by': egen double `Qw'=total(`w'*`ydev'*`ydev') if `touse';
  gene double `nu1'=`k'-1;
  gene double `isq'=100*max( 0, (`Qw'-`nu1')/`Qw' );
  lab var `w' "Inverse variance weight";
  lab var `Qw' "Heterogeneity chi-squared";
  lab var `nu1' "Heterogeneity degrees of freedom";
  lab var `isq' "Heterogeneity I-squared";
};

*
 Compute semiweights
*;
qui {;
  tempvar sumwsq;
  by `touse' `by': egen double `sumwsq'=total(`w'*`w') if `touse';
  gene double `tausq'=max( 0, (`Qw'-`nu1')/(`sumw'-(`sumwsq'/`sumw')) ) if `touse';
  gene double `svar' = `s'*`s' + `tausq' if `touse';
  gene double `wstar'=1/`svar' if `touse';
  lab var `tausq' "Heterogeneity tau-squared";
  lab var `wstar' "Inverse variance semi-weight";
};

*
 Compute semiweight-derived standard error
*;
if "`eform'"=="" {;
  gene double `sse'=sqrt(`svar') if `touse';
};
else {;
  gene double `sse'=`estimate'*sqrt(`svar') if `touse';
};
lab var `sse' "Semi-weight-based standard error";

*
 Compute F-test if degrees of freedom supplied
 or chi-squared test otherwise
*;
if "`dof'"=="" {;
  * No degrees of freedom given - use chi-squared *;
  qui gene double `pvalue'=chi2tail(`nu1',`Qw') if `touse';
};
else {;
  * Degrees of freedom given - use F *;
  if "`dfcombine'"=="welch" {;
    qui{;
      tempvar wrem a;
      gene double `wrem'=1-`w'/`sumw' if `touse';
      by `touse' `by': egen double `a'=total( (`wrem'*`wrem')/`dof' ) if `touse';
      gene double `nu2'=(`k'*`k' - 1)/(3*`a') if `touse';
      gene double `Fw'=`Qw'/( `k' -1 + 2*`a'*(`k'-2)/(`k'+1)  ) if `touse';
      gene double `pvalue'=Ftail(`nu1',`nu2',`Fw') if `touse';
    };
  };
  else if "`dfcombine'"=="constant" {;
    qui {;
      tempvar dofmax;
      by `touse' `by': egen double `nu2'=min(`dof') if `touse';
      by `touse' `by': egen double `dofmax'=max(`dof') if `touse';
      cap assert `nu2'==`dofmax';
      if _rc {;
        disp as error "Degrees of freedom non-constant when dfcombine(constant) was specified";
	error 498;
      };
      gene double `Fw'=`Qw'/`nu1' if `touse';
      gene double `pvalue'=Ftail(`nu1',`nu2',`Fw') if `touse';
    };
  };
  lab var `nu2' "Heterogeneity residual degrees of freedom";
  lab var `Fw' "Heterogeneity F";
};
lab var `pvalue' "Heterogeneity P-value";

*
 Rename generated variables
 if requested for output
*;
local OVlist "ivweight sweight sstderr chi2het dfhet i2het tau2het fhet resdfhet phet";
local TVlist "w wstar sse Qw nu1 isq tausq Fw nu2 pvalue";
local NOV: word count `OVlist';
forv i1=1(1)`NOV' {;
  local OV: word `i1' of `OVlist';
  if "``OV''"!="" {;
    local TV: word `i1' of `TVlist';
    cap conf numeric var ``TV'';
    if _rc==0 {;
      rename ``TV'' ``OV'';
      if "`float'"!="" {;
        qui recast float ``OV'', force;
      };
      qui compress ``OV'';
    };
  };
};

end;
