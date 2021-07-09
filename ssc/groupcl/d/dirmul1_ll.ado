program define dirmul1_ll
    version 9.0
    args todo b lnf g
    tempvar theta s1 s2 s3 s4 last ysum
    mleval `theta'=`b'
    local by $GROUP
    quietly {
    sort `by'
    by `by':gen double `s1'=lngamma($ML_y1+exp(`theta'))-lngamma(exp(`theta'))-lnfact($ML_y1)
    by `by':gen double `s2'=sum(`s1')
    by `by': replace `s2'=`s2'[_N]
    by `by':gen double `s3'=sum(exp(`theta'))
    by `by':replace `s3'=`s3'[_N]
    by `by':gen double `ysum'=sum($ML_y1)
    by `by':replace `ysum'=`ysum'[_N]
    by `by':gen double `s4'=lngamma(`s3')-lngamma(`s3'+`ysum')+`s2'+lnfact(`ysum')
    by `by':gen `last'=( _n==_N)
    mlsum `lnf'=`s4' if `last'
    sum `s4' if `last'
    if (`todo'==0 | `lnf'>=.) exit
    mlvecsum `lnf' `g' =(digamma(`s3')-digamma(`s3'+`ysum'))*exp(`theta')  ///
    +(digamma($ML_y1+exp(`theta'))-digamma(exp(`theta')))*exp(`theta')
    }
end
