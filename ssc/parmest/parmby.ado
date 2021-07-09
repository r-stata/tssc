#delim ;
prog def parmby, rclass;
version 16.0;
*
 Call a regression command followed by -parmest- with by-variables,
 creating an output data set containing the by-variables
 together with the parameter sequence number -parmseq-
 and all the variables in a -parmest- output data set.
*! Author: Roger Newson
*! Date: 10 April 2020
*;


gettoken cmd 0: 0;
if `"`cmd'"' == `""' {;error 198;};

syntax [ , LIst(passthru) FRAme(string asis) SAving(passthru) noREstore FAST * ];
/*
-norestore- specifies that the pre-existing data set
  is not restored after the output data set has been produced
  (set to norestore if FAST is present).
-fast- specifies that parmest will not preserve the original data set
  so that it can be restored if the user presses Break
  (intended for use by programmers).
All other options are passed to -_parmby-.
*/

*
 Set restore to norestore if fast is present
 and check that the user has specified one of the four options:
 list and/or nd/or frame and/or saving and/or norestore and/or fast.
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
if "`framename'"!="" {;
  local passframe "frame(`framename', `framereplace' `framechange')";
};

*
 Preserve old data set if -restore- is set or -fast- unset
*;
if("`fast'"==""){;
    preserve;
};

* Call -_parmby- with all other options *;
_parmby `"`cmd'"' , `list' `passframe' `saving' `options';
return add;

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
 Change frame if requested
*;
if "`framename'"!="" & "`framechange'"!="" {;
  frame change `framename';
};

end;


prog def _parmby, rclass;
version 11.0;
*
 Call a regression command followed by -parmest- with by-variables,
 creating an output data set containing the by-variables
 together with the parameter sequence number -parmseq-
 and all the variables in a -parmest- output data set.
*;

gettoken cmd 0: 0;

syntax [ ,BY(varlist) COMmand LIst(string asis) FRAme(string asis) SAving(string asis) FList(string) REName(string) FOrmat(string) * ];
*
 -by- is list of by-variables.
 -command- specifies that the regression command is saved in the output data set
  as a string variable named -command-.
 Other options are as defined for -parmest-.
*;

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

* Echo the command and by-variables *;
disp as text "Command: " as result `"`cmd'"';
if "`by'"!="" {;disp as text "By variables: " as result "`by'";};


*
 Execute the command once or once per by-group,
 depending on whether -by()- is specified,
 saving the output data set in memory.
