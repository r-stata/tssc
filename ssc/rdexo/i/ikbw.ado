program define ikbw, eclass

version 14.0


syntax varlist(numeric) [if] [in], [CUToff(numlist)]

tokenize `varlist'   //without this, the `2' will be "x," instead of "x"
marksample sampletouse 

local y `1'       // outcome variable
local x `2'       // forcing variable
local c `cutoff' // cutoff variable

if "`cutoff'"=="" {
	local c = 0
}
	
tempvar hwid flag 

local nmin=5
local flag=0

// Silverman's bandwidth for uniform kernel and Normal X
qui sum `x' if `sampletouse'
local stdX=r(sd)
local n=r(N)
		
local hx=1.84*`stdX'*(`n'^(-1/5))
		
qui sum `x' if `x'<`c' & `sampletouse'
local nl=r(N)
qui sum `x' if `x'>=`c' & `sampletouse'
local nr=r(N)
		
* restrict sample to usable observations
qui sum `y' if `x'<`c' & `x'>(`c'-`hx') & `sampletouse'
local nlh=r(N)
local syl=r(sd)^2
qui sum `y' if `x'>=`c' & `x'<(`c'+`hx') & `sampletouse'
local syr=r(sd)^2	
local nrh=r(N)

if (min(`nlh',`nrh')<`nmin') {
	display "1: Not enough observations around the cutoff! Try a larger bandwidth or sample."
	ereturn clear
	ereturn scalar hwid=0
	ereturn scalar flag=1
	ereturn list
	exit
}

* density
local fx=(`nlh'+`nrh')/(2*`n'*`hx')

* second derivatives of m_y
mata: secdev("`varlist'","`sampletouse'",`flag',`c')
local my3=my3[1,1]

local hy2l=3.56*((`syl'/(`fx'*(`my3')^2))^(1/7))*(`nl'^(-1/7))
local hy2r=3.56*((`syr'/(`fx'*(`my3')^2))^(1/7))*(`nr'^(-1/7))

mata: obscut("`varlist'","`sampletouse'",`hy2l',`hy2r',`flag',`c')
local nylh=nylh
local nyrh=nyrh	
local my2l=my2l
local my2r=my2r
if (min(`nylh',`nyrh')<`nmin') {
	display "2: Not enough observations around the cutoff! Try a larger bandwidth or sample."
	ereturn clear
	ereturn scalar hwid=0
	ereturn scalar flag=1
	ereturn list
	exit	
}

************************
* regularization terms
local rl=2160*`syl'/(`nylh'*(`hy2l'^4))
local rr=2160*`syr'/(`nyrh'*(`hy2r'^4))

************************
local h_opt = 3.4375*(((`syl'+`syr')/(`fx'*((`my2r'-`my2l')^2+(`rl'+`rr'))))^(1/5))*(`n'^(-1/5))
ereturn clear
ereturn scalar hwid = `h_opt'
ereturn scalar flag = 0
ereturn list

end




capture mata mata drop secdev()
version 14.0
mata:
void secdev(scalar varlist, scalar sampletouse,flag, c)
{
		
		real matrix M, X, Y, C, b
		real scalar n,my3
		M=X=Y=.
		st_view(M,.,varlist,sampletouse)
		st_subview(Y,M,.,1)
		st_subview(X,M,.,2)
		C=c:*J(rows(Y),1,1)
		
		X=(J(rows(X),1,1), (X:>=C), (X-C), (X-C):^2, (X-C):^3)
		n=rows(X)
		b=pinv(X'*X)*X'*Y
	
		
		if (rank(X'*X)<cols(X)) {
			flag=flag+1
			my3=(0,0,0,0,6)*b 
		}
		else {
			my3=(0,0,0,0,6)*(I(cols(X))*luinv((X'*X)))*(X'*Y)
		}

		st_matrix("beta",b')
		st_matrix("num",n)
		st_matrix("my3",my3)
		//"-->end of mata-secdev"
}
end
	
	
capture mata mata drop obscut()
version 14.0
mata:
void obscut(scalar varlist,scalar sampletouse, hy2l, hy2r, flag,c)
{
	
	real matrix M, X, Y, C, b, tmp
	real scalar n,my3
	st_view(M,.,varlist,sampletouse)
	st_subview(Y,M,.,1)
	st_subview(X,M,.,2)
	C=c:*J(rows(Y),1,1)

	HY2L=hy2l:*J(rows(C),1,1)
	HY2R=hy2r:*J(rows(C),1,1)
	
	Ylh=select(Y,((X:<C):&((C-HY2L):<X)))	
	Yrh=select(Y,((X:>=C):&(X:<(C+HY2R))))
	
	Xylh=select(X,((X:<C):&((C-HY2L):<X)))
	Xyrh=select(X,((X:>=C):&(X:<C+HY2R)))
	
	nylh=colsum((X:<C):&((C-HY2L):<X))
	nyrh=colsum((X:>=C):&(X:<(C+HY2R)))
	
	Cl=select(C,((X:<C):&((C-HY2L):<X)))
	Cr=select(C,((X:>=C):&(X:<(C+HY2R))))
	
	
	XXylh=(J(nylh,1,1), (Xylh-Cl), (Xylh-Cl):^2)	
	
	if (rank(XXylh'*XXylh)<cols(XXylh)) {
		flag=flag+1
		my2l=(0,0,2)*pinv(XXylh'*XXylh)*XXylh'*Ylh
	}
	else {
		my2l=(0,0,2)*(I(cols(XXylh))*luinv(XXylh'*XXylh))*XXylh'*Ylh
	}
	
	
	XXyrh=(J(nyrh,1,1), (Xyrh-Cr), (Xyrh-Cr):^2)
	if (rank(XXyrh'*XXyrh)<cols(XXyrh)) {
		flag=flag+1
		my2r=(0,0,2)*pinv(XXyrh'*XXyrh)*XXyrh'*Yrh
	}
	else {
		my2r=(0,0,2)*(I(cols(XXyrh))*luinv(XXyrh'*XXyrh))*XXyrh'*Yrh
	}
	
	st_numscalar("nylh",nylh)
	st_numscalar("nyrh",nyrh)
	st_numscalar("my2l",my2l)
	st_numscalar("my2r",my2r)
	//"-->end of mata-obscut"
}
end


