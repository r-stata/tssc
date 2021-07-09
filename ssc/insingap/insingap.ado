#delim ;
prog def insingap;
version 11.0;
/*
 Add a single gap observation
 at the top of each by-group defined by the varlist
 or at the top of the dataset if a varlist is not specified,
 and set the row label variable in the gap observations
 to the msdecoded values of a subset of the by-variables,
 or to a user-specified string.
 This program is an easy-to-use wrapper
 for ingap and msdecode.
*!Author: Roger Newson
*!Date: 20 March 2013
*/

syntax [ varlist (default=none) ] [ , INNerorder(varlist) ROWlabel(passthru)
  GROwlabels(passthru) GRDecode(varlist)
  NEWOrder(string)
  GAPindicator(passthru) RSTring(passthru)
  FAST *
  ];
/*
 innerorder() specifies a list of existing variables
   by which observations will be sorted
   within the by-groups specified by the input varlist.
 rowlabel() and growlabel() will be passed to ingap.
 grdecode() specifies a subset of the input varlist,
   to be msdecoded to define the gap row labels.
 neworder() specifies a generated variable
   containing the new order of an observation within the data set
   (within by-group if necessary).
 gapindicator() and rstring() will be passed to ingap.
 fast is a programmer's option,
   specifying that insingap will do no extra work
   to ensure that the original dataset is restored if the user presses Break.
 Other options will be passed to msdecode.
*/

*
 Check that the grdecode() option is a sublist
 of the input varlist.
*;
local invgrdecodes: list grdecode - varlist;
if "`invgrdecodes'"!="" {;
  disp as error "Variables in grdecode() option are not a subset of the input varlist";
  error 497;
};

*
 Parse the neworder() option
*;
genvar_parse `neworder';
local neworder "`r(varname)'";
local neworder_replace "`r(replace)'";

* Preserve old dataset if required *;
if "`fast'"=="" {;preserve;};

*
 Begin building outer order varlist
*;
local outerorder "`varlist'";

*
 Create msdecoded version of grdecode() variables if necessary
*;
if "`grdecode'"!="" {;
  tempvar sgrdecode;
  qui msdecode `grdecode', gene(`sgrdecode') replace `options';
  local outerorder "`outerorder' `sgrdecode'";
  local grexpression "grexpression(`sgrdecode')";
};

*
 Sort dataset if necessary
*;
if "`outerorder'"!="" | "`innerorder'"!="" {;
  sort `outerorder' `innerorder', stable;
};

*
 Insert gap observations
*;
tempvar tempneworder;
if "`outerorder'"!="" {;
  local byouter "by `outerorder':";
};
qui `byouter' ingap 1, neworder(`tempneworder', replace)
  `grexpression' `rowlabel' `growlabels' `gapindicator' `rstring';

*
 Finalize sort order
*;
sort `varlist' `tempneworder';
order `varlist' `tempneworder';
if "`neworder'"!="" {;
  if "`neworder_replace'"!="" {;
    cap drop `neworder';
  };
  rename `tempneworder' `neworder';
  * Set variable label *;
  if "`varlist'"=="" {;
    lab var `neworder' "Order within dataset";
  };
  else {;
    local maxlablen=80;
    if length("`varlist'")+length("Order within: ")>`maxlablen' {;
      lab var `neworder' "Order within by-group";
    };
    else {;
      lab var `neworder' "Order within: `varlist'";
    };
  };
};

* Restore old dataset if required *;
if "`fast'"=="" {;restore, not;};

end;

prog def genvar_parse, rclass;
version 11.0;
/*
 Parse generated variable options
 and return results.
*/

syntax [ name ] [ , replace ];

return local varname "`namelist'";
return local replace "`replace'";

end;
