*! History:
*! Version 1.02, Hilde Schaeper, 4 August 2003
*! version 2.00, Ben Jann, 20aug2003 ... with intermediate versions to:
*  version 2.19, Ben Jann, 27apr2005
*! version 2.20, Ben Jann, 25jun2007
*! version 2.21, Ben Jann, 22jun2019
*! version 2.22, Ben Jann, 16apr2020

program define mrtab, rclass sortpreserve byable(recall)
    version 8.2
    syntax varlist [if] [in] [fweight aweight] [, Response(numlist) CONDition(str) Poly ///
     INclude INCLUDEMissing CASEwise COUNTall Generate(string) ///
     sort SORT2(numlist int max=1 >0) DEScending TItle(string) ///
     name(string) noLabel noNames Width(int 30) ABbrev Format(string) INTeger  ///
     by(varlist max=1) noFreq COlumn row CEll RCOLumn RCEll Wrap ///
     CHi2 LRchi2 warn Mtest Mtest2(passthru) MLRchi2  ]

//SYNTAX INTEGRITY / PRELIMINARY OPTION PROCESSING
//varlist
    if "`: list dups varlist'"!="" {
        di as error "duplicate items in varlist"
        exit 198
    }
    forv i=1/`: word count `varlist'' {
        capture confirm str var `:word `i' of `varlist''
        if `i'>1 {
            if _rc == `strvars' {
                di as error "cannot mix string and numeric response variables"
                exit 198
            }
        }
        else local strvars=!_rc
    }
    if `strvars' {
        local poly 1
        if "`response'"!="" {
            di as error "option response() not allowed"
            exit 198
        }
        if "`condition'"!="" {
            di as error "option condition() not allowed"
            exit 198
        }
    }
    else local poly="`poly'"!=""
    if "`response'"!="" & "`condition'"!="" {
        di as error "option condition() not allowed if response() is specified"
        exit 198
    }
    if "`condition'"!="" {
        if !index("`condition'","@") {
            di as error "condition() must contain @"
            exit 499
        }
    }
    local countall="`countall'"!=""

//format options
    if `"`format'"'!="" {
        capt local temp : display `format' 1
        if _rc | index(`"`format'"',"%")!=1 {
            di as err `"invalid %fmt in format(): `format'"'
            exit 120
        }
    }
    else local format %9.2f
    if "`integer'"!="" local integer %9.0f
    else local integer %9.0g

//two-way table options
    if "`by'"=="" {
        foreach X in row column cell rcolumn rcell wrap chi2 ///
         lrchi2 warn mtest mtest2 mlrchi2 {
            if "``X''"!="" {
                di as error "option ``X'' not allowed"
                exit 198
            }
        }
        local nby 1
    }
    else {
        if "`chi2'`lrchi2'"=="" & "`warn'"!="" {
            di as err "option 'warn' only allowed with 'chi2' or 'lrchi2'"
            exit 198
        }
    }

//suppress frequencies table
    local table="`freq'"==""|"`row'"!=""|"`column'"!=""|"`cell'"!="" ///
     |"`rcolumn'"!=""|"`rcell'"!=""

//significance tests options
    else if "`weight'"=="aweight"|`countall' {
        foreach X in chi2 lrchi2 mtest mtest2 mlrchi2 {
            if "``X''"!="" {
                di as error "option ``X'' not allowed"
                exit 198
            }
        }
    }
    if "`mlrchi2'"!=""&"`mtest'"==""&"`mtest2'"=="" {
        di as error "option mlrchi2 not allowed"
        exit 198
    }
    if "`mtest'"!=""|"`mtest2'"!="" {
        if "`mlrchi2'"=="" local mchi2 ch
        else {
            local mchi2 lr
            local mlrchi2 _lr
        }
        _mtest syntax, `mtest2' `mtest'
        local mtest `r(method)'
    }

//label options
    if `"`title'"'!="" local name `"`title'"'
    if "`by'"!="" local bylabel="`label'"==""
    if `strvars' local label 1
    else {
        if "`label'"!="" local label 0
        else {
            local label 0
            foreach var of local varlist {
                if `poly' {
                    local tmp: val l `var'
                }
                else {
                    local tmp: var l `var'
                }
                if `"`tmp'"'!="" {
                    local label 1
                    continue, break
                }
            }
        }
    }
    if `label'==0&"`names'"!="" {
        di as error "option nonames not allowed"
        exit 198
    }
    local names="`names'"==""&!`strvars'

//sort options
    if "`sort'"!=""|"`sort2'"!="" {
        if "`descending'"=="" local sort "<"
        else local sort ">"
    }

