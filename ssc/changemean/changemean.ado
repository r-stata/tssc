*! version 3.0          <07apr2020>         JPAzevedo
* 	support aw
* 	remove the requirement of autofill
*! version 2.3          <10sept2010>         JPAzevedo
*  return list values as matrix
*! version 2.2          <10abr2007>         JPAzevedo
*   reflect changes on apoverty
* version 2.1          <30mar2007>         JPAzevedo
* version 2.0          <28nov2006>         JPAzevedo & SFranco
* All measures of poverty are now supported
* version 1.3           <20nov2006>         SFranco
* Optional measure of poverty P0, P1, P2
* version 1.2           <25jul2006>         JPAzevedo & SFranco
* change the ado.file name apoverty to apoverty
* version 1.1           <03may2005>         JPAzevedo & SFranco
* version 1.0           <25apr2005>

*** Este programa utiliza o ado.file "apoverty" - ver em ... ***


*************************************
* Change mean of income and inequal *
*************************************


program define changemean, rclass

    version 7.0

    syntax varlist(min=1 max=1 numeric)             ///
                [in] [if]                           ///
                [fweight aweight]                           ///
                [,by(varname)                       ///
                base(real -99)                      ///
                line(real -1)                       ///
                varpl(varname)                      ///
                h h2 pgr igr w s tak thon fgt1  ///
                fgt2 fgt3 fgt4 fgt5 fgt6 fgt7 fgt8  ///
                fgt9 chu1 chu2 chu3 chu4 chu5       ///
                ]


    ************************************************
    * Definiendo las variables temporarias
    ************************************************

    tempvar temp1 weight2 touse mean1 mean2 new`varlist'
    tempvar index dif dif1 dif2 dif3 dif4 income ineq parc_income parc_ineq
    tempname valnum rcount matrix matline1 matline2 matline3


    *********************************************************************************************************
    * Definiendo la mediana de `varlist' como o ponto de corte para generar 2 grupos distintos de comparacion
    *********************************************************************************************************

    preserve

    if (`line'!=-1) {
        local povertyline "line(`line')"
    }
    if ("`varpl'"!="") {
        local povertyline "varpl(`varpl')"
    }

    if ("`by'"=="") {

*       noisily di in r "change definded for varlist median"

        tabstat `varlist' [`weight' `exp'], statistics(p50) save
        mat temp=r(StatTot)
        local temp2=temp[1,1]
        gen `temp1'=1 if `varlist'<=`temp2'
        replace `temp1'=0 if `varlist'>`temp2'
        local by `temp1'
        tab `by'
    }

    if "`h'"    !="" {
        local measure2   "h"
        local measure3   "r(head_1)"
        local measure4  "Headcount Ratio"
    }

    if "`h2'"   !="" {
        local measure2   "h2"
        local measure3   "r(head2_1)"
        local measure4  "Extreme Headcount Ratio"
    }
    if "`pgr'"  !="" {
        local measure2   "pgr"
        local measure3   "r(pogapr_1)"
        local measure4  "Poverty gap ratio"
    }
    if "`igr'"  !="" {
        local measure2   "igr"
        local measure3   "r(ingapr_1)"
        local measure4  "Income gap ratio"
    }
    if "`w'"    !="" {
        local measure2   "w"
        local measure3   "r(watts_1)"
        local measure4  "Watts index"
    }
    if "`fgt1'" !="" {
        local measure2   "fgt1"
        local measure3   "r(fogto1_1)"
        local measure4   "FGT(0.5)"
    }
    if "`fgt2'" !="" {
        local measure2   "fgt2"
        local measure3   "r(fogto2_1)"
        local measure4   "FGT(1.5)"
    }
    if "`fgt3'" !="" {
        local measure2   "fgt3"
        local measure3   "r(fogto3_1)"
        local measure4   "FGT(2)"
    }
    if "`fgt4'" !="" {
        local measure2   "fgt4"
        local measure3   "r(fogto4_1)"
        local measure4   "FGT(2.5)"
    }
    if "`fgt5'" !="" {
        local measure2   "fgt5"
        local measure3   "r(fogto5_1)"
        local measure4   "FGT(3)"
    }
    if "`fgt6'" !="" {
        local measure2   "fgt6"
        local measure3   "r(fogto6_1)"
        local measure4   "FGT(3.5)"
    }
    if "`fgt7'" !="" {
        local measure2   "fgt7"
        local measure3   "r(fogto7_1)"
        local measure4   "FGT(4)"
    }
    if "`fgt8'" !="" {
        local measure2   "fgt8"
        local measure3   "r(fogto8_1)"
        local measure4   "FGT(4.5)"
    }
    if "`fgt9'" !="" {
        local measure2   "fgt9"
        local measure3   "r(fogto9_1)"
        local measure4   "FGT(5)"
    }
    if "`chu1'" !="" {
        local measure2   "chu1"
        local measure3   "r(clk1_1)"
        local measure4   "CHU(0.10)"
    }
    if "`chu2'" !="" {
        local measure2   "chu2"
        local measure3   "r(clk2_1)"
        local measure4   "CHU(0.25)"
    }
    if "`chu3'" !="" {
        local measure2   "chu3"
        local measure3   "r(clk3_1)"
        local measure4   "CHU(0.50)"
    }
    if "`chu4'" !="" {
        local measure3   "r(clk4_1)"
        local measure4   "CHU(0.75)"
        local measure2   "chu4"
    }
    if "`chu5'" !="" {
        local measure3   "r(clk5_1)"
        local measure4   "CHU(0.90)"
        local measure2   "chu5"
    }
    if "`s'"    !="" {
        local measure2   "s"
        local measure3   "r(sen_1)"
        local measure4   "Sen index"
    }
    if "`thon'" !="" {
        local measure2   "thon"
        local measure3   "r(thonse_1)"
        local measure4   "Takayama index"
    }
    if "`tak'"  !="" {
        local measure3   "r(takase_1)"
        local measure4   "Thon index"
        local measure2   "tak"
    }



    if ("`h'"=="") & ("`h2'"=="") & ("`apg'"=="") & ("`pgr'"=="") & ("`igr'"=="") & ("`w'"=="") & ("`s'"=="") & ("`tak'"=="") & ("`thon'"=="") & ("`fgt1'"=="") & ("`fgt2'"=="") & ("`fgt3'"=="") & ("`fgt4'"=="") & ("`fgt5'"=="") & ("`fgt6'"=="") & ("`fgt7'"=="") & ("`fgt8'"=="") & ("`fgt9'"=="") & ("`chu1'"=="") & ("`chu2'"=="") & ("`chu3'"=="") & ("`chu4'"=="") & ("`chu5'"=="") {
        local measure4  "Headcount Ratio"
        local measure2   "h"
        local measure3   "r(head_1)"
    }

    quietly {

        mark `touse' `if' `in' [`weight'`exp']

        ************************************************
        **** generando variables complementares
        ************************************************
            _pecats `by'  if `touse'  					/* JP Azevedo 20070330 */	
            local nrows = r(numcats)
            local c = r(catvals)
            local labcat = r(catnms8)

        ************************************************
        **** categoria de referencia
        ************************************************

        if (`base' != -99) {

            local c2 = "`c'"
            local c = subinword("`c'",string(`base'),"",.)
		local labcatbase :  label (`by')  `base'				/* JP Azevedo 20070330 */

        if ("`c2'" == "`c'") { 				 			/* JP Azevedo 20070330 */
            di as err "ommited category must be valid value for by()"
            exit 198
        }

        }

        if (`base' == -99) {

            local base = word("`c'",1)
            local c = subinword("`c'","`base'","",.)
		local labcatbase = word("`labcat'",1)			/* JP Azevedo 20070330 */
        }

        ************************************************
        * generando el promedio de cada grupo variáveis multiplas
        ************************************************

        foreach num in `base' `c' {
            tempvar mean`num'
            sum `varlist' [`weight' `exp'] if `by'==`num' &  `touse'
            local `varlist'`num'=r(mean)
            gen `mean`num''=``varlist'`num'' if  `touse'
        }

        * generando los nuevos inngresos una única variável

        tempvar new`varlist'

        gen `new`varlist'' = .

        foreach num in  `base' `c' {
            sum `varlist' [`weight' `exp'] if `by'==`num' &  `touse'
            local `varlist'`num' = r(mean)
            replace `new`varlist'' = ``varlist'`num'' if `by'==`num'  &  `touse'
        }

        * generando los nuevos inngresos una única variável (renda média)

        foreach num in `c' {
            tempvar base`varlist'_`num'
            gen `base`varlist'_`num'' = (`varlist'/`mean`base'')*(`mean`num'') if `by'==`base'  &  `touse'
        }

        * generando los nuevos inngresos una única variável (desigualdade)

        tempvar ineq`varlist'_base
        gen `ineq`varlist'_base' = (`varlist'/ `new`varlist'')*(`mean`base'') if  `touse'

        ************************************************
        **** generando los resultados finales
        ************************************************

        foreach num in `base' {

                apoverty `varlist' [`weight' `exp'] if `by'==`num'  &  `touse', `measure2' `povertyline'

                local temp_`varlist'_`num'0 = `measure3'

                scalar temp_`varlist'_`num'0 = `temp_`varlist'_`num'0'

        }


        local c1 = word("`c'",1)
        local cn = subinword("`c'","`c1'","",.)

        apoverty `varlist' [`weight' `exp'] if `by'==`c1'  &  `touse', `measure2'  `povertyline'
		
        local temp_`varlist'_`c1'1 = `measure3'
        scalar temp_`varlist'_`c1'1 = `temp_`varlist'_`c1'1'
        local namemat1 "temp_`varlist'_`c1'1"
        local matrix1 "`namemat1' "

        foreach num in `cn' {

                apoverty `varlist' [`weight' `exp'] if `by'==`num'  &  `touse', `measure2'  `povertyline'

                local temp_`varlist'_`num'1 = `measure3'

                scalar temp_`varlist'_`num'1 = `temp_`varlist'_`num'1'

                local namemat1 "\ temp_`varlist'_`num'1"

                local matrix1 "`matrix1' `namemat1'"

        }

        apoverty `base`varlist'_`c1'' [`weight' `exp'] if `by'==`base'  &  `touse', `measure2' `povertyline'
        local temp_`varlist'_`c1'2 = `measure3'
        scalar temp_`varlist'_`c1'2 = `temp_`varlist'_`c1'2'
        local namemat2 "temp_`varlist'_`c1'2"
        local matrix2 "`namemat2' "

        foreach num in `cn' {

                apoverty `base`varlist'_`num'' [`weight' `exp'] if `by'==`base'  &  `touse', `measure2' `povertyline'

                local temp_`varlist'_`num'2 = `measure3'

                scalar temp_`varlist'_`num'2 = `temp_`varlist'_`num'2'

                local namemat2 "\ temp_`varlist'_`num'2"

                local matrix2 "`matrix2' `namemat2'"

        }

        apoverty `ineq`varlist'_base' [`weight' `exp'] if `by'==`c1'  &  `touse', `measure2' `povertyline'
        local temp_`varlist'_`c1'3 = `measure3'
        scalar temp_`varlist'_`c1'3 = `temp_`varlist'_`c1'3'
        local namemat3 "temp_`varlist'_`c1'3"
        local matrix3 "`namemat3' "

        foreach num in `cn' {

                apoverty `ineq`varlist'_base' [`weight' `exp'] if `by'==`num'  &  `touse', `measure2' `povertyline'

                local temp_`varlist'_`num'3 = `measure3'

                scalar temp_`varlist'_`num'3 = `temp_`varlist'_`num'3'

                local namemat3 "\ temp_`varlist'_`num'3"

                local matrix3 "`matrix3' `namemat3'"

        }

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

        gen __base = `temp_`varlist'_`base'0'

        mat `matline1' = `matrix1'
        mat matline1   = `matrix1'
        svmat double `matline1', names(__povc)

        mat `matline2' = `matrix2'
        svmat double `matline2', names(__povsimulinc)

        mat `matline3' = `matrix3'
        svmat double `matline3', names(__povsimulinq)

        label variable __index "Index"
        label variable __base "poverty baseline"
        label variable __povc1 "original poverty"
        label variable __povsimulinc1 "change mean poverty"
        label variable __povsimulinq1 "change ineq poverty"


        gen `dif'  = __base - __povc1
        gen `dif1' = __base - __povsimulinc1
        gen `dif2' = __povsimulinq1 - __povc1
        gen `dif3' = __base -  __povsimulinq1
        gen `dif4' = __povsimulinc1 - __povc1

        egen `income' = rmean(`dif1' `dif2')
        egen `ineq' = rmean(`dif3'  `dif4')
        gen `parc_income' =`income'/`dif'
        gen `parc_ineq' = `ineq'/`dif'

        label variable `income' "Income"
        label variable `ineq' "Inequality"
        label variable `parc_income' "Inc Contr"
        label variable `parc_ineq' "Ineq Contr"
        label variable `dif' "Total Gap"

    }

    rename __base 			rn_1
    rename __povc1 			rn_2
    rename __povsimulinc1 	rn_3
    rename __povsimulinq1 	rn_4
    rename `dif' 			rn_5
    rename `income' 		rn_6
    rename `ineq' 			rn_7
    rename `parc_income' 	rn_8
    rename `parc_ineq' 		rn_9

    qui drop if __index ==.

    qui reshape long rn_, i(__index) j(var)

	tempname temp
	mkmat var __index rn_ , nomissing matrix(`temp')
	
	return matrix results = `temp'
	
    label define var 1 "Baseli" 2 "Origin" 3"Income" 4 "Inequa" 5"Gap" 6"RawInc" 7 "RawIneq" 8 "RelInc" 9 "RelIneq"
    label values var var
    label var var "Poverty Measure: `measure4'"
	
    noi di ""
    noi di in g "Income and Inequalily Contribution on Poverty Variation - " in y  "`measure4'"
    noi di in g "omited category: " in y  "`labcatbase'" in g "	
    tabdisp   __index var, c(rn_) format(%12.2f) cellwidth(6)   csepwidth(2)  stubwidth(6)

    restore

	
end
