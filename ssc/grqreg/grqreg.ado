*! version 2.1  (17 March 2011) Joao Pedro Azevedo
* incorporate Scott Merryman suggestion for wordcount
* fix bsqreg and sqreg options
* add functions: seed, reps, list, format
*! version 2.0  (10 March 2010) Joao Pedro Azevedo
* support to sbqreg
* version 1.8  (16 December 2005) Joao Pedro Azevedo
* including weights [`weight' `exp']
* version 1.7  (13 October 2005)  Joao Pedro Azevedo
* clean
* rclass
* compare
* version 1.6  (16 February 2005)  Joao Pedro Azevedo
* include save dataset option
* fix bug with OLS [_olsci]
* version 1.5  (10 February 2005)  Joao Pedro Azevedo
* correct figure title (10/02/2005)
* version 1.4  (16 April 2004)
* correct mfx confidence interval error (16/04/2004)
* include mfx
* version 1.3  (31 March 2004)
* include title option
* include nodraw option
* fixed bug with the incopatible characters in the variable name (, and == are now replaced)
* version 1.2  (01 February 2004)
* include bsqreg and sqreg
* include a label for the intercept
* use var name is var label is empty
* version 1.1  (22 January 2004)
* use var labels on the graps
* version 1.05 (19 January 2004)
* NJC 18 January 2004
* version 0.5 (13 January 2004)

program grqreg, rclass

    version 8.2

    syntax [varlist]                ///
        [fweight aweight]           ///
        [,                          ///
        qmin(real .05)              ///
        qmax(real .95)              ///
        qstep(real .05)             ///
        quantile(string)            ///
        level(integer $S_level)     ///
        cons                        ///
        ci                          ///
        ols                         ///
        olsci                       ///
        compare                     ///
        title(string)               ///
        nodraw                      ///
        mfx(string)                 ///
        saving(str)                 ///
        save(str)                   ///
        seed(str)                   ///
        list                        ///
        reps(int 20)                ///
        format(string)              ///
        *                           ///
        ]

    tempvar sample tmp

    tempname b coef testn x

    *-> set seed

    if ("`seed'" == "") & (("`e(cmd)'" == "bsqreg") | ("`e(cmd)'" == "sqreg")) {
        di _n as res "std error of grqreg will not be the same as one reported after estimation. Please use the seed option of grqreg."
    }
    if ("`seed'" != "") & (("`e(cmd)'" == "bsqreg") | ("`e(cmd)'" == "sqreg"))  {
        local seed1 = `seed'
    }
    else {
        local seed1 `c(seed)'
    }

    *-> format

    if ("`format'" == "") {
        local format "%9.2f"
    }

    *-> confirm qreg or bsqreg or sqreg

    if ("`e(cmd)'" != "qreg") & ("`e(cmd)'" != "bsqreg") & ("`e(cmd)'" != "sqreg") {
        di _n as res "grqreg" as err " only works after " ///
        as res "qreg " as err "or " as res " bsqreg " as err " or " as res " sqreg"
        exit 498
    }

    *-> if mfx if selectd after sqreg

    if ("`mfx'" != "") & ("`e(cmd)'" == "sqreg") {
        di _n as res "The MFX option is not supported after sqreg"
        exit 498
    }

    *-> make sure that is sqreg is run, quantiles is specified

    if ("`e(cmd)'" == "sqreg") {
        loc quantile = subinstr("`e(eqnames)'", "q", ".", .)
        if ("`xlabel'" == "") {
            loc xlabel " xlabel(`quantile') "
        }
    }

    if ("`e(cmd)'" == "sqreg") {
        if ("`quantile'" == "") {
            di as res "Quantiles have to specified after sqreg"
            exit 498
        }
        else {
            di as res "Only coefficients "`quantile' " will be plotted."
        }
    }


    *-> get comand from last regression

    local cmd = e(cmd)

    *-> get dependent variable from last qreg | bsqreg | sqreg

    local depvar = e(depvar)

    *-> get regressors from last qreg | bsqreg | sqreg

    if ("`quantile'" != "") & ("`e(cmd)'" == "sqreg") {

        matrix `coef' = e(b)
        local cols = colsof(`coef')
        local regs = `cols' / (e(k_cat) - 1)
        matrix `b' = `coef'[1, 1..`regs']
        local rhs : colnames(`b')

		loc tmp0 : word count `e(eqnames)'
        loc tmp1 : word count `rhs'
        loc tmp2 = (`tmp1'/`tmp0') - 1
        forvalues i = 1(1)`tmp2' {
            loc rhs0  = word("`rhs'",`i')
            loc rhs1 "`rhs1' `rhs0'"
        }
        loc rhs  "`rhs1'"
    }
    else {
        matrix `coef' = e(b)
        local cols = colsof(`coef')
        local regs = `cols' / (e(k_cat) - 1)
        matrix `b' = `coef'[1, 1..`regs']
        local rhs : colnames(`b')
        local rhs : subinstr local rhs "_cons" ""
    }

    *-> get variable list (if blank, graphlist == regression varlist)

    if "`varlist'" != "" local graphvars "`varlist'"

    if wordcount("`rhs'") <= wordcount("`varlist'") local graphvars "`rhs'"


    if "`compare'" != "" {

        local nrhs = wordcount("`varlist'")

        if `nrhs' != 2 {

        di as err "option compare only works with 2 variables"
        exit 198

        }

    }

    *-> variables for _bsqregtrace, _qregtrace, sqreg or _olsci

    local regvars "`graphvars'"

    *-> get weight info from last qreg

    if "`e(wtype)'" != "" {
        local wtis "[`e(wtype)'`e(wexp)']"
        local wexp2 "`e(wexp)'"
    }

    *-> check that estimation sample matches n from regression

    quietly {
        generate `sample' = e(sample)

        if "`e(wtype)'" == "" | "`e(wtype)'" == "aweight" /*
            */ | "`e(wtype)'" == "pweight" {
            count if `sample'
            scalar `testn' = r(N)
        }
        else if "`e(wtype)'" == "fweight" | /*
            */ "`e(wtype)'" == "iweight" {
            local wtexp = substr("`e(wexp)'", 3, .)
            gen `tmp' = (`wtexp') * `sample'
            su `tmp', meanonly
            scalar `testn' = round(r(sum),1)
        }
    }

    if e(N) != `testn' {
        di  _n as err "data has been altered since " ///
            as res "qreg" as err " was estimated"
        exit 459
    }

    if (wordcount("`title'")!=0) & "`cons'"=="" & (wordcount("`graphvars'")!=wordcount("`title'")){
        di as err "Number of titles different from number of variables"
        exit 459
    }

    if ("`mfx'"!="") {
        if "`cons'" != "" local graphvars "`graphvars'"
        local cmdmfx "mfx(`mfx')"
    }

    if ("`mfx'"=="") {
        if "`cons'" != "" local graphvars "cons `graphvars'"
        local cmdmfx ""
    }

    *-> generate betas for different quantiles

    preserve

    tempfile temp olstemp

    if ("`cmd'" == "qreg") {
        _qregtrace [`weight' `exp'], qmin(`qmin') qmax(`qmax') qstep(`qstep') ///
        level(`level') saving(`temp') `cmdmfx'
    }

    if ("`cmd'"=="bsqreg") {
        _bsqregtrace [`weight' `exp'], qmin(`qmin') qmax(`qmax') qstep(`qstep') ///
        level(`level') saving(`temp')  `cmdmfx' seed(`seed1') reps(`reps')
    }

    if ("`cmd'"=="sqreg") {
        _sqregtrace [`weight' `exp'], quantile(`quantile') ///
        level(`level') saving(`temp')  `cmdmfx' seed(`seed1')  reps(`reps')
    }

    if ("`ols'" != "") | ("`olsci'" != "") {

    _olsci [`weight' `exp'], qmin(`qmin') qmax(`qmax') qstep(`qstep') level(`level') ///
    saving(`"`olstemp'"')  `cmdmfx'

        quietly {
            use `"`olstemp'"', clear

            sort qtile
            save, replace

            use `temp', clear
            sort qtile
            merge using `olstemp'
        }
    }

    if ("`ols'" == "") & ("`olsci'" == "") {
        use `temp', clear
    }

    *-> generate graphs for each coeficient;

    #delimit ;

    local graphlist "";

    local name_final "qtile  ";

    if ("`compare'" == "") {;

        local i=1;

        foreach name of varlist `graphvars' {;

            format  *`name'*  `format';

            local graphname graph_`name';
            local varlab: variable label `name';

            if ("`varlab'"=="") {;
                local varlab `name';
            };

            local varlab=subinstr("`varlab'",",","_",.);
            local varlab=subinstr("`varlab'","==","=",.);

            if ("`title'" != "") {;
                local tname=word("`title'",`i');
            };

            if ("`ci'" != "") { ;
                local cicmd "( rarea `name'_cihi `name'_cilo qtile,
                bcolor(gs13) legend(off))" ;
                local name_ci " `name'_cihi `name'_cilo";
            } ;

            if ("`ols'" != "") { ;
                local olscmd "( scatter ols_`name' qtile, c(l) clpattern(dash)
                clcolor(black)  legend(off) msize(vtiny) )" ;
                local name_ols " ols_`name'";
            } ;

            if ("`olsci'" != "") { ;
                local olscicmd "( scatter ols_`name'_cihi ols_`name'_cilo qtile,
                c(l l)  clpattern(dot dot) clcolor(black black)
                legend(off) msize(vtiny vtiny) )" ;
                local name_olsci " ols_`name'_cihi ols_`name'_cilo ";
            };

            graph twoway `cicmd' `olscmd' `olscicmd' (line `name' qtile,
                    legend(off)
                    msize(tiny)
                    clwidth(medthick)
                    title(`tname')
                    ytitle(`varlab')
                    xtitle(Quantile)
                    nodraw
                    name(`graphname', replace) `xlabel');

            local graphlist "`graphlist' `graphname'";

            local name_coef " `name' ";

            local name_tmp "`name_coef' `name_ci' `name_ols' `name_olsci'";

            local name_final "`name_final' `name_tmp'";

            local i=1+`i';

        };

        *-> combine all graphs;

        if ("`nodraw'"=="nodraw") {;
            graph combine `graphlist', nodraw `options';
        };

        if ("`nodraw'"=="") {;
            graph combine `graphlist', `options';
        };

    };

    if ("`compare'" != "") {;

       local i=1;

       foreach name of varlist `graphvars' {;

            format  *`name'*  `format';

            local varlab`i': variable label `name';

            if ("`varlab`i''"=="") {;
                local varlab`i' `name';
            };

            local varlab`i' = subinstr("`varlab`i''",",","_",.);
            local varlab`i' = subinstr("`varlab`i''","==","=",.);

            local name`i' "`name'";

            local i=1+`i';

       };

        graph twoway (line `name1' `name2',
                legend(off)
                msize(tiny)
                clwidth(medthick)
                title(`tname')
                ytitle(`varlab1')
                xtitle(`varlab2')
                `options'
                );


    };


    mkmat `name_final', matrix(`x');

    return matrix grqreg = `x';

    `list';

    *-> save trace dataset;

    if "`save'"!="" {;
        save "`save'", replace;
    };

    *-> restore;

    restore;

    #delimit cr

end
