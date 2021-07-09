*!0.0.1 Brent McSharry brent@focused-light.net 21Sep2017
*!this program was written based on N.J.Cox excelent stata script mylabels
program mydatelabels
version 10.1
syntax [varname(default=none)] =/exp [if] [in], Local(str) [Format(str) Start End]
	marksample touse

	tokenize `"`exp'"', parse(" !~&|*/+-^<>=()[]")
	while "`1'" != "" {
		capture confirm variable `1'
		if (_rc==0){
			local timevar `1'
			local 1 ""
		} 
		else {
			macro shift
		}
	}
	
	if ("`timevar'"=="") {
		di as error "incorrect syntax - could not identify a variable name within =exp"
		return 100
	}
	
	qui replace `touse'=0 if missing(`timevar')
	
	if ("`format'"==""){
		local format:format `timevar'
	}
	if ("`varlist'"==""){
		local varlist `timevar'
	}
	tempvar changed
	qui gen `changed' = `exp' if `touse'
	
	mata:getChanges("`changed'","`touse'","indices")
	
	mata: getIndices("`touse'","index1","indexl")
	if ("`start'"!=""){
		local indices `index1' `indices'
	}
	if ("`end'"!="" & "`indexl'" != word("`indices'",wordcount("`indices'"))) {
		local indices `indices' `indexl'
	}

	foreach i of local indices {
		local val : di %18.0g `varlist'[`i']
		local v : di `format' `timevar'[`i'] 
		local mydatelabels `"`mydatelabels' `val' "`v'""'
	}
	di as res `"{p}`mydatelabels'{p_end}"' 
	c_local `local' `"`mydatelabels'"' 
end

mata:
mata set matastrict on

rowvector deltaIndices(real colvector inpt){
real scalar i, j, len, last;
real rowvector returnVar;
	len = rows(inpt);
	returnVar = J(1,len,.);
	j=0;
	last = inpt[1];
	for (i=2;i<=len;i++){
		if (inpt[i]!=last){
			last = inpt[i];
			returnVar[++j] = i;
		}
	}
	if (j>0){
		return(returnVar[1..j]);
	}
	return(J(1,0,.));
}

void getChanges(string scalar varName, string scalar touse, string scalar macName){
real colvector vw, map;
real rowvector result, mapResult;
real scalar len,i;
	st_view(vw,.,varName,touse);
	result = deltaIndices(vw)

	st_local(macName, invtokens(strofreal(result)));
}
real scalar firstIndex(real colvector inpt){
	real scalar i,len;
	len=rows(inpt)
	for (i=1;i<=len;i++){
		if (inpt[i] < . & inpt[i] > 0){
			return(i);
		}
	}
	return (0);
}
real scalar lastIndex(real colvector inpt){
	real scalar i;
	for (i=rows(inpt);i>0;i--){
		if (inpt[i] < . & inpt[i] > 0){
			return(i);
		}
	}
	return (0);
}
void getIndices(string scalar varName, string scalar macName1, string scalar macNameL){
real colvector vw;
	st_view(vw,.,varName,.);
	st_local(macName1, strofreal(firstIndex(vw)))
	st_local(macNameL, strofreal(lastIndex(vw)));
}
end