//MARK SAMPLE
    marksample touse, nov
    if "`by'"!="" markout `touse' `by', strok
    qui count if `touse'
    if r(N) == 0 error 2000

//PREPARE RESPONSE LIST
    if "`response'"==""&!`poly' local response 1
    if `poly' {
        foreach var of local varlist {
            if "`condition'"!="" {
                local temp3: subinstr local condition "@" "`var'", all
            }
            else local temp3 1
            qui levels `var' if `touse' & `temp3', l(temp)
            local temp2: list temp2 | temp
        }
        if "`response'"=="" {
            local response `"`temp2'"'
            if `strvars' local response: list sort response
            else {
                capture {
                    numlist "`response'", sort
                    local response "`r(numlist)'"
                }
            }
            if `"`response'"'=="" {
                di as error "no responses"
                exit 2000
            }
        }
        else {
            local temp: list response & temp2
            if `"`temp'"'!="" {
                local responses `"`temp'"'
            }
        }
    }

//GENERATE RESPONSE ITEMS
//if dichotomous (approach 1)
    if !`poly' {
        local noi: word count `varlist'
        if "`condition'"=="" {
            local condition "@ `response'"
            local condition: list retok condition
            local condition: subinstr local condition " " ",", all
            local condition "inlist(`condition')"
        }
        tokenize `varlist'
        forv i=1/`noi' {
            local temp: subinstr local condition "@" "``i''", all
            tempvar item`i'
            if `countall' {
                qui gen `item`i'' = cond( ( `temp' ), ``i'', 0) if ``i''<. & `touse'
            }
            else {
                qui gen byte `item`i'' = ( `temp' ) if ``i''<. & `touse'
            }
            local itemlist `"`itemlist'`item`i'' "'
            local tmp: var l ``i''
            if `"`tmp'"'=="" local tmp `"``i''"'
            qui lab var `item`i'' `"`tmp'"'
        }
    }

//if polytomous (approach 2)
    if `poly' {
        local noi: word count `response'
        forv i=1/`noi' {
            tempvar item`i'
            local itemlist `"`itemlist'`item`i'' "'
        }
        Make_polyitems `"`varlist'"' `"`response'"' `"`itemlist'"' ///
         `noi' `strvars' `countall' `touse'
    }

//COUNT TOTALS / PREPARE BY-GROUPS
//generarte summing variable
    tempvar sum
    qui gen `sum'=. if `touse'
    foreach item of local itemlist {
        qui replace `sum'=`sum'+`item' if `touse'&`item'<.&`sum'<.
        qui replace `sum'=`item' if `touse'&`item'<.&`sum'>=.
    }

