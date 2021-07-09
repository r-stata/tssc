#delim ;
prog def vallabload;
version 16.0;
/*
 Load a labels-only dataset
 with no observations or variables
 after checking that it has no observations and no variables.
*!Author: Roger Newson
*!Date: 16 September 2019
*/

syntax using/ [, noNOTEs replace ];
/*
 nonotes is ignored. It exists for backwards compatibility.
 replace specifies that variable labels of the same names
 as the loaded variable names will be replaced (not just modified).
*/

*
 Check that the dataset is a labels-only dataset
*;
if `"`using'"'!="" {;
  cap desc using `"`using'"';
  if _rc {;
    disp as error `"File `using' cannot be described as a Stata dataset"';
    error 498;
  };
  else if r(k)>0 | r(N)>0 {;
    disp as error `"File `using' is not a label-only dataset"';
    error 498;
  };
};

*
 Input labels-only dataset to temporary frame
 and transfer labels to current frame
*;
tempname tempframe;
frame create `tempframe';
frame `tempframe': append using `"`using'"';
vallabtran, from(`tempframe') `replace';

end;
