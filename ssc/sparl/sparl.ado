*! 1.7.0 NJC 19 July 2000 
* dropped leaving _ variables behind: bad style 
* 1.6.1 NJC 18 July 2000 yname, xname options: better handling of " " 
* 1.6.0 NJC 31 March 1999
* 1.5.5 NJC 15 Sept 1998 level option, superscript 2 on R-sq, corr option
* 1.5.4 NJC 21 May 1998 ci option
* 1.5.3 NJC 8 May 1998 pvalue option improved
* 1.5.2 NJC 7 May 1998 pvalue option
* 1.5.1 NJC 25 Nov 1997 _log_x _log_y _x_sq
* 1.5.0 NJC 21 Nov 1997 logy logx power ln cfmt options
* 1.4.1 NJC 20 Oct 1997 quad option
* 1.4.0 NJC 3 Apr 1997
program define sparl
    version 6.0
    #delimit ; 
    syntax varlist(min=2 max=2) [if] [in] [aweight fweight]
    , [ PGEN(str) AFMT(str) BFMT(str) CFMT(str) RFMT(str)
    RVL MEANS Round(real 1) Quad LOGX LOGY POWer LN PValue PFMT(str)
    XLAbel(str) YLAbel(str) Connect(str) Symbol(str) SOrt Gap(int 6)
    L1title(str) T1title(str) T2title(str) CI PEn(str) XName(str) YName(str) 
    Level(int $S_level) CORR * ] ;
    #delimit cr
    tokenize `varlist'
    args y x 
    tempvar ypred Y X lgy lgx xsq  
    tempname r n rsq rmse a b c P

    qui {
        corr `y' `x' [`weight' `exp'] `if' `in'
        scalar `r' = r(rho)

        if "`power'" == "power" {
            local logy "logy"
            local logx "logx"
        }
        local log = cond("`ln'" == "ln", "ln ", "log ") 
        if "`logy'" == "logy" {
            gen `lgy' = log(`y')
            label var `lgy' "`log'`y'"
            local 1 "`lgy'"
            local Logy "`log'"
        }
        if "`logx'" == "logx" {
            gen `lgx' = log(`x')
            label var `lgx' "`log'`x'"
            local 2 "`lgx'"
            local Logx "`log'"
            local lparen "("
            local rparen ")"
        }
        if "`quad'" == "quad" {
            gen `xsq' = `x'^2
            label var `xsq' "`lparen'`Logx'`x'`rparen'^2"
            local square "`xsq'"
        }

        regress `1' `2' `square' [`weight' `exp'] `if' `in'
        scalar `n' = e(N)
        scalar `rsq' = e(r2)
        scalar `P' = fprob(e(df_m),e(df_r),e(F))
        predict `ypred' if e(sample) 
        if "`ci'" == "ci" {
            if `level' < 10 | `level' > 99 {
                    local level 95
                    noi di in bl "Note: confidence level set to 95%"
            }
            tempvar se ul ll
            predict `se' if e(sample), stdp
            gen `ul' = `ypred' + invnorm((100 + `level')/ 200) * `se'
            gen `ll' = `ypred' + invnorm((100 - `level')/ 200) * `se'
        }
        if "`logy'" == "logy" {
            replace `ypred' = exp(`ypred')
            if "`ci'" == "ci" {
                replace `ul' = exp(`ul')
                replace `ll' = exp(`ll')
            }
        }
        scalar `rmse' = e(rmse)
        scalar `a' = _b[_cons]
        scalar `b' = _b[`2']
        if "`quad'" == "quad" { scalar `c' = _b[`square'] }
    }

    if "`afmt'" == "" { local afmt "%4.3f" }
    if "`bfmt'" == "" { local bfmt "%4.3f" }
    if "`cfmt'" == "" { local cfmt "%4.3f" }
    if "`rfmt'" == "" { local rfmt "%4.3f" }
    if "`pfmt'" == "" { local pfmt "%4.3f" }

    if `"`t1title'"' == "" {
        local sign = cond(`b' >= 0, "+", "-") 
	if `"`yname'"' == "" { local yname "`y'" } 
	if `"`xname'"' == "" { local xname "`x'" } 
        #delimit ;
        local t1title : di `"`Logy'`yname' = "' `afmt' `a'
        " `sign' " `bfmt' abs(`b') `" `Logx'`xname'"' ;
        #delimit cr
        if "`quad'" == "quad" {
            local sign = cond(`c' >= 0, "+", "-") 
            local t1title : /*
             */ di "`t1title' `sign' " `cfmt' abs(`c') /*
             */ `" `lparen'`Logx'`xname'`rparen'^2"'
        }
    }
    if `"`t2title'"' == "" {
        if "`pvalue'" != "" {
            local ptext : di  `pfmt' `P'
            local ptext = trim("`ptext'")
            local ptext "  P = `ptext'"
        }
        * Alt-253 for superscript square
        if "$S_OS" == "Windows"  { local sq "²" }
        else local sq "-sq" 
        if "`corr'" == "corr" { local corrtxt : di "r = " `rfmt' `r' " " }
        local t2title : di "`corrtxt'r`sq' = " `rfmt' `rsq' /*
         */ "  RMSE = " `afmt' `rmse' "`ptext'  n = " `n'
    }
    if `"`l1title'"' == "" {
        local l1title : variable label `y'
        if `"`l1title'"' == "" { local l1title "`y'" }
    }
    if "`rvl'" == "rvl" {
        local connect "||sss"
        local symbol "iiiii"
    }
    if "`connect'" == "" { local connect "..sss" }
    if "`symbol'" == "" { local symbol "Oiiii" }
    if "`pen'" == "" {
        if "`ci'" == "ci" { local pen "25544" }
        else local pen "255"
    }
    if "`xlabel'" == "" { local xlabel "xla" }
    else local xlabel "xlabel(`xlabel')" 
    if "`ylabel'" == "" { local ylabel "yla" }
    else local ylabel "ylabel(`ylabel')" 
    if "`sort'" == "" { local sort "sort" }

    qui if "`means'" != "" {
        gen `X' = round(`x', `round')
        egen `Y' = mean(`y') `if' `in', by(`X')
        local y "`Y'"
    }
            
    #delimit ;
    gra `y' `ypred' `ypred' `ul' `ll' `x' [`weight' `exp'] `if' `in',
    `xlabel' `ylabel' sy(`symbol') c(`connect') `sort' t1(`"`t1title'"')
    pen(`pen') t2(`"`t2title'"') l1(`"`l1title'"') gap(`gap') `options' ;
    #delimit cr

    if "`pgen'" != "" {
        confirm new variable `pgen'
        qui gen `pgen' = `ypred'
    }

end
