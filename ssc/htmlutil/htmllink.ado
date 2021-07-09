#delim ;
prog def htmllink;
version 14.0;
/*
 Insert a HTML link into an open file.
*|Author: Roger Newson
*!Date: 18 December 2018
*/

syntax name [ , ATtributes(string) LINKText(string) ];
/*
  attributes() specifies document attributes to be passed to the <img> tag.
  linktext specifies link text (HTML code) to be output
    between the <img> tag and the </img> tag.
*/

*
 Write link.
*;
if `"`attributes'"'=="" {;
  file write `namelist' "<a>" _n;;
};
else {;
  file write `namelist' `"<a `attributes'>"' _n;
};
file write `namelist' `"`linktext'"' _n
  "</a>" _n;

end;
