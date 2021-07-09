#delimit ;
program define normalrir;
version 10.0;
/*
 Calculate Normal ridits of inverse ridits,
 inputting expressions for a uniform deviate variable,
 a mean and standard deviation for a Normal population
 for which the uniform deviate variable is the cumulative distribution function,
 and a mean and standard deviation for the Normal population
 with respect to which the ridits are defined.
*! Author: Roger Newson
*! Date: 02 April 2018
*/
syntax newvarname [if] [in] , Uniform(string asis) [
  MU(string asis) SD(string asis) MUZero(string asis) SDZero(string asis)
  FLOAT
 ];
/*
 newvarname is the output variable name.
 uniform() specifies an expression
   delivering an input uniform deviate variable.
 mu() specifies an expression
   giving the mean of a Normal population.
 sd() specifies an expression
   giving the standard deviation of a Normal population.
 muzero() specifies an expression
   giving the mean of a second Normal population,
   with respect to which the ridits of the inverse ridits are output.
 sdzero() specifies an expression
   giving the standard deviation of a second Normal population,
   with respect to which the ridits of the inverse ridits are output.
 float-specifies that the output variable must be of type float,
   instead of the default type double.
*/


*
  Set default values for input expressions.
*;
if `"`mu'"'=="" {;local mu 0;};
if `"`sd'"'=="" {;local sd 1;};
if `"`muzero'"'=="" {;local muzero 0;};
if `"`sdzero'"'=="" {;local sdzero 1;};


* Define the sample *;
marksample touse, novarlist;


*
 Create temporary variables containing the expressions in the input options
 and mark out missing values
*;
foreach X in uniform mu sd muzero sdzero {;
  tempvar `X'_v;
  qui gene double ``X'_v'=(``X'') if `touse';
  qui compress ``X'_v';
  lab var ``X'_v' "Result of `X'";
  markout `touse' ``X'_v';
};
foreach X in uniform mu sd muzero sdzero {;
  qui replace ``X'_v'=. if !`touse';
};


*
 Create temporary output variable
*;
tempvar toeval tempres;
qui {;
  gene byte `toeval' = `uniform_v'>=0 & `uniform_v'<=1 if `touse';
  gene double `tempres' =. if `touse';
  replace `tempres' = 0 if `touse' & `toeval' & `uniform_v'<c(smallestdouble);
  replace `tempres' = 1 if `touse' & `toeval' & `uniform_v'>1-c(epsdouble);
  replace `tempres' = normal( (invnormal(`uniform_v')*`sd_v' + `mu_v' - `muzero_v')/`sdzero_v' )
    if `touse' & `toeval' & missing(`tempres');
  compress `tempres';
};


*
 Save as much space as the user has allowed
*;
if "`float'" != "" {;
  qui recast float `tempres', force;
};
qui compress `tempres';


*
 Rename and label output variable
*;
rename `tempres' `varlist';
lab var `varlist' "Ridit of inverse ridit";


end;
