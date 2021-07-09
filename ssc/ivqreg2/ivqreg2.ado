* Version 2.3 - 09 Apr 2019
* By J.M.C. Santos Silva
* Please email jmcss@surrey.ac.uk for help and support


* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the author be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define ivqreg2, eclass 
version 14.0
 if replay() {
                _prefix_display
                exit
        }

syntax varlist(numeric min=1) [if] [in],  [INSTruments(string) Quantile(numlist) ls  ///
TECHnique(string) conv_maxiter(integer 5000) conv_ptol(real 1e-6) conv_vtol(real 1e-6)  ///
conv_nrtol(real 1e-6)  tracelevel(string) quickd from(string)]

marksample touse
markout `touse' `instruments'
tempname  _y _rhs bb vold _u b g fsd CC C X fsd1 ones G O fsdu fsdg fsdv g31 g32 _u2 _uv _v U fiu fiv A V bpost V_location V_scale Q OM
gettoken _y _rhs: varlist

unab _rhs :  `_rhs'
_rmcoll `_rhs' if `touse',  forcedrop 
local _rhs "`r(varlist)'"

local insts=1
if ("`instruments'"=="") {
local instruments `_rhs' 
local insts=0    
di as text "Note: no instruments were specified; restricted quantile regression will be performed"  
 }
unab instruments :  `instruments'
_rmcoll `instruments' if `touse',  forcedrop
local instruments "`r(varlist)'"

 
 
local wq : word count `instruments'
local wx : word count `_rhs'
if `wq'<`wx' {
di as error "The model is not identified"
exit
}

if ("`quantile'"=="") {
local quantile=0.5          
 }
foreach x in `quantile'{
if (`x'>=1)|(`x'<=0) {
di as error "quantiles must be between 0 and 1"
exit 
}
}
di
di
di


