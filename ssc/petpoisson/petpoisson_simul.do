*********************************************************************
**** Endogenous participation endogenous treatment Poisson model ****
****                                                             ****
**** Example with simulated data                                 ****
****                                                             ****
**** Author: Alfonso Miranda (A.Miranda@ioe.ac.uk)               ****
**** Date: 11/01/2012                                            ****
*********************************************************************

set seed 5674
set obs 1500
local Vu = 0.10
local SEu = sqrt(`Vu')
local lambda_1 = 1.2
local lambda_2 = 1.2
gen double x1=invnormal(uniform())
gen double x2=invnormal(uniform())
gen double x3=invnormal(uniform())
gen double u = `SEu'*invnormal(uniform())
gen double zeta = invnormal(uniform())
gen double xi = invnormal(uniform())
gen double Tstar = 0 + 2.5*x1 + 0*x2 + 0*x3 + ///
(`lambda_1'*u + xi)/sqrt(`lambda_1'^2*`Vu'+1)
gen T = (Tstar>0)
gen double Pstar = 0.5 + 1.5*T + 0*x1 -1.9*x2 + 0*x3 + ///
 (`lambda_2'*u + zeta)/sqrt(`lambda_2'^2*`Vu' + 1)
gen P = (Pstar>0)
gen double mu = exp(1.56 + 1*T + 0*x1 + 0*x3 -0.8*x3 + u)
su mu
gen count = 0
gen double xp = .
scalar minx = 0
while minx==0 {
 qui replace xp = rpoisson(mu)
 qui replace count = xp if count==0
 qui su count
 scalar minx = r(min)
}
qui replace count = . if P==0

/* Probit for treatment dummy */

probit T x1 x2 x3

/* Probit for the participation dummy */

probit P T x1 x2 x3

/* Poisson for main response */

poisson count T x1 x2 x3

/* EPET-Poisson */

#delimit ;
petpoisson (T = x1) (P = T x2) (count = T x3), rep(1600) hvec(1 1 100) ;
#delimit cr

/* Marginal effects at mean of explanatory variables */

petpoisson_me

/* Marginal effects at mode of explanatory variables */

petpoisson_me, dmode

/* Marginal effects at 0.3 quantile of the linear predictors */

petpoisson_me, xbquantile(0.3)

/* Marginal effect of treatment at mode of the count dependent variable */

petpoisson_me, cmode(T 2)





