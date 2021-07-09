*! version 1.2          <30apr2014>         JPAzevedo
* improve the frontier option (isopoverty)
* version 1.1          <10apr2007>         JPAzevedo & SFranco
*   adjust syntax changes on ainequal and apoverty
* version 1.0          <21jul2006>         JPAzevedo & SFranco

* This file uses -ainequal.ado- and -apoverty.ado- by JP Azevedo which are modified versions
* of -inequal.ado- and -poverty.ado- written by Philippe Van Kerm, 1998.

program define isopoverty, rclass

    version 8.1

    syntax varlist(min=1 max=1 numeric) ///
                [in] [if]               ///
                [aweight fweight]       ///
                [, varpl(varname)       ///
                line(real -1)           ///
                stepgrw(real 0)         ///
                stepinq(real 0)         ///
                mingrw(real 0)          ///
                maxgrw(real 1)          ///
                mininq(real 0)          ///
                maxinq(real 1)          ///
                int(real 0)             ///
                target(string)          ///
                frontier                ///
                inequal                 ///
                poverty                 ///
                ]

    tempname temp touse tmptmp temptemp final_ineqreduc final_growth final_growth_ineq

    preserve

    mark `touse' `if' `in' [`weight'`exp']
    markout `touse' `varlist'
    qui keep if `touse'==1


    if ("`poverty'"=="") {
        local poverty " h h2 "
    }
    if ("`inequal'"!="") {
        local inequal " gini theil "
    }
    local apoverty "`poverty'"
    local apoverty=subinstr("`apoverty'","h ", "head ",.)
    local apoverty=subinstr("`apoverty'","h2 ", "head2 ",.)
    local matname_pov ""
    local temp_pov ""
    foreach name in `apoverty' {
        local matname_temp ", `"`name'"'"
        local temptemp ", ."
        local matname_pov "`matname_pov' `matname_temp'"
        local temp_pov "`temp_pov' `temptemp'"
    }
    local temp_pov = substr("`temp_pov'",3,.)
    local matname_pov = substr("`matname_pov'",3,.)
    local matname_ineq ""
    local temp_ineq ""
    foreach name in `inequal' {
        local matname_temp ", `"`name'"'"
        local temptemp ", ."
        local matname_ineq "`matname_ineq' `matname_temp'"
        local temp_ineq "`temp_ineq' `temptemp'"
    }
    local matname_ineq = substr("`matname_ineq'",3,.)
    if ("`varpl'"=="") & (`line'==-1) {
        qui _pctile `varlist' `if' `in' [`weight'`exp'], p(50)
        loc Z = _result(1)/2
        local pline=`Z'
    }
    if ("`varpl'"=="") & (`line'==-2) {
        qui _pctile `varlist' `if' `in' [`weight'`exp'], p(50)
        loc Z = (_result(1)/3)*2
        local pline=`Z'
    }
    if ("`varpl'"=="") & (`line'>0) {
        loc pline = `line'
    }
    qui sum `varlist' [`weight'`exp'] `if' `in'
    local mrdpc = r(mean)

***********************
* Inequality Reduction
***********************

if ("`frontier'"=="") {

    ***********************
    * poverty reduction
    ***********************

    if (`stepinq' > 0 ) {
        loc step2=1/`stepinq'
        qui forvalues i=`mininq'(`step2')`maxinq' {
            local name=int(`i'*10000)
            local index=`name'/100
            tempvar `varlist'`name'
            local tax = 1-`i'
            local credit=`i'
            gen double ``varlist'`name'' =`tax'*`varlist' + `credit'*`mrdpc'
        }
        qui forvalues i=`mininq'(`step2')`maxinq' {
            local name=int(`i'*10000)
            local index=`name'/100
            if ("`varpl'"=="") {
                apoverty ``varlist'`name'' [`weight'`exp'], line(`pline') `poverty'
            }
            if ("`varpl'"!="") {
                apoverty ``varlist'`name'' [`weight'`exp'], varpl("`varpl'") `poverty'
            }
            local head=r(head_1)
            local head2=r(head2_1)

            sum  ``varlist'`name'' [`weight'`exp']
            local mean = r(mean)

            if ("`inequal'"!="") {
                ainequal ``varlist'`name'' [`weight'`exp'], `inequal'
                local gini = r(gini_1)
                local theil = r(theil_1)
                mat `temp' = `index', `head', `head2', `mean', `gini', `theil'
                mat `final_ineqreduc' = nullmat(`final_ineqreduc') \ `temp'
            }
            if ("`inequal'"=="") {
                mat `temp' =   `index', `head', `head2', `mean'
                mat `final_ineqreduc' = nullmat(`final_ineqreduc') \ `temp'
            }

            drop  ``varlist'`name''
        }

        if ("`inequal'"=="") {
            mat colnames `final_ineqreduc' = index `apoverty' mean
        }
        if ("`inequal'"!="") {
            mat colnames `final_ineqreduc' = index `apoverty' mean `inequal'
        }

        local colsof=colsof(`final_ineqreduc')
        local rowsof=rowsof(`final_ineqreduc')
        mat `final_ineqreduc'=`final_ineqreduc'[2..`rowsof',1..`colsof']
        return matrix ineqreduc = `final_ineqreduc'
    }

    ***********************
    * growth increase
    ***********************

    if (`stepgrw' > 0) {
        loc step3=1/`stepgrw'
        qui forvalues i=`mingrw'(`step3')`maxgrw' {
            local name=int(`i'*10000)
            local index=`name'/100
            tempvar `varlist'`name'
            local growth = 1+`i'
            gen double ``varlist'`name'' = `growth'*`varlist'
        }
        qui forvalues i=`mingrw'(`step3')`maxgrw' {
            local growth = 1+`i'
            local name=int(`i'*10000)
            local index=`name'/100
            if ("`varpl'"=="") {
                apoverty ``varlist'`name'' [`weight'`exp'], line(`pline') `poverty'
            }
            if ("`varpl'"!="") {
                apoverty ``varlist'`name'' [`weight'`exp'], varpl("`varpl'") `poverty'
            }
            local head = r(head_1)
            local head2 = r(head2_1)

            sum  ``varlist'`name'' [`weight'`exp']
            local mean = r(mean)

            if ("`inequal'"!="") {
                ainequal ``varlist'`name'' [`weight'`exp'], `inequal'
                local gini = r(gini_1)
                local theil = r(theil_1)
                mat `temp' = `index', `head', `head2', `mean', `gini', `theil'
                mat `final_growth' = nullmat(`final_growth') \ `temp'
            }
            if ("`inequal'"=="") {
                mat `temp' = `index', `head', `head2', `mean'
                mat `final_growth' = nullmat(`final_growth') \ `temp'
            }
            drop ``varlist'`name''
        }

        if ("`inequal'"=="") {
            mat colnames `final_growth' = index `apoverty' mean
        }
        if ("`inequal'"!="") {
            mat colnames `final_growth' = index `apoverty' mean `inequal'
        }

        local colsof=colsof(`final_growth')
        local rowsof=rowsof(`final_growth')
        mat `final_growth' = `final_growth'[2..`rowsof',1..`colsof']
        return matrix growth = `final_growth'
    }
}


***********************
* frontier
***********************

    if ("`frontier'"!="") & (`stepgrw' > 0) & (`stepinq' > 0 ) {
        loc step3=1/`stepgrw'
        loc step2=1/`stepinq'
        qui forvalues i=`mingrw'(`step3')`maxgrw' {
            local ngrowth=int(`i'*10000)
            local index1=`ngrowth'/100
            local growth=1+`i'
            qui forvalues j=`mininq'(`step2')`maxinq' {
                local ineq=int(`j'*10000)
                local index2=`ineq'/100
				local ineqlabel = subinstr("`ineq'","-","_",.)
                tempvar `varlist'_`ngrowth'_`ineqlabel'
                local tax = 1-`j'
                local credit=`j'
                gen double ``varlist'_`ngrowth'_`ineqlabel'' =`growth'*(`tax'*`varlist' + `credit'*`mrdpc')  `if' `in'
				
                if ("`varpl'"=="") {
                    apoverty ``varlist'_`ngrowth'_`ineqlabel'' [`weight'`exp'], line(`pline') h
                }
				
                if ("`varpl'"!="") {
                    apoverty ``varlist'_`ngrowth'_`ineqlabel'' [`weight'`exp'], varpl("`varpl'") h
                }
				
                local head = r(head_1)
				
				foreach tg in `target' {
				
					if (`head'<=`tg'+`int') & (`head'>=`tg'-`int') {

						ainequal ``varlist'_`ngrowth'_`ineqlabel'' [`weight'`exp'], `inequal'
						local gini = r(gini_1)
						local theil = r(theil_1)

						sum ``varlist'_`ngrowth'_`ineqlabel'' [`weight'`exp']
						local mean = r(mean)

						mat `final_growth_ineq' = nullmat(`final_growth_ineq') \ `index1', `index2', `tg', `head', `mean', `gini', `theil'
					}
				
				}
                drop ``varlist'_`ngrowth'_`ineqlabel''
            }
        }

        mat colnames `final_growth_ineq' = growth redistr target head mean gini theil
        local colsof = colsof(`final_growth_ineq')
        local rowsof = rowsof(`final_growth_ineq')

        if (`rowsof' == 1) {
        	error 198
        }
        mat `final_growth_ineq' = `final_growth_ineq'[2..`rowsof',1..`colsof']
        return matrix frontier = `final_growth_ineq'
    }
	
    restore
	
end
