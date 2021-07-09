!* version 1.0.0 15Oct2006
* Author: Paulo Guimaraes
program define multin2_ll
    version 9.0
    args todo b lnf g negH g1
    tempvar theta sumvij prob ysum a1 a2
    mleval `theta'=`b'
    local by $GROUP
    sort `by'
    quietly {
    by `by': egen double `sumvij'=sum(exp(`theta'))
    gen double `prob'=exp(`theta')/`sumvij'
    mlsum `lnf'=$ML_y1*(`theta'-log(`sumvij'))
    if (`todo'==0 | `lnf'>=.) exit
    by `by': egen `ysum'=sum($ML_y1)
    mlvecsum `lnf' `g' = $ML_y1-`ysum'*`prob'
    if (`todo'==1 | `lnf'>=.) exit
    mlmatsum `lnf' `a1'=`ysum'*`prob'
    mlmatbysum `lnf' `a2' $ML_y1 `prob', by(`by')
    matrix `negH'= (`a1'-`a2')
    }
end