//case selection (include, includemissing, casewise)
    if "`include'"=="" {
        qui replace `sum'=. if `touse'&`sum'==0
    }
    if "`casewise'"!="" {
        foreach var of local varlist {
            if `strvars' {
                qui replace `sum'=. if `touse'&`var'==""
            }
            else {
                qui replace `sum'=. if `touse'&`var'>=.
            }
        }
    }
    foreach item of local itemlist {
        qui replace `item'=. if `touse'&`sum'>=.
    }
    if "`includemissing'"!="" {
        qui replace `sum'=0 if `touse'&`sum'>=.
    }
    foreach item of local itemlist {
        qui replace `item'=0 if `touse'&`sum'==0
    }

//count missing cases and remove them
    tempname nomc
    if "`weight'"=="fweight" {
        su `=substr("`exp'", 3,.)' if `touse'&`sum'>=.,mean
        scalar `nomc'=r(sum)
    }
    else {
        qui count if `touse'&`sum'>=.
        scalar `nomc'=r(N)
    }
    markout `touse' `sum'
    qui count if `touse'
    if r(N)==0 error 2000

//prepare by-groups
    if "`by'"!="" {
        qui ta `by' if `touse'
        local nby=r(r)
        local inby "in \`by1'/\`by2'"
        local strby=substr("`: type `by''",1,3)=="str"
    }

//count total number of responses/valid cases
    tempname nowr novc nowvc nor
    qui su `sum' [`weight'`exp'] if `touse', mean
    scalar `nowr'=r(sum)
    scalar `novc'=r(N)
    scalar `nowvc'=r(sum_w)
    scalar `nor'=`nowr'*`novc'/`nowvc'

//COUNT RESPONSES (CELLS)
    tempname H novcby
    if `nby'>1 {
        gsort -`touse' `by'
        local by2 0
    }
    forv iby=1/`nby' {
        if `nby'>1 {
            local by1=`by2'+1
            qui count if `by'==`by'[`by1']&`touse'
            local by2=`by1'+r(N)-1
            if `strby' {
                local bylbls `"`bylbls'`"`=`by'[`by1']'"' "'
            }
            else {
                local Bys `"`Bys'`=`by'[`by1']' "'
                local bylbls `"`bylbls'`"`: lab (`by') `=`by'[`by1']''"' "'
            }
            qui su `sum' [`weight'`exp'] `inby' if `touse', mean
            mat `novcby'=nullmat(`novcby'),r(sum_w)*`novc'/`nowvc'
        }
        mat `H'=nullmat(`H'),J(`noi',1,0)
        local i=1
        foreach item of local itemlist {
            qui su `item' [`weight'`exp'] `inby' if `touse', mean
            mat `H'[`i',`iby']=r(sum)*`novc'/`nowvc'
            local i=`i'+1
        }
    }
    mat `H'=`H'\J(1,rowsof(`H'),1)*`H'
    if `nby'>1 {
        mat `H'=`H',`H'*J(colsof(`H'),1,1)
        mat `novcby'=`novcby',`novcby'*J(colsof(`novcby'),1,1)
    }

//PERFORM MULTIPLE TESTS
    if "`mtest'"!="" {
        tempname M
        Mulipletest `H' `novcby' `noi' `nby' `M' `"`mtest'"' ///
         "`mchi2'" "`mlrchi2'"
        local df=`nby'-1
    }

//DISPLAY: PREPARATIONS
    if `table' {

//sort in descending/ascending order of frequency
        forv i=1/`noi' {
            local slist "`slist'`i' "
        }
        if "`sort'"!="" {
            if "`sort2'"=="" local sort2=colsof(`H')
            Sort `H' `sort' `sort2' `noi' "`slist'"
        }

//determine cell width
        local rwidth 11
        if "`format'"!="%9.2f" {
            local temp: di `format' 1
            local rwidth=max(`rwidth',`:length local temp')
        }

//determine maximum width of label
        if `label' {
            local maxlbl 2
            foreach item of local itemlist {
                local temp: var l `item'
                local maxlbl=max(`maxlbl',`:length local temp')
            }
        }

//determine width of names/values
        if `poly'&`names' {
            local nwidth 1
            forv i=1/`noi' {
                local temp: word `i' of `response'
                local nwidth=max(`nwidth',`:length local temp')
            }
            local nwidth=`nwidth'+1
        }
        if !`poly'&`names' {
            local nwidth 1
            forv i=1/`noi' {
                local temp: word `i' of `varlist'
                local nwidth=max(`nwidth',`:length local temp')
            }
            local nwidth=min(`nwidth',12)
        }

//determine width of labeling column
        if `label' {
            local width=min(`maxlbl',`width')
            if `names' {
                local lwidth=`nwidth'+1+`width'
                if `lwidth'<11 {
                    local width=`width'+11-`lwidth'
                    local lwidth 11
                }
            }
            else {
                if `width'<11 local width 11
                local lwidth `width'
            }
        }
        else {
            if `nwidth'<11 local nwidth 11
            local lwidth `nwidth'
        }

//determine n. of lines of caption
        local j 1
        local temp: piece `j' `lwidth' of `"`name'"'
        while `"`temp'"'!="" {
            local j=`j'+1
            local temp: piece `j' `lwidth' of `"`name'"'
        }
        local nlines=`j'-1

//DISPLAY ONE-WAY TABLE
        if "`by'"=="" {
            di

//head
            local tlines=max(`nlines',2)
            forv j=1/`tlines' {
                local nj=`nlines'-`tlines'+`j'
                if `nj'>0 {
                    local temp: piece `nj' `lwidth' of `"`name'"'
                    di as txt %`lwidth's `"`temp'"' _c
                }
                else di as txt %`lwidth's " " _c
                if `tlines'-`j'==1 di " {c |}" _skip(11) " " %`rwidth's "Percent of" " " ///
                 %`rwidth's "Percent"
                else if `tlines'-`j'==0 di " {c |}" %11s "Frequency" " " %`rwidth's "responses" ///
                 " " %`rwidth's "of cases"
                else di " {c |} "
            }
            di as txt "{hline `lwidth'}{hline 1}{c +}{hline 11}" ///
             "{hline 1}{hline `rwidth'}{hline 1}{hline `rwidth'}"

//body
            foreach i of local slist {
                local item: word `i' of `itemlist'
                if `poly'&`names' di as txt %`nwidth's "`:word `i' of `response''" " " _c
                if !`poly'&`names' di as txt %`nwidth's abbrev("`:word `i' of `varlist''",`nwidth') " " _c
                if `label' {
                    if "`abbrev'"=="" {
                        local temp: piece 1 `width' of `"`: var l `item''"'
                    }
                    else {
                        local temp=substr(`"`: var l `item''"',1,`width')
                    }
                    di as txt %`width's `"`temp'"' " " _c
                }
                di "{c |}" as result %11s "`:di `integer' `H'[`i',1]'" " " ///
                 %`rwidth's "`: di `format' `H'[`i',1]/`nor'*100'" ///
                 " " %`rwidth's "`: di `format' `H'[`i',1]/`novc'*100'"
                if `label' & "`abbrev'"=="" {
                    local j 2
                    local temp: piece `j' `width' of `"`: var l `item''"'
                    while `"`temp'"'!="" {
                        if `names' di _skip(`nwidth') " " _c
                        di as txt %`width's `"`temp'"' " {c |}"
                        local j=`j'+1
                        local temp: piece `j' `width' of `"`: var l `item''"'
                    }
                }
            }

//foot
            di as txt "{hline `lwidth'}{hline 1}{c +}{hline 11}" ///
             "{hline 1}{hline `rwidth'}{hline 1}{hline `rwidth'}"
            di as txt %`lwidth's "Total" " {c |}" as result %11s ///
             "`:di `integer' `H'[rowsof(`H'),1]'" " " ///
             %`rwidth's "`: di `format' `H'[rowsof(`H'),1]/`nor'*100'" ///
             " " %`rwidth's "`: di `format' `H'[rowsof(`H'),1]/`novc'*100'"
            di
        }

