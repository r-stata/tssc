capture program drop monotone_mean

program define monotone_mean, eclass

	version 12
	
	syntax varlist
	
	tempname b
	
	
	mata: monotone_mean_work("`varlist'","`b'")
	
	matrix colnames `b' = `varlist'
	ereturn post `b'
	ereturn local cmd "monotone_mean"
	ereturn display
	
	
end
	

capture mata mata drop monotone_mean_work()
	
mata:
void monotone_mean_work(string scalar vlist, string scalar mname)
{
	//for simplicity, function can only accept one data column. 
	if(length(tokens(vlist)) > 1){
		_error("monotone_mean operates on one data column, please specify only one column")
	} 
	real matrix X
	real vector m
	X = st_data(.,tokens(vlist))
	total_data = length(X)
	drop_miss = select(X, X:!=.)
	if(max(drop_miss) > 1 || min(drop_miss) < 0){
		_error("monotone_mean only accepts that values are normalized to the [0,1] interval")
	}
	remain_data = length(drop_miss)
	prop_remain = remain_data/total_data
	if(remain_data == 0){
		result = 0.5
	}
	else {
		m = mean(drop_miss)
		result = (m*(1+prop_remain))*0.5

	}
		st_matrix(mname,result)
}

end
