#delimit ;
program define powercal;
version 10.0;
/*
 Carry out power calculations,
 calculating any one of -nunit-, -power-, -alpha-, -delta- and -sdinf-
 from all the rest (and optionally -tdf- if supplied)
*! Author: Roger Newson
*! Date: 26 March 2012
*/
syntax newvarname [if] [in]
  [, Nunit(string asis) Power(string asis) Alpha(string asis) Delta(string asis) Sdinf(string asis)
   Tdf(string asis)
   noCEiling FLOAT ];
/*
 -newvarname- is the output variable name.
 -nunit- is an expression delivering number of units.
 -power- is an expression delivering power.
  (ie probability of detecting difference in right direction).
 -alpha- is an expression delivering size
  (ie probability of type I error if difference is zero).
 -delta- is an expression delivering difference to be detected.
 -sdinf- is an expression delivering SD of influence function
  (=SE*sqrt(-nunit-)).
 -tdf- is an expression delivering degrees of freedom for t-distribution.
 -noceiling- specifies that, if the output variable is a number of units,
  then it is not rounded up to the lowest integer no less than itself.
  (This may be useful if the "number of units" to be calculated
  is a continuous exposure measure, such as a number of person-years,
  instead of a number of discrete units,
  and the -sdinf- expression returns the standard deviation
  of the influence function of a unit of exposure.)
 -float- specifies that the output variable must be of type -float-,
  instead of the default output type -double-.
*/

local explis "nunit power alpha delta sdinf";
local nresult=0;
foreach X in `explis' {;
  if `"``X''"'=="" {;local nresult=`nresult'+1;local result `"`X'"';};
};
if `nresult'<1 {;
  disp as error "All of the following options are present:" _newline "`explis'"
   _newline "One of them must be absent to be calculated";
   error 498;
};
else if `nresult'>1 {;
  disp as error "All except one of the following options must be present:"
    _newline "`explis'";
  error 498;
};
disp as text "Result to be calculated is `result' in variable: " as result "`varlist'";

* Define the sample *;
marksample touse,novarlist;

*
 Create temporary variables containing the expressions in the options
*;
foreach X in `explis' tdf {;
  if `"``X''"'!="" {;
    tempvar `X'_v;
    qui gene double ``X'_v'=(``X'') if `touse';
    qui compress ``X'_v';
    lab var ``X'_v' "Result of `X'";
  };
};
* Convert to missing if out of range *;
foreach X in power alpha {;
  if `"``X''"'!="" {;
    qui replace ``X'_v'=. if `touse' & ((``X'_v'<=0) | (``X'_v'>=1));
    qui compress ``X'_v';
  };
};
foreach X in delta sdinf nunit tdf {;
  if `"``X''"'!="" {;
    qui replace ``X'_v'=. if `touse' & (``X'_v'<=0);
    qui compress ``X'_v';
  };
};

*
 Create variables containing inverse probability functions
*;
if `"`tdf'"'=="" {;
  * Normal distribution *;
  if "`result'"!="power" {;
    tempvar invfb;
    qui {;
      gene double `invfb'=invnormal(`power_v') if `touse';
      compress `invfb';
    };
  };
  if "`result'"!="alpha" {;
    tempvar invfa;
    qui {;
      gene double `invfa'=-invnormal(0.5*`alpha_v') if `touse';
      compress `invfa';
    };
  };
};
else {;
  * Student's t-distribution *;
  if "`result'"!="power" {;
    tempvar invfb;
    qui {;
      gene double `invfb'=-invttail(`tdf_v',`power_v') if `touse';
      compress `invfb';
    };
  };
  if "`result'"!="alpha" {;
    tempvar invfa;
    qui {;
      gene double `invfa'=invttail(`tdf_v',0.5*`alpha_v') if `touse';
      compress `invfa';
    };
  };
};

*
 Create intermediate variables denoted R and S in the manual if required
*;
if inlist("`result'","delta","sdinf","nunit") {;
  tempvar R;
  qui {;
    gene double `R' = `invfa' + `invfb' if `touse';
    compress `R';
  };
};
else if "`result'"=="alpha" {;
  tempvar S;
  qui {;
    gene double `S' = (`delta_v'*sqrt(`nunit_v'))/`sdinf_v' - `invfb' if `touse';
    compress `S';
  };
};

*
 Create result and rename it as the newvarname provided
*;
tempvar tempres;
if "`result'"=="power" {;
  qui{;
    gene double `tempres' = (`delta_v'*sqrt(`nunit_v')/`sdinf_v') - `invfa' if `touse';
    if `"`tdf'"'=="" {;replace `tempres'=normal(`tempres') if `touse';};
    else{;replace `tempres'=ttail(`tdf_v',-`tempres') if `touse';};
  };
};
else if "`result'"=="alpha" {;
  qui{;
    gene double `tempres' = -`S' if `touse' & (`S'>0);
    if `"`tdf'"'=="" {;
      replace `tempres'=normal(`tempres') if `touse';
    };
    else{;
      replace `tempres'=ttail(`tdf_v',-`tempres') if `touse';
    };
    replace `tempres'=2*`tempres' if `touse';
  };
};
else if "`result'"=="delta" {;
  qui gene double `tempres'=(`sdinf_v'/sqrt(`nunit_v'))*`R' if `touse' & (`R'>0);
};
else if "`result'"=="sdinf" {;
  qui gene double `tempres'=(`delta_v'*sqrt(`nunit_v'))/`R' if `touse' &  (`R'>0);
};
else if "`result'"=="nunit" {;
  qui{;
    gene double `tempres'=(`sdinf_v'/`delta_v')*`R' if `touse' & (`R'>0);
    replace `tempres'=`tempres'*`tempres' if `touse';
    if "`ceiling'" != "noceiling" {;
      replace `tempres'=int(`tempres')+1 if `touse'&(`tempres'>int(`tempres'));
    };
  };
};
* Save as much space as the user has allowed *;
if "`float'" != "" {;
  qui recast float `tempres', force;
};
qui compress `tempres';
rename `tempres' `varlist';
if inlist("`result'","power","sdinf") {;
  lab var `varlist' "Maximum `result'";
};
else {;
  lab var `varlist' "Minimum `result'";
};

end;
