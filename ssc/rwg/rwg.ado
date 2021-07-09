*Version August, 2012

program drop _all
program define rwg
version 9
syntax varlist(min=1 max=1) [, scale(integer 5) model(integer 2) ]

capture qui tsset
local id `r(panelvar)'
marksample touse

qui sum `varlist', detail
    if r(min)<0 {
    display as error "Negative value in varlist"
    exit 198
   }

qui scalar A=`scale'
    if A<2 | A<r(max){
    di as err "Please correctly specify response scale"
    exit 198    
   }

if `model' != 1 & `model' != 2{
	di as err "Please select from Rwg models 1 and 2"
	exit 198
	}

if `model' == 2 {
   *Model(2): Multiple-item estimator
qui tsset
    if r(balanced)=="unbalanced"{
    display as error "Unbalanced panel"
    exit 198
   }

qui xtsum `id'
qui scalar s1=r(Tbar)
qui scalar g1=r(n)

if g1==1{
      di as err "Single item found. Please estimate model 1"  
      exit 198
    }

*seu =(A^2 - 1)/12
qui scalar seu=sum(`scale'^2-1)/12

tempvar sd sxj rwg
qui egen `sd'= sd(`varlist'), by(`id')
qui egen `sxj'=mean(`sd'*`sd'), by(`id')
qui gen `rwg'=g1*(1-(`sxj'/seu))/(g1*(1-(`sxj'/seu))+(`sxj'/seu))
qui replace `rwg' =0 if  `rwg'<0
qui sum `rwg', detail
qui scalar Rwg=r(mean)
qui scalar median=r(p50)
qui scalar range=r(max)-r(min)
     di in gr "        ***********************************************************
     di in ye "            Interrater Agreement Rwg(j): Multiple-item Estimate
     di in gr "        ***********************************************************
     di in gr "        Judges         : "  s1 
     di in gr "        Items          : "  g1
     di in gr "        Response Scale : " `scale'
     di in ye "        Rwg(j)         : " %5.4f Rwg ", median: (" %5.4f median "), range: (" %5.4f range ")"
     di in gr "        ***********************************************************
scalar drop _all
}

if `model' == 1 {
*Model(1): Single-item estimator

qui xtsum `id'
qui scalar s1=r(Tbar)
qui scalar g1=r(n)
   if g1>1{
   di as err "Multiple items found. Please estimate model 2"
   exit 198
  }

*seu =(A^2 - 1)/12
scalar seu=sum(`scale'^2-1)/12

tempvar sd sxj rwg
qui egen `sd'= sd(`varlist'), by(`id')
qui egen `sxj'=mean(`sd'*`sd'), by(`id')
qui gen `rwg'=1-(`sxj'/seu)
qui replace `rwg'=0 if  `rwg'<0
qui ci `rwg'
qui scalar Rwg=r(mean)

     di in gr "        *************************************************
     di in ye "        Interrater Agreement Rwg(i): Single-item Estimate
     di in gr "        *************************************************
     di in gr "        Judges         : "  s1 
     di in gr "        Item           : "  g1
     di in gr "        Response Scale : " `scale'
     di in ye "        Rwg(i)         : " %5.4f Rwg
     di in gr "        *************************************************
scalar drop _all

}
end
