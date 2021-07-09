* Version 3.91 - 29 Feb 2020
* By J.A.F. Machado, Paulo M.D.C Parente and J.M.C. Santos Silva 
* Please email jmcss@surrey.ac.uk for help and support
* We are grateful to Fernando Rios-Avila for help with this code.

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.


program define qreg2, eclass                                                                       
version 11.0                                                                                       
if replay() {
                _prefix_display
                exit
        }                       
syntax [varlist(fv numeric)] [if] [in] [fweight] [,  Quantile(real .5) NOTest mss(string) WLSiter(integer 1) Cluster(string) Epsilon(real 1e-7) Silverman]           
marksample touse 

markout `touse'  `cluster', s 
tempname  _e _ae _ep50 _hsi _dens _rhs _y _gv _id _g _w _f _f2 _check _fw A D Vm phi sphi sphi2 numt ct tt _oldsort one  _V oldest
gettoken _y _rhs: varlist
if ("`_rhs'")~=("") fvunab _rhs :  `_rhs'
if "`weight'"=="" qui g `_fw'=1 if `touse'
else qui g `_fw' `exp' if `touse'

if ("`weight'"~="")&("`cluster'"~="") {
di as error "Options cluster and weights are not compatible"
exit
}

qui g `_oldsort'=_n
_rmcoll `_rhs' if `touse', expand 
local _rhss "`r(varlist)'"
qui qreg `_y' `_rhss' if `touse' [fweight=`_fw'], quantile(`quantile') wls(`wlsiter')
local cn:colnames e(b) 
local _eta=e(q)
local _k=e(df_m)+1
local enne=e(N)
matrix `_V'=e(V)
qui predict double `_f' if (`touse'), xb
qui predict double `_e' if (`touse'), res
qui g double `_ae'=abs(`_e') if (`touse')
qui su `_ae' if (`touse'), d
qui replace `_e'=0 if ((`touse')&(`_ae'<r(p50)*`epsilon'))
qui count if ((`touse')&(`_ae'<r(p50)*`epsilon'))
qui local zeros=r(N)

qui local _hs=(invnormal(0.975)^(2/3))*(((1.5*((normalden(invnormal(`_eta')))^2))/(2*((invnormal(`_eta'))^2) + 1))^(1/3))                                       
qui su `_e' [fweight=`_fw'] if (`touse'),d
if ("`silverman'"=="silverman") local ah=min(r(sd),(r(p75)-r(p25))/1.34)
if ("`silverman'"==""){
 qui g double `_ep50'=abs(`_e'-r(p50)) if (`touse')
 qui su `_ep50' [fweight=`_fw'] if (`touse'),d
 local ah=r(p50)
}
if (`_eta'+`_hs'*(r(N)^(-1/3)))>1|(`_eta'-`_hs'*(r(N)^(-1/3)))<0{
di as error "Cannot compute bandwidth; too few observations?"
exit
}
qui g double `_hsi'=`ah'*(invnormal(`_eta'+`_hs'*(r(N)^(-1/3)))-invnormal(`_eta'-`_hs'*(r(N)^(-1/3))))   if (`touse')
qui g double `_dens'=sqrt((`_fw')*(abs(`_e')<`_hsi')/(2*`_hsi'))  if (`touse')
qui g `_w' = sqrt(`_fw')*(`_eta'-(`_e'<=0)) if `touse'
qui g `_gv'=_n if `touse'
if "`cluster'"=="" qui g `_id'=_n  if `touse'
****
else qui g `_id'=`cluster'*sqrt(`_fw') if `touse'
****

qui g `one'=1 if `touse'
sort `_id'  
if ("`_rhss'")~=("") mata:myopaccum("`A'","`_rhss'","`_id'","`_w'","`touse'")
else matrix opaccum `A' = `_rhss' `one' if `touse', group(`_id') opvar(`_w') noconstant 
sort `_gv'  
if ("`_rhss'")~=("") mata:myopaccum("`D'","`_rhss'","`_gv'","`_dens'","`touse'")
else matrix opaccum `D' = `_rhss' `one' if `touse', group(`_gv') opvar(`_dens') noconstant 
matrix `Vm'=invsym(`D')*`A'*invsym(`D') 

if "`cluster'" ~= "" {
qui by `cluster', sort: egen `ct'=count(1) if (`touse')
qui by `cluster', sort: egen `tt'=seq() if (`touse')
sort `_oldsort'
qui count if `tt'==1
local clust=r(N)
}
ereturn repost  V = `Vm'
_est hold `oldest', c r
*** Display results ======================================================
di 
if `_eta'==0.5 {
di as txt "Median regression"
} 
else {
di as txt `_eta' " Quantile regression"
}

