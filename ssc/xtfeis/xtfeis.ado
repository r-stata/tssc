/*
User-written Stata ado
Estimates linear Fixed-Effects model with Individual-specific Slopes (FEIS)
Author: Volker Ludwig
Version 1.0: 23-07-2015
Version 1.1: 17-07-2018
- Fix compatibility of clustered s.e. with Stata 15
Version 2.0: 16-04-2019
- new option addsp() to add estimated individual slope parameters to the data
*/

mata:
function _feis_est(string scalar id, string scalar av, string scalar uv, string scalar slope, string scalar touse, string scalar noconstant, string scalar c1_, string scalar cluster, string scalar sp, string scalar transformed, string scalar addsp) 
{

		
/* get data matrix */
ID=st_data(., id, touse)
Y=st_data(., av, touse)
X=st_data(., tokens(uv), touse)

if (strlen(slope)>0) {
        Z=st_data(., tokens(slope), touse)
        if (strlen(noconstant)==0) {
                real colvector c
                c=J(rows(Z),1,1)
                Z=(Z,c)
        }
}
else if (strlen(slope)==0 & strlen(noconstant)==0) {
        Z=J(rows(Y),1,1)
}

/* set up panel data info matrix (identifies submatrix of units i) */ 
info = panelsetup(ID, 1, cols(Z)+1)

/* transform data matrix (premultiply by m), 
store transformed dep.var. in AV, transformed indep.vars in UV */
real colvector AV
real matrix UV
UV=J(0,cols(X),.)
real matrix m
i=1
while (i<=rows(info)) { 
    panelsubview(z, Z, i, info)
    panelsubview(x, X, i, info)
    panelsubview(y, Y, i, info)
    /*residual maker*/
	m=I(rows(z))-z*invsym(cross(z, z))*z'
    i++
    /*within transformation*/
	y=m*y
    AV=(AV\y)
    x=m*x
    UV=(UV\x)
}

/* add transformed data to current data set */
if (strlen(transformed)>0) {
    name = transformed + av
    st_store(., st_addvar("double", name), touse, AV)
    xvars = J(1,cols(UV),tokens(uv))
    i=1
    while (i<=cols(UV)) {
		name = transformed + xvars[i]
        st_store(., st_addvar("double", name), touse, UV[.,i])
        i++
    }
}

/* compute coefficient vector */
real colvector b
b=invsym(cross(UV, UV))*UV'*AV

/* compute residual vector */
real colvector u
u=AV-(UV*b)

/* compute variance matrix */
real matrix v
real scalar mindf
real scalar sigma
if (strlen(cluster)==0) {
    mindf=rows(info)*cols(Z)+cols(X)-1
    sigma=sum(u:*u)/(rows(u)-mindf)
    v=sigma*invsym(cross(UV, UV))
}
if (strlen(cluster)>0) {
    mindf=cols(Z)+cols(X)-1
    v=invsym(cross(UV, UV))
	/* store to tempvar c1 for _robust routine */
	st_view(c1=., ., c1_, touse)
	c1[.,.]=u
}

/* compute R2 within */
real scalar rss
rss=sum(u:*u)
real scalar tss
tss=sum((AV):*(AV))
real scalar r2
r2=1-(rss/tss)

/* compute APE and variance for ind. constants and slopes */
if (strlen(sp)>0) {
    real colvector alpha
	alpha=J(cols(Z),1,0)
	real colvector s
	real matrix svar
	svar=J(0,cols(Z),.)
	real matrix S
	S=J(cols(Z),cols(Z),0)
	real matrix C
	C=invsym(cross(Z, Z))*Z'*X
	real matrix A
	A=cross(UV, UV)
	real colvector B
	B=C*invsym(A)*UV'*u
	/* ind. constants and slopes */
	i=1
	while (i<=rows(info)) { 
		panelsubview(z, Z, i, info)
		panelsubview(x, X, i, info)
		panelsubview(y, Y, i, info)
		s=invsym(cross(z, z))*z'*(y-x*b) 
		alpha=(alpha:+s)
		if (strlen(addsp)>0) {
			svar=(svar\s')
		}
		i++
	}
	alpha=alpha:/(rows(info))
	/* variance matrix */
	i=1
	while (i<=rows(info)) { 
		panelsubview(z, Z, i, info)
		panelsubview(x, X, i, info)
		panelsubview(y, Y, i, info)
		s=invsym(cross(z, z))*z'*(y-x*b) 
		s=((s-alpha)-B)*(((s-alpha)-B)')
		S=(S:+s)
		i++
	}
	S=S:/(rows(u)-(cols(Z)+cols(X)))
}

/* add estimated individual slopes to current data set*/
if (strlen(addsp)>0) {
	real matrix SV
	SV=J(rows(u),cols(Z),.)
	i=1
	while (i<=rows(info)) {
		j=info[i,1]
		while (j<=info[i,2]) {
			SV[j,.]=svar[i,.]
			j++
		}
		i++
	}
	svars = J(1,1,tokens(slope))
	if (strlen(noconstant)==0) {
		svars=svars,"cons"
	}	
	j=1
	while (j<=cols(svars)) {
		name = addsp + svars[j]
        st_store(., st_addvar("double", name), touse, SV[.,j])
        j++
	}
}

/* pass results on to stata */
st_matrix("b", b')
st_matrix("V", v)
st_numscalar("mindf", mindf)
st_numscalar("N_g", rows(info))
st_numscalar("N_obs", rows(u))
info=info[.,2]-info[.,1]
st_numscalar("T_min", colmin(info)+1)
st_numscalar("T_max", colmax(info)+1)
st_numscalar("T_avg", sum(info)/rows(info)+1)
if (strlen(sp)>0) {
    st_matrix("a", alpha')
	st_matrix("sv", S)
}
if (strlen(addsp)>0) {
	st_matrix("SVAR", SV)
	st_matrix("svar", svar)
}
st_numscalar("R2", r2)

}
end


program define xtfeis, eclass
version 12
syntax varlist (min=2 numeric fv ts) [if] [in], [SLope(varlist numeric fv ts)] [NOConstant] [i(varname numeric)] [t(varname numeric)] [cluster(varname)] [sp] [TRANSformed(string)] [ADDsp(string)]

* Check group variable i() and time variable t()
if length("`i'") == 0 { 
        local i = "`_dta[iis]'"
        if length("`i'") == 0 {
                di in red "you must specify a group variable to identify panels"
                di in red "use option -i()- or command -xtset-"
                exit 198
        }
}
if length("`t'") == 0 { 
        local t = "`_dta[tis]'"
        if length("`t'") == 0 {
                di in red "you must specify a time variable"
                di in red "use option -t()- or command -xtset-"
                exit 198
        }
}

* Check groups are nested within Clusters
tempvar ch
if length("`cluster'") > 0 { 
        qbys `i' (`t') : ge `ch' = `cluster'!=`cluster'[_n-1] & _n>1
        qui su `ch'
        if r(mean)>0 {
                di in red "group variable i must be nested within clusters"
				exit 198
        }
}

* Check at least slope or constant
if length("`noconstant'")>0 & length("`slope'")==0 {    
        di in red "you must specify a slope variable or allow for individual constant"
        exit 198
}

* Expand macros
marksample touse
fvunab varlist : `varlist'
if length("`slope'")>0 {
        fvunab slope : `slope'
}
unab i : `i'
markout `touse' `slope' `i' `cluster'
tempvar no
qbys `i' : gen byte `no'=sum(`touse')
local s : word count `slope'
local s=`s'+1
if length("`noconstant'")==0 {
        local s=`s'+1
}
qbys `i' : replace `no'=. if `no'[_N]<`s'
qbys `i' : replace `no'=1 if `no'[_N]>=`s' & `no'[_N]<.
markout `touse' `slope' `i' `cluster' `no'

tokenize `varlist'
local av `1'
macro shift
local uv `*'
local id `i'
tempvar c1
qui ge `c1'=.


* invoke mata function
mata: _feis_est("`id'", "`av'", "`uv'", "`slope'", "`touse'", "`noconstant'", "`c1'", "`cluster'", "`sp'", "`transformed'", "`addsp'")


* compute panel-robust s.e.
qui reg `av' `uv' if `touse', nocons
mat beta=e(b)
local uvnames : colfullnames e(b)
mat beta=b
mat colnames beta = `uvnames'
mat Var=e(V)
local mindf=mindf
local df_r=N_obs-`mindf'
if length("`cluster'")>0 {
        mat rownames V = `uvnames'
        mat colnames V = `uvnames'
		_robust `c1' if `touse', v(V) cluster(`cluster') minus(`mindf')       
        local df_r=`r(df_r)'
}
mat Var=V
mat rownames Var = `uvnames'
mat colnames Var = `uvnames'
ereturn post beta Var, esample(`touse') depname(`av') dof(`df_r') findomitted buildfvinfo
ereturn local ivar "`i'"
ereturn scalar N=N_obs
ereturn scalar N_g=N_g
ereturn scalar g_min=T_min
ereturn scalar g_avg=T_avg
ereturn scalar g_max=T_max
ereturn scalar r2_w=R2
ereturn local cmd "xtfeis"
ereturn local cmdline "xtfeis `0'"
ereturn local depvar "`av'"
ereturn local indepvar "`uv'"
ereturn local slopevar "`slope'"
ereturn local vcetype "conventional"
if length("`cluster'")>0 {
	ereturn local vcetype "cluster"
}
ereturn local noconstant ""
if length("`noconstant'")>0 {
	ereturn local noconstant "1"
}


* Table regression results
#delimit ;
di _n in gr "Fixed-effects regression with individual-specific slopes (FEIS)" _n ;
        di in gr "Group variable: " in ye abbrev("`e(ivar)'",12) in gr
                   _col(49) in gr "Number of obs" _col(68) "="
                _col(70) in ye %9.0f e(N) ;
                di in gr _col(49) "Number of groups" _col(68) "="
                _col(70) in ye %9.0g e(N_g) _n ;
        di in gr "R-sq:  within  = " in ye %6.4f e(r2_w)
                _col(49) in gr "Obs per group: min" _col(68) "="
                _col(70) in ye %9.0g e(g_min) ;
        di in gr 
                _col(64) in gr "avg" _col(68) "="
                _col(70) in ye %9.1f e(g_avg) ;
        di in gr 
                _col(64) in gr "max" _col(68) "="
                _col(70) in ye %9.0g e(g_max) _n ;

if length("`cluster'")>0 {;
        di _n in gr "Standard errors adjusted for clusters in " in gr "`cluster'" _n ;
};
#delimit cr
ereturn display, noempty

* Table of estimated Slope Parameters (Average Partial Effects)
if length("`sp'")>0 {
	di _n in gr "Estimated slope parameters (Average Partial Effects)" _n
	qui reg `av' `slope'  if e(sample), `noconstant'
	mat sp=e(b)
	local spnames : colfullnames e(b)
	mat sp=a
	mat spv=e(V)
	mat spv=sv
	mat colnames sp = `spnames'
	mat colnames spv = `spnames'
	mat rownames spv = `spnames'
	ereturn post sp spv, findomitted buildfvinfo
	ereturn display, noempty
}

end








