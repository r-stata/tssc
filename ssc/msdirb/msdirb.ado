#delim ;
prog def msdirb;
version 10.0;
/*
 Create dataset in memory
 with 1 observation for each of a list of file names
 from the output of a MS-DOS dir/b command.
*! Author: Roger Newson
*! Date: 06 October 2014
*/

syntax [ , DIrspec(string) FIlespec(string) DName(name) FName(name) DFName(name) CLEAR
  LOwercase Attribute(string) Sortorder(string) ];
/*
 dirspec() specifies the directory to be searched.
 filespec() specifies the file specification
   whose files are to be listed to the output dataset.
 dname() specifies the name of a variable in the output dataset
   containing the directory specification.
 fname() specifies the name of a variable in the output dataset
   containing the file name.
 dfname() specifies the name of a variable in the output dataset
   containing the directory specification and the file nsme,
   separated by a backslash.
 clear specifies that the new dataset may replace any existing dataset
   that is currently in memory.
 lowercase specifies thatthe  file names will be generated in lower case.
 attribute() specifies a suboption of the /a switch
   of the MS-DOS dir command.
 sortorder() specifies a suboption of the /o switch
   of the MS-DOS dir command.
*/

*
 Check operating environment
*;
if lower(c(os))!="windows" {;
  disp as error "msdirb is only designed to work under the Windows operating environment";
  error 497;
};

*
 Check that at least 1 output variable is specified
*;
if "`dname'"=="" & "`fname'"=="" & "`dfname'"=="" {;
  disp as error "You must specify one of the output variable options:"
    _n as error "dname(), fname(), or dfname()";
  error 497;
};

*
 Set defaults
*;
if "`dirspec'"=="" {;
  local dirspec=".";
};
local dirspec: subinstr local dirspec "/" "\", all;
mata: st_local("dirspec",strtrim(st_local("dirspec")));
if "`filespec'"=="" {;
  local filespec="*";
};
mata: st_local("filespec",strtrim(st_local("filespec")));
if "`dname'"=="" {;
  tempvar dname;
};
if "`fname'"=="" {;
  tempvar fname;
};

*
 Create the output dataset
*;
tempfile flfile;
* Build dir/b command *;
local dircom="dir/b";
if "`lowercase'"=="lowercase" {;
  local dircom="`dircom'"+"/l";
};
if `"`attribute'"'!="" {;
  local dircom=`"`dircom'"'+`"/a:`attribute'"';
};
if `"`sortorder'"'!="" {;
  local dircom=`"`dircom'"'+`"/o:`sortorder'"';
};
local dircom=`"`dircom'"'+`" "`dirspec'"' + "\" + `"`filespec'""';
local dircom=`"`dircom'"' + `" > "`flfile'""';
* Execute dir/b command and input its output *;
shell `dircom';
cap conf file `"`flfile'"';
if _rc {;
  disp as error "dir/b command did not generate an output file";
  error 498;
};
tempname retcode;
cap qui insheet `fname' using `"`flfile'"', tab nonames `clear';
scal `retcode'=_rc;
if `retcode' {;
  disp as error "Directory output file could not be input";
  error `retcode';
};
* Generate variables in output dataset *;
if "`dname'"=="" {;
  tempvar dname;
};
qui gene `dname'=`"`dirspec'"';
if "`lowercase'"=="lowercase" {;
  qui replace `dname'=lower(`dname');
};
if "`dfname'"=="" {;
  tempvar dfname;
};
qui gene `dfname'=`dname'+"\"+`fname';
order `dname' `fname' `dfname';
lab var `dname' "Directory";
lab var `fname' "File name without directory";
lab var `dfname' "File name with directory";

end;
