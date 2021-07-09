*! version 2.0		(04 April 2020)		groupfunction
*   option [in] [if] added
*   phython Gini added
* version 1.0  		(05 5December 2017) groupfunction
*
* Paul Corral - World Bank Group 
* Minh Nguyen - World Bank Group 
* Joao Pedro Azevedo - World Bank Group 


cap prog drop groupfunction
program define groupfunction, eclass
	version 11.2, missing
	#delimit;
	syntax [if] [in] [aw pw fw] , 
	[
		sum(varlist numeric)  
		rawsum(varlist numeric) 
		mean(varlist numeric) 
		first(varlist numeric) 
		max(varlist numeric) 
		min(varlist numeric) 
		count(varlist numeric) 
		sd(varlist numeric) 
		gini(varlist numeric) 
		theil(varlist numeric)
		VARiance(varlist numeric) 
		by(varlist) 
		norestore
		xtile(varlist numeric)
		nq(numlist max=1 int >0)
		missing
		slow
		merge
	];
#delimit cr
qui{
if ("`by'"==""){
	tempvar myby
	gen `myby' = 1
	local by `myby'
	
}
if ("`xtile'"!="") local forby forby
local wvar : word 2 of `exp'
if ("`norestore'"!="") keep `wvar' `by' `sum' `rawsum' `mean' `first' `max' `min' `count' `sd' `variance' `gini' `theil' `xtile' 
	tempvar _useit _gr0up _thesort
	marksample _useit
		
	//save label
	qui: label dir
	local _allv `r(names)'
	foreach x of varlist `by' {
		local Nm: val lab `x'
	
		if ("`Nm'"!=""){
		local l: value label `x'
		local vallabs "`vallabs' `l'"
		}
	}
	local vallabs: list vallabs & _allv
	if ("`vallabs'"!=""){
	tempfile labeldo
	label save `vallabs' using `labeldo', replace
	}
	
	//Weights
	local wvar : word 2 of `exp'
	if "`wvar'"==""{
		tempvar peso
		gen `peso'=1
		local wvar `peso'
	}
	else{
		replace `_useit'=0 if missing(`wvar')
	}
	if ("`forby'"!=""){
		//Only one var can be specified
		tokenize `xtile'
		if ("`2'"!=""){
			dis as error "When specifying xtile variables with forby option, only one is allowed"
			error 111
			exit
		}
		if ("`nq'"==""){
			dis as error "When specifying xtile, nq needs to be specified"
			error 111
			exit
		}
		replace `_useit'=0 if missing(`xtile')
	}
	
	local procs sum mean first max min count rawsum sd variance gini theil xtile
	
	local empty=1
	
	foreach ss of local procs{
		if ("``ss''"!="") local empty = 0
	}
		
	if (`empty'==1){
		display as error "Please specify variables for sum, rawsum, mean, min, max, count, sd, variance, or first"
		error 301
		exit 
	}
	
	if ("`by'"==""){
		gen `_gr0up' =1
		local by `_gr0up'
	}
	

	//adjust here when adding new functions
	local procs sum mean first max min count rawsum sd variance gini theil
	local check
	foreach x of local procs{
		local `x': list uniq `x'
		local check: list check & `x'
	}
	
	
	if ("`checks'"!=""){
		display as error "Please specify unique names for variables in sum, first, mean, max, min, gini, theil options"
	}
	
	local numby = wordcount("`by'")
	if ("`forby'"=="") local ++numby
		
	if (`numby'>1|"`strs'"!=""){
		tempvar _1x1
		egen `_1x1' = group(`by')
		local thearea `_1x1'
	}
	else{
		local thearea `by'
	}
	
	if ("`forby'"=="") sort `thearea'
	else{ 
		levelsof `thearea' if `_useit'==1, local(myforby)
		
		foreach hi of local myforby{
			tempvar _myby
			gen `_myby' = `thearea'==`hi'
			mata: w=st_data(.,tokens("`wvar'"),"`_myby'")	
			mata: st_view(__i=.,.,tokens("`xtile'"),"`_myby'")		
			mata:__i[.,.] =_fpctilebig(__i,1,`nq',w)	
		}
		sort `thearea' `xtile'
		local thearea `thearea' `xtile'
		local by `by' `xtile'
	}
	
	//Account for more than one by variable, and strings
	foreach x of local by{
		if ("`:val lab `x''"!="") local lbl_`x' : val lab `x'
		cap confirm string variable `x'
		if (_rc==0){
			local strpres =1
			local strs `strs' `x'
			mata: st_sview(strs=.,.,tokens("`strs'"),"`_useit'")
		}
		
	}
	
	local by2: list by - strs
	mata: st_view(nostrs=.,.,tokens("`by2'"),"`_useit'")

	
	//Import data into mata
	mata: w=st_data(.,tokens("`wvar'"),"`_useit'")	
	
	if ("`forby'"=="") mata: st_view(area=.,.,tokens("`thearea'"),"`_useit'")
	else mata: st_view(area=.,.,tokens("`xtile'"),"`_useit'")
	/*
	mata: if (allof(x:==.)) st_local(cont, 0)
	if ("`cont'"=="0"){
		display as error "Your by group has all values missing"
		error 119
		exit
	}	
	*/
	mata: info = panelsetup(area,1)

	//mata: rows(info)
	//Get area matrix
	
		if ("`slow'"!="") local slow=1
		else              local slow=0
	
	if ("`strs'"!=""){
		mata: strs=strs[info[.,1],.]
		mata: nostrs=nostrs[info[.,1],.]
	}
	else{
		mata: nostrs=nostrs[info[.,1],.]
	}
	
	if ("`missing'"=="") local miss = 0
	else local miss = 1
		
	if ("`sum'"!=""){
		mata: st_view(x=.,.,tokens("`sum'"),"`_useit'")			
		mata: xsum = _fastsum(x,w,info, `miss')
		local todrop: list sum - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`rawsum'"!=""){
		mata: st_view(x=.,.,tokens("`rawsum'"),"`_useit'")	
		
		mata: w2=J(rows(w),1,1)	
		mata: xrawsum = _fastsum(x,w2,info, `miss')
		local todrop: list rawsum - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`count'"!="") {
		mata: st_view(x=.,.,tokens("`count'"),"`_useit'")	
		mata: xcount = _fastcount(x,info)
		local todrop: list count - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`mean'"!=""){
		mata: st_view(x=.,.,tokens("`mean'"),"`_useit'")
		mata: xmean = _fastmean(x,w,info, `slow')
		local todrop: list mean - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'		
	}
	
	if ("`sd'"!=""){
		mata: st_view(x=.,.,tokens("`sd'"),"`_useit'")	
		mata: xsd = sqrt(_fastvariance(x,w,info))
		local todrop: list sd - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`variance'"!=""){
		mata: st_view(x=.,.,tokens("`variance'"),"`_useit'")	
		mata: xvariance = (_fastvariance(x,w,info))
		local todrop: list variance - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`first'"!=""){
		mata: st_view(x=.,.,tokens("`first'"),"`_useit'")
		mata: xfirst = _fastfirst(x,info)
		local todrop: list first - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`max'"!=""){
		mata: st_view(x=.,.,tokens("`max'"),"`_useit'")
		mata: xmax = _fastmax(x,info)
		local todrop: list max - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`min'"!=""){
		mata: st_view(x=.,.,tokens("`min'"),"`_useit'")
		mata: xmin = _fastmin(x,info)
		local todrop: list min - wvar
		local todrop: list todrop - thearea
		if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
	}
	
	if ("`gini'"!=""|"`theil'"!=""){
		levelsof `thearea', local(misareas)
		foreach indic in gini theil{
			local mivars=1
			foreach y of local `indic'{
				local careas =1
				foreach geo of local misareas{
					CpBCaLC `y' if `thearea'==`geo' [aw=`wvar'], `indic'
					if (`careas'==1) mata: x`indic'1 = `r(`indic')'
					else 			 mata: x`indic'1 = x`indic'1 \ `r(`indic')'
					
					local ++careas
				}
			if (`mivars'==1) mata: x`indic' = x`indic'1
			else		     mata: x`indic' = x`indic',x`indic'1
			local ++mivars
			}
			
			local todrop: list `indic' - wvar
			local todrop: list todrop - thearea
			if ("`todrop'"!="" & "`merge'"=="") drop `todrop'
		}
	}
		
	foreach x of local procs{
		if ("``x''"!=""){
			local finmat `finmat' x`x'
			local procs2 `procs2' `x'
		}
	}
	local finmat=subinstr("`finmat'"," ",",",.)
	mata: xx=(`finmat')
	//Save number of observations
	mata: st_matrix("_obs_",rows(info))
	
	if ("`merge'"!=""){
		local lasvar  `procs2'
		foreach x of local lasvar{
			foreach y of local `x'{	
				if ("`exp'"=="") local WwW 
				else local WwW w
				gen double `WwW'`x'_`y' = .
				if ("`exp'"=="") lab var `WwW'`x'_`y' "`x' of `y'"
				else lab var `WwW'`x'_`y' " Weighted `x' of `y'"
				local _all `_all' `WwW'`x'_`y'			
			}
		}
		noi:mata: st_store(.,tokens(st_local("_all")),"`_useit'",theexpanse(info,xx))
	}
	else{
		//SAVE RESULTS in STATA
		clear
		local lasvar  by2 `procs2'
		local o=_obs_[1,1]
		
		set obs `o'
		if "`strs'"!=""{
			local ccc=1
			foreach x of local strs{
				mata:st_local("ha",strofreal(max(strlen(strs[.,`ccc']))))
				if (`ha'!=0) gen str`ha' `x'= ""
				else gen str1 `x'= ""
				lab var `x' "Group by `x'"
				local ccc=`ccc'+1
			}
			mata: st_sstore(.,tokens(st_local("strs")),.,strs)
		}
		
		foreach x of local lasvar{
			foreach y of local `x'{
				if ("`x'"!="by2"){
					gen double `y' = .
					lab var `y' "`x' of `y'"
					local _all `_all' `y'
				}
				else{
					gen double `y' = .
					lab var `y' "Group by `y'"
					//if `"`_val`y''"'!=""{
					//lab def `y' `_val`y''
					//lab val `y' `y' 
					//}
				}
			}
		}
		
		if ("`by2'"!="") mata: st_store(.,tokens(st_local("by2")),.,nostrs)
		mata: st_store(.,tokens(st_local("_all")),.,xx)
		//apply label back
		if ("`vallabs'"!=""){
			do `labeldo'
			foreach x of local by2 {
				if "`lbl_`x''"~="" lab val `x' `lbl_`x''
			}
		}
	}
	mata: mata drop area info nostrs 
	cap mata: mata drop x
	cap mata: mata drop y
	cap mata: mata drop w
	cap mata: mata drop xmean
	cap mata: mata drop xgini
	cap mata: mata drop xgini1
	cap mata: mata drop xsum
	cap mata: mata drop xrawsum
	cap mata: mata drop w2
	cap mata: mata drop xx
	
}
	
end

mata 
mata set matastrict off

function _TTheil(y,w){
	one=ln(y:/mean(y,w))
	two=one:*(y:/mean(y,w))
	return(mean(two,w))
}

function _fasttheil(real matrix x, real matrix w, real matrix info){
	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	
	for(i=1; i<=r;i++){
		panelsubview(xi=.,x,i,info)
		panelsubview(wi=.,w,i,info)
		for(j=1;j<=jj;j++){
			X1[i,j] = _TTheil(xi[.,j],wi)
		}
	}
	return(X1)
}


function _GGini(x, w) {
	t = x,w
	_sort(t,1)
	x=t[.,1]
	w=t[.,2]
	xw = x:*w
	rxw = quadrunningsum(xw) :- (xw:/2)
	return(1- 2*((quadcross(rxw,w)/quadcross(x,w))/quadcolsum(w)))
}

function _fastgini(real matrix x, real matrix w, real matrix info){
	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	

	for(i=1; i<=r;i++){
		panelsubview(xi=.,x,i,info)
		panelsubview(wi=.,w,i,info)
		for(j=1;j<=jj;j++){
			X1[i,j] = _GGini(xi[.,j],wi)
		}
	}	
	return(X1)
}


//data should have been previously sorted
function _fastmean(real matrix x, real matrix w, real matrix info, slow){

	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	//check to see if we can use block 
	if (((hasmissing(x)+hasmissing(w))!=0)|slow==1){
		//slow option
		for(i=1; i<=r;i++){
			panelsubview(xi=.,x,i,info)
			panelsubview(wi=.,w,i,info)
			for(j=1;j<=jj;j++){
				X1[i,j] = mean(xi[.,j],wi)
			}
		}
	}
	else{
		for(i=1; i<=r; i++){
			rr  = info[i,1],. \info[i,2],.
			rr2 = info[i,1],1 \ info[i,2],1
			X1[i,.] = mean(x[|rr|],w[|rr2|])
		}
	}
	return(X1)
}

function _fastvariance(real matrix x, real matrix w, real matrix info){
	
	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	//check to see if we can use block 
	if ((hasmissing(x)+hasmissing(w))!=0){
		//slow option
		for(i=1; i<=r;i++){
			panelsubview(xi=.,x,i,info)
			panelsubview(wi=.,w,i,info)
			for(j=1;j<=jj;j++){
				X1[i,j] = diagonal(quadvariance(xi[.,j],wi))'
			}
		}
	}
	else{
		for(i=1; i<=r; i++){
			rr  = info[i,1],. \info[i,2],.
			rr2 = info[i,1],1 \ info[i,2],1
			X1[i,.] = diagonal(quadvariance(x[|rr|],w[|rr2|]))'
		}
	}
	return(X1)
}


//data should have been previously sorted
function _fastsum(real matrix x, real matrix w, real matrix info, miss){
	//ww = strtoreal(stlocal("rawsum")
	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	//check to see if we can use block 	
	if ((hasmissing(x)+hasmissing(w))!=0){
		//slow option
		for(i=1; i<=r;i++){
			panelsubview(xi=.,x,i,info)
			panelsubview(wi=.,w,i,info)
			
			for(j=1;j<=jj;j++){
				if (miss==1){
					if (colnonmissing(xi[.,j])!=0){
						if(j==1) X1[i,1] = quadcolsum(xi[.,j]:*wi)
						else     X1[i,j] = quadcolsum(xi[.,j]:*wi)
					}
					else{
						if(j==1) X1[i,1] = .
						else     X1[i,j] = .
					}
				}
				else{
					if(j==1) X1[i,1] = quadcolsum(xi[.,j]:*wi)
					else     X1[i,j] = quadcolsum(xi[.,j]:*wi)
				}
			}
		}
	}
	else{
		for(i=1; i<=r; i++){
			rr  = info[i,1],. \info[i,2],.
			rr2 = info[i,1],1 \ info[i,2],1
			X1[i,.] =  quadcolsum(x[|rr|]:*w[|rr2|])
		}
	}
	return(X1)
}

function _fastfirst(real matrix x, real matrix info){
	
	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	//check to see if we can use block 
	
	for(i=1; i<=r; i++){
		rr  = info[i,1],. \info[i,2],.
		X1[i,.] =  x[info[i,1],.]
	}
	
	
	return(X1)
}

function _fastmax(real matrix x, real matrix info){
	
	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	//check to see if we can use block 
	
	for(i=1; i<=r; i++){
		rr  = info[i,1],. \info[i,2],.
		X1[i,.] =  colmax(x[|rr|])
	}
	
	
	return(X1)
}

function _fastmin(real matrix x, real matrix info){
	
	r  = rows(info)
	jj = cols(x)
	X1 = J(rows(info),cols(x),0)
	//check to see if we can use block 
	
	for(i=1; i<=r; i++){
		rr  = info[i,1],. \info[i,2],.
		X1[i,.] =  colmin(x[|rr|])
	}
	
	
	return(X1)
}

//data should have been previously sorted
function _fastcount(real matrix x, real matrix info) {
	r  = rows(info)
	jj = cols(x)
	X1 = J(r,jj,0)
	//fest = (st_local("std")~="" ? J(2,3,NULL) : J(1,3,NULL))        
	for(i=1; i<=r; i++){
		rr  = info[i,1],. \ info[i,2],.
		rr2 = info[i,1],1 \ info[i,2],1
		X1[i,.] = quadcolsum((x[|rr|]:<.))
	}
	return(X1)
}

end

*! version 2.0		(21 March 2020)		cpbcalc 
* Paul Corral - World Bank Group 
* Jose Montes - World Bank Group 
* Joao Pedro Azevedo - World Bank Group 

cap prog drop CpBCaLC
program define CpBCaLC, rclass
	version 11.2
	syntax varlist(max=1 numeric) [if] [in] [aw pw fw] , [ gini theil poverty(numlist >=0 max=1 integer) line(numlist >0 max=1)]
	
marksample touse1					 
local vlist: list uniq varlist

//Get weights matrix
mata:st_view(y=., .,"`vlist'","`touse1'")

//Weights
	local wvar : word 2 of `exp'
	if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}
	
mata:st_view(w=., .,"`wvar'","`touse1'")

if ("`poverty'"!=""){
	if ("`line'"==""){
		dis as error "You need to specify a threshold for poverty calculation"
		error 198
		exit
	}
}

if ("`line'"!=""){
	if ("`poverty'"==""){
		dis as error "You specified a poverty line, but no FGT value"
		error 198
		exit
	}
}




local options gini theil poverty

foreach x of local options{
	if ("``x''"!=""){
		if ("`x'"=="poverty"){
			mata:p=_CPBfgt(y,w,`line',``x'')	
			mata: st_local("_x0",strofreal(p))
			return local fgt``x'' = `_x0'
			
			dis in green "fgt``x'' : `_x0'"
		}
		else{
			if ("`x'"=="gini"){
				cap python: gini("`vlist'","`wvar'","`touse1'")
				if (_rc!=0){
					mata:p=_CPB`x'(y,w)
					mata: st_local("_x0",strofreal(p))
					return local `x' = `_x0'
				} 
				else{
					return local `x' = r(gini)
				}
			}
			else{
				mata:p=_CPB`x'(y,w)
				mata: st_local("_x0",strofreal(p))
				return local `x' = `_x0'
				
				dis in green "`x' : `_x0'"
			}
		}	
	}
}	

	
end
	
mata
function _CPBtheil(y,w){
	one=ln(y:/mean(y,w))
	two=one:*(y:/mean(y,w))
	return(mean(two,w))
}

	function _CPBtheils(x,w){
		
		for(i=1;i<=cols(x);i++){
			if (i==1) out = _CPBtheil(x[.,i],w)
			else      out = out,_CPBtheil(x[.,i],w)
		}
	return(out)
	}

function _CPBgini(x, w) {
	t = x,w
	_sort(t,1)
	x=t[.,1]
	w=t[.,2]
	xw = x:*w
	rxw = quadrunningsum(xw) :- (xw:/2)
	return(1- 2*((quadcross(rxw,w)/quadcross(x,w))/quadcolsum(w)))
}

function _CPBginis(x,w){
	
	for(i=1;i<=cols(x);i++){
		if (i==1) out = _CPBgini(x[.,i],w)
		else      out = out,_CPBgini(x[.,i],w)
	}
return(out)
}

function _CPBfgt(x,w,z,a){
	return(mean((x:<z):*(1:-(x:/z)):^(a),w))
}

function _CPBfgts(x,w,z,a){
	
	for(i=1;i<=cols(x);i++){
		if (i==1) out = _CPBfgt(x[.,i],w,z,a)
		else      out = out,_CPBfgt(x[.,i],w,z,a)
	}
return(out)
}

//Returns xtile classiffication for each observation
function _fpctilebig(real colvector X, si ,real scalar nq, |real colvector w) {
	rr = rows(X)
	if (args()==2) w = J(rr,1,1)	
	if (rr < nq) {
		_error(3200, "Number of bins is more than the number of observations")
		exit(error(3200))       
	}
	data = runningsum(J(rr,1,1)), X, w
	if (si==1) _sort(data,(2,3))
	nq0 = quadsum(data[.,3])/nq 
	//nq0
	q = trunc((quadrunningsum(data[.,3]):/nq0):+1e-15):+1 	
	q[|rr|] = nq
	if (si==1) return(q[order(data,1)])
	else return(q)
}

function theexpanse(real matrix info, real matrix xx){
	for(i=1; i<=rows(info);i++){
		m00 = info[i,2] - info[i,1] + 1
		if(i==1) Homer = J(m00,1,xx[i,.])
		else     Homer = Homer \ J(m00,1,xx[i,.])
	}
	
	return(Homer)

}

end

//The below is ready to insert into and ado! Yay you!!
python
#import data command
from sfi import Data
#import numpy
import numpy as np
from numpy import cumsum
from sfi import Scalar

def gini(y,w, touse):
	y = np.matrix(Data.get(y, selectvar=touse))
	w = np.matrix(Data.get(w, selectvar=touse))
	t = np.array(np.transpose(np.concatenate([y,w])))
	t = t[t[:,0].argsort()]
	y = t[:,0]
	w= t[:,1]
	yw = y*w
	rxw = cumsum(yw) - yw/2
	gini = 1-2*((np.transpose(rxw).dot(w)/np.transpose(y).dot(w))/sum(w))
	Scalar.setValue("r(gini)", gini)
end



//		groupfunction [aw=weight], sum(`todosaqui2' `pptarsa') mean(`pp1' `ppcovsa' `ppadsa' `ppdepsa' `pppov0' `pppov1' `pppov2' `todosaqui' `medexp_red' `fullcredit2016' `tax_owed0' `agtax' `discount') by(decile) rawsum