//DISPLAY TWO-WAY TABLE
        else {

//key table/prepare cells statistics
            local freq=cond("`freq'"=="","freq","")
            local keywidth 0
            foreach cs in freq row column cell rcolumn rcell {
                if "``cs''"!="" {
                    local clist `"`=trim("`clist' `cs'")'"'
                    if "`cs'"=="freq" {
                        local `cs'name "frequency of responses"
                        local `cs'denom 1
                    }
                    else if "`cs'"=="row" {
                        local `cs'name "row percent of responses"
                        local `cs'denom "\`H'[\`j',colsof(\`H')]*100"
                    }
                    else if "`cs'"=="column" {
                        local `cs'name "column percent of cases"
                        local `cs'denom "\`novcby'[1,\`i']*100"
                    }
                    else if "`cs'"=="cell" {
                        local `cs'name "cell percent of cases"
                        local `cs'denom "\`novc'*100"
                    }
                    else if "`cs'"=="rcolumn" {
                        local `cs'name "column percent of responses"
                        local `cs'denom "\`H'[rowsof(\`H'),\`i']*100"
                    }
                    else if "`cs'"=="rcell" {
                        local `cs'name "cell percent of responses"
                        local `cs'denom "\`nor'*100"
                    }
                    local keywidth=max(`keywidth',`:length  local `cs'name')
                }
            }
            local rlines: word count `clist'
            if `rlines'>1 {
                di
                di as txt "{c TLC}{hline 1}{hline `keywidth'}{hline 1}{c TRC}"
                di "{c |} " %-`keywidth's "Key" " {c |}"
                di as txt "{c LT}{hline 1}{hline `keywidth'}{hline 1}{c RT}"
                foreach cs of local clist {
                    di "{c |} " `"{it:`: di %~`keywidth's "``cs'name'"'}"' " {c |}"
                }
                di as txt "{c BLC}{hline 1}{hline `keywidth'}{hline 1}{c BRC}"
            }

//prepare table-splits
            local nres=colsof(`H')
            local chiwd=10*("`mchi2'"!="")
            if "`wrap'"=="" local maxr=floor((`:set linesize'-`lwidth'-3-`chiwd')/(`rwidth'+1))
            else local maxr `nres'

//iteration over table-splits
            local r1 1
            local r2 0
            while `r1'<=`nres' {
                di
                if `maxr'<=1 local r2 `r1'
                else if `maxr'>=`nres'-`r2' local r2 `nres'
                else if `maxr'<`nres'-`r2' local r2=`r1'+`maxr'-1
                local ncol=`r2'-`r1'+1

//first head
                if `r1'==1 {
                    if `bylabel'&`"`:var l `by''"'!="" local bynme: var l `by'
                    else local bynme "`by'"
                    local bynmespace=(`ncol'-(`r2'==`nres'))*(`rwidth'+1)
                    local j 1
                    local temp: piece `j' `bynmespace' of `"`bynme'"'
                    while `"`temp'"'!="" {
                        local j=`j'+1
                        local temp: piece `j' `bynmespace' of `"`bynme'"'
                    }
                    local blines=`j'-1
                    local tlines=max(`nlines',`blines'+1)
                    forv j=1/`tlines' {
                        local jn=`j'-`tlines'+`nlines'
                        if `jn'>0 {
                            local temp: piece `jn' `lwidth' of `"`name'"'
                            di as txt %`lwidth's `"`temp'"' " {c |}" _c
                        }
                        else di as txt %`lwidth's " " " {c |}" _c
                        local jb=`j'-`tlines'+`blines'+1
                        if `jb'>0&`j'!=`tlines' {
                            local temp: piece `jb' `bynmespace' of `"`bynme'"'
                            di as txt %~`bynmespace's `"`temp'"'
                        }
                        else if `j'!=`tlines' di as txt " "
                        if `j'==`tlines'{
                            forv i=1/`r2' {
                                if `i'==`nres' {
                                    di "{c |}" %`rwidth's "Total" _c
                                    if "`mtest'"!="" di %10s "chi2/p*"
                                    else di
                                }
                                else {
                                    if `bylabel'|`strby' {
                                        local temp: word `i' of `bylbls'
                                    }
                                    else local temp: word `i' of `Bys'
                                    if `i'<`r2' di %`rwidth's substr(`"`temp'"',1,`rwidth'-1) " " _c
                                    else di %`rwidth's substr(`"`temp'"',1,`rwidth'-1)
                                }
                            }
                        }
                    }
                }

//consecutive heads
                else {
                    di as txt %`lwidth's " " " {c |}" _c
                    forv i=`r1'/`r2' {
                        if `i'==`nres' {
                            di "{c |}" %`rwidth's "Total" _c
                            if "`mtest'"!="" di %10s "chi2\p*"
                            else di
                        }
                        else {
                            if `bylabel'|`strby' {
                                local temp: word `i' of `bylbls'
                            }
                            else local temp: word `i' of `Bys'
                            if `i'<`r2' di %`rwidth's substr(`"`temp'"',1,`rwidth'-1) " " _c
                            else di %`rwidth's substr(`"`temp'"',1,`rwidth'-1)
                        }
                    }
                }
                di "{hline `lwidth'}{hline 1}{c +}" _c
                forv i=`r1'/`r2' {
                    if `i'==`nres' di "{c +}{hline `rwidth'}"
                    else if `i'<`r2' di "{hline `rwidth'}{hline 1}" _c
                    else di "{hline `rwidth'}{hline 1}"
                }

