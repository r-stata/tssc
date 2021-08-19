program mvdcmpgroup, eclass
*! version 2 27apr2017 Dan Powers
// previous update 18sept2010
// program doesn't use erets related to E,C,R anymore.
// debugged
// scale now included in this program too
// Note: preliminary tests show that this works with 
//       the official version of -mvdcmp-
syntax anything [, NOCONS]
tempvar touse
global mvdcmp_scale `e(scale)'
global mvdcmp_varlist `e(indvar)' _cons
global mvdcmp_nvar: word count $mvdcmp_varlist
global mvdcmp_nvar2 = $mvdcmp_nvar - 1
forval i = 1/$mvdcmp_nvar {
global mvdcmp_varname`i' : word `i' of $mvdcmp_varlist
}
forval i = 1/$mvdcmp_nvar {
local Avarlist `Avarlist' A:${mvdcmp_varname`i'}
}
global mvdcmp_depvar `e(depvar)'
global mvdcmp_lab0 `e(high)'
global mvdcmp_lab1 `e(low)'
global mvdcmp_N `e(N)'
mat Coef = e(b) 			   // changed from e(Coef) to e(b)
mat Coef1 = Coef[1,1..${mvdcmp_nvar}*2] // added 18sept2010 
mat Var = e(V)  			   // changed from e(Var) to e(V) 18sept2010
mat Var1 = Var[1..${mvdcmp_nvar}*2,1..${mvdcmp_nvar}*2] 
mat w = Coef1[1, 1..$mvdcmp_nvar]
mat x = Coef1[1, $mvdcmp_nvar+1...]
mat y = Var1[1..$mvdcmp_nvar, 1..$mvdcmp_nvar]
mat z = Var1[$mvdcmp_nvar+1..., $mvdcmp_nvar+1...]
mat coln w = `Avarlist'
mat coln x = `Avarlist'
mat coln y = `Avarlist'
mat coln z = `Avarlist'
mat rown y = `Avarlist'
mat rown z = `Avarlist'
local i 0
while (1) {
        if `"`anything'"'=="" continue, break
        gettoken group anything : anything, match(paren)
          if index(`"`group'"',":") {
          gettoken gname vars : group, parse(":")
          gettoken colon vars : vars,  parse(":")
          local gname = trim(`"`gname'"')
          unab vars: `vars'
          local vgrplegend `vgrplegend' (`gname': `vars')
          }
            else {
            gettoken gname : group
            unab vars: `group'
            local vars `group'
            local vgrplegend `vgrplegend' (`gname': `vars')
            }
            local gvarlist `gvarlist' `vars'
            local vgrp`++i' `vars'
            local vgrpnms `vgrpnms' `gname'
           }
local i 0
while (1) {
        if `"`vgrplegend'"'=="" continue, break
        gettoken vgrplegend`++i' vgrplegend : vgrplegend, match(paren)
        global mvdcmp_ngrp `i'
        }
if "`nocons'"!=""{
local vgrplegend`++i' nocons: `e(indvar)'
global mvdcmp_ngrp `i'
}
forval i=1/$mvdcmp_ngrp{
gettoken tempgrpname`i' 1:vgrplegend`i', parse(:)
gettoken 0 tempwords`i':1, parse(:)
local grpnames `grpnames' `tempgrpname`i''
}
forval i=1/1{
mat a=0
mat c=0
mat e=0
mat g=0
local nowords: word count `tempwords`i''
   forval j=1/`nowords'{
   local tempword: word `j' of `tempwords`i''
   mat a`j' = w[1, "A:`tempword'"]
   mat a = a + a`j'
   mat c`j' = x[1, "A:`tempword'"]
   mat c = c + c`j'
      forval k=1/`nowords'{
      local tempword2: word `k' of `tempwords`i''
      mat e`j'`k'=y["A:`tempword'", "A:`tempword2'"]
      mat e=e+e`j'`k'
      mat g`j'`k'=z["A:`tempword'", "A:`tempword2'"]
      mat g=g+g`j'`k'
      }
   }
mat b = a
mat d = c
mat f = e
mat h = g
}
forval i=2/$mvdcmp_ngrp{
mat a=0
mat c=0
mat e=0
mat g=0
local nowords: word count `tempwords`i''
   forval j=1/`nowords'{
   local tempword: word `j' of `tempwords`i''
   mat a`j' = w[1, "A:`tempword'"]
   mat a = a + a`j'
   mat c`j' = x[1, "A:`tempword'"]
   mat c = c + c`j'
      forval k=1/`nowords'{
      local tempword2: word `k' of `tempwords`i''
      mat e`j'`k'=y["A:`tempword'", "A:`tempword2'"]
      mat e=e+e`j'`k'
      mat g`j'`k'=z["A:`tempword'", "A:`tempword2'"]
      mat g=g+g`j'`k'
      }
   }