*;
if "`by'"=="" {;
  *
   Beginning of non-by-group section.
   (Execute the command and -parmest- only once for the whole data set.)
  *;
  * Beginning of common section to be executed with or without -by- *;
  cap noi {;
    `cmd';
  };
  if _rc!=0 {;
    drop *;
  };
  else {;
    parmest, fast `options';
  };
  * End of common section to be executed with or without -by- *;
  * Add parmest results to return results *;
  return add;
  * Error if no parameters, otherwise sort parameters *;
  if _N==0 {;
    disp as error "Command was not completed successfully";
    error 498;
  };
  * Create parameter sequence variable *;
  qui {;
    gene long parmseq=_n;
    compress parmseq;
    order parmseq;
    sort parmseq;
    lab var parmseq "Parameter sequence number";
  };
  *
   End of non-by-group section.
  *;
};
else {;
  *
   Beginning of by-group section.
   (Create grouping variable -group- defining by-group
   and data set -tf0- with 1 obs per by-group,
   execute the command and -parmest- on each by-group in turn,
   saving the results to temporary files,
   and concatenate temporary files.)
  *;
  *
   Sort and abbreviate dataset
   and create grouping variable -group-
   and macro -ngroup- containing number of groups
   and temporary filenames
  *;
  tempfile df0 tf0;
  qui {;
    sort `by', stable;
    save `df0', replace;
    tempvar group;
    by `by': gene long `group'=_n==1;
    replace `group'=sum(`group');
    compress `group';
    keep `by' `group';
    sort `group';
  };
  local ngroup=`group'[_N];
  forv i1=1(1)`ngroup' {;
    tempfile tf`i1';
  };
  * Create temporary results files *;
  mata: by_groups_for_parmby();
  * Add last parmest results to return results *;
  return add;
  * Concatenate temporary files *;
  qui {;
    use `"`tf1'"', clear;
    forv i1=2(1)`ngroup' {;append using `"`tf`i1''"';};
  };
  * Error if no parameters, otherwise sort parameters *;
  if _N==0 {;
    disp as error "Command was not completed successfully for any by-group";
    error 498;
  };
  * Create parameter sequence variable *;
  qui {;
    sort `group', stable;
    by `group': gene long parmseq=_n;
    compress parmseq;
    order parmseq;
    sort `group' parmseq;
    lab var parmseq "Parameter sequence number";
  };
  *
   End of by-group section.
  *;
};

* Add variable -command- if requested *;
if "`command'"!="" {;
  qui gene str1 command="";
  qui replace command=`"`cmd'"';
  lab var command "Estimation command";
  order parmseq command;
};

*
 Rename variables if requested
 (including -parmseq- and -command-, which cannot be renamed by -parmest-)
 and create macros -parmseqv- and -commandv-,
 containing -parmseq- and -command- variable names
*;
local parmseqv "parmseq";
if "`command'"=="" {;local commandv "";};
else {;local commandv "command";};
if "`rename'"!="" {;
    local nrename:word count `rename';
    if mod(`nrename',2) {;
        disp as text 
          "Warning: odd number of variable names in rename list - last one ignored";
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
            disp as text
             "Warning: it is not possible to rename `oldname' to `newname'";
        };
        else {;
            rename `oldname' `newname';
            if "`oldname'"=="parmseq" {;local parmseqv "`newname'";};
            if "`oldname'"=="command" {;local commandv "`newname'";};
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

* Add by-variables from file -tf0- if present *;
if "`by'"!="" {;
  tempvar merg;
  qui merge `group' using `"`tf0'"',_merge(`merg');
  qui keep if `merg'==3;
  drop `group' `merg';
  order `by';
  sort `by' `parmseqv';
};

*
 List variables if requested
*;
if `"`list'"'!="" {;
    if "`by'"=="" {;
        disp _n as text "Listing of results:";
        list `list';
    };
    else {;
        disp _n as text "Listing of results by: " as result "`by'";
        by `by':list `list';
    };
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
if `"`framename'"'!="" {;
  qui frame copy `oldframe' `framename', `framereplace';
};


* Return results *;
return local by "`by'";
return local command `"`cmd'"';

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


#delim cr
version 16.0
/*
  Private Mata programs used by parmby
*/
mata:


void by_groups_for_parmby()
{
/*
  Create temporary dataset tf0 with 1 obs per by group
  and data on by variable values
  and temporary datasets tf1-tf<ngroup>, where <ngroup> is the number of groups,
  with 1 observation per estimated parameter in the indicated group
  and data on parameter attributes,
  so that datasets tf1-tf<ngroup> can later be concatenated
  and dataset tf0 then merged in.
*/

string scalar tfcur,lcquote,rcquote,longform,groupvar,byvars,command,parmestopts
real matrix groupview,byrange
real scalar maxlong,groupseq,retcode
/*
  tfcur contains temporary file currently being created.
  lcquote contains left compound quote.
  rcquote contains right compound quote.
  longform contains a format for outputting observation numbers
    to Stata commands.
  groupvar is name of group variable.
  byvars is the list of by variables.
  command is the Stata command executed for each by group.
  parmestopts is list of parmest options to be used.
  groupview is a view onto the group variable.
  byrange is a panel matrix with 1 row per by group
    containing ranges for by groups.
  maxlong is used to store the scalar c(maxlong).
  groupseq is the group sequence number.
  retcode is the current return code.
*/

/*
  Initialize constant scalars
*/
lcquote="`"+`"""'
rcquote=`"""'+"'"
longform="%100.0f";
groupvar=st_local("group")
byvars=st_local("by")
command=st_local("cmd")
parmestopts=st_local("options")
maxlong=st_numscalar("c(maxlong)")

/*
  Create range matrix for by groups
  and check that it contains only legal values
  for storage type long
*/
st_view(groupview,.,groupvar)
byrange=panelsetup(groupview,1)
for(groupseq=1;groupseq<=rows(byrange);groupseq++) {
  if(byrange[groupseq,1]>maxlong | byrange[groupseq,2]>maxlong){
    displayas("error")
    printf("Invalid observation number (>c(maxlong) beginning or ending a by-group\n")
    exit(error(498))
  }
}

/*
  Create temporary dataset tf0
*/
tfcur=st_local("tf0")
stata("qui by " + groupvar + ": keep if _n==1")
stata("qui save " + lcquote + tfcur + rcquote + ", replace")

/*
  Create datasets tf1 to tf<ngroup>
*/
for(groupseq=1;groupseq<=rows(byrange);groupseq++) {
  tfcur=st_local("df0")
  stata(
    "qui use in " + strtrim(strofreal(byrange[groupseq,1],longform))
    + "/" + strtrim(strofreal(byrange[groupseq,2],longform))
    + " using " + lcquote + tfcur + rcquote
    + ", clear"
  )
  stata("by " + byvars + ": list if 0")
  retcode=_stata(command)
  if(retcode!=0){
    stata("qui drop _all")
  }
  else {
    retcode=_stata("qui parmest, fast " + parmestopts)
    if(retcode!=0) {
      exit(error(retcode))
    }
  }
  stata("qui gene long " + groupvar + "=" + strtrim(strofreal(groupseq,longform)))
  stata("qui compress `group'")
  tfcur=st_local("tf" + strtrim(strofreal(groupseq,longform)))
  stata("qui save " + lcquote + tfcur + rcquote + ", replace emptyok")
}

}


end
