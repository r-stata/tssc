#delim ;
prog def parmcip, byable(onecall);
version 16.0;
/*
  Input a dataset with 1 obs per parameter
  and variables containing estimates, standard errors
  and (optionally) degrees of freedom.
  Add output variables containing z-statistics or t-statistics,
  confidence limits and P-values.
*! Author: Roger Newson
*! Date: 09 April 2020
*/

syntax [if] [in] [, noTDist EForm FLOAT FAST
      ESTimate(varname) STDerr(varname) Dof(varname)
      Zstat(name) Tstat(name) Pvalue(name)
      STArs(numlist descending >=0 <=1) NSTArs(name)
      LEvel(numlist >=0 <100 sort) CLNumber(string) MINprefix(name) MAXprefix(name)
      MCOMPare(name) MCOMCi(name) noZErop NUllvalue(numlist min=1 max=1)
      replace
      ];
/*
noTDist specifies whether or not a t-distribution is used
  to calculate confidence limits
  (defaulting to tdist if dof() variable exists and to notdist otherwise).
EForm indicates that the input estimates are exponentiated,
  and that the input standard errors are multiplied by the exponentiated estimate,
  and that the output confidence limits are to be exponentiated.
FLOAT specifies that the numeric output variables
  will be created as type float or below.
FAST is an option for programmers, and specifies that no action will be taken
  to restore the original data if the user presses Break.
ESTimate() contains the name of the input variable containing estimates
  (defaulting to "estimate").
STDerr() contains the name of the input variable containing standard errors
  (defaulting to "stderr").
Dof() contains the name of the input variable containing degrees of freedom
  (defaulting to "dof").
Zstat() contains the name of the output variable containing the z-statistics
  (defaulting to "z").
Tstat() contains the name of the output variable containing the t-statistics
  (defaulting to "t").
Pvalue() contains the name of the output variable containing the P-values
  (defaulting to "p").
STArs() specifies a list of P-value thresholds,
  and indicates that the new data set should contain a string variable
  with default name stars,
  containing, in each observation, one star for each P-value threshold alpha
  such that the variable p is less than or equal to alpha.
NSTArs() specifies the name of the output variable containing the stars
  (defaulting to "stars" if stars() is present, and ignored otherwise).
LEvel() specifies the confidence level(s) to be used
  in calculating the lower and upper confidence limits minxx and maxxx
  (defaulting to $S_level if not specified).
CLNumber() specifies the method for numbering the names
  of the lower and upper confidence limit variable names minxx and maxxx,
  and may be level (specifying that xx is the confidence level)
  or rank (specifying that xx is the rank, in ascending order,
  of the confidence level in the set of levels specified in the level option).
MINprefix() specifies the prefix for the lower confidence limits
  (defaulting to "min").
MAXprefix() specifies the prefix for the upper confidence limits
  (defaulting to "max").
MCOMPare specifies a multiple-comparison correction method
  to be used with confidence limits and P-values.
MCOMCi specifies a multiple-comparison correction method
  to be used with confidence limits only.
noZErop specifies that P-values below c(smallestdouble) will be left-truncated
  to c(smallestdouble).
NUllvalue specifies the parameter values under the null hypotheses tested
  using the t- or z-statistics and confidence intervals.
replace specifies that generated variables
  should overwrite existing variables of the same names.
*/


*
 Set bybyvars macro.
*;
if _by() {;
  local bybyvars "by `_byvars' `_byrc0':";
};


*
 Set default input options
*;
if "`estimate'"=="" {;local estimate "estimate";};
if "`stderr'"=="" {;local stderr "stderr";};
if "`dof'"=="" {;local dof "dof";};
if "`tdist'"=="" {;
  cap confirm variable `dof';
  if _rc==0 {;
    local tdist "tdist";
  };
  else {;
    local tdist "notdist";
    disp as text "Note: variable `dof' not found, normal distribution assumed";
  };
};
if "`nullvalue'"=="" {;
  local nullvalue=.;
};
if missing(`nullvalue') {;
  if "`eform'"=="" {;
    local nullvalue=0;
  };
  else {;
    local nullvalue=1;
  };
};
if "`mcompare'"=="" {;
  local mcompare "noadjust";
};
if "`mcomci'"=="" {;
  local mcomci "`mcompare'";
};
foreach MC in mcompare mcomci {;
  if strpos("noadjust","``MC''")==1 & length("``MC''")>=5 {;
    local `MC' "noadjust";
  };
  else if strpos("bonferroni","``MC''")==1 & length("``MC''")>=3 {;
    local `MC' "bonferroni";
  };
  else if strpos("sidak","``MC''")==1 & length("``MC''")>=3 {;
    local `MC' "sidak";
  };
  else {;
    disp as error "Invalid `MC'(``MC'')";
    error 498;
  };
};


