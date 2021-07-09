#delim ;
prog def vallabsave;
version 16.0;
/*
 Save a labels-only dataset
 with no observations or variables
 and a user-specified list of value labels.
*!Author: Roger Newson
*!Date: 15 September 2019
*/

syntax [ namelist ] using/ [, replace DSLabel(string) ];
/*
 replace specifies that any existing file of the same name will be replaced.
 dslabel specifies a dataset label for the label-only dataset.
*/

*
 Set default namelist if necessary
*;
if `"`namelist'"'=="" {;
  qui lab dir;
  local namelist `"`r(names)'"';
};

*
 Create and save label-only dataset
*;
tempname tempframe;
frame create `tempframe';
vallabtran `namelist', to(`tempframe');
* Add dataset label if requested *;
if `"`dslabel'"'!="" {;
  frame `tempframe': label data `"`dslabel'"';
};
frame `tempframe': save `"`using'"', orphans emptyok `replace';

end;
