#delim ;
prog def xcollapse;
version 16.0;
/*
  Extended version of -collapse- with by-groups
  and an output data set that can be listed to the Stata log,
  saved to a disk file, or written to memory
  (overwriting any pre-existing data set in memory).
*! Author: Roger Newson
*! Date: 06 April 2020
*/

syntax anything(name=clist id=clist equalok)  [if] [in] [aw fw iw pw] [,
  LIst(string asis) FRAme(string asis) SAving(string asis) noREstore FAST
  FList(string)
  by(varlist)
  IDNum(string) NIDNum(name) IDStr(string) NIDStr(name)
  FOrmat(string) float
  * ];
/*
-list- contains a varlist of variables to be listed,
  expected to be present in the output data set
  and referred to by the new names if REName is specified,
  together with optional if and/or in subsetting clauses and/or list_options
  as allowed by the list command.
-frame- specifies a Stata data frame in which to create the output data set.
-saving- specifies a data set in which to save the output data set.
-norestore- specifies that the pre-existing data set
  is not restored after the output data set has been produced
  (set to norestore if FAST is present).
-fast- specifies that -xcollapse- will not preserve the original data set
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
  to which -xcollapse- will append the name of the data set
  specified in the SAving() option.
  This enables the user to build a list of filenames
  in a global macro,
  containing the output of a sequence of model fits,
  which may later be concatenated using -dsconcat- (if installed) or -append-.
-by- specifies a by-option to be passed to -collapse-.
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
-float- specifies that double-precision output variables
  will be forced to storage type float.
All other options are passed to -collapse-.
*/

*
 Insert default weight specification and expression
 (this seems to fix a bug/feature in -collapse-)
*;
if "`weight'"=="" {;local weight "fweight";};
if "`exp'"=="" {;local exp "= 1";};

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
      _n "If you specify list(), then the output variables specified are listed."
      _n "f you specify frame(), then the new data set is output to a data frame."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the memory,"
      _n "and any existing data set in the memory is destroyed."
      _n "For more details, see {help xcollapse:on-line help for xcollapse}.";
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
 Preserve old data set if restore is set or fast unset
*;
if("`fast'"==""){;
    preserve;
};

* Calculate summary statistics *;
if "`by'"=="" {;
  collapse `clist' [`weight' `exp'] `if' `in' , fast `options';
};
else {;
  collapse `clist' [`weight' `exp'] `if' `in' , by(`by') fast `options';
  order `by';
};

*
 Compress non-key variables
 and force double non-key variables to float if requested
*;
unab nonkey: *;
local nonkey: list nonkey - by;
qui compress `nonkey';
if "`float'"!="" {;
  foreach Y of var `nonkey' {;
    local Ytype: type `Y';
    if "`Ytype'"=="double" {;
      qui recast float `Y', force;
      qui compress `Y';
    };
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
  list `list';
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
 Create new frame if requested
*;
local oldframe=c(frame);
tempname tempframe;
if `"`framename'"'!="" {;
  frame copy `oldframe' `tempframe', `framereplace';
};

*
 Restore old data set if restore is set
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
