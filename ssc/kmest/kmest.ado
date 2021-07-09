#delim ;
program kmest, eclass;
version 16.0;
/*
 Compute a vector of Kaplan-Meier survival probabilities
 and/or Kaplan-Meier percentiles
 and save them as returned results,
 for input to bootstrap or jackknife.
 This command assumes that the data have been stset.
*!Author: Roger Newson
*!Date: 11 March 2020
*/


syntax [if] [in], [ Times(numlist) Centiles(numlist >=0 <=100)
  STRansform(string asis) CTRansform(string asis) ];
/*
 times() specifies the survival times
   for which the survival probabilities will be calculated.
 centiles() specifies the percents
   for which the percentiles will be calculated.
 stransform() specifies a transform for survival probabilities.
 ctransform() specifies a transform for percentiles.
*/


*
 Check that times() or centiles() option is present
*;
if "`times'"=="" & "`centiles'"=="" {;
  disp as error "Either times() option or centiles() option must be prsent";
  error 498;
};


*
 Set default stransform and ctransform if necessary
*;
foreach X in stransform ctransform {;
  if `"``X''"'=="" {;
    local `X'="@";
  };
};


*
 Rearrange list of times
 to be ascending and unique.
*;
if "`times'"=="" {;
  local Ntime=0;
};
else {;
  numlist "`times'", sort;
  local times "`r(numlist)'";
  local times: list uniq times;
  local Ntime: word count `times';
};


*
 Rearrange list of percents
 to be ascending and unique.
*;
if "`centiles'"=="" {;
  local Ncentile=0;
};
else {;
  numlist "`centiles'", sort;
  local centiles "`r(numlist)'";
  local centiles: list uniq centiles;
  local Ncentile: word count `centiles';
};


*
 Mark and count sample
*;
marksample touse, novarlist;
tempname Nscal;
summ `touse', meanonly;
scal `Nscal'=r(sum);


*
 Compute Kaplan-Meier estimates for sample
*;
tempvar kmsurv;
qui sts generate `kmsurv'=s if `touse';


*
 Extract survival times and probabilities
*;
tempname survframe;
frame put _t _d `kmsurv' `touse', into(`survframe');
qui frame `survframe' {;
  keep if `touse';
  drop `touse';
  * Extract number of failures *;
  tempname N_fail_scal;
  summ _d, meanonly;
  scal `N_fail_scal'=r(sum);
  * Create output vectors of times and survival probabilities *;
  if `Ntime'>0 {;
    tempname tmat smat sscal cfmat cfscal;
    local sstransform=subinstr(`"`stransform'"',"@","`sscal'",.);
    matr def `tmat'=J(1,`Ntime',.);
    matr def `smat'=J(1,`Ntime',.);
    matr def `cfmat'=J(1,`Ntime',.);
    matr rownames `tmat'="_t";
    matr rownames `smat'="_t";
    matr rownames `cfmat'="_t";
    local cnames "";
    forv i1=1(1)`Ntime' {;
      local cnames `"`cnames' st_`i1'"';
    };
    matr colnames `tmat'=`cnames';
    matr colnames `smat'=`cnames';
    matr colnames `cfmat'=`cnames';
    forv i1=1(1)`Ntime' {;
      local Tcur: word `i1' of `times';
      matr def `tmat'[1,`i1']=`Tcur';
      summ `kmsurv' if _t<=`Tcur', meanonly;
      scal `sscal'=min(r(min),1);
      scal `sscal'=`sstransform';
      if missing(`sscal') {;
        disp as error `"stransform(`stransform') produced a missing value"';
        error 498;
      };
      matr def `smat'[1,`i1']=`sscal';
      summ _d if _t<=`Tcur', meanonly;
      scal `cfscal'=max(r(sum),0);
      matr def `cfmat'[1,`i1']=`cfscal';
    };
  };
  * Create output vectors of percents and percentiles *;
  if `Ncentile'>0 {;
    tempname pmat cmat cscal;
    local sctransform=subinstr(`"`ctransform'"',"@","`cscal'",.);
    matr def `pmat'=J(1,`Ncentile',.);
    matr def `cmat'=J(1,`Ncentile',.);
    matr rownames `pmat'="_t";
    matr rownames `cmat'="_t";
    local cnames "";
    forv i1=1(1)`Ncentile' {;
      local cnames `"`cnames' ce_`i1'"';
    };
    matr colnames `pmat'=`cnames';
    matr colnames `cmat'=`cnames';
    forv i1=1(1)`Ncentile' {;
      local Pcur: word `i1' of `centiles';
      matr def `pmat'[1,`i1']=`Pcur';
      if `Pcur'<=0 {;
        scal `cscal'=0;
      };
      else {;
        summ _t if `kmsurv'<=(100-`Pcur')/100, meanonly;
        scal `cscal'=min(r(min),c(maxdouble));
      };
      scal `cscal'=`sctransform';
      if missing(`cscal') {;
        disp as error `"ctransform(`ctransform') produced a missing value"';
        error 498;
      };
      matr def `cmat'[1,`i1']=`cscal';
    };
  };
};


*
 Create output matrices
*;
if `Ntime'>0 {;
  tempname temat;
  matr def `temat'=`tmat'',`smat'';
  matr colnames `temat'="Time" "Survival";
};
if `Ncentile'>0 {;
  tempname cemat;
  matr def `cemat'=`pmat'',`cmat'';
  matr colnames `cemat'="Percent" "Percentile";
};


*
 List times and estimates
*;
if `Ntime'>0 {;
  if `"`stransform'"'!="@" {;
    disp as text "stransform() option: " as result `"`stransform'"';
  };
  matr list `temat', noheader;
};
if `Ncentile'>0 {;
  if `"`ctransform'"'!="@" {;
    disp as text "ctransform() option: " as result `"`ctransform'"';
  };
  matr list `cemat', noheader;
};


*
 Return results
*;
tempname bmat timcen;
if `Ntime'>0 & `Ncentile'>0 {;
  matr def `bmat'=`smat',`cmat';
  matr def `timcen'=`tmat',`pmat';
};
else if `Ntime'>0 {;
  matr def `bmat'=`smat';
  matr def `timcen'=`tmat';
};
else if `Ncentile'>0 {;
  matr def `bmat'=`cmat';
  matr def `timcen'=`pmat';
};
ereturn post `bmat', obs(`=`Nscal'') esample(`touse');
ereturn scalar N_fail=`N_fail_scal';
ereturn matrix timcen=`timcen';
if `Ncentile'>0 {;
  ereturn matrix cemat=`cemat';
  ereturn matrix centiles=`cmat';
};
ereturn local predict "kmest_p";
ereturn local ctransform `"`ctransform'"';
ereturn local stransform `"`stransform'"';
if `Ntime'>0 {;
  ereturn matrix cumfail=`cfmat';
  ereturn matrix temat=`temat';
  ereturn matrix times=`tmat';
};


end;
