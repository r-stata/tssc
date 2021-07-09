*Version March 2014

program drop _all
program define pindex
version 9
syntax [if] [in] [, p(varlist) q(varlist) base(integer 5) by(varlist) method(string) outfile  replace]

tempvar rowmin
qui egen `rowmin'=rmin(`p' `q')
qui sum `rowmin'
        if r(min)<0 {
                display as error "Negative value(s) in price or quantity variable"
                exit 198
                    }
marksample touse
tokenize `if' `in'

qui tsset
local id `r(panelvar)'


tempvar time id_ px qx p0 q0 pq0 p0q0 pq p0q s_pq0 s_p0q0 s_pq s_p0q
qui gen `time'=`r(timevar)'
qui gen `id_'=`r(panelvar)'

qui gen `px'=`p' if `base'==`time'
qui gen `qx'=`q' if `base'==`time'

qui egen `p0'=min(`px'), by( `by' `id_')
qui egen `q0'=min(`qx'), by( `by' `id_')


qui gen `pq0'=`p'*`q0'
qui gen `p0q0'=`p0'*`q0'
qui gen `pq'=`p'*`q'
qui gen `p0q'=`p0'*`q'

qui egen `s_pq0'=sum(`pq0'), by( `by' `time')
qui egen `s_p0q0'=sum(`p0q0'), by( `by' `time')
qui egen `s_pq'=sum(`pq'), by( `by' `time')
qui egen `s_p0q'=sum(`p0q'), by( `by' `time')

   
if "`method'"~="laspeyres" & "`method'"~="paasche"  & "`method'"~="marshall" & "`method'"~="fisher" & "`method'"~="walsh"{
di as err "Please select appropriate price index from available options"
	exit 198
	}


*Laspeyres Index: L= Summation(pn*q0)/ Summation(p0*q0)

if "`method'"=="laspeyres" {
qui gen pindex_lasp_`base'=(`s_pq0'/`s_p0q0')*100 `if' `in'
qui label var pindex_lasp_`base' "Laspeyres Price Index"
sum pindex_lasp_`base'
}

*Paasche Index: P= Summation(pn*qn)/ Summation(p0*qn)

if "`method'"=="paasche" {
qui gen pindex_pasch_`base'=(`s_pq'/`s_p0q')*100 `if' `in'
qui label var pindex_pasch_`base' "Paasche Price Index"
sum pindex_pasch_`base'
}

*Fisher Price Index:  SQRT(Paasche*Laspeyres)

if "`method'"=="fisher" {
qui gen pindex_fisher_`base'=(sqrt((`s_pq0'/`s_p0q0')*(`s_pq'/`s_p0q')))*100
qui label var pindex_fisher_`base' "Fisher Ideal Price Index"
sum pindex_fisher_`base'
}

*Marshall-Edgeworth Index: ME= Summation[(q0+qn)*pn]/ Summation[(q0+qn)*p0]

if "`method'"=="marshall" {
tempvar q0qp q0qp0 s_q0qp s_q0qp0
qui gen `q0qp'=(`q0'+`q')*`p'
qui gen `q0qp0'=(`q0'+`q')*`p0'
qui egen `s_q0qp'=sum(`q0qp'), by(`by' `time')
qui egen `s_q0qp0'=sum(`q0qp0'), by(`by' `time')
qui gen pindex_marshall_`base'=(`s_q0qp'/`s_q0qp0')*100  `if' `in'

qui label var pindex_marshall_`base' "Marshall-Edgeworth Index"
sum pindex_marshall_`base'
}

*Walsh Index: W= Summation(pn*SQRT(q0*qn))/ Summation(p0*SQRT(q0*qn))

if "`method'"=="walsh" {
tempvar pq0q  p0q0q s_pq0q  s_p0q0q
qui gen `pq0q'=`p'*(sqrt(`q0'*`q'))
qui gen `p0q0q'=`p0'*(sqrt(`q0'*`q'))

qui egen `s_pq0q'=sum(`pq0q'), by(`by' `time')
qui egen `s_p0q0q'=sum(`p0q0q'), by(`by' `time')
qui gen pindex_walsh_`base'=(`s_pq0q'/`s_p0q0q')*100 `if' `in'

qui label var pindex_walsh_`base' "Walsh Price Index"
sum pindex_walsh_`base'
}


if "`outfile'"=="outfile" { 
preserve
qui egen tag=tag(`by' `time')
qui keep if tag==1 
qui gen time=`time'

qui outsheet `by' time pindex_* using "Pindex.csv",comma `replace'
di in gr "output has been saved in default directory"
pwd
restore
}
end
