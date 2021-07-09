#delim ;
prog def rtflink;
version 11.0;
/*
 Insert a linked object in an open RTF output file
 specified by a handle.
*!Author: Roger Newson
*!Date: 29 September 2009
*/

syntax name using/;

file write `namelist'
  _n "{\field\fldedit{\*\fldinst { INCLUDEPICTURE  \\d"
  _n `""`using'""'
  _n "\\*MERGEFORMATINET }}{\fldrslt {}}}"
  _n;

end;