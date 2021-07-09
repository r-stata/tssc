version 10
prog drop _all
set more 1

      est clear
      sysuse auto, clear
      poisson mpg disp wei, r
      est sto pois
      ivpois mpg wei, exog(turn) endog(disp)
      est sto endog
      ivpois mpg disp wei, exog(turn)
      est sto excl
      ivpois mpg disp wei
      est sto noexcl
      g manuf=word(make,1)
      bs, cl(manuf): ivpois mpg wei, exog(turn) endog(disp)
      est sto clustbs
      cap ssc inst estout
      esttab *, nogaps se mti

/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Comparison of poisson to ivpois with an exposure variable and a small sample.
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
      est clear
      webuse dollhill3, clear
      tab agecat, gen(a)
      drop a4 a5
      poisson deaths smokes a?, exposure(pyears) r
      est sto p
      bs: poisson deaths smokes a?, exposure(pyears)
      est sto bsp
      ivpois deaths smokes a?, exposure(pyears)
      est sto gmm
      bs: ivpois deaths smokes a?, exposure(pyears)
      est sto bsgmm
      cap ssc inst estout
      esttab *, nogaps se mti

/*-------------------------------------------------------------------------------------------------------------------------------------------------------
The following three examples offer a comparison of linear regression of ln(y) on X to Poisson regression of y on X, and each model has some real
economic content.  You will need to install ivreg2 from SSC to run these examples.
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
*    An example from Card (1995):
      use http://fmwww.bc.edu/ec-p/data/wooldridge/card, clear
      loc x "exper* smsa* south mar black reg662-reg669"
      ivreg2 lw `x' (educ=nearc4)
      ivpois wage `x', endog(educ) exog(nearc4)

*    An example from Mullahy (1997) where ivreg2 reports no evidence of a weak instruments problem:
      use http://fmwww.bc.edu/RePEc/bocode/i/ivp_bwt.dta, clear
      g lnbw=ln(bw)
      loc x "parity white male"
      loc z "edfwhite edmwhite incwhite cigtax88"
      ivreg2 lnbw `x' (cigspreg=`z')
      ivpois bw `x', endog(cigspreg) exog(`z')

*    An example from Mullahy (1997) where ivreg2 reports evidence of a weak instruments problem:
      use http://fmwww.bc.edu/RePEc/bocode/i/ivp_cig.dta, clear
      g lnc=ln(cigpacks)
      loc x "pcigs79 rest79 income age qage educ qeduc famsize white"
      loc z "ageeduc cage ceduc pcigs78 restock"
      ivreg2 lnc `x' (k210=`z')
      ivpois cigpacks `x', endog(k210) exog(`z')

/*-------------------------------------------------------------------------------------------------------------------------------------------------------
An alternative Generalized Linear Model (glm) approach, due to Hardin, Schmiediche, and Carroll (2003), is designed to address endogeneity due to
measurement error. Type findit qvf to install. The following example, loosely based on the qvf help file, favors the GMM approach:
-------------------------------------------------------------------------------------------------------------------------------------------------------*/
      clear all
      set obs 1000
      gen x1 = uniform()
      gen x2 = uniform()
      gen x3 = uniform()
      gen err = invnorm(uniform())
      gen y = exp(1+2*x1+3*x2+4*x3+err)
      gen t3 = .8*x3 + .6*invnorm(uniform())
      qvf y x1 x2 x3 (x1 x2 t3), link(log) fam(poisson)
      est sto qvf
      bs: qvf y x1 x2 x3 (x1 x2 t3), link(log) fam(poisson)
      est sto bsqvf
      ivpois y x1 x2, endog(x3) exog(t3)
      est sto gmm
      bs: ivpois y x1 x2, endog(x3) exog(t3)
      est sto bsgmm
      cap ssc inst estout
      esttab *, nogaps se mti

*Check errors:

      ivpois y x1 x2, endog(x3) exog(x3)
      ivpois y x1 x2, e(x3) o(t3)
      mat b=(1,2,3)
      ivpois y x1 x2 x3, from(b)
      ivpois y x1 x2 x2, from(b)
      mat b=(2,3,4,1)
      ivpois y x1 x2 x2, from(b)