qui corr `_f' `_y' [fweight=`_fw'] if (`touse')
di as text "R-squared = " _continue
di as result r(rho)^2
local r_2=r(rho)^2

di as txt "Number of obs = "  _continue
di as result   `enne'

qui g double `_check'=`_e'*(`_eta'-(`_e'<=0)) if (`touse')
qui su `_check' [fweight=`_fw'] if (`touse')
di  as text "Objective function = " _continue
di as result r(mean)
local check=r(mean)

di 
if (`_k'==1&"`cluster'" == "") {
di as txt "                     Standard errors valid with i.i.d. errors"
}
else {                            
if "`cluster'" ~= "" {
di as txt "Standard errors adjusted for " _continue" 
di as result `clust' _continue
di as txt " clusters in `cluster'"
}
else {
di as txt "                     Heteroskedasticity robust standard errors"
}   
}
ereturn display
*** Do MSS ===============================================================
if ("`notest'" == "")&("`cluster'"=="") {
local empty=0
 
if "`mss'"==""{
local empty=1
qui g double `_f2'= `_f'^2 if  (`touse')
local mss "`mss' `_f' `_f2'"
}
local _k : word count `mss'
qui reg  `_check' `mss' [fweight=`_fw'] if  (`touse')
local MSS=e(N)*e(r2)
qui  su `_check', meanonly
di 
di as txt "Machado-Santos Silva test for heteroskedasticity"
di as txt "         Ho: Constant variance"
di as txt "         Variables: " _continue
if `empty'==1 {
di as result "Fitted values of `_y' and its squares"
}
else di as result "`mss'"
di
di as txt "         chi2(" _continue
di as result `_k' _continue
di as txt ")" _continue
di _column(23) "=  " _continue
di %6.3f as result `MSS'
di as txt "         Prob > chi2  =  " _continue
di %6.3f as result chi2tail(`_k',`MSS') 
}


*** Do PSS ===============================================================
if ("`notest'" == "")&("`cluster'"~="")  {
if (`clust'<`enne') {
qui g double `phi'=`_eta'-(`_e'<0) if (`touse')
qui egen `sphi'=sum(`phi') if (`touse'), by(`cluster')
qui egen `sphi2'=sum(`phi'^2) if (`touse'), by(`cluster')
qui g double `numt'=(`sphi'^2-`sphi2')/sqrt(2*(`_eta'^2)*((1-`_eta')^2)*`ct'*(`ct'-1)) if ((`touse')&(`tt'==1)&(`ct'>1))
qui su `numt' if ((`touse')&(`tt'==1)&(`ct'>1))
qui local PSS=r(mean)*sqrt(r(N))

di 
di as txt "Parente-Santos Silva test for intra-cluster correlation"
di as txt "         Ho: No intra-cluster correlation"
di
di as txt "            T" _continue
di _column(17) "=  " _continue
di %6.3f as result `PSS'
di as txt "         P>|T|  =  " _continue
di %6.3f as result 2*normal(-abs(`PSS')) 
}
}
*** Return results ========================================================
_est unhold `oldest'
qui ereturn display
ereturn local cmd "qreg2"
if ("`notest'" == "")&("`cluster'"=="")  {
ereturn scalar mss_chi2 = `MSS'
ereturn scalar mss_df = `_k'
ereturn scalar mss_p = chi2tail(`_k',`MSS')
}
if ("`notest'" == "")&("`cluster'"~="")  {
if (`clust'<`enne') {
ereturn scalar pss_t = `PSS'
ereturn scalar pss_p = 2*normal(-abs(`PSS'))
}
}
ereturn scalar obj_func = `check'
ereturn scalar r2 = `r_2'
ereturn scalar zeros = `zeros'

if "`weight'"!="" ereturn local wexp "`exp'"
else              {
ereturn local wexp "`exp'"
ereturn local wtype "" 
}
end


*** This code by Fernando Rios-Avila should do the same oppaccum 
*** does but allows for factor notation. Just like with opaccum
*** it assumes sorting by "group" variable

mata: 
void myopaccum(string scalar mout, string scalar indepvar, 
			   string scalar gvar, string scalar opvar,
			   string scalar touse) {
	real matrix ivar_, gvar_, opvar_
	real matrix M, info, nc, xi, ei
	real scalar i, k
	ivar_  =st_data(.,indepvar,touse)
	gvar_  =st_data(.,gvar,touse)
	opvar_ =st_data(.,opvar,touse)
	ivar_ =ivar_ ,J(rows(ivar_),1,1)
	
	/// This "detects" the panel part
	info = panelsetup(gvar_, 1)
	nc   = rows(info)
	k=cols(ivar_)
	M    = J(k, k, 0)
	for(i=1; i<=nc; i++) {
		xi = panelsubmatrix(ivar_ ,i,info)
		ei = panelsubmatrix(opvar_,i,info)
		M  = M + quadcross(xi,ei)*quadcross(ei,xi)
	}
	st_matrix(mout,M)
}
end



