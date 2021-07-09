#delim ;
prog def rcentile, rclass byable(recall);
version 16.0;
/*
 Compute robust confidence intervals for percentiles,
 allowing for clustering and sampling-probability weights.
*!Author: Roger Newson
*!Date: 16 April 2013
*/


syntax varname(numeric) [fweight pweight iweight] [if] [in] [ ,
  CEntile(numlist >=0 <=100 sort)
  Level(cilevel) CLuster(varname) CFWeight(string asis)
  TDist TRansf(string)
  FAST
  ];
/*
centile() specifies the list of percents for the percentiles.
level() specifies the confidence interval level.
cluster() specifies a variable identifying the clusters.
cfweight() specifies the cluster frequency weights.
tdist specifies that confidence intervals will be calculated
  using the t-distribution.
transf() specifies the Normalizing and variance-stabilizing transformation
  used for Somers' D to calculate the confidence intervals.
fast specifies that rcentile will not do any work to restore the original data
  if the user presses Break.
*/


* Initialize percentiles to default *;
if "`centile'"=="" {;
  local centile "50";
};


*
 Preserve data if fast not specified
*;
if "`fast'"=="" {;
  preserve;
};


*
 Initialize estimation sample
*;
marksample touse;
if "`cluster'"!="" {;
  markout `touse' `cluster', strok;
};


*
 Evaluate ordinary Stata weights
 and cluster frequency weights
*;
tempvar wexpval cfwexpval;
* Ordinary weights *;
if `"`exp'"'=="" {;
  qui gene byte `wexpval'=1 if `touse';
};
else if "`weight'"=="fweight" {;
  qui gene long `wexpval'`exp' if `touse';
};
else {;
  qui gene double `wexpval'`exp' if `touse';
};
* Cluster frequency weights *;
if `"`cfweight'"'=="" {;
  qui gene byte `cfwexpval'=1 if `touse';
};
else {;
  cap qui gene long `cfwexpval'=`cfweight' if `touse';
  if _rc!=0 {;
    disp as error "Invalid cfweight()";
    error 498;
  };
};