//body
                foreach j of local slist {
                    local item: word `j' of `itemlist'
                    local lblln 1
                    local ichi 1
                    foreach cs of local clist {
                        if `poly'&`names'&`lblln'==1 di as txt %`nwidth's ///
                         "`:word `j' of `response''" " " _c
                        if !`poly'&`names'&`lblln'==1 di as txt %`nwidth's ///
                         abbrev("`:word `j' of `varlist''",`nwidth') " " _c
                        if `names'&`lblln'>1 di as txt _skip(`nwidth') " " _c
                        if `label' {
                            if "`abbrev'"=="" {
                                local temp: piece `lblln' `width' of `"`: var l `item''"'
                            }
                            else if `lblln'==1 {
                                local temp=substr(`"`: var l `item''"',1,`width')
                            }
                            else local temp
                            di as txt %`width's `"`temp'"' " " _c
                        }
                        di "{c |}" _c
                        local lblln=`lblln'+1
                        if "`cs'"=="freq" local fmt "`integer'"
                        else local fmt "`format'"
                        forv i=`r1'/`r2' {
                            if `i'==`nres' di as txt "{c |}" _c
                            di as result %`rwidth's "`: di `fmt' `H'[`j',`i']/``cs'denom''" " " _c
                            if `i'==`nres'&"`mtest'"!=""&`ichi'<=2 {
                                di as result %9s "`: di %9.3f `M'[`j',`ichi']'" _c
                            }
                            if `i'==`r2' di
                        }
                        local ichi=`ichi'+1
                    }
                    if `label' & "`abbrev'"=="" {
                        local temp: piece `lblln' `width' of `"`: var l `item''"'
                        while `"`temp'"'!="" {
                            if `names' di _skip(`nwidth') " " _c
                            di as txt %`width's `"`temp'"' " " _c
                            di "{c |}" _c
                            if `r2'==`nres' {
                                di _skip(`=(`ncol'-1)*(`rwidth'+1)') "{c |}" _c
                                if `ichi'==2&"`mtest'"!="" {
                                    di _skip(`rwidth') " " as result %9s "`: di %9.3f `M'[`j',`ichi']'" _c
                                }
                            }
                            di
                            local lblln=`lblln'+1
                            local ichi=`ichi'+1
                            local temp: piece `lblln' `width' of `"`: var l `item''"'
                        }
                    }
                    if `r2'==`nres'&`ichi'==2&"`mtest'"!="" {
                        di _skip(`lwidth') as txt " {c |}" _skip(`=(`ncol'-1)*(`rwidth'+1)') "{c |}" ///
                          _skip(`rwidth') " " as result %9s "`: di %9.3f `M'[`j',`ichi']'"
                        local ichi=`ichi'+1
                    }
                    if (`rlines'>1|"`mtest'"!="")&`j'!=`: word `noi' of `slist'' {
                        di as txt "{hline `lwidth'}{hline 1}{c +}" _c
                        forv i=`r1'/`r2' {
                            if `i'==`nres' di "{c +}{hline `rwidth'}"
                            else if `i'<`r2' di "{hline `rwidth'}{hline 1}" _c
                            else di "{hline `rwidth'}{hline 1}"
                        }
                    }
                }
                di as txt "{hline `lwidth'}{hline 1}{c +}" _c
                forv i=`r1'/`r2' {
                    if `i'==`nres' di "{c +}{hline `rwidth'}"
                    else if `i'<`r2' di "{hline `rwidth'}{hline 1}" _c
                    else di "{hline `rwidth'}{hline 1}"
                }

