#delim ;
prog def parmhet;
version 10.0;
/*
 Input a varlist containing an estimates variable, a standard error variable,
 and (optionally) a  degrees of freedom variable,
 and (optionally) a list of by-variables.
 Output an output dataset (or resultsset)
 with 1 obs (or 1 ons per by-group)
 and data om heterogeneity statistics,
 and (optionally) add new variables to the existing dataset,
 containing inverse-variance weights and/or semi-weights
 and/or semiweight-based standard errors.
*!Author: Roger Newson
*!Date: 23 September 2010.
*/


syntax varlist(numeric min=2 max=3) [if] [in] [,
  BY(varlist) EForm FLOAT DFCombine(passthru)
  IVWeight(name) SWeight(name) SSTderr(name)
  LIst(string asis) SAving(string asis) noREstore FAST FList(string)
  IDNum(string) NIDNum(name) IDStr(string) NIDStr(name)
  SUmvar(varlist numeric) FOrmat(string) KEep(namelist)
  CHI2het(name) DFhet(name) I2het(name) TAU2het(name)
  Fhet(name) RESdfhet(name)
  Phet(name)
  ];
/*
by() specifies a list of by-variables.
eform indicates that the input estimates are exponentiated,
  and that the input standard errors are multiplied by the exponentiated estimate,
  and that the output confidence limits are to be exponentiated.
float specifies that the numeric output variables
  will be created as type float or below.
dfcombine() specifies a degrees-of-freedom combination rule
  for use in the F-test.
ivweight() specifies a variable, generated in the existing dataset,
  containing inverse variance weights.
sweight() specifies an output variable containing semi-weights.
sstderr() specifies an output variable
  containing semi-weight-based standard errors.
list contains a varlist of variables to be listed,
  expected to be present in the output resultsset,
  together with optional if and/or in subsetting clauses and/or list_options
  as allowed by the list command.
saving() specifies a file in which to save the resultsset.
norestore specifies that the pre-existing dataset
  is not restored after the output resultsset has been produced
  (set to norestore if FAST is present).
  The user must specify at least one of the four options
  list, saving, norestore and fast,
  because they specify whether the output resultsset
  is listed to the log, saved to a disk file,
  written to the memory (destroying any pre-existing dataset),
  or multiple combinations of these possibilities.
fast specifies that parmhet will not preserve the original dataset
  so that it can be restored if the user presses Break
  (intended for use by programmers).
flist is a global macro name,
  belonging to a macro containing a filename list (possibly empty),
  to which parmhet will append the name of the file
  specified in the SAving() option.
  This enables the user to build a list of filenames in a global macro,
  belonging to files which may later be concatenated
  using dsconcat (if installed) or append.
idnum() is an ID number for the output dataset,
  used to create a numeric variable idnum in the output dataset
  with the same value for all observations.
  This is useful if the output dataset is concatenated
  with other output datasets using -dsconcat- (if installed) or -append-.
nidnum() specifies a name for the numeric ID variable (defaulting to -idnum-).
idstr() is an ID string for the output dataset,
  used to create a string variable (defaulting to -idstr-) in the output dataset
  with the same value for all observations.
nidstr() specifies a name for the numeric ID variable (defaulting to -idstr-).
sumvar() specifies a list of variables to be summarized (using unweighted sums)
  and saved in the output resultsset.
format() contains a list of the form varlist1 format1 ... varlistn formatn,
  where the varlists are lists of variables in the output dataset
  and the formats are formats to be used for these variables
  in the output datasets.
keep() specifies the variables to keep in the output dataset.
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
 Initialize output-variable options,
 defining lists of output variables of different kinds.
*;
local addvaropts "ivweight sweight sstderr";
local hetvaropts "chi2het dfhet i2het tau2het fhet resdfhet phet";
foreach H in `hetvaropts' {;
  if "``H''"=="" {;
    local `H' "`H'";
  };
};


*
 Set maximum numeric type according to float option
*;
if "`float'"=="" {;local maxntype "double";};
else {;local maxntype "float";};


*
 Set -restore- to -norestore- if -fast- is present
 and check that the user has specified one of the four options:
 -list()- and/or -saving()- and/or -norestore- and/or -fast-.
*;
if "`fast'"!="" {;
    local restore="norestore";
};
if (`"`list'"'=="")&(`"`saving'"'=="")&("`restore'"!="norestore")&("`fast'"=="") {;
    disp as error "You must specify at least one of the four options:"
      _n "list(), saving(), norestore, and fast."
      _n "If you specify list(), then the output variables specified are listed."
      _n "If you specify saving(), then the new dataset is output to a disk file."
      _n "If you specify norestore and/or fast, then the new dataset is created in the memory,"
      _n "and any existing dataset in the memory is destroyed."
      _n "For more details, see {help parmhet:on-line help for parmhet.";
    error 498;
};


* Mark out the sample for use *;
marksample touse;


*
 Call parmiv to create new variables
 to be added to the existing dataset
 or saved as minima in the resultsset
*;
local outvaropts "";
foreach V in `addvaropts' `hetvaropts' {;
  tempvar tv_`V';
  local outvaropts "`outvaropts' `V'(`tv_`V'')";
};
parmiv `estimate' `stderr' `dof' if `touse', by(`by') `eform' `float' `dfcombine'
  `outvaropts';


*
 Store variable labels and formats
*;
local nsumvar: word count `sumvar';
forv i1=1(1)`nsumvar' {;
  local sumvcur: word `i1' of `sumvar';
  local sumvlab`i1': var lab `sumvcur';
  local sumvfmt`i1': format `sumvcur';
};
local nhetvar: word count `hetvaropts';
forv i1=1(1)`nhetvar' {;
  local H: word `i1' of `hetvaropts';
  cap conf var `tv_`H'';
  if !_rc {;
    local hetvlab`i1': var lab `tv_`H'';
    local hetvfmt`i1': format `tv_`H'';
  };
};


*
 Preserve old dataset if -restore- is set or -fast- unset
*;
if("`fast'"==""){;
    preserve;
};


*
 Collapse dataset
*;
local minvar "";
foreach H in `hetvaropts' {;
  cap conf var `tv_`H'';
  if !_rc {;
    local minvar "`minvar' `tv_`H''";
  };
};
local clist "";
if "`sumvar'"!="" {;
  local clist "`clist' (sum) `sumvar'";
};
if "`minvar'"!="" {;
  local clist "`clist' (min) `minvar'";
};
collapse `clist' if `touse', by(`by');
order `by' `sumvar' `minvar';


*
 Set characteristic -varname-
 for heterogeneity-test variables
*;
char `tv_chi2het'[varname] "chi-squared";
char `tv_dfhet'[varname] "df";
char `tv_i2het'[varname] "I-squared";
char `tv_tau2het'[varname] "tau-squared";
if "`dof'"=="" {;
  char `tv_phet'[varname] "prob > chi-squared";
};
else {;
  char `tv_fhet'[varname] "F";
  char `tv_resdfhet'[varname] "residual df";
  char `tv_phet'[varname] "prob > F";
};


*
 Label and format summed and heterogeneity variables
 and rename minimized variables
 to corresponding heterogeneity variable options
*;
forv i1=1(1)`nsumvar' {;
  local sumvcur: word `i1' of `sumvar';
  qui compress `sumvcur';
  lab var `sumvcur' `"`sumvlab`i1''"';
  format `sumvcur' `sumvfmt`i1'';
};
forv i1=1(1)`nhetvar' {;
  local H: word `i1' of `hetvaropts';
  cap confirm var `tv_`H'';
  if !_rc {;
    qui compress `tv_`H'';
    lab var `tv_`H'' `"`hetvlab`i1''"';
    format `tv_`H'' `hetvfmt`i1'';
    rename `tv_`H'' ``H'';
  };
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
 Keep only selected variables if requested
*;
if "`keep'"!="" {;
    confirm variable `keep';
    keep `keep';
};


*
 List variables if requested
*;
if `"`list'"'!="" {;
  disp _n as text "Heterogeneity test statistics:";
  list `list';
};


*
 Save dataset if requested
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
 Restore old dataset if -restore- is set
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
 Rename additional variables for old dataset.
*;
foreach A in `addvaropts' {;
  if "``A''"!="" {;
    rename `tv_`A'' ``A'';
  };
};


end;
