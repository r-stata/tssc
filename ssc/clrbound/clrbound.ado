capt program drop clrbound
program define clrbound, eclass

version 11.2

syntax anything [if] [in] [, METhod(string) noRSEED SEED(integer 0) *]

ereturn clear
	
/* Check the estimator which the user wants to use 
	The default option is parametric estimator. */
	
if "`rseed'" != "norseed" {
	set seed `seed' 
}
	
if "`method'" == "series" {
	clr_s `anything' `if' `in' , `options' 
}

else if "`method'" == "local" {
	clr_k `anything' `if' `in' , `options'
}

else {
	clr_p `anything' `if' `in' , `options'
}

ereturn local cmd = "clrbound"

end
