program define _gvreldif, sortpreserve

    version 10

    gettoken type 0 : 0
    gettoken g    0 : 0
    gettoken eqs  0 : 0

    syntax varlist [if] [in] , BY(string)

    marksample touse, novarlist

    capture confirm variable `by'
    if _rc {
       di as err "`by' found where varlist expected"
       exit 7
    }
    sort `by' `_sortorder'
    capture bysort `by' : assert _N <= 2
    if _rc {
       di as err "the data should have at most two observations per unique combination(s) of `by'"
       exit 9
    }

    tempvar vrd panelid
    qui bysort `by' : gen long `panelid' = (_n==1)
    qui replace `panelid' = sum(`panelid')
    qui gen double `vrd' = .

    mata : VRelDif( "`varlist'", "`panelid'", "`vrd'", "`touse'" )

    qui generate `type' `g' = `vrd'

end

version 10
mata

void VRelDif( string scalar varlist, string scalar byname, string scalar genname, string scalar tousename ) {

   real matrix x, thex, gen, thegen, by, info;
   real scalar i;

   st_view(x=.,   ., tokens(varlist), tousename)
   st_view(by=.,  ., tokens(byname),  tousename)
   st_view(gen=., ., tokens(genname), tousename)

   info = panelsetup( by, 1, 2, 2)
   for(i=1;i<=rows(info);i++) {
      thex  = panelsubmatrix( x, i, info )
      panelsubview( thegen, gen, i, info )
      thegen[,] = J(rows(thegen),1, mreldif( thex[1,.], thex[2,.] ) )
   }

}

end

exit
