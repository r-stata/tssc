#delim ;
prog def rtfclose;
version 11.0;
/*
 Close a file for input using RTF.
*!Author: Roger Newson
*!Date: 29 September 2009
*/
;

syntax name;

file write `namelist' _n "}" _n;
file close `namelist';

end;
