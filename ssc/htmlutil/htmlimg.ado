#delim ;
prog def htmlimg;
version 14.0;
/*
 Insert a HTML <img> tag into an open file.
*|Author: Roger Newson
*!Date: 18 December 2018
*/

syntax name [ , ATtributes(string) ];
/*
  attributes specifies document attributes to be passed to the <img> tag.
*/

*
 Write <img> tag.
*;
if `"`attributes'"'=="" {;
  file write `namelist' "<img>" _n;;
};
else {;
  file write `namelist' `"<img `attributes'>"' _n;
};


end;