mat b = (b, a)
mat d = (d, c)
mat f = (f, e)
mat h = (h, g)
}
*****E, C, R
mat E=Coef[1,${mvdcmp_nvar}*2+1] /***changed 20100918*/
mat C=Coef[1,${mvdcmp_nvar}*2+2] /***changed 20100918*/
mat R=Coef[1,${mvdcmp_nvar}*2+3] /***changed 20100918*/
mat sE=Var[${mvdcmp_nvar}*2+1,${mvdcmp_nvar}*2+1] /***added 20100918*/
mat sC=Var[${mvdcmp_nvar}*2+2,${mvdcmp_nvar}*2+2] /***added 20100918*/
mat sR=Var[${mvdcmp_nvar}*2+3,${mvdcmp_nvar}*2+3] /***added 20100918*/
mata: E=st_matrix("E")
mata: C=st_matrix("C")
mata: R=st_matrix("R")
mata: sE=st_matrix("sE")
mata: sC=st_matrix("sC")
mata: sR=st_matrix("sR")
mata:ZvalueE=E/sE
mata:ZvalueC=C/sC
mata:ZvalueR=R/sR
mata:PctE=100*E/(E+C)
mata:PctC=100*C/(E+C)
mata:El=E-1.96*sE
mata:Eh=E+1.96*sE
mata:Cl=C-1.96*sC
mata:Ch=C+1.96*sC
mata:Rl=R-1.96*sR
mata:Rh=R+1.96*sR
mata:st_matrix("El", El)
mata:st_matrix("Eh", Eh)
mata:st_matrix("Cl", Cl)
mata:st_matrix("Ch", Ch)
mata:st_matrix("Rl", Rl)
mata:st_matrix("Rh", Rh)

// added 7sept2010 (start)
global mvdcmp_ZE=ZE[1,1]
global mvdcmp_ZC=ZC[1,1]
global mvdcmp_ZR=ZR[1,1]
global mvdcmp_PE=PE[1,1]
global mvdcmp_PC=PC[1,1]
global mvdcmp_PZE=PZE[1,1]
global mvdcmp_PZC=PZC[1,1]
global mvdcmp_PZR=PZR[1,1]
global mvdcmp_El = El[1,1]
global mvdcmp_Eh = Eh[1,1]
global mvdcmp_Cl = Cl[1,1]
global mvdcmp_Ch = Ch[1,1]
global mvdcmp_Rl = Rl[1,1]
global mvdcmp_Rh = Rh[1,1]
// added 7sept20 (end)

// each group
mata: DCE =st_matrix("b")
mata: CWdb=st_matrix("d")
mata: Var_E_k=st_matrix("f")
mata: Var_C_k=st_matrix("h")
mata: seWdx=sqrt(Var_E_k)
mata: seWdb=sqrt(Var_C_k)
mata:ZEWdx=DCE:/seWdx
mata:ZCWdb=CWdb:/seWdb
mata: PZE=2*normal(-abs(ZvalueE))
mata: PZC=2*normal(-abs(ZvalueC))
mata:PCTcom=100*(DCE:/(E+C))
mata:PCTcoe=100*(CWdb:/(E+C))
mata:st_matrix("DCE", DCE)
mata:st_matrix("CWdb", CWdb)
mata:st_matrix("seWdx", seWdx)
mata:st_matrix("seWdb", seWdb)
mata:st_matrix("ZEWdx", ZEWdx)
mata:st_matrix("ZCWdb", ZCWdb)
mata:st_matrix("PZE", PZE)
mata:st_matrix("PZC", PZC)
mata:st_matrix("PCTcom", PCTcom)
mata:st_matrix("PCTcoe", PCTcoe)

forval i = 1/$mvdcmp_ngrp{
global mvdcmp_varname`i' : word `i' of `grpnames'
global mvdcmp_DCE`i'=DCE[1,`i']*$mvdcmp_scale
global mvdcmp_seWdx`i'=seWdx[1,`i']*$mvdcmp_scale
global mvdcmp_ZEWdx`i'=ZEWdx[1,`i']
global mvdcmp_PZE`i'=2*normal(-abs(${mvdcmp_ZEWdx`i'}))
global mvdcmp_El`i'=${mvdcmp_DCE`i'}-1.96*${mvdcmp_seWdx`i'}
global mvdcmp_Eh`i'=${mvdcmp_DCE`i'}+1.96*${mvdcmp_seWdx`i'}
global mvdcmp_PCTcom`i'=PCTcom[1,`i']
global mvdcmp_CWdb`i'=CWdb[1,`i']*$mvdcmp_scale
global mvdcmp_seWdb`i'=seWdb[1,`i']*$mvdcmp_scale
global mvdcmp_ZCWdb`i'=ZCWdb[1,`i']
global mvdcmp_PZC`i'=2*normal(-abs(${mvdcmp_ZCWdb`i'}))
global mvdcmp_Cl`i'=${mvdcmp_CWdb`i'}-1.96*${mvdcmp_seWdb`i'}
global mvdcmp_Ch`i'=${mvdcmp_CWdb`i'}+1.96*${mvdcmp_seWdb`i'}
global mvdcmp_PCTcoe`i'=PCTcoe[1,`i']
}
displayresult
forval i = 1/$mvdcmp_ngrp{
di as txt "`vgrplegend`i''"
}
macro drop mvdcmp*
end

