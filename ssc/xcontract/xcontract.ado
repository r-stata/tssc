#delim ;
program define xcontract;
version 16.0;
/*
  Extended version of -contract- with by-groups,
  percentages within by-group,
  cumulative frequencies and percentages within by-group,
  and an output data set that can be listed to the Stata log,
  saved to a disk file, or written to memory
  (overwriting any pre-existing data set in memory).
  This program contains re-engineered code
  originally derived from official Stata's -contract- and -fillin-.
*! Author: Roger Newson
*! Date: 08 April 2020
*/
	
syntax varlist [if] [in] [fw] [,  LIst(string asis) FRAme(string asis) SAving(string asis) noREstore FAST FList(string)
  Freq(name) Percent(name) CFreq(name) CPercent(name) PTYpe(string) by(varlist)
  IDNum(string) NIDNum(name) IDStr(string) NIDStr(name)
  FOrmat(string)
  Zero noMISS ];
/*

Output-destination options:

-list- contains a varlist of variables to be listed,
  expected to be present in the output data set
  and referred to by the new names if REName is specified,
  together with optional if and/or in subsetting clauses and/or list_options
  as allowed by the list command.
-frame-  specifies a Stata data frame in which to create the output data set.
-saving- specifies a data set in which to save the output data set.
-norestore- specifies that the pre-existing data set
  is not restored after the output data set has been produced
  (set to norestore if FAST is present).
-fast- specifies that -xcontract- will not preserve the original data set
  so that it can be restored if the user presses Break
  (intended for use by programmers).
  The user must specify at least one of the four options
  list, saving, norestore and fast,
  because they specify whether the output data set
  is listed to the log, saved to a disk file,
  written to the memory (destroying any pre-existing data set),
  or multiple combinations of these possibilities.
-flist- is a global macro name,
  belonging to a macro containing a filename list (possibly empty),
  to which -xcontract- will append the name of the data set
  specified in the SAving() option.
  This enables the user to build a list of filenames
  in a global macro,
  containing the output of a sequence of model fits,
  which may later be concatenated using dsconcat (if installed) or append.

Output-variable options:

-freq- is the name of the frequency variable (defaulting to _freq).
-percent- is the name of the percent variable (defaulting to _percent).
-cfreq- is the name of the cumulative frequency variable
  (created only if specified).
-cpercent- is the name of the cumulative percent variable
  (created only if specified).
-ptype- is the storage type for generated percentage variable(s)
  (defaulting to -float-).
-by- contains a list of by-variables.
-idnum- is an ID number for the output data set,
  used to create a numeric variable idnum in the output data set
  with the same value for all observations.
  This is useful if the output data set is concatenated
  with other output data sets using -dsconcat- (if installed) or -append-.
-nidnum- specifies a name for the numeric ID variable (defaulting to -idnum-).
-idstr- is an ID string for the output data set,
  used to create a string variable (defaulting to -idstr-) in the output data set
  with the same value for all observations.
-nidstr- specifies a name for the numeric ID variable (defaulting to -idstr-).
-format- contains a list of the form varlist1 format1 ... varlistn formatn,
  where the varlists are lists of variables in the output data set
  and the formats are formats to be used for these variables
  in the output data sets.

Other options:

-zero- specifies that combinations of values of -varlist- with zero frequencies
  are to be included in the output data set.
-nomiss- specifies that combinations of values of -varlist- with missing values
  are not to be included in the output data set.
*/


*
 Set restore to norestore if fast is present
 and check that the user has specified one of the four options:
 list and/or saving and/or norestore and/or fast.
*;
if "`fast'"!="" {;
    local restore="norestore";
};
if (`"`list'"'=="")&(`"`frame'"'=="")&(`"`saving'"'=="")&("`restore'"!="norestore")&("`fast'"=="") {;
    disp as error "You must specify at least one of the five options:"
      _n "list(), frame(), saving(), norestore, and fast."
      _n "If you specify list(), then the new data set is listed."
      _n "f you specify frame(), then the new data set is output to a data frame."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the memory,"
      _n "and any existing data set in the memory is destroyed."
      _n "For more details, see {help xcontract:on-line help for xcontract}.";
    error 498;
};


