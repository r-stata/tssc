*! Date        : 03may2016
*! Version     : 1.2.0
*! Author      : Charlie Joyez, Paris-Dauphine University
*! Email	   : charlie.joyez@dauphine.fr

*REQUIRES THE NWCOMMANDS PACKAGE BY T.GRUND (https://nwcommands.wordpress.com/)
* Calculates network Reciprocity
* See A. Barrat, M. Barthélemy, R. Pastor-Satorras, and A. Vespignani, “The architecture of complex weighted networks”. PNAS 101 (11): 3747–3752 (2004).

capture program drop nwreciprocity
program nwreciprocity, rclass
	version 9
	syntax 	[, net(string) nodes(string) density(string) weight(string) loop(string)  kdensity histogram SHOWcount *]	
set more off


if "`net'"!=""{
_nwsyntax `net', max(9999)
preserve
noi di "`net'"
quie nwsummarize `net'
local nodes `r(nodes)' 
local loop `loop' 
local density `r(density)'
local weight `r(edges_sum)'
nwtomata, mat(A)
drop _all
}	
	
else {
clear 
set more off
local nodes `nodes' 
local loop `loop' 
local density `density'
local weight `weight'
if missing("`nodes'"){
noi di as error "either net() or nodes() should be filled"
error
}
if missing("`density'") & missing("`weight'"){
noi di as error "either density() or weight() should be filled"
error
}
}
if `nodes'<=1 {
noi di as error "nodes value must be greater than 1"
error
}

if `density'<0 | `density'>1{
noi di as error "density value must be [0;1]"
error
}

if "`loop'"==""{
local loop=10000
noi di "loop is set to `loop'"
}
if `loop'<=0 {
noi di as error "loop must have a positive value"
error
}


mata R=J(`loop',1,.)
quietly{
forvalues n=1/`loop'{
	if "`showcount'"!="" {
	noi di "`n' / `loop'"
	}
nwrandom `nodes',density(`density')
*nwreplace random = random*1000
forvalues i =1/`nodes'{
replace net`i'=net`i'*runiform()
*replace net`i'=round(net`i')
}
nwdyads
nwset net*
nwsummarize network
nwdyads random network
nwtomata network,mat(W)
mata : s=sum(W)
if "`weight'"!=""{
mata W= W:/s :* `weight'
mata : s=sum(W)
return scalar weight= `weight'
}

mata Z = W :* (W :< W') + W' :* (W' :< W) /*min of symmetrics elements : reciprocated ties*/

mata E=sum(Z)
mata r=E/s

mata: R[`n',] = r

nwdrop random network, attr(net*) 
}
}
set obs `loop'

quie mata R

quiet capture drop r 
quiet capture drop _nullreciprocity
quiet mata : st_addvar("double","_nullreciprocity")
quiet mata :  st_store(.,"_nullreciprocity",R)
noi su _nullreciprocity
local mean_null `r(mean)'
local mnr = round(`mean_null'*100,.01)
return scalar nodes= `nodes'
return scalar loop= `loop'
return scalar density= `density'
return scalar mean_null = `mean_null'
noi display "  {txt} The share of reciprocated weights of a random network of {res}`nodes' {txt}nodes and with density of {res}`density' {txt}is in average (on {res}`loop' {txt} iterations) {res} `mnr' {txt}%  "


if "`kdensity'"!="" {
	noi kdensity _nullreciprocity,normal
	}
if "`histogram'"!="" {
histogram _nullreciprocity,normal 
		}		
	
if "`net'"!=""{
restore
mata Z=A
mata s=sum(A)
mata sym=issymmetric(A)
mata sym
mata st_local("s",strofreal(sym))

mata : Z = A :* (A :< A') + A' :* (A' :< A) /*min of symmetrics elements : reciprocated ties*/
if `s'==1 {
mata Z=A 
}
}
if "`net'"!=""{
mata E=sum(Z)
mata r=E/s
preserve
drop _all
qui set obs `loop'
forvalues n=1/`loop'{

mata: R[`n',] = r
}
quiet capture drop _reciprocity
qui set obs `loop'
quiet mata : st_addvar("double","_reciprocity")
quiet mata :  st_store(.,"_reciprocity",R)
su _reciprocity
local mean_real `r(mean)'
local mr = round(`mean_real'*100,.01)
noi display " {txt} The share of reciprocated weights of  {res}`netname' is  {res}`mr' {txt}% "
restore
noi di "mean real `mean_real' " 
noi di "mean null `mean_null' " 
local R_coeff = (`mean_real' - `mean_null') / (1 - `mean_null')
return scalar nodes= `nodes'
return scalar loop= `loop'
return scalar density= `density'
return scalar mean_null = `mean_null'
return scalar mean_real = `mean_real'
return scalar r_coeff = `R_coeff'
noi display " {txt} The reciprocity coefficient of  {res}`netname' is  {res}`R_coeff' "
if `R_coeff'>0 {
di " {res}`netname' {txt} tends to reciprocate"
}
if `R_coeff'<0 {
di " {res}`netname' {txt} avoids to reciprocate"
}
if `R_coeff'==0 {
di " {res}`netname' {txt} has no reciprocity tendency"
}
}

	end

