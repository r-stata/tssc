#delim ;
prog def metaparm, byable(onecall);
version 16.0;
/*
  Meta-analysis using parmest resultsset
  Input a parmest-style resultsset with 1 obs per parameter
  and data on estimates, standard errors and (optionally) degrees of freedom.
  Output a parmest-style resultsset with 1 obs per by-group
  and data on estimates, test statistics, P-values and confidence limits
  for the meta-analysed summary parameter within each by-group,
  assuming that parameters within each by-group are statistically independent.
*! Author: Roger Newson
*! Date: 10 April 2020
*/


syntax [if] [in] [aweight iweight] [,
      LIst(string asis) FRAme(string asis) SAving(string asis) noREstore FList(string)
      BY(varlist) SUmvar(varlist numeric)
      DFCombine(string)
      IDNum(string) NIDNum(name) IDStr(string) NIDStr(name)
      FOrmat(string)
      noTDist EForm FLOAT FAST
      ESTimate(varname) STDerr(varname) Dof(varname)
      replace
      * ];
/*
LIst contains a varlist of variables to be listed,
  expected to be present in the output resultsset,
  together with optional if and/or in subsetting clauses and/or list_options
  as allowed by the list command.
FRAme specifies a Stata data frame in which to create the output data set.
SAving() specifies a file in which to save the resultsset.
noREstore specifies that the pre-existing dataset
  is not restored after the output resultsset has been produced
  (set to norestore if FAST is present).
  The user must specify at least one of the four options
  list, saving, norestore and fast,
  because they specify whether the output resultsset
  is listed to the log, saved to a disk file,
  written to the memory (destroying any pre-existing data set),
  or multiple combinations of these possibilities.
FList is a global macro name,
  belonging to a macro containing a filename list (possibly empty),
  to which parmest will append the name of the file
  specified in the SAving() option.
  This enables the user to build a list of filenames in a global macro,
  belonging to files which may later be concatenated
  using dsconcat (if installed) or append.
BY() specifies a list of by-variables.
SUmvar() specifies a list of variables to be summarized (using unweighted sums)
  and saved in the output resultsset.
DFCombine specifies how degrees of freedom of the input parameters
  will be combined to derive degrees of freedom for the output parameters.
IDNum() is an ID number for the output data set,
  used to create a numeric variable idnum in the output data set
  with the same value for all observations.
  This is useful if the output data set is concatenated
  with other output data sets using -dsconcat- (if installed) or -append-.
NIDNum() specifies a name for the numeric ID variable (defaulting to -idnum-).
IDStr() is an ID string for the output data set,
  used to create a string variable (defaulting to -idstr-) in the output data set
  with the same value for all observations.
NIDStr() specifies a name for the numeric ID variable (defaulting to -idstr-).
FOrmat() contains a list of the form varlist1 format1 ... varlistn formatn,
  where the varlists are lists of variables in the output data set
  and the formats are formats to be used for these variables
  in the output data sets.
noTDist specifies whether or not a t-distribution is used
  to calculate confidence limits
  (defaulting to tdist if dof() variable exists and to notdist otherwise).
EForm indicates that the input estimates are exponentiated,
  and that the input standard errors are multiplied by the exponentiated estimate,
  and that the output confidence limits are to be exponentiated.
FLOAT specifies that the numeric output variables
  will be created as type float or below.
FAST specifies that parmest will not preserve the original data set
  so that it can be restored if the user presses Break
  (intended for use by programmers).
ESTimate() contains the name of the input variable containing estimates
  (defaulting to "estimate").
STDerr() contains the name of the input variable containing standard errors
  (defaulting to "stderr").
Dof() contains the name of the input variable containing degrees of freedom
  (defaulting to "dof").
replace is a parmcip option that metaparm does not pass to parmcip.
All other options are passed to parmcip, and are described in parmcip.ado.
*/


*
 Set bybyvars macro
 and check that the by: prefix list begins the by: option.
*;
if _by() {;
  local bybyvars "by `_byvars' `_byrc0':";
  local Nbyprefvars: word count `_byvars';
  forv i1=1(1)`Nbyprefvars' {;
    local Bpref: word `i1' of `_byvars';
    local Bopt: word `i1' of `by';
    if "`Bpref'"!="`Bopt'" {;
      disp as error "The by: prefix variables must begin the by() option";
      error 498;
    };
  };
};


