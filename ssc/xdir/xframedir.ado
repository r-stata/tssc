#delim ;
prog def xframedir;
version 16.0;
/*
 Create a resultsset with 1 obs per file
 in a specified directory with a specified pattern.
*! Author: Roger Newson
*! Date: 06 May 2020
*/


syntax [,
  LIst(string asis) FRame(string asis) SAving(string asis) noREstore FAST FList(string)
  LOcal(name)
  IDNum(string) IDStr(string) REName(string) GSort(string) KEep(namelist)
  ];
/*
LIst() contains a varlist of variables to be listed,
  expected to be present in the output data set
  and referred to by the new names if REName is specified,
  together with optional if and/or in subsetting clauses and/or list_options
  as allowed by the list command.
FRame() specifies a frame in which to save the output dataset.
SAving() specifies a data set in which to save the output data set.
noREstore specifies that the pre-existing data set
  is not restored after the output data set has been produced
  (set to norestore if FAST is present).
FAST specifies that xdir will not preserve the original data set
  so that it can be restored if the user presses Break
  (intended for use by programmers).
  The user must specify at least one of the four options
  list, saving, norestore and fast,
  because they specify whether the output data set
  is listed to the log, saved to a disk file,
  written to the memory (destroying any pre-existing data set),
  or multiple combinations of these possibilities.
FList() is a global macro name,
  belonging to a macro containing a filename list (possibly empty),
  to which xdir will append the name of the data set
  specified in the SAving() option.
  This enables the user to build a list of filenames
  in a global macro,
  containing the output of a sequence of model fits,
  which may later be concatenated using dsconcat (if installed) or append.
LOcal() specifies the name of a local macro in the calling program,
  to contain the file list.
IDNum() is an ID number for the model fit,
  used to create a numeric variable idnum in the output data set
  with the same value for all observations.
  This is useful if the output data set is concatenated
  with other xdir output data sets,
  using dsconcat (if installed) or append.
IDStr() is an ID string for the model fit,
  used to create a string variable idstr in the output data set
  with the same value for all observations.
REName() contains a list of alternating old and new variable names,
  so the user can rename variables in the output data set.
GSort() specifies a gsort list by which the resultsset should be sorted.
KEep() option specifies the variables to keep
  in the output data set.
*/


*
 Extract output framename list into a local macro
*;
qui frame dir;
local outflist "`r(frames)'";


*
 Set restore to norestore if fast is present
 and check that the user has specified one of the seven options:
 local and/or plocal and/or list and/or frame and/or saving and/or norestore and/or fast.
*;
if "`fast'"!="" {;
    local restore="norestore";
};
if ("`local'"=="" & `"`list'"'=="") & `"`frame'"'=="" & (`"`saving'"'=="") & ("`restore'"!="norestore") & ("`fast'"=="") {;
    disp as error "You must specify at least one of the 6 options:"
      _n "local(), list(), frame(), saving(), norestore, and fast."
      _n "If you specify local(), then the frame name list is output to a local macro."
      _n "If you specify list(), then the output variables specified are listed."
      _n "If you specify frame(), then the new data set is output to a data frame."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the memory,"
      _n "and any existing data set in the memory is destroyed."
      _n "For more details, see {help xframedir:on-line help for xframedir}.";
    error 498;
};


*
 Return local() results if requested
*;
if "`local'"!="" {;
  c_local `local': copy local outflist;
};


*
 Beginning of resultsset-generating section (NOT INDENTED)
*;
if (`"`list'"'!="") | (`"`frame'"'!="") | (`"`saving'"'!="") | ("`restore'"=="norestore") | ("`fast'"!="") {;


*
 Parse frame option if present
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
 Beginning of frame block (NOT INDENTED)
*;
local oldframe=c(frame);
tempname tempframe;
frame create `tempframe';
frame `tempframe' {;


*
 Initialize resultsset
*;
drop _all;
local Noutf: word count `outflist';
qui set obs `Noutf';


*
 Create variable framename
 containing names of directory and files, respectively
*;
qui gene framename="";
forv i1=1(1)`Noutf' {;
  local outfcur: word `i1' of `outflist';
  qui replace framename=`"`outfcur'"' in `i1';
};
lab var framename "Frame name";
sort framename;


*
 Create numeric and/or string ID variables if requested
 and move them to the beginning of the variable order
*;
if("`idstr'"!=""){;
    qui gene str1 idstr="";
    qui replace idstr=`"`idstr'"';
    qui compress idstr;
    qui order idstr;
    lab var idstr "String ID";
};
if("`idnum'"!=""){;
    qui gene double idnum=real("`idnum'");
    qui compress idnum;
    qui order idnum;
    lab var idnum "Numeric ID";
};


*
 Left-justify formats for all character variables
 in the base output variable set
*;
unab outvars: *;
foreach X of var `outvars' {;
    local typecur: type `X';
    if strpos("`typecur'","str")==1 {;
        local formcur: format `X';
        local formcur=subinstr("`formcur'","%","%-",1);
        format `X' `formcur';
    };
};


*
 Rename variables if requested
*;
if "`rename'"!="" {;
    local nrename:word count `rename';
    if mod(`nrename',2) {;
        disp as text "Warning: odd number of variable names in rename list - last one ignored";
        local nrename=`nrename'-1;
    };
    local nrenp=`nrename'/2;
    local i1=0;
    while `i1'<`nrenp' {;
        local i1=`i1'+1;
        local i3=`i1'+`i1';
        local i2=`i3'-1;
        local oldname:word `i2' of `rename';
        local newname:word `i3' of `rename';
        cap{;
            confirm var `oldname';
            confirm new var `newname';
        };
        if _rc!=0 {;
            disp as text "Warning: it is not possible to rename `oldname' to `newname'";
        };
        else {;
            rename `oldname' `newname';
        };
    };
};


*
 Sort if requested
*;
if "`gsort'"!="" {;
  tempvar tiebreak;
  qui gene long `tiebreak'=_n;
  qui compress `tiebreak';
  gsort `gsort' + `tiebreak';
  drop `tiebreak';
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
 Save data set if requested
*;
if(`"`saving'"'!=""){;
    capture noisily save `saving';
    if(_rc!=0){;
        disp as error `"saving(`saving') invalid"';
        exit 498;
    };
    tokenize `"`saving'"', parse(" ,");
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
 End of frame block (NOT INDENTED)
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


};
*
 End of resultsset-generating section (NOT INDENTED)
*;


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