*
 Set default output options
*;
if "`tdist'"=="notdist" & "`zstat'"=="" {;local zstat "z";};
if "`tdist'"=="tdist" & "`tstat'"==""  {;local tstat "t";};
if "`pvalue'"=="" {;local pvalue "p";};
if "`stars'"!="" & "`nstars'"=="" {;local nstars "stars";};
if "`minprefix'"=="" {;local minprefix "min";};
if "`maxprefix'"=="" {;local maxprefix "max";};


*
 Check for name clashes of output variables
 with input variables and with each other
*;
local invars "`estimate' `stderr'";
if "`tdist'"=="tdist" {;
  local invars "`invars' `dof'";
};
local outvars "";
local iovars "`invars'";
foreach Y in `zstat' `tstat' `pvalue' `nstars' {;
  local clash: list Y in iovars;
  if `clash' {;
    disp _n as error "Clash with output variable name: " as result "`Y'"
      _n as error "Existing input variable names: " as result "`invars'"
      _n as error "Existing output variable names: " as result "`outvars'";
    error 498;
  };
  else {;
    local outvars "`outvars' `Y'";
    local iovars "`iovars' `Y'";
  };
};


*
 Set maximum numeric type according to float option
*;
if "`float'"=="" {;local maxntype "double";};
else {;local maxntype "float";};


*
 Set level to default value
 and set local macro nlevel to number of distinct levels
*;
if "`level'"=="" {;
    local level=c(level);
};
local nlevel:word count `level';


*
 Set clnumber to default value if absent
 and check that it is valid if present
*;
if `"`clnumber'"'=="" {;
    local clnumber "level";
};
if !inlist(`"`clnumber'"',"level","rank") {;
    disp as error `"Invalid clnumber(`clnumber')"';
    error 498;
};


if "`fast'"=="" {;preserve;};


marksample touse;


*
 Define symmetric estimates and standard errors
 for use in calculating test statistics, P-values and confidence limits
 (important if eform option is specified)
*;
if "`eform'"=="" {;
  local sestimate "`estimate'";
  local sstderr "`stderr'";
};
else {;
  tempvar sestimate sstderr;
  qui gene double `sestimate' = log(`estimate') if `touse';
  qui gene double `sstderr' = `stderr' / `estimate' if `touse';
};


* Calculate number of multiple comparisons *;
tempvar Ncomp;
if "`mcompare'"!="noadjust" | "`mcomci'"!="noadjust" {;
  qui `bybyvars' egen `Ncomp'=total(`touse');
};


* Add t-statistics or z-scores and P-values *;
if "`eform'"=="" {;
  local snullvalue "`nullvalue'";
};
else {;
  local snullvalue=log(`nullvalue');
  if missing(`snullvalue') {;
    disp as error "Missing value for log of nullvalue(`nullvalue')"
      _n "nullvalue() must be positive if eform is specified";
    error 498;
  };
};
if "`tdist'"=="notdist" {;
    * Normal distribution *;
    if "`replace'"!="" {;
      foreach Y in `zstat' `pvalue' {;cap drop `Y';};
    };
    qui gene double `zstat' = (`sestimate' - `snullvalue') / `sstderr' if `touse';
    qui gene double `pvalue' = 2 * normprob(-abs(`zstat')) if `touse';
    if "`maxntype'"!="double" {;
      recast `maxntype' `tstat', force;
    };
    qui compress `zstat';
    label variable `zstat' "Standard normal deviate";
};
else {;
    * t-distribution *;
    if "`replace'"!="" {;
      foreach Y in `tstat' `pvalue' {;cap drop `Y';};
    };
    qui gene double `tstat' = (`sestimate' - `snullvalue') / `sstderr' if `touse';
    qui gene double `pvalue' = tprob(`dof',`tstat') if `touse';
    if "`maxntype'"!="double" {;
      recast `maxntype' `zstat', force;
    };
    qui compress `tstat';
    label variable `tstat' "t-test statistic";
};
if "`mcompare'"=="bonferroni" {;
  qui replace `pvalue'=`pvalue'*`Ncomp' if `touse';
  qui replace `pvalue'=min(`pvalue',1) if `touse' & !missing(`pvalue');
};
else if "`mcompare'"=="sidak" {;
  qui replace `pvalue'=1-(1-`pvalue')^`Ncomp' if `touse' & 1-`pvalue'<1;
  qui replace `pvalue'=`pvalue'*`Ncomp' if `touse' & 1-`pvalue'==1;
  qui replace `pvalue'=min(`pvalue',1) if `touse' & !missing(`pvalue');
};
if "`zerop'"=="nozerop" {;
  qui replace `pvalue'=c(smallestdouble) if `touse' & `pvalue'<c(smallestdouble);
};
qui compress `pvalue';
if "`maxntype'"!="double" {;
  recast `maxntype' `pvalue', force;
};
label variable `pvalue' "P-value";
char def `pvalue'[mcom] "`mcompare'";


