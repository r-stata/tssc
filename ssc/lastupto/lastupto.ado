#delim ;
prog def lastupto;
version 10.0;
/*
  Create an output dataset (or resultsset)
  with 1 obs per X-value per by-group for each of a list of X-values
  and data on the non-by non-X variables in the current dataset
  in the last observation in the by-group
  with an X-value up to the current one,
  when the input dataset is ordered by the by-variables,
  then by the X-variable,
  and then in the pre-existing order..
  This package uses the SSC package expgen.
*! Author: Roger Newson
*! Date: 22 July 2018
*/


syntax varname(numeric) [if] [in] [,
  XValues(numlist sort)
  BY(varlist)
  LIst(string asis) SAving(string asis) noREstore FAST FList(string)
  IDNum(string) NIDNum(name) IDStr(string) NIDStr(name)
  FOrmat(string) noOrder keep(namelist)
  ];
/*
varname specifies the X-variable.
xvalues() specifies the list of X-values.
by() specifies a varlist to identify by-groups,
  within which lastupto is executed,
  creating a concatenated resultsset with 1 obs per by-group per X-value.
list() specifies the listing options.
saving() specifies a new disk file to contain the output resultsset.
norestore() specifies that the existing dataset in memory
  will be replaced by the output resultsset.
fast specifies that the existing dataset in memory
  will be replaced by the output resultsset
  without any work being done to restore the existing dataset
  if lastupto fails.
flist() specifies the name of a global macro to contain a list of output filenames,
  to which the saving() output filename will be appended.
idnum() specifies the value of a numeric resultsset ID variable.
nidnum() specifies the name of the numeric resultsset ID variable.
idstr() specifies the value of a string resultsset ID variable.
nidstr() specifies the name of the string resultsset ID variable.
format() specifies formats for variables in the output resultsset.
noorder specifies that the by-variables and X-variable
  will not be ordered to be the first variables in the output dataset.
keep()  specifies the variables to keep in the output dataset.
*/


*
 Create macros xvar, bybyvars and nonkeyvars
 containing the X-variable, by prefix and non-key variables,
 respectively.
*;
local xvar "`varlist'";
if "`by'"!="" {;
  local bybyvars "by `by':";
};
unab nonkeyvars: *;
local nonkeyvars: list nonkeyvars - by;
local nonkeyvars: list nonkeyvars - xvar;


*
 Remove repeated elements from xvalues,
 and set default xvalues if necessary,
 and count xvalues
*;
local xvalues: list uniq xvalues;
if "`xvalues'"=="" {;
  local xvalues 0;
};
local Nxvalue: word count `xvalues';


*
 Set restore to norestore if fast is present
 and check that the user has specified one of the four options:
 list and/or saving and/or norestore and/or fast.
*;
if "`fast'"!="" {;
    local restore="norestore";
};
if (`"`list'"'=="")&(`"`saving'"'=="")&("`restore'"!="norestore")&("`fast'"=="") {;
    disp as error "You must specify at least one of the four options:"
      _n "list(), saving(), norestore, and fast."
      _n "If you specify list(), then the output variables specified are listed."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the memory,"
      _n "and any existing data set in the memory is destroyed."
      _n "For more details, see {help lastupto:on-line help for lastupto}.";
    error 498;
};


*
 Preserve old data set if restore is set or fast unset
*;
if("`fast'"==""){;
    preserve;
};


*
 Keep only wanted observations
*;
marksample touse;
qui keep if `touse';
drop `touse';


*
 Sort dataset
 and evaluate to-duplicate variable
 and duplicate end-of-by-group observations
*;
sort `by' `xvar', stable;
tempvar todup;
qui `bybyvars' gene byte `todup'=_n==_N;
tempvar cseq;
expgen =`todup'*`Nxvalue'+1, copyseq(`cseq');
forv i1=1(1)`Nxvalue' {;
  local xvcur: word `i1' of `xvalues';
  qui replace `xvar'=`xvcur' if `cseq'==`i1'+1;
};


*
 Sort dataset
 and evaluate non-key variables in non-first duplicates
*;
foreach Y of var `nonkeyvars' {;
  cap confirm numeric var `Y';
  if _rc {;
    qui replace `Y'="" if `cseq'>1;
  };
  else {;
    qui replace `Y'=. if `cseq'>1;
  };
};
sort `by' `xvar' `cseq', stable;
foreach Y of var `nonkeyvars' {;
  qui `bybyvars' replace `Y'=`Y'[_n-1] if `cseq'>1;
};


*
 Keep wanted observations and variables
 and sort dataset by by-group and X-variable
*;
qui keep if `cseq'>1;
drop `todup' `cseq';
qui compress `xvar';
sort `by' `xvar';


*
 Create numeric and/or string ID variables if requested
 and move them to the beginning of the variable order
*;
if ("`nidstr'"=="") local nidstr "idstr";
if("`idstr'"!=""){;
    qui gene str1 `nidstr'="";
    qui replace `nidstr'=`"`idstr'"';
    qui compress `nidstr';
    qui order `nidstr';
    lab var `nidstr' "String ID";
};
if ("`nidnum'"=="") local nidnum "idnum";
if("`idnum'"!=""){;
    qui gene double `nidnum'=real("`idnum'");
    qui compress `nidnum';
    qui order `nidnum';
    lab var `nidnum' "Numeric ID";
};


*
 Format variables if requested
*;
if `"`format'"'!="" {;
    local vlcur "";
    foreach X in `format' {;
        if strpos(`"`X'"',"%")!=1 {;
            * varlist item *;
            local vlcur `"`vlcur' `X'"';
        };
        else {;
            * Format item *;
            unab Y : `vlcur';
            conf var `Y';
            cap format `Y' `X';
            local vlcur "";
        };
    };
};


*
 Order the by-variables and X-variable to the first position
 if this is not counter-ordered
*;
if "`order'"!="noorder" {;
  order `by' `xvar';
};


*
 Keep only selected variables if requested
*;
if "`keep'"!="" {;
    unab keepvars: `keep';
    confirm variable `keepvars';
    keep `keepvars';
};


*
 List variables if requested
*;
if `"`list'"'!="" {;
  list `list';
};


*
 Save dataset if requested
*;
if(`"`saving'"'!=""){;
    capture noisily save `saving';
    if(_rc!=0){;
        disp in red `"saving(`saving') invalid"';
        exit 498;
    };
    tokenize `"`saving'"',parse(" ,");
    local fname `"`1'"';
    if(strpos(`"`fname'"'," ")>0){;
        local fname `""`fname'""';
    };
    * Add filename to file list in FList if requested *;
    if(`"`flist'"'!=""){;
        if(`"$`flist'"'==""){;
            global `flist' `"`fname'"';
        };
        else{;
            global `flist' `"$`flist' `fname'"';
        };
    };
};


*
 Restore old dataset if restore is set
 or if program fails when fast is unset
*;
if "`fast'"=="" {;
    if "`restore'"=="norestore" {;
        restore,not;
    };
    else {;
        restore;
    };
};


end;
