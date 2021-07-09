* Likelihood Function for the Dirichlet-Multinomial assuming identical that the
* intraclass correlation is a function of other variables!!!
* This is for d0 routine
* Need to change to d2
program define dirmul2_ll
    version 7.0
    args todo b lnf
    tempvar xb theta pjg s1 s2 s3 s4 last ysum z
    mleval `xb'=`b', eq(1)
    mleval `theta'=`b', eq(2)
    local by $GROUP
    quietly {
    sort `by'
    gen double `z'=log((`theta'/(1-`theta')))
    by `by':gen double `s1'=exp(`xb')
    by `by':gen double `s2'=sum(`s1')
    by `by':gen double `pjg'=`s1'/`s2'[_N]
    by `by':gen double `s3'=sum(lngamma($ML_y1+`pjg'/exp(`z'))-lngamma(`pjg'/exp(`z'))-lnfact($ML_y1))
    by `by':replace `s3'=`s3'[_N]
    by `by':gen double `ysum'=sum($ML_y1)
    by `by':replace `ysum'=`ysum'[_N]
    by `by':gen double `s4'=lngamma(1/exp(`z'))-lngamma(1/(exp(`z'))+`ysum')+`s3'+lnfact(`ysum')
    by `by':gen `last'=( _n==_N)
    mlsum `lnf'=`s4' if `last'
    }
end
