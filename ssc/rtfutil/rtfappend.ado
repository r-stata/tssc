#delim ;
prog def rtfappend;
version 11.0;
/*
 Open a file for appended output using rtfutil.
*|Author: Roger Newson
*!Date: 13 February 2013
*/

syntax name using/ [ , replace FRom(string) ];
/*
  replace specifies that the using file will be replaced,
    if it already exists.
  from() specifies an input file, to which the output will be appended.
*/

*
 Confirm that using file exists and replace is specified
 or that using file does not exist and from() is specified
*;
cap conf file `"`using'"';
if _rc {;
 if `"`from'"'=="" {;
   disp as error `"File `using' not found"'
     _n "Use the from() option to specify an input file"
     _n "with a different name from the using file";
     error 497;
 };
};
else {;
  if "`replace'"=="" {;
    disp as error `"File `using' already exists"';
    error 602;
  };
};

*
 Confirm that from() file exists
 and copy it to using file if it does
*;
if `"`from'"'!="" {;
  conf file `"`from'"';
  copy `"`from'"' `"`using'"', `replace';
};

*
 Open using file for read and write access
*;
file open `namelist' using `"`using'"' , text write read;

*
 Read to end of file,
 and position just before final right brace
 (which should terminate a well-formed .rtf document).
*;
local enddoc "}";
file seek `namelist' query;
local loc = r(loc);
file read `namelist' line;
while r(eof)==0 {;
  mata: rtfappend_split_line();
  if `"`rline'"'=="`enddoc'" {;
    file seek `namelist' query;
    local loc0 = r(loc);
    file read `namelist' line;
    if r(eof)==0 {;
      local loc = `loc0';
      continue;
    };
    continue, break;
  };
  file seek `namelist' query;
  local loc = r(loc);
  file read `namelist' line;
};
file seek `namelist' `loc';
file write `namelist' `"`macval(lline)'"' _n;

end;

#delim cr
mata:

void function rtfappend_split_line() {
  /*
   Split the right-trimmed contents of the macro line
   and insert the final character into the macro rline
   and the other characters into the macro lline.
   This ensures that rtfappend will work
   if the input file contains a well-formd RTF document,
   and the last non-space character
   of the last line of the input file
   is a }.
   (This condition will be true if there are no extra lines
   in the input file
   after the terminating }.)
  */
  real scalar linlen;
  string scalar linecur;
  linecur=strrtrim(st_local("line"));
  linlen=strlen(linecur);
  st_local("lline",substr(linecur,1,linlen-1));
  st_local("rline",substr(linecur,linlen,1));
}

end
