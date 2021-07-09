#delim ;
program define dotex;
version 16.0;
*
 Execute a do-file `1', outputting to `1'.tex,
 written in the SJ LaTeX version of TeX,
 with the option of passing parameters.
 Adapted from dolog (which creates text log files).
*! Author: Roger Newson
*! Date: 27 June 2019
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
 generating a log file
 and then a LaTeX file.
*;
tempname currentlog;
tempfile tmplog;
qui log using `"`tmplog'"', smcl replace name(`currentlog');
display "Temporary log file opened on `c(current_date)' at `c(current_time)'";
capture noisily do `"`dfname'"' `arglist', `options';
local retcod = _rc;
display "Temporary log file completed on `c(current_date)' at `c(current_time)'";
qui log close `currentlog';
* Copy temporary file to TeX file *;
qui log texman `"`tmplog'"' `"`abdfname'.tex"',replace; 
display "TeX file `abdfname'.tex completed on `c(current_date)' at `c(current_time)'";
exit `retcod';

end;
