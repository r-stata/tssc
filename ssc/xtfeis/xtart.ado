/*
User-written Stata ado
Computes Artificial Regression Test (ART) version of Hausman test
Author: Volker Ludwig
Version 1.0: 16-04-2019
*/

mata:
function _feis_art(string scalar id, string scalar av, string scalar uv, string scalar slope, string scalar touse, string scalar noconstant, string scalar addv, string scalar predvars, string scalar meanvars)
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

/* compute individual predicted data, add to current data set */
PAV=Y-AV
PUV=X-UV
if (strlen(predvars)==0) {
	predvars = "_pred_" 
}	
name = predvars + av
st_store(., st_addvar("double", name), touse, PAV)
xvars = J(1,cols(UV),tokens(uv))
prednames = " "
i=1
while (i<=cols(UV)) {
	name = predvars + xvars[i]
    st_store(., st_addvar("double", name), touse, PUV[.,i])
    prednames = prednames + name + " "
	i++
}

/* compute individual means data, add to current data set */
real colvector MAV
real matrix MUV
MUV=J(0,cols(X),.)
real matrix MSV
MSV=J(0,cols(Z),.)
i=1
while (i<=rows(info)) { 
	panelsubview(z, Z, i, info)
	panelsubview(x, X, i, info)
	panelsubview(y, Y, i, info)
	i++
	/*mean calc*/
	y=J(rows(y),1,1)*mean(y)
	MAV=(MAV\y)
	x=J(rows(x),1,1)*mean(x)
	MUV=(MUV\x)
	z=J(rows(z),1,1)*mean(z)
	MSV=(MSV\z)
}
if (strlen(meanvars)==0) {
	meanvars = "_mean_" 
}
name = meanvars + av
st_store(., st_addvar("double", name), touse, MAV)
xvars = J(1,cols(UV),tokens(uv))
meannames = " "
i=1
while (i<=cols(UV)) {
	name = meanvars + xvars[i]
    st_store(., st_addvar("double", name), touse, MUV[.,i])
    meannames = meannames + name + " "
	i++
}
slvars = J(1,(cols(Z)-1),tokens(slope))
i=1
while (i<cols(Z)) {
	name = meanvars + slvars[i]
    st_store(., st_addvar("double", name), touse, MSV[.,i])
    meannames = meannames + name + " "
    i++
}

st_local("predvars", prednames)
st_local("meanvars", meannames)

}
end 



****************************************************************************

program define xtart, rclass 
syntax [anything] , [FE] [RE] [keep(varlist numeric fv ts)] [addvars(varlist numeric fv ts)] [PREDicted] [PREDicted2(string)]

if (length("`anything'")>0) {
	qui est restore `anything'
}

tempvar sam
qui ge `sam'=0
qui replace `sam'=1 if e(sample)
*marksample touse, nov
*markout `touse' 
*cap drop touse
local touse `"`sam'"'

local av `"`e(depvar)'"'
local uv `"`e(indepvar)'"'
local slope `"`e(slopevar)'"'
local id `"`e(ivar)'"'
local noconstant `"`e(noconstant)'"'
local cluster `"`e(vcetype)'"' 

unab id : `id'
unab av : `av'
fvunab uv : `uv'

if length("`slope'")>0 {
    fvunab slope : `slope'
}

if (length("`addvars'")>0) {
	fvunab addv : `addvars'
}

if (length("`keep'")>0) {
	fvunab keep : `keep'
}

tokenize `predicted2'
local predvars `1'
macro shift
local meanvars `*'
if (length("`predicted2'")>0) {
	local `_p_' `predvars'
	local `_m_' `meanvars'
}
else {
	local _p_ "_pred_"
	local _m_ "_mean_"
}

* invoke mata function
mata: _feis_art("`id'", "`av'", "`uv'", "`slope'", "`touse'", "`noconstant'", "`addv'", "`predvars'", "`meanvars'")


if (length("`cluster'")>0) {
	local robse="vce(cluster `id')"
}

/* Test of FE model */

qui xtreg `av' `uv' `slope' `predvars' `meanvars' `addv' if e(sample), re `robse'
local estcmd="`e(cmdline)'"

if (length("`fe'")==0 & length("`re'")==0) {
	if (length("`keep'")>0) {
		local pvars ""
		foreach v of local keep {
			local pvars "`pvars' `_p_'`v'"
		}
	}
	di _newline(3)
	di "------------------------------------"
	di _n in gr "Artificial Regression Test" _n
	di _n in gr "(FEIS vs. FE model)" _n
	di "------------------------------------"
	di _newline(1)
	di in gr "Full (FEIS) model estimation command : " 
	di in gr "`estcmd'" 
	di _newline(1)
	di in gr "Test of H0: FEIS and FE estimates consistent" 
	di in gr "Alternative H1: FEIS consistent, FE inconsistent"
	di _newline(1)
	di in gr "Model constraints"
	if (length("`keep'")>0) {
			test `pvars', 
	}
	else {
		test `predvars', 
	}
	return local chi2 `r(chi2)'
	return local df `r(df)'
	return local p `r(p)'
	return local estcmd `estcmd'	

}


/* Optional test of FE vs. RE model */
if (length("`fe'")>0) {
	if (length("`keep'")>0) {
		local mvars ""
		foreach v of local keep {
			local mvars "`mvars' `_m_'`v'"
		}
	}
	qui xtreg `av' `uv' `slope' `meanvars' `addv' if e(sample), re `robse'
	local estcmd="`e(cmdline)'"
	di _newline(3)
	di "------------------------------------"
	di _n in gr "Artificial Regression Test" _n
	di _n in gr "(FE vs. RE model)" _n
	di "------------------------------------"
	di _newline(1)
    di in gr "Full (FE) model estimation command : " 
    di in gr "`estcmd'" 
	di _newline(1)
    di in gr "Test of H0: FE and RE estimates consistent" 
    di in gr "Alternative H1: FE consistent, RE inconsistent"
	di _newline(1)
    di in gr "Model constraints"
	if (length("`keep'")>0) {
			test `mvars', 
	}
	else {
		test `meanvars',
	}
	return local chi2 `r(chi2)'
	return local df `r(df)'
	return local p `r(p)'
	return local estcmd `estcmd'	
}


/* Optional test of FEIS vs. RE model */
if (length("`re'")>0) {
	if (length("`keep'")>0) {
		local pvars ""
		foreach v of local keep {
			local pvars "`pvars' `_p_'`v'"
		}
	}
	qui xtreg `av' `uv' `slope' `predvars' `addv' if e(sample), re `robse'
	local estcmd="`e(cmdline)'"
	di _newline(3)
	di "------------------------------------"
	di _n in gr "Artificial Regression Test" _n
	di _n in gr "(FEIS vs. RE model)" _n
	di "------------------------------------"
	di _newline(1)
    di in gr "Full (FEIS) model estimation command : " 
    di in gr "`estcmd'" 
	di _newline(1)
    di in gr "Test of H0: FEIS and RE estimates consistent" 
    di in gr "Alternative H1: FEIS consistent, RE inconsistent"
	di _newline(1)
    di in gr "Model constraints"
	if (length("`keep'")>0) {
			test `pvars', 
	}
	else {
		test `predvars',
	}
	return local chi2 `r(chi2)'
	return local df `r(df)'
	return local p `r(p)'
	return local estcmd `estcmd'	
}

	
if (length("`predicted'")==0 & length("`predicted2'")==0) {
	cap drop `predvars'
	cap drop _pred_`av'
	cap drop `meanvars'
	cap drop _mean_`av'
}

end 

