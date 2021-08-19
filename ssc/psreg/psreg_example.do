// Data import
use psreg_example_data, clear

//  Treatment
tab treatment  // follow a training programme for unemployed

// Outcome variable
* employment status 15 months after treatment 
tab employed

// BRA estimates - default options
psreg employed treatment female native age emp_status12 emp_status24
* ATT= 0.101**
* 6 blocks

// BRA estimates - additional examples
psreg employed treatment female native age emp_status12 emp_status24, logit common quietly
** uses logit instead of the default probit to estimate the propensity score
** defines common support
** does not print the regressions within each block
* ATT= 0.098**
* 5 blocks
* 1 unit off support

psreg employed treatment female native age emp_status12 emp_status24, groups(3) ate
** define a specific number of blocks .
** computes the ATE instead of the default ATT
* ATE= 0.077*
* 3 blocks


  


