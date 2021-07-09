* Example of a Monte Carlo experiment estimating the small-sample bias of AR(1) fixed effect 
* and AR(1) random effect estimators when the DGP is an AR(1) random effect model
* Giovanni SF Bruno, 31may05



program drop _all
set seed 12345
 

program define xtsimee,rclass                 /* XTSIMEE:  program to simulate the
                                                estimation_error of estimators */
version 8.0


xtarsim  y x z,n(20) t(10) b(.8)              /* set up the DGP using xtarsim 
*/ g(.2) r(.8) sn(2)                                                   
                                                         
qui gen y_1=l.y
xtreg y y_1 x, fe                             /* fe (LSDV) estimator */
mat b=e(b)

return scalar ee_g_fe=b[1,1]-0.2              /* estimation error */
return scalar ee_b_fe=b[1,2]-0.8
return scalar ee_c_fe=b[1,3]-0.0              

xtreg y y_1 x                                 /* re (GLS) estimator */
mat b=e(b)

return scalar ee_g_re=b[1,1]-0.2              /* estimation error */
return scalar ee_b_re=b[1,2]-0.8
return scalar ee_c_re=b[1,3]-0.0              

end

/* Monte Carlo experiment to estimate the bias, E(ee), of both estimators */

if c(stata_version)==9 simulate ee_g_fe=r(ee_g_fe) ee_b_fe=r(ee_b_fe) ee_c_fe=r(ee_c_fe) /*
*/ ee_g_re=r(ee_g_re) ee_b_re=r(ee_b_re) ee_c_re=r(ee_c_re), reps(1000): xtsimee
else simulate "xtsimee" ee_g_fe=r(ee_g_fe) ee_b_fe=r(ee_b_fe) ee_c_fe=r(ee_c_fe) /*
*/ ee_g_re=r(ee_g_re) ee_b_re=r(ee_b_re) ee_c_re=r(ee_c_re),d reps(1000)

sum,sep(3)     /* estimated bias as the sample mean of ee */
  
