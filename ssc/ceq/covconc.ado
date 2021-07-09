** ADO FILE FOR GINI AND CONCENTRATION COEFFICIENTS



** CHANGES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.0 029jun2017
** (beta version; please report any bugs), originally written by Sean Higgins sean.higgins@ceqinstitute.org, modified by Paul Corral



*************************
** PRELIMINARY PROGRAMS *
*************************

mata
	function _fGini_ceq(x,s,w,|r){
		if (args()==4){
		t=x,w,r
		if (s==1) _sort(t,(3,1))
		rxw = quadrunningsum((t[.,1]:*t[.,2])):-((t[.,1]:*t[.,2]):/2)
		return(1-2*((quadcross(rxw,t[.,2])/quadcross(t[.,1],t[.,2]))/quadcolsum(t[.,2])))		
		}
		else{
		t=x,w
		if (s==1){
		_sort(t,1)
		}
		rxw = quadrunningsum((t[.,1]:*t[.,2])):-((t[.,1]:*t[.,2]):/2)
		return(1-2*((quadcross(rxw,t[.,2])/quadcross(t[.,1],t[.,2]))/quadcolsum(t[.,2])))
		}
	}

	function _fGinis_ceq(x,s,w,|r){
		if (args()==4){
			for(i=1;i<=cols(x);i++){
				if (i==1) out = _fGini_ceq(x[.,i],s,w,r)
				else      out = out,_fGini_ceq(x[.,i],s,w,r)
			}
		}
		else{
			for(i=1;i<=cols(x);i++){
				if (i==1) out = _fGini_ceq(x[.,i],s,w)
				else      out = out,_fGini_ceq(x[.,i],s,w)
			}
		}
	return(out)
	}
end



// Beign covconc
// Original program by Sean Higgins (2015), modified Paul Corral (WB-GPV03) (2017)
// Calculates Gini and Concentration Coefficients 

cap program drop covconc

program define covconc, rclass sortpreserve
	syntax varname [if] [in] [aweight pweight/], [rank(varname)]
	marksample touse
	local 1 `varlist'
	if "`rank'"=="" {
		local _return gini
		local _returndi Gini
	}
	else {
		local _return conc
		local _returndi Concentration Coefficient
	}
	local wvar `exp'
	if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}
	
	
	if "`exp'"!="" { // with weights
		if ("`rank'"!=""){
			mata:st_view(x=., ., "`1'", "`touse'")
			mata:st_view(w=., ., "`wvar'", "`touse'")
			mata:st_view(r=., ., "`rank'", "`touse'")
			mata: st_numscalar("_rconc",_fGinis_ceq(x,1,w,r))			
		}
		else{
			mata:st_view(x=., ., "`1'", "`touse'")
			mata:st_view(w=., ., "`wvar'", "`touse'")
			mata: st_numscalar("_rconc",_fGinis_ceq(x,1,w))						
		}
	}
	else {
			mata:st_view(x=., ., "`1'", "`touse'")
			mata:st_view(w=., ., "`wvar'", "`touse'")
			mata: st_numscalar("_rconc",_fGinis_ceq(x,1,w))	
	}
	
	local `_return' = _rconc
	
	return scalar `_return' = ``_return''
	di as result "`_returndi': ``_return''"
	if "`exp'"=="" cap drop `w'
end 
