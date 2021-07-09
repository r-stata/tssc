*! sizefx v1.3 MSOpenshaw 01Apr2010
* Program to calculate Cohen's d & Hedges' g
program define sizefx, rclass byable(recall)
version 10.1syntax varlist(min=2 max=2 numeric) [if] [in]

*ENSURES N > 0
     marksample touse
     quietly count if `touse'
     if `r(N)' == 0 {
          error 2000
     }
    
*Define temporary variableslocal res n1 s1 m1 n2 m2 s2 dfd dfg meandiff numr spd spg dvalue hedgesg d2 es_rtempname `res'
quietly summarize `1' if `touse'     scalar `n1' = r(N)     scalar `m1' = r(mean)     scalar `s1' = r(Var)quietly summarize `2' if `touse'     scalar `n2' = r(N)     scalar `m2' = r(mean)     scalar `s2' = r(Var)*Calculate difference in means     scalar `meandiff' = abs(`m1'-`m2')

*Calculate pooled variance for Cohen's d and Hedges' g
     scalar `numr' = ((`n1'-1)*`s1') + ((`n2'-1)*`s2')     scalar `dfd' = `n1'+`n2'
     scalar `dfg' = `n1'+`n2'-2     scalar `spd' = sqrt(`numr'/`dfd')     scalar `spg' = sqrt(`numr'/`dfg')*Calculate the statistics     scalar `dvalue' = `meandiff'/`spd'     scalar `hedgesg' = `meandiff'/`spg'*Calculate effect size (ES) correlation     scalar `d2' = `dvalue'*`dvalue'     scalar `es_r' = `dvalue'/(sqrt(`d2'+4))*Displays Resultsdi ""display as result "Cohen's {it:d} and Hedges' {it:g} for: `1' vs. `2'"di as txt "Cohen's {it:d} statistic (pooled variance) = " `dvalue'di as txt "Hedges' {it:g} statistic = " `hedgesg'di ""di as result "Effect size correlation ({it:r}) for: `1' vs. `2'"
di as txt "ES correlation {it:r} = " `es_r'

     return scalar N = r(N)
     return scalar Cd = `dvalue'
     return scalar Hg = `hedgesg'
     return scalar ESr = `es_r'

end
