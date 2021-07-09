#delim ;
prog def prodvars, rclass;
version 10.0;
/*
  Input a left varlist and a right varlist,
  and generate a product variable for each pair of variables
  from the Cartesian product of the left and right varlists,
  with names formed by combining the left and right variable names,
  and values equal to the numeric products of the left and right variable values.
*!Author: Roger B. Newson
*!Date: 08 February 2011
*/

syntax varlist(numeric min=1) [if] [in] , RVarlist(varlist numeric min=1) [
  Generate(name)
  PRefix(string) SUffix(string) SEparator(string)
  LPRefix(string) LSUffix(string) LSEparator(string)
  LLName LRName noLabel
  LCHarlist(namelist) RCHarlist(namelist) CCHarlist(namelist)
  CCPRefix(string) CCSUffix(string) CCSEparator(string)
  noConstant float replace fast ];
/*
varlist is the left variable list.
rvarlist() is the right variable list.
generate() is the stub for generating product variable names.
prefix() is the prefix for the generated product variable names.
suffix() is the suffix for the generated product variable names.
separator() is the separator string for the new variable names.
lprefix() is the prefix for the generated product variable labels.
lsuffix() is the suffix for the generated product variable labels.
lseparator() is the separator string for the generated product variable labels.
llname specifies that variable labels of the generated product variables
  eill be constructed using left variable names
  (instead of left variable labels).
lrname specifies that variable labels of the generated product variables
  eill be constructed using right variable names
  (instead of right variable labels).
lcharlist() specifies a list of characteristics for the output variables,
  to be inherited from the left input varlist.
rcharlist() specifies a list of characteristics for the output variables,
  to be inherited from the right input varlist specified by rvarlist().
ccharlist() specifies a list of characteristics for the output variables,
  to be combined from the characteristics of the same names
  for the corresponding input variables from the left and right input varlists.
ccprefix() specifies a prefix string to be used
  when combining left and right variable characteristics
  specified by ccharlist().
ccsuffix() specifies a suffix string to be used
  when combining left and right variable characteristics
  specified by ccharlist().
ccseparator() specifies a separator string to be used
  when combining left and right variable characteristics
  specified by ccharlist().
nolabel specifies that the generated product variables
  must not have variable labels.
noconstant specifies that constant generated product variables mist be dropped.
float specifies that the maximum precision for generated product variables
  is float (instead of double).
replace specifies that old variables
  with the same names as the generated product variables
  must be replaced.
fast specifies that prodvars will do no extra work
  to preserve the original dataset if the user presses Break.
*/
local leftvars: list uniq varlist;
local rightvars: list uniq rvarlist;
marksample touse;

*
 Create product variable list
*;
local prodvars "";
local i1=0;
foreach X of var `leftvars' {;
  foreach Y of var `rightvars' {;
    if "`generate'"=="" {;
      local XYcur `"`prefix'`X'`separator'`Y'`suffix'"';
    };
    else {;
      local i1=`i1'+1;
      local XYcur "`generate'`i1'";
    };
    if "`replace'"=="" {;
      confirm new var `XYcur';
    };
    else {;
      confirm name `XYcur';
    };
    local prodvars `"`prodvars' `XYcur'"';
  };
};
local prodvars: list retokenize prodvars;

if "`fast'"=="" {;preserve;};

*
 Calculate product variables
*;
local maxprec="`float'";
if "`maxprec'"=="" {;
  local maxprec="double";
};
local i1=0;
foreach X of var `leftvars' {;
  local Xlab: var lab `X';
  if `"`Xlab'"'=="" | "`llname'"!="" {;
    local Xlab "`X'";
  };
  foreach Y of var `rightvars' {;
    local Ylab: var lab `Y';
    if `"`Ylab'"'=="" | "`lrname'"!="" {;
      local Ylab "`Y'";
    };
    local i1=`i1'+1;
    local XYcur: word `i1' of `prodvars';
    if `"`replace'"'!="" {;
      cap drop `XYcur';
    };
    qui {;
      gene `maxprec' `XYcur'=`X'*`Y' if `touse';
      compress `XYcur';
    };
    if "`label'"!="nolabel" {;
      lab var `XYcur' `"`lprefix'`Xlab'`lseparator'`Ylab'`lsuffix'"';
    };
    *
     Define characteristics for product variables
    *;
    foreach CN in `lcharlist' {;
      mata: st_global("`XYcur'[`CN']",st_global("`X'[`CN']"));
    };
    foreach CN in `rcharlist' {;
      mata: st_global("`XYcur'[`CN']",st_global("`Y'[`CN']"));
    };
    foreach CN in `ccharlist' {;
      mata:
        st_global("`XYcur'[`CN']",
          st_local("ccprefix")+st_global("`X'[`CN']")+st_local("ccseparator")+st_global("`Y'[`CN']")+st_local("ccsuffix")
        );
    };
  };
};

*
 Drop constant product variables if requested
*;
if "`constant'"=="noconstant" {;
  local i1=0;
  foreach X of var `leftvars' {;
    foreach Y of var `rightvars' {;
      local i1=`i1'+1;
      local XYcur: word `i1' of `prodvars';
      qui summ `XYcur' if `touse';
      if r(min)==r(max) {;
        drop `XYcur';
        local prodvars: list prodvars - XYcur;
      };
    };
  };
};

if "`fast'"=="" {;restore, not;};

*
 Return list of product variables
*;
return local prodvars "`prodvars'";

end;