*
 Set restore to norestore if -fast- is present
 and check that the user has specified one of the five options:
 -list()- and/or -frame- and/or -saving()- and/or -norestore- and/or -fast-.
*;
if (`"`list'"'=="")&(`"`frame'"'=="")&(`"`saving'"'=="")&("`restore'"!="norestore")&("`fast'"=="") {;
    disp as error "You must specify at least one of the five options:"
      _n "list(), frame(), saving(), norestore, and fast."
      _n "If you specify list(), then the output variables specified are listed."
      _n "f you specify frame(), then the new data set is output to a data frame."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the current ata frame,"
      _n "and any existing data set in the current data frame is destroyed."
      _n "For more details, see {help parmest:on-line help for parmby and parmest}.";
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

 Set default weight
*;
if "`weight'"=="" {;
  local weight "aweight";
  local exp "= 1";
};


*
 Set default input options
*;
if "`estimate'"=="" {;local estimate "estimate";};
if "`stderr'"=="" {;local stderr "stderr";};
if "`dof'"=="" {;local dof "dof";};
if "`tdist'"=="" {;
  cap confirm variable `dof';
  if _rc==0 {;
    local tdist "tdist";
  };
  else {;
    local tdist "notdist";
    disp as text "Note: variable `dof' not found, normal distribution assumed";
  };
};
if `"`dfcombine'"'=="" {;
  local dfcombine="satterthwaite";
};
foreach DFC in "satterthwaite" "welch" "constant" {;
  if strpos("`DFC'",`"`dfcombine'"')==1 {;
    local dfcombine "`DFC'";
  };
};
cap assert inlist("`dfcombine'","satterthwaite","welch","constant");
if _rc!=0 {;
  disp as error "Invalid dfcombine() option: `dfcombine'";
  error 498;
};


*
 Set maximum numeric type according to float option
*;
if "`float'"=="" {;local maxntype "double";};
else {;local maxntype "float";};


*
 Preserve old data set if -restore- is set or -fast- unset
*;
if("`fast'"==""){;
    preserve;
};


* Mark out the sample for use *;
marksample touse, zeroweight;

* Sort by by-variables if present *;
if "`by'" != "" {;sort `by', stable;};

*
 Create weight variable
*;
tempvar wt;
if "`weight'"=="iweight" {;
  qui gene `maxntype' `wt' `exp' if `touse';
};
else if "`weight'"=="aweight" {;
  qui gene `maxntype' `wt' `exp' if `touse';
  tempvar totwt;
  if "`by'" != "" {;
    qui by `by' : egen `maxntype' `totwt' = sum(`wt') if `touse';
  };
  else {;
    qui egen `maxntype' `totwt' = sum(`wt') if `touse';
  };
  qui replace `wt' = `wt' / `totwt' if `touse';
  drop `totwt';
};
else {;
  disp as error "Invalid weight type - `weight'";
  error 498;
};


*
 Convert estimates and standard errors to symmetric form
 if eform option is specified
*;
if "`eform'"!="" {;
  qui replace `stderr' = `stderr' / `estimate' if `touse';
  qui replace `estimate' = log(`estimate') if `touse';
};


*

 Store variable labels and formats
*;
local nsumvar: word count `sumvar';
forv i1=1(1)`nsumvar' {;
  local sumvcur: word `i1' of `sumvar';
  local sumvlab`i1': var lab `sumvcur';
  local sumvfmt`i1': format `sumvcur';
};
local estlab: var lab `estimate';
local selab: var lab `stderr';
local estfmt: format `estimate';
local sefmt: format `stderr';
if "`tdist'" == "tdist" {;
  local doflab: var lab `dof';
  local doffmt: format `dof';
};


*

 Create variables containing weighted estimates, square-weighted variances
 and Satterthwaite/Welch denominators (if required)