program displayresult, eclass
local format	
{
		di 
		di as text "Version 2.0"
        di %10s as text "Decomposition Results"              as text %55s    "Number of obs =   "   as res %7s "$mvdcmp_N"
        di as text "{hline 13}{hline 70}"
	    di as text "High outcome group: " as res "`e(high)'"  as text " ---  Low outcome group: " as res "`e(low)'""
/*
	di as text "{hline 11}{c TT}{hline 71}"
        di as text %11s "$mvdcmp_depvar" _col(10) as text "{c |}" _col(11) as text %11s "Coef." _col(22) as text %11s "Std. Err." _col(29) as text %8s "z" _col(38) /*
        */ as text %9s "P>|z|" _col(47) as text %24s "[95% Conf. Interval]" _col(71) as text %8s "Pct."
        di as text "{hline 11}{c +}{hline 71}"
        di as text %11s  "E"       _col(10) as text "{c |}"  as res %11.5g $mvdcmp_E as res %11.5g $mvdcmp_seE as res %8.2fc $mvdcmp_ZE /*
        */as res %9.3fc $mvdcmp_PZE as res %12.5g $mvdcmp_El as res %12.5g $mvdcmp_Eh   as res %8.5g $mvdcmp_PE
        di as text %11s  "C"        _col(10) as text "{c |}" as res %11.5gc $mvdcmp_C as res %11.5gc $mvdcmp_seC as res %8.2fc $mvdcmp_ZC /*
        */as res %9.3fc $mvdcmp_PZC as res %12.5g $mvdcmp_Cl as res %12.5g $mvdcmp_Ch   as res %8.5g $mvdcmp_PC
        di as text "{hline 11}{c +}{hline 71}"
di as text %11s  "R"        _col(10) as text "{c |}" as res %11.5gc $mvdcmp_R as res %11.5gc $mvdcmp_seR as res %8.2fc $mvdcmp_ZR /*
        */as res %9.3fc $mvdcmp_PZR as res %12.5g $mvdcmp_Rl as res %12.5g $mvdcmp_Rh as res %8.5g
*/
        di
        di %~84s as text "Due to Difference in Characteristics (E)"
        di as text "{hline 11}{c TT}{hline 71}"
        di as text %10s "$mvdcmp_depvar", _col(10) as text "{c |}" _col(11) as text %11s "Coef." _col(22) as text %11s "Std. Err." _col(29) as text %8s "z" _col(38) /*
        */ as text %9s "P>|z|" _col(47) as text %24s "[95% Conf. Interval]" _col(71) as text %8s "Pct."
        di as text "{hline 11}{c +}{hline 71}"
forval i = 1/$mvdcmp_ngrp{
        di as text %10s  "${mvdcmp_varname`i'}", _col(10) as text "{c |}" as res %11.5g ${mvdcmp_DCE`i'}  as res %11.5g ${mvdcmp_seWdx`i'} /*
        */ as res %8.2fc ${mvdcmp_ZEWdx`i'} as res %9.3fc ${mvdcmp_PZE`i'} as res %12.5g ${mvdcmp_El`i'} as res %12.5g ${mvdcmp_Eh`i'}  as res %8.5g ${mvdcmp_PCTcom`i'}
}
        di as text "{hline 11}{c BT}{hline 71}"
        di
        di %~84s as text "Due to Difference in Coefficients (C)"
        di as text "{hline 11}{c TT}{hline 71}"
        di as text %10s "$mvdcmp_depvar", _col(10) as text "{c |}" _col(11) as text %11s "Coef." _col(22) as text %11s "Std. Err." _col(29) as text %8s "z" _col(38) /*
        */ as text %9s "P>|z|" _col(47) as text %24s "[95% Conf. Interval]" _col(71) as text %8s "Pct."
        di as text "{hline 11}{c +}{hline 71}"
forval i = 1/$mvdcmp_ngrp {
        di as text %10s  "${mvdcmp_varname`i'}", _col(10) as text "{c |}" as res %11.5g  ${mvdcmp_CWdb`i'}  as res %11.5g ${mvdcmp_seWdb`i'} /*
        */ as res %8.2fc ${mvdcmp_ZCWdb`i'} as res %9.3fc ${mvdcmp_PZC`i'} as res %12.5g ${mvdcmp_Cl`i'} as res %12.5g ${mvdcmp_Ch`i'}  as res %8.5g ${mvdcmp_PCTcoe`i'}
}
        di as text "{hline 11}{c BT}{hline 71}"
	
}
end
