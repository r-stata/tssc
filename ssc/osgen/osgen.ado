#delim ;
prog def osgen;
version 16.0;
/*
 Generate Python os.stat attribute variables for files in a xdir resultsset.
*! Author: Roger Newson
*! Date: 14 September 2020
*/


syntax [if] [in] [,
  FIlename(varname string) DIrname(varname string)
  noDN
  st_mode(name) st_ino(name) st_dev(name) st_nlink(name) st_uid(name)
  st_gid(name) st_size(name) st_atime(name) st_mtime(name) st_ctime(name)
  REPLACE noDESTring
  ];
/*
filename() specifies the file name input variable.
dirname() specifies the directory name input variable.
nodn specifies that the directory name input variable will not be used,
  even if it exists.
st_mode() specifies the generated variable containing the file mode (type and permissions).
st_ino() specifies the generated variable containing file identification number (within device).
st_dev() specifies the generated variable containing the device identifier.
st_nlink() specifies the generated variable containing the number of hard links.
st_uid() specifies the generated variable containing the user ID of the file owner.
st_gid() specifies the generated variable containing the group ID of the file owner.
st_size() specifies the generated variable containing the size of the file (in bytes).
st_atime() specifies the generated variable containing the last access time of the file (in seconds).
st_mtime() specifies the generated variable containing the last modification time of the file (in seconds).
st_ctime() specifies the generated variable containing the creation time of the file (in seconds).
replace specifies that any existing variables with the same names as
  generated variables will be replaced.
nodestring specifies that generated variables will not be destringed to numeric.
*/


*
 Mark sample and count all observations
*;
marksample touse;
local Nfile=_N;

*
 Set default input variable options
*;
if `"`filename'"'=="" {;
  local filename filename;
};
if `"`dirname'"'=="" {;
  local dirname dirname;
};


*
 Check and echo filename and dirname variable
 and reset nodn option if dirname is not available
*;
conf var `filename';
disp as text "File names input from variable: " as result "`filename'";
cap conf var `dirname';
if _rc {;
  local dn="nodn";
  disp as text "No directory variable: " as result "`dirname'";
};
else {;
  disp as text "Directory name input from variable: " as result "`dirname'";
};


*
 Set default output variable name options
*;
local strgen "st_mode st_ino st_dev st_nlink st_uid st_gid st_size st_atime st_mtime st_ctime";
foreach X in `strgen' {;
  if "``X''"=="" {;
    local `X' "`X'";
  };
};


*
 Check that variables to be generated do not already exist
 if replace is not specified
*;
if "`replace'"=="" {;
  local genexists=0;
  foreach X in `strgen' {;
    cap conf var ``X'';
    if !_rc {;
      disp as error "Variable ``X'' already exists";
      error 498;
    };
  };
};


*
 Generate output variables as string
*;
foreach X in `strgen' {;
  cap drop ``X'';
  qui gene ``X''="";   
};


*
 Evaluate output variables as string
*;
tempname FNscal DNscal SR;
python: import os;
python: from sfi import Macro, Scalar;
forv i1=1(1)`Nfile' {;
 if `touse'[`i1'] {;
   scal `FNscal'=`filename'[`i1'];
   if "`dn'"!="nodn" {;
     scal `FNscal'=`dirname'[`i1']+c(dirsep)+`FNscal';
   };
   mata: st_local("isFN",strofreal(fileexists(st_strscalar("`FNscal'"))));
   if `isFN' {;
     * Valid file name - get attributes using Python *;
     python: fos=os.stat(Scalar.getString("`FNscal'"));
     foreach X in `strgen' {;
       python: Macro.setLocal("attrcur",str(fos.`X'));
       qui replace ``X''="`attrcur'" in `i1';
     };     
   };
 };
};


*
 Label variables
*;
lab var `st_mode' "File mode (types and permissions)";
lab var `st_ino' "File identification number (within device)";
lab var `st_dev' "Device identifier";
lab var `st_nlink' "Number of hard links";
lab var `st_uid' "User ID of file owner";
lab var `st_gid' "Group ID of file owner";
lab var `st_size' "Size of file (bytes)";
lab var `st_atime' "Last access time of file (seconds)";
lab var `st_mtime' "Last modification time of file (seconds)";
lab var `st_ctime' "Creation time of file (seconds)";


*
 Destring output variables if required
*;
if "`destring'"!="nodestring" {;
  foreach X in `strgen' {;
    qui destring ``X'', force replace;
    foreach C in destring destring_cmd {;
      char def ``X''[`C'] "";
    };
  };
};


end;
