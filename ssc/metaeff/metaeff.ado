/*  meta analysis module by Evangelos Kontopantelis
    creted in STATA v9.2
    last update: 19 Aug 2009
*/

/*metaeff calculates the effect and SE for each study (if possible)*/
program define metaeff
    /*stata version define*/
    version 9.2
    /*command syntax*/
    syntax namelist(min=2 max=2) [if] [in], [ni(string) nc(string) i(string) c(string) orval(string) ci95lo(string) /*
    */ ci95up(string) md(string) meani(string) meanc(string) sdi(string) sdc(string) ci95loi(string) ci95upi(string) /*
    */ ci95loc(string) ci95upc(string) p(string) t(string)/*
    */ or owrite infovar]
    /*rename some variables to less ordinary names to avoid messing up later*/
    local nia = "`ni'"
    local nca = "`nc'"
    local ia = "`i'"
    local ca = "`c'"
    /*temp variables used in all methods*/
    tempvar eff seeff uCI95smd lCI95smd denom denomi denomc pia pca sediff rd sd orv q mdv sdia sdca tvaly pvaly z ifvar method
    /*INITIAL STUFF*/
    /*get variable names for effect sizes and SE of effects*/
    local var1 = word("`namelist'",1)
    local var2 = word("`namelist'",2)
    local var3 = "_method"
    /*make sure a user doesn't give the same variable names*/
    if "`var1'"=="`var2'" {
        di in red "Output variables need to have different names!"
        error 110
    }
    /*find out if the variables specified are there and store info in 'exists' variables*/
    forvalues i=1(1)3 {
        capture confirm numeric variable `var`i'', exact
        local exists`i'=!_rc
    }
    /*if one of them is there (or both) end program if overwrite has not been specified. otherwise just warn*/
    if `exists1'==1 | `exists2'==1 | (`exists3'==1 & "`infovar'"!="") {
        if "`owrite'" =="" {
           if `exists1'==1 | `exists2'==1 {
              di in red "At least one of the specified variables already exist. Either use different names or the overwrite option"
           }
           if (`exists3'==1 & "`infovar'"!="") {
              di in red "Problem with the infovar option: a variable named '_method' already exists. Either rename it or use the overwrite option"
           }
           error 110
        }
        else {
            di in yellow "At least one of the specified variables already exist. Values in existing variables will be overwritten as selected"
        }
    }
    /*generate the 3 needed variables*/
    qui gen `seeff' = .
    qui gen `eff' = .
    qui gen str3 `method' = ""
    scalar execm = 0

    /*CALLING APPROPRIATE METHOD*/
    /*method 7 - Mean Difference method requiring NI, NC and P-value (or t-value) for two sample t-test*/
    if "`nia'"!="" & "`nca'"!="" & ("`p'"!="" | "`t'"!="")  {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `md' `meani' `meanc' `p' `t' {
            confirm numeric variable `x', exact
        }
        /*dealing with p and t*/
        if "`t'"!="" {
            /*if t provided use value to create tempvar `pvaly'*/
            qui gen `pvaly'= 2*ttail(`nia'+`nca'-2, `t')
            /*if p provided as well copy cases where t is missing*/
            if "`p'"!="" {
                qui replace `pvaly' = `p' if `pvaly'==.
            }
        }
        else {
            /*if t not provided, use p value*/
            qui gen `pvaly' = `p'
        }
        /*calculate z value*/
        qui gen `z' = abs(invnormal(`pvaly'/2))
        /*effect and SE*/
        qui replace `seeff' = sqrt(1/`nia' + 1/`nca') if `nia'!=. & `nca'!=. & `z'!=.
        qui replace `eff' = `z'*`seeff' if `nia'!=. & `nca'!=. & `z'!=.
        qui replace `method' = "7" if `nia'!=. & `nca'!=. & `z'!=.
        qui drop `z' `pvaly'
        scalar execm = 1
    }
    /*method 6 - Mean Difference method requiring NI, NC, MD (or two means) and P-value (or-tvalue) for two sample t-test*/
    if "`nia'"!="" & "`nca'"!="" & ("`md'"!="" | ("`meani'"!="" & "`meanc'"!="")) & ("`p'"!="" | "`t'"!="") {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `md' `meani' `meanc' `p' `t'{
            confirm numeric variable `x', exact
        }
        /*dealing with MD*/
        if "`md'"!="" {
            /*if MD provided copy to temp variable `mdv'*/
            qui gen `mdv'= `md'
            /*if means provided as well copy cases where MD is missing*/
            if "`meani'"!="" & "`meanc'"!="" {
                qui replace `mdv' = `meani' - `meanc' if `mdv'==.
            }
        }
        else {
            /*if MD not provided, generate from means*/
            qui gen `mdv' = `meani' - `meanc'
        }
        /*dealing with p and t*/
        if "`t'"!="" {
            /*if t provided copy to temp variable `tvaly'*/
            qui gen `tvaly'= `t'
            /*if p provided as well copy cases where t is missing*/
            if "`p'"!="" {
                qui replace `tvaly' = invttail(`nia'+`nca'-2, `p'/2) if `tvaly'==.
            }
        }
        else {
            /*if tval not provided, generate from pvalue*/
            qui gen `tvaly' = invttail(`nia'+`nca'-2, `p'/2)
        }
        /*calculate SE of the difference from p value*/
        qui gen `sediff' = `mdv'/`tvaly'
        /*effect, its SE and SD*/
        qui replace `seeff' = sqrt(1/`nia' + 1/`nca') if `nia'!=. & `nca'!=. & `sediff'!=.
        qui gen `sd' = `sediff'/`seeff'
        qui replace `eff' = `mdv'/`sd' if `nia'!=. & `nca'!=. & `sediff'!=.
        qui replace `method' = "6" if `nia'!=. & `nca'!=. & `sediff'!=.
        qui drop `sediff' `sd' `tvaly' `mdv'
        scalar execm = 1
    }
    /*method 3 - Mean Difference method requiring NI, NC, MD (or two means) and CI95%(MD)*/
    if "`nia'"!="" & "`nca'"!="" & "`ci95lo'"!="" & "`ci95up'"!="" & ("`md'"!="" | ("`meani'"!="" & "`meanc'"!="")) {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `ci95lo' `ci95up' `md' `meani' `meanc' {
            confirm numeric variable `x', exact
        }
        /*if MD provided copy to temp variable `mdv'*/
        if "`md'"!="" {
            qui gen `mdv'= `md'
            /*if means provided as well copy cases where MD is missing*/
            if "`meani'"!="" & "`meanc'"!="" {
                qui replace `mdv' = `meani' - `meanc' if `mdv'==.
            }
        }
        /*if MD not provided, generate from means*/
        else {
            qui gen `mdv' = `meani' - `meanc'
        }
        /*different denominator based on sizes - normal approximation or not*/
        qui gen `denom' = 3.92
        if `nia'<60 | `nca'<60 {
            qui replace `denom' = 2*invttail(`nia'+`nca'-2, 0.025)
        }
        /*calculate SE of the difference from confidence interval*/
        qui gen `sediff' = (`ci95up'-`ci95lo')/`denom'
        /*effect, its SE and SD*/
        qui replace `seeff' = sqrt(1/`nia' + 1/`nca') if `nia'!=. & `nca'!=. & `sediff'!=. & `mdv'!=.
        qui gen `sd' = `sediff'/`seeff'
        qui replace `eff' = `mdv'/`sd' if `nia'!=. & `nca'!=. & `sediff'!=. & `mdv'!=.
        qui replace `method' = "3" if `nia'!=. & `nca'!=. & `sediff'!=. & `mdv'!=.
        qui drop `sediff' `sd' `denom' `mdv'
        scalar execm = 1
    }
    /*method 5 - Mean Difference method requiring NI, NC, MD (or two means), CI(I) & CI(C)*/
    if "`nia'"!="" & "`nca'"!="" & "`ci95loi'"!="" & "`ci95loc'"!="" & "`ci95upi'"!="" & "`ci95upc'"!="" /*
    */ & ("`md'"!="" | ("`meani'"!="" & "`meanc'"!="")) {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `ci95loi' `ci95loc' `ci95upi' `ci95upc' `md' `meani' `meanc' {
            confirm numeric variable `x', exact
        }
        /*if MD provided copy to temp variable `mdv'*/
        if "`md'"!="" {
            qui gen `mdv'= `md'
            /*if means provided as well copy cases where MD is missing*/
            if "`meani'"!="" & "`meanc'"!="" {
                qui replace `mdv' = `meani' - `meanc' if `mdv'==.
            }
        }
        /*if MD not provided, generate from means*/
        else {
            qui gen `mdv' = `meani' - `meanc'
        }
        /*different denominator based on sizes - normal approximation or not*/
        qui gen `denomi' = 3.92
        if `nia'<60 qui replace `denomi' = 2*invttail(`nia'-1, 0.025)
        qui gen `denomc' = 3.92
        if `nca'<60 qui replace `denomc' = 2*invttail(`nca'-1, 0.025)
        /*calculate SDs from confidence intervals*/
        qui gen `sdia' = sqrt(`nia')*(`ci95upi'-`ci95loi')/`denomi'
        qui gen `sdca' = sqrt(`nca')*(`ci95upc'-`ci95loc')/`denomc'
        /*overall SD calculation*/
        qui gen `sd' = sqrt((`sdia'^2*`nia' + `sdca'^2*`nca')/(`nia'+`nca'))
        /*effect and its SE*/
        qui replace `eff' = `mdv'/`sd' if `nia'!=. & `nca'!=. & `mdv'!=. & `sd'!=.
        qui replace `seeff' = sqrt(1/`nia' + 1/`nca') if `nia'!=. & `nca'!=. & `mdv'!=. & `sd'!=.
        qui replace `method' = "5" if `nia'!=. & `nca'!=. & `mdv'!=. & `sd'!=.
        qui drop `sd' `sdia' `sdca' `denomi' `denomc' `mdv'
        scalar execm = 1
    }
    /*method 4 - Mean Difference method requiring NI, NC, MD (or two means), SD(I) & SD(C)*/
    if "`nia'"!="" & "`nca'"!="" & "`sdi'"!="" & "`sdc'"!="" & ("`md'"!="" | ("`meani'"!="" & "`meanc'"!="")) {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `sdi' `sdc' `md' `meani' `meanc' {
            confirm numeric variable `x', exact
        }
        /*if MD provided copy to temp variable `mdv'*/
        if "`md'"!="" {
            qui gen `mdv'= `md'
            /*if means provided as well copy cases where MD is missing*/
            if "`meani'"!="" & "`meanc'"!="" {
                qui replace `mdv' = `meani' - `meanc' if `mdv'==.
            }
        }
        /*if MD not provided, generate from means*/
        else {
            qui gen `mdv' = `meani' - `meanc'
        }
        /*overall SD calculation*/
        qui gen `sd' = sqrt((`sdi'^2*(`nia'-1) + `sdc'^2*(`nca'-1))/(`nia'+`nca'-2))
        /*effect and its SE*/
        qui replace `eff' = `mdv'/`sd' if `nia'!=. & `nca'!=. & `mdv'!=. & `sd'!=.
        qui replace `seeff' = sqrt(1/`nia' + 1/`nca') if `nia'!=. & `nca'!=. & `mdv'!=. & `sd'!=.
        qui replace `method' = "4" if `nia'!=. & `nca'!=. & `mdv'!=. & `sd'!=.
        qui drop `sd' `mdv'
        scalar execm = 1
    }
    /*method 1b - Odds Ratio method requiring NI, NC, I and C and used only if has been specifically selected over RD method 1a*/
    if "`nia'"!="" & "`nca'"!="" & "`ia'"!="" & "`ca'"!="" & "`or'"!="" {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `ia' `ca' {
            confirm numeric variable `x', exact
        }
        /*odds ratio calculations*/
        qui gen `orv' = (`ia'/(`nia'-`ia')) / (`ca'/(`nca'-`ca'))
        qui gen `q' = ln(`orv')
        qui gen `sediff' = sqrt(1/`ia' + 1/(`nia'-`ia') + 1/`ca' + 1/(`nca'-`ca'))
        /*effect and its SE*/
        qui replace `eff' = (sqrt(3)/_pi) * `q' if `q'!=. & `sediff'!=.
        qui replace `seeff' = (sqrt(3)/_pi) * `sediff' if `q'!=. & `sediff'!=.
        qui replace `method' = "1b" if `q'!=. & `sediff'!=.
        qui drop `orv' `q' `sediff'
        scalar execm = 1
    }
    /*method 1a - Risk Difference method requiring NI, NC, I and C and used as default unless OR 1b has been specifically selected*/
    if "`nia'"!="" & "`nca'"!="" & "`ia'"!="" & "`ca'"!="" & "`or'"=="" {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `ia' `ca' {
            confirm numeric variable `x', exact
        }
        /*percentages*/
        qui gen `pia' = `ia' / `nia'
        qui gen `pca' = `ca' / `nca'
        /*SE of the difference*/
        qui gen `sediff' = sqrt(`pia'*(1-`pia')/`nia'+`pca'*(1-`pca')/`nca')
        /*risk difference*/
        qui gen `rd' = `ia'/`nia'-`ca'/`nca'
        /*effect and its SE - using SD as well*/
        qui replace `seeff' = sqrt(1/`nia'+1/`nca') if `nia'!=. & `nca'!=. & `rd'!=. & `sediff'!=.
        qui gen `sd' = `sediff'/`seeff'
        qui replace `eff' = `rd'/`sd' if `nia'!=. & `nca'!=. & `rd'!=. & `sediff'!=.
        qui replace `method' = "1a" if `nia'!=. & `nca'!=. & `rd'!=. & `sediff'!=.
        qui drop `pia' `pca' `rd' `sediff' `sd'
        scalar execm = 1
    }
    /*method 2 - Odds Ratio method requiring NI, NC, OR and CI95%(OR)*/
    if "`nia'"!="" & "`nca'"!="" & "`orval'"!="" & "`ci95lo'"!="" & "`ci95up'"!="" {
        /*verify variables are there and numeric*/
        foreach x in `nia' `nca' `orval' `ci95lo' `ci95up' {
            confirm numeric variable `x', exact
        }
        /*lower and upper CI for Standardised Mean Difference*/
        qui gen `uCI95smd' = (sqrt(3)/_pi)*ln(`ci95up')
        qui gen `lCI95smd' = (sqrt(3)/_pi)*ln(`ci95lo')
        /*different denominator based on sizes - normal approximation or not*/
        qui gen `denom' = 3.92
        if `nia'<60 | `nca'<60 {
            qui replace `denom' = 2*invttail(`nia'+`nca'-2, 0.025)
        }
        qui replace `eff' = (sqrt(3)/_pi)*ln(`orval') if `orval'!=. & `uCI95smd'!=. & `lCI95smd'!=. & `denom'!=.
        qui replace `seeff' = (`uCI95smd' - `lCI95smd')/`denom' if `orval'!=. & `uCI95smd'!=. & `lCI95smd'!=. & `denom'!=.
        qui replace `method' = "2" if `orval'!=. & `uCI95smd'!=. & `lCI95smd'!=. & `denom'!=.
        qui drop `uCI95smd' `lCI95smd' `denom'
        scalar execm = 1
    }
    /*if no method is selected*/
    if execm==0 {
        di in red "No method selected: not enough input variables. Please refer to the help file for more details"
        error 110
    }
    /*if program proceeds this far all went OK and we can create the final variables from the temp ones*/
    qui gen `ifvar'=0   /*ifvar needed in case user gives "if eff==." or "if seeff==." a way to update eff & seeff simultaneously*/
    qui replace `ifvar'=1 `if'
    /*final effect*/
    qui capture gen `var1'=.
    qui replace `var1' = `eff' `in' if `ifvar'==1
    label var `var1' "effect sizes"
    /*final SE of the effect*/
    qui capture gen `var2'=.
    qui replace `var2' = `seeff' `in' if `ifvar'==1
    label var `var2' "SE of the effect sizes"    
    /*final information on method variable*/
    if "`infovar'"!="" {
       qui capture gen str3 _method=""
       qui replace _method = `method' `in' if `ifvar'==1
       label var _method "selected effect size estimation method"
    }
    /*see if dichotomous methods had be used and warn about transformation*/
    //qui count if _method=="1b" | _method=="2"
    di in yellow "Warning: Transformation to SMD (via Odds Ratios, methods 1b and/or 2) took place in certain cases."
    di in yellow _col(10) "If you want to meta-analyse dichotomous outcomes only, please use metan to estimate the effects"
end
