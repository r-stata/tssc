* Example of a Monte Carlo experiment estimating the bias of 1way and 2way fixed
* effect estimators when the DGP is a 2way fixed effect model
* Giovanni SF Bruno, 31may05

program drop _all
set seed 12345
 

program define xtsimee,rclass           /* XTSIMEE: wrapper program to simulate 
				                   the estimation_error of estimators */
version 8.0


xtarsim  y x z w,n(50) t(10) b(.8) g(0)  /* gen the static 2-way fixed effect  
*/ r(.8) one(corr 1) two(corr 50) sn(9)  /* DGP through  XTARSIM */
                                                                         
xtreg y  x, fe                           /* 1way fe estimator (biased) */
mat b=e(b)

return scalar ee_b1=b[1,1]-0.8
return scalar ee_c1=b[1,2]-1             /* load*(1-gamma)=1 */       

tab tvar,gen(ti)
xtreg y  x ti2-ti10, fe                  /* 2way fe estimator excluding the 
							  1st time indicator (unbiased)*/
mat b=e(b)

return scalar ee_b2=b[1,1]-0.8
return scalar ee_c2=b[1,11]-1            /* load*(1-gamma)=1 */


end

/* Monte Carlo experiment to estimate the bias: E(ee) */

if c(stata_version)==9 simulate ee_b1=r(ee_b1) ee_c1=r(ee_c1) ee_b2=r(ee_b2) ee_c2=r(ee_c2), reps(1000): xtsimee
else simulate "xtsimee"  ee_b1=r(ee_b1) ee_c1=r(ee_c1) ee_b2=r(ee_b2) ee_c2=r(ee_c2) ,d reps(1000)


sum, sep(2)     /* estimated bias as the sample mean of ee */
  
