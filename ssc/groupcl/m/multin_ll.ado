!* version 1.0.0 14Jun2006
* Author: Paulo Guimaraes
program define multin_ll
    version 9.0
    args todo b lnf g negH g1
    tempvar theta vij sumvij lnfysum s3 s4 prob ysum last a1 a2
    mleval `theta'=`b'
    local by $GROUP
    sort `by'
    quietly {
    gen double `vij'=exp(`theta')
    by `by': egen double `sumvij'=sum(`vij')
    gen double `prob'=`vij'/`sumvij'
    gen double `s3'=$ML_y1*ln(`prob')-lnfact($ML_y1)
    by `by': egen double `lnfysum'= sum($ML_y1)
    by `by': replace `lnfysum'= lnfact(`lnfysum'[_N])
    by `by':gen double `s4'=sum(`s3')
    by `by':gen `last'=( _n==_N)
    mlsum `lnf'=`s4'+`lnfysum' if `last'
    if (`todo'==0 | `lnf'>=.) exit
    by `by': egen `ysum'=sum($ML_y1)
    replace `g1'=$ML_y1-`ysum'*`prob'
    mlvecsum `lnf' `g' = `g1'
    if (`todo'==1 | `lnf'>=.) exit
    mlmatsum `lnf' `a1'=`ysum'*`prob'
    mlmatbysum `lnf' `a2' $ML_y1 `prob', by(`by')
    matrix `negH'= (`a1'-`a2')
    }
end
