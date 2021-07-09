#delim ;
prog def llinuxlsd1;
version 10.0;
/*
 Create local macro
 containing list of file information records
 from the output of a Linux or Mac OS X ls -d1 command.
*! Author: Roger Newson
*! Date: 01 April 2016
*/

syntax [ , FInfo(name) * ];
/*
  finfo() specifies name of local macro to be created,
   containing a list of file information records from ls -d1.
 All other options are passed to linuxlsd1.
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

preserve;

*
 Call msdirb
*;
tempname finfo_v;
linuxlsd1, clear finfo(`finfo_v') `options';
local Nfile=_N;

*
 Copy output variables to local macros in the calling module
*;
foreach LO in finfo {;
  if "``LO''"!="" {;
    local `LO'_l "";
    forv i1=1(1)`Nfile' {;
      local Fcur=``LO'_v'[`i1'];
      local `LO'_l `"``LO'_l' `"`Fcur'"'"';
    };
    local `LO'_l: list retokenize `LO'_l;
    c_local ``LO'' `"``LO'_l'"';
  };
};

restore;

end;