qui su `_y' if `touse'
if ("`from'"=="") {
local sd=r(sd)
local mu=r(mean)
local from="b0 `mu' g0 `sd'"
}
if "`technique'"=="nr"  qui gmm  (main: (`_y' - {xb: `_rhs'}-{b0})/({xg: `_rhs'}+{g0}))  /// 
(abs((`_y' - {xb:}-{b0})/({xg:}+{g0}))-1) if `touse', /// 
instruments(main 2: `instruments')  winitial(identity) one from(`from') `quickd' ///
technique(`technique') tracelevel(`tracelevel') conv_maxiter(`conv_maxiter') ///
conv_ptol(`conv_ptol') conv_vtol(`conv_vtol')  conv_nrtol(`conv_nrtol')  ///
deriv(main/xb =                           -1/( {xg: }+{g0})   ) ///                           
deriv(main/b0 =                           -1/( {xg: }+{g0})   ) ///
deriv(2/xb = -sign(`_y' - {xb: }-{b0})/( {xg: }+{g0})   ) ///
deriv(2/b0 = -sign(`_y' - {xb: }-{b0})/( {xg: }+{g0})   ) ///
deriv(main/xg =  -(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2)) ///
deriv(main/g0 =  -(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2)) ///
deriv(2/xg =  -abs(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2)) ///
deriv(2/g0 =  -abs(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2))

else qui gmm  (main: (`_y' - {xb: `_rhs'}-{b0})/({xg: `_rhs'}+{g0}))  /// 
(abs((`_y' - {xb:}-{b0})/({xg:}+{g0}))-1) if `touse', /// 
instruments(main 2: `instruments')  winitial(identity) one from(`from') `quickd' ///
technique(`technique') tracelevel(`tracelevel') conv_maxiter(`conv_maxiter') ///
conv_ptol(`conv_ptol') conv_vtol(`conv_vtol')  ///
deriv(main/xb =                           -1/( {xg: }+{g0})   ) ///                           
deriv(main/b0 =                           -1/( {xg: }+{g0})   ) ///
deriv(2/xb = -sign(`_y' - {xb: }-{b0})/( {xg: }+{g0})   ) ///
deriv(2/b0 = -sign(`_y' - {xb: }-{b0})/( {xg: }+{g0})   ) ///
deriv(main/xg =  -(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2)) ///
deriv(main/g0 =  -(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2)) ///
deriv(2/xg =  -abs(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2)) ///
deriv(2/g0 =  -abs(`_y' - {xb: }-{b0})/(({xg: }+{g0})^2))
 
 
qui predict double `_u' if `touse', residuals equation(main)
local objf=e(Q)
local conv=e(converged)
matrix `bb'=e(b) 
matrix `V'=e(V)
local k=e(k)+1
local k1=(`k'-1)/2
local enne=e(N)
matrix `b'=`bb'[1,1..`k1']
matrix `g'=`bb'[1,`k1'+1..`k'-1]
mat `V_location'=`V'[1..`k1',1..`k1']
mat `V_scale'=`V'[`k1'+1..`k'-1,`k1'+1..`k'-1]


di as input "                              MM-QR regression results"
di
di as txt "Number of obs = "  _continue
di as result   `enne'


if ("`ls'"!="") {
mat `G'=`b'
mat `O'=`V_location'
ereturn post `G' `O'
di as input "                                                           Location parameters"
ereturn display, first
di
mat `G'=`g'
mat `O'=`V_scale'
ereturn post `G' `O'
di as input "                                                              Scale parameters"
ereturn display, first
di
}
qui mat score `fsd' = `g' if `touse'
qui replace `fsd' = `fsd'+`bb'[1,`k'-1]
qui su `fsd'
if r(min)<=0 di as error "WARNING: some fitted values of the scale function are negative"


qui g `ones'=1
mata st_view(`C'=.,.,"`instruments' `ones'","`touse'")
mata st_view(`X'=.,.,"`_rhs' `ones'","`touse'")


matrix `G'=J(2*(`wq'+1)+1,`k',0)

qui g `fsd1'=1/`fsd' if `touse'
mata `fsd1'=st_data(.,"`fsd1'","`touse'")
mata st_matrix("`OM'", ((`X')')*((J(1,`wq'+1,1)#(`fsd1')):*(`C')))
mat `G'[1,1]=(`OM')'


qui g `fsdu'=`_u'/`fsd' if `touse'
mata `fsdu'=st_data(.,"`fsdu'","`touse'")
mata st_matrix("`OM'", ((`X')')*(((J(1,`wq'+1,1)#(`fsdu'))):*(`C')))
matrix `G'[1,`k1'+1]=(`OM')'


qui g `fsdg'=sign(`_u')/`fsd' if `touse'
mata `fsdg'=st_data(.,"`fsdg'","`touse'")
mata st_matrix("`OM'", ((`X')')*(((J(1,`wq'+1,1)#(`fsdg')):*(`C'))))
mat `G'[`wq'+2,1]=(`OM')'


qui g `fsdv'=abs(`_u')/`fsd' if `touse'
mata `fsdv'=st_data(.,"`fsdv'","`touse'")
mata st_matrix("`OM'", ((`X')')*(((J(1,`wq'+1,1)#(`fsdv')):*(`C'))))
matrix `G'[`wq'+2,`k1'+1]=(`OM')'


matrix `G'[2*(`wq'+1)+1,`k']=`enne'
matrix vecaccum `g31' = `fsd1' `_rhs'  if `touse'
matrix vecaccum `g32' = `fsdu' `_rhs'  if `touse'
matrix `G'[2*`wq'+3,1]=`g31'
matrix `G'[2*`wq'+3,`k1'+1]=`g32'


mat `O'=J(2*(`wq'+1)+1,2*(`wq'+1)+1,0)
qui matrix accum `CC' = `instruments' if `touse'

qui g `_u2'=(`_u')^2 if `touse'
su `_u2' if `touse', meanonly
matrix `O'[1,1]=r(mean)*`CC'


qui g `_uv'=(`_u')*(abs(`_u')-1) if `touse'
su `_uv' if `touse', meanonly
matrix `O'[1,(`wq'+1)+1]=r(mean)*`CC'
matrix `O'[(`wq'+1)+1,1]=r(mean)*`CC'


qui g `_v'=(abs(`_u')-1)^2 if `touse'
su `_v' if `touse', meanonly
matrix `O'[(`wq'+1)+1,(`wq'+1)+1]=r(mean)*(`CC')


matrix vecaccum `CC' = `ones' `instruments' if `touse'

qui g double `fiu'=. 
qui g double `fiv'=.

foreach qu in `quantile' {

qui qreg `_u' if `touse', q(`qu') vce(iid)
local fu= sqrt(`qu'*(1-`qu'))/(_se[_cons]*sqrt(e(N)))
matrix `Q'=e(b)
qui replace `fiu'=`_u'*(`qu'-(`_u'<=_b[_cons])) if `touse'
su `fiu' if `touse', meanonly
matrix `O'[1,2*(`wq'+1)+1]=((`CC')')*r(mean)/(`fu')
matrix `O'[2*(`wq'+1)+1,1]=(`CC')*r(mean)/(`fu')

qui replace `fiv'=(abs(`_u')-1)*(`qu'-(`_u'<=_b[_cons])) if `touse'
su `fiv' if `touse', meanonly
matrix `O'[2*(`wq'+1)+1,`wq'+2]=(`CC')*r(mean)/(`fu')
matrix `O'[`wq'+2,2*(`wq'+1)+1]=((`CC')')*r(mean)/(`fu')
matrix `O'[2*(`wq'+1)+1,2*(`wq'+1)+1]= (`enne')*(`qu')*(1-`qu')/(`fu')^2

mat `A'=I(`k1'),_b[_cons]*I(`k1'),(`g')'
mat `V'=(`A')*inv(((`G')')*inv(`O')*(`G'))*(`A')'
matrix `bpost'=`b'+`g'*_b[_cons]


matrix colnames `bpost' = `_rhs' _cons
matrix colnames `V' = `_rhs' _cons
matrix rownames `V' = `_rhs' _cons
mat coleq `bpost' = eq1
mat coleq `V' = eq1
mat roweq `V' = eq1

local __b_q=ustrtoname("__b`qu'")
matrix `__b_q' = `bpost'
local __V_q=ustrtoname("__V`qu'")
matrix `__V_q' = `V'
local __Q_q=ustrtoname("__Q`qu'")
matrix `__Q_q' = `Q'

ereturn post `bpost' `V', obs(`enne')
if `insts'==1 di as txt `qu' " Structural quantile function"
else di as txt `qu' " Restricted quantile regression"
ereturn display, first
di
}
if `insts'==1 di as txt "Instruments used: `instruments'"  
ereturn repost , esample(`touse')
ereturn scalar converged = `conv'
ereturn scalar Q = `objf'
ereturn local cmd = "ivqreg"
ereturn local depvar = "`_y'"
ereturn matrix b_location = `b'
ereturn matrix b_scale = `g'
ereturn matrix V_location = `V_location'
ereturn matrix V_scale = `V_scale'
ereturn matrix q = `Q'
local wq : word count `quantile' 
if `wq' > 1 foreach qu in `quantile' {
local __b_q=ustrtoname("__b`qu'")
local b_q=ustrtoname("b`qu'")
ereturn matrix `b_q' = `__b_q'
local __V_q=ustrtoname("__V`qu'")
local V_q=ustrtoname("V`qu'")
ereturn matrix `V_q' = `__V_q'
local __Q_q=ustrtoname("__Q`qu'")
local _Q_q=ustrtoname("q`qu'")
ereturn matrix `_Q_q' = `__Q_q'
}
end
