#delim ;
prog def tfconcat, rclass;
version 13.0;
/*
 Concatenate a sequence of text files into a Stata data set in the memory,
 optionally creating additional variables identifying, for each obs,
 the text file from which that obs originated as a record
 and/or the sequential order of that record within its original text file.
*! Author: Roger Newson
*! Date: 31 March 2007
*/

*
 Extract file list and leave command line ready to be syntaxed
*;
local ntf=0;
gettoken tfcur 0 : 0, parse(", ");
while `"`tfcur'"'!="" & `"`tfcur'"'!="," {;
  local ntf=`ntf'+1;
  local tf`ntf' `"`tfcur'"';
  gettoken tfcur 0 : 0, parse(" ,");
};
local 0 `", `0'"';
if `ntf'<=0 {;
  disp as error "No input text files have been specified";
  error 498;
};

* Crack syntax of rest of input line *;
syntax , Generate(passthru) [ LEngth(passthru) TFId(string) TFName(string) OBSseq(string) ];
/*
 generate() is the prefix for generated string variables.
 length() is maximum length of generated string variables.
 tfid() is name of new integer variable containing text file ID,
  with value label of the same name if possible, specifying text file names.
 tfname() is name of new string variable containing text file names.
 obsseq() is name of new integer variable
  containing sequential order of obs as a record within original text file.
*/

preserve;

* Input text files and store in temporary data sets *;
local mrecl=0;
local nsect=0;
forv i1=1(1)`ntf' {;
  qui intext using `"`tf`i1''"',`generate' `length' clear;
  local mreclcur=r(mrecl);
  local nsectcur=r(nsect);
  if `mreclcur'>`mrecl' {;local mrecl=`mreclcur';};
  if `nsectcur'>`nsect' {;local nsect=`nsectcur';};
  tempfile ds`i1';
  qui save `"`ds`i1''"',replace;
};

*
 Define temporary variables
 (to be created and renamed to corresponding options
 if and only if none of the input data sets
 contain a variable of the same name)
*;
tempvar tfidt tfnamet obsseqt;

*
 Concatenate temporary data sets
*;
* Input first data set *;
qui use `"`ds1'"', clear `label';
* Create newvar options if requested *;
if `"`tfid'"'!="" {;
  qui {;
    gene long `tfidt'=1;
    lab var `tfidt' "Input text file";
  };
};
if `"`tfname'"'!="" {;
  qui {;
    gene str1 `tfnamet'="";
    replace `tfnamet'=`"`tfcur'"';
    lab var `tfnamet' "Input text file name";
  };
};
if `"`obsseq'"'!="" {;
  qui {;
    gene long `obsseqt'=_n;
    lab var `obsseqt' "Observation sequence in input text file";
  };
};
local nobs=_N;
* Append other data sets *;
forv i1=2(1)`ntf' {;
  qui append using `"`ds`i1''"',`label';
  if `"`tfid'"'!="" {;
    qui replace `tfidt'=`i1' if _n>`nobs';
  };
  if `"`tfname'"'!="" {;
    qui replace `tfnamet'=`"`tf`i1''"' if _n>`nobs';
  };
  if `"`obsseq'"'!="" {;
    qui replace `obsseqt'=_n-`nobs' if _n>`nobs';
  };
  local nobs=_N;
};

*
 Compress temporary variables
 and rename them to the corresponding user-supplied options if possible
*;
foreach V in tfid tfname obsseq {;
  if `"``V''"'!="" {;
    qui compress ``V't';
    rename ``V't' ``V'';
  };
};

* Create value label for -dsid- if required *;
if `"`tfid'"'!="" {;
  forv i1=1(1)`ntf' {;
    cap lab def `tfid' `i1' `"`tf`i1''"', add;
  };
  lab val `tfid' `tfid';
};

restore,not;

return scalar ntf=`ntf';
return scalar nobs=`nobs';
return scalar mrecl=`mrecl';
return scalar nsect=`nsect';

end;
