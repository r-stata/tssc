#delim ;
prog def inccat,rclass;
version 7.0;
/*
  Concatenate input file list to an output file,
  optionally including extra input files
  listed in lines beginning with a user-defined prefix string.
*! Author: Roger Newson
*! Date: 22 February,2007
*/

local flist "";

*
 Extract file list and leave command line ready to be syntaxed
*;
gettoken token 0 : 0, parse(", ");
while `"`token'"'!="" & `"`token'"'!="," {;
  local flist `"`flist' `"`token'"'"';
  gettoken token 0 : 0, parse(", ");
};
local 0 `",`0'"';

syntax, To(string) [ HMax(integer 31) PRefix(passthru) POstfix(passthru) REPLACE ];
/*
  -to- is the output filename.
  -hmax- is maximum height of a family tree of files
    whose root is a file in the original file list,
    and where the daughters of a file are the files listed in that file
    in a line with a prefix string.
  -prefix- specifies a prefix string,
    such that any line in an input file beginning with -prefix-
    is to be replaced in the output file
    by the concatenation of files listed in the rest of the line
    before the first appearance of the -postfix- sting.
  -postfix- specifies a postfix string,
    which terminates a file list in a line in a file beginning with the -prefix- string.
  -replace- specifies that, if a file named -to- already exists,
    then it is to be overwritten.
*/

* Check that output file -to- is allowed *;
if "`replace'"=="" {;confirm new file `"`to'"';};
else {;
  cap confirm new file `"`to'"';
  local rcode1=_rc;
  cap confirm file `"`to'"';
  local rcode2=_rc;
  if (`rcode1'>0)&(`rcode2'>0) {;
    error 603;
  };
};

* Open temporary output file *;
tempname tohandle;
tempfile totemp;
qui file open `tohandle' using `"`totemp'"',write text replace;

foreach F in `flist' {;
  inccopy,infile(`F') tohandle(`tohandle') hmax(`hmax') `prefix' `postfix';
};

* Close temporary output file *;
file close `tohandle';

* Copy temporary output file to output file -to- *;
copy `"`totemp'"' `"`to'"',text `replace';

end;

prog def inccopy,rclass;
/*
  Copy input file to an open output file,
  optionally including extra input files
  listed in lines beginning with a user-defined prefix string.
*/

syntax , Infile(string) Tohandle(string) HMax(integer) [ PRefix(string) POstfix(string) ];
/*
  -infile- is input file name.
  -tohandle- is handle of open output file.
  -prefix- specifies a prefix,
   such that any line in an input file beginning with -prefix-
   is to be replaced in the output file
   by the concatenation of files listed in the rest of the line.
*/

* Check that input file is valid *;
confirm file `infile';

*
 Compute maximum height of trees of files
 whose root is a file included in the current execution of -inccopy-
*;
local hmaxm=`hmax'-1;

* Open input file *;
tempname inhandle;
file open `inhandle' using `"`infile'"',text read;

*
 Copy input file across
*;
local preflen=length(`"`prefix'"');
if (`preflen'<=0)|(`hmaxm'<=0) {;
  *
   Copy lines without checking for prefix
  *;
  file read `inhandle' line;
  while !r(eof) {;
    file write `tohandle' `"`line'"' _n;
    file read `inhandle' line;
  };
};
else {;
  *
   Copy lines checking for prefix
  *;
  file read `inhandle' line;
  while !r(eof) {;
    local prefixq=substr(`"`line'"',1,`preflen');
    if `"`prefixq'"'!=`"`prefix'"' {;
      * Line is not prefixed, so output it *;
      file write `tohandle' `"`line'"' _n;
    };
    else {;
      * Line is prefixed, so process file list *;
      local flist2:subinstr local line `"`prefix'"' "";
      gettoken F2 flist2 : flist2 , parse(" ");
      while (`"`F2'"'!="")&(`"`F2'"'!=`"`postfix'"') {;
        inccopy,infile(`F2') tohandle(`tohandle') hmax(`hmaxm')
          prefix(`"`prefix'"') postfix(`"`postfix'"');
        gettoken F2 flist2 : flist2 , parse(" ");
      };
    };
    file read `inhandle' line;
  };
};


* Close input file *;
file close `inhandle';

end;
