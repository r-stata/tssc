#delim ;
prog def lmsdirb;
version 10.0;
/*
 Create local macros
 containing lists of file names
 from the output of a MS-DOS dir/b command.
*! Author: Roger Newson
*! Date: 11 February 2015
*/

syntax [ , DName(name) FName(name) DFName(name) * ];
/*
 dname() specifies the name of a local macro to be created,
   containing a list of items
   containing the directory specifications.
 fname() specifies the name of a local macro to be created,
   containing the file names.
 dfname() specifies the name of a local macro to be created,
   containing the directory specifications and the file nsmes,
   separated by a backslash.
 Other options are passed to msdirb.
*/

*
 Check operating environment
*;
if lower(c(os))!="windows" {;
  disp as error "lmsdirb is only designed to work under the Windows operating environment";
  error 497;
};

*
 Check that at least 1 output variable is specified
*;
if "`dname'"=="" & "`fname'"=="" & "`dfname'"=="" {;
  disp as error "You must specify one of the output local macro options:"
    _n as error "dname(), fname(), or dfname()";
  error 497;
};

preserve;

*
 Call msdirb
*;
tempname dname_v fname_v dfname_v;
msdirb, clear dname(`dname_v') fname(`fname_v') dfname(`dfname_v') `options';
local Nfile=_N;

*
 Copy output variables to local macros in the calling module
*;
foreach LO in dname fname dfname {;
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
