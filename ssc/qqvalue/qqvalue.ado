#delim ;
prog def qqvalue, byable(onecall) sortpreserve;
version 10.0;
/*
  Generate frequentist q-values corresponding to multiple test procedures.
  Take, as input, a data set with 1 obs per null hypothesis tested
  and a variable containing the correspoding P-values,
  and a specified multiple test procedure method.
  Create, as output, new variables
  containing numbers of P-values, P-value ranks,
  sky-limited inverse critical P-value thresholds,
  roofed inverse critical P-value thresholds,
  and corresponding q-values.
*! Author: Roger Newson
*! Date: 08 October 2012
*/

syntax varname(numeric) [if] [in] [ ,
 MEthod(name) BEstof(integer 0)
 QValue(name) NPvalue(name) RAnk(name) SValue(name) RValue(name)
 FLOAT FAST ];
/*
 method() specifies the method used to generate the q-values.
 bestof() specifies the total number of P-values
   (in case the P-values provided are the smallest P-values of a greater set).
 qvalue() specifies the name of the output variable
   containing the q-values.
 npvalue() specifies the name of the output variable
   containing the number of P-values in the dataset or by-group.
 rank() specifies the name of the output variable
   containing the ranks of the input P-values
  (from lowest to highest, with ties sorted in original order).
 svalue() specifies the name of the output variable containing the s-values,
   which are the sky-limited uncorrected critical P-values
   calculated from the input P-values
   by inverting the critical P-value threshold formulas specified by method().
 rvalue() specifies the name of the output variable containing the r-values,
   which are the roof-limited uncorrected critical P-values
   calculated by truncating the sky-limited s-values at a maximum of 1.
 float specifies that the output variables qvalue(), rvalue() and svalue()
   will be saved as float variables (instead of double variables).
 fast is an option for programmers,
   specifying that -multproc- will take no action to restore the pre-existing data set
   if error occurs or the user presses Break.
*/

* Set macro pvalue to contain supplied variable *;
local pvalue "`varlist'";

*
 Set default value for method if necessary
 and check that it is recognized
*;
if "`method'"=="" {;
  local method "bonferroni";
};
if !inlist("`method'","bonferroni","sidak","holm","holland","hochberg","simes","yekutieli") {;
  disp as error `"Unrecognised method(`method')"';
  error 498;
};

marksample touse;

if "`fast'"=="" {;preserve;};

*
 Define temporary output variables if necessary,
 otherwise confirm validity of user-defined output variable names,
 and initialise output variables to missing
