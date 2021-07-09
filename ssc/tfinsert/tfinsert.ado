#delim ;
prog def tfinsert;
version 10.0;
/*
  Insert an in-stream file and/or an existing text file on disk
  into another existing text file with a buffer open for write access,
  which will usually be a TeX, HTML or XML document.
*!Author: Roger Newson
*!Date: 28 February 2014
*/


syntax name [using/], [ TErminator(string) MAXlines(numlist min=1 max=1 >=0) ];
/*
  terminator() specifies the terminator string,
    used to terminate in-stream input.
  maxlines() specifies the maximum number of lines
    that can be read from an in-stream file,
    in case tfinsert encounters an end of a do-file.
*/


* Set default maxlines() *;
if "`maxlines'"=="" {;
  local maxlines=1024;
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
 Input and insert in-stream dataset
*;
if `sterminator'!="" {;
  qui disp _request2(_curline);
  mata: st_strscalar("`scurline'",st_local("curline"));
  local nline=0;
  while `scurline'!=`sterminator' & `nline'<`maxlines' {;
    file write `namelist' (`scurline') _n;
    local nline=`nline'+1;
    qui disp _request2(_curline);
    mata: st_strscalar("`scurline'",st_local("curline"));
  };
};


*
  Input and insert disk dataset
*;
if `"`using'"'!="" {;
  tempname inbuff;
  file open `inbuff' using `"`using'"', read text;
  file read `inbuff' curline;
  while !r(eof) {;
    mata: st_strscalar("`scurline'",st_local("curline"));
    file write `namelist' (`scurline') _n;
    file read `inbuff' curline;
  };
  file close `inbuff';
};


end;
