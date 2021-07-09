#delim ;
prog def rtfhyper;
version 11.0;
/*
 Insert a hyperlink into an open .rtf output file
 specified by a handle.
*!Author: Roger Newson
*!Date: 22 October 2009.
*/

syntax name , Hyperlink(string) [ Text(string) ];
/*
 hyperlink() specifies the URL for the hyperlink.
 text() specifies the text to be used in the hyperlink.
*/

if `"`text'"'=="" {;
  local text `"`hyperlink'"';
};

file write `namelist'
  _n "{\field{\*\fldinst{HYPERLINK"
  _n `" "`hyperlink'""'
  _n "}}{\fldrslt{"
  _n `"`text'"'
  _n "}}}"
  _n;

end;