*
 Define variables containing cluster frequency weights,
 observation frequency weights and importance weights.
 Importance weights are the w_hi in the formulae.
 Observation frequency weights are summed over all observations
 to evaluate the returned result e(N),
 and are used for nothing else.
 Cluster frequency weights (f_i for the i'th cluster)
 must be the same for all observations in the same cluster,
 and signify that the i'th cluster in the data set stands
 for f_i identical clusters in the true sample.
 If cfweight() is specified,
 then it is interpreted as cluster frequency weights,
 and fweights, iweights and pweights are all interpreted
 as importance weights.
 If cfweight() is unspecified and cluster() is specified,
 then fweights, iweights and pweights are all interpreted
 as importance weights,
 and cluster frequency weights are set to one.
 If cfweight() and cluster() are both unspecified,
 then fweights are interpreted as cluster frequency weights
 (and all importance weights are set to one),
 and iweights and pweights are interpreted as importance weights
 (and all cluster frequency weights are set to one).
 Therefore, if cweight() is unspecified,
 then this protocol is equivalent to the standard Stata practice
 of treating iweights and pweights as importance weights
 and treating fweights by doing the calculations
 as if there were multiple identical observations in the data set.
*;
tempvar cfwei ofwei iwei;
if `"`cfweight'"'!="" {;
  * Cluster frequency weights supplied by user *;
  qui gene long `cfwei'=`cfwexpval' if `touse';
  if "`weight'"=="" {;
    qui gene long `ofwei'=`cfwexpval' if `touse';
    qui gene byte `iwei'=1 if `touse';
  };
  else if "`weight'"=="fweight" {;
    qui gene long `ofwei'=`cfwexpval'*`wexpval' if `touse';
    qui gene long `iwei'=`wexpval' if `touse';
  };
  else {;
    qui gene long `ofwei'=`cfwexpval' if `touse';
    qui gene double `iwei'=`wexpval' if `touse';
  };
};
else if "`cluster'"!="" {;
  * Clusters specified without cfweights *;
  qui gene byte `cfwei'=1 if `touse';
  if "`weight'"=="" {;
    qui gene byte `ofwei'=1 if `touse';
    qui gene byte `iwei'=1 if `touse';
  };
  else if "`weight'"=="fweight" {;
    qui gene long `ofwei'=`wexpval' if `touse';
    qui gene long `iwei'=`wexpval' if `touse';
  };
  else {;
    qui gene byte `ofwei'=1 if `touse';
    qui gene double `iwei'=`wexpval' if `touse';
  };
};
else {;
  * No cfweights or clusters *;
  if "`weight'"=="" {;
    qui gene byte `cfwei'=1 if `touse';
    qui gene byte `ofwei'=1 if `touse';
    qui gene byte `iwei'=1 if `touse';
  };
  else if "`weight'"=="fweight" {;
    qui gene long `cfwei'=`wexpval' if `touse';
    qui gene long `ofwei'=`wexpval' if `touse';
    qui gene byte `iwei'=1 if `touse';
  };
  else {;
    qui gene byte `cfwei'=1 if `touse';
    qui gene byte `ofwei'=1 if `touse';
    qui gene double `iwei'=`wexpval' if `touse';
  };
};
* Exclude observations with missing or zero weights *;
foreach X of varlist `ofwei' `cfwei' `iwei' {;
  qui replace `touse'=0 if missing(`X') | (`X'==0);
};


*
 Sum observation frequency weights
 (to be saved as r(N))
*;
tempname N;
qui summ `ofwei' if `touse', meanonly;
scal `N'=r(sum);


* Call sccendif *;
tempvar t_nyvar t_nweight t_ncfweight t_nobs t_nscen;
local wttype="`weight'";
if "`wttype'"=="" {;
  local wttype="iweight";
};
qui sccendif `varlist' 0 if `touse' [`wttype'=`iwei'] ,
  nyvar(`t_nyvar') nweight(`t_nweight') ncfweight(`t_ncfweight') nobs(`t_nobs') nscen(`t_nscen')
  centile(`centile') level(`level') transf(`transf') `tdist'
  cluster(`cluster') cfweight(`cfwei')
  fast;
tempname N_clust df_r cimat;
scal `N_clust'=r(N_clust);
scal `df_r'=r(df_r);
local transf `"`r(transf)'"';
local tranlab `"`r(tranlab)'"';
matr def `cimat'=r(cimat);
matr colnames `cimat'=Percent Centile Minimum Maximum;


*
 Preserve data if fast not specified
*;
if "`fast'"=="" {;
  restore;
};


*
 List confidence limits for percentiles
*;
disp as text "Percentile(s) for variable: " as result "`varlist'";
disp as text "Mean sign transformation: " as result "`tranlab'";
disp as text "Valid observations: " as result `N';
if("`cluster'"!=""){;
  disp as text "Number of clusters (`cluster') = " as result `N_clust';
};
if("`tdist'"!=""){;
  disp as text "Degrees of freedom: " as result `df_r';
};
disp as text "`level'% confidence interval(s) for percentile(s)";
matlist `cimat', noheader noblank nohalf lines(none) names(columns) format(%9.0g);


*
 Return saved results
*;
return matrix cimat `cimat';
return scalar N=`N';
if("`tdist'"!=""){;return scalar df_r=`df_r';};
if("`cluster'"!=""){;
  return scalar N_clust=`N_clust';
};
return scalar level=`level';
return local depvar "`varlist'";
return local wtype "`weight'";
return local wexp "`exp'";
return local centiles "`centile'";
return local tdist "`tdist'";
return local transf "`transf'";
return local tranlab "`tranlab'";
if `"`cfweight'"'!="" {;
  return local cfweight `"`cfweight'"';
};
return local clustvar "`cluster'";


end;
