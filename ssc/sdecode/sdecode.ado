#delim ;
program define sdecode;
version 13.0;
/*
  Decode an input numeric variable to an output string variable,
  which may be new or replace the input variable,
  optionally replacing unlabelled input values with formatted values.
*! Author: Roger Newson
*! Date: 20 September 2013
*/

syntax varname(numeric) [if] [in] , [ Generate(name) replace MAXLength(string) FORMat(string) LABOnly Missing
  FTRim XMLSub ESub(string asis) PRefix(string) SUffix(string) ];
/*
  -generate()- specifies the name of a new output string variable.
  -replace- specifies that the output string variable will replace the input numeric variable.
  -maxlength- is the maximum length of the output string variable.
  -format- is a string or string variable name specifying the format
    used to define output string variable values
    corresponding to unlabelled input numeric variable values.
  -labonly- specifies that only labelled values are to be decoded.
  -missing- specifies that missing values will be decoded (using formats).
  -ftrim- specifies that formatted values will be trimmed to remove left and right spaces.
  -xmlsub- specifies that the substrings "&", &<" and ">" will be substituted
    with the XML entity references "&amp;", "&lt;" and "&gt;", respectively.
  -esub()- specifies rule for substitution of exponents in formatted output values.
  -prefix- specifies a prefix string (to be added on the left).
  -suffix- specifies a suffix string (to be added on the right).
*/

*
 Check that either -generate- or -replace- is present (but not both)
 and initialise -generate- accordingly
 *;
if "`replace'"!="" {;
  if "`generate'"!="" {;
    disp as error "options generate() and replace are mutually exclusive";
    error 198;
  };
  * Save old variable order *;
  unab oldvars: *;
  tempvar generate;
};
else {;
  if "`generate'"=="" {;
    disp as error "must specify either generate() or replace option";
    error 198;
  };
  confirm new variable generate;
};

*
 Initialise -maxlength- if absent
 and check that -maxlength- is legal otherwise
*;
local maxmaxl=c(maxstrvarlen);
if "`maxlength'"=="" {;
  local maxlength=`maxmaxl';
};
else {;
  cap confirm integer number `maxlength';
  if _rc!=0 {;
    disp as error "option maxl() incorrectly specified";
    error 198;
  };
  if `maxlength'<1 | `maxlength'>`maxmaxl' {;
    disp as error "maxlength() must be between 1 and `maxmaxl' in this form of Stata";
    error 198;
  };
};

* Initialise -format- if absent *;
if "`format'"=="" {;
  local format:format `varlist';
};

preserve;

marksample touse, novarlist;

*
 Decode labelled values (and unlabelled values if specified)
*;
local vallab: value label `varlist';
if `"`vallab'"'=="" {;
  * No value label is present *;
  qui gene str1 `generate'="";
  local Glab: var lab `varlist';
  lab var `generate' `"`Glab'"';
};
else {;
  * Value label is present *;
  decode `varlist' if `touse', gene(`generate') maxlength(`maxlength');
};
if "`labonly'"=="" {;
  tempvar toformat;
  gene byte `toformat' = `touse' & missing(`generate');
  cap confirm string variable `format';
  if _rc==0 {;
    * -format()- is a string variable *;
    qui replace `generate'=substr(string(`varlist',`format'),1,`maxlength') if `toformat';
  };
  else {;
    * -format()- is a format *;
    qui replace `generate'=substr(string(`varlist',"`format'"),1,`maxlength') if `toformat';
  };
  if "`missing'"=="" {;qui replace `generate'="" if `toformat' & missing(`varlist');};
  if "`ftrim'"!="" {;qui replace `generate'=trim(`generate') if `toformat';};
  * XML substitution *;
  if "`xmlsub'"!="" {;
    qui {;
      replace `generate'=subinstr(`generate',"&","&amp;",.) if `touse';
      replace `generate'=subinstr(`generate',"<","&lt;",.) if `touse';
      replace `generate'=subinstr(`generate',">","&gt;",.) if `touse';
    };
  };
  * Exponent substitution *;
  if `"`esub'"'!="" {;
    _esub `generate' `toformat' `esub';
  };
};
qui compress `generate';

*
 Add prefix and/or suffix if specified
*;
if `"`prefix'"'!="" {;
  qui replace `generate'=`"`prefix'"'+`generate' if `touse';
};
if `"`suffix'"'!="" {;
  qui replace `generate'=`generate'+`"`suffix'"' if `touse';
};

