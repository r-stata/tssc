#delim ;
program define dolog7;
version 7.0;
*
 Execute a do-file `1', outputting to `1'.log,
 with the option of passing parameters.
 Adapted from an example called dofile, given in net course 151,
 and installed at the KCL site by Jonathan Sterne.
*!Author: Roger Newson
*!Date: 22 August 2018
*;
 tempname currentlog;
 log using `"`1'.log"', replace name(`currentlog');
 capture noisily do `0';
 local retcod = _rc;
 log close `currentlog';
 exit `retcod';
end;
