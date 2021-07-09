capt program drop clr2bound
program define clr2bound, eclass

version 11.2

syntax anything [if] [in] [, METhod(string) noRSEED SEED(integer 0) *]

ereturn clear
	
/* Check the estimator which the user wants to use 
	The default option is parametric estimator. */


if "`rseed'" != "norseed" {
	set seed `seed' 
}	
	
if "`method'" == "series" {
	clr_b `anything' `if' `in' , `options' 
}

else if "`method'" == "local" {
	clr_kb `anything' `if' `in' , `options' 
}

else {
	clr_pb `anything' `if' `in' , `options'
}

ereturn local cmd = "clr2bound"

end
