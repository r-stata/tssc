*! Version 2.0     20 dez 2010
* fix genx program define bug
* Version 1.01     9 fev 2005
* Version 1.0      3 fev 2005

program dfl

    version 8.2

    syntax [varlist(default=none)] [if] [in], outcome(varname) [ group(varname) ///
        graph(string) min(real -99) max(real -99) nbins(real 200) w(real -99) ///
        step(varlist) adaptive gauss epan oaxaca quietly nogrt(string) probit  ///
        ylabel(string) xlabel(string) colfirst ycommon  xcommon  copies nodraw ///
        rows(string) cols(string) holes(string) iscale(string) iscale(string) ///
        imargin(string) name3(string) saving(string) xtitle(string) nxvar(string) ///
        ncfactual(string) nufactual(string) nfactual(string)title(string) subtitle(string) ///
        note(string) caption(string) t1title(string) t2title(string)b1title(string) b2title(string) ///
        l1title(string) l2title(string) r1title(string) r2title(string) legend(string) grtpos(string) ///
        xscale(string)]

    tempvar phat wgt x ufactual factual cfactual diff outcome2 x cfwage cfwage2 lwage2 ///
        cfwage3 lwage3 diff_all

    tokenize `varlist'
    local ct=wordcount("`varlist'")
    local ct=`ct'-1
    local depvar `1'
    macro shift
    local rhs `1'

    forvalues i=2/`ct' {
        local reg ``i''
        local rhs `rhs' `reg'
    }

    if ("`nxvar'"=="") {
        local outname: variable label `outcome'
        if ("`outname'"=="") {
            local nxvar ""`outcome'""
        }
        else {
            local nxvar ""`outname'""
        }
    }

    if ("`nxvar'"!="") {
        local nxvar ""`nxvar'""
    }

    local clab: value label `depvar'
    if ("`clab'"!="") {
        _pecats `depvar'
        local catnms "`r(catnms)'"
    }

    if ("`ncfactual'"=="") {
        if ("`clab'"=="") {
            local ncfactual ""weighted `depvar'=0""
        }
        else {
            local deplab: word 1 of `catnms'
            local ncfactual ""weighted `deplab'""
        }
    }

    if ("`ncfactual'"!="") {
        local ncfactual ""`ncfactual'""
    }

    if ("`nufactual'"=="") {
        if ("`clab'"=="") {
            local nufactual ""`depvar'=1""
        }
        else {
            local deplab: word 2 of `catnms'
            local nufactual ""`deplab'""
        }
    }

    if ("`nufactual'"!="") {
        local nufactual ""`nufactual'""
    }

    if ("`nfactual'"=="") {
        if ("`clab'"=="") {
            local nfactual ""`depvar'=0""
        }
        else {
            local deplab: word 1 of `catnms'
            local nfactual ""`deplab'""
        }
    }

    if ("`nfactual'"!="") {
        local nfactual ""`nfactual""
    }

    local varlist `rhs'

    gen double `outcome2'=`outcome'

    if ("`probit'"=="") {
        local model "logit"
    }

    if ("`probit'"!="") {
        local model "probit"
    }

    if ("`if'"!="") {
        local if2=subinstr("`if'","if","",.)
        local if2 "& `if2'"
    }

    quietly if "`group'"=="" {

        if "`step'"=="" {

            if ("`quietly'"=="") {
                noisily `model' `depvar' `varlist' `if' `in'
                predict double `phat'
            }

            if ("`quietly'"!="") {
                qui `model' `depvar' `varlist' `if' `in'
                qui predict double `phat'
            }

            gen double `wgt'=(1-`phat')/`phat'

            if ((`min'==-99) & (`max'==-99)) {
                qui summ `outcome2'
                local min=r(min)
                local max=r(max)
            }

            _genx `x', min(`min') max(`max') nbins(`nbins')

            if ("`adaptive'"=="") {

            quietly summ `x'

                if (`w'==-99) {
                    kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                    kdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') nograph `gauss' `epan'
                    kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                }

                if (`w'!=-99) {
                    kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                    kdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') w(`w') nograph `gauss' `epan'
                    kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
                }
            }

            if ("`adaptive'"!="") {

            quietly summ `x'

                if (`w'==-99) {
                    akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                    akdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') nograph `gauss' `epan'
                    akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                }

                if (`w'!=-99) {
                    akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                    akdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') w(`w') nograph `gauss' `epan'
                    akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
                }
            }

            local bwid =`x'[2]-`x'[1]
            quietly summ `cfactual'

        noisily di
            *noisily di in r %5.2f r(sum)*`bwid' in y " <- This should be one "

            gen `diff'=`ufactual'-`cfactual'

            label variable `x' `nxvar'
            label variable `cfactual' `ncfactual'
            label variable `factual' `nfactual'
            label variable `ufactual' `nufactual'

            #delimit ;
            graph twoway line `factual' `cfactual' `x',
                c(l l)
                clpattern(dash l)
                msymbol(T O)
                msize(vtiny vtiny)
                name(cfactual, replace)
                nodraw
                ytitle("Density")
                xtitle(`xtitle')
                ylabel(`ylabel')
                xlabel(`xlabel')
                legend(`legend')
                xscale(`scale');

            graph twoway line `ufactual' `cfactual' `x',
                c(l l)
                clpattern(dash l)
                msymbol(T O)
                msize(vtiny vtiny)
                name(ufactual, replace)
                nodraw
                ytitle("Density")
                xtitle(`xtitle')
                ylabel(`ylabel')
                xlabel(`xlabel')
                legend(`legend')
                xscale(`scale');

            graph twoway line `diff' `x',
                c(l)
                clpattern(l)
                msymbol(T)
                msize(vtiny)
                name(diff, replace)
                nodraw
                ytitle("Difference in Densities")
                xtitle(`xtitle')
                ylabel(`ylabel')
                xlabel(`xlabel')
                legend(`legend')
                xscale(`scale');


            if "`graph'"=="" {;
                graph combine cfactual ufactual diff,
                `colfirst'
                `ycommon'
                `xcommon'
                `copies'
                `nodraw'
                cols(`cols')
                    rows(`rows')
                    holes(`holes')
                    iscale(`iscale')
                    imargin(`imargin')
                    name(`name3')
                    saving(`saving')
                    title(`title')
                    subtitle(`subtitle')
                    note(`note')
                    caption(`caption')
                    t1title(`t1title')
                    t2title(`t2title')
                    b1title(`b1title')
                    b2title(`b2title')
                    l1title(`l1title')
                    l2title(`l2title')
                    r1title(`r1title')
                    r2title(`r2title');
            };

            if "`graph'"!="" {;
                graph combine `graph',
            `colfirst'
                `ycommon'
                `xcommon'
                `copies'
                `nodraw'
                cols(`cols')
                    rows(`rows')
                    holes(`holes')
                    iscale(`iscale')
                    imargin(`imargin')
                    name(`name3')
                    saving(`saving')
                    title(`title')
                    subtitle(`subtitle')
                    note(`note')
                    caption(`caption')
                    t1title(`t1title')
                    t2title(`t2title')
                    b1title(`b1title')
                    b2title(`b2title')
                    l1title(`l1title')
                    l2title(`l2title')
                    r1title(`r1title')
                    r2title(`r2title');
            };

        #delimit cr


            if "`oaxaca'"!="" {

                if "`if'"=="" {
                    quietly reg  `outcome2' `varlist' if `depvar' `if2'
                    quietly predict double `cfwage' if !`depvar'  `if2'
                }

                if "`if'"!="" {
                    quietly reg  `outcome2' `varlist' `if' & `depvar' `if2'
                    quietly predict double `cfwage' `if' & !`depvar'  `if2'
                }

                qui summ `cfwage' if !`depvar'
                local cfwage=r(mean)
                qui summ `outcome2' if !`depvar'
                local outcome3=r(mean)

                qui summ `x'  [aw=`cfactual']
                local cfwage2=r(mean)
                gen `cfwage3' =r(mean)
                qui summ `x'  [aw=`factual']
                local lwage2=r(mean)
                gen `lwage3'=r(mean)
                replace `cfwage3'=`cfwage3'[_N]
                replace `lwage3'=`lwage3'[_N]

                local diff_f=`cfwage'-`cfwage2'
                local diff_cf=`outcome3'-`lwage2'

                noisily di
                noisily di in g "Mean wage for the union worker: " as res `cfwage'
                noisily di in g "Mean generate from the nonparametric density: " as res `outcome3'
                noisily di
                noisily di in g "Diff actual less kdensity nonunion mean : " as res `diff_f'
                noisily di in g "Diff oaxaca less kdensity cfactual mean : " as res `diff_cf'
                noisily di
            }
        }


        if "`step'"!="" {

            if "`quietly'"=="" {
                noisily `model' `depvar' `varlist' `step' `if' `in'
                predict double `phat'
            }

            if "`quietly'"!="" {
                qui `model' `depvar' `varlist' `step' `if' `in'
                qui predict double `phat'
            }

            gen double `wgt'=(1-`phat')/`phat'

            if ((`min'==-99) & (`max'==-99)) {
                qui summ `outcome2'
                local min=r(min)
                local max=r(max)
            }

            _genx `x', min(`min') max(`max') nbins(`nbins')

            if "`adaptive'"=="" {

            quietly summ `x'

                if (`w'==-99) {
                    kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                    kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                }

                if (`w'!=-99) {
                    kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                    kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
                }
            }

            if "`adaptive'"!="" {

            quietly summ `x'

                if (`w'==-99) {
                    akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                    akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                }

                if (`w'!=-99) {
                    akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                    akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
                }
            }

            local bwid =`x'[2]-`x'[1]
            quietly summ `cfactual'

            *di in r %5.2f r(sum)*`bwid' in y " <- This should be one "

            gen `diff_all'=`ufactual'-`cfactual'

            label var `diff_all' "All variables"
            label variable `x' `nxvar'

            #delimit ;
            graph twoway line `diff_all' `x',
                c(l)
                clpattern(l)
                msymbol(T)
                msize(vtiny)
                name(diff_all, replace)
                nodraw
                ytitle("Difference in Densities")
                xtitle(`xtitle')
                ylabel(`ylabel')
                xlabel(`xlabel')
                legend(`legend')
                xscale(`scale');

            #delimit cr

                foreach var of varlist `step' {

                    local varname=subinstr("`step'","`var'","",.)

                    tempvar wgt_`var' ufactual_`var' cfactual_`var' phat_`var'  diff_`var'

                    if "`quietly'"=="" {
                        noisily `model' `depvar' `varlist' `varname' `if' `in'
                        predict double `phat_`var''
                    }

                    if "`quietly'"!="" {
                        qui `model' `depvar' `varlist' `varname' `if' `in'
                        qui predict double `phat_`var''
                    }

                    gen double `wgt_`var''=(1-`phat_`var'')/`phat_`var''

                    if "`adaptive'"=="" {

                    if (`w'==-99) {
                            kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') nograph `gauss' `epan'
                            kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') nograph `gauss' `epan'
                        }

                    if (`w'!=-99) {
                            kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                            kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                        }
                    }

                    if "`adaptive'"!="" {

                    if (`w'==-99) {
                            akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') nograph `gauss' `epan'
                            akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') nograph `gauss' `epan'
                        }

                        if (`w'!=-99) {
                            akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                            akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                        }
                    }

                    local bwid =`x'[2]-`x'[1]
                    quietly summ `cfactual_`var''

                    *di in r %5.2f r(sum)*`bwid' in y " <- This should be one "

                    gen `diff_`var''=`ufactual_`var''-`cfactual_`var''

                    label variable `diff_`var'' "Except `var'"

                    #delimit ;
                    graph twoway line `diff_`var'' `x',
                        c(l)
                        clpattern(l)
                        msymbol(T)
                        msize(vtiny)
                        name(diff_`var', replace)
                        nodraw
                        ytitle("Difference in Densities")
                        xtitle(`xtitle')
                        ylabel(`ylabel')
                        xlabel(`xlabel')
                        legend(`legend')
                        xscale(`scale');
                    #delimit cr

                    }

                local diff `diff_all'

                foreach var in `step' {
                    local new `diff_`var''
                    local diff `diff' `new'
                }

                #delimit ;
                graph twoway line `diff' `x',
                    c(l l l l l)
                    clpattern(l dash dot dash dot)
                    msymbol(T O T O T)
                    msize(vtiny vtiny vtiny vtiny vtiny)
                    ytitle("Difference in Densities")
                    xtitle(`xtitle')
                    ylabel(`ylabel')
                    xlabel(`xlabel')
                    legend(`legend')
                    xscale(`scale');
                #delimit cr
        }

    }

    quietly if "`group'"!="" {

        tempname valnum rcount

        qui tabulate `group' `if' `in', matrow(`valnum') matcell(`rcount')

        local nrows = rowsof(`valnum')

        local f = `valnum'[1,1]

        local c = `valnum'[1,1]

        forval i = 2 / `nrows' {
            local d = `valnum'[`i',1]
            local c `c' `d'
        }

        local g = `valnum'[2,1]
            forval i = 3 / `nrows' {
            local h = `valnum'[`i',1]
            local  g `g' `h'
        }


        if "`step'"=="" {

            local i=1

            foreach num of numlist `c' {

                if "`nogrt'"=="" {

                local valab2: value label `group'

                if "`valab2'"=="" {
                    local valab `group'=`num'
                }

                if "`valab2'"!="" {
                    _pecats `group'
                    local catnms "`r(catnms)'"
                    local valab: word `i' of `catnms'
                }
                }

        if "`nogrt'"!="" {
             local valab ""
        }

                preserve

                keep if `group'==`num'

                if ("`quietly'"=="") {
                    noisily `model' `depvar' `varlist' `if' `in'
                    predict double `phat'
                }

                if ("`quietly'"!="") {
                    qui `model' `depvar' `varlist' `if' `in'
                    qui predict double `phat'
                }

                gen double `wgt'=(1-`phat')/`phat'

                if ((`min'==-99) & (`max'==-99)) {
                    qui summ `outcome2'
                    local min=r(min)
                    local max=r(max)
                }

                _genx `x', min(`min') max(`max') nbins(`nbins')

        if "`adaptive'"=="" {

            if (`w'==-99) {
                kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                kdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') nograph `gauss' `epan'
                kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                }

            if (`w'!=-99) {
                kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                kdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') nograph `gauss' `epan'
                kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
                }
        }

        if "`adaptive'"!="" {

            if (`w'==-99) {
                akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                akdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') nograph `gauss' `epan'
                akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                }

            if (`w'!=-99) {
                akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                akdensity `outcome2' if `depvar'==0 `if2', gen(`factual') at(`x') nograph `gauss' `epan'
                akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
            }
        }

        local bwid =`x'[2]-`x'[1]

                    quietly summ `cfactual'

                    noisily di
                    *noisily di in r %5.2f r(sum)*`bwid' in y " <- This should be one "
                    noisily di

                    gen `diff'=`ufactual'-`cfactual'

                    label variable `x' `nxvar'
                    label variable `cfactual' `ncfactual'
                    label variable `factual' `nfactual'
                    label variable `ufactual' `nufactual'

                    #delimit ;
                    graph twoway line `factual' `cfactual' `x',
                        c(l l)
                        clpattern(dash l)
                        msymbol(T O)
                        msize(vtiny vtiny)
                        name(cfactual, replace)
                        nodraw
                        ytitle("Density")
                        xtitle(`xtitle')
                        ylabel(`ylabel')
                        xlabel(`xlabel')
                        legend(`legend')
                        xscale(`scale');

                    graph twoway line `ufactual' `cfactual' `x',
                        c(l l)
                        clpattern(dash l)
                        msymbol(T O)
                        msize(vtiny vtiny)
                        name(ufactual, replace)
                        nodraw
                        ytitle("Density")
                        xtitle(`xtitle')
                        ylabel(`ylabel')
                        xlabel(`xlabel')
                        legend(`legend')
                        xscale(`scale');

                    graph twoway line `diff' `x',
                        c(l)
                        clpattern(l)
                        msymbol(T)
                        msize(vtiny)
                        name(diff, replace)
                        nodraw
                        ytitle("Difference in Densities")
                        xtitle(`xtitle')
                        ylabel(`ylabel')
                        xlabel(`xlabel')
                        legend(`legend')
                        xscale(`scale');


                    if ("`graph'"=="") {;
                        graph combine cfactual ufactual diff,
                            name(combine_`num', replace)
                            title("`valab'", `grtpos')
                            nodraw
                            `colfirst'
                            `ycommon'
                            `xcommon'
                            `copies'
                            holes(`holes')
                            iscale(`iscale')
                            imargin(`imargin');

                    };

                    if ("`graph'"!="") {;
                        graph combine `graph',
                            name(combine_`num', replace)
                            title("`valab'", `grtpos')
                            nodraw
                            `colfirst'
                            `ycommon'
                            `xcommon'
                            `copies'
                            holes(`holes')
                            iscale(`iscale')
                            imargin(`imargin');

                    };

                    #delimit cr

                    if ("`oaxaca'"!="") {

                        tempvar cfwage_`num' cfwage3_`num' lwage3_`num'

                        if ("`if'"=="") {
                            quietly reg  `outcome2' `varlist' if `depvar' & `group'==`num' `if2'
                            quietly predict double `cfwage_`num'' if !`depvar' & `group'==`num' `if2'
                        }

                        if ("`if'"!="") {
                            quietly reg  `outcome2' `varlist' `if' & `depvar' & `group'==`num' `if2'
                            quietly predict double `cfwage_`num'' `if' & !`depvar' & `group'==`num' `if2'
                        }

                        qui summ `cfwage_`num'' if !`depvar' & `group'==`num' `if2'
                        local cfwage_`num'=r(mean)
                        qui summ `outcome2' if !`depvar' & `group'==`num' `if2'
                        local outcome3_`num'=r(mean)


                        qui summ `x'  [aw=`cfactual']
                        local cfwage2_`num'=r(mean)
                        gen `cfwage3_`num'' =r(mean)
                        qui summ `x'  [aw=`factual']
                        local lwage2_`num'=r(mean)
                        gen `lwage3_`num''=r(mean)
                        replace `cfwage3_`num''=`cfwage3_`num''[_N]
                        replace `lwage3_`num''=`lwage3_`num''[_N]


                        local diff_f_`num'=`cfwage_`num''-`cfwage2_`num''
                        local diff_cf_`num'=`outcome3_`num''-`lwage2_`num''

                        noisily di
                        noisily di in g "Mean wage for the union worker: " as res `cfwage_`num''
                        noisily di in g "Mean generate from the nonparametric density: " as res `outcome3_`num''
                        noisily di
                        noisily di in g "Diff actual less kdensity nonunion mean : " as res `diff_f_`num''
                        noisily di in g "Diff oaxaca less kdensity cfactual mean : " as res `diff_cf_`num''
                        noisily di

                    }

                    local i=`i'+1

                    restore
                }

                local name combine_`f'

                foreach num of numlist `g' {
                    local name2 combine_`num'
                    local name `name' `name2'
                }

                #delimit ;

                graph combine `name',
                `colfirst'
                `ycommon'
                `xcommon'
                `copies'
                `nodraw'
                name(`name3')
                cols(`cols')
                rows(`rows')
                holes(`holes')
                iscale(`iscale')
                imargin(`imargin')
                saving(`saving')
                title(`title')
                subtitle(`subtitle')
                note(`note')
                caption(`caption')
                t1title(`t1title')
                t2title(`t2title')
                b1title(`b1title')
                b2title(`b2title')
                l1title(`l1title')
                l2title(`l2title')
                r1title(`r1title')
                r2title(`r2title');

                #delimit cr

            }

             if ("`step'"!="") {

                local i=1

                foreach num of numlist `c' {

            if "`nogrt'"=="" {

            local valab2: value label `group'

            if "`valab2'"=="" {
                local valab `group'=`num'
            }

            if "`valab2'"!="" {
                _pecats `group'
                local catnms "`r(catnms)'"
                    local valab: word `i' of `catnms'
            }
            }

            if "`nogrt'"!="" {
            local valab ""
        }

                    preserve

                    keep if `group'==`num'

                    if "`quietly'"=="" {
                        noisily `model' `depvar' `varlist' `step' `if' `in'
                        predict double `phat'
                    }

                    if "`quietly'"!="" {
                        qui `model' `depvar' `varlist' `step' `if' `in'
                        qui predict double `phat'
                    }

                    gen double `wgt'=(1-`phat')/`phat'

                    if ((`min'==-99) & (`max'==-99)) {
                        qui summ `outcome2'
                        local min=r(min)
                        local max=r(max)
                    }

                    _genx `x', min(`min') max(`max') nbins(`nbins')

                    if "`adaptive'"=="" {

                    if (`w'==-99) {
                            kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                            kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                        }

                    if (`w'!=-99) {
                            kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                            kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
                        }
                    }

                    if "`adaptive'"!="" {

                    if (`w'==-99) {
                            akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') nograph `gauss' `epan'
                            akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') nograph `gauss' `epan'
                        }

                        if (`w'!=-99) {
                            akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual') at(`x') w(`w') nograph `gauss' `epan'
                            akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt'], gen(`cfactual') at(`x') w(`w') nograph `gauss' `epan'
                        }
                    }

                        local bwid =`x'[2]-`x'[1]
                        quietly summ `cfactual'

                        *noisily di in r %5.2f r(sum)*`bwid' in y " <- This should be one "


                        gen `diff_all'=`ufactual'-`cfactual'

                        label var `diff_all' "All variables"
                        label variable `x' `nxvar'



                    foreach var in `step' {

                        local varname=subinstr("`step'","`var'","",.)

                        tempvar wgt_`var' ufactual_`var' cfactual_`var' phat_`var'  diff_`var'

                        if "`quietly'"=="" {
                            noisily `model' `depvar' `varlist' `varname' `if' `in'
                            predict double `phat_`var''
                        }

                        if "`quietly'"!="" {
                            qui `model' `depvar' `varlist' `varname' `if' `in'
                            qui predict double `phat_`var''
                        }

                        gen double `wgt_`var''=(1-`phat_`var'')/`phat_`var''

                    if "`adaptive'"=="" {

                    if (`w'==-99) {
                            kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') nograph `gauss' `epan'
                            kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') nograph `gauss' `epan'
                        }

                    if (`w'!=-99) {
                            kdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                            kdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                        }
                    }

                    if "`adaptive'"!="" {

                    if (`w'==-99) {
                            akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') nograph `gauss' `epan'
                            akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') nograph `gauss' `epan'
                        }

                        if (`w'!=-99) {
                            akdensity `outcome2' if `depvar'==1 `if2', gen(`ufactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                            akdensity `outcome2' if `depvar'==1 `if2' [aw=`wgt_`var''], gen(`cfactual_`var'') at(`x') w(`w') nograph `gauss' `epan'
                        }
                    }

                            local bwid =`x'[2]-`x'[1]
                            quietly summ `cfactual_`var''

                            *di in r %5.2f r(sum)*`bwid' in y " <- This should be one "

                            gen `diff_`var''=`ufactual_`var''-`cfactual_`var''

                            label variable `diff_`var'' "Except `var'"

                        }

                        local diff `diff_all'

                        foreach var in `step' {
                            local new `diff_`var''
                            local diff `diff' `new'
                        }

                        #delimit ;
                        graph twoway line `diff' `x',
                            c(l l l l l)
                            clpattern(l dash dot dash dot)
                            msymbol(T O T O T)
                            msize(vtiny vtiny vtiny vtiny vtiny)
                            ytitle("Difference in Densities")
                            xtitle(`xtitle')
                            title("`valab'", `grtpos')
                            name(combine_`num', replace)
                            nodraw
                            ylabel(`ylabel')
                            xlabel(`xlabel')
                            legend(`legend')
                            xscale(`scale');

                        #delimit cr

                        restore

                        local i=`i'+1
                    }

            local name combine_`f'

            foreach num of numlist `g' {
                local name2 combine_`num'
                local name `name' `name2'
            }

        #delimit ;

            graph combine `name',
            `colfirst'
            `ycommon'
            `xcommon'
            `copies'
            `nodraw'
            cols(`cols')
            rows(`rows')
            holes(`holes')
            iscale(`iscale')
            imargin(`imargin')
            saving(`saving')
            title(`title')
            subtitle(`subtitle')
            note(`note')
            caption(`caption')
            t1title(`t1title')
            t2title(`t2title')
            b1title(`b1title')
            b2title(`b2title')
            l1title(`l1title')
            l2title(`l2title')
            r1title(`r1title')
            r2title(`r2title');

        #delimit cr

        }

    }

end
