
*! This version 1.1 (2006-10-16, 2006-12-1,2007-5-18,  Zhuo (Adam) Chen)
* 2007-5-18, fixed the case for the weighted individual cases
* This file is -concindc.ado- by Zhuo (Adam) Chen
* The procedure is to calculate concentration (CI) with grouped data approach

* Compared to the other two available procedures -concindexi.ado-
*                                                -concindexg.ado- :
*
* (1) -concindexi.ado- calculates  CI with assumed continous welfare variable;
* (2) -concindexg.ado- computes grouped dataset, note that grouped dataset could be
*         special case that can be computed using this procedure.
*
* concindc can handle 
*   1. micro data with categorical welfare variable-- original purpose: they are essentially grouped data, 
*         see a companion paper by Chen & Roy (2006)
*   2. grouped data -- input the group size as frequency weight and also accept standard error of group means if provided
*   3. micro data with actual welfare variable -- one is a minuscule group, isn't it?
* 
* Enjoy and please send me (chenzhuo@gmail.com) an email if any bugs has bugged you.
* Please note that this is a user written program. No warranties are given.
* see http://siteresources.worldbank.org/INTPAH/Resources/Publications/Quantitative-Techniques/concentration_index.xls
* for a validation procedure

program define concindc, rclass

	version 6.0

	local varlist "req ex max(1)"
	local if "opt"
	local in "opt"
	local options "Welfarevar(string) Sigmavar(string) "
	local weight "aweight fweight"

	parse "`*'"
	parse "`varlist'", parse (" ")


	local nfac : word count `varlist'
	tempvar wt touse  cumwy cumw maxw pvar maxww totalwt sumww cumw1 /*
         */ sumyw maxyw miut tvar tvar2 tvar3 tvar4 tvar5 fft stdt att var11 var12 nt tvar6
         
	
      qui preserve
      qui drop if `welfarevar'==.
 
      quietly {
	      if "`weight'" == "" {qui ge `wt' = 1}
     	      else {qui ge `wt' `exp'}

      	mark `touse' `if' `in'
	      markout `touse' `varlist' 
		gsort - `touse' + `welfarevar' 

            gen double `cumwy' = sum(`wt'*`varlist')  if `touse'
		gen double `cumw' = sum(`wt') if `touse'
            sum `cumw' if `touse'
		gen double `totalwt' = r(max) if `touse'
            egen  `maxww'=max(`cumw') if `touse', by(`welfarevar')  /* category max weight */
            egen  `sumww'=total(`wt') if `touse', by(`welfarevar')
		gen double `pvar' = (`maxww'-`sumww'/2 )/`totalwt' if `touse'  /* fractional rank */

            gen double `fft'= `sumww'/`totalwt' if `touse'    /*population share */

            egen  `sumyw'=total(`wt'*`varlist') if `touse', by(`welfarevar')
            egen  `maxyw'=max(`cumwy') if `touse', by(`welfarevar') /*  */
            gen  `miut'=`sumyw'/`sumww' if `touse'    /* group mean */
       
		/* Calculate std of group mean */
 	      if "`sigmavar'" == "" {
                  egen  `tvar6' = total(`wt'*(`varlist'-`miut')^2) if `touse', by(`welfarevar')
			gen `stdt' =sqrt(`tvar6'/`sumww') if `touse'
                                 }
      	else {gen `stdt'=`sigmavar' if `touse'}
	      replace `stdt'=0 if `stdt' ==. & `touse'  /* without std within welfare category*/


            sum `cumwy'  if `touse'
            local toty=r(max) /*overall health */
            local nnn=r(N)
            sum `wt' if `touse'
            local totw=r(sum)
            local meany=`toty'/`totw' /* overall mean */

            gen `tvar'= `pvar'*`miut'/`totw'*`wt'
            sum `tvar' if `touse'
            local cic=(2*r(sum)/`meany'-1)   /* concentration index */

            egen `nt' = count(`fft') if `touse', by(`welfarevar')
            egen `tvar2' = total(`miut'*`fft'/(`nt')^2) if `touse', by(`welfarevar')

            gen `tvar3' = sum(`tvar2'/`meany') if `touse'
            egen `tvar4' = max(`tvar3') if `touse', by(`welfarevar') /* qt */

            egen `tvar5' = min(`tvar3') if `touse', by(`welfarevar')

            replace `tvar5'= `tvar5'-`tvar2'/`meany'  if `touse' /*q(t-1) */
            replace `tvar5'=0 if `tvar5'<1e-07 & `touse'
            gen `att'=`miut'*(2*`pvar'-1-`cic')/`meany' + 2 - `tvar5' - `tvar4'
		sum `stdt'

	      if "`sigmavar'" != "" & r(sum)>1.e-6  { local nnn= `totw'} /* without std within welfare category */

            gen `var11'=`fft'*(`att')^2/`nnn'/`nt'  /* dividing `nt' because summing over individuals */
            sum `var11' if `touse'
            local vara=r(sum) -((1+`cic')^2)/`nnn'
            gen `var12'=`fft'*(`stdt'^2)*(2*`pvar'-1-`cic')^2/`nt'/`nnn'/((`meany')^2)  if `touse'
            sum `var12'  if `touse'
            local varc=sqrt(`vara'+r(sum))
            noi: display in g "Concentration Index (CI) using grouped approach"
            noi: display in g "as in Kakwani, Wagstaff & van Doorslaer (1997)" 
            noi: display in g "  Concentration Index        " in y %9.8f  `cic' 
            noi: display in g "  Std. Error of CI           " in y %9.8f  `varc' 
          restore
          return scalar concindex = `cic'
          return scalar stdci =`varc'
       
}
end

