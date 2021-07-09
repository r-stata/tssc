#delim ;
prog def rsource;
version 10.0;
/*
  Run R as a command line job,
  using source code from an instream R source and/or the using file,
  and optionally outputting source code and/or listed output
  to the Stata log.
*!Author: Roger Newson
*!Date: 27 February 2014
*/

syntax [ using/ ] [ , TErminator(string) MAXlines(numlist min=1 max=1 >=0)
  RPath(string) ROptions(string) noLOutput LSource ];
/*
  terminator() is the terminator string terminating an instream R program.
  maxlines() is the maximum number of lines input from an instream R program
    if the terminator string is not found.
  rpath() is the path for the Rterm program on the user's system
    (possibly stored by default in the global macro Rterm_path
    and otherwise set by default to "Rterm.exe").
  roptions() is the default option set for the Rterm program on the user's system
    (possibly stored by default in the global macro Rterm_options
    and otherwise set by default to an empty string).
  noloutput specifies that the listed R output is not listed to the Stata log.
  lsource specifies that the  source file is listed to the Stata log.
*/

* Set default maxlines() *;
if "`maxlines'"=="" {;
  local maxlines=1024;
};

*
 Set default Rterm path and options
*;
if `"`rpath'"'=="" {;
  local rpath `"$Rterm_path"';
  if `"`rpath'"'=="" {;
    local rpath = cond(c(os) == "Windows", "Rterm.exe", "/usr/bin/r");
  };
};
if `"`roptions'"'=="" {;
  local roptions `"$Rterm_options"';
};

*
 Initialize terminator and current line scalars
*;
tempname sterminator scurline;
mata: st_strscalar("`sterminator'",strtrim(st_local("terminator")));

*
 Check that either using or terminator() is present.
 but not both.
*;
if `"`using'"'=="" & `sterminator'=="" {;
  disp as error "You must specify either using <filename> or a terminator() string ";
  error 498;
};

*
 Open temporary source file
 to contain R source code from instream and/or file sources
*;
tempfile tempsource;
tempname tempbf;
qui file open `tempbf' using `"`tempsource'"', write text replace;

*
 Input and insert in-stream R source code
*;
if `sterminator'!="" {;
  qui disp _request2(_curline);
  mata: st_strscalar("`scurline'",st_local("curline"));
  local nline=0;
  while `scurline'!=`sterminator' & `nline'<`maxlines' {;
    file write `tempbf' (`scurline') _n;
    local nline=`nline'+1;
    qui disp _request2(_curline);
    mata: st_strscalar("`scurline'",st_local("curline"));
  };
};

*
  Input and insert disk R source code
*;
if `"`using'"'!="" {;
  tempname inbuff;
  file open `inbuff' using `"`using'"', read text;
  file read `inbuff' curline;
  while !r(eof) {;
    mata: st_strscalar("`scurline'",st_local("curline"));
    file write `tempbf' (`scurline') _n;
    file read `inbuff' curline;
  };
  file close `inbuff';
};

*
 Close temporary source file
*;
qui file close `tempbf';

* Display assumed R path to output *;
disp as text "Assumed R program path: " as result `""`rpath'""';

*
 List R source if requested
*;
if "`lsource'"=="lsource" {;
  disp as text "Beginning of listing of R source code ";
  type `"`tempsource'"';
  disp as text "End of listing of R source code ";
};

*
 Execute Rterm
*;
tempfile templis;
local Rcommand `""`rpath'" `roptions' < "`tempsource'" > "`templis'""';
shell `Rcommand';

*
 List R output if requested
*;
if "`loutput'"!="noloutput" {;
  disp as text "Beginning of R output";
  type `"`templis'"';
  disp as text "End of R output";
};

end;
