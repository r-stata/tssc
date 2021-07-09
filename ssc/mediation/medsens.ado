
program define medsens , rclass
version 10.0

foreach 9 in _med_rho _med_delta0 _med_updelta0 _med_lodelta0 _med_rho _med_delta0 _med_updelta0 _med_lodelta0 ///
  _med_delta1 _med_updelta1 _med_lodelta1 _med_tau _med_uptau _med_lotau _med_nu _med_upnu _med_lonu {
capture confirm new variable `9'
if _rc~=0 {
di "Dropping existing variable `9'"
drop `9'
}
}

preserve
capture drop ___s1
gettoken eqn 0 : 0, parse(" ,[") match(paren)
gettoken eqn2 0 : 0, parse(" ,[") match(paren)

if "`eqn2'"=="" {
nois di as error "You must specify two equations"
exit 198
}
gettoken modname1 var1 : eqn
gettoken modname2 var2 : eqn2

syntax  [if] [in] , [SIMs(int 100) eps(real .01) GRaph Level(cilevel)] MEDiate(varname) TREAT(varname)  
marksample touse

gettoken dv1 rhs1 : var1
gettoken dv2 rhs2 : var2

markout `touse' `var1' `var2'


if "`dv1'"~="`mediate'" {
nois di as error "Mediate variable not the dependent variable in equation 1"
exit 198
}

if "`treat'"=="" {
nois di as error "No treatment variable specified. Please specify a treatment variable"
exit 198
}


local ck: list treat & rhs1
if "`ck'"~="`treat'" {
nois di as error "Treatment variable `treat' is not in equation 1."
exit 198
}
local ck: list treat & rhs2
if "`ck'"~="`treat'" {
nois di as error "Treatment variable `treat' is not in equation 2."
exit 198
}
local ck: list mediate & rhs2
if "`ck'"~="`mediate'" {
nois di as error "Mediate variable is not in equation 2."
exit 198
}

local rhs1 : list treat | rhs1
/* Treat first var in eq 2; mediate second var 
put mediate first in rhs2 */
local rhs2 : list mediate | rhs2

if "`modname1'"~="regress" & "`modname1'"~="logit" & "`modname1'"~="probit" {
nois di as error "Mediate only supports OLS, logit, and probit"
if substr("`modname1'",1,3)=="reg" {
nois di as error "Perhaps you meant regress. Mediate requires the full command name"
}
exit 198
}
if "`modname2'"~="regress" & "`modname2'"~="logit" & "`modname2'"~="probit" {
nois di as error "Mediate only supports OLS, logit, and probit"
if substr("`modname2'",1,3)=="reg" {
nois di as error "Perhaps you meant regress. Mediate requires the full command name"
}
exit 198
}

tempvar res_m res_y fit_m fit_y varfit_m varfit_y _s1 _s2

tempname r2m bm v vm  r2y vy by

local cmdline1 `modname1' `dv1' `rhs1'

`cmdline1' if `touse'
gen `_s1' =e(sample)
local samp1 = e(N)
if "`modname1'"=="regress" {
predict `res_m' , res
scalar `r2m' = e(r2)
}
if "`modname1'"=="logit" | "`modname1'"=="probit" {
predict `fit_m' , xb
egen `varfit_m'=sd(`fit_m')
replace `varfit_m'=`varfit_m'^2
scalar `r2m' = (`varfit_m')/(1+`varfit_m')
}
mat define `bm'=get(_b)
mat `v' = e(V)
mat `vm' = vecdiag(cholesky(`v'))

local cmdline2 `modname2' `dv2' `rhs2'

`cmdline2' if `touse'
gen `_s2'=e(sample)
local samp2 = e(N)
if "`modname2'"=="logit" | "`modname2'"=="probit" {
predict `fit_y' , xb
egen `varfit_y'=sd(`fit_y')
replace `varfit_y'=`varfit_y'^2
scalar `r2y' = (`varfit_y')/(1+`varfit_y')
}
mat define `by'=get(_b)
mat `v' = e(V)
mat `vy' = vecdiag(cholesky(`v'))

