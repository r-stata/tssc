#delim ;
prog def bpdifmed, rclass byable(recall);
version 10.0;
/*
 Compute Binett-Price confidence interval
 for difference between medians of 2 groups.
*!Author: Roger Newson
*!Date: 06 October 2016
*/

syntax varname(numeric) [if] [in] , by(varname) [ Level(cilevel) EForm fast ];
/*
 by() specifies a variable containing the group for each observation.
 level() specifies the confidence interval level.
 eform specifies that the confidence intreval is to be displayed
   in an exponentiated form.
 fast specifies that no action is taken to restore the original data
   if the program fails or if the user presses Break.
*/

local yvar `varlist';

*
 Identify estimation sample
*;
marksample touse;
qui replace `touse'=0 if missing(`by');
qui count if `touse';
if r(N)==0 error 2000;

*
 Tabulate grouping variable
 and check that it is binary
*;
disp as text "Group numbers:";
tab `by' if(`touse');
tempname N ngrp;
scal `N'=r(N);
scal `ngrp'=r(r);
if(`N'<=0){;
  error 2000;
};
else if(`ngrp'<2){;
  disp as error "Less than 2 groups found, 2 required";
  error 420;
};
else if(`ngrp'>2){;
  disp as error "More than 2 groups found, only 2 allowed";
  error 420;
};

*
 Identify and create numeric grouping variable
 together with ifs minimum, maximum and value label
*;
local bytype: type `by';
if index("`bytype'","str")==1 {;
  * String by-variable - create numeric grouping variable *;
  tempvar numgroup;
  tempname numgroupvl;
  encode `by' if `touse', gene(`numgroup') label(`numgroupvl');
};
else {;
  * Numeric by-variable - identify numeric grouping variable *;
  local numgroup "`by'";
  local numgroupvl: value label `by';
};
tempname minnumgp maxnumgp;
qui summ `numgroup' if `touse', meanonly;
scal `minnumgp'=r(min);
scal `maxnumgp'=r(max);

*
 Create scalars containing group numbers
 and matrices containing group medians and their variances
*;
tempname N1 N2 b1 b2 V1 V2;
if "`fast'"=="" {;preserve;};
qui bpmedian `yvar' if `touse' & (`numgroup'==`minnumgp'), level(`level') fast;
scal `N1'=e(N);
matr def `b1'=e(b);
matr def `V1'=e(V);
qui bpmedian `yvar' if `touse' & (`numgroup'==`maxnumgp'), level(`level') fast;
scal `N2'=e(N);
matr def `b2'=e(b);
matr def `V2'=e(V);
if "`fast'"=="" {;restore;};

*
 Create output matrix
*;
tempname cimat;
mata:bpdifmed_cimatrix("`cimat'",`level',"`eform'"!="",
  "`N1'","`N2'","`b1'","`b2'","`V1'","`V2'");

*
 Display output matrix
*;
if "`eform'"!="" {;
  disp as text "Sample numbers and Bonett-Price `level'% confidence intervals and P-values"
  _n "for medians of Groups 1 and 2 and their ratio:";
};
else {;
  disp as text "Sample numbers and Bonett-Price `level'% confidence intervals and P-values"
  _n "for medians of Groups 1 and 2 and their difference:";
};
matlist `cimat', noheader noblank nohalf lines(none) names(all) format(%10.0g);

*
 Return saved results
*;
return matrix cimat `cimat';
return scalar level=`level';
return scalar N_2=`N2';
return scalar N_1=`N1';
return scalar N=`N';
return local eform "`eform'";
return local by "`by'";
return local depvar "`yvar'";

end;

#delim cr
version 10.0
mata:

void bpdifmed_cimatrix(string scalar cimat,real scalar level,real scalar eform,
  string scalar N1,string scalar N2,string scalar b1,string scalar b2,string scalar V1,string scalar V2)
{
/*
 cimat is name of output Stata matrix of frequencies, estimates, confidence intervals and P-values.
 level is the confidence level.
 eform indicates if the estimates and confidence limits should be exponentiated.
 N1 and N2 are names of scalars containing numbers of observations in first and second groups.
 b1 and b2 are names of matrices containing estimated medians of first and second groups.
 V1 and V2 are names of matrices containing estimated variances of medians of first and second groups.
*/

real matrix cimatvals, hwid;
string matrix cimrows, cimcols;
string scalar labcur;
/*
 cimatvals will contain values of output confidence interval matrix.
 hwid will contain column vector of standard errors and then confidence interval half-widths.
 cimrows and cimcols will contain row and column stripes for output confidence interval matrix.
 labcur will contain the value label currently being assigned.
*/

/*
 Calculate CI matrix values
*/
cimatvals=J(3,5,.);
cimatvals[1..2,1]=(st_numscalar(N1)\st_numscalar(N2));
cimatvals[3,1]=cimatvals[1,1]+cimatvals[2,1];
cimatvals[1..2,2]=(st_matrix(b1)\st_matrix(b2));
cimatvals[3,2]=cimatvals[1,2]-cimatvals[2,2];
hwid=J(3,1,.);
hwid[1..2,1]=(st_matrix(V1)\st_matrix(V2));
hwid[3,1]=hwid[1,1]+hwid[2,1];
hwid=sqrt(hwid);
cimatvals[1..3,5]=2*((hwid==0)?0:normal(-abs(cimatvals[1..3,2]:/hwid)));
hwid=invnormal(1-(100-level)/200)*hwid;
cimatvals[1..3,3]=cimatvals[1..3,2]-hwid;
cimatvals[1..3,4]=cimatvals[1..3,2]+hwid;

/*
 Calculate CI matrix row and column stripes
*/
cimcols=J(5,2,"");
cimcols[1..5,2]=("N"\"Estimate"\"Minimum"\"Maximum"\"P");
cimrows=J(3,2,"");
cimrows[1..3,2]=("Group_1"\"Group_2"\"Difference");

/*
 Exponentiate and relabel confidence intervals if required
*/
if(eform){
  cimatvals[1..3,2..4]=exp(cimatvals[1..3,2..4]);
  cimrows[3,2]="Ratio";
}

/*
 Return Stata CI matrix
*/
st_matrix(cimat,cimatvals);
st_matrixcolstripe(cimat,cimcols);
st_matrixrowstripe(cimat,cimrows);

}

end
