*! version 0.2.0, Brent McSharry, 11dec2017
* Tabular CUSUM chart with O-E (VLAD) for binary outcomes
*!this program was written with great help from the excellent textbook: Statistical Methods for Hospital Monitoring with R 
*!written by Anthony Morton, Kerrie Mengersen, Michael Whitby, Geoffrey Playford
program define tabcusum, sortpreserve
version 10.1
syntax varlist(min=2 max=2 numeric) [if] [in] , Predicted(varname numeric) [OR(real 1.5) Threshold(real 2.9) /*
*/ HEADstart(real 0.5) XLABEL(passthru) NOTE(passthru) TITLE(passthru) SUBtitle(passthru) XTitle(passthru) XAXis(passthru) /*
*/ SHAdearea(real 0) LIMits(numlist missingokay >0 <100 sort) noTRUNClimits] 
	marksample touse
	qui {
		replace `touse' = 0 if missing(`predicted')
		count if `touse'
		local count `r(N)'
		if (`count'<2) {
			di as error "insufficient obs"
			return 2000
		}
		
		if (`headstart' <0 | `headstart'>1) {
			di as error "headstart represents a multiplier to the threshold for where to begin after reset and must be between 0 and 1"
			return 198
		}
		tokenize `varlist'
		local observed `1'
		capture assert missing(`observed') | inlist(`observed', 0, 1)
		if _rc != 0 {
			di "The observed outcome can only have values of missing, 0 or 1"
			error 7 
		}
		
		gsort  -`touse' `2'
		tempvar sequenceVar
		gen `sequenceVar' = _n in 1/`count'
		set obs `=_N+1'
		label variable `sequenceVar' "Case No."
		replace `sequenceVar' = 0 in l
		replace `touse' = 1 in l
		gsort  -`touse' `sequenceVar'
		local ++count
			
		if `shadearea'>0 {
			tempvar shadeY
			gen `shadeY' = `threshold' if `sequenceVar' >= `shadearea'
			local grapharea (area `shadeY' `sequenceVar', color(gs13) lwidth(none))
			local lorder 3
		}
		else {
			local lorder 2
		}
		
//create rasprt
		tempvar si Tihalf signal cumulative
		
		gen `si' = ln(cond(`observed',`or',1)/(1-`predicted' +(`or' * `predicted'))) in 2/`count'
		
		gen float `Tihalf' = 0 in 1
		local reset = `threshold' * `headstart'

		replace `Tihalf' = max(`si' + cond(`Tihalf'[_n-1] < `threshold',`Tihalf'[_n-1],`reset'),0) in 2/`count'
		gen byte `signal' = `Tihalf'>`threshold' in 1/`count'
		gen float `cumulative' = 0 in 1
		replace `cumulative' = sum(`signal'[_n-1]) in 2/`count'
		
		sum `signal', meanonly
		forvalues i=0/`r(sum)' {
			tempvar l`i'
			gen float `l`i'' = `Tihalf' if `cumulative'==`i'
			replace `l`i'' = `reset' if missing(`l`i'') & !missing(`l`i''[_n+1])
			local graphline `graphline' `l`i''
			local pstyle `pstyle' p1
		}
		if `r(sum)'>0 {
			local legend legend(order(`lorder') label(`lorder' "CUSUM signal") ring(0) position(10) region(lwidth(none)))
			local resetY yline(`reset', lwidth(thin) lpattern(dot) lcolor(gs8))
		}
		else {
			local legend legend(off)
		}
		
		capture noisily twoway `grapharea' (line `graphline' `sequenceVar', pstyle(`pstyle') `xaxis'), /*
			*/ `xlabel' ytitle("Tabular CUSUM") yline(`threshold', lpattern(shortdash)) `resetY' yscale(range(0 `threshold')) /*
			*/ legend(off) `xtitle' graphregion(margin(tiny))/*
			*/ name(sprt, replace) nodraw 
	
//create o-e now resets are sorted
		tempvar oe
		generate `oe' = sum(`observed' - `predicted') in 1/`count'
		replace `signal' = cond(`signal'==1,`oe',.) 
		
		sum `oe', meanonly
		local minoe `r(min)'
		local maxoe `r(max)'
		if ("`shadeY'" != "") {
			replace `shadeY' = ceil(`r(max)'+1) if !missing(`shadeY')
			local shade (area `shadeY' `sequenceVar', color(gs13) lwidth(none) base(`=floor(`r(min)'-1)'))
		}
		
		if ("`limits'"!="") {
			replace `touse' = 0 in 1 
			forvalues i = 1(1)`=wordcount("`limits'")' {
				local l:word `i' of `limits'
				tempvar lb`i' ub`i'
				qui gen `lb`i'' = .
				qui gen `ub`i'' = .
				mata:getCometTails("`predicted'","`touse'", "`lb`i''", "`ub`i''", `l')
				
				if ("`trunclimits'"==""){
					replace `lb`i'' = . if `lb`i'' < `minoe'
					replace `ub`i'' = . if `ub`i'' > `maxoe'
				}
				local linepat: word `i' of longdash dash shortdash dot shortdash_dot dash_dot longdash_dot
				local linepat lpattern(`linepat') lcolor(gs8) lwidth(thin)
				local bounds `bounds' (line `ub`i'' `sequenceVar', `linepat') (line `lb`i'' `sequenceVar', `linepat')
			}
		}
		
		capture noisily twoway `shade' (line `oe' `sequenceVar', `xaxis') (scatter `signal' `sequenceVar', msymbol(T) msize(large) mcolor(red)) `bounds', /*
			*/ `xlabel' ytitle("O-E CUSUM") `legend' name(oe, replace) nodraw xtitle("") graphregion(margin(tiny))
	}
	
	if "`title'" == "" {
		local title:variable label `observed'
		if "`title'"=="" {
			local title `observed'
		}
		local title title(`"`title'"')
	}
		
	capture noi graph combine  oe sprt, cols(1) `note' `title' `subtitle' 
	capture graph drop oe sprt
	qui drop in 1
