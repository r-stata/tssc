#delim ;
prog def descgen, rclass;
version 16.0;
/*
 Generate dataset attribute variables in an xgen resultsset.
*! Author: Roger Newson
*! Date: 08 May 2020
*/


syntax [if] [in] [,
  FIlename(varname string) DIrname(varname string)
  noDN
  FRAmename(name)
  ISdta(name) NObs(name) NVar(name) WIdth(name) SIze(name)
  SOrtedby(name) ALlvars(name)
  noSB noAV
  Label
  DSLabel(name)
  CHarlist(string asis)
  CHARPrefix(name)
  REPLACE
  ];
/*
filename() specifies the file name input variable.
dirname() specifies the directory name input variable.
nodn specifies that the directory name input variable will not be used,
  even if it exists.
framename() specifies the frame name input variable.
isdta() specifies the generated variable indicating whether a file name
  is a Stata dataset that can be described.
nobs() specifies the generated variable containing number of observations.
nvar() specifies the generated variable containing the number of observations.
width() specifies the generated variable containing the observation width
  (in bytes).
size() specifies the generated variable containing the size of the dataset
  (in bytes).
sortedby() specifies the generated variable containing the sort list of
  variables.
allvars() specifies the generated variable containing the varlist.
nosb specifies that the sortedby variable will not be created.
noav specifies that the allvars variable will not be created.
label specifies that the dslabel variable will be created.
dslabel() specifies the generated variable containing the dataset label.
charlist() specifies a list of dataset characteristics to be stored
  in a list of variables.
charprefix() specifies a prefix for the names of the dataset characteristic
  variables.
replace specifies that any existing variables with the same names as
  generated variables will be replaced.
*/


*
 Mark sample and count all observations
*;
marksample touse;
local Nfile=_N;


*
 Set default input variable options
*;
if `"`filename'"'=="" {;
  local filename filename;
};
if "`dirname'"=="" {;
  local dirname dirname;
};
if "`framename'"=="" {;
  local framename framename;
};


*
 Decide whether to use file name or frame name variable
*;
local descframe=0;
cap conf var `filename';
if _rc {;
  * File name variable absent *;
  cap conf var `framename';
  if _rc {;
    disp as error
      "filename() variable `filename' and framename() variable `framename' are both absent";
    error 498;
  };
  else {;
    local descframe=1;
  };
  disp as text "Frame names input from variable: " as result "`framename'";
};
else {;
  * File name variable present *;
  cap conf var `framename';
  if !_rc {;
    disp as text
      "Note: filename() variable `filename' is present."
      _n "framename() variable `framename' ignnored.";
  };
  disp as text "File names input from variable: " as result "`filename'";
};


*
 Expand and/or contract charlist
*;
local charlist: list uniq charlist;
local Ncharlist: word count `charlist';
* Check for stars and non-names *;
local starfound=0;
forv i1=1(1)`Ncharlist' {;
  local charcur: word `i1' of `charlist';
  if "`charcur'"=="*" {;
    if `starfound'==0 {;
      local starfound=1;
    };
  };
  else {;
    cap conf name `charcur';
    if _rc {;
      disp as error `"Illegal characteristic name - `charcur'"';
      error 498;
    };
  };
};
* Expand stars to full list of characteristics if necessary *;
if `starfound' {;
  local charlist2 "";
  forv i1=1(1)`Ncharlist' {;
    local charcur: word `i1' of `charlist';
    if "`charcur'"=="*" {;
      * Collect all characteristic names in macro allchars *;
      tempname FNscal;
      local allchars "";
      forv i2=1(1)`Nfile' {;
        if `touse'[`i2'] {;
          if `descframe' {;
            *
             Use framename variable
            *;
            scal `FNscal' = `framename'[`i2'];
            mata: st_local("isFN",strofreal(st_frameexists(st_strscalar("`FNscal'"))));
            if `isFN' {;
              frame `=`FNscal'' : local allchars2: char _dta[];
            };
            local allchars `"`allchars' `allchars2'"';
            local allchars: list uniq allchars;
            local charlist2 `"`charlist2' `allchars'"';
          };
          else {;
            *
             Use filename variable
            *;
            scal `FNscal' = `filename'[`i2'];
            if "`dn'"!="nodn" {;
              scal `FNscal'=`dirname'[`i2']+c(dirsep)+`FNscal';
            };
            * Check that the file name names a readable file *;
            mata: st_local("isFN",strofreal(fileexists(st_strscalar("`FNscal'"))));
            if `isFN' {;
              * Check that file is a Stata dataset *;
              cap desc using `"`=`FNscal''"';
              if !_rc {;
                preserve;
                qui use `"`=`FNscal''"' if 0, clear;
                local allchars2: char _dta[];
                restore;
                local allchars `"`allchars' `allchars2'"';
                local allchars: list uniq allchars;
                local charlist2 `"`charlist2' `allchars'"';
              };
            };                
          };
        };
      };
    };
    else {;
      local charlist2 `"`charlist2' `charcur'"';
    };
  };
  local charlist2: list uniq charlist2;
  local charlist `"`charlist2'"';
  local Ncharlist: word count `charlist';
};  


*
 Set default dataset characteristic variable options
*;
if "`charprefix'"=="" {;
  local charprefix "dschar";
};
if "`charlist'"!="" {;
  local chargen "";
  forv i1=1(1)`Ncharlist' {;
      local chargen `"`chargen' `charprefix'`i1'"';
  };  
};