*
 Replace input string variable with generated coded variable
 if -replace- is specified
*;
if "`replace'"!="" {;
  char rename `varlist' `generate';
  drop `varlist';
  rename `generate' `varlist';
  order `oldvars';
};

restore, not;

end;

prog def _esub;
version 13.0;
/*
 Substitute exponents in formatted values.
*/

syntax namelist(min=2 max=3) [ , ELZero ];
/*
 elzero specifies that leading zeros in the exponent will be retained.
*/
local generate: word 1 of `namelist';
local toformat: word 2 of `namelist';
local esub: word 3 of `namelist';
/*
 generate is the output string variable being generated.
 toformat is the indicator of observations being formatted.
 esub is the exponent substitution rule.
*/

*
 Check for illegal esub() values
*;
if `"`esub'"'=="" {;
  disp as error "Invalid esub()"
    _n "substitution_rule required";
  error 498;
};
local esub=lower(`"`esub'"');
if !inlist(`"`esub'"',"none","x10","rtfsuper","texsuper","htmlsuper","smclsuper") {;
  disp as error `"Illegal esub(`esub')"';
  error 498;
};

*
 Generate temporary variable toemsub and toepsub,
 indicating observations for positive and negative exponent substitution.
*;
tempvar emstart epstart toemsub toepsub;
qui {;
  gene long `emstart'=cond(`toformat',strpos(`generate',"e-"),0);
  gene long `epstart'=cond(`toformat',strpos(`generate',"e+"),0);
  gene byte `toemsub'=`emstart'>0;
  gene byte `toepsub'=`epstart'>0;
  replace `toemsub'=0 if 0<`epstart' & `epstart'<`emstart';
  replace `toepsub'=0 if 0<`emstart' & `emstart'<`epstart';
};

*
 Remove leading zeros if requested.
*;
if "`elzero'"=="" {;
  qui {;
    replace `generate' = substr(`generate',1,`emstart'+1) + trim(string(real(trim(substr(`generate',`emstart'+2,.))),"%9.0g"))
      if `toemsub';;
    replace `generate' = substr(`generate',1,`epstart'+1) + trim(string(real(trim(substr(`generate',`epstart'+2,.))),"%9.0g"))
      if `toepsub';;
  };
};

*
 Do esponent substitution.
*;
qui {;
  if `"`esub'"'=="x10" {;
    replace `generate'=subinstr(`generate',"e-","x10-",1) if `toemsub';
    replace `generate'=subinstr(`generate',"e+","x10",1) if `toepsub';
  };
  else if `"`esub'"'=="rtfsuper" {;
    replace `generate'=subinstr(`generate',"e-","x10{\super -",1) if `toemsub';
    replace `generate'=subinstr(`generate',"e+","x10{\super ",1) if `toepsub';
    replace `generate'=`generate'+"}" if `toemsub' | `toepsub';
  };
  else if `"`esub'"'=="texsuper" {;
    replace `generate'=subinstr(`generate',"e-","\times 10^{-",1) if `toemsub';
    replace `generate'=subinstr(`generate',"e+","\times 10^{",1) if `toepsub';
    replace `generate'=`generate'+"}" if `toemsub' | `toepsub';
  };
  else if `"`esub'"'=="htmlsuper" {;
    replace `generate'=subinstr(`generate',"e-","x10<sup>-",1) if `toemsub';
    replace `generate'=subinstr(`generate',"e+","x10<sup>",1) if `toepsub';
    replace `generate'=`generate'+"</sup>" if `toemsub' | `toepsub';
  };
  else if `"`esub'"'=="smclsuper" {;
    replace `generate'=subinstr(`generate',"e-","x10{sup:-",1) if `toemsub';
    replace `generate'=subinstr(`generate',"e+","x10{sup:",1) if `toepsub';
    replace `generate'=`generate'+"}" if `toemsub' | `toepsub';    
  };
};

end;
