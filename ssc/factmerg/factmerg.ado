#delim ;
prog def factmerg, rclass;
version 11.0;
/*
 Merge a list of input factors to create new output string variables
 with value for each observation copied from the first factor in the input list
 with a non-missing value for that observation.
*! Author: Roger Newson
*! Date: 19 April 2013
*/
syntax varlist [if] [in] [, FValue(string) FName(name) FLabel(name)
  MValue(string asis) MName(string asis) MLabel(string asis)
  FMissing(string) XMLSub
  PValue(string) PName(string) PLabel(string)
  SValue(string) SName(string) SLabel(string)
  ];
/*
 -varlist- is a list of input factor variables to be merged.
 -fvalue()- specifies a string output variable
  containing, in each observation,
  a value copied from the first variable in the input list
  with a non-missing value for that observation,
  and (optionally) some -msdecode- options.
 -fname()- is a string output variable containing, in each observation,
  the name of the input variable from which the value of -fvalue-
  is copied for that observation.
 -flabel()- is a string output variable containing, in each observation,
  the variable label of the input variable
  from which the value of -fvalue- is copied for that observation.
 -mvalue()- is a string expression
  from which values will be copied to the -fvalue- variable
  for observations with missing values for the -fvalue- variable.
 -mname()- is a string expression
  from which values will be copied to the -fname- variable
  for observations with missing values for the -fvalue- variable.
 -mlabel()- is a string expression
  from which values will be copied to the -flabel- variable
  for observations with missing values for the -fvalue- variable.
  in the -fvalue()- and -flabel()- output variables.
 -fmissing()- is a numeric output variable,
  containing missing values for observations excluded by -if- and -in-,
  1 for other observations in which all the input factors are missing,
  and 0 for other observations in which at least one input factor is nonmissing.
 -xmlsub- indicates that XML substitutions will be performed.
 -pvalue()- is a prefix for the -fvalue()- variable.
 -pname()- is a prefix for the -fname()- variable.
 -plabel()- is a prefix for the -flabel()- variable.
 -svalue()- is a suffix for the -fvalue()- variable.
 -sname()- is a suffix for the -fname()- variable.
 -slabel()- is a suffix for the -flabel()- variable.
*/

preserve;

marksample touse,novarlist strok;

local nfac:word count `varlist';

*
 Parse -fvalue- option
*;
msdecode_parse `fvalue';
local fvalue `"`r(varname)'"';
local fvalue_options `"`r(options)'"';
if "`xmlsub'"!="" {;
  local fvalue_options: list fvalue_options | xmlsub;
};

* Confirm that output variable names are valid *;
if "`fname'"!="" {;confirm new var `fname';};
if "`flabel'"!="" {;confirm new var `flabel';};
if "`fvalue'"!="" {;confirm new var `fvalue';};

*
Create temporary variables
to contain factor names, labels and values
*;
tempvar fn fl fv fvcur;
qui {;
  gene str1 `fn'="";
  gene str1 `fl'="";
  gene str1 `fv'="";
};
forv i1=`nfac'(-1)1 {;
  local fcur:word `i1' of `varlist';
  local flcur:var lab `fcur';
  qui replace `fn'="`fcur'" if `touse' & !missing(`fcur');
  qui replace `fl'="`flcur'" if `touse' & !missing(`fcur');
  qui msdecode `fcur' if `touse', gene(`fvcur') `fvalue_options';
  qui replace `fv'=`fvcur' if `touse' & !missing(`fcur');
  drop `fvcur';  
};

*
 Fill in missing values for -fvalue-, -fname- and -flabel-
 from -mvalue-, -mname- and -mlabel- if requested
*;
if `"`mname'"'!="" {;
  qui replace `fn'=(`mname') if `touse' & missing(`fv');
};
if `"`mlabel'"'!="" {;
  qui replace `fl'=(`mlabel') if `touse' & missing(`fv');
};
if `"`mvalue'"'!="" {;
  qui replace `fv'=(`mvalue') if `touse' & missing(`fv');
};

lab var `fn' "Factor name";
lab var `fl' "Factor label";
lab var `fv' "Factor value";

* Rename output variables *;
if "`fname'"!="" {;rename `fn' `fname';};
if "`flabel'"!="" {;rename `fl' `flabel';};
if "`fvalue'"!="" {;rename `fv' `fvalue';};

* XML substitution *;
if "`xmlsub'"!="" & "`fvalue' `flabel'"!="" {;
  foreach GE of var `fname' `flabel' {;
    qui {;
      replace `GE'=subinstr(`GE',"&","&amp;",.) if `touse';
      replace `GE'=subinstr(`GE',"<","&lt;",.) if `touse';
      replace `GE'=subinstr(`GE',">","&gt;",.) if `touse';
    };
  };
};

* Add -fmissing()- variable *;
if `"`fmissing'"'!="" {;
  local nfmissing:word count `fmissing';
  if `nfmissing'!=1 {;
    disp as error "Invalid fmissing()";
    error 198;
  };
  conf new var `fmissing';
  qui gene byte `fmissing'=1 if `touse';
  foreach X of var `varlist' {;
    qui replace `fmissing'=0 if `touse' & !missing(`X');
  };
  lab var `fmissing' "Missing: `varlist'";
};

*
 Add prefixes and suffixes
*;
if "`fname'"!="" {;qui replace `fname'=`"`pname'"'+`fname'+`"`sname'"' if `touse';};
if "`flabel'"!="" {;qui replace `flabel'=`"`plabel'"'+`flabel'+`"`slabel'"' if `touse';};
if "`fvalue'"!="" {;qui replace `fvalue'=`"`pvalue'"'+`fvalue'+`"`svalue'"' if `touse';};

restore, not;

end;

prog def msdecode_parse, rclass;
version 11.0;
/*
 Parse msdecode suboptions
 and return results.
*/

syntax name [ , Generate(passthru) Delimiters(passthru) replace * ];
if "`replace'"!="" | `"`generate'"'!="" | `"`delimiters'"'!="" {;
  disp _n as error "msdecode options generate(), replace and delimiters() not allowed";
  error 498;
};

return local options `"`options'"';
return local varname `"`namelist'"';

end;