//foot
                di as txt %`lwidth's "Total" " {c |}" _c
                local lblln 0
                local j=rowsof(`H')
                foreach cs of local clist {
                    if `lblln' di as txt %`lwidth's " " " {c |}" _c
                    local lblln 1
                    if "`cs'"=="freq" local fmt "`integer'"
                    else local fmt "`format'"
                    forv i=`r1'/`r2' {
                        if `i'==`nres' di as txt "{c |}" _c
                        di as result %`rwidth's "`: di `fmt' `H'[`j',`i']/``cs'denom''" " " _c
                        if `i'==`r2' di
                    }
                }
                if "`freq'"!="" {
                    di as txt %`lwidth's "Cases" " {c |}" _c
                    forv i=`r1'/`r2' {
                        if `i'==`nres' di as txt "{c |}" _c
                        di as result %`rwidth's "`: di `integer' `novcby'[1,`i']'" " " _c
                        if `i'==`r2' di
                    }
                }
                di
                local r1=`r2'+1
            }
            if "`mtest'"!="" {
                if "`mlrchi2'"=="" local chitype Pearson
                else local chitype likelihood-ratio
                di as txt "* {it:`chitype' chi2(`df') / }" _c
                _mtest footer 1 `mtest'
                di
            }
        }
        di as txt "Valid cases:  " %9.0g `novc'
        di as txt "Missing cases:" %9.0g `nomc'
    }

//CONDUCT/DISPLAY OVERALL SIGNIFICANCE TESTS
    if "`chi2'"!=""|"`lrchi2'"!="" {
        local i 1
        foreach item of local itemlist {
            if `i++'==1 local temp "string(`item')"
            else local temp "`temp'+string(`item')"
        }
        tempvar pattern
        qui gen `pattern'=`temp' if `touse'&`sum'<.
        if `"`warn'"'!="" {
            tempname CELL ROW COL
            local matopt matcell(`CELL')
        }
        di
        di as txt "Overall Test(s) of Significance:"
        ta `pattern' `by' [`weight'`exp'] if `touse'&`sum'<., `chi2' `lrchi2' `matopt' nofreq
        if `"`warn'"'!="" {
            matrix `ROW' = J(`r(r)', 1, 0)
            matrix `COL' = J(1, `r(c)', 0)
            forv i = 1/`r(r)' {
                forv j = 1/`r(c)' {
                    matrix `ROW'[`i',1] = `ROW'[`i',1] + `CELL'[`i',`j']
                    matrix `COL'[1,`j'] = `COL'[1,`j'] + `CELL'[`i',`j']
                }
            }
            local expect5 = 0
            local expect1 = 0
            forv i = 1/`r(r)' {
                forv j = 1/`r(c)' {
                    mat `CELL'[`i', `j'] = (`ROW'[`i',1] * `COL'[1,`j']) / r(N)
                    if `CELL'[`i', `j']<1 local expect1 = `expect1' + 1
                    if `CELL'[`i', `j']<5 local expect5 = `expect5' + 1
                }
            }
            local expect5 = `expect5' / (r(r) * r(c)) * 100
            local warn = `expect5'>20 | `expect1'!=0
            if `warn' {
                di ""
                di as txt "  Warning: " as res `expect5' _c
                di as txt " percent of cells have expected frequency < 5"
                di as txt "           " as res `expect1' _c
                di as txt " cells have expected frequency < 1"
            }
            ret sca warn = `warn'
            ret sca expect1 = `expect1'
            ret sca expect5 = `expect5'
        }
        ret sca df=(`r(r)'-1)*(`r(c)'-1)
        ret add
    }

