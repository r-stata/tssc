/*Do file for examples in ``Stata Commands for Testing Conditional Moment 
Ineualites/Equalities'' by D. W. K. Andrews, W. Kim, and X. Shi.*/




/*Example for cmi_test*/
clear all

use cmitest.dta , clear

/*Generating the moment functions*/

gen lbound = ( Y < log(20) ) * D
gen ubound = ( Y < log(20) ) * D + 1 - D


gen CMI1 = 0.5 - lbound 
gen CMI2 = ubound - 0.5

/*Use default options*/
cmi_test (CMI1 CMI2) () X1 X2

/*Use the Kolmogorov-Smirnov type statistic: */

cmi_test (CMI1 CMI2) () X1 X2, ks

/*se Max function and the bootstrap critival value:*/

cmi_test (CMI1 CMI2) () X1 X2, sfunc(3) boot


/*Example for cmi_interval*/

/*Use default options*/
 
cmi_interval (lbound) (ubound) X1 X2

/*Use Max function: */

cmi_interval (lbound) (ubound) X1 X2, sfunc(3) 

/*Use the inequalities defining the lower bound alone, compute up to the second
 decimal point, and compute 90% confidence interval: */

cmi_interval (lbound) ( ) X1 X2, deci(2) level(0.9)


