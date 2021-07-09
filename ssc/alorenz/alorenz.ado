*! version 3.2.1       <20200406>       JPAzevedo
*    	update _ebin to version 1.0
* version 3.2         <20200405>        JPAzevedo
*    	fix parameters from which_version
*    	dependencies check runs quietly
* version 3.1         <20200404>        JPAzevedo
*    	check for dependencies 
*    	install groupfunction on the fly (when needed)
* version 3.0         <20200404>        JPAzevedo
*    	replace collapse by groupfunction
*    	support [aw]
*    	support return add
* version 2.3          <20140702>       JPAzevedo
*		fix replace _pecatsal in ebin
* version 2.2          <20120328>       JPAzevedo
* 		test ksmirnof
* 		use _ebin (equal bins)
* version 2.0          <20001212>       JPAzevedo & SFranco
* version 1.0          <20060724>       JPAzevedo & SFranco
/*
gl xtitle("Proportion of `varlist'")
gp xtitle("Average accumulated `varlist'")
ge xtitle("Average accumulated `varlist'")
*/

program define alorenz   , rclass

    version 8.0

    syntax varlist(min=1 max=1 numeric)             ///
                [in] [if]                           ///
                [pweight fweight aweight]           ///
                [ , 								///
					Points(real 10)                 ///
					by(varname)                     ///
					format(string)                  ///
					output(string)                  ///
					view                            ///
					fullview                        ///
					angle45                         ///
					gl                              ///
					gp                              ///
					ge                              ///
					gom                             ///
					goa                             ///
					compare                         ///
					base(real -99)                  ///
					invert                          ///
					results(string)                 ///
					grname(string)                  ///
					order(varname)                  ///
					select(string)                  ///
					mlabangle(string)               ///
					mlabsize(string)                ///
					mark(string)                    ///
					marklabel(string)               ///
					markvar(varname)                ///
					XDECrease                       ///
					trimif(string)                  ///
					ksmirnov                        ///
					exact                           ///
					NOIsily                         ///
					*                               ///
                ]
    
  *-----------------------------------------------------------------------------
  * Download and install required user written ado's
  *-----------------------------------------------------------------------------
  * Fill this list will all user-written commands this project requires
	  local user_commands groupfunction which_version

  * Loop over all the commands to test if they are already installed, if not, then install
	  qui foreach command of local user_commands {
		cap which `command'
		if _rc == 111 { 
			ssc install `command'
		}
		else {
			which_version groupfunction 
			if  (`s(version)' < 2.0) {
				ado update groupfunction , update
			}
		}
	  }
					
				
    /** flow control */

    if (("`gom'" != "") | ("`goa'" != "")) & ("`order'" == "") {
        di as err "option order is required to be specificied jointly with gom or goa."
        exit 198
    }

    if ("`ksmirnov'" != "") & ("`by'"=="") {
        di as err "by() option is required in order to run ksmirnov test."
        exit 198
    }

    if ("`compare'" != "") & ("`by'"=="") {
        di as err "by() option is required in order to compare distributions."
        exit 198
    }

    if ("`by'"!="") & (("`mark'" != "") | ("`select'" != "") | ("`markvar'" != "")) {
        di as err "by() option is not supported jointly with markvar and mark and select"
        exit 198
    }

    if (("`gl'"!="")) & (("`select'" != "") | ("`markvar'" != "")) {
        di as err "the gl option is not supported with markvar and select"
        exit 198
    }

    if ("`mark'" != "") {
        loc v = wordcount("`mark'")
        loc n = wordcount("`marklabel'")
        if (`v' != `n') {
            di as err "if the option marklabel is selected, the number of values and labels have to be the same."
            exit 198
        }
        if ("`select'" != "") {
            di as err "if the option mark is enabled the option select can not be active."
            exit 198
        }
    }

    /** begin */
	
	tempvar acumprop pesotot weight2 touse varpoint rmean

    tempname valnum rcount temp matrix at bt ct

    mark `touse' `if' `in'

    quietly {

		if ("`by'" != "") {

			_pecatsal `by' if `touse'                 /* JP Azevedo 15 sept 2005 */
			local nrows = r(numcats)
			local c = r(catvals)
			local labcat = r(catnms8)

			if (`nrows'<2) {
				di as err "by() needs two or more valid categories"
				exit 198
			}

			if ("`compare'" != "") & (`base' != -99) {         /* JP Azevedo 19 sept 2005 */
				local find = index("`c'","`base'")
				if (`find'==0) {
					di as err "base category must be within the values of by()"
					exit 198
				}
			}
		}

		if ("`by'"=="") {
			tempvar temp
			tempvar lab
			gen `temp'=1  if `touse'
			label define `lab' 1 "Total"
			label values `temp' `lab'
			local by `temp'
			local c=1
		}

		if ("`format'"=="") {
			local format "%12.2f"
		}

		if "`weight'" == "" {
			qui gen byte `weight2' = 1  if `touse'
		}
		else {
			qui gen `weight2' `exp'  if `touse'
		}

		****************************
		* Select                  *
		***************************

		if ("`select'" != "") {

			tknz "`select'" , parse("|") s(v) nochar

			forvalues sel = 1(1)`s(items)' {
				loc varsel = word("`v`sel''",1)
				loc criter = word("`v`sel''",2)
				loc valsel = word("`v`sel''",3)
				loc k = 1
				foreach i of numlist `c' {
					sum `varlist' if `varsel' `criter' "`valsel'" & `touse' & `by' == `i'
					if (`r(N)' > 0) {
						loc mark`k'_`sel' = `r(mean)'
						loc mark`k' "`mark`k'' `mark`k'_`sel''"
						loc labelsel`k'_`sel'  "`valsel'"
						loc labelsel`k'   "`labelsel`k'' `valsel'"
						loc k = `k'+1
					}
				}
			}
			
			if ("`select'" != "") & (`r(N)'==0) {
				di	""
				di as err "select option error: value `valsel' not available in variable `varsel'." 
				exit 198
			}
		}

		****************************
		* mark                  *
		***************************

		if ("`select'" == "") & ("`mark'" != "") {
				loc k = 1
				loc mark`k'         "`mark'"
				loc labelsel`k'     "`marklabel'"
				loc select "1"
		}

		****************************
		* markvar                  *  /* JPA 20081115 */
		***************************

		if ("`select'" == "") & ("`mark'" == "") & ("`markvar'" != "")  {

				_pecatsal `markvar' if `touse'
				loc select = r(numcats)
				loc strcat = r(catnms8)
				loc labelsel1 "`r(catnms8)'"
				loc k = 1
				foreach n in `r(catvals)' {
					sum `varlist' if `markvar' == `n' & `touse'
					loc mark1 "`mark1' `r(mean)'"
					loc k = `k'+1
				}
				loc tt1 = wordcount("`mark1'")
				loc tt2 = wordcount("`labelsel1'")
				di `tt1'
				di `tt2'
		}
		

************************************************
**** looping que genera la curva de lorenz y los respectivos datos para cada grupo de comparacion
************************************************

   local tempall ""

   foreach i of numlist `c' {

        local temp ", temp`i'"

        local tmptmp "`tmptmp' `temp'"

        preserve

			keep if `by'==`i' & `touse'==1 & `varlist' !=. & `weight2' != .

			sort `varlist'

			local name : label (`by') `i'

			****************************
			* generando los percentis  *
			***************************

			sum `varlist'
			if (`r(N)' < `points') {
				loc points = `r(N)'+1
				di as err "the value for points() automatically adjusted to be equal to the number of observations plus one (points=`points')"
			}

			if ("`order'" == "") {
				*xtile `acumprop'=`varlist' , nquantiles(`points')
				_ebin `varlist' [`weight' `exp']  if `touse', nquantile(`points') gen(`acumprop')
				loc xtitle1 "Cumulative proportion of sample"
				loc xtitle2 "Sample proportion"
			}

			if ("`order'" != "") {
				*xtile `acumprop'=`order' [`weight' `exp']  if `touse', nquantiles(`points')
				_ebin `varlist' [`weight' `exp']  if `touse', nquantile(`points') gen(`acumprop') order(`order')
				loc xtitle1 "Cumulative proportion population sorted by `order'"
				loc xtitle2 "`order' proportion"
				gen max`order' = `order'     if `touse'
			}

	*        noisily tab `acumprop'

			gen peso`varlist'=`weight2'  if `touse'
			gen max`varlist'=`varlist'   if `touse'

			****************************************************************
			* generando a renda media para comparacao entre distribuicoes  *
			****************************************************************

			if "`weight'" == "pweight"{
				qui svyset [`weight' `exp']
				qui svymean `varlist'  if `touse'
				gen `rmean'=r(b)
			}
			if "`weight'" == "fweight" | "`weight'" == "aweight"{
				qui sum `varlist' [`weight' `exp']  if `touse'
				gen `rmean'=r(mean)
			}
			if "`weight'" == "" {
				qui sum `varlist'  if `touse'
				gen `rmean'=r(mean)
			}

        if ("`order'" != "") {
            groupfunction if `touse' [`weight' `exp'] , sum(`varlist') rawsum(peso`varlist') max( max`varlist') mean( `rmean' `order') max(max`order') by(`acumprop')
        }
        else {
            groupfunction if `touse' [`weight' `exp'] , sum(`varlist') rawsum(peso`varlist') max(max`varlist') mean(`rmean') by(`acumprop')
        }
        *******************************************
        * obtenendo los resultados por percentil  *
        *******************************************

			tempvar totvar totpeso
			rename `acumprop' x`varlist'`i'                                             	   /*percentil*/
			rename `varlist' s`varlist'                                                 	   /*`var'total por percentil*/
			rename peso`varlist' speso                                                  	   /*peso total do percentil*/
			rename `rmean' rmean                                                        	   /*`var  media da populacao*/
			if ("`order'" != "") {                                                              /* JPA 20120325 */
				rename `order' mean_`order'                                                     /** valor medio da variavel `order' */
			}
			gen ac_s`varlist' = s`varlist'
			replace ac_s`varlist' = ac_s`varlist'[_n] + ac_s`varlist'[_n-1] in 2/l      	   /*var acumulado*/

			gen ac_speso = speso
			replace ac_speso = ac_speso[_n] + ac_speso[_n-1] in 2/l                     	   /*peso acumulado*/

			gen mean_`varlist' = s`varlist' / speso                                       	   /*var pormedio del percentil*/
		
			gen ac_mean_`varlist' = ac_s`varlist'/ ac_speso                               	   /*var pormedio de los pobres*/

			qui sum speso
			gen prop_pop = speso/ r(sum) * 100                                            	   /*porcentage de la poblacion*/
			gen `totpeso'=r(sum)

			gen ac_prop_pop = prop_pop
			replace ac_prop_pop = ac_prop_pop[_n] + ac_prop_pop[_n-1] in 2/l            	   /*porcentage acumulada de la poblacion*/

			qui sum s`varlist'
			gen prop_`varlist' = s`varlist'/ r(sum) * 100                                 	   /*porcentage del var total*/
			gen `totvar'=r(sum)

			gen ac_prop_`varlist' = prop_`varlist'
			replace ac_prop_`varlist' = ac_prop_`varlist'[_n] + ac_prop_`varlist'[_n-1] in 2/l  /*porcentage acumulada del var total*/

			gen `varpoint' = x`varlist'`i'*(100/`points')
			local points2=`points'+1
			set obs `points2'
			replace `varpoint'=0 in `points2'

			if ("`order'" != "") {                                                              /* JPA 20120325 */
				tempname tmp1 ac_tmp1
				gen `tmp1'      = mean_`order'*speso
				gen `ac_tmp1'   = `tmp1' in 1
				replace `ac_tmp1' = `tmp1'[_n]+`ac_tmp1'[_n-1] in 2/l
				gen ac_mean_`order' = `ac_tmp1'/ac_speso
			}

			foreach var2 of varlist x`varlist'`i' - ac_prop_`varlist'{
				replace `var2'=. in `points2'
			}

			if ("`xdecrease'"!="") {            /* JPA 26/05/2008 */
				sum x`varlist'`i'
				gen  inv_x`varlist'`i' = 1+abs(x`varlist'`i'-`r(max)')
				loc  l "`inv_x`varlist'`i'' "
			}

			************************************
			* generando los respectivos datos  *
			************************************

			if  ("`nrows'" != "") {
				gen `by' = `i'
				local bycols  "+1"                                            /* JPA 20120325 */
				local bylist ", `by'"
				local bymat  "  `by'"
			}

			if ("`order'" != "") {                                                  /* JPA 20120325 */
				local orderlist ", mean_`order', max`order', ac_mean_`order'"
				local ordermat  " mean_`order'  max`order' ac_mean_`order'"
				if ("`fullview'" != "") {
					local colsmax = 13
				}
				if ("`view'" != "") {
					local colsmax = 8
				}
			}
			else {
				if ("`fullview'" != "") {
					local colsmax = 10
				}
				if ("`view'" != "") {
					local colsmax = 5
				}
			}

			if ("`results'" == "" ) & ("`xdecrease'"=="") {
				if ("`fullview'" != "") {
					local matfullview     "max`varlist', mean_`varlist', ac_mean_`varlist', speso, ac_speso, prop_pop, ac_prop_pop, prop_`varlist', ac_prop_`varlist'  `orderlist'  `bylist'"
					local cols = `colsmax' `bycols'
				}
				if ("`view'" != "") {
					local matview         "ac_prop_`varlist',  max`varlist', ac_prop_pop, ac_mean_`varlist'  `orderlist'  `bylist'"
					local cols = `colsmax' `bycols'
				}
			}

			if ("`results'" == "" ) & ("`xdecrease'"!="") {
				if ("`fullview'" != "") {
					local matfullview     "inv_x`varlist'`i', max`varlist', mean_`varlist', ac_mean_`varlist', speso, ac_speso, prop_pop, ac_prop_pop, prop_`varlist', ac_prop_`varlist'  `orderlist' `bylist'"
					local cols = `colsmax'+1 `bycols'
				}
				if ("`view'" != "") {
					local matview         "inv_x`varlist'`i', ac_prop_`varlist',  max`varlist', ac_prop_pop, ac_mean_`varlist'  `orderlist' `bylist'"
					local cols = `colsmax' `bycols'
				}
			}


			if ("`results'" != "" ) {
				local count = wordcount("`results'")
				if ("`fullview'" != "") {
					local matfullview   "`results'"
					local cols = 1+`count'
				}
				if ("`view'" != "") {
					local matview       "`results'"
					local cols = 1+`count'
				}
			}

		/* JPA  20081115 */

			if ("`fullview'" != "")  & ("`xdecrease'"=="") {

				tempname `varlist'_`c' mat1
				replace max`varlist'=. if x`varlist'`i'==`points'
				mkmat x`varlist'`i' max`varlist' mean_`varlist' ac_mean_`varlist' speso ac_speso prop_pop ac_prop_pop prop_`varlist' ac_prop_`varlist' `ordermat' `bymat'
				mat ``varlist'_`c'' = x`varlist'`i', `matfullview'
				mat `mat1' = ``varlist'_`c''[1..`points',1..`cols']
				return matrix lorenz`i' = `mat1'
			}

			if ("`view'" != "")  & ("`xdecrease'"=="") {

				tempname `varlist'_`c' mat1
				replace max`varlist'=. if x`varlist'`i'==`points'
				mkmat x`varlist'`i' ac_prop_`varlist' max`varlist' ac_prop_pop ac_mean_`varlist'  `ordermat' `bymat'
				mat ``varlist'_`c'' = x`varlist'`i',  `matview'
				mat `mat1' = ``varlist'_`c''[1..`points',1..`cols']
				return matrix lorenz`i' = `mat1'
			}

		/* JPA  20081115 */

			if ("`fullview'" != "")  & ("`xdecrease'"!="") {

				tempname `varlist'_`c' mat1
				replace max`varlist'=. if x`varlist'`i'==`points'
				mkmat x`varlist'`i' inv_x`varlist'`i'   max`varlist' mean_`varlist' ac_mean_`varlist' speso ac_speso prop_pop ac_prop_pop prop_`varlist' ac_prop_`varlist'  `ordermat' `bymat'
				mat ``varlist'_`c'' = x`varlist'`i', `matfullview'
				mat `mat1' = ``varlist'_`c''[1..`points',1..`cols']
				return matrix lorenz`i' = `mat1'
			}

			if ("`view'" != "")  & ("`xdecrease'"!="") {

				tempname `varlist'_`c' mat1
				replace max`varlist'=. if x`varlist'`i'==`points'
				mkmat x`varlist'`i' inv_x`varlist'`i'  ac_prop_`varlist' max`varlist' ac_prop_pop ac_mean_`varlist'  `ordermat'  `bymat'
				mat ``varlist'_`c'' = x`varlist'`i',  `matview'
				mat `mat1' = ``varlist'_`c''[1..`points',1..`cols']
				return matrix lorenz`i' = `mat1'
			}

			if ("`output'" != "") {
				outsheet x`varlist'`i' max`varlist' mean_`varlist' ac_mean_`varlist' speso ac_speso prop_pop ac_prop_pop prop_`varlist' ac_prop_`varlist'  `ordermat' `bymat'  using `output'_`name'.csv, comma replace
				noisily di in r "file saved"
			}

			if ("`compare'" != "") {
				tempname `varlist'_`i' mat1
				mkmat  x`varlist'`i' rmean mean_`varlist' ac_mean_`varlist' ac_prop_`varlist'  `ordermat'  `bymat'
				mat ``varlist'_`i'' = x`varlist'`i', rmean, mean_`varlist', ac_mean_`varlist', ac_prop_`varlist' `orderlist'  `bylist'
				mat colnames ``varlist'_`i'' = percent`i' t_`i' x_`i' s_`i' l_`i'
				mat mat`i' = ``varlist'_`i''[1..`points',1..5]
			}

			tempname `varlist'_`c'
			replace max`varlist'=. if x`varlist'`i'==`points'
			mkmat  `varpoint'  ac_prop_`varlist' max`varlist' ac_prop_pop ac_mean_`varlist' mean_`varlist' `ordermat' `bymat'
			mat ``varlist'_`c'' = `varpoint',  ac_prop_`varlist',  max`varlist', ac_prop_pop, ac_mean_`varlist', mean_`varlist'  `orderlist'  `bylist'
			mat colnames ``varlist'_`c'' = `varpoint'`i'  ac_prop_`varlist'`i' max`varlist'`i' ac_prop_pop`i' ac_mean_`varlist'`i' mean_`varlist'  `ordermat' `bymat'
			mat temp`i' = ``varlist'_`c''
			matrix ``varlist'_`c'' = ``varlist'_`c''[1..`points',1..6]
			if ("`fullview'" == "") & ("`view'" == "") {
				return matrix lorenz`i' = ``varlist'_`c''
			}

			if ("`results'" == "" ) {
				if ("`fullview'" != "") {
					local fullviewvarname "max`varlist' mean_`varlist' ac_mean_`varlist' speso ac_speso prop_pop ac_prop_pop prop_`varlist' ac_prop_`varlist'  `ordermat' `bymat'"
				}
				if ("`view'" != "") {
					local viewvarname "ac_prop_`varlist' max`varlist' ac_prop_pop ac_mean_`varlist' `ordermat' `bymat' "
				}
			}

			if ("`results'" != "" ) {
				local results2 = subinstr("`results'",","," ",.)
				if ("`fullview'" != "") {
					local fullviewvarname "`results2'"
				}
				if ("`view'" != "") {
					local fullviewvarname "`results2'"
				}
			}

			if ("`fullview'" != "") {
			   local k = 1
				foreach var of varlist `fullviewvarname' {
					rename `var' ds`k'
					label define _j `k' `var', modify
					local k = `k'+1
				}
				rename x`varlist'`i' percentile
				keep if percentile != .
				reshape long ds , i(percentile)
				label values _j _j
				label var _j "Result:  `name'"
				noisily di
				noisily di in y "Result:  `name'"
				noi tabdisp percentile _j, c(ds) format(`format')
			}

			if ("`view'" != "") {
			   local k = 1
				foreach var of varlist `viewvarname'  {
					rename `var' ds`k'
					label define _j `k' `var', modify
					local k = `k'+1
				}
				rename x`varlist'`i' percentile
				keep if percentile != .
				reshape long ds , i(percentile)
				label values _j _j
				label var _j "Result:  `name'"
				noisily di
				noisily di in y "Result:  `name'"
				noi tabdisp percentile _j, c(ds) format(`format')
			}

        restore
   }

    preserve

    **********************************************
    * generando las figuras Lorenz e Pen's Parade  *
    **********************************************

    if ("`gl'" != "" | "`gp'" != "" | "`ge'" != "" | "`gom'" != "" | "`goa'" != "") {

        local temp = substr("`tmptmp'", 3, .)
        mat `matrix' = `temp'
        svmat double `matrix' , name(bvector)
        local colsof=colsof(`matrix')
        return mat a = `matrix'

        _pecatsal `by' if `touse'                                                                 /* JPA incluir if touse  28/07/2005*/
        local catvals = r(catvals)
        local catnms8 = r(catnms8)
        local wordcount = wordcount("`catvals'")
        local seqorder ""
        forvalues t = 1(1)`wordcount' {
            local word1 = word("`catvals'",`t')
            local temp1 : label (`by') `word1'                                                  /* JPA include full name 15/09/2005 and fix JPA 20070330*/
            local label`t' "`temp1'"
            local temp3 "`t'"
            local seqorder "`seqorder' `temp3'"
         }

        loc start = 1

        if ("`order'" != "") & ("`nrows'" != "") {                                           /* JPA 20120325 */
            local skip = 10
        }
        if ("`order'" != "") & ("`nrows'" == "") {                                           /* JPA 20120325 */
            local skip = 9
        }
        if ("`order'" == "") & ("`nrows'" != "") {                                           /* JPA 20120325 */
            local skip = 7
        }
        if ("`order'" == "") & ("`nrows'" == "") {                                          /* JPA 20120325 */
            local skip = 6
        }

        ***************************
        * ksmirnov                * /* JPA 26/03/2012 */
        ***************************

        if ("`ksmirnov'" != "") {

            local kn = 1

            forvalues s = `start'(`skip')`colsof' {

                local knn = word("`c'",`kn')

                tempvar k`s'

                gen `k`s'' = `knn'

                local tmp1 = `s'
                local tmp2 = `s'+1
                local tmp3 = `s'+2
                local tmp4 = `s'+3
                local tmp5 = `s'+4

                if ("`gl'"!= ""){
                    tempname gl_mat`knn'
                    mkmat `k`s'' bvector`tmp2' if bvector`tmp2' != ., matrix( `gl_mat`knn'')
                    local ggl gl
                }
                if ("`gp'" != ""){
                    tempname gp_mat`knn'
                    mkmat `k`s'' bvector`tmp3' if bvector`tmp3' != . , matrix( `gp_mat`knn'')
*                    mkmat `k`s'' bvector`tmp3' if bvector`tmp3' != . & bvector`tmp1' <= 99, matrix( `gp_mat`knn'')
                    local ggp gp
                }
                if ("`ge'" != ""){
                    tempname ge_mat`knn'
                    mkmat `k`s'' bvector`tmp5' if bvector`tmp5' != ., matrix( `ge_mat`knn'')
                    local gge ge
                }

                local kn = `kn'+1

              }

              foreach type in `ggl' `ggp' `gge' {
                 tempname ks_`type'
                 foreach knn in `c' {
                        mat `ks_`type'' = nullmat(`ks_`type'') \ ``type'_mat`knn''
                        matrix colnames `ks_`type'' = `by'  `type'_y
                    }

                 svmat double `ks_`type'', names(ks`type')

                 `noisily' di ""
                 `noisily' di in y "`type'"
                 `noisily' ksmirnov ks`type'2 , by(ks`type'1) `exact'

                 if ("`exact'" == "") {
                     loc kspval = round(`r(p_cor)',.0001)
                 }
                 else {
                     loc kspval = round(`r(p_exact)',.0001)
                }
                 local figks`type' "caption(Note: Two-sample Kolmogorov-Smirnov test for equality of distribution functions: p-val `kspval', size(*.7) )"

                 return local ks_`type'_D  = `r(D)'
                 if ("`exact'" == "") {
                     return local ks_`type'_p_cor  = `r(p_cor)'
                 }
                 else {
                     return local ks_`type'_p_exact  = `r(p_exact)'
                 }
                 return local ks_`type'_p  = `r(p)'
                 return matrix ks_`type' = `ks_`type''
                }
        }

       ***************************
       * Figures                 *
       ***************************

        forvalues s = `start'(`skip')`colsof' {

            local tmp1 = `s'
            local tmp2 = `s'+1
            local tmp3 = `s'+2
            local tmp4 = `s'+3
            local tmp5 = `s'+4
            local tmp6 = `s'+5
            local tmp7 = `s'+6
            local tmp8 = `s'+7
            local tmp9 = `s'+8

            foreach i in 1 4 {
                if ("`xdecrease'"!="") {            /* JPA 26/05/2008 */
                   	sum bvector`tmp`i''
                 	replace bvector`tmp`i'' = 1+abs(bvector`tmp`i''-`r(max)')
                }
            }

            if ("`invert'"=="") {                                                                                                   /* JPA 15/09/2005 */
                local gl`s' "(line bvector`tmp2' bvector`tmp1')"
                local gp`s' "(line bvector`tmp3' bvector`tmp4' )"
*                local gp`s' "(line bvector`tmp3' bvector`tmp4' if bvector`tmp1' <= 99)"
                local ge`s' "(line bvector`tmp5' bvector`tmp4')"
                local gom`s' "(line bvector`tmp6' bvector`tmp7' )"
                local goa`s' "(line bvector`tmp5' bvector`tmp9')"
            }

            if ("`invert'"!="") {                                                                                                   /* JPA 15/09/2005 */
                local gl`s' "(line bvector`tmp1' bvector`tmp2')"
                local gp`s' "(line bvector`tmp4' bvector`tmp3' )"
*                local gp`s' "(line bvector`tmp4' bvector`tmp3' if bvector`tmp1' <= 99)"
                local ge`s' "(line bvector`tmp4' bvector`tmp5')"
                local gom`s' "(line bvector`tmp7' bvector`tmp6' )"
                local goa`s' "(line bvector`tmp9' bvector`tmp5')"
            }

            loc gl_f "`gl_f' `gl`s''"
            loc gp_f "`gp_f' `gp`s''"
            loc ge_f "`ge_f' `ge`s''"
            loc gom_f "`gom_f' `gom`s''"
            loc goa_f "`goa_f' `goa`s''"

        }

        if ("`select'" != "") {

            loc k = 1
            loc p = 1
            loc sel = 1

            forvalues s = 1(`skip')`colsof' {

                local tmp1 = `s'
                local tmp2 = `s'+1
                local tmp3 = `s'+2
                local tmp4 = `s'+3
                local tmp5 = `s'+4

                tempvar sel_l`s'  sel_p`s' sel_e`s' tmp_l`s' tmp_p`s' tmp_e`s' selname_p`s' selname_l`s' selname_e`s' per_p`s' per_l`s' per_e`s'

                _matchval bvector`tmp2'  if `touse' , nnval(`mark`k'') gen(`sel_l`s'') ///
                        nnlab(`labelsel`k'') genlab(`selname_l`s'') ///
                        return(bvector`tmp4') rvar(`per_l`s'')
                _matchval bvector`tmp3'  if `touse' , nnval(`mark`k'') gen(`sel_p`s'') ///
                        nnlab(`labelsel`k'') genlab(`selname_p`s'') ///
                        return(bvector`tmp4') rvar(`per_p`s'')
                _matchval bvector`tmp2'  if `touse' , nnval(`mark`k'') gen(`sel_e`s'') ///
                        nnlab(`labelsel`k'') genlab(`selname_e`s'') ///
                        return(bvector`tmp4') rvar(`per_e`s'')

                local zzz = 1

               quietly foreach st in `mark`k'' {

                    if ("`gp'" != ""){
                        sort `sel_p`s'' `per_p`s''
                        tempvar tmpp`zzz'
                        gen double `tmpp`zzz'' = round(abs(`sel_p`s''-`st')) if `touse'
                        sort `tmpp`zzz''
                        local per = `per_p`s'' in 1
                        mat `bt' = nullmat(`bt') \ `st' , `per'
                    }

                    if ("`ge'" != ""){
                        sort `sel_e`s'' `per_e`s''
                        tempvar tmpe`zzz'
                        gen double `tmpe`zzz'' = round(abs(`sel_e`s''-`st')) if `touse'
                        sort `tmpe`zzz''
                        local per = `per_e`s'' in 1
                        mat `ct' = nullmat(`ct') \ `st' , `per'
                    }

                    local zzz = 1+`zzz'
                }

                if ("`gl'"!= ""){
                    return matrix select`k'_gl = `at'
                }
                if ("`gp'" != ""){
                    return matrix select`k'_gp = `bt'
                }
                if ("`ge'" != ""){
                    return matrix select`k'_gp = `ct'
                }

                sort bvector`tmp4'

               if ("`invert'"=="") {                                                                                                   /* JPA 15/05/2008*/
                    local sel_l`s' "(scatter `sel_l`s'' bvector`tmp1', mlabel(`selname_l`s'') mcolor(black) mlabangle(`mlabangle') mlabsize(`mlabsize'))"
                    local sel_p`s' "(scatter `sel_p`s'' bvector`tmp4', mlabel(`selname_p`s'') mcolor(black) mlabangle(`mlabangle') mlabsize(`mlabsize'))"
                    local sel_e`s' "(scatter `sel_e`s'' bvector`tmp4', mlabel(`selname_e`s'') mcolor(black) mlabangle(`mlabangle') mlabsize(`mlabsize'))"
                }

                if ("`invert'"!="") {                                                                                                   /* JPA 15/05/2008 */
                    local sel_l`s' "(scatter bvector`tmp1'  `sel_l`s'', mlabel(`selname_l`s'') mcolor(black) mlabangle(`mlabangle') mlabsize(`mlabsize'))"
                    local sel_p`s' "(scatter bvector`tmp4'  `sel_p`s'', mlabel(`selname_p`s'') mcolor(black) mlabangle(`mlabangle') mlabsize(`mlabsize'))"
                    local sel_e`s' "(scatter bvector`tmp4'  `sel_e`s'', mlabel(`selname_e`s'') mcolor(black) mlabangle(`mlabangle') mlabsize(`mlabsize'))"
                }


                loc sel_l "`sel_l' `sel_l`s''"
                loc sel_p "`sel_p' `sel_p`s''"
                loc sel_e "`sel_e' `sel_e`s''"


                loc k = `k'+1
            }

        }

        if ("`angle45'" != "") {
            local angle "(line  bvector`tmp1'  bvector`tmp1')"
        }

        if ("`invert'"=="") {                                                                                                   /* JPA 15/09/2005 */

            if ("`gl'" != "") {
                graph twoway `gl_f' `angle' `sel_l' `trimif' , ///                   /* JPA 15/09/2005 */
                    name(temp1`grname', replace) title("Loren's Curve") ytitle("Proportion of `varlist'") ///
                    xtitle("`xtitle1'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'") label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'") order(`seqorder')) `options'  `figksgl'  /* Lorenz */
            }
            if ("`gp'" != "") {
                graph twoway  `gp_f' `sel_p'  `trimif' , ///                          /* JPA 15/09/2005 */
                    name(temp2`grname', replace) title("Pen's Parade") ytitle("`varlist'") ///
                    xtitle("`xtitle2'") legend(label(1 "`label1'") label(2 "`label2'") label(3 "`label3'") ///
                    label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") label(8 "`label8'") ///
                    label(9 "`label9'") label(10 "`label10'")) `options'  `figksgp'  /*Pen's Parade */
            }
            if ("`ge'" != "") {
                graph twoway `ge_f' `sel_e' `trimif' , ///                           /* JPA 15/09/2005 */
                    name(temp3`grname', replace) title("Generalized Loren's Curve") ytitle("Average accumulated `varlist'") ///
                    xtitle("`xtitle1'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'")) `options' `figksge' /* General Lorenz */
            }
            if ("`gom'" != "") {
                graph twoway `gom_f' `sel_om' `trimif' , ///                           /* JPA 25/03/2012 */
                    name(temp4`grname', replace) title("") ytitle("Mean `varlist'") ///
                    xtitle("Mean `order'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'")) `options' `figksge' /* Mean values by order variable  */
            }
            if ("`goa'" != "") {
                graph twoway `goa_f' `sel_oa' `trimif' , ///                           /* JPA 25/03/2012 */
                    name(temp5`grname', replace) title("") ytitle("Average accumulated `varlist'") ///
                    xtitle("Average accumulated `order'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'")) `options' `figksge' /* Accumulated mean values by ordered variable  */
            }

        }


        if ("`invert'"!="") {                                                                                                   /* JPA 15/09/2005 */

            if ("`gl'" != "") {
                graph twoway `gl_f' `angle' `sel_l' `trimif' , ///                   /* JPA 15/09/2005 */
                    name(temp1`grname', replace) title("Loren's Curve") xtitle("Proportion of `varlist'") ///
                    ytitle("`xtitle1'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'") label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'") order(`seqorder'))   `options' `figksgl'  /* Lorenz */
            }
            if ("`gp'" != "") {
                graph twoway  `gp_f' `sel_p'  `trimif' , ///                          /* JPA 15/09/2005 */
                    name(temp2`grname', replace) title("Pen's Parade") xtitle("`varlist'") ///
                    ytitle("`xtitle2'") legend(label(1 "`label1'") label(2 "`label2'") label(3 "`label3'") ///
                    label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") label(8 "`label8'") ///
                    label(9 "`label9'") label(10 "`label10'"))   `options'    `figksgp'  /*Pen's Parade */
            }
            if ("`ge'" != "") {
                graph twoway `ge_f' `sel_e' `trimif' , ///                           /* JPA 15/09/2005 */
                    name(temp3`grname', replace) title("Generalized Loren's Curve") xtitle("Average accumulated `varlist'") ///
                    ytitle("`xtitle1'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'")) `options'  `figksge'  /* General Lorenz */
            }
            if ("`gom'" != "") {
                graph twoway `gom_f' `sel_om' `trimif' , ///                           /* JPA 25/03/2012 */
                    name(temp4`grname', replace) title("") xtitle("Mean `varlist'") ///
                    ytitle("Mean `order'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'")) `options' `figksge' /* Mean values by order variable  */
            }
            if ("`goa'" != "") {
                graph twoway `goa_f' `sel_oa' `trimif' , ///                           /* JPA 25/03/2012 */
                    name(temp5`grname', replace) title("") xtitle("Average accumulated `varlist'") ///
                    ytitle("Average accumulated `order'") legend(label(1 "`label1'") label(2 "`label2'") ///
                    label(3 "`label3'") label(4 "`label4'") label(5 "`label5'") label(6 "`label6'")  label(7 "`label7'") ///
                    label(8 "`label8'") label(9 "`label9'") label(10 "`label10'")) `options' `figksge' /* Accumulated mean values by ordered variable  */
            }

        }

        drop bvector*

   }


*****************************************************
* Compare distributions / Stocastic Dominance       *
*****************************************************

        if ("`compare'" != "") {

            foreach i of numlist `c' {
                svmat double mat`i', names(col)
            }


        ********************************
        * Define base category compare *
        ********************************

        _pecatsal `by' if `touse'
        local nrows = r(numcats)
        local c = r(catvals)
        local labcat = r(catnms8)


        if (`base' != -99) {
            local c = subinword("`c'",string(`base'),"",.)
            local c1 = `base'
            local c2 = "`c'"
    		local labcatbase :  label (`by')  `base'				  /* JP Azevedo 20070330 */
        }

        if (`base' == -99) {
            local base = word("`c'",1)
            local c = subinword("`c'","`base'","",.)
            local c1 = `base'
            local c2 = "`c'"
    		local labcatbase = word("`labcat'",1)			          /* JP Azevedo 20070330 */
        }


            ***************************
            * comparing distributions *
            ***************************


            foreach num in `c1' {

                drop if percent`num'==.

                tempvar comp`base'_t comp`base'_x comp`base'_l comp`base'_s
                tempname mat1`base'_t mat1`base'_x mat1`base'_l mat1`base'_s
                tempname mat2`base'_t mat2`base'_x mat2`base'_l mat2`base'_s

                * Comapare t

                    tempvar ind1 ind2
                    gen `ind1' = 1 if t_`num' > t_`base'
                    gen `ind2' = 1 if t_`num' <= t_`base'

                    sum `ind1' if 1<=percent`num'<=`points'

                    local temp`base'_t_`num' = r(sum)
                    scalar temp`base'_t1_`num' = `temp`base'_t_`num''
                    local namemat "temp`base'_t1_`num'"
                    local mat1t "`mat1t' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'

                    local temp`base'_t_`num' = r(sum)
                    scalar temp`base'_t2_`num' = `temp`base'_t_`num''
                    local namemat "temp`base'_t2_`num'"
                    local mat2t "`mat2t' `namemat'"

                * Comapare x (percentile)
                    tempvar ind1 ind2
                    gen `ind1' = 1 if x_`num' > x_`base'
                    gen `ind2' = 1 if x_`num' <= x_`base'

                    sum `ind1' if 1<=percent`num'<=`points'

                    local temp`base'_x_`num' = r(sum)
                    scalar temp`base'_x1_`num' = `temp`base'_x_`num''
                    local namemat "temp`base'_x1_`num'"
                    local mat1x "`mat1x' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'

                    local temp`base'_x_`num' = r(sum)
                    scalar temp`base'_x2_`num' = `temp`base'_x_`num''
                    local namemat "temp`base'_x2_`num'"
                    local mat2x "`mat2x' `namemat'"

                * Comapare l
                    tempvar ind1 ind2
                    gen `ind1' = 1 if l_`num' > l_`base'
                    gen `ind2' = 1 if l_`num' <= l_`base'

                    sum `ind1' if 1<=percent`num'<=`points'-1

                    local temp`base'_l_`num' = r(sum)
                    scalar temp`base'_l1_`num' = `temp`base'_l_`num''
                    local namemat "temp`base'_l1_`num'"
                    local mat1l "`mat1l' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'-1

                    local temp`base'_l_`num' = r(sum)
                    scalar temp`base'_l2_`num' = `temp`base'_l_`num''
                    local namemat "temp`base'_l2_`num'"
                    local mat2l "`mat2l' `namemat'"

                * Comapare s
                    tempvar ind1 ind2
                    gen `ind1' = 1 if s_`num' > s_`base'
                    gen `ind2' = 1 if s_`num' <= s_`base'

                    sum `ind1' if 1<=percent`num'<=`points'

                    local temp`base'_s_`num' = r(sum)
                    scalar temp`base'_s1_`num' = `temp`base'_s_`num''
                    local namemat "temp`base'_s1_`num'"
                    local mat1s "`mat1s' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'

                    local temp`base'_s_`num' = r(sum)
                    scalar temp`base'_s2_`num' = `temp`base'_s_`num''
                    local namemat "temp`base'_s2_`num'"
                    local mat2s "`mat2s' `namemat'"

            }


            foreach num in `c2' {

                keep if 1<=percent`num'<=`points'

                tempvar comp`base'_t comp`base'_x comp`base'_l comp`base'_s
                tempname mat1`base'_t mat1`base'_x mat1`base'_l mat1`base'_s
                tempname mat2`base'_t mat2`base'_x mat2`base'_l mat2`base'_s
                tempvar result_i result_ie result_ce

                * Comapare t /* T-Income mean */

                    tempvar ind1 ind2
                    gen `ind1' = 0
                    replace `ind1' = 1 if t_`num' > t_`base'
                    gen `ind2' = 0
                    replace `ind2' = 1 if t_`num' <= t_`base'

                    sum `ind1' if 1<=percent`num'<=`points'

                    local temp`base'_t_`num' = r(sum)
                    scalar temp`base'_t1_`num' = `temp`base'_t_`num''
                    local namemat "\ temp`base'_t1_`num'"
                    local mat1t "`mat1t' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'

                    local temp`base'_t_`num' = r(sum)
                    scalar temp`base'_t2_`num' = `temp`base'_t_`num''
                    local namemat "\ temp`base'_t2_`num'"
                    local mat2t "`mat2t' `namemat'"

                * Comapare x /* Pen's Parade */
                    tempvar ind1 ind2
                    gen `ind1' = 0
                    replace `ind1' = 1 if x_`num' > x_`base'
                    gen `ind2' = 0
                    replace `ind2' = 1 if x_`num' <= x_`base'

                    sum `ind1' if 1<=percent`num'<=`points'

                    local temp`base'_x_`num' = r(sum)
                    scalar temp`base'_x1_`num' = `temp`base'_x_`num''
                    local namemat "\ temp`base'_x1_`num'"
                    local mat1x "`mat1x' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'

                    local temp`base'_x_`num' = r(sum)
                    scalar temp`base'_x2_`num' = `temp`base'_x_`num''
                    local namemat "\ temp`base'_x2_`num'"
                    local mat2x "`mat2x' `namemat'"

                * Comapare l /* Loren's Curve */
                    tempvar ind1 ind2
                    gen `ind1' = 0
                    replace `ind1' = 1 if l_`num' > l_`base'
                    gen `ind2' = 0
                    replace `ind2' = 1 if l_`num' <= l_`base'

                    sum `ind1' if 1<=percent`num'<=`points'-1

                    local temp`base'_l_`num' = r(sum)
                    scalar temp`base'_l1_`num' = `temp`base'_l_`num''
                    local namemat "\ temp`base'_l1_`num'"
                    local mat1l "`mat1l' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'-1

                    local temp`base'_l_`num' = r(sum)
                    scalar temp`base'_l2_`num' = `temp`base'_l_`num''
                    local namemat "\ temp`base'_l2_`num'"
                    local mat2l "`mat2l' `namemat'"

                * Comapare s /* Gen Loren's Curve */
                    tempvar ind1 ind2
                    gen `ind1' = 0
                    replace `ind1' = 1 if s_`num' > s_`base'
                    gen `ind2' = 0
                    replace `ind2' = 1 if s_`num' <= s_`base'

                    sum `ind1' if 1<=percent`num'<=`points'

                    local temp`base'_s_`num' = r(sum)
                    scalar temp`base'_s1_`num' = `temp`base'_s_`num''
                    local namemat "\ temp`base'_s1_`num'"
                    local mat1s "`mat1s' `namemat'"

                    sum `ind2' if 1<=percent`num'<=`points'

                    local temp`base'_s_`num' = r(sum)
                    scalar temp`base'_s2_`num' = `temp`base'_s_`num''
                    local namemat "\ temp`base'_s2_`num'"
                    local mat2s "`mat2s' `namemat'"

            }

            mat `mat1`base'_t' = `mat1t'
            svmat double `mat1`base'_t', names(__t1)
            mat `mat2`base'_t' = `mat2t'
            svmat double `mat2`base'_t', names(__t2)
            mat `mat1`base'_x' = `mat1x'
            svmat double `mat1`base'_x', names(__x1)
            mat `mat2`base'_x' = `mat2x'
            svmat double `mat2`base'_x', names(__x2)
            mat `mat1`base'_l' = `mat1l'
            svmat double `mat1`base'_l', names(__l1)
            mat `mat2`base'_l' = `mat2l'
            svmat double `mat2`base'_l', names(__l2)
            mat `mat1`base'_s' = `mat1s'
            svmat double `mat1`base'_s', names(__s1)
            mat `mat2`base'_s' = `mat2s'
            svmat double `mat2`base'_s', names(__s2)

            * Comapare t
                gen `comp`base'_t' = "above" if __t1 == `points'
                replace `comp`base'_t' = "below" if __t2 == `points'

            * Comapare x
                gen `comp`base'_x' = "above" if __x1 == `points'
                replace `comp`base'_x' = "below" if __x2 == `points'
                replace `comp`base'_x' = "indet" if __x1 != `points' & __x2 != `points'

            * Comapare l
                gen `comp`base'_l' = "above" if __l1 == `points'-1
                replace `comp`base'_l' = "below" if __l2 == `points'-1
                replace `comp`base'_l' = "indet" if __l1 != `points'-1 & __l2 != `points'-1

            * Comapare x
                gen `comp`base'_s' = "above" if __s1 == `points'
                replace `comp`base'_s' = "below" if __s2 == `points'
                replace `comp`base'_s' = "indet" if __s1 != `points' & __s2 != `points'


            *** Resumo das comparacoes ***
            * Ausencia de envidia
                *better
                gen `result_i' = "better" if `comp`base'_t' == "above" & `comp`base'_x' == "above"
                *worse
                replace `result_i' = "worse" if `comp`base'_t' == "below" & `comp`base'_x' == "below"
                *none
                replace `result_i' = "indet" if `result_i' ==""

            * Ausencia de envidia y preferencia por igualdad
                *better
                gen `result_ie' = "better" if `comp`base'_t' == "above" & `comp`base'_x' == "above"
                replace `result_ie' = "better" if `comp`base'_t' == "above" & `comp`base'_x' != "above" & `comp`base'_l' == "above"
                replace `result_ie' = "better" if `comp`base'_t' == "above" & `comp`base'_x' != "above" & `comp`base'_l' != "above" & `comp`base'_l' == "above"
                *worse
                replace `result_ie' = "worse" if `comp`base'_t' == "below" & `comp`base'_x' == "below"
                replace `result_ie' = "worse" if `comp`base'_t' == "below" & `comp`base'_x' != "below" & `comp`base'_l' == "below"
                replace `result_ie' = "worse" if `comp`base'_t' == "below" & `comp`base'_x' != "below" & `comp`base'_l' != "below" & `comp`base'_l' == "below"
                *none
                replace `result_ie' = "indet" if `result_ie' ==""

            * Preferencia por crecimiento y igualdad
                *better
                gen `result_ce' = "better" if `comp`base'_t' == "above" & `comp`base'_l' == "above"
                *worse
                replace `result_ce' = "worse" if `comp`base'_t' == "below" & `comp`base'_l' == "below"
                *none
                replace `result_ce' = "indet" if `result_ce' ==""

            label variable `comp`base'_t' "T-Income mean"
            label variable `comp`base'_x' "X-Pen's Parade"
            label variable `comp`base'_l' "L-Loren's Curve"
            label variable `comp`base'_s' "S-Gen Loren's Curve"
            label variable `result_i' "I"
            label variable `result_ie' "IE"
            label variable `result_ce' "CE"

            gen __index =.
            local max = `nrows'-1
            forvalues i = 1(1) `max' {
                local tmptmp = word("`c'", `i')
                replace __index = real("`tmptmp'") in `i'
            }
            local valcat :  value label `by'
            if ("`valcat'" != "") {
                label values __index `valcat'
            }

            rename `comp`base'_t' rn_acomp_t
            rename `comp`base'_x' rn_bcomp_x
            rename `comp`base'_l' rn_ccomp_l
            rename `comp`base'_s' rn_dcomp_s
            rename `result_i' rn_eresult_i
            rename `result_ie' rn_fresult_ie
            rename `result_ce' rn_gresult_ce

            drop if __index ==.

            keep __index rn_*

            reshape long rn_, i(__index) j(var) string

            replace var="1" if var ==  "acomp_t"
            replace var="2" if var ==  "bcomp_x"
            replace var="3" if var ==  "ccomp_l"
            replace var="4" if var ==  "dcomp_s"
            replace var="5" if var ==  "eresult_i"
            replace var="6" if var ==  "fresult_ie"
            replace var="7" if var ==  "gresult_ce"

            gen var2=real(var)
            label var var2 "Summary of the distribution comparisson"
            label var __index "Comparisson Groups"

            label define var2 1 "IncMean" 2 "Pen" 3 "Lorenz" 4 "GenLorenz" 5 "I" 6 "IE" 7 "CE", modify
            label value var2 var2
            noi di ""
            noi di ""
            noi di in g "Omited category: " in y  "`labcatbase'"
            noisily tabdisp   __index var2 , c(rn_) format(`format') cellwidth(6)   csepwidth(3)  stubwidth(16)
            noi di in y "I:  " in g" Lack of envy."
            noi di in y "IE: " in g" Lack of envy and preference for equity."
            noi di in y "CE: " in g" Preference for growth with equity."
            noi di ""

    restore

    }


	}	
	
	return add

end