//RETURNS
    mat `H'=`H'[1..`noi',1..`nby']
    if "`by'"!="" mat `novcby'=`novcby'[1,1..`nby']
    if `poly'&!`strvars' {
        mat rown `H'=`response'
        if "`mtest'"!="" mat rown `M'=`response'
    }
    if !`poly' {
        mat rown `H'=`varlist'
        if "`mtest'"!="" mat rown `M'=`varlist'
    }
    if `nby'>1 {
        mat coln `H'=`Bys'
        mat coln `novcby'=`Bys'
        mat rown `novcby'=`by'
        ret sca c=`nby'
        if `strby' ret local bytype string
        else ret local bytype numeric
        if `strby'|`"`:val l `by''"'!="" {
            local bylbls: list clean bylbls
            ret local bylist `"`bylbls'"'
        }
    }
    ret sca r=`noi'
    ret sca N_miss=`nomc'
    ret sca N=`novc'
    if "`mtest'"!="" ret mat mchi2`mlrchi2' `M'
    if `nby'>1 ret mat cases `novcby'
    ret mat responses `H'
    if `poly' ret local mode poly
    else ret local indicator
    if `strvars' ret local type string
    else ret local type numeric
    if !`strvars' {
        local temp
        foreach item of local itemlist {
            local temp `"`temp' `"`:var lab `item''"'"'
        }
        local temp: list clean temp
    }
    if `strvars' local temp: list clean response
    ret local list `"`temp'"'