*;
foreach X of any qvalue npvalue rank svalue rvalue {;
  if "``X''"=="" {;tempvar `X';};
  else {;confirm new variable ``X'';};
};

*
 Sort and generate ranks and numbers of P-values
*;
qui {;
  sort `touse' `_byvars' `pvalue', stable;
  by `touse' `_byvars': gene long `npvalue'=_N if `touse';
  by `touse' `_byvars': gene long `rank'=_n if `touse';
  if `bestof'>0 {;
    cap assert `npvalue'<=`bestof' if `touse';
    if _rc {;
      disp as error "Number of P-values is greater than option bestof(" `bestof' ")";
      error 498;
    };
    else {;
      replace `npvalue'=`bestof' if `touse';
    };
  };
};

*
 Generate s-values
*;
qui {;
  if "`method'"=="bonferroni" {;
    gene double `svalue'=`npvalue'*`pvalue' if `touse';
  };
  else if "`method'"=="sidak" {;
    gene double `svalue'=1-(1-`pvalue')^`npvalue' if `touse' & 1-`pvalue'<1;
    replace `svalue'=`npvalue'*`pvalue' if `touse' & 1-`pvalue'>=1;
  };
  else if inlist("`method'","holm","hochberg") {;
    gene double `svalue'=`pvalue'*(`npvalue'-`rank'+1) if `touse';
  };
  else if "`method'"=="holland" {;
    gene double `svalue'=1-(1-`pvalue')^(`npvalue'-`rank'+1) if `touse' & 1-`pvalue'<1;
    replace `svalue'=`pvalue'*(`npvalue'-`rank'+1) if `touse' & 1-`pvalue'>=1;
  };
  else if "`method'"=="simes" {;
    gene double `svalue'=`pvalue'*(`npvalue'/`rank') if `touse';
  };
  else if "`method'"=="yekutieli" {;
      tempvar toeval suminvr;
      gene byte `toeval'=`touse' & (`rank'==1);
      gene double `suminvr'=.;
      mata: qqvalue_suminvr("`toeval'","`npvalue'","`suminvr'");
      by `touse' `_byvars': replace `suminvr'=`suminvr'[1] if `touse';
      gene double `svalue'=`pvalue'*`suminvr'*(`npvalue'/`rank') if `touse';
      drop `toeval' `suminvr';
  };
  else {;
    disp as error `"Unrecognised method(`method')"';
    error 498;
  };
};

*
 Generate r-values
*;
qui gene double `rvalue'=min(`svalue',1) if `touse' & !missing(`svalue');

*
 Generate q-values
*;
qui {;
  gene double `qvalue'=.;
  if inlist("`method'","bonferroni","sidak") {;
    * One-step procedure *;
    replace `qvalue'=`rvalue' if `touse';
  };
  else if inlist("`method'","holm","holland") {;
    * Step-down procedure *;
    by `touse' `_byvars': replace `qvalue'=cond(_n==1,`rvalue',max(`rvalue',`qvalue'[_n-1])) if `touse';
  };
  else if inlist("`method'","hochberg","simes","yekutieli") {;
    * Step-up procedure *;
    gsort `touse' `_byvars' -`rank';
    by `touse' `_byvars': replace `qvalue'=cond(_n==1,`rvalue',min(`rvalue',`qvalue'[_n-1])) if `touse';
    sort `touse' `_byvars' `pvalue' `rank';
  };
  else {;
    disp as error `"Unrecognised method(`method')"';
    error 498;
  };
};

*
 Complete calculation of output variables
*;
* Convert double variables to float if specified *;
if ("`float'"!="") {;
  foreach X of var `qvalue' `rvalue' `svalue' {;
    qui recast float `X', force;
  };
};
* Compress to save space if possible *;
qui compress `rank' `npvalue' `qvalue' `rvalue' `svalue';

*
 Variable labels for new variables
*;
lab var `npvalue' "Number of P-values";
lab var `rank' "P-value rank";
lab var `svalue' "s-value by method(`method')";
lab var `rvalue' "r-value by method(`method')";
lab var `qvalue' "q-value by method(`method')";

if "`fast'"=="" {;restore,not;};

end;

#delim cr
/*
  Private Mata programs used by qqvalue
*/
mata:

void qqvalue_suminvr(string scalar toeval,string scalar npvalue,string scalar suminvr)
{
/*
  Input the name of a variable in npvalue
  containing numbers of P-values per by group,
  and the name of a variable in toeval
  containing the observations in which evaluation is to be done,
  and the name of a variable in suminvr,
  to be evaluated as the sum of inverse P-value ranks,
  and evaluate sums of inverse P-value ranks.
*/
real matrix datmat;
real scalar rowcur, npvalcur, suminvrcur, rankcur;
/*
  datmat will contain the data matrix view.
  npvalcur will contain the current number of P-values.
  suminvrcur will contain the current accumulating sum of inverse ranks.
  rankcur will contain the rank whose reciprocal is currently being evaluated.
*/

printf("Entered qqvalue_suminvr\n");

/*
  Evaluate datmat[.,2] from datmat[.,1].
*/
st_view(datmat,.,(npvalue,suminvr),toeval);
for (rowcur=1;rowcur<=rows(datmat);rowcur++) {
  npvalcur=datmat[rowcur,1];
  suminvrcur=0;
  for (rankcur=npvalcur;rankcur>0;rankcur--) {
    suminvrcur=suminvrcur+(1/rankcur);
  }
  datmat[rowcur,2]=suminvrcur;
}

}

end
