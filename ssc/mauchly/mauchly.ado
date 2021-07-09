*Version Jan 22, 2017

program drop _all
matrix drop _all
scalar drop _all

program define mauchly
version 12
syntax varlist(min=1) [, m(varlist)]

qui sum `varlist'
scalar n=_N
 
tempvar rowmiss
qui egen `rowmiss'=rmiss(`varlist')
qui sum `rowmiss'
        if r(max)>0{
                display as error "Missing values in varlist"
                exit 198
                    }
					
if "`m'"!="" {
qui xtset
preserve
tempvar id
qui gen `id'=`r(panelvar)'
qui separate `varlist', by(`m') generate(xistq_)
qui collapse xistq_*, by(`id')
scalar n=_N
mkmat xistq_*, mat(T)
restore
}


capture sum `m'
capture scalar k1=r(max)
capture qui corr `varlist', cov
capture scalar k1 = rowsof(r(C))

    if k1<3 & k1!=1{
    display as error "Mauchly test is inapplicable with two levels"
    exit 198
   }
   
   if "`m'"==""  & k1<2{
   di as error "Please specify repeated measures, m(varlist)"
   exit 198
   }
   
if "`m'"!="" {
mata: X=st_matrix("T")
 }
 else {
mata: X = st_data(.,("`varlist'"))
}
mata: cov=quadvariance(X)
mata: col_mean=(mean(cov))'
mata: row_mean=(mean(cov'))'
mata: gmean=mean(vec(cov))
mata: k =cols(X)
mata: U =J(k,k,gmean)
mata: col_mean2=mm_repeat(col_mean,1,k)
mata: row_mean2=mm_repeat(row_mean',k,1)
mata: d_centered=((cov - col_mean2)- row_mean2) + U
mata: eigen=symeigenvalues(d_centered)
mata: st_matrix("eigen",eigen)

scalar k = colsof(eigen)
scalar k2=comb(k,2)


forvalues i=1/`=k' {
qui scalar e`i' = round(el(eigen,1,`i'), 0.000001)
}

tempvar esum esum2 eds Huyhn
qui gen `esum'=e1
qui gen `esum2'=e1
qui gen `eds'=e1^2
forvalues i=2/`=k' {
qui replace `esum'= `esum'+e`i' if e`i'!=0
qui replace `esum2'= `esum2'*e`i' if e`i'!=0
qui replace `eds'= `eds'+e`i'^2 if e`i'!=0
}

scalar esum=`esum'
scalar esum2=`esum2'
scalar eds=`eds'

*Mauchly's Test of Sphericity
scalar W=round((esum2)/((1/(k-1)*(esum))^(k-1)), 0.0001)

scalar fw=1-((2*((k-1)^2)+(k-1)+2))/((6*(k-1)*(n-1)))
scalar dfw=(k*(k-1)/2)-1
scalar X2w=-1*(n-1)*fw*ln(W)
scalar pval=round(chi2tail(dfw, X2w), 0.0001)

*********************************************
*Greenhouse-Geisser & Huynh-Feldt corrections
*********************************************
scalar V=(esum^2)/(eds)

scalar Eta=round((1/(k-1)*V), 0.0001)
scalar l_bound=round(1/(k-1), 0.0001)

qui gen `Huyhn'= round((n*(k-1)*Eta-2)/((k-1)*(n-1-(k-1)*Eta)),0.0001)
qui replace `Huyhn'=1 if `Huyhn'>=1
scalar Huyhn=round(`Huyhn', 0.0001)
scalar W=round(W, 0.0001)


di in b ""
di in ye "Mauchly's Test of Sphericity
di as text _dup(80) "_"
di in gr " Mauchly's W.   Chi2.   d.f.    P-value.   Epsilon_gg.   Epsilon_ff. Lower-bound
di as text _dup(80) "_"
di in gr       "  "%5.4f W "       " %5.4f X2w "     " dfw "      "   pval  "       " %5.4f Eta   "        "%5.4f  Huyhn  "       " %5.4f l_bound
di as text _dup(80) "_"
scalar drop _all
matrix drop _all

end
