#delim ;
program define dolog16;
version 16.0;
*
 Execute a do-file `1', outputting to `1'.log,
 with the option of passing parameters.
 Adapted from an example called dofile, given in net course 151,
 and installed at the KCL site by Jonathan Sterne.
*!Author: Roger Newson
*!Date: 27 June 2019
*;

syntax [ anything ] [ , * ];

*
 Extract do-file name (unabbreviated and abbreviated)
 and argument list.
*;
gettoken dfname arglist : anything;
if `"`dfname'"'=="" {;
  disp as error "Do-file name required";
  error 498;
};
mata: st_local("abdfname",pathrmsuffix(st_local("dfname")));

*
 Execute the do-file,
 generating a log file.
*;
tempname currentlog;
log using `"`abdfname'.log"', replace name(`currentlog');
capture noisily do `"`dfname'"' `arglist', `options';
local retcod = _rc;
log close `currentlog';
exit `retcod';

end;
