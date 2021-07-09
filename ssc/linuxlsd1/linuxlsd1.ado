#delim ;
prog def linuxlsd1;
version 10.0;
/*
 Create dataset in memory
 with 1 observation for each of a list of files
 from the output of a Linux or Mac OS X ls -d1 command
 and data on the file information output from ls -d1
 (usually only a file name).
*! Author: Roger Newson
*! Date: 01 April 2016
*/

syntax [ , LSOptions(string) FSpec(string) FInfo(name) CLEAR ];
/*
 lsoptions() specifies the additional Linux or Mac OS X options to be passed to ls.
 fspec() specifies the file specification(s) to be passed to ls.
 finfo() specifies the name of a variable in the output dataset
   containing the file information output by ls.
 clear specifies that the new dataset may replace any existing dataset
   that is currently in memory.
*/

*
 Check operating environment
*;
if !inlist(lower(c(os)),"linux","unix","macosx") {;
  disp as error "linuxlsd1 is only designed to work under the Linux, Unix or Mac OS X operating environments";
  error 497;
};

*
 Set defaults
*;
if "`finfo'"=="" {;
  local finfo="finfo";
};

*
 Create the output dataset
*;
tempfile flfile;
* Build ls -d1 command *;
local lscom "ls -d1";
local lscom `"`lscom'  `lsoptions' `fspec'"';
local lscom `"`lscom' > `flfile'"';
disp as text "Command to be executed: " _n as result `"`lscom'"';
* Execute ls -d1 command and input its output *;
shell `lscom';
cap conf file `"`flfile'"';
if _rc {;
  disp as error "ls -d1 command did not generate an output file";
  error 498;
};
tempname retcode;
cap qui insheet `finfo' using `"`flfile'"', tab nonames `clear';
scal `retcode'=_rc;
if `retcode' {;
  disp as error "ls -d1 output file could not be input";
  error `retcode';
};
local finfofmt: format `finfo';
local finfofmt = subinstr("`finfofmt'","%","%-",1);
format `finfo' `finfofmt';
lab var `finfo' "File information";

end;