*
 Add stars for P-values if requested
*;
if `"`stars'"'!="" {;
  if "`replace'"!="" {;cap drop `nstars';};
  qui{;
    gene str1 `nstars'="" if `touse';
    foreach A of numlist `stars' {;
      replace `nstars'=`nstars'+"*" if `touse' & `pvalue'<=`A';
    };
    qui compress `nstars';
    * Choose a default left-justified string format for stars *;
    tempvar numstars;
    gene `numstars'=length(`nstars') if `touse';
    summ `numstars';
    local mstars=max(r(max),1);
    drop `numstars';
    format `nstars' %-`mstars's;
    lab var `nstars' "Stars for P-value";
  };
};


* Add confidence limits *;
tempvar hwid alpha;
local i1=0;
foreach leveli1 of numlist `level' {;
    local i1=`i1'+1;
    if `"`clnumber'"'=="rank" {;
        * Number confidence limits by ascending rank of level *;
        local cimin "`minprefix'`i1'";
        local cimax "`maxprefix'`i1'";
    };
    else {;
        * Number confidence limits by level *;
        *
         Create macro sleveli1 containing string version of leveli1
         to define variable names for confidence limits
        *;
        local sleveli1="`leveli1'";
        local sleveli1=subinstr("`sleveli1'",".","_",.);
        local sleveli1=subinstr("`sleveli1'","-","m",.);
        local sleveli1=subinstr("`sleveli1'","+","p",.);
        local cimin  "`minprefix'`sleveli1'";
        local cimax  "`maxprefix'`sleveli1'";
    };
    * Check for name clashes involving confidence limits *;
    foreach Y in `cimin' `cimax' {;
      local clash: list Y in iovars;
      if `clash' {;
        disp _n as error "Clash with output variable name: " as result "`Y'"
          _n as error "Existing input variable names: " as result "`invars'"
          _n as error "Existing output variable names: " as result "`outvars'";
        error 498;
      };
      else {;
        local outvars "`outvars' `Y'";
        local iovars "`iovars' `Y'";
      };
    };
    * Generate confidence limits *;
    qui gene double `alpha'=(100-`leveli1')/100;
    if "`mcomci'"=="bonferroni" {;
      qui replace `alpha' = `alpha'/`Ncomp';
    };
    else if "`mcomci'"=="sidak" {;
      qui replace `alpha' = 1 - (1-`alpha')^(1/`Ncomp');
    };
    if "`tdist'"=="notdist" {;
        qui gene double `hwid' = `sstderr'*invnorm(1-`alpha'/2) if `touse';
    };
    else {;
        qui gene double `hwid' = `sstderr'*invttail(`dof',`alpha'/2) if `touse';
    };
    if "`replace'"!="" {;
      foreach Y in `cimin' `cimax' {;cap drop `Y';};
    };
    qui gene double `cimin' = `sestimate' - `hwid' if `touse';
    qui gene double `cimax' = `sestimate' + `hwid' if `touse';
    * Exponentiate if requested *;
    if "`eform'"!="" {;
      qui replace `cimin' = exp(`cimin') if `touse';
      qui replace `cimax' = exp(`cimax') if `touse';
    };
    if "`maxntype'"!="double" {;
      qui recast `maxntype' `cimin' `cimax', force;
    };
    qui compress `cimin' `cimax';
    drop `hwid' `alpha';
    label variable `cimin' "Lower `leveli1'% confidence limit";
    label variable `cimax' "Upper `leveli1'% confidence limit";
    char `cimin'[level] `=`leveli1'';
    char `cimax'[level] `=`leveli1'';
    char `cimin'[mcom] "`mcomci'";
    char `cimax'[mcom] "`mcomci'";
};


if "`fast'"=="" {;restore, not;};

end;