*
 Set default generated variable name options
*;
local numgen "isdta nobs nvar width size";
local strgen "sortedby allvars dslabel `chargen'";
foreach X in `numgen' `strgen' {;
  if "``X''"=="" {;
    local `X' `X';
  };
};


*
 Check that variables to be generated do not already exist
 if replace is not specified
*;
if "`replace'"=="" {;
  local tobegen "";
  foreach X in `numgen' {;
    local tobegen "`tobegen' ``X''";
  };
  if "`sb'"!="nosb" {;
    local tobegen "`tobegen' `sortedby'";
  };
  if "`av'"!="noav" {;
    local tobegen "`tobegen' `allvars'";  
  };
  if "`label'"!="" {;
    local tobegen "`tobegen' `dslabel'";
  };
  if "`charlist'"!="" {;
    local tobegen "`tobegen' `chargen'";
  };
  conf new var `tobegen';
};


*
 Initialize variables
*;
foreach X in `numgen' `strgen' {;
  if "`X'"!="" {;
    cap conf new var ``X'';
  };
};
foreach X in `numgen' {;
  tempvar `X'_t;
  qui gene byte ``X'_t'=. if `touse';
};
foreach X in `strgen' {;
  tempvar `X'_t;
  qui gene str1 ``X'_t'="" if `touse';
};


*
 Evaluate variables
