#delim ;
program define msdecode;
version 13.0;
/*
  Decode a list of input numeric variables
  to a single output string variable,
  optionally replacing unlabelled input values with formatted values
  and/or including delimiters between the decoded values..
*! Author: Roger Newson
*! Date: 20 September 2013
*/

syntax varlist(min=1 default=none) [if] [in] , Generate(name)
  [ replace
  Delimiters(string asis)
  PRefix(string) SUffix(string) XMLSub *
  ];
/*
  -generate()- specifies the name of a new output string variable.
  -replace- specifies that the output string variable will replace any existing variable
    with the same name.
  -delimiters()- is a list of delimiter strings to be inserted
    in between the decoded variables.
  -prefix- specifies a prefix string (to be added on the left).
  -suffix- specifies a suffix string (to be added on the right).
  -xmlsub- specifies that XML substitution will be performed.
*/

*
 Check whether -replace- is present
 and, if not, check that -generate- is new
 *;
if "`replace'"=="" {;
  confirm new variable `generate';
};

*
 Count the input variablse
 and extend the delimiter list if necessary
*;
local Ninvar: word count `varlist';
local Ndelim: word count `delimiters';
if `Ndelim'==0 {;
  forv i1=1(1)`=`Ninvar'-1' {;
    local delimiters `"`delimiters' ""';
  };
};
else if `Ndelim'< `Ninvar'-1 {;
  local lastdelim: word `Ndelim' of `delimiters';
  forv i1=`=`Ndelim'+1'(1)`=`Ninvar'-1' {;
    local delimiters `"`delimiters' `lastdelim'"';
  };
};

marksample touse, novarlist;

*
 Decode input variables to generate output variable
*;
tempvar newgenerate gencur;
local var1: word 1 of `varlist';
cap conf numeric variable `var1';
if _rc {;
  qui gene `newgenerate'=`var1' if `touse';
  if "`xmlsub'"!="" {;
    _xmlsub `newgenerate' if `touse';
  };
};
else {;
  qui sdecode `var1' if `touse', gene(`newgenerate') `xmlsub' `options';
};
lab var `newgenerate' "";
local charlist: char `newgenerate'[];
foreach C in `charlist' {;
  char `newgenerate'[`C'] "";
};
forv i1=2(1)`Ninvar' {;
  local i2=`i1'-1;
  local dlmcur: word `i2' of `delimiters';
  local  varcur: word `i1' of `varlist';
  cap conf numeric var `varcur';
  if _rc {;
    qui gene `gencur'=`varcur' if `touse';
    if "`xmlsub'"!="" {;
       _xmlsub `gencur' if `touse';
    };
  };
  else {;
    qui sdecode `varcur' if `touse', gene(`gencur') `xmlsub' `options';
  };
  qui replace `newgenerate'=`newgenerate'+`"`dlmcur'"'+`gencur' if `touse';
  drop `gencur';
};

*
 Add prefix and/or suffix if specified
*;
if `"`prefix'"'!="" {;
  qui replace `newgenerate'=`"`prefix'"'+`newgenerate' if `touse';
};
if `"`suffix'"'!="" {;
  qui replace `newgenerate'=`newgenerate'+`"`suffix'"' if `touse';
};

*
 Rename new generated variable,
 replacing old variable of the same name
 if -replace- is specified
*;
if "`replace'"!="" {;
  cap drop `generate';
};
rename `newgenerate' `generate';

end;

prog def _xmlsub;
version 11.0;
*
 Do XML substitutions
*;

syntax varname(string) if;
marksample touse, strok;

qui {;
  replace `varlist'=subinstr(`varlist',"&","&amp;",.) if `touse';
  replace `varlist'=subinstr(`varlist',"<","&lt;",.) if `touse';
  replace `varlist'=subinstr(`varlist',">","&gt;",.) if `touse';
};

end;
