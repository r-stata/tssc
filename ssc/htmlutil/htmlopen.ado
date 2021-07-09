#delim ;
prog def htmlopen;
version 14.0;
/*
 Open a file for output using HTML.
*|Author: Roger Newson
*!Date: 18 December 2018
*/


syntax name using/ [ , replace ATtributes(string)
  HEad HEADAttributes(string) HEADFrom(string) TItle(string)
  BOdy BODYAttributes(string)
  BOM(string)
  ];
/*
  replace specifies that the output must replace an existing file of the same name.
  attributes specifies document attributes to be passed to the <html> tag.
  head specifies that a head will be generated for the output HTML file.
  headattributes() specifies the attributes for the <head> tag.
  headfrom() specifies an existing file,
    from which the HTML head (or part of it) will be input.
  title() specifies a title for the document.
  body specifies that a <body> tag will be written to the output file,
    initiating a HTML body.
  bodyattributes() specifies attributes for the <body> tag.
  bom() specifies a type of byte order marker (BOM) to enable non-ASCII output files.
*/


*
 Check byte order marker (BOM)
*;
local bom=lower(`"`bom'"');
if `"`bom'"'=="" {;
  local bomvalue="";
};
else if `"`bom'"'=="utf-8" {;
  local bomvalue=ustrunescape("\uFEFF");
};
else {;
  disp as error `"Invalid bom(`bom')"';
  error 498;
};


*
 Set head and body options
 if the headattributes() or title() options and the bodyattributes() option (respectively)
 are specified
*;
if `"`headattributes'"'!="" | `"`title'"'!="" {;
  local head="head";
};
if `"`bodyattributes'"'!="" {;
  local body="body";
};


*
 Open and output HTML tag
*;
file open `namelist' using `"`using'"' , text write `replace';
file write `namelist' `"`bomvalue'<!DOCTYPE html>"' _n;
if `"`attributes'"'=="" {;
  file write `namelist' "<html>" _n;
};
else {;
  file write `namelist' `"<html `attributes'>"' _n;
};


*
 Output HTML head
*;
if "`head'"!="" {;
  if `"`headattributes'"'!="" {;
    file write `namelist' `"<head `headattributes'>"' _n;
  };
  else {;
    file write `namelist' "<head>" _n;
  };
};
if `"`headfrom'"'!="" {;
  * Input HTML head from file *;
  cap noi {;
    conf file `"`headfrom'"';
    tempname inbuff scurline;
    file open `inbuff' using `"`headfrom'"', read text;
    file read `inbuff' curline;
    while !r(eof) {;
      mata: st_strscalar("`scurline'",st_local("curline"));
      file write `namelist' (`scurline') _n;
      file read `inbuff' curline;
    };
    file close `inbuff';  
  };
};
if `"`title'"'!="" {;
  file write `namelist' `"<title>`title'</title>"' _n;
};
if "`head'"!="" {;
  file write `namelist' "</head>" _n;
};


*
 Initiate HTML body if specified
*;
if "`body'"!="" {;
  if `"`bodyattributes'"'!="" {;
    file write `namelist' `"<body `bodyattributes'>"' _n;
  };
  else {;
    file write `namelist' "<body>" _n;
  };
};


end;
