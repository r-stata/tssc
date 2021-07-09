*! 1.1 N.Orsini 04 Feb 2005

capture program drop p2ci
program p2ci, rclass
version 8
syntax anything [, dfr(string) Level(int $S_level)  Format(string)  eform ]

if `level' <10 | `level'>99 { 
di in red "level() invalid"
exit 198
}   

if "`format'" == "" {
local format = "%4.3f"
}   
else {
local format = "`format'"
}

if `2' == 0 { 
di in red "#pval cannot be exactly equal to zero"
exit 198
}   

tempname b pval tc sec lb ub  zc levelci mlevelci
                            
scalar `levelci' = `level' * 0.005 + 0.50

scalar `mlevelci' = 1- `levelci'

scalar `b' =  `1' 

scalar `pval' =  `2' 

if "`dfr'" == "" {

// If the reg. coeff. b is compared with a z-distribution 

* 1) Calculate z-statistic

scalar `zc' = invnorm(`pval'/2)

* 2) calculate se given that you know b

scalar `sec' = abs(`b' /`zc')

* 3) calculate CI for b

scalar `lb' = `b' - invnorm(`levelci') * `sec'
scalar `ub' = `b' + invnorm(`levelci') * `sec'

}   
else {

// If the reg. coeff. b is compared with a t-distribution 

tempname df

scalar `df' = `dfr'

* 1) Calculate t-statistic

scalar `tc' = invttail(`df', `pval'/2)

* 2) calculate se given that you know b

scalar `sec' = abs(`b' / `tc')

* 3) calculate CI for b

scalar `lb' = `b' - invttail(`df',`mlevelci') * `sec'
scalar `ub' = `b' + invttail(`df',`mlevelci') * `sec'

}

if "`eform'" == "" {
di _col(3) in g `format' `b' " (" `format' in y `sec' in g ")"  " `level'% Conf. Interval [" `format' in y `lb' ", " `format' `ub' in g "]"
}   
else {
di _col(3) in g `format' exp(`b') " (" `format' in y `sec' in g ")"   " `level'% Conf. Interval [" `format' in y exp(`lb') ", " `format' exp(`ub') in g "]"
}


return scalar b = `b'
return scalar se = `sec'
return scalar lb = `lb'
return scalar ub = `ub'
return scalar pval = `pval'

return local cmd = "p2ci"
end

 


