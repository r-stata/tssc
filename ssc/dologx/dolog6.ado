#delim ;
program define dolog6;
version 6.0;
*
 Execute a do-file `1', outputting to `1'.log,
 with the option of passing parameters.
 Adapted from an example called dofile, given in net course 151,
 and installed at the KCL site by Jonathan Sterne.
*! Author: Roger Newson
*! Date: 07 August 2017
*;
 capture log close;
 log using `"`1'.log"', replace;
 capture noisily do `0';
 local retcod = _rc;
 log close;
 exit `retcod';
end;