//RETURN ITEMS AS VARIABLES
    if _bylastcall()&"`generate'"!="" {
        local temp=trim(substr(`"`name'"',1,8))
        local i 1
        foreach item of local itemlist {
            if `"`temp'"'!="" qui lab var `item' `"`temp': `:var lab `item''"'
            ren `item' `generate'`i'
            local i=`i'+1
        }
        if "`chi2'"!=""|"`lrchi2'"!="" {
            ren `pattern' `generate'rp
            if `"`temp'"'!="" local temp `"`temp': "'
            qui lab var `generate'rp `"`temp'response pattern"'
        }
    }
end

program define Make_polyitems
    args varlist response itemlist noi strvars countall touse
    tokenize `varlist'
    local first 1
    while "`1'"!="" {
        forv i=1/`noi' {
            local temp: word `i' of `response'
            local item: word `i' of `itemlist'
            if `strvars' {
                if `first' {
                    qui gen byte `item'=`"`temp'"'==`1' if `touse'
                    qui lab var `item' `"`temp'"'
                }
                else {
                    if `countall' qui replace `item'=match(`"`temp'"',`1') ///
                     + cond(`item'<.,`item',0) if `touse'
                    else qui replace `item'=`"`temp'"'==`1' if `touse'&`item'!=1
                }
            }
            else {
                if `first' {
                    qui gen byte `item'=`1'==`temp' if `1'<.&`touse'
                    qui lab var `item' `"`:lab (`1') `temp''"'
                }
                else {
                    if `countall' qui replace `item'=cond(`item'<.,`item',0) ///
                     +(`1'==`temp') if `1'<.&`touse'
                    else qui replace `item'=`1'==`temp' if `1'<.&`touse'&`item'!=1
                }
            }
        }
        local first 0
        macro shift
    }
end

program define Mulipletest
    args H novcby noi nby M mtest mchi2 mlrchi2
    forv i=1/`noi' {
        local freqir1 ""
        local freqir2 ""
        forv j=1/`nby' {
            local freqir1 "`freqir1'`=`H'[`i',`j']' "
            local freqir2 "`freqir2'`=`novcby'[1,`j']-`H'[`i',`j']' "
        }
        qui tabi `freqir1' \ `freqir2', `mchi2' nofreq
        mat `M'=nullmat(`M') \ (r(chi2`mlrchi2'),r(p`mlrchi2'))
    }
    mat coln `M'=chi2 p
    _mtest adjust `M', mtest(`mtest') pindex(2) replace
    mat `M'=r(result)
end

program define Sort
    args H sort sort2 noi nlist
    forv i=1/`noi' {
        local k 1
        foreach j of local nlist {
            if `k++'==1 {
                local temp `j'
                local temp2 `H'[`j',`sort2']
            }
            else {
                if `H'[`j',`sort2']`sort'`temp2' {
                    local temp `j'
                    local temp2 `H'[`j',`sort2']
                }
            }
        }
        local slist "`slist'`temp' "
        local nlist: list nlist - temp
    }
    c_local slist "`slist'"
end