*;
qui {;
  tempvar westi w2vari;
  gene double `westi' = `wt' * `estimate' if `touse';
  gene double `w2vari' = `wt' * `stderr' if `touse';
  replace `w2vari' = `w2vari' * `w2vari' if `touse';
  if "`tdist'" == "tdist" & "`dfcombine'"=="satterthwaite" {;
    tempvar satden;
    gene double `satden' = ( `w2vari' * `w2vari') / `dof' if `touse';
  };
  else if "`tdist'" == "tdist" & "`dfcombine'"=="welch" {;
    tempvar satden;
    gene double `satden' = ( `w2vari' * `w2vari' ) / (`dof'+2) if `touse';
  };
  else {;
    local satden "";
  };
};


*
 Collapse dataset
*;
if "`tdist'"=="tdist" & "`dfcombine'"=="constant" {;
  * Degrees of freedom must be constant within by-groups *;
  tempvar dofmax dofmin;
  collapse (sum) `sumvar' `westi' `w2vari' (min) `dofmin'=`dof' (max) `dofmax'=`dof' if `touse', by(`by') fast;
  cap assert `dofmin'==`dofmax';
  if _rc!=0 {;
    disp as error "Degrees of freedom non-constant when dfcombine(constant) was specified";
    error 498;
  };
};
else {;
  collapse (sum) `sumvar' `westi' `w2vari' `satden' if `touse', by(`by') fast;
};


* Label and format summarized variables *;
forv i1=1(1)`nsumvar' {;
  local sumvcur: word `i1' of `sumvar';
  qui compress `sumvcur';
  lab var `sumvcur' `"`sumvlab`i1''"';
  format `sumvcur' `sumvfmt`i1'';
};


* Generate parameter estimation variables *;
qui {;
  gene double `estimate' = `westi';
  gene double `stderr' = sqrt(`w2vari');
  if "`eform'"!="" {;
    replace `estimate' = exp(`estimate');
    replace `stderr' = `estimate' * `stderr';
  };
  compress `estimate' `stderr';
  lab var `estimate' `"`estlab'"';
  lab var `stderr' `"`selab'"';
  format `estimate' `estfmt';
  format `stderr' `sefmt';
  if "`tdist'"=="tdist" {;
    if "`dfcombine'"=="satterthwaite" {;
      gene double `dof' = (`w2vari' * `w2vari') / `satden';
    };
    else if "`dfcombine'"=="welch" {;
      gene double `dof' = (`w2vari' * `w2vari') / `satden' - 2;
    };
    else if "`dfcombine'"=="constant" {;
      gene double `dof'=`dofmin';
    };
    compress `dof';
    lab var `dof' `"`doflab'"';
    format `dof' `doffmt';
  };
};
drop `westi' `w2vari' `satden' `dofmin' `dofmax';

*
 Order variables
*;
if "`tdist'"=="tdist" {;
  order `by' `sumvar' `estimate' `stderr' `dof';
};
else {;
  order `by' `sumvar' `estimate' `stderr';
};

*
 Add test statistics, P-values and confidence limits
*;
if "`tdist'"=="notdist" {;
  `bybyvars' parmcip, estimate(`estimate') stderr(`stderr') `tdist' `eform' `options';

};
else {;
  `bybyvars' parmcip, estimate(`estimate') stderr(`stderr') dof(`dof') `tdist' `eform' `options';
};


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
 Recast numeric non-by-variables if requested
*;
if "`maxntype'"!="double" {;
  unab allvars: *;
  local nonbyvars: list allvars - by;
  foreach X of var `nonbyvars' {;
    cap confirm numeric var `X';
    if _rc==0 {;
      qui recast `maxntype' `X', force;
      qui compress `X';
    };
  };
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
  disp _n as text "Listing of results:";
  list `list';
};


*
 Save data set if requested
*;
if(`"`saving'"'!=""){;
    capture noisily save `saving';
    if(_rc!=0){;
        disp as error `"saving(`saving') invalid"';
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
 Create new frame if requested
*;
local oldframe=c(frame);
tempname tempframe;
if `"`framename'"'!="" {;
  qui frame copy `oldframe' `tempframe', `framereplace';
};


*
 Restore old data set if -restore- is set
 or if program fails when -fast- is unset
*;
if "`fast'"=="" {;
    if "`restore'"=="norestore" {;
        restore,not;
    };
    else {;
        restore;
    };
};


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
