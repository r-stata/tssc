#delim ;
prog def htmlclose;
version 14.0;
/*
 Close a file for input using HTML.
*!Author: Roger Newson
*!Date: 18 December 2018
*/
;

syntax name [, BOdy ];

if "`body'"!="" {;
  file write `namelist' "</body>" _n;
};
file write `namelist' "</html>" _n;
file close `namelist';

end;