*
 Parse frame() option if present
*;
if `"`frame'"'!="" {;
  cap frameoption `frame';
  if _rc {;
    disp as error `"Illegal frame option: `frame'"';
    error 498;
  };
  local framename "`r(namelist)'";
  local framereplace "`r(replace)'";
  local framechange "`r(change)'";
  if `"`framename'"'=="`c(frame)'" {;
    disp as error "frame() option may not specify current frame."
      _n "Use norestore or fast instead.";
    error 498;
  };
  if "`framereplace'"=="" {;
    cap noi conf new frame `framename';
    if _rc {;
      error 498;
    };
  };
};


*
 Mark sample for use
 (note that, if the if-expression contains _n or _N,
 then these are interpreted as the observation sequence or observation number, respectively,
 for the whole input data set before any exclusions are made) 
*;
if "`miss'"=="nomiss" {;
  marksample touse , strok;
};
else {;
  marksample touse , strok novarlist;
};


* Fill in -freq- macro value if missing *;
if `"`freq'"' == "" {;
  local freq "_freq";
};


*
 Create weight-expression variable
 (note that, if the weight expression contains _n or _N,
 then these are interpreted as the observation sequence or observation number, respectively,
 for the whole input data set before any exclusions are made)
*;
tempvar expvar;
if `"`exp'"' == "" {; local exp "= 1"; };
qui gen `expvar' `exp';


*
 Beginning of frame block (NOT INDENTED)
*;
local oldframe=c(frame);
tempname tempframe;
frame put `touse' `by' `varlist' `expvar', into(`tempframe');
frame `tempframe' {;


* Keep only observations to be used *;
qui keep if `touse';
if _N == 0 {;
  error 2000;
};


*
  Create data set with 1 obs per value combination
  and variable -freq- containing frequencies
*;
qui {;
  sort `by' `varlist', stable;
  by `by' `varlist' : gen long `freq' = sum(`expvar');
  by `by' `varlist' : keep if _n == _N;
  compress `freq';
  label var `freq' "Frequency";
};

*
  Create variable -bygrp- containing sequential order of by-group
  (to be used in calculating percents
  and filling in zero-frequency combinations)
*;
tempvar bygrp;
if "`by'"=="" {;
  qui gene byte `bygrp'=1;
  local nbygrp=1;
};
else {;
  gsort `by', gene(`bygrp');
  qui summ `bygrp';
  local nbygrp=r(max);
};

*
 Fill in zero-frequency combinations of -varlist- if requested.
 (This may use a lot of file processing resources.)
*;
if "`zero'"!="" {;
  tempfile tf0;
  qui save `"`tf0'"',replace;
  if "`by'"!="" {;
    * Save file of by-groups with data on by-variable values *;
    tempfile byfile;
    keep `bygrp' `by';
    sort `bygrp';
    qui by `bygrp':keep if _n==1;
    qui save `"`byfile'"', replace;
  };
  drop _all;
  forv i1=1(1)`nbygrp' {;
    qui use `varlist' `freq' `bygrp' if `bygrp'==`i1' using `"`tf0'"', clear;
    _fillin `varlist';
    qui replace `freq'=0 if missing(`freq');
    qui replace `bygrp'=`i1' if missing(`bygrp');
    tempfile tf`i1';
    qui save `"`tf`i1''"', replace;
  };
  qui erase `"`tf0'"';
  qui use `"`tf1'"', clear;
  forv i1=2(1)`nbygrp' {;
    qui append using `"`tf`i1''"';
  };
  if "`by'"!="" {;
    * Merge in by-group values *;
    sort `bygrp' `varlist';
    tempvar merge;
    merge `bygrp' using `"`byfile'"', _merge(`merge');
    drop `merge';
    qui erase `"`byfile'"';
  };
};

* Order and sort output data set *;
order `by' `varlist';
sort `by' `varlist';


*
 Add percent and cumulative frequency variables
*;

* Default type for percent variables *;
if "`ptype'" == "" {;
  local ptype "float";
};