if "`modname2'"=="regress" {
scalar `r2y' = e(r2)
}
qui sum `_s1' if `_s1'==1
local N = r(N)

qui if `samp1'~=`samp2' {
nois di as error "There are missing values of Y. The command cannot be run."
exit 198
}

if "`modname2'"=="regress" {
local rhs2a : list rhs2 - mediate 
local cmdline2a `modname2' `dv2' `rhs2a'
qui `cmdline2a'
predict `res_y' , res
}

capture mata g = mm_quantile(1,1,.025)
if _rc~=0 {
nois di as error "You must have moremata installed to run this program"
nois di as error "net install moremata.pkg"
exit 198
}

qui drop if ~`touse'

local lev = (round((100+`level')/2,.01))/100

if "`modname1'"=="regress" & "`modname2'"=="regress" {
mata: med_sens(`eps',`N',"`rhs1'","`rhs2'","`dv1'","`dv2'","`_s1'",`lev')
qui corr `res_m' `res_y'
local errcr=round(r(rho),.0001)
}
if "`modname1'"=="regress" & ("`modname2'"=="logit"  | "`modname2'"=="probit") {
mata: med_sens_cb(`sims',`eps',`N',"`by'","`vy'","`rhs1'","`rhs2'","`dv1'","`dv2'","___s1",`lev')
tempvar t
gen `t'= abs(_med_delta0-0)
qui sum `t'
qui sum _med_rho if  `t'==r(min)
local errcr=round(r(mean),.0001)
}

if ("`modname1'"=="logit"  | "`modname1'"=="probit") & "`modname2'"=="regress" {
mata: med_sens_bc(`sims',`eps',`N',"`bm'","`vm'","`rhs1'","`rhs2'","`dv1'","`dv2'","___s1",`lev')
tempvar t
gen `t'= abs(_med_delta0-0)
qui sum `t'
qui sum _med_rho if  `t'==r(min)
local errcr=round(r(mean),.0001)
}

if ("`modname1'"=="logit"  | "`modname1'"=="probit") & ("`modname2'"=="logit"  | "`modname2'"=="probit") {
nois di as error "Mediate sensitivity does not work with a binary mediator and a binary outcome"
exit 198
}

keep _med_rho _med_delta0 _med_updelta0 _med_lodelta0 _med_delta1 _med_updelta1 _med_lodelta1
tempfile _aaaa
save `_aaaa'

restore 
merge using `_aaaa' 
drop _merge

return scalar errcr = `errcr'
local r2s_thresh = round((`errcr')^2,.0001)
local r2t_thresh=round((`errcr')^2*(1-`r2m')*(1-`r2y'),.0001)


return scalar r2s_thresh = `r2s_thresh'
return scalar r2t_thresh=`r2t_thresh'

nois {
di as text ""
di as text ""
di as text "{hline 64}"
di as text "Sensitivity results"
di as text "{hline 41}{c TT}{hline 22}"
di as result "        Rho at which ACME = 0            {c |} "     as result %9.0g     `errcr' "
di as result "        R^2_M*R^2_Y* at which ACME = 0:  {c |} "     as result %9.0g     `r2s_thresh'   "
di as result "        R^2_M~R^2_Y~ at which ACME = 0:  {c |} "     as result %9.0g     `r2t_thresh' " 
di as text "{hline 41}{c BT}{hline 22}"
di as text "`level'% Confidence interval"
}

if "`graph'"~="" {
twoway rarea  _med_updelta0 _med_lodelta0 _med_rho, bcolor(gs14) || line  _med_delta0 _med_rho , lcolor(black) ytitle("Average mediation effect") xtitle("Sensitivity parameter: {&rho}") legend(off) note("`level'% Conf. Interval") title("ACME({&rho})")
}

end

mata
 
void med_sens( real scalar eps, real scalar n, string scalar rhs1,  string scalar rhs2, string scalar dv1, string scalar dv2, string scalar _s1, real scalar level)
 {
real colvector Xy, b, bsur, bold, ycoefs, mcoefs, ehat, ehat1, ehat2, yc, d0var, d1var, rholist, y, m,  d0, d1, upperd0, upperd1, lowerd0, lowerd1, ones
 real matrix X, XX, Xvi, Xsur, vy, vm, vi, vcov, I, omega, omegai, Yzeros, Mzeros,  MModel,  YModel
real scalar bdif, yl, ml, sd1, sd2, n2, k, rho,  _med_delta0, _med_lodelta0, _med_rho, _med_updelta0, _med_delta1, _med_lodelta1,  _med_updelta1, alliv, mnum

yl = cols(tokens(rhs2)) + 1
ml = cols(tokens(rhs1)) + 1

rholist = (-9::9)
rholist = rholist :/ 10

d0 = J(length(rholist),1,0)
d1 = J(length(rholist),1,0)
d0var = J(length(rholist),1,0)
d1var = J(length(rholist),1,0)

for (k=1; k<=length(rholist); k++) {
rho = rholist[k]
bdif=1

ones = J(n,1,1)
Yzeros = J(n,yl,0)
Mzeros = J(n,ml,0)

YModel=(st_data(.,tokens(rhs2),"`_s1'"),ones,Mzeros)
y=(st_data(.,tokens(dv2),"`_s1'"))
MModel=(Yzeros, st_data(.,tokens(rhs1),"`_s1'"),ones)
m = (st_data(.,tokens(dv1),"`_s1'"))


X = YModel \ MModel
yc = y \ m

XX = cross(X , X)
Xy = cross(X , yc)
b = invsym(XX)*Xy
n2=n*2

while (abs(bdif)>eps) {
ehat = yc - (X * b)
ehat1 = ehat[1..n,.]
ehat2 = ehat[n+1..n2,.]
sd1 =sqrt(variance(ehat1))
sd2 =sqrt(variance(ehat2))

omega = J(2,2,0)
omega[1,1] = cross(ehat1, ehat1) / (n-1)
omega[2,2] = cross(ehat2, ehat2) / (n-1)
omega[1,2] = rho * sd1 * sd2
omega[2,1] = rho * sd1 * sd2

I = I(n)
omegai = invsym(omega)
vi = omegai#I
Xvi = X' * vi
Xsur = Xvi*X
bsur = invsym(Xsur)*(Xvi*yc)
vcov = invsym(Xsur)
bold = b
bdif = sum((bsur-bold):^2)
b = bsur
}
alliv=yl +ml
mnum=yl+1
ycoefs = bsur[1::yl,.]
mcoefs = bsur[mnum::alliv,.]
vy = vcov[1::yl,1::yl]
vm = vcov[mnum::alliv,mnum::alliv]

d0[k,.] = mcoefs[1,1]*ycoefs[1,1]
d0var[k,.]=mcoefs[1,1]^2 * vy[1,1] + ycoefs[1,1]^2 * vm[1,1]
d1[k,.] = mcoefs[1,1]*ycoefs[1,1]
d1var[k,.]=mcoefs[1,1]^2 * vy[1,1] + ycoefs[1,1]^2 * vm[1,1]
}

upperd0 = d0 + invnormal(level)*sqrt(d0var)
lowerd0 = d0 - invnormal(level)*sqrt(d0var)
upperd1 = d1 + invnormal(level)*sqrt(d1var)
lowerd1 = d1 - invnormal(level)*sqrt(d1var)

_med_rho = st_addvar("float","_med_rho")
_med_delta0 = st_addvar("float","_med_delta0")
_med_updelta0 = st_addvar("float","_med_updelta0")
_med_lodelta0 = st_addvar("float","_med_lodelta0")
_med_delta1 = st_addvar("float","_med_delta1")
_med_updelta1 = st_addvar("float","_med_updelta1")
_med_lodelta1 = st_addvar("float","_med_lodelta1")


st_store((1,rows(rholist)),_med_rho,rholist)
st_store((1,rows(d0)),_med_delta0,d0)
st_store((1,rows(upperd0)),_med_updelta0,upperd0)
st_store((1,rows(lowerd0)),_med_lodelta0,lowerd0)
st_store((1,rows(d1)),_med_delta1,d1)
st_store((1,rows(upperd1)),_med_updelta1,upperd1)
st_store((1,rows(lowerd1)),_med_lodelta1,lowerd1)
 }
end


mata
function lambda(real matrix mmodel, real matrix mcoef, real matrix m)
 {
 real matrix muboot
 real matrix ms
 muboot = mmodel*mcoef'
ms = ((m :*normalden(-muboot) :- (1 :-m):*normalden(-muboot)) :/ (m :*normal(muboot) :+(1:-m) :*normal(-muboot)))
return(ms)
 }

 
 void med_sens_bc(real scalar sims, real scalar eps, real scalar n, string colvector bm, string colvector vm, string scalar rhs1, string scalar rhs2, string scalar dv1, string scalar dv2, string scalar _s1, real scalar level)
 {

real colvector l,v, w, e, rholist, M, Y, Yb, Ycoefboot, Ystar, adj, d0boot, d1boot, d0, d1, upperd0, upperd1, lowerd0, lowerd1, ones
 real matrix V, MModel_sim , MModel, MModel0, MModel1, YModel, muboot, muboot1, muboot0, YModel_adj, wdiag
real scalar kc, k, i, rho, RMSE, RMSEtemp, sigmadif, s2, _med_delta0, _med_lodelta0, _med_rho, _med_updelta0, _med_delta1, _med_lodelta1,  _med_updelta1

 bm = st_matrix(st_local("bm"))
 vm = st_matrix(st_local("vm"))
  MModel_sim = rnormal(sims,1,bm, vm)
 ones = J(n,1,1)
 from = J(n,1,0)
to = J(n,1,1)
Y=(st_data(.,tokens(dv2),"`_s1'"))
MModel=(st_data(.,tokens(rhs1),"`_s1'"),ones)
M = (st_data(.,tokens(dv1),"`_s1'"))
YModel=(st_data(.,tokens(rhs2),"`_s1'"),ones)
MModel0 = MModel
MModel1 = MModel
MModel0[.,1] = from 
MModel1[.,1] = to 

muboot = MModel*MModel_sim'
muboot0 = MModel0*MModel_sim'
muboot1 = MModel1*MModel_sim'

 rholist = (-9::9)
 rholist = rholist :/ 10
 eps = .01
 d0 =d1=upperd0=upperd1=lowerd0=lowerd1= J(length(rholist),1,0)
d0boot=d1boot=J(sims,1,0)
for (k=1; k<=length(rholist); k++) {
rho = rholist[k]
for (i=1; i<sims; i++) {

l=lambda(MModel,MModel_sim[i,.],M)
adj = l:*rho
w = 1 :- rho^2:*l :* (l:+muboot[.,i])
wdiag = diag(w)
YModel_adj = (YModel,adj)

Yb = qrinv(YModel_adj'*wdiag*YModel_adj)*(YModel_adj'*wdiag*Y)
e= Y-YModel_adj*Yb
n=rows(YModel_adj)
kc=cols(YModel_adj)
s2 = cross(e,e)/(n-kc)
V = s2*qrinv(YModel_adj'*wdiag*YModel_adj)
RMSE =sqrt(cross(e, e)/n)
sigmadif =1 
while (abs(sigmadif)>eps) {
Ystar = Y :- RMSE:*adj
Yb = qrinv(YModel'*wdiag*YModel)*(YModel'*wdiag*Ystar)
e= Ystar-YModel*Yb
n=rows(YModel)
kc=cols(YModel)
s2 = (e'e)/(n-kc)
V = s2*qrinv(YModel'*YModel)
RMSEtemp =sqrt((e'e)/n)
sigmadif = RMSEtemp - RMSE
RMSE = RMSEtemp
}

v = diagonal(cholesky(V))
Ycoefboot=J(sims,kc,.)
Ycoefboot[i,.] = rnormal(1,1,Yb, v)'

d0boot[i,.] = mean((Ycoefboot[i,1]):*(normal(muboot1[.,i]):-normal(muboot0[.,i])))
d1boot[i,.] = mean((Ycoefboot[i,1]):*(normal(muboot1[.,i]):-normal(muboot0[.,i])))
 }
 
 d0[k,.]=mean(d0boot)
 upperd0[k,.] = mm_quantile(d0boot,1,level) 
 lowerd0[k,.] = mm_quantile(d0boot,1,1-level)
 d1[k,.]=mean(d1boot)
 upperd1[k,.] = mm_quantile(d1boot,1,level)
 lowerd1[k,.] = mm_quantile(d1boot,1,1-level)
 }

 _med_rho = st_addvar("float","_med_rho")
_med_delta0 = st_addvar("float","_med_delta0")
_med_updelta0 = st_addvar("float","_med_updelta0")
_med_lodelta0 = st_addvar("float","_med_lodelta0")
_med_delta1 = st_addvar("float","_med_delta1")
_med_updelta1 = st_addvar("float","_med_updelta1")
_med_lodelta1 = st_addvar("float","_med_lodelta1")

st_store((1,rows(rholist)),_med_rho,rholist)
st_store((1,rows(d0)),_med_delta0,d0)
st_store((1,rows(upperd0)),_med_updelta0,upperd0)
st_store((1,rows(lowerd0)),_med_lodelta0,lowerd0)
st_store((1,rows(d1)),_med_delta1,d1)
st_store((1,rows(upperd1)),_med_updelta1,upperd1)
st_store((1,rows(lowerd1)),_med_lodelta1,lowerd1)
 
 } 
 end
 
 mata
 void med_sens_cb(real scalar sims, real scalar eps, real scalar n, string colvector by, string colvector vy, string scalar rhs1, string scalar rhs2, string scalar dv1, string scalar dv2, string scalar _s1, real scalar level)
 {
 real colvector b, v, e, Xy, beta2boot, sigma2boot, gammatilde, gammaboot, rho12boot, rholist, M, d0boot, d1boot, d0, d1, upperd0, upperd1, lowerd0, lowerd1, ones, zeros, lowernu, lowertau, uppernu, uppertau, tau, nu, nuboot, tauboot
 real matrix V, MModel_sim , MModel, YModel, XX, YModel_sim, ymat0, ymat1, YTModelboot
real scalar  df, kc, k, i, rho, RMSE, s2, sig2invscale, sig2shape, yk, _med_delta0, _med_lodelta0, _med_rho, _med_updelta0,  _med_delta1, _med_lodelta1, _med_updelta1

 ones = J(n,1,1)
 zeros = J(n,1,0)

MModel=(st_data(.,tokens(rhs1),"`_s1'"),ones)
M = (st_data(.,tokens(dv1),"`_s1'"))
YModel=(st_data(.,tokens(rhs2),"`_s1'"),ones) 
XX = cross(MModel , MModel)
Xy = cross(MModel , M)
b = invsym(XX)*Xy

e = M - (MModel * b)

 n=rows(MModel)
kc=cols(MModel)
df = n - kc
s2 = cross(e,e)/df
V = s2*qrinv(MModel'*MModel)
v = diagonal(cholesky(V))
RMSE =sqrt(cross(e, e)/n)
MModel_sim = rnormal(sims,1,b', v')

beta2boot = MModel_sim[.,1]
sig2shape = df/2
sig2invscale = (df/2)*RMSE^2
sigma2boot =sqrt(1 :/ rgamma(sims,1,sig2shape, 1/sig2invscale))

by = st_matrix(st_local("by"))
vy = st_matrix(st_local("vy"))
yk = length(by)
 
YModel_sim = rnormal(sims,1,by, vy)
gammatilde = YModel_sim[.,1]
 
rho12boot = (sigma2boot :* gammatilde) :/ (1 :+ sqrt(sigma2boot :^ 2 :* gammatilde :^ 2))

YTModelboot = (YModel_sim[.,2..yk] :* sqrt(1 :- rho12boot :^ 2))'
 
ymat1 = YModel[.,2..yk]
ymat1[.,1]=ones
ymat0 = YModel[.,2..yk]
ymat0[.,1]=zeros
rholist = (-9::9)
rholist = rholist :/ 10

d0 =d1=upperd0=upperd1=lowerd0=lowerd1= J(length(rholist),1,0)
tau = nu = uppertau = uppernu = lowertau = lowernu = J(length(rholist),1,0)
d0boot = d1boot = tauboot = nuboot = J(sims,1,0)
 
for (k=1; k<=length(rholist); k++) {
rho = rholist[k]
gammaboot = (-rho :+ rho12boot :* sqrt((1 :- (rho^2)) :/ (1 :- (rho12boot :^ 2)))) :/ sigma2boot
for (i=1; i<sims; i++) {
d0boot[i,.] = mean(normal(ymat0*YTModelboot[.,i] :+ gammaboot[i,.] :* beta2boot[i,.] :/ sqrt(gammaboot[i,.]^2 :* sigma2boot[i,.] :^ 2 ///
 :+ 2 :* gammaboot[i,.] :* rho :* sigma2boot[i,.] :+ 1)) :- normal(ymat0*YTModelboot[.,i]))
d1boot[i,.] = mean(normal(ymat1*YTModelboot[.,i]) :- normal(ymat1*YTModelboot[.,i]:- gammaboot[i,.] :* beta2boot[i,.] :/ sqrt(gammaboot[i,.]^2 ///
 :* sigma2boot[i,.] :^ 2 :+ 2 :* gammaboot[i,.] :* rho :* sigma2boot[i,.] :+ 1)))
tauboot[i,.] = mean(normal(ymat1*YTModelboot[.,i]) :- normal(ymat0*YTModelboot[.,i]))
nuboot[i,.]=(d0boot[i,.] :+ d1boot[i,.]) :/ (2 :* tauboot[i,.])
}

 d0[k,.]=mean(d0boot)
 upperd0[k,.] = mm_quantile(d0boot,1,level) 
  lowerd0[k,.] = mm_quantile(d0boot,1,1-level)
 d1[k,.]=mean(d1boot)
 upperd1[k,.] = mm_quantile(d1boot,1,level)
 lowerd1[k,.] = mm_quantile(d1boot,1,1-level)
 tau[k,.] = mean(tauboot)
 nu[k,.] = mean(nuboot)
  uppertau[k,.] = mm_quantile(tauboot,1,level) 
  lowertau[k,.] = mm_quantile(tauboot,1,1-level)
 uppernu[k,.] = mm_quantile(nuboot,1,level) 
  lowernu[k,.] = mm_quantile(nuboot,1,1-level)
  
 }
  _med_rho = st_addvar("float","_med_rho")
_med_delta0 = st_addvar("float","_med_delta0")
_med_updelta0 = st_addvar("float","_med_updelta0")
_med_lodelta0 = st_addvar("float","_med_lodelta0")
_med_delta1 = st_addvar("float","_med_delta1")
_med_updelta1 = st_addvar("float","_med_updelta1")
_med_lodelta1 = st_addvar("float","_med_lodelta1")

st_store((1,rows(rholist)),_med_rho,rholist)
st_store((1,rows(d0)),_med_delta0,d0)
st_store((1,rows(upperd0)),_med_updelta0,upperd0)
st_store((1,rows(lowerd0)),_med_lodelta0,lowerd0)
st_store((1,rows(d1)),_med_delta1,d1)
st_store((1,rows(upperd1)),_med_updelta1,upperd1)
st_store((1,rows(lowerd1)),_med_lodelta1,lowerd1)

 
  }
 end