*;
local vl "varlist";
if "`sb'"=="nosb" & "`av'"=="noav" {;
  local vl "";
};
tempname dshframe FNscal DSLscal;
forv i1=1(1)`Ncharlist' {;
  tempname CHscal`i1';
};
forv i1=1(1)`Nfile' {;
  if `touse'[`i1'] {;
    if `descframe' {;
      * Use framename() variable *;
      scal `FNscal'=`framename'[`i1'];
      mata: st_local("isFN",strofreal(st_frameexists(st_strscalar("`FNscal'"))));
    };
    else {;
      * Use filename() variable and possibly dirname() variable *;
      scal `FNscal' = `filename'[`i1'];
      if "`dn'"!="nodn" {;
        scal `FNscal'=`dirname'[`i1']+c(dirsep)+`FNscal';
      };
      * Check that the file name names a readable file *;
      mata: st_local("isFN",strofreal(fileexists(st_strscalar("`FNscal'"))));
    };
    if !`isFN' {;
      qui replace `isdta_t'=0 in `i1';
    };
    else {;
      if `descframe' {;
        cap frame `=`FNscal'': desc, `vl';
        local isdtacur=!_rc;
      };
      else {;
        cap desc using `"`=`FNscal''"', `vl';
        local isdtacur=!_rc;
      };
      qui replace `isdta_t'=`isdtacur' in `i1';
      if `isdta_t'[`i1']==1 {;
        qui {;
          replace `nobs_t'=r(N) in `i1';
          replace `nvar_t'=r(k) in `i1';
          replace `width_t'=r(width) in `i1';
          if "`sb'"!="nosb" {;
            replace `sortedby_t'=`"`r(sortlist)'"' in `i1';
          };
          if "`av'"!="noav" {;
            replace `allvars_t'=`"`r(varlist)'"' in `i1';
          };
        };
        if "`label'"!="" | "`charlist'"!="" {;
          *
           Find dataset label and/or characteristics
           in dataset header frame
          *;
         if `descframe' {;
            * Extract header from a frame *;
            qui frame `=`FNscal'': frame put if 0, into(`dshframe');
          };
          else {;
            * Extract header from a file *;
            frame create `dshframe';
            qui frame `dshframe': use `"`=`FNscal''"' if 0, clear;
          };
          * Extract dataset labels and/or characteristics from the header frame *;
          frame `dshframe' {;
            if "`label'"!=""{;
              local ldslabel: data label;
              mata: st_strscalar("`DSLscal'",st_local("ldslabel"));
            };
            if "`charlist'"!="" {;
              forv i2=1(1)`Ncharlist' {;
                local charcur: word `i2' of `charlist';
                local charvalcur: char _dta[`charcur'];
                mata:st_strscalar("`CHscal`i2''",st_local("charvalcur"));
              };
            };
          };
          frame drop `dshframe';
          if "`label'"!="" {;
            qui replace `dslabel_t'=`DSLscal' in `i1';
          };
          if "`charlist'"!="" {;
            forv i2=1(1)`Ncharlist' {;
              qui replace ``charprefix'`i2'_t'=`CHscal`i2'' in `i1';
            };
          };
        };
      };
    };
  };
};
qui replace `size_t'=`nobs_t'*`width_t' if `touse';


*
 Compress generated numeric variables
*;
foreach X in `numgen' {;
  qui compress ``X'_t';
};


*
 Left-justify formats for generated string variables
*;
unab outvars: *;
foreach X in `strgen' {;
    local typecur: type ``X'_t';
    if strpos("`typecur'","str")==1 {;
        local formcur: format ``X'_t';
        local formcur=subinstr("`formcur'","%","%-",1);
        format ``X'_t' `formcur';
    };
};


*
 Label variables and assign variable characteristics
*;
lab var `isdta_t' "Stata dataset status indicator";
lab var `nobs_t' "N of observations";
lab var `nvar_t' "N of variables";
lab var `width_t' "Width of observation (bytes)";
lab var `size_t' "Size of dataset (bytes)";
lab var `sortedby_t' "Sort list of variables";
lab var `allvars_t' "List of all variables";
lab var `dslabel_t' "Dataset label";
char `isdta_t'[varname] "dataset status";
char `nobs_t'[varname] "n of observations";
char `nvar_t'[varname] "n of variables";
char `width_t'[varname] "observation width";
char `size_t'[varname] "dataset size";
char `sortedby_t'[varname] "sort list";
char `allvars_t'[varname] "variable list";
char `dslabel_t'[varname] "dataset label";
if "`charlist'"!="" {;
  forv i1=1(1)`Ncharlist' {;
    local charcur: word `i1' of `charlist';
    lab var ``charprefix'`i1'_t' "Characteristic _dta[`charcur']";
    char ``charprefix'`i1'_t'[varname] "_dta[`charcur']";
    char ``charprefix'`i1'_t'[charname] "`charcur'";
  };
};


*
 Rename generated variables
*;
foreach X in `numgen' {;
  if "`replace'"!="" {;
    cap drop ``X'';
  };
  rename ``X'_t' ``X'';
};
if "`sb'"!="nosb" {;
  if "`replace'"!="" {;
    cap drop `sortedby';
  };
  rename `sortedby_t' `sortedby';
};
if "`av'"!="noav" {;
  if "`replace'"!="" {;
    cap drop `allvars';
  };
  rename `allvars_t' `allvars';
};
if "`label'"!="" {;
  if "`replace'"!="" {;
    cap drop `dslabel';
  };
  rename `dslabel_t' `dslabel';
};
if "`charlist'"!="" {;
  forv i1=1(1)`Ncharlist' {;
    if "`replace'"!="" {;
      cap drop `charprefix'`i1';
    };
    rename ``charprefix'`i1'_t' `charprefix'`i1';
  };
};


*
 Return results
*;
return local charlist `"`charlist'"';


end;