* Default format for percent variables *;
local pformat "%8.2f";

* Default names for percent and cumulative frequency variables *;
if "`percent'"=="" {;local percent "_percent";};
if "`cfreq'"=="" & "`cpercent'"!="" {;
  tempvar tempcfreq;
  local cfreq "`tempcfreq'";
};

* Generate percent and cumulative frequency variables *;
qui {;
  gene `ptype' `percent'=.;
  lab var `percent' "Percent";
  format `percent' `pformat';
  if "`cfreq'"!="" {;
    gene long `cfreq'=.;
    lab var `cfreq' "Cumulative frequency";
  };
  if "`cpercent'"!="" {;
    gene `ptype' `cpercent'=.;
    lab var `cpercent' "Cumulative percent";
    format `cpercent' `pformat';
  };
};

* Evaluate percent and cumulative frequency variables *;
tempname Ninbygrp;
forv i1=1(1)`nbygrp' {;
  qui {;
    summ `freq' if `bygrp'==`i1';
    scal `Ninbygrp'=r(sum);
    replace  `percent'=(100*`freq')/`Ninbygrp' if `bygrp'==`i1';
    if "`cfreq'"!="" {;replace `cfreq'=sum(`freq') if `bygrp'==`i1';};
    if "`cpercent'"!="" {;replace `cpercent'=(100*`cfreq')/`Ninbygrp' if `bygrp'==`i1';};
  };
};

*
 Compress percent and cumulative frequency variables
 to minimum type possible without loss of precision
*;
qui compress `freq' `percent' `cfreq' `cpercent';

* Keep only wanted variables in final order *;
keep `by' `varlist' `freq' `percent' `cfreq' `cpercent';
order `by' `varlist' `freq' `percent' `cfreq' `cpercent';
cap drop `tempcfreq';

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
 List variables if requested
*;
if `"`list'"'!="" {;
    if "`by'"=="" {;
        list `list';
    };
    else {;
        by `by':list `list';
    };
};

*
 Save data set if requested
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
 Copy new frame to old frame if requested
*;
if "`restore'"=="norestore" {;
  frame copy `tempframe' `oldframe', replace;
};


};
*
 End of frame block (NOT INDENED)
*;


*
 Rename temporary frame to frame name (if frame is specified)
 and change current frame to frame name (if requested)
*;
if "`framename'"!="" {;
  if "`framereplace'"=="replace" {;
    cap frame drop `framename';
  };
  frame rename `tempframe' `framename';
  if "`framechange'"!="" {;
    frame change `framename';
  };
};


end;

program define _fillin;
/*
 Fill in combinations of -varlist- with zero frequencies.
 This code is originally derived from official Stata's -fillin-
 (version 2.1.2  19dec1998),
 re-engineered by Roger Newson 12 August 2003.
*/
  version 10.0;
  syntax varlist(min=2);
  tokenize `varlist';
  tempvar merge;
  tempfile FILLIN0 FILLIN1;
  preserve;
  quietly {;
    keep `varlist' ;
    save `"`FILLIN0'"', replace;
    keep `1';
    sort `1';
    by `1':  keep if _n==_N;
    save `"`FILLIN1'"', replace; 
    mac shift ;
    while "`1'"!="" { ;
      use `"`FILLIN0'"', clear;
      keep `1';
      sort `1';
      by `1':  keep if _n==_N;
      cross using `"`FILLIN1'"';
      save `"`FILLIN1'"', replace ;
      macro shift;
    };
    erase `"`FILLIN0'"';    /* to save disk space only */
    sort `varlist';
    save `"`FILLIN1'"', replace ;
    restore, preserve;
    sort `varlist' ;
    merge `varlist' using `"`FILLIN1'"', _merge(`merge');
    noisily assert `merge'!=1;
    drop `merge' ;
    sort `varlist';
    restore, not;
  };
end;

prog def frameoption, rclass;
version 16.0;
*
 Parse frame() option
*;

syntax name [, replace CHange ];

return local change "`change'";
return local replace "`replace'";
return local namelist "`namelist'";

end;