end

mata:
mata set matastrict on

class CusumFinder {
	public real scalar p, i, approx, maxIts
	public real scalar LbBeta(), UbBeta()
	public real scalar BinarySearch()
	void new()
}
void CusumFinder::new(){
	approx = 0.0001;
	maxIts = 200;
}
real scalar CusumFinder::BinarySearch(
	//pointer(real scalar function) scalar delegate,
	real scalar ub,
	real scalar target,
	real scalar min,
	real scalar max)
{
	real scalar half, k, val, argLen;
	
	argLen = args();
	for(k=0;k<maxIts;k++){
		half = (min+max)/2;
		if (ub==0){
			val = LbBeta(half);
		}else{
			val = UbBeta(half);
			//printf("i:%10.0g p:%10.0g val:%10.0g half:%10.0g target:%10.0g\n",i,p,val,half,target);
		}
		if (val >= .) {
		  return(.);
		}
		if ((abs(val-target)<=approx)){
		  return(half)
		}
		if (val<target) {
		  min = half;
		} else {
		  max = half;
		}
	} 
	return(.);
}

real scalar CusumFinder::LbBeta(real scalar x){
    return(ibetatail(x+1,i-x, p))
}
  
real scalar CusumFinder::UbBeta(real scalar x){
    return(1-ibetatail(x,i-x+1, p))
}
real matrix GetBetaCis(
	real colvector expectVector,
	| real scalar ci)
{
real scalar len, minDecr, maxIncr;
real matrix returnVar;
class CusumFinder scalar cf;
	
	if (args()<2){ci=95;}
	target = (100-ci)/200;
	len = rows(expectVector);

	returnVar = J(len, 2, .);

	//define boundries for our binary search, based on the last bound. Obviously the narrower the boundries, the faster the search
	minDecr=0.3;
	maxIncr=1.3;
	lastLb=minDecr;
	lastUb=minDecr;

	for (cf.i = 1;cf.i<=len;cf.i++)
	{
		cf.p=expectVector[cf.i]/cf.i; //the p variable is being set because it is used in the functions lbBeta and ubBeta
		if (cf.LbBeta(0)<target) {
		  lastLb=cf.BinarySearch(0, target, lastLb-minDecr, lastLb+maxIncr);
		  returnVar[cf.i,1]=lastLb;
		}else{
		  returnVar[cf.i,1]= 0;
		  lastLb=minDecr;
		}
		if (cf.UbBeta(cf.i)<target){
		  lastUb=cf.BinarySearch(1, target, lastUb+maxIncr, lastUb-minDecr);
		  returnVar[cf.i,2] = lastUb;
		} else {
		  lastUb=cf.i;
		  returnVar[cf.i,2]=cf.i;
		}
	}
	return(returnVar);
}
void getCometTails(string scalar expVarName, string scalar touse, string scalar lb, string scalar ub, | real scalar ci){
real scalar expIndx
real colvector expView
real colvector sumExpect
real matrix result
	if (args() < 5){
		ci = 95;
	}
	st_view(expView,.,expVarName,touse);
	sumExpect = runningsum(expView)
	result = GetBetaCis(sumExpect, ci);
	result = result :- sumExpect;
	st_store(.,(lb,ub), touse, result);
}

end
