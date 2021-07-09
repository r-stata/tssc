
program define ueve, eclass
version 10

syntax varlist(min=2 numeric) [if] [in] [fweight aweight pweight iweight/] , GRoup(varname) ///
     [ewald eve b2sls Level(integer $S_level)]

marksample touse
local depvar: word 1 of `varlist'
local regs: list varlist - depvar
tempname b V g d _group

// Drop groups with 1 observation, display warning message with number of these groups

sort `group'
qui egen `g'=count(`depvar') if `touse', by(`group')
qui egen `d'=count(`depvar') if `g'==1
if `d' !=. {
	di as error "Warning: " `d' " groups with one observation are dropped"
}
qui replace `g'=. if `g'==1
markout `touse' `g'
qui egen `_group'=group(`group') if `touse'
markout `touse' `_group'

// Create weights (fweight aweight pweight iweight) for Mata
   tempvar normwt 
   if `"`exp'"' != "" {
      qui gen double `normwt' = `exp' if `touse'
      if "`weight'" == "aweight" | "`weight'" == "pweight" {
         summ `normwt' if `touse', mean
         di as text "(sum of wgt is " %12.4e r(sum) ")"
         qui replace `normwt' = r(N)*`normwt'/r(sum)
      }
      local wtexp `"[`weight' = `exp']"'
      summ `normwt' if `touse', mean
      if "`weight'" == "iweight" {
         local normN = trunc(r(sum))
      }
      else {
         local normN = r(sum)
      }
      markout `touse' `normwt'
   }
   else {
      qui gen double `normwt' = 1 if `touse'
      qui count if `touse'
      local normN = r(N)
   }

// Display chosen estimation method, assign it to local scalar

if "`ewald'" !="" { 
  display _newline as text "EWALD regression"
  local emethod=1
}
else if "`eve'" !="" { 
  display _newline as text "EVE regression"
  local emethod=2
}
else { 
  display _newline as text "UEVE regression"
  local emethod=0
}

// execute program computing estimator and its covariance matrix in Mata

mata: UEVE("`depvar'","`regs'","`_group'","`normwt'","`touse'","`emethod'")

// return results and report statistics

ereturn clear

matrix `b' = r(b)
matrix `V' = r(V)
local vnames `regs' _cons

matname `V' `vnames'
matname `b' `vnames', c(.)

local k = colsof(`b')
local N = r(N)
local df = `N' - `k' - 1

ereturn post `b' `V', dof(`df') obs(`N') depname(`depvar') esample(`touse')
ereturn local depvar = "`depvar'"
ereturn local indepvars = "`regs'"
ereturn scalar N = r(N)
ereturn scalar G = r(G)
ereturn scalar r2 = r(R2)
ereturn local cmd "ueve"

display _col(53) as text "Number of obs    = " as result %7.0f e(N)
display _col(53) as text "Number of groups = " as result %7.0f e(G) 
display _col(53) as text "R-squared        = " as result %7.4f e(r2) _newline
ereturn display, level(`level')

end

// main Mata program computing the estimator and its covariance matrix

mata 

real matrix UEVE (string scalar depvar, string scalar regs, string scalar group, string scalar normwt, string scalar touse, string scalar emethod)
{
real scalar ng, N, G, K, K1
real vector cons, lg, b
real matrix gwyx, _gwyx, Xg, Pg, Mg, Sg, sg, sxx, sxy, syy, s1ng, V

st_view(gwyx=., ., (tokens(group), tokens(normwt), tokens(depvar), tokens(regs)), touse)

N=rows(gwyx)
G=gwyx[rows(gwyx),1]
K1=cols(gwyx)
K=K1-2

Sg=J(K,K,0)
sg=J(K,1,0)
sxx=J(K,K,0)
sxy=J(K,1,0)
syy=J(1,1,0)
s1ng=0
Ybar=.
Xbar=J(1,K,.)

// compute variance of the sampling errors

for (i=1; i<=G; i++) {
	_gwyx=select(gwyx, gwyx[.,1]:==i)
	Yg = _gwyx[.,3]
	ng = rows(Yg)
	cons = J(ng,1,1)
	Xg = _gwyx[.,4..K1], cons
	lg = J(ng,1,1)
	w = sqrt(_gwyx[.,2])
	Xg=w:*Xg
	Yg=w:*Yg
	lg=w:*lg

	Pg = lg*invsym(lg'*lg)*lg'
	sxx = sxx + Xg'*Pg*Xg
	sxy = sxy + Xg'*Pg*Yg
	syy = syy + Yg'*Pg*Yg
	s1ng = s1ng + 1/ng

	Pg=.
	Mg=-lg*invsym(lg'*lg)*lg'
	dMg=J(ng,1,1)-(-diagonal(Mg))
	_diag(Mg,dMg)
	Sg = Sg + (1/(ng-1))*Xg'*Mg*Xg
	sg = sg + (1/(ng-1))*Xg'*Mg*Yg	

	// create matrices of averages for R2
	ybar=colsum(Yg)/colsum(w)
	Ybar=Ybar\ybar
	xbar=colsum(Xg)/colsum(w)
	Xbar=Xbar\xbar
}

Mxx=(1/G)*sxx
Mxy=(1/G)*sxy
Myy=(1/G)*syy
Shat=(1/G)*Sg
shat=(1/G)*sg

// choose estimation method

// UEVE
if (emethod=="0") {
   a=(G-K-1)/G
}
// EWALD
if (emethod=="1") {
   a=0
}
// EVE
if (emethod=="2") {
   a=1
}

// Compute estimator

b=qrinv(Mxx-a*Shat)*(Mxy-a*shat)

// Compute covariance matrix of estimator

Omega=Mxx-a*Shat
rho=Myy-b'*Omega*b
A=Mxx*(Myy-b'*Omega*b+b'*Shat*b-2*shat'b)+(shat-Shat*b)*(shat-Shat*b)'
B=(1/G)*s1ng*(Shat*(rho+b'*Shat*b-2*shat'b)+Shat*(shat-Shat*b)*(shat-Shat*b)')
V=(1/G)*qrinv(Omega)*(A+(a^2)*B)*qrinv(Omega)
_makesymmetric(V)

// Compute R-squared using group means

Ybar=Ybar[2..(G+1),.]
Xbar=Xbar[2..(G+1),.]
i = J(G,1,1)
R2= 1 - (Ybar-Xbar*b)'(Ybar-Xbar*b)/(Ybar'Ybar-(i'Ybar)^2/G)

st_matrix("r(b)",b')
st_matrix("r(V)",V)
st_numscalar("r(N)",N)
st_numscalar("r(G)",G)
st_numscalar("r(R2)",R2)

}

end

