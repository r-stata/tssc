*! ldtest v1.0 GFBarrett 01Sept2012
program ldtest, rclass
 version 11.0
 syntax varlist(min=2 max=4 numeric) [if] [in] [, breps(integer 10) CVM LCE]
 marksample alluse, novarlist
//marksample touse

// varname string not allowed
 confirm numeric variable `varlist'

 tokenize `varlist'

 quietly count if `alluse'
 if `r(N)' == 0 {
     error 2000
 }

 if `breps' > 0 {
     scalar bootr = `breps'
 }
 else {
     scalar bootr = 10
 }

if "`cvm'" !="" {
  scalar optn = 2
}
else if "`lce'" !=""{
  scalar optn = 3
}
else {
  scalar optn = 1
}


di " "
di "========================================================================"
display c(current_time) " - " c(current_date)
scalar ct0=c(current_time)

mata: st_view(x=., ., ("`1'","`2'"),"`2'")
mata: st_view(y=., ., ("`3'","`4'"),"`4'")
mata: x=select(x,rowmissing(x):==0)
mata: y=select(y,rowmissing(y):==0)
mata: n = rows(x)
mata: m = rows(y)
mata: lam = sqrt(n*m/(n+m))

* // Construct the empirical LC for x and y at each distinct population quantile
* // with the function EmpLor(.)
mata: LCx = emplorenz(x)
mata: LCy = emplorenz(y)

* // Now construct LCs from the empirical LC defined over all empirical population
* //  proportions defined in either sample
mata: gp=uniqrows(LCx[.,1]\LCy[.,1])
mata: gLCx=lorinterpol(gp,LCx)
mata: gLCy=lorinterpol(gp,LCy)

* // Take the difference between the gLCs
mata: LCd= (gLCy-gLCx)

mata: bootreps=st_numscalar("bootr")
mata: testch=st_numscalar("optn")

mata: printf("{hline 72}\n")
mata: printf("BDB(2012) Consistent Nonparametric Test of Lorenz Dominance\nP-values based on bootstrap repetitions = %f\n", bootreps)
mata: printf("{hline 72}\n")


if (optn == 1) {
* // Default is the KS test

mata:  maxdf=max(LCd)
mata:  ks  = lam*maxdf
mata: kspv=ldbootpvalue4(ks, x, y, bootreps, testch)
mata: st_numscalar("testst",ks)
mata: st_numscalar("distance",maxdf)
mata: st_numscalar("pval",kspv)

mata: printf("KS  Test Stat  [p-value] = %9.8f [%6.4f]\n", ks, kspv)
mata: printf("Max LC diff = %6.5f\n", maxdf)

return scalar KS=testst
return scalar pKS=pval
return scalar dKS=distance

}

else if (optn == 2) {

* // PID Test
mata: Ud = lorintegration(gp,LCd)
mata: lcdarea=quadcolsum(Ud)
mata: U = lam*lcdarea
mata: kspv=ldbootpvalue4(U, x, y, bootreps, testch)

mata: st_numscalar("testst",U)
mata: st_numscalar("distance",lcdarea)
mata: st_numscalar("pval",kspv)

mata: printf("CvM  Test Stat  [p-value] = %6.5f [%6.4f]\n", U, kspv)
mata: printf("Integrated PosDiff = %6.5f \n", lcdarea)

return scalar CvM=testst
return scalar pCvM=pval
return scalar dCvM=distance


}

else if (optn == 3) {

* // Test of LC equality
mata: maxabsd=max(abs(LCd))
mata: kslce=lam*maxabsd
mata: kspv=ldbootpvalue4(kslce, x, y, bootreps, testch)

mata: st_numscalar("testst",kslce)
mata: st_numscalar("distance",maxabsd)
mata: st_numscalar("pval",kspv)
mata: printf("LCe Test Stat [p-value] = %6.5f [%6.4f] \n", kslce,kspv)
mata: printf("Max Abs LC Diff = %6.5f \n", maxabsd)

return scalar LCe=testst
return scalar pLCe=pval
return scalar dLCe=distance

}


scalar ct1=c(current_time)
scalar rntmd=clock(ct1,"hms")-clock(ct0,"hms")
di "Run time = "  seconds(rntmd), "seconds"

di "========================================================================"

end

