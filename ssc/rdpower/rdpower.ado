*! Version 1.0  3-25-2011

// description 

program rdpower, rclass
    syntax namelist, es(real) n(real)  ///
    [p(real 0)] [m(real 0)]  ///
    [icc2(numlist max = 1 < 1)]  ///
    [icc3(numlist max = 1 < 1)] [alpha(real 0.05)]  ///
    [pre1(real 0)] [pre2(real 0)] [pre3(real 0)]  ///
    [l2vars(real 0)] [l3vars(real 0)] ///
    [v(numlist max = 1)]
	version 11.1
    tempname de dec lamda_square dfd f beta power eta1 eta2 eta3
    if "`namelist'" == "rd1" {
        *calcualte the noncentrality parameter lamda-squared
        scalar `lamda_square' = (`es'^2)*(`n'/2)
        *calcualte degrees of freedom
        scalar `dfd' = (2*`n') - 2
        *critical f
        scalar `f' = invFtail(1,`dfd',`alpha')
        *calculate power
        scalar `power' = nFtail(1,`dfd',`lamda_square',`f')
        *Display parameters and results
        display as text _newline "Estimated power for"  ///
        as result " one-level randomized" as text  " design"
        display as text "Treatment is at level" as result " 1"
        display as result _newline "Power parameters"
        display as result "{hline 65}"
        if round(`power', .0001) == 1 {
            display _col(5) as text "Power" _col(50) ">" _col(55) as result %9.4f .9999
        }
        else {
            display _col(5) as text "Power" _col(50) "=" _col(55) as result %9.4f `power'
        }
		display _col(5) as text "Effect size" _col(50) "=" _col(55) as result %9.4f `es'
        display _col(5) as text "Noncentral t" _col(50) "=" _col(55) as result %9.4f `lamda_square'^.5
        display _col(5) as text "Critical t" _col(50) "=" _col(55) as result %9.4f `f'^.5
        display _col(5) as text "Alpha (two-tailed test)" _col(50) "=" _col(55) as result %9.4f `alpha'
        display as result _newline "Sample size (n * 2)"
        display as result "{hline 65}"
        display _col(5) as text "N per treatment" _col(50) "=" _col(55) as result %9.4f `n'
        display _col(5) as text "Total sample size" _col(50) "=" _col(55) as result %9.4f `n' * 2
        *Save Results in r
        return local type "`namelist'"
        return scalar samplesize = `n' * 2
        return scalar n = `n'
        return scalar alpha = `alpha'
        return scalar effectsize = `es'
        return scalar noncentral = `lamda_square'^.5
        return scalar critical = `f' ^ .5
        return scalar power = `power'
    }
    else if "`namelist'" == "crd2" {
        capture confirm existence `icc2'
        if _rc == 6 {
            display as error "must specify level 2 intraclass correlation value icc2(x)"
            error _rc
        }
        if `pre1' > 0 | `pre2' > 0 {
            capture assert `l2vars' > 0
            if _rc == 9 {
                display as error "must have at least 1 level 2 vars with PRE options"
                error _rc
            }
        }
        capture assert `m' >= 2
        if _rc == 9 {
            display as error "m must be 2 or greater"
            error _rc
        }
        capture assert `l2vars' < `m' - 1
        if _rc == 9 {
            display as error "too few degrees of freedom at level 2, increase m or decrease covariates"
            error _rc
        }
        *calcualte the design effect
        scalar `de' = 1+((`n'-1)*`icc2')
        scalar `dec' = `pre1' + (((`n' * `pre2')-`pre1')*`icc2')
        *calcualte the noncentrality parameter lamda-squared
        scalar `lamda_square' = (`es'^2)*((`n'*`m')/2)*(1/(`de' - `dec'))
        *calcualte degrees of freedom
        scalar `dfd' = (2*`m') - 2 - `l2vars'
        *critical f
        scalar `f' = invFtail(1,`dfd',`alpha')
        *calculate power
        scalar `power' = nFtail(1,`dfd',`lamda_square',`f')
        *Display parameters and results
        display as text _newline "Estimated power for"  ///
        as result " two-level cluster randomized" as text  " design" _continue
        if `pre1' > 0 | `pre2' > 0 | `pre3' > 0 {
            display as result " with covariates"
        }
        else {
            display ""
        }
        display as text "Treatment is at level" as result " 2"
        display as result _newline "Power parameters"
        display as result "{hline 65}"
        if round(`power', .0001) == 1 {
            display _col(5) as text "Power" _col(50) ">" _col(55) as result %9.4f .9999
        }
        else {
            display _col(5) as text "Power" _col(50) "=" _col(55) as result %9.4f `power'
        }
		display _col(5) as text "Effect size" _col(50) "=" _col(55) as result %9.4f `es'
        display _col(5) as text "Noncentral t" _col(50) "=" _col(55) as result %9.4f `lamda_square'^.5
        display _col(5) as text "Critical t" _col(50) "=" _col(55) as result %9.4f `f'^.5
        display _col(5) as text "Alpha (two-tailed test)" _col(50) "=" _col(55) as result %9.4f `alpha'
        display as result _newline "Design parameters"
        display as result "{hline 65}"
        display _col(5) as text "Level 2 intraclass correlation" _col(50) "=" _col(55) as result %9.4f `icc2'
        if `pre2' > 0 {
            display _col(5) as text "Level 2 R-square" _col(50) "=" _col(55) as result %9.4f `pre2'
        }
        if `pre1' > 0 {
            display _col(5) as text "Level 1 R-square" _col(50) "=" _col(55) as result %9.4f `pre1'
        }
        if `l2vars' > 0 {
            display _col(5) as text "Number level 2 covariates" _col(50) "=" _col(55) as result %9.4f `l2vars'
        }
        display _col(5) as text "Design effect" _col(50) "=" _col(55) as result %9.4f `de' - `dec'
        display as result _newline "Sample size (n * m * 2)"
        display as result "{hline 65}"
        display _col(5) as text "Level 2 clusters per treatment" _col(50) "=" _col(55) as result %9.4f `m'
        display _col(5) as text "N per level 2 cluster" _col(50) "=" _col(55) as result %9.4f `n'
        display _col(5) as text "Total sample size" _col(50) "=" _col(55) as result %9.4f `n' * (`m'*2)
        *Save Results in r
        return local type "`namelist'"
        if `l2vars' > 0 {
            return scalar level2vars = `l2vars'
        }
        if `pre2' > 0 {
            return scalar r2_level2 = `pre2'
        }
        if `pre1' > 0 {
            return scalar r2_level1 = `pre1'
        }
        return scalar samplesize = `n' * (`m'*2)
        return scalar m = `m'
        return scalar n = `n'
        return scalar alpha = `alpha'
        return scalar icc2 = `icc2'
        return scalar effectsize = `es'
        return scalar designeffect = `de' - `dec'
        return scalar noncentral = `lamda_square'^.5
        return scalar critical = `f' ^ .5
        return scalar power = `power'
    }
    else if "`namelist'" == "crd3" {
        capture confirm existence `icc2'
        if _rc == 6 {
            display as error "must specify level 2 intraclass correlation value icc2(x)"
            error _rc
        }
        if `pre1' > 0 | `pre2' > 0 | `pre3' > 0 {
            capture assert `l3vars' > 0
            if _rc == 9 {
                display as error "must have at least 1 level 2 vars with PRE options"
                error _rc
            }
        }
        capture assert `m' >= 2
        if _rc == 9 {
            display as error "m must be 2 or greater"
            error _rc
        }
        capture assert `l3vars' < `m' - 1
        if _rc == 9 {
            display as error "too few degrees of freedom at level 3, increase m or decrease covariates"
            error _rc
        }
        capture confirm existence `icc3'
        if _rc == 6 {
            display as error "must specify level 3 intraclass correlation value icc3(x)"
            error _rc
        }
        capture assert `p' >= 1
        if _rc == 9 {
            display as error "must specify level 2 clusters value p(x)"
            error _rc
        }
        *calcualte the design effect
        scalar `de' = 1+(((`p'*`n')-1)*`icc3') + ((`n'-1)*`icc2')
        scalar `dec' = `pre1' + (((`pre3'*`p'*`n')-`pre1')*`icc3') + (((`pre2'*`n') - `pre1')*`icc2')
        *calcualte the noncentrality parameter lamda-squared
        scalar `lamda_square' = (`es'^2)*((`n'*`p'*`m')/2)*(1/(`de' - `dec'))
        *calcualte degrees of freedom
        scalar `dfd' = (2*`m') - 2 - `l3vars'
        *critical f
        scalar `f' = invFtail(1,`dfd',`alpha')
        *calculate power
        scalar `power' = nFtail(1,`dfd',`lamda_square',`f')

        *Display parameters and results
        display as text _newline "Estimated power for"  ///
        as result " three-level cluster randomized" as text  " design" _continue
        if `pre1' > 0 | `pre2' > 0 | `pre3' > 0 {
            display as result " with covariates"
        }
        else {
            display ""
        }
        display as text "Treatment is at level" as result " 3"
        display as result _newline "Power parameters"
        display as result "{hline 65}"
        if round(`power', .0001) == 1 {
            display _col(5) as text "Power" _col(50) ">" _col(55) as result %9.4f .9999
        }
        else {
            display _col(5) as text "Power" _col(50) "=" _col(55) as result %9.4f `power'
        }
		display _col(5) as text "Effect size" _col(50) "=" _col(55) as result %9.4f `es'
        display _col(5) as text "Noncentral t" _col(50) "=" _col(55) as result %9.4f `lamda_square'^.5
        display _col(5) as text "Critical t" _col(50) "=" _col(55) as result %9.4f `f'^.5
        display _col(5) as text "Alpha (two-tailed test)" _col(50) "=" _col(55) as result %9.4f `alpha'
        display as result _newline "Design parameters"
        display as result "{hline 65}"
        display _col(5) as text "Level 3 intraclass correlation" _col(50) "=" _col(55) as result %9.4f `icc3'
        display _col(5) as text "Level 2 intraclass correlation" _col(50) "=" _col(55) as result %9.4f `icc2'
        if `pre3' > 0 {
            display _col(5) as text "Level 3 R-square" _col(50) "=" _col(55) as result %9.4f `pre3'
        }
        if `pre2' > 0 {
            display _col(5) as text "Level 2 R-square" _col(50) "=" _col(55) as result %9.4f `pre2'
        }
        if `pre1' > 0 {
            display _col(5) as text "Level 1 R-square" _col(50) "=" _col(55) as result %9.4f `pre1'
        }
        if `l3vars' > 0 {
            display _col(5) as text "Number level 3 covariates" _col(50) "=" _col(55) as result %9.4f `l3vars'
        }
        display _col(5) as text "Design effect" _col(50) "=" _col(55) as result %9.4f `de' - `dec'
        display as result _newline "Sample size (n * p * m * 2)"
        display as result "{hline 65}"
        display _col(5) as text "Level 3 clusters per treatment" _col(50) "=" _col(55) as result %9.4f `m'
        display _col(5) as text "Level 2 clusters per level 3 cluster" _col(50) "=" _col(55) as result %9.4f `p'
        display _col(5) as text "N per level 2 cluster" _col(50) "=" _col(55) as result %9.4f `n'
        display _col(5) as text "Total sample size" _col(50) "=" _col(55) as result %9.4f `n' * `p' * (`m'*2)

        *Save Results in r
        return local type "`namelist'"

        if `l3vars' > 0 {
            return scalar level2vars = `l3vars'
        }
        if `pre3' > 0 {
            return scalar r2_level2 = `pre3'
        }
        if `pre2' > 0 {
            return scalar r2_level2 = `pre2'
        }
        if `pre1' > 0 {
            return scalar r2_level1 = `pre1'
        }
        return scalar samplesize = `n' * `p' * (`m'*2)
        return scalar m = `m'
        return scalar p = `p'
        return scalar n = `n'
        return scalar alpha = `alpha'
        return scalar icc3 = `icc3'
        return scalar icc2 = `icc2'
        return scalar effectsize = `es'
        return scalar designeffect = `de' - `dec'
        return scalar noncentral = `lamda_square'^.5
        return scalar critical = `f' ^ .5
        return scalar power = `power'

    }
    else if "`namelist'" == "rbd2" {
        capture confirm existence `icc2'
        if _rc == 6 {
            display as error "must specify level 2 intraclass correlation value icc2(x)"
            error _rc
        }
        capture confirm existence `v'
        if _rc == 6 {
            display as error "must specify variation in treatment effects parameter v(x)"
            error _rc
        }
        if `pre1' > 0 | `pre2' > 0 {
            capture assert `l2vars' > 0
            if _rc == 9 {
                display as error "must have at least 1 level 2 vars with PRE options"
                error _rc
            }
        }
        capture assert `m' >= 2
        if _rc == 9 {
            display as error "m must be 2 or greater"
            error _rc
        }
        capture assert `l2vars' < `m' - 1
        if _rc == 9 {
            display as error "too few degrees of freedom at level 2, increase m or decrease covariates"
            error _rc
        }
        *calcualte the design effect
        scalar `de' = 1+((((`n'/2)*`v')-1)*`icc2')
        scalar `dec' = `pre1' + ((((`n'/2)* `v' * `pre2')-`pre1')*`icc2')
        *calcualte the noncentrality parameter lamda-squared
        scalar `lamda_square' = (`es'^2)*(((`m'*`n')/2)/(`de' - `dec'))
        *calcualte degrees of freedom
        scalar `dfd' = (`m') - 1 - `l2vars'
        *critical f
        scalar `f' = invFtail(1,`dfd',`alpha')
        *calculate power
        scalar `power' = nFtail(1,`dfd',`lamda_square',`f')

        *Display parameters and results
        display as text _newline "Estimated power for"  ///
        as result " two-level randomized blocks" as text " design" _continue
        if `pre1' > 0 | `pre2' > 0 | `pre3' > 0 {
            display as result " with covariates"
        }
        else {
            display ""
        }
        display as text "Treatment is at level" as result " 1"
        display as result _newline "Power parameters"
        display as result "{hline 65}"
        if round(`power', .0001) == 1 {
            display _col(5) as text "Power" _col(50) ">" _col(55) as result %9.4f .9999
        }
        else {
            display _col(5) as text "Power" _col(50) "=" _col(55) as result %9.4f `power'
        }
		display _col(5) as text "Effect size" _col(50) "=" _col(55) as result %9.4f `es'
        display _col(5) as text "Noncentral t" _col(50) "=" _col(55) as result %9.4f `lamda_square'^.5
        display _col(5) as text "Critical t" _col(50) "=" _col(55) as result %9.4f `f'^.5
        display _col(5) as text "Alpha (two-tailed test)" _col(50) "=" _col(55) as result %9.4f `alpha'
        display as result _newline "Design parameters"
        display as result "{hline 65}"
        display _col(5) as text "Level 2 intraclass correlation" _col(50) "=" _col(55) as result %9.4f `icc2'
        display _col(5) as text "Variance ratio" _col(50) "=" _col(55) as result %9.4f `v'
        if `pre2' > 0 {
            display _col(5) as text "Level 2 R-square (treatment effects)" _col(50) "=" _col(55) as result %9.4f `pre2'
        }
        if `pre1' > 0 {
            display _col(5) as text "Level 1 R-square" _col(50) "=" _col(55) as result %9.4f `pre1'
        }
        if `l2vars' > 0 {
            display _col(5) as text "Number level 2 covariates" _col(50) "=" _col(55) as result %9.4f `l2vars'
        }
        display _col(5) as text "Design effect" _col(50) "=" _col(55) as result %9.4f `de' - `dec'
        display as result _newline "Sample size (n * m * 2)"
        display as result "{hline 65}"
        display _col(5) as text "Number of level 2 clusters" _col(50) "=" _col(55) as result %9.4f `m'
        display _col(5) as text "N per treatment per level 2 cluster" _col(50) "=" _col(55) as result %9.4f `n'
        display _col(5) as text "Total sample size" _col(50) "=" _col(55) as result %9.4f (2*`n') * (`m')

        *Save Results in r
        return local type "`namelist'"

        if `l2vars' > 0 {
            return scalar level2vars = `l2vars'
        }
        if `pre2' > 0 {
            return scalar r2_level2 = `pre2'
        }
        if `pre1' > 0 {
            return scalar r2_level1 = `pre1'
        }
        return scalar samplesize = (2 * `n') * (`m')
        return scalar m = `m'
        return scalar n = `n'
        return scalar alpha = `alpha'
        return scalar icc2 = `icc2'
        return scalar effectsize = `es'
        return scalar treatmentvariance = `v'
        return scalar designeffect = `de' - `dec'
        return scalar noncentral = `lamda_square'^.5
        return scalar critical = `f' ^ .5
        return scalar power = `power'

    }
    else if "`namelist'" == "rbd3" {
        capture confirm existence `icc2'
        if _rc == 6 {
            display as error "must specify level 2 intraclass correlation value icc2(x)"
            error _rc
        }
        capture confirm existence `v'
        if _rc == 6 {
            display as error "must specify variation in treatment effects parameter v(x)"
            error _rc
        }
        capture assert `p' >= 1
        if _rc == 9 {
            display as error "must specify level 2 clusters value p(x)"
            error _rc
        }
        if `pre1' > 0 | `pre2' > 0 | `pre3' > 0 {
            capture assert `l3vars' > 0
            if _rc == 9 {
                display as error "must have at least 1 level 3 vars with PRE options"
                error _rc
            }
        }
        capture assert `m' >= 2
        if _rc == 9 {
            display as error "m must be 2 or greater"
            error _rc
        }
        capture assert `l3vars' < `m' - 1
        if _rc == 9 {
            display as error "too few degrees of freedom at level 3, increase m or decrease covariates"
            error _rc
        }
        *calcualte the design effect

        scalar `de' = 1 + (((((`p'*`n')/2)*`v')-1)*`icc3')+((`n'-1)*`icc2')
        scalar `dec' = `pre1' + (((((`p'*`n')/2)*`v'*`pre3')-`pre1')*`icc3')+(((`n'*`pre2')-`pre1')*`icc2')

        *calcualte the noncentrality parameter lamda-squared
        scalar `lamda_square' = (`es'^2)*(((`m'*`p'*`n')/2)/(`de' - `dec'))
        *calcualte degrees of freedom
        scalar `dfd' = (`m') - 1 - `l3vars'
        *critical f
        scalar `f' = invFtail(1,`dfd',`alpha')
        *calculate power
        scalar `power' = nFtail(1,`dfd',`lamda_square',`f')

        *Display parameters and results
        display as text _newline "Estimated power for"  ///
        as result " three-level randomized blocks" as text  " design" _continue
        if `pre1' > 0 | `pre2' > 0 | `pre3' > 0 {
            display as result " with covariates"
        }
        else {
            display ""
        }
        display as text "Treatment is at level" as result " 2"
        display as result _newline "Power parameters"
        display as result "{hline 65}"
        if round(`power', .0001) == 1 {
            display _col(5) as text "Power" _col(50) ">" _col(55) as result %9.4f .9999
        }
        else {
            display _col(5) as text "Power" _col(50) "=" _col(55) as result %9.4f `power'
        }
		display _col(5) as text "Effect size" _col(50) "=" _col(55) as result %9.4f `es'
        display _col(5) as text "Noncentral t" _col(50) "=" _col(55) as result %9.4f `lamda_square'^.5
        display _col(5) as text "Critical t" _col(50) "=" _col(55) as result %9.4f `f'^.5
        display _col(5) as text "Alpha (two-tailed test)" _col(50) "=" _col(55) as result %9.4f `alpha'
        display as result _newline "Design parameters"
        display as result "{hline 65}"
        display _col(5) as text "Level 3 intraclass correlation" _col(50) "=" _col(55) as result %9.4f `icc3'
        display _col(5) as text "Level 2 intraclass correlation" _col(50) "=" _col(55) as result %9.4f `icc2'
        display _col(5) as text "Variance ratio" _col(50) "=" _col(55) as result %9.4f `v'
        if `pre3' > 0 {
            display _col(5) as text "Level 3 R-square (treatment effects)" _col(50) "=" _col(55) as result %9.4f `pre3'
        }
        if `pre2' > 0 {
            display _col(5) as text "Level 2 R-square" _col(50) "=" _col(55) as result %9.4f `pre2'
        }
        if `pre1' > 0 {
            display _col(5) as text "Level 1 R-square" _col(50) "=" _col(55) as result %9.4f `pre1'
        }
        if `l2vars' > 0 {
            display _col(5) as text "Number level 3 covariates" _col(50) "=" _col(55) as result %9.4f `l2vars'
        }
        display _col(5) as text "Design effect" _col(50) "=" _col(55) as result %9.4f `de' - `dec'
        display as result _newline "Sample size (n * p * m * 2)"
        display as result "{hline 65}"
        display _col(5) as text "Number of level 3 clusters" _col(50) "=" _col(55) as result %9.4f `m'
        display _col(5) as text "Level 2 clusters per level 3 per treatment" _col(50) "=" _col(55) as result %9.4f `p'
        display _col(5) as text "N per level 2 cluster" _col(50) "=" _col(55) as result %9.4f `n'
        display _col(5) as text "Total sample size" _col(50) "=" _col(55) as result %9.4f `n' * (`m')   * (`p'*2)

        *Save Results in r
        return local type "`namelist'"

        if `l2vars' > 0 {
            return scalar level3vars = `l3vars'
        }
        if `pre3' > 0 {
            return scalar r2_level2 = `pre3'
        }
        if `pre2' > 0 {
            return scalar r2_level2 = `pre2'
        }
        if `pre1' > 0 {
            return scalar r2_level1 = `pre1'
        }
        return scalar samplesize = `n' * (`m') * (`p'*2)
        return scalar m = `m'
        return scalar p = `p'
        return scalar n = `n'
        return scalar alpha = `alpha'
        return scalar icc2 = `icc2'
        return scalar icc3 = `icc3'
        return scalar effectsize = `es'
        return scalar treatmentvariance = `v'
        return scalar designeffect = `de' - `dec'
        return scalar noncentral = `lamda_square'^.5
        return scalar critical = `f' ^ .5
        return scalar power = `power'

    }
    else {
        display as error "unknown design type `namelist'"
        error 197
    }
    display as result "{hline 65}"
end
